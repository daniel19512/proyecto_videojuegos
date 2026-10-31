extends Camera3D

@export var objetivo: Node3D
# -32 grados respecto a la horizontal: 58 grados desde la vertical.
@export var desplazamiento: Vector3 = Vector3(0.0, 13.8, 20.80435)
@export var altura_encuadre: float = 0.8
@export_range(0.1, 30.0, 0.1) var suavizado: float = 6.0


func _ready() -> void:
	if is_instance_valid(objetivo):
		global_position = objetivo.global_position + desplazamiento
		look_at(objetivo.global_position + Vector3.UP * altura_encuadre)


func _process(delta: float) -> void:
	if is_instance_valid(objetivo):
		var destino: Vector3 = objetivo.global_position + desplazamiento
		global_position = global_position.lerp(destino, 1.0 - exp(-suavizado * delta))