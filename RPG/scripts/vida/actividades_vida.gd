extends Node3D
## Colocaciones en las envolventes jugables. No añade cuerpos ni bloquea caminos.

const Punto = preload("res://scripts/vida/punto_vida.gd")
const Bolsa = preload("res://scripts/vida/bolsa.gd")
const Descubrimientos = preload("res://scripts/vida/descubrimientos.gd")
const RADIO := 1.15
const PUESTOS_FERIA := [
	["feria_campo", "feria", "trigo", Vector3(3.2, 0, -2.7)],
	["feria_taller", "feria", "tablas", Vector3(3.2, 0, 0.0)],
	["feria_caminos", "feria", "cobre", Vector3(3.2, 0, 2.7)],
]
const PUNTOS := {
	"Aldea": [
		["mercado", "tienda", "mercado", Vector3(5.0, 0, 1.0)],
		["cofre_mercado", "cofre", "", Vector3(5.0, 0, 3.5)],
	],
	"CamposYGranjas": [
		["bancal_01", "parcela", "", Vector3(-5.5, 0.02, -28.5)],
		["bancal_02", "parcela", "", Vector3(-5.5, 0.02, -26.5)],
		["bancal_03", "parcela", "", Vector3(-5.5, 0.02, -24.5)],
		["bancal_04", "parcela", "", Vector3(-5.5, 0.02, -22.5)],
		["cofre_campos", "cofre", "", Vector3(-5.5, 0, -20.5)],
		["cesta_zanahorias", "recurso", "zanahoria", Vector3(14, 0, -6), 2, 720.0],
		["saco_trigo", "recurso", "trigo", Vector3(-9, 0, -16), 2, 720.0],
		["ramas_granja", "recurso", "madera", Vector3(-5.5, 0, -18), 2, 720.0],
		["canto_granja", "recurso", "piedra", Vector3(-4.5, 0, -31), 2, 720.0],
		["puesto_semillas", "tienda", "semillas", Vector3(-5.5, 0, -15.5)],
	],
	"Bosque": [
		["ramas_entrada", "recurso", "madera", Vector3(2.5, 0.4, 38), 3, 360.0],
		["hierbas_entrada", "recurso", "hierbas", Vector3(3.5, 0.5, 34), 2, 360.0],
		["flores_claro", "recurso", "flores", Vector3(4, 0.8, 3), 2, 360.0],
		["tronco_claro", "recurso", "madera", Vector3(6.5, 0.8, 2), 5, 720.0, "hacha"],
		["setas_claro", "recurso", "setas", Vector3(-4, 0.8, 2), 2, 360.0],
		["tronco_sendero_sur", "recurso", "madera", Vector3(2.5, 0.55, 29), 3, 540.0, "hacha"],
	],
	"Montanas": [
		["cantos_valle", "recurso", "piedra", Vector3(-49, 2.0, 50), 3, 480.0],
		["carbon_valle", "recurso", "carbon", Vector3(-45, 2.0, 48), 2, 480.0, "pico"],
		["cobre_valle", "recurso", "cobre", Vector3(-42, 2.0, 48), 2, 720.0, "pico"],
	],
	"Minas": [
		["piedra_bocamina", "recurso", "piedra", Vector3(2, 0, -3), 2, 480.0],
		["carbon_bocamina", "recurso", "carbon", Vector3(-2, 0, -3), 2, 720.0, "pico"],
		["cobre_galeria", "recurso", "cobre", Vector3(5, -4, -39), 2, 720.0, "pico"],
		["hierro_galeria", "recurso", "hierro", Vector3(8, -4, -42), 2, 720.0, "pico"],
	],
	"InteriorE02": [["mostrador_panaderia", "tienda", "panaderia", Vector3(1.4, 0, 0.75)]],
	"InteriorE03": [["mostrador_herreria", "tienda", "herreria", Vector3(1.75, 0, 0.65)]],
	"InteriorE05": [["mostrador_herbolario", "tienda", "herbolario", Vector3(1.3, 0, -0.2)]],
	"InteriorE06": [
		["cofre_personal", "cofre_personal", "", Vector3(-1.55, 0, 0.2)],
		["cama_personal", "descanso", "", Vector3(-0.55, 0, -1.8)],
	],
}

var region: String
var jugador: CharacterBody3D
var _actual: Node3D


