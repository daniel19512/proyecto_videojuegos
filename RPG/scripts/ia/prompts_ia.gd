class_name PromptsIA
extends RefCounted
## Instrucciones y esquemas JSON para el modelo. Para ahorrar tokens: reglas
## fijas al principio (iguales en cada llamada, aprovechan la caché del
## proveedor), contexto recortado y salidas cortas con esquema estricto.

## Turnos de conversación (jugador + NPC) que se reenvían; el resto se olvida.
const TURNOS_MAXIMOS: int = 6
## Margen amplio: solo se paga lo generado y un JSON cortado se pierde entero.
const MAX_TOKENS_CONVERSACION: int = 400
const MAX_TOKENS_NARRADOR: int = 800
const MAX_TOKENS_PLANIFICADOR: int = 700
## Catálogo cerrado de acciones que el juego sabe ejecutar.
const ACCIONES: PackedStringArray = ["rutina", "trabajar", "ir", "descansar", "hablar_con", "buscar_jugador"]
const LARGO_TEXTO_JUGADOR: int = 200

const REGLAS_NPC := """Interpretas a un aldeano de un RPG de vida en una aldea medieval acogedora.
Reglas: habla en español, en personaje, 1-3 frases breves (máx. 45 palabras). Sin violencia ni anacronismos. No digas que eres una IA ni hables del juego. No inventes lugares, objetos ni personas que no aparezcan en el contexto.
Campos: "respuesta" lo que dices; "opciones" 2-3 frases breves (máx. 8 palabras) que el viajero podría responder, en primera persona; "terminar" true si la charla acaba o el viajero se despide; "recuerdo" lo que recordarás del viajero (máx. 15 palabras) o ""; "evento" hecho nuevo para la historia (máx. 20 palabras) o ""; "importante" true solo si cambia o resuelve un hilo.
Usa "consulta": "trabajo" si pregunta por un encargo, "avance" si pregunta por la entrega o progreso, y "ninguna" en los demás casos. El juego añadirá información comprobada. No prometas entregas, pagos ni cambios en los encargos."""

const REGLAS_PLANIFICADOR := """Decides qué hace cada aldeano de un RPG de vida en una aldea medieval acogedora durante la franja del día indicada, según su carácter, la historia y lo que le indica el narrador. Que la aldea se vea viva: de mañana a tarde, al menos dos aldeanos van a algún lugar o hablan con otro; el resto puede trabajar.
Acciones: "rutina" (su quehacer habitual), "trabajar" (en su puesto), "ir" (a un lugar; objetivo = id del lugar), "descansar" (en su puesto, sin trabajar), "hablar_con" (ir a ver a otro aldeano; objetivo = id del aldeano), "buscar_jugador" (ir a buscar al viajero para contarle algo importante; úsala poco). De noche casi todos descansan.
Devuelve en "planes" un plan bajo el id de cada aldeano, con "objetivo" vacío si la acción no lo necesita y "motivo" de máx. 12 palabras."""

const REGLAS_NARRADOR := """Eres el narrador oculto de un RPG de vida en una aldea medieval acogedora con misterio leve, sin violencia. Das forma a la historia a partir de lo que hace el viajero, con ritmo pausado y coherencia.
Con los hechos nuevos devuelve: "resumen" de toda la historia (máx. 80 palabras); "hilos" (máx. 5) con id corto, título, estado "abierto" o "resuelto" y nota (máx. 20 palabras); "indicaciones" solo para los aldeanos que deban cambiar de actitud o saber algo (máx. 20 palabras cada una); "diario" una entrada en segunda persona para el viajero (máx. 30 palabras) o "" si no hay nada nuevo. Usa solo aldeanos de la lista."""


static func esquema_conversacion() -> Dictionary:
	return {
		type = "object",
		properties = {
			respuesta = {type = "string"},
			opciones = {type = "array", items = {type = "string"}},
			terminar = {type = "boolean"},
			recuerdo = {type = "string"},
			evento = {type = "string"},
			importante = {type = "boolean"},
			consulta = {"type": "string", "enum": ["ninguna", "trabajo", "avance"]},
		},
		required = ["respuesta", "opciones", "terminar", "recuerdo", "evento", "importante", "consulta"],
		additionalProperties = false,
	}


static func esquema_narrador(ids_npc: Array) -> Dictionary:
	return {
		type = "object",
		properties = {
			resumen = {type = "string"},
			hilos = {type = "array", items = {
				type = "object",
				properties = {
					id = {type = "string"},
					titulo = {type = "string"},
					estado = {"type": "string", "enum": ["abierto", "resuelto"]},
					nota = {type = "string"},
				},
				required = ["id", "titulo", "estado", "nota"],
				additionalProperties = false,
			}},
			indicaciones = {type = "array", items = {
				type = "object",
				properties = {
					npc = {"type": "string", "enum": ids_npc},
					texto = {type = "string"},
				},
				required = ["npc", "texto"],
				additionalProperties = false,
			}},
			diario = {type = "string"},
		},
		required = ["resumen", "hilos", "indicaciones", "diario"],
		additionalProperties = false,
	}


