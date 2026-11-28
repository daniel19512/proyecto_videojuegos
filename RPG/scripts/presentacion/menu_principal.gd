extends Control

const Estilo = preload("res://scripts/presentacion/estilo.gd")
const Regiones = preload("res://scripts/presentacion/regiones.gd")
const Vista = preload("res://scripts/presentacion/vista_regional.gd")
const Opciones = preload("res://scripts/presentacion/opciones.gd")
const Teclado = preload("res://scripts/presentacion/teclado_virtual.gd")
const LOGOTIPO = preload("res://assets/branding/sapientIA.png")
const DURACION_FONDO := 20.0
const SECUENCIA := ["CamposYGranjas", "Aldea", "Ruinas", "Aldea"]
const RELATO := [
	"Entre senderos y campos, cada estación trae su propio ritmo.",
	"En la aldea, los oficios y sus habitantes dan forma a los días.",
	"Más allá del bosque, las piedras guardan historias que aún pueden escucharse.",
	"Hoy llegas a la aldea. Aquí comienza tu historia. Tú eliges adónde te lleva.",
]
const AYUDA := "SapientIA es una aventura tranquila. La historia principal es opcional: explora a tu ritmo, cultiva, comercia y aprende oficios.\n\nCamina con WASD, flechas o stick izquierdo. Gira con Q/E o el stick derecho. F/A conversa, recoge, abre puertas o usa estaciones. T/X abre el comercio cuando está disponible.\n\nAbre la mochila con I/Y y el diario con J o al pulsar el stick izquierdo. M o Ver abre el mapa. Esc o Menú pausa. En menús, usa la cruceta o el stick para moverte, A para aceptar y B para volver.\n\nHabla, acepta encargos o entrega regalos para conocer a los habitantes. El diario sigue misiones, amistad, confianza y descubrimientos. Con OpenRouter configurado puedes conversar libremente.\n\nSiembra en los bancales, vende productos y visita talleres para encontrar recetas y minijuegos. Guarda desde la pausa. Tu espacio también se guarda automáticamente."
const CREDITOS := "Desarrolladores\nDaniel Alejandro Berrio Restrepo\nSamuel Castro Carmona\nEstudiantes de Ciencias de la Computación.\n\nProyecto académico — 2026\n\nGodot Engine · GDScript\nConversación opcional mediante OpenRouter y GLM Flash (Z.ai).\n\nRecursos visuales: Quaternius, Kay Lousberg (KayKit), hooray4brains, Larchrow, Avramania, Kenney y colaboradores de los paquetes de interiores. Sprites originales de Gif, Noiracide y Romi.\nTipografías Cinzel y Alegreya, SIL Open Font License 1.1.\n\nMúsica: alkakrab y maxstack.\nAudio: Magnesus, Nox_Sound, reklamacja, brunoboselli, lebaston100, Emmaproductions, Benboncan, bmoreno, cabled_mess, heyheytheree, pagancow, steprock y Outta This World Audio.\n\nGoteos de cueva de lebaston100 (CC BY 4.0). Free Fantasy UI Sounds se usa bajo los términos del autor, sin regalías. Las condiciones y los enlaces figuran en el registro de créditos del proyecto. Godot Engine se distribuye bajo la licencia MIT."

var en_intro := false
var _vista: Node3D
var _tinte: ColorRect
var _oscuro: ColorRect
var _marco: Control
var _contenido: VBoxContainer
var _status: Label
var _pagina := ""
var _fondo := 0
var _reloj_fondo := 0.0
var _intro_id := 0
var _intro_paso := 0
var _aspectos: Array[Dictionary]
var _aspecto := 0
var _direccion := 3
var _caminar := false
var _nombre: LineEdit
var _sprite: AnimatedSprite2D
var _descripcion_aspecto: Label
var _opciones: Control
var _fundiendo := false
var _saliendo := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	if DisplayServer.get_name() != "headless":
		DisplayServer.set_icon(LOGOTIPO.get_image())
	_vista = Vista.new()
	add_child(_vista)
	_tinte = ColorRect.new()
	_tinte.color = Color(0.095, 0.065, 0.04, 0.35)
	_tinte.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_tinte)
	_tinte.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_oscuro = ColorRect.new()
	_oscuro.color = Color(0, 0, 0, 0)
	_oscuro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_oscuro)
	_oscuro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if get_tree().get_script() == null:
		Partidas.migrar()
	_vista.mostrar("Aldea")
	_principal()

