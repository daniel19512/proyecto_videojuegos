extends Node
## Población, rutas y encuentros del mundo. Los cinco originales conservan
## las órdenes narrativas de Historia. Las rutinas regionales usan el Reloj
## y EstadoMundo. Los encuentros entre personajes se resuelven localmente.

signal orden_cambiada(id: StringName)
signal encuentro_terminado(id: StringName, otro: StringName)

const RUTA_LUGARES := "res://data/historia/lugares.json"
const RutinasRegionales = preload("res://scripts/npc/rutinas_regionales.gd")
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
var _rutinas := RutinasRegionales.new()
var _intervalo_local := 1.0
var _momento_local: Array = []
var _escena_mapa: Node
var _acercamiento: Array = []
var _destinos_originales: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	lugares = JSON.parse_string(FileAccess.get_file_as_string(RUTA_LUGARES))
	Reloj.franja_cambiada.connect(func(_dia, _franja): planificar())
	Historia.historia_actualizada.connect(_al_actualizar_historia)


func _process(delta: float) -> void:
	if get_tree().paused or GestorRegiones.en_transicion or EstadoMundo.restaurando:
		return
	_intervalo_local -= delta
	if _intervalo_local > 0.0:
		return
	_intervalo_local = 1.0
	_rutinas.actualizar(get_tree().current_scene, Historia.poblacion)
	if not activo():
		_rutina_original()
	_buscar_charla()

func al_descansar() -> void:
	_rutinas.al_descansar(Historia.poblacion)
	_intervalo_local = 0.0


func reiniciar_sesion() -> void:
	_momento_local.clear()
	_acercamiento.clear()
	_destinos_originales.clear()
	encuentros_en_curso.clear()
	_ultimo_plan_ms = -1000000
	_intervalo_local = 1.0
	_escena_mapa = null
	mapa = null
	_rutinas = RutinasRegionales.new()


func _rutina_original() -> void:
	var momento := [Reloj.dia, Reloj.franja()]
	if _momento_local == momento or Reloj.franja() < 2:
		return
	_momento_local = momento
	for id in Historia.ids_originales:
		var estado := estado_de(StringName(id))
		estado.rutina_local = momento
		var ficha: Dictionary = Historia.premisa.npcs[id]
		var paseo: bool = ficha.horario[Reloj.franja()] == "paseo"
		_ordenar(StringName(id), "ir" if paseo else "rutina", ficha.paseo if paseo else "", "")


func _buscar_charla() -> void:
	if not _acercamiento.is_empty():
		_comprobar_acercamiento()
		return
	if not encuentros_en_curso.is_empty():
		return
	var social := EstadoMundo.objeto("@poblacion", "@social")
	if Reloj.tiempo_juego < float(social.get("proxima", 30.0)):
		return
	var ids := nodos.keys()
	for i in ids.size():
		var a: Node3D = nodos[ids[i]]
		if not _disponible_social(a):
			continue
		for j in range(i + 1, ids.size()):
			var b: Node3D = nodos[ids[j]]
			var distancia := a.global_position.distance_to(b.global_position)
			if not _disponible_social(b) or distancia < 1.0 or distancia > 6.0:
				continue
			if not _linea_social(a, b):
				continue
			if distancia > 3.0:
				if not _rutinas.acercar(a, b):
					continue
				_acercamiento = [ids[i], ids[j], Reloj.tiempo_juego + 9.0]
				social.proxima = Reloj.tiempo_juego + 20.0
				return
			social.proxima = Reloj.tiempo_juego + 55.0
			_charla_local(ids[i], ids[j])
			return


func _disponible_social(npc: Node3D) -> bool:
	if npc.hablando or npc.conversando or npc.jugador_cerca or npc.esta_caminando():
		return false
	if npc.regional:
		var actividad := EstadoMundo.objeto("@poblacion", String(npc.id_npc))
		return actividad.get("actividad", "") not in ["viaje", "regreso", "descanso"] and (
			Reloj.franja() != 1 or actividad.get("actividad", "") != "trabajo")
	return true


