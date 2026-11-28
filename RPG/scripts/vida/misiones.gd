extends CanvasLayer
## El catálogo es inmutable. El progreso, las instancias y la economía viven en EstadoMundo.

signal actualizado

const Bolsa = preload("res://scripts/vida/bolsa.gd")
const Catalogo = preload("res://scripts/vida/catalogo.gd")
const Oficios = preload("res://scripts/vida/oficios.gd")
const Hallazgos = preload("res://scripts/vida/descubrimientos.gd")
const RUTA := "res://data/vida/misiones.json"
const MAX_DINAMICAS := 5
const DIAS_ENTRE_ENCARGOS := 1
const CAPITULOS := ["Una nueva vida", "El valor del trabajo", "Caminos por descubrir",
	"Ecos del pasado", "El renacer de la comunidad"]
const ACTIVAS := ["aceptada", "en_progreso", "lista"]
const NOMBRES := {"hablar": "Conversar con", "visitar": "Visitar", "recoger": "Recoger",
	"sembrar": "Sembrar", "cosechar": "Cosechar", "pescar": "Pescar", "extraer": "Extraer",
	"fabricar": "Fabricar", "minijuego": "Completar actividad de", "comercio": "Comerciar",
	"descubrir": "Examinar", "reliquia": "Registrar reliquia", "entregar": "Entregar",
	"amistad": "Amistad con", "confianza": "Confianza con", "nivel": "Nivel de",
	"mision": "Completar", "intro": "Encargos introductorios completados", "decision": "Elegir",
	"cualquiera": "Actividades completadas", "confianzas": "Habitantes que confían en ti",
	"excursion": "Volver a visitar", "examinar": "Volver a examinar",
	"feria": "Visitar los puestos de la feria"}

var catalogo: Dictionary
var _panel: PanelContainer
var _lista: VBoxContainer
var _titulo: Label
var _desplazamiento: ScrollContainer
var _npc := ""
var _volver: Callable
var _recado_fijo: Callable
var _tienda := ""
var _detalle := ""
var _sesion := 0
var _solicitando := false
var _seguimiento: Label


func _ready() -> void:
	catalogo = JSON.parse_string(FileAccess.get_file_as_string(RUTA))
	EstadoMundo.actividad_registrada.connect(_al_registrar)
	EstadoMundo.apariencia_cambiada.connect(func(_id): actualizado.emit())
	GestorRegiones.finalizada.connect(_visita)
	layer = 41
	process_mode = Node.PROCESS_MODE_ALWAYS
	_construir()
	actualizado.connect(_refrescar_seguimiento)


func ficha(id: String) -> Dictionary:
	return catalogo.get(id, EstadoMundo.datos.zonas.get("@misiones_dinamicas", {}).get(id, {}))


func registro(id: String) -> Dictionary:
	return EstadoMundo.datos.zonas.get("@misiones", {}).get(id, {})


func relacion(npc: String) -> Dictionary:
	var guardada: Dictionary = EstadoMundo.datos.zonas.get("@relaciones", {}).get(npc, {})
	if not guardada.is_empty():
		return guardada
	var visitas := int(EstadoMundo.datos.zonas.get("Aldea", {}).get("npc_" + npc, {}).get("conversaciones", 0))
	var recado_anterior := npc == "panadera" and estado("recado_pan") == "completada"
	return {"amistad": mini(visitas, 12) + (3 if recado_anterior else 0), "confianza": 5 if recado_anterior else 0}


func _ajustar(npc: String, amistad: int, confianza: int) -> Dictionary:
	var anterior := relacion(npc)
	var datos := EstadoMundo.objeto("@relaciones", npc)
	datos.amistad = clampi(int(anterior.amistad) + amistad, 0, 100)
	datos.confianza = clampi(int(anterior.confianza) + confianza, 0, 100)
	return datos


func conversar(npc: String) -> void:
	if not Historia.tiene_npc(npc):
		return
	var dia := _dia()
	if relacion(npc).get("saludo", -1) != dia:
		_ajustar(npc, 1, 0).saludo = dia
	EstadoMundo.registrar_actividad("hablar", npc)


func _dia() -> int:
	return floori(Reloj.tiempo_juego / Reloj.DURACION_DIA)


func _visita(region: StringName) -> void:
	EstadoMundo.registrar_actividad("visitar", String(region))


func _al_registrar(_tipo: String, _id: String) -> void:
	actualizado.emit()


