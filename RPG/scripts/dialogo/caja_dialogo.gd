extends CanvasLayer
## Caja de dialogo inferior. Muestra lineas de una en una con efecto de
## escritura; F/A avanza (o completa la linea) y Esc cierra. Funciona con el
## arbol en pausa; quien la abre decide pausar o no.

signal cerrado

const CARACTERES_POR_SEGUNDO: float = 45.0

var abierta: bool = false
var lineas: PackedStringArray = []
var indice: int = 0

var _fotograma_apertura: int = -1

@onready var _nombre: Label = $Panel/Nombre
@onready var _texto: Label = $Panel/Texto
@onready var _indicador: Label = $Panel/Indicador


func _ready() -> void:
	visible = false


func mostrar(nombre: String, nuevas_lineas: PackedStringArray) -> void:
	if nuevas_lineas.is_empty():
		return
	lineas = nuevas_lineas
	indice = 0
	_nombre.text = nombre
	_fotograma_apertura = Engine.get_process_frames()
	abierta = true
	visible = true
	_mostrar_linea()


func cerrar() -> void:
	if not abierta:
		return
	abierta = false
	visible = false
	cerrado.emit()


func linea_completa() -> bool:
	return _texto.visible_ratio >= 1.0


func _process(delta: float) -> void:
	if not abierta:
		return
	if not linea_completa():
		var total: int = maxi(_texto.text.length(), 1)
		_texto.visible_ratio = minf(_texto.visible_ratio + CARACTERES_POR_SEGUNDO * delta / total, 1.0)
	_indicador.visible = linea_completa()
	# La pulsacion que abrio la caja no debe saltar la primera linea.
	if Engine.get_process_frames() == _fotograma_apertura:
		return
	if Input.is_action_just_pressed("ui_cancel"):
		cerrar()
	elif Input.is_action_just_pressed("interactuar") or Input.is_action_just_pressed("ui_accept"):
		_avanzar()


func _avanzar() -> void:
	if not linea_completa():
		_texto.visible_ratio = 1.0
		return
	indice += 1
	if indice >= lineas.size():
		cerrar()
	else:
		_mostrar_linea()


func _mostrar_linea() -> void:
	_texto.text = lineas[indice]
	_texto.visible_ratio = 0.0
	_indicador.text = "[F] Seguir" if indice < lineas.size() - 1 else "[F] Cerrar"
	_indicador.visible = false
