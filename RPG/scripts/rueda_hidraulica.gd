extends Node3D
## Corriente hacia +Z: en la parte inferior, rotacion X negativa desplaza paletas a +Z.
@export var grados_por_segundo: float = -9.0
func _process(delta: float) -> void:
	rotation.x = wrapf(rotation.x + deg_to_rad(grados_por_segundo)*delta, -PI, PI)