func estado(id: String) -> String:
	var m := ficha(id)
	if m.is_empty():
		return "bloqueada"
	if id == "recado_pan":
		var fase := int(EstadoMundo.datos.zonas.get("Aldea", {}).get(id, {}).get("fase", 0))
		return ["disponible", "en_progreso", "lista", "completada"][clampi(fase, 0, 3)]
	var datos := registro(id)
	var fase: String = datos.get("estado", "")
	if fase in ACTIVAS:
		var avance := false
		var lista := true
		for objetivo in m.objetivos:
			var actual := progreso(id, objetivo)
			avance = avance or actual > 0
			lista = lista and actual >= int(objetivo[2])
		if lista:
			return "lista"
		return "en_progreso" if avance else "aceptada"
	if not fase.is_empty():
		return fase
	for previo in m.get("previas", []):
		if estado(previo) != "completada":
			return "bloqueada"
	var trato := relacion(m.npc)
	if trato.amistad < int(m.get("amistad", 0)) or trato.confianza < int(m.get("confianza", 0)):
		return "bloqueada"
	return "disponible"


func progreso(id: String, objetivo: Array) -> int:
	var tipo: String = objetivo[0]
	var clave: String = objetivo[1]
	var historial: Dictionary = EstadoMundo.datos.zonas.get("@actividades", {})
	match tipo:
		"excursion":
			return _desde(id, historial, "visitar", clave, false)
		"hablar":
			var antigua := int(EstadoMundo.datos.zonas.get("Aldea", {}).get("npc_" + clave, {}).get("conversaciones", 0))
			return maxi(antigua, _cuenta(historial, tipo, clave)) if objetivo.size() > 3 else _desde(id, historial, tipo, clave, false)
		"visitar":
			if clave == String(GestorRegiones.region_actual):
				return 1
			return _cuenta(historial, tipo, clave)
		"descubrir", "reliquia":
			var dato: Dictionary = EstadoMundo.datos.zonas.get("@descubrimientos", {}).get(clave, {})
			return int(dato.get("descubierto" if tipo == "descubrir" else "reliquia_recogida", false))
		"nivel":
			return Oficios.nivel(clave)
		"amistad", "confianza":
			return int(relacion(clave)[tipo])
		"entregar":
			var cantidad := 0
			for opcion in clave.split("/"):
				cantidad = maxi(cantidad, Bolsa.cantidad(Bolsa.jugador(), opcion))
			return cantidad
		"mision":
			return int(estado(clave) == "completada")
		"intro":
			var total := 0
			for otra in catalogo:
				if catalogo[otra].tipo == "intro" and estado(otra) == "completada":
					total += 1
			return total
		"confianzas":
			var total := 0
			for npc in Historia.nombres_npc():
				if relacion(npc).confianza >= 5:
					total += 1
			return total
		"cualquiera":
			var total := 0
			for opcion in objetivo[3]:
				total += mini(int(opcion[2]), progreso(id, opcion))
			return total
	return _desde(id, historial, tipo, clave, objetivo.size() > 3 and objetivo[3] == true)


func _cuenta(historial: Dictionary, tipo: String, clave: String) -> int:
	return int(historial.get(tipo, {}).get(clave, 0))


func _desde(id: String, historial: Dictionary, tipo: String, clave: String, historico: bool) -> int:
	var base: Dictionary = registro(id).get("base", {})
	return maxi(0, _cuenta(historial, tipo, clave) - (0 if historico else _cuenta(base, tipo, clave)))


func ofrecer(id: String, npc: String) -> bool:
	var m := ficha(id)
	if id == "recado_pan" or estado(id) != "disponible" or m.npc != npc:
		return false
	EstadoMundo.objeto("@misiones", id).estado = "ofrecida"
	return true


func aceptar(id: String, npc: String) -> bool:
	var m := ficha(id)
	if estado(id) not in ["ofrecida", "abandonada"] or m.npc != npc:
		return false
	var datos := EstadoMundo.objeto("@misiones", id)
	if not datos.has("base"):
		datos.base = EstadoMundo.datos.zonas.get("@actividades", {}).duplicate(true)
	datos.estado = "aceptada"
	materiales(id, npc)
	EstadoMundo.guardar_actual()
	actualizado.emit()
	return true


func materiales(id: String, npc: String) -> bool:
	var m := ficha(id)
	if estado(id) not in ACTIVAS or m.npc != npc or not m.has("receta"):
		return false
	var receta: Dictionary = Oficios.RECETAS[m.receta]
	var cantidad := int(m.get("tandas", 1))
	var insumos := {}
	for clave in receta.ingredientes:
		insumos[clave] = int(receta.ingredientes[clave]) * cantidad
	if not Oficios.entregar_materiales(id, insumos, false):
		return false
	EstadoMundo.guardar_actual()
	return true


func entregar(id: String, npc: String) -> bool:
	var m := ficha(id)
	if id == "recado_pan" or estado(id) != "lista" or m.get("receptor", m.npc) != npc:
		return false
	var monedas := int(m.monedas)
	var pago := false
	for objetivo in m.objetivos:
		if objetivo[0] == "entregar":
			var se_entrego := false
			for opcion in objetivo[1].split("/"):
				if Oficios.entregar_producto(id, opcion, int(objetivo[2]), monedas, false):
					se_entrego = true
					break
			if not se_entrego:
				return false
			pago = true
	if not pago:
		EstadoMundo.datos.monedas += monedas
	var datos := EstadoMundo.objeto("@misiones", id)
	datos.estado = "completada"
	datos.dia = _dia()
	_reconocer(id, m)
	if id == "principal_15":
		EstadoMundo.objeto("@social", "feria").terminada = true
	EstadoMundo.guardar_actual()
	actualizado.emit()
	return true