func _process(delta: float) -> void:
	if _fundiendo or _saliendo or Partidas.ocupado:
		return
	_reloj_fondo += delta
	if en_intro and _reloj_fondo >= 7.5:
		_intro_paso += 1
		if _intro_paso == SECUENCIA.size():
			_terminar_intro()
		else:
			_mostrar_intro(true)
	elif not en_intro and _reloj_fondo >= DURACION_FONDO:
		_fondo = (_fondo + 1) % Regiones.DATOS.size()
		_fondo_fundido(Regiones.DATOS.keys()[_fondo])

func _input(evento: InputEvent) -> void:
	if _pagina not in ["ayuda", "creditos"]:
		return
	var direccion := int(evento.is_action_pressed("ui_down")) - int(evento.is_action_pressed("ui_up"))
	if direccion:
		var scroll := _contenido.get_parent() as ScrollContainer
		scroll.scroll_vertical += direccion * 44
		get_viewport().set_input_as_handled()

func _unhandled_input(evento: InputEvent) -> void:
	if not evento.is_action_pressed("ui_cancel") or evento.is_echo() or is_instance_valid(_opciones):
		return
	get_viewport().set_input_as_handled()
	match _pagina:
		"intro": _terminar_intro()
		"crear": _espacios(true)
		"principal": confirmar_salida()
		_: _principal()

func _pagina_base(id: String, titulo: String, ancho: float = 600) -> void:
	if is_instance_valid(_marco):
		_marco.hide()
		_marco.queue_free()
	_pagina = id
	var posicion := CenterContainer.new()
	posicion.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(posicion)
	posicion.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if id == "principal" and get_viewport_rect().size.x >= 780:
		posicion.anchor_right = 0.46
	_marco = posicion
	var panel := PanelContainer.new()
	panel.custom_minimum_size.x = minf(ancho, get_viewport_rect().size.x - 48)
	posicion.add_child(panel)
	_contenido = VBoxContainer.new()
	_contenido.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if id == "intro":
		panel.add_child(_contenido)
	else:
		var scroll := ScrollContainer.new()
		scroll.follow_focus = id not in ["ayuda", "creditos"]
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		var altura := 570.0 if id == "principal" else 530.0
		scroll.custom_minimum_size.y = minf(altura, get_viewport_rect().size.y - 54.0)
		panel.add_child(scroll)
		scroll.add_child(_contenido)
	if not titulo.is_empty():
		_contenido.add_child(Estilo.titulo(titulo))
	_status = Estilo.texto("")
	_status.hide()


func _boton(titulo: String, accion: Callable) -> Button:
	var boton := Estilo.boton(titulo, accion)
	_contenido.add_child(boton)
	return boton

func _principal() -> void:
	_pagina_base("principal", "", 330)
	var logo := Estilo.textura(LOGOTIPO, Vector2(130, 130))
	_contenido.add_child(logo)
	var titulo := Estilo.titulo("SapientIA", 35)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_contenido.add_child(titulo)
	var reciente := Partidas.reciente()
	var continuar := _boton("Continuar", _abrir.bind(reciente))
	continuar.disabled = reciente == 0
	var nueva := _boton("Nueva partida", _espacios.bind(true))
	var cargar := _boton("Cargar partida", _espacios.bind(false))
	_botones_menu([continuar, nueva, cargar, _boton("Opciones", _mostrar_opciones),
		_boton("Cómo jugar", _lectura.bind(false)), _boton("Créditos", _lectura.bind(true)),
		_boton("Salir", confirmar_salida)])
	_contenido.add_child(_status)
	(nueva if continuar.disabled else continuar).grab_focus()

func _botones_menu(botones: Array) -> void:
	for boton in botones:
		boton.theme_type_variation = &"TituloMenu"

