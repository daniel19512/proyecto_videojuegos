extends CanvasLayer
## Autoload `Diario`: con J (o desde el menú de pausa) muestra los hilos de la
## historia y los últimos sucesos que escribe el narrador. Pausa mientras está
## abierto; J o Esc lo cierran.

const SUCESOS_VISIBLES: int = 6
const Descubrimientos = preload("res://scripts/vida/descubrimientos.gd")

var abierto: bool = false
var _pausa_propia: bool = false
var _foco_anterior: Control
var _texto: RichTextLabel
var _titulo: Label
var _propietario: Label
var _seccion := 0
var _hallazgo := false
var _boton_seguir: Button
const SECCIONES := ["Acontecimientos", "Historia principal", "Misiones", "Relaciones", "Descubrimientos"]


func _ready() -> void:
	layer = 40
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_construir()
	Historia.historia_actualizada.connect(_actualizar)
	Misiones.actualizado.connect(_actualizar_si_abierto)


func _actualizar_si_abierto() -> void:
	if abierto and not _hallazgo:
		_actualizar()


func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_echo():
		return
	if abierto and (evento.is_action_pressed("abrir_diario") or evento.is_action_pressed("ui_cancel")):
		cerrar()
		get_viewport().set_input_as_handled()
	elif not abierto and evento.is_action_pressed("abrir_diario") and not get_tree().paused and not GestorRegiones.en_transicion:
		abrir(true)
		get_viewport().set_input_as_handled()
	elif abierto and (evento.is_action_pressed("ui_up") or evento.is_action_pressed("ui_down")):
		var barra := _texto.get_v_scroll_bar()
		barra.value += 48 if evento.is_action_pressed("ui_down") else -48
		get_viewport().set_input_as_handled()
	elif abierto and (evento.is_action_pressed("ui_left") or evento.is_action_pressed("ui_right")):
		_cambiar_seccion(posmod(_seccion + (1 if evento.is_action_pressed("ui_right") else -1), SECCIONES.size()))
		get_viewport().set_input_as_handled()
	elif abierto and not _hallazgo and _seccion in [1, 2] and evento.is_action_pressed("ui_accept"):
		_seguir()
		get_viewport().set_input_as_handled()


## `pausar`: false cuando lo abre el menú de pausa, que ya tiene el árbol en pausa.
func abrir(pausar: bool) -> void:
	AudioJuego.sonido_interfaz("abrir")
	_hallazgo = false
	_foco_anterior = get_viewport().gui_get_focus_owner()
	_pausa_propia = pausar
	if pausar:
		get_tree().paused = true
	_actualizar()
	_texto.scroll_to_line(0)
	abierto = true
	visible = true


func cerrar() -> void:
	abierto = false
	visible = false
	if _pausa_propia:
		get_tree().paused = false
	if is_instance_valid(_foco_anterior):
		_foco_anterior.grab_focus()


func texto_plano() -> String:
	return _texto.get_parsed_text()


func mostrar_descubrimiento(id: String, aviso: String) -> void:
	abrir(true)
	_hallazgo = true
	_boton_seguir.hide()
	var ficha: Dictionary = Descubrimientos.PUNTOS[id]
	_texto.text = "[b]%s[/b]\n%s" % [ficha.titulo, ficha.texto]
	if not aviso.is_empty():
		_texto.append_text("\n\n" + aviso)
	_texto.scroll_to_line(0)


func _actualizar() -> void:
	if _texto == null or Historia.estado.is_empty():
		return
	_propietario.text = "Diario de %s" % EstadoMundo.nombre_protagonista()
	_titulo.text = "%s — %s" % [SECCIONES[_seccion], Reloj.descripcion().capitalize()]
	_boton_seguir.visible = _seccion in [1, 2]
	var seguida: Dictionary = Misiones.ficha(Misiones.seguida())
	_boton_seguir.text = "Cambiar seguimiento · " + str(seguida.get("titulo", "Sin seguimiento"))
	if _seccion in [1, 2, 3]:
		var registros := Misiones.resumen_relaciones() if _seccion == 3 else Misiones.resumen(_seccion == 1)
		_texto.text = "\n".join(registros) if not registros.is_empty() else "Todavía no hay entradas."
		return
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
	partes.append_array(Misiones.acontecimientos())
	var descubrimientos := PackedStringArray()
	var descubiertos: Dictionary = EstadoMundo.datos.zonas.get("@descubrimientos", {})
	for id in Descubrimientos.PUNTOS:
		if descubiertos.get(id, {}).get("descubierto", false):
			var ficha: Dictionary = Descubrimientos.PUNTOS[id]
			descubrimientos.append("• [b]%s[/b] — %s" % [ficha.titulo, ficha.texto])
	if not descubrimientos.is_empty():
		partes.append("\n[b]Descubrimientos[/b]")
		partes.append_array(descubrimientos)
	_texto.text = "\n".join(descubrimientos if _seccion == 4 else partes)


func _cambiar_seccion(indice: int) -> void:
	AudioJuego.sonido_interfaz("abrir")
	_hallazgo = false
	_seccion = indice
	_actualizar()
	_texto.scroll_to_line(0)


func _seguir() -> void:
	Misiones.alternar_seguimiento(_seccion == 1)


func _construir() -> void:
	var fondo := ColorRect.new()
	fondo.color = Color(0, 0, 0, 0.5)
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fondo)
	var marco := PanelContainer.new()
	marco.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	marco.custom_minimum_size = Vector2(720, 520)
	marco.position = -marco.custom_minimum_size * 0.5
	marco.theme_type_variation = &"Pergamino"
	fondo.add_child(marco)
	var columna := VBoxContainer.new()
	marco.add_child(columna)
	_propietario = Label.new()
	_propietario.theme_type_variation = &"TituloTinta"
	_propietario.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	columna.add_child(_propietario)
	var titulo := Label.new()
	_titulo = titulo
	titulo.text = "Diario"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.theme_type_variation = &"TituloTinta"
	titulo.add_theme_font_size_override("font_size", 28)
	titulo.add_theme_color_override("font_color", Color(0.3, 0.18, 0.08))
	columna.add_child(titulo)
	var pestanas := HBoxContainer.new()
	pestanas.alignment = BoxContainer.ALIGNMENT_CENTER
	columna.add_child(pestanas)
	for i in SECCIONES.size():
		var boton := Button.new()
		boton.text = SECCIONES[i]
		boton.focus_mode = Control.FOCUS_NONE
		boton.pressed.connect(_cambiar_seccion.bind(i))
		pestanas.add_child(boton)
	_texto = RichTextLabel.new()
	_texto.bbcode_enabled = true
	_texto.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_texto.add_theme_color_override("default_color", Color(0.18, 0.11, 0.05))
	columna.add_child(_texto)
	_boton_seguir = Button.new()
	_boton_seguir.focus_mode = Control.FOCUS_NONE
	_boton_seguir.pressed.connect(_seguir)
	columna.add_child(_boton_seguir)
	var ayuda := Label.new()
	ayuda.text = "←/→: sección · ↑/↓: desplazar · J, Esc o B: cerrar"
	ayuda.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ayuda.add_theme_color_override("font_color", Color(0.35, 0.24, 0.12))
	columna.add_child(ayuda)
