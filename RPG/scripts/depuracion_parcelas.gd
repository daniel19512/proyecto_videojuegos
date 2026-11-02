extends Node3D
## Solo cambia la visibilidad de marcas de desarrollo; no altera geometria ni metadatos.
@export var mostrar_limites_parcelas: bool = false:
	set(valor):
		mostrar_limites_parcelas = valor
		if is_inside_tree():
			actualizar_limites()

func _ready() -> void:
	actualizar_limites()

func obtener_limites() -> Array[MeshInstance3D]:
	var limites: Array[MeshInstance3D] = []
	for nombre in ["Parcelas","Jardines","Reservas","Plaza"]:
		var grupo := get_node_or_null(NodePath(nombre))
		if grupo == null:
			continue
		for borde: MeshInstance3D in grupo.find_children("Borde*","MeshInstance3D",true,false):
			limites.append(borde)
	return limites

func actualizar_limites() -> void:
	for borde in obtener_limites():
		borde.visible = mostrar_limites_parcelas