func _comprobar_acercamiento() -> void:
	var id: StringName = _acercamiento[0]
	var otro: StringName = _acercamiento[1]
	var a: Node3D = nodos.get(id)
	var b: Node3D = nodos.get(otro)
	if not a or not b or Reloj.tiempo_juego >= float(_acercamiento[2]) or a.jugador_cerca or b.jugador_cerca:
		_acercamiento.clear()
		for npc in [a, b]:
			if is_instance_valid(npc):
				npc.replanificar_regional = true
	elif a.ruta_regional_acabada() and b.ruta_regional_acabada():
		_acercamiento.clear()
		var distancia := a.global_position.distance_to(b.global_position)
		if distancia >= 1.0 and distancia <= 3.0 and _linea_social(a, b):
			EstadoMundo.objeto("@poblacion", "@social").proxima = Reloj.tiempo_juego + 55.0
			_charla_local(id, otro)


func _linea_social(a: Node3D, b: Node3D) -> bool:
	var excluir: Array[RID] = []
	for npc in [a, b]:
		var cuerpo := npc.get_node_or_null("Cuerpo") as StaticBody3D
		if cuerpo:
			excluir.append(cuerpo.get_rid())
	var altura_cara := Vector3.UP * 1.25
	var rayo := PhysicsRayQueryParameters3D.create(a.global_position + altura_cara, b.global_position + altura_cara, 1, excluir)
	return a.get_world_3d().direct_space_state.intersect_ray(rayo).is_empty()


func _charla_local(id: StringName, otro: StringName) -> void:
	if not encuentros_en_curso.is_empty() or not nodos.has(id) or not nodos.has(otro):
		return
	var a: Node3D = nodos[id]
	var b: Node3D = nodos[otro]
	if a.hablando or b.hablando or a.conversando or b.conversando:
		return
	encuentros_en_curso[id] = otro
	var nombres := Historia.nombres_npc()
	var tema := _registrar_charla(id, otro)
	if encuentro_visible(id, otro):
		await _representar(id, otro, [{quien = id, texto = tema}, {quien = otro, texto = "Gracias por contármelo, %s." % nombres[String(id)]}])
	for npc in [a, b]:
		if is_instance_valid(npc) and npc.regional:
			npc.replanificar_regional = true
	encuentros_en_curso.erase(id)
	encuentro_terminado.emit(id, otro)


func _registrar_charla(id: StringName, otro: StringName) -> String:
	var voces := {
		"pescador": "La pesca está junto al puente. Para probar suerte hace falta una caña.",
		"panadera": "Con el trigo del campo y la harina del molino hacemos pan.",
		"herrero": "Para trabajar el hierro en la fragua hace falta carbón.",
		"tabernero": "En la taberna se prepara cerveza de malta.",
		"guardia": "El puente es el paso seguro para llegar a la otra orilla.",
	}
	var tema: String = Historia.poblacion.get(String(id), {}).get("conoce", voces.get(String(id), "Los puestos se abastecen durante el día."))
	var resumen := "%s habló con %s. %s" % [Historia.premisa.npcs[String(id)].nombre, Historia.premisa.npcs[String(otro)].nombre, tema]
	var social := EstadoMundo.objeto("@poblacion", "@social")
	var hechos: Array = social.get("hechos", [])
	var pareja := [String(id), String(otro)]
	pareja.sort()
	var contacto := "%s/%s" % pareja
	var clave := "%s/%d/%d" % [contacto, Reloj.dia, Reloj.franja()]
	if not hechos.any(func(hecho): return hecho.id == clave):
		var rumor := Misiones.compartir_recuerdo(String(id), String(otro))
		if not rumor.is_empty():
			tema = rumor
			resumen = "%s dijo a %s: %s" % [Historia.premisa.npcs[String(id)].nombre, Historia.premisa.npcs[String(otro)].nombre, tema]
		hechos.append({id = clave, texto = resumen, participantes = [String(id), String(otro)]})
		social.hechos = hechos.slice(-20)
		var relaciones: Dictionary = social.get("relaciones", {})
		relaciones[contacto] = int(relaciones.get(contacto, 0)) + 1
		social.relaciones = relaciones
		Historia.aprender(id, resumen)
		Historia.aprender(otro, resumen)
	return tema


