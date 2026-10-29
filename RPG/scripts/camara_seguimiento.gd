extends Camera3D

@export var objetivo: Node3D
@export var desplazamiento: Vector3 = Vector3(0.0, 14.0, 16.68455)
@export_range(0.1, 30.0, 0.1) var suavizado: float = 6.0


func _ready() -> void:
	if is_instance_valid(objetivo):
		global_position = objetivo.global_position + desplazamiento


func _process(delta: float) -> void:
	if is_instance_valid(objetivo):
		var destino: Vector3 = objetivo.global_position + desplazamiento
		global_position = global_position.lerp(destino, 1.0 - exp(-suavizado * delta))