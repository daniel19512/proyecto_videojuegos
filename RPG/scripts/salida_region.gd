extends Area3D
## Una conexión explícita. No interpreta destinos futuros ni abre límites físicos.
@export_file("*.tscn") var escena_destino: String
@export var entrada_destino: String
@export var marcador_salida: NodePath

func _ready() -> void:
	if not marcador_salida.is_empty():
		var marcador := get_node_or_null(marcador_salida) as Marker3D
		if marcador:
			global_position = marcador.global_position+Vector3.UP
	body_entered.connect(_entrar)

func _entrar(cuerpo: Node3D) -> void:
	var escena := get_tree().current_scene
	if not is_instance_valid(escena):
		return
	var config := escena.get_node_or_null("Region")
	if config and cuerpo==config.get_node_or_null(config.jugador):
		get_node("/root/GestorRegiones").solicitar(escena_destino,entrada_destino)