func interrumpir_charla(id: StringName) -> void:
	for emisor in encuentros_en_curso:
		var otro: Variant = encuentros_en_curso[emisor]
		if otro is StringName and id in [emisor, otro]:
			for participante in [emisor, otro]:
				if nodos.has(participante):
					nodos[participante].ocultar_bocadillo()
			return


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
	if npc.regional:
		return
	var estado := estado_de(id)
	estado.puesto = [npc.puesto.x, npc.puesto.z]
	# En «rutina» ya cumplida está en su puesto (el guardia retoma su ronda).
	var en_rutina: bool = estado.accion == "rutina" and estado.llegado
	if activo() and estado.pos.size() == 2 and not en_rutina:
		npc.global_position = Vector3(estado.pos[0], npc.global_position.y, estado.pos[1])
	if activo():
		npc.ejecutar.call_deferred()
		planificar_si_falta.call_deferred()
	elif estado.get("rutina_local", []) == [Reloj.dia, Reloj.franja()] and Reloj.franja() == 2:
		_reubicar_original.call_deferred(id)
	_separar_aparicion_original.call_deferred(id)


func _reubicar_original(id: StringName) -> void:
	if not nodos.has(id) or not _asegurar_mapa():
		return
	var npc: Node3D = nodos[id]
	_reservar_original(id, _pos_lugar(Historia.premisa.npcs[String(id)].paseo))
	var pos: Vector3 = _destinos_originales.get(id, npc.puesto)
	var jugador := _jugador()
	if jugador and jugador.global_position.distance_to(pos) < 1.8:
		return
	npc.global_position = Vector3(pos.x, mapa.altura(pos), pos.z)
	npc._actualizar_solidez()


func _separar_aparicion_original(id: StringName) -> void:
	var jugador := _jugador()
	var npc: Node3D = nodos.get(id)
	if not jugador or not npc or jugador.global_position.distance_to(npc.global_position) >= 0.95 or not _asegurar_mapa():
		return
	var reserva: Variant = _destinos_originales.get(id)
	_destinos_originales.erase(id)
	_reservar_original(id, npc.global_position)
	if _destinos_originales.has(id):
		var pos: Vector3 = _destinos_originales[id]
		npc.global_position = Vector3(pos.x, mapa.altura(pos), pos.z)
		npc._actualizar_solidez()
	_destinos_originales.erase(id)
	if reserva is Vector3:
		_destinos_originales[id] = reserva


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
	_destinos_originales.erase(id)
	if npc.regional:
		_rutinas.reservas.erase(String(id))
		return
	if EstadoMundo.restaurando:
		return
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
	if Historia.poblacion.has(String(id)):
		return
	var estado := estado_de(id)
	if estado.accion != "buscar_jugador":
		return
	_ordenar(id, "rutina", "", "")


# --- Destinos y rutas ---------------------------------------------------------

func destino(id: StringName) -> Vector3:
	var estado := estado_de(id)
	match estado.accion:
		"ir":
			return _destinos_originales.get(id, _pos_lugar(estado.objetivo))
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


func ruta(desde: Vector3, hasta: Vector3, evitar: PackedVector3Array = []) -> PackedVector3Array:
	if not _asegurar_mapa():
		return PackedVector3Array()
	return mapa.ruta(desde, hasta, evitar)


func obstaculos_personales(npc: Node3D, objetivo: Vector3) -> PackedVector3Array:
	var obstaculos := PackedVector3Array()
	var jugador := _jugador()
	if jugador and jugador.global_position.distance_to(objetivo) > 1.2:
		obstaculos.append(jugador.global_position)
	for otro in nodos.values():
		if otro != npc and otro.global_position.distance_to(objetivo) > 1.0:
			obstaculos.append(otro.global_position)
	return obstaculos


func separar_jugador(posicion: Vector3, paso: Vector3) -> Vector3:
	var horizontal := _plano(paso)
	if horizontal.is_zero_approx():
		return paso
	const RADIO := 0.66
	for npc in nodos.values():
		if not is_instance_valid(npc) or absf(npc.global_position.y - posicion.y) >= 1.6:
			continue
		var separacion := _plano(posicion - npc.global_position)
		if (separacion + horizontal).length_squared() >= RADIO * RADIO:
			continue
		var normal := separacion.normalized()
		if normal.is_zero_approx():
			continue
		var acercamiento := minf(horizontal.dot(normal), 0.0)
		if acercamiento < 0.0:
			horizontal -= normal * acercamiento
	return Vector3(horizontal.x, paso.y, horizontal.y)


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
	var ids: Array = Historia.ids_originales
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
		if not String(id) in Historia.ids_originales:
			continue
		var accion := str(plan.get("accion", "rutina"))
		var objetivo := str(plan.get("objetivo", "")).strip_edges()
		if not accion in PromptsIA.ACCIONES:
			accion = "rutina"
		if accion == "ir" and not lugares.has(objetivo):
			accion = "rutina"
		if accion == "hablar_con" and (not objetivo in Historia.ids_originales or objetivo == String(id)):
			accion = "rutina"
		if not accion in ["ir", "hablar_con"]:
			objetivo = ""
		_ordenar(id, accion, objetivo, str(plan.get("motivo", "")).strip_edges().left(100))
	Historia.guardar()


