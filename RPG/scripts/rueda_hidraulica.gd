extends Node3D
## Corriente hacia +Z: en la parte inferior, rotacion X negativa desplaza paletas a +Z.
const GRADOS_POR_SEGUNDO := -9.0
@export var grados_por_segundo: float = GRADOS_POR_SEGUNDO
func _process(delta: float) -> void:
	rotation.x = wrapf(rotation.x + deg_to_rad(grados_por_segundo)*delta, -PI, PI)
