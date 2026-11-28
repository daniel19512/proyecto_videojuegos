extends CanvasLayer
## Autoload `DialogoIA`: conversación con un NPC controlada por el modelo.
## Muestra la respuesta, 2-3 opciones y «Escribir otra cosa…» para texto libre.
## Quien la abre pausa el árbol y la quita al terminar `conversar()`, que
## devuelve false si la primera respuesta falla (el NPC usa entonces lo fijo).
## Cada turno guarda el recuerdo y el hecho que propone el modelo.

signal cerrado(exito: bool)
signal turno_listo

const Teclado = preload("res://scripts/presentacion/teclado_virtual.gd")
const Estilo = preload("res://scripts/presentacion/estilo.gd")
const TEXTO_ESCRIBIR := "Escribir otra cosa…"
const TEXTO_DESPEDIRSE := "Despedirse"
const APERTURA := "(El viajero se acerca a hablar contigo.)"

var abierta: bool = false
var esperando: bool = false
var id_npc: StringName = &""
var turnos: Array = []
var respuesta_actual: String = ""
var opciones_actuales: PackedStringArray = []
var terminada: bool = false
var cancelada := false
var _solicitud := 0

var _exito: bool = false
var _fotograma_apertura: int = -1
var _nombre: Label
var _texto: Label
var _opciones: VBoxContainer
var _entrada: LineEdit
var _ayuda: Label
var _fila_entrada: HBoxContainer
var _retrato: TextureRect
var _trato: Label


func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_construir()


## Abre la conversación y espera a que se cierre.
func conversar(id: StringName, nombre: String) -> bool:
	id_npc = id
	turnos.clear()
	terminada = false
	_exito = false
	cancelada = false
	_nombre.text = nombre
	var npc: Node = Aldeanos.nodos.get(id)
	_retrato.texture = npc.frames.get_frame_texture(&"idle_abajo", 0) if is_instance_valid(npc) and npc.frames else null
	var trato := Misiones.relacion(String(id))
	_trato.text = "Amistad %d · Confianza %d" % [trato.amistad, trato.confianza]
	_fotograma_apertura = Engine.get_process_frames()
	abierta = true
	visible = true
	_pedir(APERTURA, true)
	var exito: bool = await cerrado
	return exito


func cerrar() -> void:
	if not abierta:
		return
	abierta = false
	_solicitud += 1
	esperando = false
	visible = false
	_entrada.release_focus()
	cerrado.emit(_exito)


## Elige una de las opciones visibles (también lo usan las pruebas).
func elegir(texto: String) -> void:
	if esperando or not abierta:
		return
	if texto == TEXTO_DESPEDIRSE:
		cerrar()
	elif texto == TEXTO_ESCRIBIR:
		_mostrar_entrada()
	else:
		_pedir(texto, false)


func _process(_delta: float) -> void:
	if not abierta or Engine.get_process_frames() == _fotograma_apertura or _entrada.get_child_count() > 0:
		return
	if Input.is_action_just_pressed("ui_cancel"):
		if _fila_entrada.visible:
			_fila_entrada.visible = false
			_enfocar_primera()
		else:
			cancelada = true
			cerrar()
		return
	# Los botones reciben ui_accept por el foco. F conserva la confirmación adicional.
	if not _entrada.has_focus() and Input.is_action_just_pressed("interactuar") and not Input.is_action_just_pressed("ui_accept"):
		var foco := get_viewport().gui_get_focus_owner()
		if foco is Button and foco.get_parent() == _opciones:
			foco.pressed.emit()


func _pedir(texto_jugador: String, inicial: bool) -> void:
	_solicitud += 1
	var solicitud := _solicitud
	esperando = true
	_fila_entrada.visible = false
	_limpiar_opciones()
	_texto.text = "…"
	_ayuda.text = "Pensando…"
	var mensaje := texto_jugador if inicial else EstadoMundo.nombre_protagonista() + ": " + texto_jugador.left(PromptsIA.LARGO_TEXTO_JUGADOR)
	var contexto := Historia.contexto(id_npc)
	contexto.protagonista = EstadoMundo.nombre_protagonista()
	contexto.ahora = Aldeanos.descripcion(id_npc)
	contexto.trato = Misiones.relacion(String(id_npc))
	contexto.logros = EstadoMundo.datos.zonas.get("@social", {}).get("recuerdos", {}).get(String(id_npc), []).slice(-3)
	contexto.feria = EstadoMundo.datos.zonas.get("@social", {}).get("feria", {}).get("terminada", false)
	var mensajes := PromptsIA.mensajes_conversacion(contexto, turnos, mensaje)
	turnos.append({quien = "jugador", texto = mensaje})
	var resultado: Dictionary = await IA.solicitar(mensajes, "conversacion", PromptsIA.esquema_conversacion(), PromptsIA.MAX_TOKENS_CONVERSACION)
	if solicitud != _solicitud:
		return
	esperando = false
	if not abierta:
		return
	if not resultado.ok:
		if inicial:
			cerrar()
			return
		_mostrar("(Se queda pensativo y vuelve a lo suyo.)", PackedStringArray(), true)
		return
	_exito = true
	var datos: Dictionary = resultado.datos
	var respuesta := str(datos.get("respuesta", "")).strip_edges()
	turnos.append({quien = "npc", texto = respuesta})
	Historia.recordar(id_npc, str(datos.get("recuerdo", "")))
	var nombre: String = Historia.premisa.npcs[String(id_npc)].nombre
	var evento := str(datos.get("evento", "")).strip_edges()
	if not evento.is_empty():
		Historia.registrar_hecho("%s: %s" % [nombre, evento], bool(datos.get("importante", false)))
	var opciones := PackedStringArray()
	for opcion in datos.get("opciones", []):
		var limpia := str(opcion).strip_edges()
		if not limpia.is_empty() and opciones.size() < 3:
			opciones.append(limpia.left(80))
	var consulta := Misiones.consulta_dialogo(String(id_npc), datos.get("consulta"))
	if not consulta.is_empty():
		respuesta += "\n" + consulta
	_mostrar(respuesta, opciones, bool(datos.get("terminar", false)))


