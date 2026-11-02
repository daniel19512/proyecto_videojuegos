extends "res://scripts/camara_seguimiento.gd"
## Orbita compartida de mundo y laboratorio; entradas persistentes en project.godot.
const GIRAR_IZQUIERDA := &"girar_camara_izquierda"
const GIRAR_DERECHA := &"girar_camara_derecha"

@export_range(10.0, 180.0, 1.0) var velocidad_giro: float = 75.0

var angulo_horizontal: float = 0.0
var centro_seguimiento := Vector3.ZERO


func _ready() -> void:
	if is_instance_valid(objetivo):
		centro_seguimiento = objetivo.global_position
		actualizar_orbita()


func _process(delta: float) -> void:
	if not is_instance_valid(objetivo):
		return
	var giro := Input.get_axis(GIRAR_IZQUIERDA, GIRAR_DERECHA)
	# Se envuelve el angulo numerico; la posicion/basis son continuas en +/-PI.
	angulo_horizontal = wrapf(angulo_horizontal - giro * deg_to_rad(velocidad_giro) * delta, -PI, PI)
	centro_seguimiento = centro_seguimiento.lerp(objetivo.global_position, 1.0 - exp(-suavizado * delta))
	actualizar_orbita()


func actualizar_orbita() -> void:
	global_position = centro_seguimiento + desplazamiento.rotated(Vector3.UP, angulo_horizontal)
	look_at(centro_seguimiento + Vector3.UP * altura_encuadre)


func _exit_tree() -> void:
	# Se libera el estado; las acciones y sus eventos permanecen en InputMap.
	for accion in [GIRAR_IZQUIERDA, GIRAR_DERECHA, &"mover_izquierda", &"mover_derecha", &"mover_arriba", &"mover_abajo"]:
		Input.action_release(accion)