func abandonar(id: String, npc: String) -> bool:
	var m := ficha(id)
	if m.get("tipo") != "dinamica" or m.npc != npc or estado(id) not in ACTIVAS:
		return false
	registro(id).estado = "abandonada"
	EstadoMundo.guardar_actual()
	actualizado.emit()
	return true


func reconocer_recado() -> void:
	var datos := EstadoMundo.objeto("@misiones", "recado_pan")
	if datos.get("reconocido", false):
		return
	datos.reconocido = true
	_reconocer("recado_pan", ficha("recado_pan"), not EstadoMundo.zona("@relaciones").has("panadera"))
	actualizado.emit()


func _reconocer(id: String, m: Dictionary, migrado: bool = false) -> void:
	var personal: bool = m.tipo == "personal"
	if not migrado:
		_ajustar(m.npc, 10 if personal else 3, 10 if personal else 5)
	var reputacion := EstadoMundo.objeto("@social", "reputacion")
	if m.tipo != "dinamica":
		reputacion[m.region] = mini(100, int(reputacion.get(m.region, 0)) + (5 if personal else 2))
	var recuerdos := EstadoMundo.objeto("@social", "recuerdos")
	var logros: Array = recuerdos.get(m.npc, [])
	var recuerdo := {"id": id, "texto": m.cierre, "region": m.region, "dia": _dia(), "tema": m.tipo}
	logros.append(recuerdo)
	while logros.size() > 8:
		logros.pop_front()
	recuerdos[m.npc] = logros
	if m.tipo in ["personal", "principal"]:
		EstadoMundo.objeto("@social", "hitos")[id] = recuerdo
	if m.tipo == "dinamica":
		EstadoMundo.objeto("@social", "ultimo_encargo")[m.npc] = {"dia": _dia(), "objeto": m.variante}
		EstadoMundo.zona("@misiones_dinamicas").erase(id)
		EstadoMundo.zona("@misiones").erase(id)


func compartir_recuerdo(origen: String, receptor: String) -> String:
	var logros: Array = EstadoMundo.objeto("@social", "recuerdos").get(origen, [])
	if logros.is_empty():
		return ""
	var evento: Dictionary = logros.back()
	var datos := EstadoMundo.objeto("@rumores", receptor)
	var recibidos: Array = datos.get("registros", [])
	if recibidos.any(func(rumor): return rumor.id == evento.id):
		return ""
	var rumor := evento.duplicate()
	rumor.origen = origen
	rumor.receptor = receptor
	rumor.recibido = _dia()
	rumor.conocido = true
	recibidos.append(rumor)
	datos.registros = recibidos.slice(-8)
	return "El viajero me ayudó con un encargo. " + evento.texto


func saludo(npc: String) -> String:
	var trato := relacion(npc)
	var rumores: Array = EstadoMundo.datos.zonas.get("@rumores", {}).get(npc, {}).get("registros", [])
	if not rumores.is_empty():
		var origen: String = Historia.nombres_npc().get(rumores.back().origen, "")
		return "%s me habló de la ayuda que le prestaste." % origen
	if EstadoMundo.datos.zonas.get("@social", {}).get("feria", {}).get("terminada", false):
		return "Todavía se habla de la feria. Fue bueno volver a compartir la plaza."
	if trato.amistad >= 40:
		return "Me alegra verte de nuevo, %s." % EstadoMundo.nombre_protagonista()
	if trato.confianza >= 20:
		return "Si sale algún trabajo importante, sé que puedo contar contigo."
	return ""


func consulta_dialogo(npc: String, consulta: Variant) -> String:
	if not consulta is String or consulta not in ["trabajo", "avance"]:
		return ""
	for id in catalogo.keys() + EstadoMundo.datos.zonas.get("@misiones_dinamicas", {}).keys():
		var m := ficha(id)
		var fase := estado(id)
		if consulta == "trabajo" and m.npc == npc and fase in ["disponible", "ofrecida"]:
			return "Puedo hablarte de «%s» si eliges el encargo en nuestro menú." % m.titulo
		if consulta == "avance" and fase in ACTIVAS and npc in [m.npc, m.get("receptor", m.npc)]:
			if fase == "lista":
				return "Ya se puede entregar «%s» a %s." % [m.titulo, _nombre_objetivo(m.get("receptor", m.npc))]
			return "«%s» sigue abierto. En el diario están los objetivos que quedan." % m.titulo
	return ""


