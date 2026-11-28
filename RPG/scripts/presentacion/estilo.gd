extends RefCounted

const RUTA := "res://scenes/presentacion/sapientia.tres"
const ORO := Color("#b99a59")
const PAPEL := Color("#e6d6b5")

static func titulo(texto: String, tamano: int = 30) -> Label:
	var etiqueta := Label.new()
	etiqueta.text = texto
	etiqueta.theme_type_variation = &"Titulo"
	etiqueta.add_theme_font_size_override("font_size", tamano)
	etiqueta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return etiqueta

static func texto(texto_visible: String) -> Label:
	var etiqueta := Label.new()
	etiqueta.text = texto_visible
	etiqueta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return etiqueta

static func boton(texto_visible: String, accion: Callable) -> Button:
	var control := Button.new()
	control.text = texto_visible
	control.pressed.connect(accion)
	return control

static func textura(imagen: Texture2D, minimo: Vector2) -> TextureRect:
	var control := TextureRect.new()
	control.custom_minimum_size = minimo
	control.texture = imagen
	control.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	control.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return control

static func confirmar(raiz: Node, texto_visible: String, accion: Callable, aceptar: String = "Confirmar", alternativa: Callable = Callable(), titulo_visible: String = "SapientIA", cancelar: String = "Volver", al_cancelar: Callable = Callable()) -> void:
	if raiz.has_node("ConfirmacionSapientia"):
		return
	var dialogo := ConfirmationDialog.new()
	dialogo.name = "ConfirmacionSapientia"
	dialogo.title = titulo_visible
	dialogo.process_mode = Node.PROCESS_MODE_ALWAYS
	dialogo.theme = load(RUTA)
	dialogo.dialog_text = texto_visible
	dialogo.ok_button_text = aceptar
	dialogo.cancel_button_text = cancelar
	var foco := raiz.get_viewport().gui_get_focus_owner()
	dialogo.confirmed.connect(func():
		dialogo.hide()
		dialogo.queue_free()
		accion.call())
	if alternativa.is_valid():
		dialogo.add_button("Salir sin guardar", true, "alternativa")
		dialogo.custom_action.connect(func(_id):
			dialogo.hide()
			dialogo.queue_free()
			alternativa.call())
	dialogo.window_input.connect(func(evento):
		if evento.is_action_pressed("ui_cancel"):
			dialogo.set_input_as_handled()
			dialogo.hide()
			dialogo.canceled.emit())
	dialogo.canceled.connect(func():
		dialogo.queue_free()
		if al_cancelar.is_valid():
			al_cancelar.call()
		if is_instance_valid(foco):
			foco.grab_focus())
	raiz.add_child(dialogo)
	dialogo.popup_centered()
	dialogo.get_cancel_button().grab_focus()


static func aviso_interaccion(texto_visible: String) -> String:
	var cierre := texto_visible.find("]")
	if cierre >= 0 and texto_visible.begins_with("["):
		return "[%s]%s" % [Ajustes.indicacion("interactuar"), texto_visible.substr(cierre + 1)]
	return texto_visible
