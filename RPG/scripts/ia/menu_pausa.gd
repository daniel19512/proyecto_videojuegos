extends CanvasLayer
## Autoload `MenuPausa`: Esc (con el juego en marcha) pausa y abre el menú:
## Continuar, Diario, Opciones de IA y Salir. Las opciones guardan la clave y
## el modelo en user://ia.cfg mediante el autoload IA, muestran el gasto de la
## sesión y permiten empezar una historia nueva (con confirmación).

const Estilo = preload("res://scripts/presentacion/estilo.gd")
const Opciones = preload("res://scripts/presentacion/opciones.gd")
var _opciones_generales: Control
var abierto: bool = false
var _principal: VBoxContainer
var _opciones: VBoxContainer
var _activa: CheckBox
var _clave: LineEdit
var _modelo: LineEdit
var _tope: SpinBox
var _uso: Label
var _estado: Label
var _nueva: Button
var _confirmar_nueva: bool = false


func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_construir()
	IA.uso_actualizado.connect(func(_t, _c): _actualizar_uso())


func _unhandled_input(evento: InputEvent) -> void:
	if not (evento.is_action_pressed("pausar_juego") or evento.is_action_pressed("ui_cancel")) or evento.is_echo() or MapaMundo.abierto or is_instance_valid(_opciones_generales):
		return
	if abierto:
		if Diario.abierto:
			return
		if _opciones.visible:
			_volver()
		else:
			cerrar()
		get_viewport().set_input_as_handled()
	elif not get_tree().paused and not GestorRegiones.en_transicion and GestorRegiones.region_actual != &"":
		abrir()
		get_viewport().set_input_as_handled()


func abrir() -> void:
	get_tree().paused = true
	abierto = true
	visible = true
	_mostrar_principal()


func cerrar() -> void:
	abierto = false
	visible = false
	get_tree().paused = false


func mostrar_opciones() -> void:
	_principal.visible = false
	_opciones.visible = true
	_activa.button_pressed = IA.activa
	_clave.text = IA.clave
	_modelo.text = IA.modelo
	_tope.value = IA.tope_tokens / 1000
	_estado.text = ""
	_confirmar_nueva = false
	_nueva.text = "Nueva historia"
	_actualizar_uso()
	_activa.grab_focus()


## Aplica los campos al servicio de IA y los guarda.
func aplicar_opciones() -> void:
	IA.activa = _activa.button_pressed
	IA.clave = _clave.text.strip_edges()
	IA.modelo = _modelo.text.strip_edges() if not _modelo.text.strip_edges().is_empty() else IA.MODELO_POR_DEFECTO
	IA.tope_tokens = int(_tope.value) * 1000
	IA.guardar_config()
	Aldeanos.planificar_si_falta()


func _mostrar_principal() -> void:
	_opciones.visible = false
	_principal.visible = true
	(_principal.get_child(1) as Button).grab_focus()


func _volver() -> void:
	aplicar_opciones()
	_mostrar_principal()


func _abrir_diario() -> void:
	Diario.abrir(false)


func _nueva_historia() -> void:
	if not _confirmar_nueva:
		_confirmar_nueva = true
		_nueva.text = "¿Seguro? Se borra la historia actual (pulsa otra vez)"
		return
	Historia.reiniciar()
	_confirmar_nueva = false
	_nueva.text = "Nueva historia"
	_estado.text = "Historia reiniciada."


func _actualizar_uso() -> void:
	if _uso:
		_uso.text = "Gasto de esta sesión: %d tokens de %d (%.4f USD)" % [IA.tokens_sesion, IA.tope_tokens, IA.coste_sesion]


