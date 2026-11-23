extends Node
## Autoload `Aldeanos`: qué hace cada NPC y dónde está, aunque su escena no
## esté cargada. Con IA disponible, una sola llamada por franja del día (y
## tras cada narración) planifica a todos los aldeanos con el catálogo cerrado
## de PromptsIA.ACCIONES; el plan se valida y los nodos presentes lo ejecutan
## caminando por MapaAldea. Los ausentes llegan de forma abstracta a su
## destino. Sin IA no hace nada y los NPC siguen en sus puestos de siempre.
## El estado vive en Historia.estado.aldeanos y se guarda con la historia.

signal orden_cambiada(id: StringName)
signal encuentro_terminado(id: StringName, otro: StringName)

const RUTA_LUGARES := "res://data/historia/lugares.json"
## Segundos mínimos entre planificaciones (las narraciones pueden encadenarse).
const PAUSA_ENTRE_PLANES: float = 20.0
## Distancia a la que se da por alcanzado a otro aldeano o al viajero.
const DISTANCIA_ENCUENTRO: float = 1.4
## Distancia del viajero a la que un encuentro se representa con bocadillos.
const DISTANCIA_VISIBLE: float = 12.0

var lugares: Dictionary = {}
## id -> nodo NPC presente en la escena actual.
var nodos: Dictionary = {}
var mapa: MapaAldea
var planificando: bool = false
var velocidad: float = 1.6
## Lectura de los bocadillos (las pruebas los reducen).
var segundos_por_caracter: float = 0.06
var segundos_minimos_linea: float = 2.5
## id del que inició el encuentro -> true mientras dura.
var encuentros_en_curso: Dictionary = {}

var _ultimo_plan_ms: int = -1000000


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	lugares = JSON.parse_string(FileAccess.get_file_as_string(RUTA_LUGARES))
	Reloj.franja_cambiada.connect(func(_dia, _franja): planificar())
	Historia.historia_actualizada.connect(_al_actualizar_historia)


func activo() -> bool:
	return IA.disponible()


func estado_de(id: StringName) -> Dictionary:
	if not Historia.estado.has("aldeanos"):
		Historia.estado.aldeanos = {}
	var todos: Dictionary = Historia.estado.aldeanos
	if not todos.has(String(id)):
		todos[String(id)] = {accion = "rutina", objetivo = "", motivo = "", pos = [], puesto = [], llegado = true}
	return todos[String(id)]


# --- Nodos presentes ----------------------------------------------------------

## Lo llama cada NPC al entrar en escena; con IA retoma su orden guardada.
func registrar(npc: Node3D) -> void:
	var id: StringName = npc.id_npc
	nodos[id] = npc
	var estado := estado_de(id)
	estado.puesto = [npc.puesto.x, npc.puesto.z]
	# En «rutina» ya cumplida está en su puesto (el guardia retoma su ronda).
	var en_rutina: bool = estado.accion == "rutina" and estado.llegado
	if activo() and estado.pos.size() == 2 and not en_rutina:
		npc.global_position = Vector3(estado.pos[0], npc.global_position.y, estado.pos[1])
	if activo():
		npc.ejecutar.call_deferred()
		planificar_si_falta.call_deferred()


## Planifica si la franja actual aún no tiene plan: al entrar en la aldea o al
## activar la IA, sin esperar al siguiente cambio de franja.
func planificar_si_falta() -> void:
	if activo() and Historia.estado.get("ultimo_plan", []) != [Reloj.dia, Reloj.franja()]:
		planificar(true)


## Lo llama cada NPC al salir de escena: si iba de camino, llega en abstracto.
func baja(npc: Node3D) -> void:
	var id: StringName = npc.id_npc
	if nodos.get(id) != npc:
		return
	nodos.erase(id)
	var estado := estado_de(id)
	estado.pos = [npc.ultima_posicion.x, npc.ultima_posicion.z]
	if activo() and not estado.llegado:
		_simular_llegada(id)


func llegada(id: StringName) -> void:
	var estado := estado_de(id)
	if estado.llegado:
		return
	estado.llegado = true
	if nodos.has(id):
		var npc: Node3D = nodos[id]
		estado.pos = [npc.global_position.x, npc.global_position.z]
	if estado.accion == "hablar_con":
		encuentro(id)
	Historia.guardar()