func _mostrar(respuesta: String, opciones: PackedStringArray, fin: bool) -> void:
	respuesta_actual = respuesta
	terminada = fin
	_texto.text = respuesta
	_limpiar_opciones()
	opciones_actuales = PackedStringArray()
	if not fin:
		opciones_actuales.append_array(opciones)
		opciones_actuales.append(TEXTO_ESCRIBIR)
	opciones_actuales.append(TEXTO_DESPEDIRSE)
	for opcion in opciones_actuales:
		var boton := Button.new()
		boton.text = opcion
		boton.alignment = HORIZONTAL_ALIGNMENT_LEFT
		boton.pressed.connect(elegir.bind(opcion))
		_opciones.add_child(boton)
	_ayuda.text = "Flechas / mando: elegir   ·   F / Enter / A: aceptar   ·   Esc / B: salir"
	_enfocar_primera()
	turno_listo.emit()


func _mostrar_entrada() -> void:
	_entrada.text = ""
	_fila_entrada.visible = true
	if Ajustes.mando:
		_fila_entrada.get_child(1).grab_focus()
		Teclado.mostrar(_entrada)
	else:
		_entrada.grab_focus()
	_ayuda.text = "Teclado virtual o entrada directa · Enviar confirma"


func _al_enviar_texto(texto: String) -> void:
	texto = texto.strip_edges()
	if texto.is_empty() or esperando:
		return
	_entrada.release_focus()
	_pedir(texto, false)


func _limpiar_opciones() -> void:
	for hijo in _opciones.get_children():
		_opciones.remove_child(hijo)
		hijo.queue_free()


func _enfocar_primera() -> void:
	if _opciones.get_child_count() > 0:
		(_opciones.get_child(0) as Button).grab_focus()


func _construir() -> void:
	var marco := PanelContainer.new()
	marco.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	marco.offset_left = 90
	marco.offset_right = -90
	marco.offset_top = -390
	marco.offset_bottom = -24
	add_child(marco)
	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 8)
	var scroll := ScrollContainer.new()
	scroll.follow_focus = true
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	marco.add_child(scroll)
	columna.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(columna)
	_nombre = Label.new()
	_nombre.add_theme_font_size_override("font_size", 22)
	_nombre.add_theme_color_override("font_color", Color(0.98, 0.85, 0.5))
	var cabecera := HBoxContainer.new()
	columna.add_child(cabecera)
	_retrato = Estilo.textura(null, Vector2(50, 58))
	_retrato.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	cabecera.add_child(_retrato)
	var datos := VBoxContainer.new()
	cabecera.add_child(datos)
	_nombre.theme_type_variation = &"Titulo"
	datos.add_child(_nombre)
	_trato = Label.new()
	datos.add_child(_trato)
	_texto = Label.new()
	_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_texto.custom_minimum_size = Vector2(0, 60)
	columna.add_child(_texto)
	_opciones = VBoxContainer.new()
	columna.add_child(_opciones)
	_entrada = LineEdit.new()
	_entrada.placeholder_text = "Escribe lo que quieres decir…"
	_entrada.max_length = PromptsIA.LARGO_TEXTO_JUGADOR
	_entrada.text_submitted.connect(_al_enviar_texto)
	_fila_entrada = HBoxContainer.new()
	columna.add_child(_fila_entrada)
	_entrada.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_fila_entrada.add_child(_entrada)
	_fila_entrada.add_child(Estilo.boton("Teclado", Teclado.mostrar.bind(_entrada)))
	_fila_entrada.add_child(Estilo.boton("Enviar", func(): _al_enviar_texto(_entrada.text)))
	_fila_entrada.hide()
	_ayuda = Label.new()
	_ayuda.add_theme_font_size_override("font_size", 14)
	_ayuda.add_theme_color_override("font_color", Color(0.85, 0.78, 0.6))
	columna.add_child(_ayuda)
