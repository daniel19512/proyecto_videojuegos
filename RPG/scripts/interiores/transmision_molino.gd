extends Node3D
## Eje este-oeste movido por la rueda; la corona cambia el giro al eje vertical.
const Rueda := preload("res://scripts/rueda_hidraulica.gd")
const DIENTES_MOTRIZ := 16
const DIENTES_CORONA := 12

@onready var eje: Node3D = $EjeHorizontal
@onready var corona: Node3D = $EjeVertical


func _process(delta: float) -> void:
	var avance := deg_to_rad(Rueda.GRADOS_POR_SEGUNDO) * delta
	eje.rotation.x = wrapf(eje.rotation.x + avance, -PI, PI)
	corona.rotation.y = wrapf(corona.rotation.y - avance * DIENTES_MOTRIZ / DIENTES_CORONA, -PI, PI)