func regalar(npc: String, indice: int) -> String:
	if not Historia.tiene_npc(npc):
		return "El habitante no está disponible."
	if relacion(npc).get("regalo", -1) == _dia():
		return "Ya compartiste un regalo hoy."
	var bolsa := Bolsa.jugador()
	if indice < 0 or indice >= bolsa.size() or not bolsa[indice] is Dictionary:
		return "El objeto ya no está en la mochila."
	var id: String = bolsa[indice].id
	if not _regalable(id):
		return "Este objeto se guarda para su uso original."
	var perfil: Dictionary = ficha("intro_" + npc if npc != "panadera" else "recado_pan")
	var preferencia: Array = perfil.get("gustos", [])
	if preferencia.size() != 3:
		return "Este habitante todavía no acepta regalos."
	var puntos := 1
	if id == preferencia[0]:
		puntos = 10
	elif id == preferencia[1]:
		puntos = 5
	elif id == preferencia[2]:
		puntos = -2
	if not Bolsa.quitar(bolsa, indice, 1):
		return "El objeto ya no está en la mochila."
	var trato := _ajustar(npc, puntos, 0)
	trato.regalo = _dia()
	var preferencias: Dictionary = trato.get("preferencias", {})
	preferencias[id] = {10: "favorito", 5: "le gusta", 1: "neutral", -2: "no le gusta"}[puntos]
	trato.preferencias = preferencias
	EstadoMundo.guardar_actual()
	actualizado.emit()
	return {10: "¡Mi favorito! Gracias por acordarte.", 5: "Me gusta mucho. Gracias.",
		1: "Gracias por el detalle.", -2: "Gracias por pensar en mí. No suelo usar esto."}[puntos]


func _regalable(id: String) -> bool:
	return id not in ["ficha_pesaje", "recuerdo", "azada", "regadera", "pico", "hacha", "cana"]


func solicitar(npc: String) -> String:
	var introduccion := ficha("intro_" + npc if npc != "panadera" else "recado_pan")
	if introduccion.is_empty():
		return ""
	var instancias := EstadoMundo.zona("@misiones_dinamicas")
	for id in instancias:
		if instancias[id].npc == npc:
			return id
	if instancias.size() >= MAX_DINAMICAS or relacion(npc).confianza < 5:
		return ""
	var anterior: Dictionary = EstadoMundo.objeto("@social", "ultimo_encargo").get(npc, {})
	if anterior.has("dia") and int(anterior.dia) + DIAS_ENTRE_ENCARGOS > _dia():
		return ""
	var candidatos: Array = [["entregar", introduccion.gustos[0], 1], ["entregar", introduccion.gustos[1], 1]]
	for base in introduccion.objetivos:
		var tipo: String = base[0]
		if tipo in ["entregar", "reliquia", "cualquiera", "mision"]:
			continue
		var tipo_repetible: String = {"visitar": "excursion", "descubrir": "examinar"}.get(tipo, tipo)
		candidatos.push_front([tipo_repetible, base[1], base[2]])
	var objetivo: Array = candidatos[0]
	for candidato in candidatos:
		if _variante(candidato) != anterior.get("objeto", ""):
			objetivo = candidato
			break
	var objeto: String = objetivo[1]
	var precio := int(Catalogo.ficha(objeto).get("compra", 0))
	var nombre: String = _nombre_objetivo(objeto)
	EstadoMundo.datos.serie += 1
	var id := "encargo_%d" % EstadoMundo.datos.serie
	var titulo := "Un trabajo para " + str(Historia.nombres_npc().get(npc, npc))
	instancias[id] = {"tipo": "dinamica", "titulo": titulo, "npc": npc, "region": introduccion.region,
		"objetivos": [objetivo.duplicate(true)], "monedas": clampi(precio + 3, 4, 18),
		"variante": _variante(objetivo), "oferta": "Me vendría bien tu ayuda con %s. ¿Puedes hacerlo cuando tengas ocasión?" % nombre,
		"aceptacion": "Gracias. Puedes tomarte tu tiempo.", "cierre": "Con esto puedo seguir trabajando. Gracias."}
	if objetivo[0] == "fabricar" and introduccion.has("receta"):
		instancias[id].receta = introduccion.receta
		instancias[id].objetivos.append(["entregar", objeto, int(objetivo[2])])
	ofrecer(id, npc)
	EstadoMundo.guardar_actual()
	return id


func _variante(objetivo: Array) -> String:
	return "%s/%s" % [objetivo[0], objetivo[1]]


func ambientar_encargo(id: String) -> void:
	var m := ficha(id)
	if m.is_empty() or m.get("ambientado", false) or estado(id) != "ofrecida":
		return
	m.ambientado = true
	if not IA.disponible():
		return
	var esquema := {"type": "object", "properties": {
		"titulo": {"type": "string"}, "motivo": {"type": "string"}},
		"required": ["titulo", "motivo"], "additionalProperties": false}
	var contexto := Historia.contexto(m.npc)
	var mensajes := [
		{"role": "system", "content": "Escribe un título y una frase en español medieval para un encargo opcional sin plazo. Expresa solo una intención del personaje. Mantén exactamente la actividad indicada. El objetivo, objetos, cantidades y pago son fijos y los muestra el juego. No menciones recompensas, fechas ni acontecimientos inventados."},
		{"role": "user", "content": JSON.stringify({"npc": contexto.nombre, "ficha": contexto.ficha, "actividad": _objetivo(id, m.objetivos[0])})},
	]
	var resultado := await IA.solicitar(mensajes, "texto_encargo", esquema, 240)
	if resultado.ok and ficha(id) == m and estado(id) == "ofrecida":
		aplicar_texto_encargo(id, resultado.datos)
	EstadoMundo.guardar_actual()


