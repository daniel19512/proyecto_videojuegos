extends CanvasLayer
## Autoload `Diario`: con J (o desde el menú de pausa) muestra los hilos de la
## historia y los últimos sucesos que escribe el narrador. Pausa mientras está
## abierto; J o Esc lo cierran.

const SUCESOS_VISIBLES: int = 6

var abierto: bool = false
var _pausa_propia: bool = false
var _texto: RichTextLabel
var _titulo: Label


func _ready() -> void:
	layer = 40
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_construir()
	Historia.historia_actualizada.connect(_actualizar)


func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_echo():
		return
	if abierto and (evento.is_action_pressed("abrir_diario") or evento.is_action_pressed("ui_cancel")):
		cerrar()
		get_viewport().set_input_as_handled()
	elif not abierto and evento.is_action_pressed("abrir_diario") and not get_tree().paused and not GestorRegiones.en_transicion:
		abrir(true)
		get_viewport().set_input_as_handled()


## `pausar`: false cuando lo abre el menú de pausa, que ya tiene el árbol en pausa.
func abrir(pausar: bool) -> void:
	_pausa_propia = pausar
	if pausar:
		get_tree().paused = true
	_actualizar()
	abierto = true
	visible = true


func cerrar() -> void:
	abierto = false
	visible = false
	if _pausa_propia:
		get_tree().paused = false


func texto_plano() -> String:
	return _texto.get_parsed_text()


func _actualizar() -> void:
	if _texto == null or Historia.estado.is_empty():
		return
	_titulo.text = "Diario — %s" % Reloj.descripcion().capitalize()
	var partes := PackedStringArray(["[b]Asuntos abiertos[/b]"])
	var resueltos := PackedStringArray()
	for hilo in Historia.estado.hilos:
		if hilo.estado == "abierto":
			partes.append("• [color=#7a3d10]%s[/color] — %s" % [hilo.titulo, hilo.nota])
		else:
			resueltos.append("• [color=#6b5a44]%s (resuelto)[/color]" % hilo.titulo)
	if partes.size() == 1:
		partes.append("Nada pendiente por ahora.")
	if not resueltos.is_empty():
		partes.append("")
		partes.append("[b]Resueltos[/b]")
		partes.append_array(resueltos)
	partes.append("")
	partes.append("[b]Últimos sucesos[/b]")
	var diario: Array = Historia.estado.diario
	for i in range(diario.size() - 1, maxi(diario.size() - SUCESOS_VISIBLES, 0) - 1, -1):
		partes.append("• " + diario[i])
	_texto.text = "\n".join(partes)


func _construir() -> void:
	var fondo := ColorRect.new()
	fondo.color = Color(0, 0, 0, 0.5)
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fondo)
	var marco := PanelContainer.new()
	marco.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	marco.custom_minimum_size = Vector2(720, 520)
	marco.position = -marco.custom_minimum_size * 0.5
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.86, 0.78, 0.6)
	estilo.border_color = Color(0.4, 0.27, 0.14)
	estilo.set_border_width_all(6)
	estilo.set_corner_radius_all(4)
	estilo.set_content_margin_all(20)
	marco.add_theme_stylebox_override("panel", estilo)
	fondo.add_child(marco)
	var columna := VBoxContainer.new()
	marco.add_child(columna)
	var titulo := Label.new()
	_titulo = titulo
	titulo.text = "Diario"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 28)
	titulo.add_theme_color_override("font_color", Color(0.3, 0.18, 0.08))
	columna.add_child(titulo)
	_texto = RichTextLabel.new()
	_texto.bbcode_enabled = true
	_texto.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_texto.add_theme_color_override("default_color", Color(0.18, 0.11, 0.05))
	_texto.add_theme_font_size_override("normal_font_size", 18)
	_texto.add_theme_font_size_override("bold_font_size", 20)
	columna.add_child(_texto)
	var ayuda := Label.new()
	ayuda.text = "J o Esc: cerrar"
	ayuda.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ayuda.add_theme_color_override("font_color", Color(0.35, 0.24, 0.12))
	columna.add_child(ayuda)
