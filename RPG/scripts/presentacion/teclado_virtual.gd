extends PanelContainer

const Estilo = preload("res://scripts/presentacion/estilo.gd")
var _objetivo: LineEdit
var _entrada: LineEdit
var _anterior: Control
var _foco_inicial: Control

static func mostrar(campo: LineEdit) -> void:
	var panel := new()
	panel._objetivo = campo
	panel._anterior = campo.get_viewport().gui_get_focus_owner()
	var capa := CanvasLayer.new()
	capa.layer = 90
	capa.process_mode = Node.PROCESS_MODE_ALWAYS
	campo.add_child(capa)
	var fondo := ColorRect.new()
	fondo.color = Color(0.08, 0.05, 0.04, 0.64)
	capa.add_child(fondo)
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.name = "Teclado"
	capa.add_child(panel)

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	var pila := VBoxContainer.new()
	add_child(pila)
	pila.add_child(Estilo.titulo("Teclado", 23))
	_entrada = LineEdit.new()
	_entrada.text = _objetivo.text
	_entrada.max_length = _objetivo.max_length
	_entrada.secret = _objetivo.secret
	_entrada.editable = false
	_entrada.focus_mode = Control.FOCUS_NONE
	pila.add_child(_entrada)
	var cuadricula := GridContainer.new()
	cuadricula.columns = 10
	pila.add_child(cuadricula)
	var caracteres := "ABCDEFGHIJKLMNÑOPQRSTUVWXYZÁÉÍÓÚÜ0123456789.,¿?¡!;:/_-+@[]"
	for caracter in caracteres:
		var tecla := Estilo.boton(caracter, _agregar.bind(caracter))
		tecla.custom_minimum_size.x = 43
		cuadricula.add_child(tecla)
	var acciones := HBoxContainer.new()
	pila.add_child(acciones)
	var minusculas := CheckButton.new()
	minusculas.text = "Minúsculas"
	minusculas.button_pressed = true
	acciones.add_child(minusculas)
	minusculas.toggled.connect(func(activas):
		for tecla in cuadricula.get_children():
			tecla.text = tecla.text.to_lower() if activas else tecla.text.to_upper())
	for tecla in cuadricula.get_children():
		tecla.text = tecla.text.to_lower()
	acciones.add_child(Estilo.boton("Espacio", _agregar.bind(" ")))
	acciones.add_child(Estilo.boton("Borrar", func(): _entrada.text = _entrada.text.left(-1)))
	acciones.add_child(Estilo.boton("Aceptar", _cerrar.bind(true)))
	acciones.add_child(Estilo.boton("Cancelar", _cerrar.bind(false)))
	_foco_inicial = cuadricula.get_child(0)
	_foco_inicial.grab_focus()

func _input(evento: InputEvent) -> void:
	if evento.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_cerrar(false)
		return
	var lados := {"ui_left": SIDE_LEFT, "ui_right": SIDE_RIGHT, "ui_up": SIDE_TOP, "ui_down": SIDE_BOTTOM}
	for accion in lados:
		if not evento.is_action_pressed(accion):
			continue
		var foco := get_viewport().gui_get_focus_owner()
		var siguiente := foco.find_valid_focus_neighbor(lados[accion]) if foco and is_ancestor_of(foco) else _foco_inicial
		if siguiente and is_ancestor_of(siguiente):
			siguiente.grab_focus()
		get_viewport().set_input_as_handled()
		return

func _agregar(caracter: String) -> void:
	var foco := get_viewport().gui_get_focus_owner() as Button
	var nuevo := foco.text if foco and foco.text.length() == 1 else caracter
	if _entrada.max_length <= 0 or _entrada.text.length() < _entrada.max_length:
		_entrada.text += nuevo

func _cerrar(aplicar: bool) -> void:
	if aplicar:
		_objetivo.text = _entrada.text
		_objetivo.text_changed.emit(_objetivo.text)
	if is_instance_valid(_anterior):
		_anterior.grab_focus()
	get_parent().queue_free()