func aplicar_texto_encargo(id: String, propuesta: Dictionary) -> bool:
	var m := ficha(id)
	if m.get("tipo") != "dinamica" or estado(id) != "ofrecida" or propuesta.size() != 2:
		return false
	for clave in ["titulo", "motivo"]:
		var valor: Variant = propuesta.get(clave)
		if not valor is String or valor.length() > (72 if clave == "titulo" else 220):
			return false
		if valor.strip_edges().is_empty() or valor.contains("\n") or valor.contains("[") or valor.contains("]"):
			return false
	m.titulo = propuesta.titulo.strip_edges()
	m.oferta = propuesta.motivo.strip_edges()
	return true


func resumen(principales: bool) -> PackedStringArray:
	var partes := PackedStringArray()
	var capitulo_actual := 0
	for id in catalogo.keys() + EstadoMundo.datos.zonas.get("@misiones_dinamicas", {}).keys():
		var fase := estado(id)
		var m := ficha(id)
		if (m.tipo == "principal") != principales or fase == "bloqueada" or (fase == "disponible" and not principios_conocidos(m)):
			continue
		var receptor: String = m.get("receptor", m.npc)
		var nombre := _nombre_objetivo(receptor)
		var region: String = Historia.poblacion.get(receptor, {}).get("region", "Aldea")
		var estados := {"lista": "lista para entregar", "en_progreso": "en progreso"}
		if principales and int(m.capitulo) != capitulo_actual:
			capitulo_actual = int(m.capitulo)
			partes.append("[b]Capítulo %d · %s[/b]" % [capitulo_actual, CAPITULOS[capitulo_actual - 1]])
		var marca := "★ " if seguida() == id else ""
		partes.append("%s[b]%s[/b] · %s · %s (%s)" % [marca, m.titulo, estados.get(fase, fase), nombre, _nombre_objetivo(region)])
		if fase in ACTIVAS:
			partes.append("  %s · %d monedas · Sin plazo" % [m.oferta.replace("[", "(").replace("]", ")"), int(m.monedas)])
			if m.has("receta") and not EstadoMundo.datos.zonas.get("@encargos_oficio", {}).get(id, {}).get("materiales", false):
				partes.append("  Materiales disponibles con " + _nombre_objetivo(m.npc))
			for objetivo in m.objetivos:
				partes.append("  " + _objetivo(id, objetivo))
	return partes


func principios_conocidos(m: Dictionary) -> bool:
	return m.tipo == "principal" or progreso("", ["hablar", m.npc, 1, true]) > 0


func resumen_relaciones() -> PackedStringArray:
	var partes := PackedStringArray()
	var nombres := Historia.nombres_npc()
	for npc in nombres:
		if progreso("", ["hablar", npc, 1, true]) == 0:
			continue
		var trato := relacion(npc)
		var m := ficha("recado_pan" if npc == "panadera" else "intro_" + npc)
		var ubicacion := Aldeanos.descripcion(npc)
		var profesiones := {"pescador": "Pescador", "panadera": "Panadera", "herrero": "Herrero", "guardia": "Guardia", "tabernero": "Tabernero"}
		var profesion: String = Historia.poblacion.get(npc, {}).get("profesion", profesiones.get(npc, ""))
		partes.append("[b]%s[/b] · %s · %s" % [nombres[npc], profesion, _nombre_objetivo(m.get("region", ""))])
		partes.append("  " + ubicacion)
		var amistad := ["desconocido", "conocido", "cercano", "amigo", "mejor amigo"]
		var confianza := ["inicial", "básica", "moderada", "alta", "plena"]
		partes.append("  Amistad %d/100 (%s) · Confianza %d/100 (%s)" % [
			trato.amistad, amistad[mini(floori(trato.amistad / 20.0), 4)],
			trato.confianza, confianza[mini(floori(trato.confianza / 20.0), 4)]])
		var preferencias: Dictionary = trato.get("preferencias", {})
		for objeto in preferencias:
			partes.append("  %s · %s" % [_nombre_objetivo(objeto), preferencias[objeto]])
	var reputacion: Dictionary = EstadoMundo.datos.zonas.get("@social", {}).get("reputacion", {})
	for region in reputacion:
		partes.append("Reputación en %s · %d/100" % [_nombre_objetivo(region), reputacion[region]])
	return partes