## Tras hablar con el viajero que buscaba, el aldeano vuelve a su rutina.
func cumplido(id: StringName) -> void:
	var estado := estado_de(id)
	if estado.accion != "buscar_jugador":
		return
	_ordenar(id, "rutina", "", "")


# --- Destinos y rutas ---------------------------------------------------------

func destino(id: StringName) -> Vector3:
	var estado := estado_de(id)
	match estado.accion:
		"ir":
			return _pos_lugar(estado.objetivo)
		"hablar_con":
			return posicion_de(StringName(estado.objetivo))
		"buscar_jugador":
			var jugador := _jugador()
			return jugador.global_position if jugador else _pos_lugar("plaza")
	return _vector(estado.puesto)


## Posición actual de un aldeano, esté o no en escena.
func posicion_de(id: StringName) -> Vector3:
	if nodos.has(id):
		var npc: Node3D = nodos[id]
		return npc.global_position if npc.is_inside_tree() else npc.ultima_posicion
	var estado := estado_de(id)
	return _vector(estado.pos if estado.pos.size() == 2 else estado.puesto)


func ruta(desde: Vector3, hasta: Vector3) -> PackedVector3Array:
	if not _asegurar_mapa():
		return PackedVector3Array()
	return mapa.ruta(desde, hasta)


func altura(pos: Vector3) -> float:
	return mapa.altura(pos) if mapa else pos.y


# --- Planificación ------------------------------------------------------------

func planificar(forzar: bool = false) -> void:
	if not activo() or planificando:
		return
	if not forzar and Time.get_ticks_msec() - _ultimo_plan_ms < PAUSA_ENTRE_PLANES * 1000.0:
		return
	planificando = true
	_ultimo_plan_ms = Time.get_ticks_msec()
	var ids: Array = Historia.premisa.npcs.keys()
	var mensajes := PromptsIA.mensajes_planificador(_datos_planificador(ids))
	var resultado: Dictionary = await IA.solicitar(mensajes, "planificador", PromptsIA.esquema_planificador(ids), PromptsIA.MAX_TOKENS_PLANIFICADOR)
	planificando = false
	if resultado.ok:
		Historia.estado.ultimo_plan = [Reloj.dia, Reloj.franja()]
		var por_npc: Dictionary = resultado.datos.get("planes", {})
		var planes: Array = []
		for id in por_npc:
			var plan: Dictionary = por_npc[id]
			plan.npc = id
			planes.append(plan)
		aplicar_planes(planes)


## Valida cada plan contra el catálogo; lo inválido se convierte en «rutina».
func aplicar_planes(planes: Array) -> void:
	for plan in planes:
		var id := StringName(str(plan.get("npc", "")))
		if not Historia.tiene_npc(id):
			continue
		var accion := str(plan.get("accion", "rutina"))
		var objetivo := str(plan.get("objetivo", "")).strip_edges()
		if not accion in PromptsIA.ACCIONES:
			accion = "rutina"
		if accion == "ir" and not lugares.has(objetivo):
			accion = "rutina"
		if accion == "hablar_con" and (not Historia.tiene_npc(StringName(objetivo)) or objetivo == String(id)):
			accion = "rutina"
		if not accion in ["ir", "hablar_con"]:
			objetivo = ""
		_ordenar(id, accion, objetivo, str(plan.get("motivo", "")).strip_edges().left(100))
	Historia.guardar()


## Frase para el contexto de la conversación: qué hace y en qué momento.
func descripcion(id: StringName) -> String:
	var estado := estado_de(id)
	var nombres := Historia.nombres_npc()
	var texto: String
	match estado.accion:
		"ir":
			texto = "vas a %s" % lugares.get(estado.objetivo, {}).get("nombre", "otro sitio")
		"hablar_con":
			texto = "ibas a hablar con %s" % nombres.get(estado.objetivo, "otro aldeano")
		"buscar_jugador":
			texto = "buscabas al viajero"
		"trabajar":
			texto = "estás trabajando"
		"descansar":
			texto = "estás descansando"
		_:
			texto = "estás con tu quehacer de siempre"
	if not str(estado.motivo).is_empty():
		texto += " (%s)" % estado.motivo
	return "%s. Es el %s." % [texto, Reloj.descripcion()]