func _espacios(nueva: bool) -> void:
	_pagina_base("nueva" if nueva else "cargar", "Nueva partida" if nueva else "Cargar partida", 720)
	var inicial: Button
	var libres := 0
	for id in range(1, Partidas.CAPACIDAD + 1):
		var datos := Partidas.leer(id)
		var existe := Partidas.existe(id)
		var fila := HBoxContainer.new()
		_contenido.add_child(fila)
		var dibujo: Texture2D
		if not datos.is_empty():
			dibujo = Partidas.apariencia(datos).get("vista_previa")
		var imagen := Estilo.textura(dibujo, Vector2(48, 54))
		imagen.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		fila.add_child(imagen)
		var rotulo := "Espacio %d · %s" % [id, "Datos sin recuperar" if existe else "Vacío"]
		if not datos.is_empty():
			rotulo = "Espacio %d · %s\n%s" % [id, Partidas.nombre(datos), Partidas.resumen(datos)]
		var boton := Estilo.boton(rotulo, _crear.bind(id) if nueva else _abrir.bind(id))
		boton.alignment = HORIZONTAL_ALIGNMENT_LEFT
		boton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		boton.disabled = existe if nueva else datos.is_empty()
		fila.add_child(boton)
		if existe:
			fila.add_child(Estilo.boton("Eliminar", _confirmar_eliminar.bind(id, nueva)))
		else:
			libres += 1
		if not boton.disabled and inicial == null:
			inicial = boton
	if nueva and libres == 0:
		_contenido.add_child(Estilo.texto("Los cinco espacios están ocupados. Puedes eliminar una partida o volver."))
	_contenido.add_child(_status)
	var volver := _boton("Volver", _principal)
	(volver if inicial == null else inicial).grab_focus()

func _confirmar_eliminar(id: int, nueva: bool) -> void:
	Estilo.confirmar(self, "¿Eliminar la partida del espacio %d y sus respaldos?" % id, func():
		var eliminada := Partidas.eliminar(id)
		_espacios(nueva)
		_mensaje("Espacio eliminado." if eliminada else "No se pudo eliminar la partida."))

func _crear(id: int) -> void:
	_pagina_base("crear", "Tu protagonista", 635)
	_aspectos = EstadoMundo.apariencias_disponibles()
	if _aspectos.is_empty():
		_contenido.add_child(Estilo.texto("Las apariencias aún no están disponibles."))
		_boton("Volver", _espacios.bind(true)).grab_focus()
		return
	_aspecto = 0
	_direccion = 3
	_caminar = false
	var fila := HBoxContainer.new()
	_contenido.add_child(fila)
	_nombre = LineEdit.new()
	_nombre.placeholder_text = "Nombre"
	_nombre.max_length = EstadoMundo.MAX_NOMBRE
	_nombre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila.add_child(_nombre)
	var teclado := Estilo.boton("Teclado virtual", Teclado.mostrar.bind(_nombre))
	fila.add_child(teclado)
	var campo := Control.new()
	campo.custom_minimum_size.y = 123
	_contenido.add_child(campo)
	_sprite = AnimatedSprite2D.new()
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.scale = Vector2(2.5, 2.5)
	campo.add_child(_sprite)
	campo.resized.connect(func(): _sprite.position = campo.size * 0.5)
	_descripcion_aspecto = Estilo.texto("")
	_contenido.add_child(_descripcion_aspecto)
	var aspectos := HBoxContainer.new()
	_contenido.add_child(aspectos)
	var grupo := ButtonGroup.new()
	for i in _aspectos.size():
		var boton := Estilo.boton("", _cambiar_aspecto.bind(i))
		boton.toggle_mode = true
		boton.button_group = grupo
		boton.button_pressed = i == 0
		boton.icon = _aspectos[i].vista_previa
		boton.add_theme_constant_override("icon_max_width", 34)
		boton.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		boton.tooltip_text = _aspectos[i].nombre
		boton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		aspectos.add_child(boton)
	var animaciones := HBoxContainer.new()
	_contenido.add_child(animaciones)
	for i in 4:
		animaciones.add_child(Estilo.boton(["Izquierda", "Derecha", "Arriba", "Abajo"][i], _girar.bind(i)))
	var caminar := CheckButton.new()
	caminar.text = "Caminar"
	caminar.toggled.connect(func(estado):
		_caminar = estado
		_actualizar_vista())
	animaciones.add_child(caminar)
	_actualizar_vista()
	_contenido.add_child(_status)
	_boton("Comenzar", _nueva.bind(id))
	_boton("Volver", _espacios.bind(true))
	teclado.grab_focus()