func _construir() -> void:
	var fondo := ColorRect.new()
	fondo.color = Color(0, 0, 0, 0.55)
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fondo)
	var marco := PanelContainer.new()
	marco.custom_minimum_size = Vector2(620, 0)
	marco.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	marco.grow_horizontal = Control.GROW_DIRECTION_BOTH
	marco.grow_vertical = Control.GROW_DIRECTION_BOTH
	fondo.add_child(marco)
	var pila := VBoxContainer.new()
	marco.add_child(pila)

	_principal = VBoxContainer.new()
	_principal.add_theme_constant_override("separation", 10)
	pila.add_child(_principal)
	_principal.add_child(_titulo("Pausa"))
	_principal.add_child(_boton("Continuar", cerrar))
	_principal.add_child(_boton("Diario", _abrir_diario))
	_principal.add_child(_boton("Opciones", _mostrar_opciones_generales.bind("Gráficos")))
	_principal.add_child(_boton("Guardar partida", _guardar_partida))
	_principal.add_child(_boton("Mapa", MapaMundo.abrir))
	_principal.add_child(_boton("Controles", _mostrar_opciones_generales.bind("Controles")))
	_principal.add_child(_boton("Menú principal", _confirmar_salida.bind(true)))
	_principal.add_child(_boton("Salir del juego", _confirmar_salida.bind(false)))

	_opciones = VBoxContainer.new()
	_opciones.add_theme_constant_override("separation", 8)
	_opciones.visible = false
	pila.add_child(_opciones)
	_opciones.add_child(_titulo("Opciones de IA"))
	_activa = CheckBox.new()
	_activa.text = "Usar IA en los aldeanos (sin ella, diálogos fijos)"
	_opciones.add_child(_activa)
	_opciones.add_child(_etiqueta("Clave de OpenRouter (se guarda solo en este equipo)"))
	_clave = LineEdit.new()
	_clave.secret = true
	_clave.placeholder_text = "sk-or-…"
	_opciones.add_child(_clave)
	_opciones.add_child(_etiqueta("Modelo"))
	_modelo = LineEdit.new()
	_modelo.placeholder_text = IA.MODELO_POR_DEFECTO
	_opciones.add_child(_modelo)
	_opciones.add_child(_etiqueta("Tope por sesión (miles de tokens)"))
	_tope = SpinBox.new()
	_tope.min_value = 10
	_tope.max_value = 5000
	_tope.step = 10
	_opciones.add_child(_tope)
	_uso = _etiqueta("")
	_opciones.add_child(_uso)
	_nueva = _boton("Nueva historia", _nueva_historia)
	_opciones.add_child(_nueva)
	_estado = _etiqueta("")
	_estado.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_opciones.add_child(_estado)
	_opciones.add_child(_boton("Guardar y volver", _volver))


func _guardar_partida() -> void:
	if not EstadoMundo.automatico:
		_aviso_partida("Inicia la partida desde la escena principal para guardarla.")
		return
	_aviso_partida("Partida guardada." if EstadoMundo.guardar_actual() else "No se pudo guardar la partida.")


func _aviso_partida(texto: String) -> void:
	var aviso := AcceptDialog.new()
	aviso.dialog_text = texto
	aviso.window_input.connect(func(evento):
		if evento.is_action_pressed("ui_cancel"):
			aviso.set_input_as_handled()
			aviso.hide()
			aviso.canceled.emit())
	aviso.confirmed.connect(aviso.queue_free)
	aviso.canceled.connect(aviso.queue_free)
	add_child(aviso)
	aviso.popup_centered()


func _mostrar_opciones_generales(seccion: String) -> void:
	_principal.hide()
	_opciones_generales = Opciones.new()
	_opciones_generales.seccion_inicial = seccion
	add_child(_opciones_generales)
	_opciones_generales.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_opciones_generales.offset_left = 32
	_opciones_generales.offset_right = -32
	_opciones_generales.offset_top = 24
	_opciones_generales.offset_bottom = -24
	_opciones_generales.cerrado.connect(_mostrar_principal)


func _confirmar_salida(volver: bool) -> void:
	var pregunta := "¿Volver al menú principal?" if volver else "¿Salir del juego?"
	var aceptar := "Guardar y volver" if volver else "Guardar y salir"
	Estilo.confirmar(self, pregunta, _salir.bind(volver, true), aceptar, _salir.bind(volver, false))

func _salir(volver: bool, guardar: bool) -> void:
	if volver and IA.peticiones_en_curso > 0:
		_aviso_partida("Hay una respuesta pendiente. Vuelve a intentarlo cuando termine.")
		return
	if guardar and not EstadoMundo.guardar_actual():
		_aviso_partida("No se pudo guardar la partida. Puedes volver a intentarlo.")
		return
	if volver:
		if Partidas.volver_al_menu():
			cerrar()
		else:
			_aviso_partida("No se pudo abrir el menú principal.")
	else:
		AudioJuego.salir_del_juego()

func _titulo(texto: String) -> Label:
	var etiqueta := Estilo.titulo(texto)
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta.add_theme_font_size_override("font_size", 28)
	etiqueta.add_theme_color_override("font_color", Color(0.98, 0.85, 0.5))
	return etiqueta


func _etiqueta(texto: String) -> Label:
	var etiqueta := Label.new()
	etiqueta.text = texto
	etiqueta.add_theme_color_override("font_color", Color(0.9, 0.83, 0.68))
	return etiqueta


func _boton(texto: String, accion: Callable) -> Button:
	var boton := Button.new()
	boton.text = texto

	boton.pressed.connect(accion)
	return boton
