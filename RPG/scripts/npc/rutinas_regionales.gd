extends RefCounted

const Apariencias = preload("res://scripts/npc/apariencias.gd")
const ESCENA_NPC := "res://scenes/npc_aldeano.tscn"
const ENLACES := {
	"Aldea": {
		"Bosque": ["SalidaBosque", "bosque_aldea_sur"],
		"CamposYGranjas": ["SalidaCampos", "campos_aldea_norte"],
		"TabernaE01": ["../PuertaTabernaE01", "taberna_e01_entrada"],
		"InteriorE06": ["../PuertaE06", "interior_e06"],
		"InteriorE11": ["../PuertaE11", "interior_e11"],
	},
	"Bosque": {"Aldea": ["SalidaAldea", "aldea_bosque_norte"]},
	"CamposYGranjas": {"Aldea": ["SalidaAldea", "aldea_campos_sur"]},
	"TabernaE01": {"Aldea": ["../Salida", "aldea_taberna_e01"]},
	"InteriorE06": {"Aldea": ["../Salida", "aldea_e06"]},
	"InteriorE11": {"Aldea": ["../Salida", "aldea_e11"]},
}
const CASA_JUGADOR := "InteriorE06"
const CASA_INES := "InteriorE11"
const PARADA_VIAJE := 18.0
const SEPARACION := 1.0
const FERIA := {"ines": Vector3(4.1, 0, -2.7), "rodrigo": Vector3(4.1, 0, 0.0), "baltasar": Vector3(4.1, 0, 2.7)}
const PLAZAS := [Vector2i.ZERO, Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN,
	Vector2i(1, 1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(-1, -1)]

var config: Node
var mapa: MapaAldea
var reservas: Dictionary = {}
var _escena_npc: PackedScene


func actualizar(escena: Node, catalogo: Dictionary) -> void:
	var actual := escena.get_node_or_null("Region") if is_instance_valid(escena) else null
	if actual != config or not is_instance_valid(config):
		config = actual
		mapa = null
		reservas.clear()
	var aqui := String(config.id_region) if config else ""
	for id in catalogo:
		var ficha: Dictionary = catalogo[id]
		var estado := EstadoMundo.objeto("@poblacion", id)
		if estado.is_empty():
			estado.merge({"region": ficha.region, "actividad": "reposo", "destino": "", "entrada": ""})
		var visita: String = ficha.get("visita", "") if Reloj.franja() == 2 else ""
		if Reloj.franja() == 3 and id in ["rodrigo", "baltasar"]:
			visita = "TabernaE01"
		var vivienda := _vivienda(id, ficha)
		if not vivienda.is_empty():
			visita = vivienda
		var feria := Misiones.feria_en_curso() and FERIA.has(id)
		if feria:
			visita = "Aldea"
		var esperada: String = ficha.region if visita.is_empty() else visita
		var npc: Node3D = Aldeanos.nodos.get(StringName(id))
		if not estado.destino.is_empty():
			if Reloj.tiempo_juego < float(estado.llegada):
				continue
			estado.region = estado.destino
			estado.destino = ""
		var region: String = estado.region
		var actividad: String = ficha.horario[Reloj.franja()] if region == ficha.region else "paseo"
		var pos := _posicion(ficha[actividad])
		if feria and region == "Aldea":
			actividad = "feria"
			pos = FERIA[id]
		if region != ficha.region and aqui == region:
			var entrada := config.obtener_entrada(estado.entrada) as Marker3D
			if entrada:
				pos = entrada.global_position + Vector3(3, 0, -3)
			if region == "TabernaE01":
				pos = Vector3(-2.5, 0.0, 1.5 if id == "rodrigo" else -0.5)
			elif region == CASA_INES:
				pos = Vector3(-0.5 if id == "ines" else 0.5, 0.0, -1.5)
			elif region == CASA_JUGADOR:
				pos = Vector3(0.5, 0.0, -0.5)
		var siguiente := esperada
		if region != esperada:
			if region.begins_with("Interior"):
				siguiente = "Aldea"
			var enlace: Array = ENLACES.get(region, {}).get(siguiente, [])
			if not enlace.is_empty():
				if region != aqui:
					_viajar(estado, siguiente, enlace[1])
					continue
				var salida := config.get_node_or_null(enlace[0]) as Area3D
				if salida:
					actividad = "viaje"
					pos = salida.global_position
		if region != aqui:
			estado.actividad = actividad
			estado.erase("pos")
			continue
		if not npc:
			var origen: Vector3 = estado.get("pos", pos)
			var entrada := config.obtener_entrada(estado.entrada) as Marker3D
			if entrada and not estado.has("pos"):
				origen = entrada.global_position
				if region == "TabernaE01":
					origen += Vector3(-2.0 if id == "rodrigo" else 2.0, 0.0, -1.0)
				elif region.begins_with("Interior"):
					origen.z -= 1.0
			npc = _aparecer(id, ficha, origen)
		if not npc:
			continue
		if npc.conversando or npc.hablando:
			estado.actividad = "interacción" if npc.hablando else "socialización"
			estado.pos = npc.global_position
			continue
		var clave := [Reloj.dia, Reloj.franja(), actividad]
		if actividad == "paseo":
			clave.append(int((Reloj.tiempo_juego + posmod(id.hash(), 24)) / 28.0))
		if npc.orden_regional != clave or npc.replanificar_regional:
			if npc.hablando or npc.conversando or npc.jugador_cerca:
				continue
			if actividad == "paseo":
				var variante := posmod(clave.back() + id.hash(), PLAZAS.size())
				var paso: Vector2i = PLAZAS[variante]
				pos += Vector3(paso.x, 0, paso.y) * 2.0
			var destino := _reservar(id, npc.global_position, pos)
			if not destino.is_finite():
				continue
			npc.orden_regional = clave
			var ruta := _mapa().ruta(npc.global_position, destino, Aldeanos.obstaculos_personales(npc, destino))
			npc.ruta_regional(ruta)
			npc.replanificar_regional = ruta.is_empty()
		if actividad == "viaje":
			estado.actividad = "viaje"
		elif npc.esta_caminando():
			estado.actividad = "regreso" if actividad == "descanso" else "desplazamiento"
		else:
			estado.actividad = actividad
		estado.pos = npc.global_position
		if actividad == "viaje" and not npc.replanificar_regional and npc.ruta_regional_acabada() and npc.global_position.distance_to(pos) < 3.0:
			_viajar(estado, siguiente, ENLACES[region][siguiente][1])
			reservas.erase(id)
			npc.queue_free()

func _vivienda(id: String, ficha: Dictionary) -> String:
	var hora := Reloj.segundos
	# Inés recibe a su vecino Rodrigo en su día libre. Llega antes de la visita
	# y permanece en casa después de que él se marche.
	if id == "ines" and (Reloj.franja() == 3 or (Reloj.dia % 2 == 1 and hora >= 180.0 and hora < 320.0)):
		return CASA_INES
	if id == "rodrigo" and ficha.relaciones.has("ines") and Reloj.dia % 2 == 1 and hora >= 220.0 and hora < 285.0 and ficha.horario[Reloj.franja()] == "paseo":
		var anfitriona := EstadoMundo.objeto("@poblacion", "ines")
		if anfitriona.get("region") == CASA_INES and anfitriona.get("destino", "").is_empty():
			return CASA_INES
	if id == "baltasar" and Reloj.dia % 2 == 0 and hora >= 210.0 and hora < 280.0 and Misiones.relacion(id).amistad >= 25:
		return CASA_JUGADOR
	return ""

func al_descansar(catalogo: Dictionary) -> void:
	for id in catalogo:
		var estado := EstadoMundo.objeto("@poblacion", id)
		if estado.get("region", "").begins_with("Interior") or estado.get("destino", "").begins_with("Interior"):
			var npc: Node3D = Aldeanos.nodos.get(StringName(id))
			if is_instance_valid(npc):
				Aldeanos.baja(npc)
				npc.queue_free()
			estado.region = catalogo[id].region
			estado.actividad = catalogo[id].horario[Reloj.franja()]
			estado.destino = ""
			estado.entrada = ""
			estado.erase("pos")


func _viajar(estado: Dictionary, destino: String, entrada: String) -> void:
	estado.destino = destino
	estado.entrada = entrada
	estado.llegada = Reloj.tiempo_juego + PARADA_VIAJE
	estado.actividad = "viaje"
	estado.erase("pos")


func _aparecer(id: String, ficha: Dictionary, centro: Vector3) -> Node3D:
	var visual := Apariencias.ficha(ficha.apariencia)
	if visual.is_empty():
		return null
	var posicion := _reservar(id, centro, centro, 1.8)
	if not posicion.is_finite():
		return null
	if not _escena_npc:
		_escena_npc = load(ESCENA_NPC) as PackedScene
	var npc := _escena_npc.instantiate() as Node3D
	npc.name = id.capitalize()
	npc.id_npc = StringName(id)
	npc.nombre = ficha.nombre
	npc.regional = true
	npc.frames = visual.frames
	npc.tamano_pixel = visual.escala
	npc.desplazamiento = visual.offset
	npc.lineas_primera_visita = PackedStringArray(["Soy %s. %s" % [ficha.nombre, ficha.historia], ficha.conoce])
	npc.lineas_habituales = PackedStringArray([ficha.conoce])
	npc.position = config.get_parent().to_local(posicion)
	config.get_parent().add_child(npc)
	Apariencias.colocar_sombra(npc)
	return npc


func acercar(a: Node3D, b: Node3D) -> bool:
	if not mapa or not a.regional or not b.regional:
		return false
	var centro := (a.global_position + b.global_position) * 0.5
	var separacion := (a.global_position - b.global_position).normalized() * 1.05
	var previas := reservas.duplicate()
	var destino_a := _reservar(String(a.id_npc), a.global_position, centro + separacion)
	var destino_b := _reservar(String(b.id_npc), b.global_position, centro - separacion)
	if not destino_a.is_finite() or not destino_b.is_finite() or destino_a.distance_to(destino_b) > 3.0:
		reservas = previas
		return false
	var ruta_a := mapa.ruta(a.global_position, destino_a, Aldeanos.obstaculos_personales(a, destino_a))
	var ruta_b := mapa.ruta(b.global_position, destino_b, Aldeanos.obstaculos_personales(b, destino_b))
	if ruta_a.is_empty() or ruta_b.is_empty():
		reservas = previas
		return false
	a.ruta_regional(ruta_a)
	b.ruta_regional(ruta_b)
	return true


func _reservar(id: String, origen: Vector3, centro: Vector3, distancia_jugador: float = SEPARACION) -> Vector3:
	var navegacion := _mapa()
	var base := navegacion.celda_libre_cercana(centro)
	var jugador := config.get_node_or_null(config.jugador) as Node3D
	for desplazamiento in PLAZAS:
		var celda: Vector2i = base + desplazamiento
		var candidato := Vector3(celda.x + 0.5, 0.0, celda.y + 0.5)
		if not navegacion.transitable(candidato):
			continue
		candidato.y = navegacion.altura(candidato)
		if jugador and _cerca(jugador.global_position, candidato, distancia_jugador):
			continue
		if reservas.keys().any(func(otro): return otro != id and _cerca(reservas[otro], candidato)):
			continue
		if Aldeanos.nodos.keys().any(func(otro): return String(otro) != id and _cerca(Aldeanos.nodos[otro].global_position, candidato)):
			continue
		if navegacion.ruta(origen, candidato).is_empty():
			continue
		reservas[id] = candidato
		return candidato
	return Vector3.INF


func _mapa() -> MapaAldea:
	if mapa:
		return mapa
	if config.id_region == &"Aldea" and Aldeanos._asegurar_mapa():
		mapa = Aldeanos.mapa
		return mapa
	var escena := config.get_parent()
	var excluir: Array[RID] = []
	var jugador := config.get_node_or_null(config.jugador) as CharacterBody3D
	if jugador:
		excluir.append(jugador.get_rid())
	for npc in Aldeanos.nodos.values():
		var cuerpo := npc.get_node_or_null("Cuerpo") as StaticBody3D
		if cuerpo:
			excluir.append(cuerpo.get_rid())
	mapa = MapaAldea.new()
	mapa.construir(escena, excluir, String(config.id_region))
	return mapa


func _cerca(a: Vector3, b: Vector3, separacion: float = SEPARACION) -> bool:
	return absf(a.y - b.y) < 1.6 and Vector2(a.x, a.z).distance_squared_to(Vector2(b.x, b.z)) < separacion * separacion


func _posicion(par: Array) -> Vector3:
	return Vector3(par[0], 0, par[1])