func _ordenar(id: StringName, accion: String, objetivo: String, motivo: String) -> void:
	var estado := estado_de(id)
	estado.accion = accion
	estado.objetivo = objetivo
	estado.motivo = motivo
	estado.llegado = false
	if nodos.has(id):
		nodos[id].ejecutar()
	else:
		_simular_llegada(id)
	orden_cambiada.emit(id)


func _datos_planificador(ids: Array) -> Dictionary:
	var hilos := PackedStringArray()
	for hilo in Historia.estado.hilos:
		if hilo.estado == "abierto":
			hilos.append("%s: %s" % [hilo.titulo, hilo.nota])
	var nombres_lugares := {}
	for id in lugares:
		nombres_lugares[id] = lugares[id].nombre
	var lineas := PackedStringArray()
	for id in ids:
		var ficha: Dictionary = Historia.premisa.npcs[id]
		var linea := "- %s (%s): %s Ahora: %s." % [id, ficha.nombre, ficha.ficha, _resumen_orden(StringName(id))]
		var indicacion: String = Historia.estado.npcs[id].indicacion
		if not indicacion.is_empty():
			linea += " Narrador: " + indicacion
		var rumores: Array = Historia.estado.npcs[id].get("rumores", [])
		if not rumores.is_empty():
			linea += " Sabe: " + "; ".join(PackedStringArray(rumores.slice(-2)))
		lineas.append(linea)
	return {
		momento = Reloj.descripcion(),
		resumen = Historia.estado.resumen,
		hilos = hilos,
		lugares = nombres_lugares,
		aldeanos = lineas,
	}


## Orden actual en forma neutra para el planificador: «ir → plaza (motivo)».
func _resumen_orden(id: StringName) -> String:
	var estado := estado_de(id)
	var texto: String = estado.accion
	if not str(estado.objetivo).is_empty():
		texto += " → " + estado.objetivo
	if not str(estado.motivo).is_empty():
		texto += " (%s)" % estado.motivo
	return texto


func _simular_llegada(id: StringName) -> void:
	var estado := estado_de(id)
	var fin := destino(id)
	estado.pos = [fin.x, fin.z]
	estado.llegado = true
	if estado.accion == "hablar_con":
		encuentro(id)


## Encuentro de `id` con el aldeano al que fue a ver (acción hablar_con).
## Con el viajero cerca y ambos en escena, el modelo escribe 2-4 frases que se
## ven en bocadillos; si no, solo el resumen (llamada más corta). Cada uno
## aprende algo del otro y el resumen llega al narrador. Sin respuesta, queda
## una frase de plantilla.
func encuentro(id: StringName) -> void:
	var estado := estado_de(id)
	var otro := StringName(estado.objetivo)
	if encuentros_en_curso.has(id) or not Historia.tiene_npc(otro):
		return
	encuentros_en_curso[id] = true
	var con_dialogo := encuentro_visible(id, otro)
	var nombres := Historia.nombres_npc()
	var mensajes := PromptsIA.mensajes_encuentro(_ficha_encuentro(id), _ficha_encuentro(otro), str(estado.motivo), Reloj.descripcion(), Historia.estado.resumen, con_dialogo)
	var resultado: Dictionary = {ok = false}
	if activo():
		resultado = await IA.solicitar(mensajes, "encuentro", PromptsIA.esquema_encuentro(String(id), String(otro)),
			PromptsIA.MAX_TOKENS_ENCUENTRO if con_dialogo else PromptsIA.MAX_TOKENS_ENCUENTRO_RESUMEN)
	if not resultado.ok:
		encuentros_en_curso.erase(id)
		var texto := "%s fue a hablar con %s" % [nombres[String(id)], nombres.get(String(otro), "alguien")]
		if not str(estado.motivo).is_empty():
			texto += ": " + estado.motivo
		Historia.registrar_hecho(texto)
		return
	var datos: Dictionary = resultado.datos
	if con_dialogo and encuentro_visible(id, otro):
		await _representar(id, otro, datos.get("lineas", []))
	encuentros_en_curso.erase(id)
	Historia.aprender(id, str(datos.get("aprende_a", "")))
	Historia.aprender(otro, str(datos.get("aprende_b", "")))
	var resumen := str(datos.get("resumen", "")).strip_edges()
	if resumen.is_empty():
		resumen = "hablaron un rato"
	Historia.registrar_hecho("%s y %s: %s" % [nombres[String(id)], nombres[String(otro)], resumen], bool(datos.get("importante", false)))
	encuentro_terminado.emit(id, otro)


