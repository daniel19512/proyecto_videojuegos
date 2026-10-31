extends CanvasLayer
## Comparador local de pruebas_assets.tscn; no modifica el seguimiento compartido.

const TAMANOS: Array[float] = [23.0, 19.0, 17.0, 15.0]
const NOMBRES: Array[String] = ["Original", "Intermedia", "Cercana", "Muy cercana"]
const TECLAS: Array[Key] = [KEY_1, KEY_2, KEY_3, KEY_4]

@onready var camara: Camera3D = get_parent().get_node("CamaraPrincipal")
@onready var opciones: VBoxContainer = $Panel/Margen/Contenido/Opciones
@onready var seleccion: Label = $Panel/Margen/Contenido/Seleccion


func _ready() -> void:
	for i in TAMANOS.size():
		var boton: BaseButton = opciones.get_child(i)
		boton.pressed.connect(seleccionar.bind(i))
	seleccionar(0)


func seleccionar(indice: int) -> void:
	if indice < 0 or indice >= TAMANOS.size():
		return
	camara.size = TAMANOS[indice]
	for i in TAMANOS.size():
		var boton: BaseButton = opciones.get_child(i)
		boton.set_pressed_no_signal(i == indice)
	seleccion.text = "Seleccionada: %d — %s" % [TAMANOS[indice], NOMBRES[indice]]


func _unhandled_key_input(evento: InputEvent) -> void:
	if evento is not InputEventKey or not evento.pressed or evento.echo:
		return
	if evento.ctrl_pressed or evento.alt_pressed or evento.meta_pressed:
		return
	var tecla: Key = evento.physical_keycode if evento.physical_keycode != 0 else evento.keycode
	var indice := TECLAS.find(tecla)
	if indice >= 0:
		seleccionar(indice)
		get_viewport().set_input_as_handled()
