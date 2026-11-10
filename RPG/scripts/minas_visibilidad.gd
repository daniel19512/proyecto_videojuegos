extends Node3D
## Recorte exclusivo de roca superior; nunca modifica colisiones ni cámara.
@export var superficies: Array[ShaderMaterial] = []

func _process(_delta: float) -> void:
	var camara := get_viewport().get_camera_3d()
	var jugador := get_parent().get_node_or_null("Jugador") as Node3D
	if camara == null or jugador == null:
		return
	for material in superficies:
		material.set_shader_parameter("jugador", jugador.global_position)
		material.set_shader_parameter("camara", camara.global_position)