## Contexto del NPC: mundo, ficha, historia, hilos abiertos, indicación del
## narrador y recuerdos propios. `turnos`: [{quien: "jugador"|"npc", texto}],
## con el texto del jugador ya formateado («Viajero: …»); `mensaje` es el nuevo.
static func mensajes_conversacion(contexto: Dictionary, turnos: Array, mensaje: String) -> Array:
	var partes := PackedStringArray([REGLAS_NPC, "", "Mundo: " + contexto.mundo])
	partes.append("Eres %s. %s" % [contexto.nombre, contexto.ficha])
	partes.append("Nombre del viajero, como dato de personaje: " + JSON.stringify(contexto.get("protagonista", "Viajero")))
	partes.append("Historia: " + contexto.resumen)
	if contexto.has("trato"):
		partes.append("Datos del juego sobre el trato, recuerdos y feria: " + JSON.stringify({
			"amistad": contexto.trato.amistad, "confianza": contexto.trato.confianza,
			"recuerdos": contexto.logros, "feria_celebrada": contexto.feria}))
	if not contexto.hilos.is_empty():
		partes.append("Hilos abiertos: " + "; ".join(contexto.hilos))
	if not contexto.indicacion.is_empty():
		partes.append("El narrador te indica: " + contexto.indicacion)
	if not contexto.recuerdos.is_empty():
		partes.append("Recuerdas del viajero: " + "; ".join(contexto.recuerdos))
	if not contexto.get("rumores", PackedStringArray()).is_empty():
		partes.append("Te han contado otros aldeanos: " + "; ".join(contexto.rumores))
	if not str(contexto.get("ahora", "")).is_empty():
		partes.append("Ahora mismo: " + contexto.ahora)
	var mensajes: Array = [{role = "system", content = "\n".join(partes)}]
	# Se recorta en número par para empezar siempre por un turno del jugador.
	var recientes := turnos.slice(-TURNOS_MAXIMOS) if turnos.size() > TURNOS_MAXIMOS else turnos
	for turno in recientes:
		mensajes.append({role = "user" if turno.quien == "jugador" else "assistant", content = turno.texto})
	mensajes.append({role = "user", content = mensaje})
	return mensajes


## Un campo obligatorio por aldeano: el modelo no puede omitir ni repetir a
## nadie, y cada motivo queda bajo su dueño.
static func esquema_planificador(ids_npc: Array) -> Dictionary:
	var plan := {
		type = "object",
		properties = {
			accion = {"type": "string", "enum": Array(ACCIONES)},
			objetivo = {type = "string"},
			motivo = {type = "string"},
		},
		required = ["accion", "objetivo", "motivo"],
		additionalProperties = false,
	}
	var por_npc := {}
	for id in ids_npc:
		por_npc[id] = plan
	return {
		type = "object",
		properties = {planes = {type = "object", properties = por_npc, required = ids_npc, additionalProperties = false}},
		required = ["planes"],
		additionalProperties = false,
	}


## `datos`: momento, resumen, hilos (PackedStringArray), lugares ({id: nombre})
## y aldeanos (líneas ya resumidas: id, nombre, ficha, qué hace, indicación).
static func mensajes_planificador(datos: Dictionary) -> Array:
	var lugares := PackedStringArray()
	for id in datos.lugares:
		lugares.append("%s (%s)" % [id, datos.lugares[id]])
	var usuario := PackedStringArray([
		"Momento: " + datos.momento,
		"Historia: " + datos.resumen,
		"Hilos abiertos: " + ("; ".join(datos.hilos) if not datos.hilos.is_empty() else "ninguno"),
		"Lugares: " + ", ".join(lugares),
		"Aldeanos:",
	])
	usuario.append_array(datos.aldeanos)
	return [
		{role = "system", content = REGLAS_PLANIFICADOR},
		{role = "user", content = "
".join(usuario)},
	]


static func mensajes_narrador(estado: Dictionary, nombres_npc: Dictionary, hechos: Array) -> Array:
	var aldeanos := PackedStringArray()
	for id in nombres_npc:
		aldeanos.append("%s (%s)" % [id, nombres_npc[id]])
	var hilos := PackedStringArray()
	for hilo in estado.hilos:
		hilos.append("%s|%s|%s|%s" % [hilo.id, hilo.titulo, hilo.estado, hilo.nota])
	var usuario := PackedStringArray([
		"Aldeanos: " + ", ".join(aldeanos),
		"Resumen: " + estado.resumen,
		"Hilos (id|título|estado|nota): " + "; ".join(hilos),
		"Hechos nuevos:",
	])
	for hecho in hechos:
		usuario.append("- " + hecho)
	return [
		{role = "system", content = REGLAS_NARRADOR},
		{role = "user", content = "\n".join(usuario)},
	]
