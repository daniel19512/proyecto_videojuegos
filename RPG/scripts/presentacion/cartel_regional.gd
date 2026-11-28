extends Control

const Regiones = preload("res://scripts/presentacion/regiones.gd")
const Estilo = preload("res://scripts/presentacion/estilo.gd")
var _imagen: TextureRect
var _nombre: Label
var _descripcion: Label
var _cargando: Label
var _pulso := 0.0
var _destino := ""

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_imagen = Estilo.textura(null, Vector2.ZERO)
	add_child(_imagen)
	_imagen.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_imagen.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_imagen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var velo := ColorRect.new()
	velo.color = Color(0.07, 0.05, 0.03, 0.26)
	velo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(velo)
	velo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var centro := CenterContainer.new()
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(centro)
	centro.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	centro.offset_top = -180
	centro.offset_bottom = -24
	var panel := PanelContainer.new()
	centro.add_child(panel)
	var pila := VBoxContainer.new()
	pila.custom_minimum_size.x = 440
	panel.add_child(pila)
	_nombre = Estilo.titulo("")
	_descripcion = Estilo.texto("")
	_cargando = Estilo.texto("")
	for etiqueta in [_nombre, _descripcion, _cargando]:
		etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		pila.add_child(etiqueta)
	hide()

func presentar(id: String) -> void:
	_destino = id
	_imagen.texture = Regiones.imagen(id)
	_nombre.text = Regiones.nombre(id)
	_descripcion.text = Regiones.DATOS[id][2]
	_pulso = 0.0
	_cargando.text = "Cargando ·"
	modulate.a = 1.0
	show()

func _process(delta: float) -> void:
	if visible:
		_pulso += delta
		_cargando.text = "Cargando " + "·".repeat(posmod(int(_pulso * 3.0), 3) + 1)