## Ambos en escena y el viajero lo bastante cerca para leer los bocadillos.
func encuentro_visible(id: StringName, otro: StringName) -> bool:
	var jugador := _jugador()
	if jugador == null or not nodos.has(id) or not nodos.has(otro):
		return false
	return _plano(jugador.global_position).distance_to(_plano(posicion_de(id))) <= DISTANCIA_VISIBLE


## Muestra las frases por turnos con los dos parados y mirándose.
func _representar(id: StringName, otro: StringName, lineas: Array) -> void:
	var a: Node3D = nodos[id]
	var b: Node3D = nodos[otro]
	a.conversando = true
	b.conversando = true
	a._refrescar_aviso()
	b._refrescar_aviso()
	a.mirar_a(b.global_position)
	b.mirar_a(a.global_position)
	for linea in lineas.slice(0, PromptsIA.LINEAS_ENCUENTRO):
		var quien := StringName(str(linea.get("quien", "")))
		var texto := str(linea.get("texto", "")).strip_edges().left(180)
		if texto.is_empty() or not quien in [id, otro] or not nodos.has(quien):
			continue
		var hablante: Node3D = nodos[quien]
		await hablante.decir(texto, maxf(segundos_minimos_linea, texto.length() * segundos_por_caracter))
	for npc in [a, b]:
		if is_instance_valid(npc):
			npc.conversando = false
			npc._refrescar_aviso()


func _ficha_encuentro(id: StringName) -> Dictionary:
	var ficha: Dictionary = Historia.premisa.npcs[String(id)]
	var memoria: Dictionary = Historia.estado.npcs[String(id)]
	return {
		id = String(id),
		nombre = ficha.nombre,
		ficha = ficha.ficha,
		rumores = PackedStringArray(memoria.get("rumores", [])),
		indicacion = memoria.indicacion,
	}


func _plano(v: Vector3) -> Vector2:
	return Vector2(v.x, v.z)


func _al_actualizar_historia() -> void:
	# «Nueva historia»: estado sin aldeanos; los presentes vuelven a su puesto.
	if not Historia.estado.has("aldeanos"):
		for id in nodos:
			var npc: Node3D = nodos[id]
			estado_de(id).puesto = [npc.puesto.x, npc.puesto.z]
			if activo():
				npc.ejecutar()
		return
	planificar()


func _asegurar_mapa() -> bool:
	if mapa:
		return true
	var escena := get_tree().current_scene
	if escena == null or not escena.has_node("Aldea"):
		return false
	var excluir: Array[RID] = []
	for cuerpo in escena.find_children("*", "CharacterBody3D", true, false):
		excluir.append(cuerpo.get_rid())
	for id in nodos:
		var cuerpo: Node = nodos[id].get_node_or_null("Cuerpo")
		if cuerpo:
			excluir.append(cuerpo.get_rid())
	mapa = MapaAldea.new()
	mapa.construir(escena, excluir)
	return true


func _jugador() -> Node3D:
	var escena := get_tree().current_scene
	if escena == null or not escena.is_inside_tree() or not escena.has_node("Aldea"):
		return null
	var jugador := escena.get_node_or_null("Jugador") as Node3D
	return jugador if jugador and jugador.is_inside_tree() else null


func _pos_lugar(id: String) -> Vector3:
	var pos: Array = lugares.get(id, lugares.plaza).pos
	return Vector3(pos[0], 0.0, pos[1])


func _vector(par: Array) -> Vector3:
	return Vector3(par[0], 0.0, par[1]) if par.size() == 2 else Vector3.ZERO
