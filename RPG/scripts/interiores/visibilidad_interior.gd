extends Node3D
## Corte de casa de muñecas: oculta únicamente las paredes del lado de la cámara.
## Los cuerpos físicos siempre permanecen activos, incluso al ocultar la geometría.
func _process(_delta: float) -> void:
	var camara := get_viewport().get_camera_3d()
	if camara == null:
		return
	var lado := camara.global_basis.z
	for pared: Node3D in get_children():
		var normal: Vector3 = pared.get_meta("normal", Vector3.ZERO)
		pared.visible = normal.dot(lado) < 0.15