func acontecimientos() -> PackedStringArray:
	var partes := PackedStringArray()
	var hitos: Dictionary = EstadoMundo.datos.zonas.get("@social", {}).get("hitos", {})
	var recientes := hitos.keys().slice(-6)
	recientes.reverse()
	for id in recientes:
		partes.append("• [b]%s[/b] — %s" % [ficha(id).titulo, hitos[id].texto])
	return partes


func seguir(id: String) -> void:
	EstadoMundo.objeto("@social", "seguimiento").id = id
	EstadoMundo.guardar_actual()
	actualizado.emit()


func alternar_seguimiento(principales: bool) -> void:
	var opciones := PackedStringArray([""])
	for id in catalogo.keys() + EstadoMundo.datos.zonas.get("@misiones_dinamicas", {}).keys():
		var m := ficha(id)
		if (m.tipo == "principal") == principales and estado(id) in ACTIVAS and id != "recado_pan":
			opciones.append(id)
	seguir(opciones[posmod(opciones.find(seguida()) + 1, opciones.size())])


func seguida() -> String:
	return EstadoMundo.datos.zonas.get("@social", {}).get("seguimiento", {}).get("id", "")


func _refrescar_seguimiento() -> void:
	var id := seguida()
	var fase := estado(id)
	_seguimiento.visible = fase in ACTIVAS
	if not _seguimiento.visible:
		return
	var m := ficha(id)
	_seguimiento.text = m.titulo + "\n"
	for objetivo in m.objetivos:
		if progreso(id, objetivo) < int(objetivo[2]):
			_seguimiento.text += _objetivo(id, objetivo)
			return
	_seguimiento.text += "Habla con " + _nombre_objetivo(m.get("receptor", m.npc))


func _objetivo(id: String, objetivo: Array) -> String:
	var clave: String = objetivo[1]
	var nombre := _nombre_objetivo(clave)
	if objetivo[0] in ["nivel", "minijuego"]:
		nombre = Oficios.OFICIOS.get(clave, [clave])[0]
	if objetivo[0] == "feria":
		nombre = ""
	if objetivo[0] == "cualquiera":
		var opciones := PackedStringArray()
		for opcion in objetivo[3]:
			opciones.append(_objetivo(id, opcion))
		nombre = " · ".join(opciones)
	return "%s %s (%d/%d)" % [NOMBRES.get(objetivo[0], objetivo[0]), nombre,
		mini(progreso(id, objetivo), int(objetivo[2])), int(objetivo[2])]


func _nombre_objetivo(clave: String) -> String:
	var alias := {"InteriorE02": "Panadería", "TabernaE01": "Taberna", "CamposYGranjas": "Campos y Granjas",
		"Montanas": "Montañas", "proponer_feria": "cómo proponer la feria", "acuerdo_feria": "cómo abrir la feria",
		"pescado/carpa_dorada": "pescado o carpa dorada", "operacion": "en una tienda"}
	return alias.get(clave, Hallazgos.PUNTOS.get(clave, {}).get("titulo", Catalogo.ficha(clave).get("nombre",
		Historia.nombres_npc().get(clave, ficha(clave).get("titulo", clave)))))


func tiene_aviso(npc: String) -> bool:
	for id in catalogo:
		var m: Dictionary = catalogo[id]
		if m.npc == npc and m.tipo == "principal" and estado(id) in ["disponible", "ofrecida"]:
			return true
		if m.get("receptor", m.npc) == npc and registro(id).get("estado", "") in ACTIVAS and estado(id) == "lista":
			return true
	return false


func abrir(npc: String, hablar: Callable, recado_fijo: Callable, tienda: String = "") -> void:
	_sesion += 1
	_npc = npc
	_volver = hablar
	_recado_fijo = recado_fijo
	_tienda = tienda
	_panel.get_parent().show()
	get_tree().paused = true
	_inicio()


func _input(evento: InputEvent) -> void:
	if _panel == null or not _panel.is_visible_in_tree():
		return
	if evento.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_cerrar()
	elif evento.is_action_pressed("interactuar") and not evento.is_action_pressed("ui_accept"):
		var foco := get_viewport().gui_get_focus_owner() as Button
		if foco and foco.get_parent() == _lista and not foco.disabled:
			get_viewport().set_input_as_handled()
			InterfazVida.registrar_interaccion_mundo()
			foco.pressed.emit()
	elif evento.is_action_pressed("ui_down") or evento.is_action_pressed("ui_up"):
		var botones := _lista.get_children().filter(func(nodo): return nodo is Button)
		if not botones.is_empty():
			var foco := botones.find(get_viewport().gui_get_focus_owner())
			var paso := 1 if evento.is_action_pressed("ui_down") else -1
			botones[clampi(foco + paso, 0, botones.size() - 1)].grab_focus()
		get_viewport().set_input_as_handled()