func _ready() -> void:
	var config := get_parent()
	region = String(config.id_region)
	jugador = config.get_node_or_null(config.jugador)
	if not jugador:
		set_process(false)
		return
	for ficha in PUNTOS.get(region, []):
		_crear(ficha)
	if region == "Aldea":
		Misiones.actualizado.connect(_actualizar_feria)
		_actualizar_feria()
	var escenario := config.get_parent()
	for id in Descubrimientos.PUNTOS:
		var ficha: Dictionary = Descubrimientos.PUNTOS[id]
		if ficha.region != region:
			continue
		var marcador := escenario.get_node_or_null(ficha.marcador) as Marker3D
		if marcador:
			_crear([id, "descubrimiento", id, to_local(marcador.global_position)])
	for id in EstadoMundo.zona(region):
		var estado: Dictionary = EstadoMundo.zona(region)[id]
		if id.begins_with("suelto_") and not estado.get("recogido", false):
			_crear([id, "recurso", estado.producto, estado.pos])


func _actualizar_feria() -> void:
	if Misiones.feria_abierta() and not has_node("feria_campo"):
		for ficha in PUESTOS_FERIA:
			_crear(ficha)


func _crear(ficha: Array) -> void:
	var punto := Punto.new()
	punto.name = ficha[0]
	punto.estado = EstadoMundo.objeto(region, ficha[0])
	punto.tipo = ficha[1]
	punto.producto = ficha[2]
	punto.position = ficha[3]
	punto.cantidad = ficha[4] if ficha.size() > 4 else 1
	punto.regeneracion = ficha[5] if ficha.size() > 5 else 0.0
	punto.herramienta = ficha[6] if ficha.size() > 6 else ""
	add_child(punto)


func _cercano() -> Node3D:
	var elegido: Node3D
	var mejor := RADIO * RADIO
	for punto in get_children():
		if not punto.visible:
			continue
		var distancia: float = punto.global_position.distance_squared_to(jugador.global_position)
		if distancia < mejor or (elegido and punto.tipo == "recurso" and is_equal_approx(distancia, mejor)):
			mejor = distancia
			elegido = punto
	return elegido


func _process(_delta: float) -> void:
	for punto in get_children():
		punto.refrescar()
		if punto.is_queued_for_deletion():
			continue
		if not punto.visible and String(punto.name).begins_with("suelto_"):
			EstadoMundo.zona(region).erase(String(punto.name))
			punto.queue_free()
	if is_instance_valid(_actual):
		_actual.aviso.hide()
	_actual = _cercano()
	if _actual and not GestorRegiones.en_transicion:
		_actual.aviso.text = "[%s] %s" % [Ajustes.indicacion("interactuar"), _actual.texto()]
		_actual.aviso.show()


func _input(evento: InputEvent) -> void:
	if GestorRegiones.en_transicion or not is_instance_valid(jugador) or not evento.is_action_pressed("interactuar"):
		return
	var punto := _cercano()
	if punto:
		get_viewport().set_input_as_handled()
		InterfazVida.registrar_interaccion_mundo()
		punto.actuar()


func soltar() -> bool:
	if not is_instance_valid(jugador) or not jugador.is_on_floor():
		return false
	var id_objeto: String = Bolsa.seleccion().get("id", "")
	var indice := int(EstadoMundo.objeto("@jugador", "bolsa").get("seleccion", -1))
	if not Bolsa.quitar(Bolsa.jugador(), indice, 1):
		return false
	EstadoMundo.datos.serie += 1
	var id := "suelto_%d" % EstadoMundo.datos.serie
	var pos := jugador.global_position
	var estado := EstadoMundo.objeto(region, id)
	estado.merge({"producto": id_objeto, "pos": pos}, true)
	_crear([id, "recurso", id_objeto, pos])
	return true


func usar_seleccion_rapida() -> void:
	var punto := _cercano()
	var objeto: String = Bolsa.seleccion().get("id", "")
	if punto == null or objeto.is_empty():
		return
	var etapa := Punto.Parcela.etapa(punto.estado) if punto.tipo == "parcela" else -1
	var herramienta := (etapa == 0 and objeto == "azada") or (etapa == 1 and objeto.begins_with("semilla_")) or (etapa == 2 and objeto == "regadera")
	if herramienta:
		punto.actuar()
	elif punto.tipo == "recurso" and objeto == punto.herramienta:
		punto.actuar()