func _cambiar_aspecto(indice: int) -> void:
	_aspecto = indice
	_actualizar_vista()

func _girar(indice: int) -> void:
	_direccion = indice
	_actualizar_vista()

func _actualizar_vista() -> void:
	var ficha := _aspectos[_aspecto]
	_descripcion_aspecto.text = ficha.nombre
	_sprite.sprite_frames = ficha.frames
	_sprite.play(("%s_%s" % ["walk" if _caminar else "idle", ["izquierda", "derecha", "arriba", "abajo"][_direccion]]) as StringName)

func _nueva(id: int) -> void:
	if EstadoMundo._validar_nombre(_nombre.text).is_empty():
		_mensaje("Escribe entre 1 y 24 caracteres. Evita barras, corchetes y signos angulares.")
		return
	if not Partidas.crear(id, _nombre.text, _aspectos[_aspecto].id):
		_mensaje("No se pudo crear la partida en este espacio.")
		return
	_intro_id = id
	_intro_paso = 0
	en_intro = true
	_mostrar_intro(false)

func _mostrar_intro(fundir: bool) -> void:
	var llegada: SpriteFrames = _aspectos[_aspecto].frames if _intro_paso == 3 else null
	if fundir:
		await _fondo_fundido(SECUENCIA[_intro_paso], llegada)
	else:
		_vista.mostrar(SECUENCIA[_intro_paso], llegada)
	_reloj_fondo = 0.0
	_pagina_base("intro", "", 720)
	_marco.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_marco.offset_top = -160.0
	_marco.offset_bottom = -18.0
	_contenido.add_child(Estilo.titulo("Un nuevo comienzo" if _intro_paso == 0 else Regiones.nombre(SECUENCIA[_intro_paso]), 23))
	_contenido.add_child(Estilo.texto(RELATO[_intro_paso]))
	if _intro_paso == SECUENCIA.size() - 1:
		_contenido.add_child(Estilo.texto("Bruno te espera en la Aldea. Tu casa está al noroeste de la plaza. Allí puedes guardar tus cosas y dormir hasta la mañana siguiente."))
	_boton("Omitir introducción · Esc / B", _terminar_intro).grab_focus()

func _terminar_intro() -> void:
	if _saliendo or not en_intro:
		return
	_saliendo = true
	_abrir(_intro_id)
	if not Partidas.ocupado:
		en_intro = false
		_saliendo = false
		_espacios(false)
		_mensaje("No se pudo iniciar la partida.")

func _fondo_fundido(id: String, llegada: SpriteFrames = null) -> void:
	var introduccion := en_intro
	_fundiendo = true
	_reloj_fondo = 0.0
	var entrada := create_tween()
	entrada.tween_property(_oscuro, "color:a", 1.0, 0.5)
	await entrada.finished
	if not _saliendo and introduccion == en_intro:
		_vista.mostrar(id, llegada)
	var salida := create_tween()
	salida.tween_property(_oscuro, "color:a", 0.0, 0.6)
	await salida.finished
	_fundiendo = false

func _abrir(id: int) -> void:
	if not Partidas.abrir(id):
		AudioJuego.sonido_interfaz("error")
		_mensaje("No se pudo abrir esta partida.")

func _mostrar_opciones() -> void:
	_marco.hide()
	_opciones = Opciones.new()
	add_child(_opciones)
	_opciones.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_opciones.offset_left = 30
	_opciones.offset_right = -30
	_opciones.offset_top = 24
	_opciones.offset_bottom = -24
	_opciones.cerrado.connect(_principal)

func _lectura(creditos: bool) -> void:
	_pagina_base("creditos" if creditos else "ayuda", "Créditos de SapientIA" if creditos else "Cómo jugar", 710)
	if creditos:
		_contenido.add_child(Estilo.textura(LOGOTIPO, Vector2(80, 80)))
	_contenido.add_child(Estilo.texto(CREDITOS if creditos else AYUDA))
	_boton("Volver", _principal).grab_focus()

func confirmar_salida() -> void:
	Estilo.confirmar(self, "¿Salir de SapientIA?", AudioJuego.salir_del_juego)

func _mensaje(mensaje: String) -> void:
	_status.text = mensaje
	_status.show()