func _inicio() -> void:
	_detalle = ""
	_limpiar(Historia.nombres_npc().get(_npc, _npc))
	var trato := relacion(_npc)
	_texto("Amistad %d/100  ·  Confianza %d/100" % [trato.amistad, trato.confianza])
	_boton("Conversar", _hablar)
	if Historia.tiene_npc(_npc):
		var perfil: Dictionary = Historia.poblacion.get(_npc, {})
		var profesion: String = perfil.get("profesion", "")
		var tema: String = perfil.get("conoce", Historia.contexto(_npc).ficha)
		if not profesion.is_empty() or not tema.is_empty():
			_boton("Preguntar por su oficio", _tema.bind(profesion.capitalize(), tema))
		if trato.amistad >= 20 and perfil.has("historia"):
			_boton("Preguntar por su historia", _tema.bind("Su historia", perfil.historia))
	for id in catalogo.keys() + EstadoMundo.datos.zonas.get("@misiones_dinamicas", {}).keys():
		if id == "recado_pan":
			continue
		var m := ficha(id)
		var fase := estado(id)
		if (m.npc == _npc and fase != "bloqueada" and fase != "completada") or (m.get("receptor", m.npc) == _npc and fase in ACTIVAS):
			_boton(m.titulo, _mostrar.bind(id))
	if _npc == "panadera" or _npc == "guardia":
		if estado("recado_pan") != "completada":
			_boton("Recado de Marta", _hablar_recado)
	_boton("Pedir un encargo", _pedir)
	_boton("Dar un regalo", _regalos)
	if not _tienda.is_empty():
		_boton("Comerciar", _comerciar)
	_boton("Cerrar", _cerrar)


func _mostrar(id: String, aviso: String = "") -> void:
	_detalle = id
	var m := ficha(id)
	ofrecer(id, _npc)
	var fase := estado(id)
	_limpiar(m.titulo)
	_texto(m.oferta)
	if not aviso.is_empty():
		_texto(aviso)
	for objetivo in m.objetivos:
		_texto(_objetivo(id, objetivo))
	_texto("Recompensa · %d monedas" % int(m.monedas))
	_texto("Sin límite de tiempo")
	if fase in ["ofrecida", "abandonada"]:
		_boton("Aceptar" if fase == "ofrecida" else "Retomar", _aceptar.bind(id))
	if fase in ACTIVAS:
		if m.has("decision") and not registro(id).has("decision"):
			for i in range(1, m.decision.size()):
				_boton(m.decision[i], _decidir.bind(id, i))
		if id == "principal_15" and not feria_abierta():
			_boton("Abrir la feria", _abrir_feria)
		if m.has("receta") and m.npc == _npc and not EstadoMundo.datos.zonas.get("@encargos_oficio", {}).get(id, {}).get("materiales", false):
			_boton("Recoger materiales", _materiales.bind(id))
		if fase == "lista" and m.get("receptor", m.npc) == _npc:
			_boton("Completar", _entregar.bind(id))
		_boton("Dejar de seguir" if seguida() == id else "Seguir misión", _alternar_seguimiento.bind(id))
		if m.tipo == "dinamica" and m.npc == _npc:
			_boton("Dejar el encargo en pausa", _pausar_encargo.bind(id))
	_boton("Volver", _inicio)


func _tema(titulo: String, linea: String) -> void:
	conversar(_npc)
	_mensaje(titulo if not titulo.is_empty() else "Su oficio", linea)


func _alternar_seguimiento(id: String) -> void:
	seguir("" if seguida() == id else id)
	_mostrar(id)


func _pausar_encargo(id: String) -> void:
	if abandonar(id, _npc):
		_inicio()


func _decidir(id: String, opcion: int) -> void:
	var m := ficha(id)
	if estado(id) not in ACTIVAS or _npc not in [m.npc, m.get("receptor", m.npc)] or registro(id).has("decision"):
		return
	registro(id).decision = m.decision[opcion]
	EstadoMundo.registrar_actividad("decision", m.decision[0])
	EstadoMundo.guardar_actual()
	_mostrar(id, "Queda acordado. " + m.decision[opcion] + ".")


func feria_abierta() -> bool:
	return EstadoMundo.datos.zonas.get("@social", {}).get("feria", {}).get("abierta", false)


func feria_en_curso() -> bool:
	return feria_abierta() and not EstadoMundo.datos.zonas.get("@social", {}).get("feria", {}).get("terminada", false)


func _abrir_feria() -> void:
	if _npc != "guardia" or estado("principal_15") not in ACTIVAS or feria_abierta():
		return
	EstadoMundo.objeto("@social", "feria").abierta = true
	EstadoMundo.guardar_actual()
	actualizado.emit()
	_mostrar("principal_15", "Los puestos te esperan en la plaza, junto al Mercado.")


func visitar_puesto(puesto: String) -> void:
	if not feria_abierta():
		return
	var visitas := EstadoMundo.objeto("@social", "feria")
	if visitas.get(puesto, false):
		return
	visitas[puesto] = true
	EstadoMundo.registrar_actividad("feria", "mercado")
	EstadoMundo.guardar_actual()


