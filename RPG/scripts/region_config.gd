extends Node
## Configuración de una región jugable. Los escenarios y sus cierres no se alteran.
@export var id_region: StringName
@export var jugador: NodePath = ^"../Jugador"
@export var camara: NodePath = ^"../CamaraPrincipal"
@export var entradas: Dictionary[String, NodePath] = {}

func _ready() -> void:
	get_parent().set_meta("id_region",id_region)

func obtener_entrada(id: String) -> Marker3D:
	if not entradas.has(id):
		return null
	return get_node_or_null(entradas[id]) as Marker3D