## Frase para el contexto de la conversación: qué hace y en qué momento.
func descripcion(id: StringName) -> String:
	if Historia.poblacion.has(String(id)):
		var actividad := EstadoMundo.objeto("@poblacion", String(id))
		return "Actividad: %s. Región: %s. %s." % [actividad.get("actividad", "reposo"),
			actividad.get("region", Historia.poblacion[String(id)].region), Reloj.descripcion()]
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
	_destinos_originales.erase(id)
	if nodos.has(id):
		if accion == "ir" and _asegurar_mapa():
			_reservar_original(id, _pos_lugar(objetivo))
		nodos[id].ejecutar()
	else:
		_simular_llegada(id)
	orden_cambiada.emit(id)


func _reservar_original(id: StringName, centro: Vector3) -> void:
	var npc: Node3D = nodos[id]
	var ocupadas: Array = _destinos_originales.values() + _rutinas.reservas.values()
	var jugador := _jugador()
	if jugador:
		ocupadas.append(jugador.global_position)
	for otro in nodos.values():
		if otro != npc:
			ocupadas.append(otro.global_position)
	for desplazamiento: Vector3 in [Vector3.ZERO, Vector3.RIGHT * 1.3, Vector3.LEFT * 1.3,
			Vector3.FORWARD * 1.3, Vector3.BACK * 1.3]:
		var candidato := centro + desplazamiento
		if ocupadas.any(func(punto): return _plano(punto - candidato).length_squared() < 1.0):
			continue
		if desplazamiento != Vector3.ZERO and not mapa.transitable(candidato):
			continue
		if not mapa.ruta(npc.global_position, candidato).is_empty():
			_destinos_originales[id] = candidato
			return


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


## Cierra una orden de visita con un intercambio local.
func encuentro(id: StringName) -> void:
	var estado := estado_de(id)
	var otro := StringName(estado.objetivo)
	if encuentros_en_curso.has(id) or not Historia.tiene_npc(otro):
		return
	if nodos.has(id) and nodos.has(otro):
		_charla_local(id, otro)
	elif String(id) in Historia.ids_originales and String(otro) in Historia.ids_originales:
		_registrar_charla(id, otro)
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
	for linea in lineas:
		var quien := StringName(str(linea.get("quien", "")))
		var texto := str(linea.get("texto", "")).strip_edges().left(180)
		if not is_instance_valid(a) or not is_instance_valid(b) or not a.conversando or not b.conversando:
			break
		if texto.is_empty() or not quien in [id, otro] or not nodos.has(quien):
			continue
		var hablante: Node3D = nodos[quien]
		await hablante.decir(texto, maxf(segundos_minimos_linea, texto.length() * segundos_por_caracter))
	for npc in [a, b]:
		if is_instance_valid(npc):
			npc.conversando = false
			npc._refrescar_aviso()


func _plano(v: Vector3) -> Vector2:
	return Vector2(v.x, v.z)


func _al_actualizar_historia() -> void:
	# «Nueva historia»: estado sin aldeanos; los presentes vuelven a su puesto.
	if not Historia.estado.has("aldeanos"):
		_momento_local.clear()
		for id in nodos:
			var npc: Node3D = nodos[id]
			if npc.regional:
				continue
			estado_de(id).puesto = [npc.puesto.x, npc.puesto.z]
			if activo():
				npc.ejecutar()
		return
	planificar()


func _asegurar_mapa() -> bool:
	var escena := get_tree().current_scene
	if escena == null or not escena.has_node("Aldea"):
		return false
	if mapa and _escena_mapa == escena:
		return true
	_escena_mapa = escena
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
	if escena == null or not escena.is_inside_tree():
		return null
	var jugador := escena.get_node_or_null("Jugador") as Node3D
	return jugador if jugador and jugador.is_inside_tree() else null


func _pos_lugar(id: String) -> Vector3:
	var pos: Array = lugares.get(id, lugares.plaza).pos
	return Vector3(pos[0], 0.0, pos[1])


func _vector(par: Array) -> Vector3:
	return Vector3(par[0], 0.0, par[1]) if par.size() == 2 else Vector3.ZERO