func _aceptar(id: String) -> void:
	if aceptar(id, _npc):
		_mostrar(id, ficha(id).aceptacion)


func _materiales(id: String) -> void:
	_mostrar(id, "Materiales guardados en la mochila." if materiales(id, _npc) else "Haz espacio en la mochila y vuelve a pedirlos.")


func _entregar(id: String) -> void:
	var m := ficha(id)
	if entregar(id, _npc):
		_mensaje(m.titulo, m.cierre)
	else:
		_mostrar(id, "Revisa la mochila y los objetivos.")


func _pedir() -> void:
	if _solicitando:
		return
	var id := solicitar(_npc)
	if id.is_empty():
		_mensaje("Encargos", "Por ahora no tengo otro encargo disponible.")
	else:
		var sesion := _sesion
		_solicitando = true
		if IA.disponible() and not ficha(id).get("ambientado", false):
			_limpiar("Encargos")
			_texto("Pensando en el próximo encargo…")
			_boton("Cerrar", _cerrar)
		await ambientar_encargo(id)
		_solicitando = false
		if sesion == _sesion and _panel.is_visible_in_tree():
			_mostrar(id)


func _regalos() -> void:
	_limpiar("Elige un regalo")
	var bolsa := Bolsa.jugador()
	for i in bolsa.size():
		if bolsa[i] is Dictionary and _regalable(bolsa[i].id):
			_boton(Catalogo.ficha(bolsa[i].id).nombre, _confirmar_regalo.bind(i))
	_boton("Volver", _inicio)


func _confirmar_regalo(indice: int) -> void:
	_limpiar("Confirmar regalo")
	_texto(Catalogo.ficha(Bolsa.jugador()[indice].id).nombre)
	_boton("Entregar una unidad", _dar.bind(indice))
	_boton("Cancelar", _regalos)


func _dar(indice: int) -> void:
	_mensaje("Regalo", regalar(_npc, indice))


func _mensaje(titulo: String, linea: String) -> void:
	_limpiar(titulo)
	_texto(linea)
	_boton("Volver", _inicio)


func _cerrar() -> void:
	_panel.get_parent().hide()
	get_tree().paused = false


func _comerciar() -> void:
	_cerrar()
	InterfazVida.abrir("tienda", _tienda)


func _hablar() -> void:
	var llamada := _volver
	_cerrar()
	if llamada.is_valid():
		llamada.call()


func _hablar_recado() -> void:
	var llamada := _recado_fijo
	_cerrar()
	if llamada.is_valid():
		llamada.call()


func _limpiar(titulo: String) -> void:
	_titulo.text = titulo
	for hijo in _lista.get_children():
		_lista.remove_child(hijo)
		hijo.queue_free()
	_desplazamiento.set_deferred("scroll_vertical", 0)


func _boton(titulo: String, accion: Callable) -> void:
	var boton := Button.new()
	boton.text = titulo
	boton.pressed.connect(accion)
	_lista.add_child(boton)
	if get_viewport().gui_get_focus_owner() == null:
		boton.grab_focus()


func _texto(linea: String) -> void:
	var etiqueta := Label.new()
	etiqueta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	etiqueta.text = linea
	_lista.add_child(etiqueta)


func _construir() -> void:
	_seguimiento = Label.new()
	_seguimiento.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_seguimiento.offset_left = -320.0
	_seguimiento.offset_right = -18.0
	_seguimiento.offset_top = 18.0
	_seguimiento.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_seguimiento.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_seguimiento.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_seguimiento.add_theme_color_override("font_shadow_color", Color.BLACK)
	_seguimiento.add_theme_constant_override("shadow_offset_x", 2)
	_seguimiento.add_theme_constant_override("shadow_offset_y", 2)
	_seguimiento.hide()
	add_child(_seguimiento)
	var fondo := ColorRect.new()
	fondo.color = Color(0, 0, 0, 0.55)
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fondo)
	fondo.hide()
	_panel = PanelContainer.new()
	fondo.add_child(_panel)
	_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_panel.offset_left = -280
	_panel.offset_right = 280
	_panel.offset_top = -235
	_panel.offset_bottom = 235
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color("#30291f")
	estilo.set_content_margin_all(20)
	estilo.set_corner_radius_all(8)
	_panel.add_theme_stylebox_override("panel", estilo)
	var columna := VBoxContainer.new()
	_panel.add_child(columna)
	_titulo = Label.new()
	_titulo.add_theme_font_size_override("font_size", 24)
	columna.add_child(_titulo)
	_desplazamiento = ScrollContainer.new()
	_desplazamiento.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_desplazamiento.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_desplazamiento.follow_focus = true
	columna.add_child(_desplazamiento)
	_lista = VBoxContainer.new()
	_lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lista.add_theme_constant_override("separation", 7)
	_desplazamiento.add_child(_lista)

