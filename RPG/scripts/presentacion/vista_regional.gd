extends Node3D
## Los nodos de presentación se preparan fuera del árbol. Solo conservan
## scripts visuales que no dependen de la partida ni escriben en ella.

const Regiones = preload("res://scripts/presentacion/regiones.gd")
const VISUALES := [
	"res://scripts/terreno_aldea.gd", "res://scripts/depuracion_parcelas.gd",
	"res://scripts/rueda_hidraulica.gd",
]
var _escenario: Node
var _camara: Camera3D
var _centro := Vector3.ZERO
var _tiempo := 0.0
var _viajero: Node3D
var _inicio_viajero := Vector3.ZERO

func mostrar(id: String, llegada: SpriteFrames = null) -> void:
	if is_instance_valid(_escenario):
		remove_child(_escenario)
		_escenario.queue_free()
	var recurso := load(Regiones.ruta(id)) as PackedScene
	_escenario = recurso.instantiate()
	_viajero = null
	_limpiar(_escenario)
	add_child(_escenario)
	_centro = Regiones.DATOS[id][4]
	var jugador := _escenario.get_node_or_null("Jugador") as Node3D
	if jugador:
		_centro = jugador.global_position + Vector3(0, 1, 0) if llegada else _centro
		jugador.visible = llegada != null
		if llegada:
			_viajero = jugador
			_inicio_viajero = jugador.position + Vector3(0, 0, 2.0)
			var sprite := jugador.get_node_or_null("Visual/SpriteAnimado") as AnimatedSprite3D
			if sprite:
				sprite.sprite_frames = llegada
				sprite.play(&"walk_arriba")
	if not _camara:
		_camara = Camera3D.new()
		_camara.projection = Camera3D.PROJECTION_ORTHOGONAL
		add_child(_camara)
	_camara.size = 13.0 if id == "Minas" or llegada else 23.0
	if id == "Minas":
		var luz := OmniLight3D.new()
		luz.position = _centro + Vector3(0, 4, 0)
		luz.light_color = Color("#e9c999")
		luz.light_energy = 1.5
		luz.omni_range = 17.0
		_escenario.add_child(luz)
		for malla in _escenario.find_children("*", "MeshInstance3D", true, false):
			var material: Material = malla.material_override
			if material is ShaderMaterial and material.get_shader_parameter("es_techo") == true:
				malla.hide()
	_camara.make_current()
	_tiempo = 0.0
	_process(0)

func _limpiar(nodo: Node) -> void:
	var script: Script = nodo.get_script()
	if script and nodo.get("id_npc") != null:
		var sprite := nodo.get_node_or_null("Visual/SpriteAnimado") as AnimatedSprite3D
		var cuadros: SpriteFrames = nodo.get("frames")
		if sprite and cuadros:
			sprite.sprite_frames = cuadros
			sprite.pixel_size = nodo.get("tamano_pixel")
			sprite.offset = nodo.get("desplazamiento")
			sprite.play(&"idle_abajo")
	if nodo is Label3D and (nodo.name == &"Aviso" or nodo.text.begins_with("[")):
		nodo.hide()
	if script and script.resource_path not in VISUALES:
		nodo.set_script(null)
	if nodo is CollisionObject3D:
		nodo.collision_layer = 0
		nodo.collision_mask = 0
	if nodo is Area3D:
		nodo.monitoring = false
		nodo.monitorable = false
	for hijo in nodo.get_children():
		if hijo is CanvasLayer or hijo is Camera3D or hijo is AudioStreamPlayer or hijo is AudioStreamPlayer3D:
			nodo.remove_child(hijo)
			hijo.free()
		else:
			_limpiar(hijo)

func _process(delta: float) -> void:
	if not _camara:
		return
	if not Ajustes.reducir_movimiento:
		_tiempo += delta
	if is_instance_valid(_viajero):
		var avance := 1.0 if Ajustes.reducir_movimiento else clampf(_tiempo / 2.6, 0.0, 1.0)
		_viajero.position = _inicio_viajero - Vector3(0, 0, 2.0) * avance
		if avance >= 1.0:
			_viajero.get_node("Visual/SpriteAnimado").play(&"idle_abajo")
			_viajero = null
	var angulo := 0.65 + sin(_tiempo * 0.055) * 0.35
	_camara.look_at_from_position(_centro + Vector3(sin(angulo) * 18, 12, cos(angulo) * 18), _centro)
