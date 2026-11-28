extends Node

const ARCHIVO := "user://opciones.cfg"
const ACCIONES := {
	"mover_arriba": "Mover: arriba", "mover_abajo": "Mover: abajo",
	"mover_izquierda": "Mover: izquierda", "mover_derecha": "Mover: derecha",
	"girar_camara_izquierda": "Girar cámara: izquierda", "girar_camara_derecha": "Girar cámara: derecha",
	"interactuar": "Interactuar", "comerciar_npc": "Comercio",
	"abrir_inventario": "Inventario", "abrir_diario": "Diario",
	"abrir_mapa_mundo": "Mapa", "pausar_juego": "Pausa",
	"ranura_anterior": "Barra rápida: anterior", "ranura_siguiente": "Barra rápida: siguiente",
	"ranura_usar": "Barra rápida: usar",
}
const BUS := ["Master", "Música", "Ambiente", "Efectos", "Interfaz"]
const VELOCIDADES := {"tranquila": 4.0, "normal": 6.0, "rapida": 8.0}
const RESOLUCIONES := [Vector2i(960, 600), Vector2i(1152, 720), Vector2i(1280, 800), Vector2i(1600, 900), Vector2i(1920, 1080)]
const BASE := {
	"modo": 0, "resolucion": Vector2i(1152, 720), "calidad": 1, "sombras": 1,
	"vsync": true, "fps": 60, "escala": 1.0, "texto": 20, "contraste": false,
	"dialogo": 1.0, "instantaneo": false, "movimiento": false, "barra": true,
	"velocidad": "normal",
	"camara": 1.0, "invertir": false, "volumen": [1.0, 0.35, 0.55, 0.65, 0.4], "silencio": false,
}
var valores := BASE.duplicate(true)
var controles: Dictionary = {}
var predeterminados: Dictionary = {}
var mando := false
var reducir_movimiento: bool:
	get: return valores.movimiento
signal dispositivo_cambiado
signal cambiado

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_accion("abrir_mapa_mundo", KEY_M, JOY_BUTTON_BACK)
	var diario := InputEventJoypadButton.new()
	diario.device = -1
	diario.button_index = JOY_BUTTON_LEFT_STICK
	InputMap.action_add_event("abrir_diario", diario)
	_accion("pausar_juego", KEY_ESCAPE, JOY_BUTTON_START)
	_accion("ranura_anterior", KEY_BRACKETLEFT, JOY_BUTTON_LEFT_SHOULDER)
	_accion("ranura_siguiente", KEY_BRACKETRIGHT, JOY_BUTTON_RIGHT_SHOULDER)
	_accion("ranura_usar", KEY_R, JOY_BUTTON_RIGHT_STICK)
	for accion in ACCIONES:
		if InputMap.has_action(accion):
			var eventos := InputMap.action_get_events(accion)
			for evento in eventos:
				if evento is InputEventJoypadButton:
					evento.device = -1
			predeterminados[accion] = eventos
	for nombre in BUS:
		if AudioServer.get_bus_index(nombre) == -1:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, nombre)
	if get_tree().get_script() == null:
		cargar_configuracion()
		aplicar_pantalla()
		get_tree().auto_accept_quit = false
	_aplicar_controles()
	aplicar()

func _accion(nombre: String, codigo: Key, boton: JoyButton) -> void:
	if InputMap.has_action(nombre):
		return
	InputMap.add_action(nombre)
	var tecla := InputEventKey.new()
	tecla.physical_keycode = codigo
	InputMap.action_add_event(nombre, tecla)
	var evento := InputEventJoypadButton.new()
	evento.device = -1
	evento.button_index = boton
	InputMap.action_add_event(nombre, evento)

func _input(evento: InputEvent) -> void:
	var nuevo := mando
	if evento is InputEventJoypadButton or (evento is InputEventJoypadMotion and absf(evento.axis_value) > 0.6):
		nuevo = true
	elif evento is InputEventKey or evento is InputEventMouseButton:
		nuevo = false
	if mando != nuevo:
		mando = nuevo
		dispositivo_cambiado.emit()

func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_CLOSE_REQUEST and get_tree().get_script() == null:
		var escena := get_tree().current_scene
		if is_instance_valid(escena) and escena.has_method("confirmar_salida"):
			escena.confirmar_salida()
		elif not get_tree().paused and not GestorRegiones.en_transicion:
			MenuPausa.abrir()
			MenuPausa._confirmar_salida(false)

func aplicar_pantalla() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var ventana := get_tree().root
	ventana.mode = Window.MODE_FULLSCREEN if valores.modo == 1 else Window.MODE_WINDOWED
	ventana.borderless = valores.modo == 2
	if valores.modo != 1:
		ventana.size = (valores.resolucion as Vector2i).min(DisplayServer.screen_get_usable_rect().size)
		ventana.move_to_center()

func aplicar() -> void:
	var ventana := get_tree().root
	ventana.content_scale_factor = clampf(valores.escala, 0.8, 1.3)
	ventana.msaa_3d = [Viewport.MSAA_DISABLED, Viewport.MSAA_2X, Viewport.MSAA_4X][clampi(valores.calidad, 0, 2)]
	ventana.positional_shadow_atlas_size = [1024, 2048, 4096][clampi(valores.sombras, 0, 2)]
	RenderingServer.directional_shadow_atlas_set_size([1024, 2048, 4096][clampi(valores.sombras, 0, 2)], true)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if valores.vsync else DisplayServer.VSYNC_DISABLED)
	if get_tree().get_script() == null or DisplayServer.get_name() != "headless":
		Engine.max_fps = clampi(valores.fps, 0, 240)
	for i in BUS.size():
		var indice := AudioServer.get_bus_index(BUS[i])
		var nivel := clampf(valores.volumen[i] if valores.volumen.size() == BUS.size() else BASE.volumen[i], 0, 1)
		AudioServer.set_bus_volume_db(indice, linear_to_db(maxf(0.0001, nivel)))
		AudioServer.set_bus_mute(indice, nivel <= 0 or (i == 0 and valores.silencio))
	var tema := load("res://scenes/presentacion/sapientia.tres") as Theme
	tema.default_font_size = clampi(valores.texto, 16, 28)
	var color_texto := Color.WHITE if valores.contraste else Color("#f4e6c9")
	for tipo in ["Label", "Button", "LineEdit", "OptionButton", "CheckButton", "CheckBox"]:
		tema.set_color("font_color", tipo, color_texto)
	tema.set_color("default_color", "RichTextLabel", color_texto)
	for estado in ["normal", "hover", "pressed"]:
		var estilo := tema.get_stylebox(estado, "Button") as StyleBoxFlat
		if not estilo.has_meta("color_original"):
			estilo.set_meta("color_original", estilo.bg_color)
		estilo.bg_color = Color("#291e13") if valores.contraste else estilo.get_meta("color_original")
	var panel := tema.get_stylebox("panel", "PanelContainer") as StyleBoxFlat
	panel.bg_color = Color("#15100c") if valores.contraste else Color("#382d23")
	cambiado.emit()

func cargar_configuracion(ruta: String = ARCHIVO) -> void:
	var cfg := ConfigFile.new()
	if cfg.load(ruta) == OK:
		for id in BASE:
			var valor: Variant = cfg.get_value("juego", id, BASE[id])
			if typeof(valor) == typeof(BASE[id]):
				valores[id] = valor
		if not VELOCIDADES.has(valores.velocidad):
			valores.velocidad = BASE.velocidad
		for accion in predeterminados:
			var eventos: Variant = cfg.get_value("controles", accion, [])
			if eventos is Array and eventos.size() > 0:
				controles[accion] = eventos

func guardar(ruta: String = ARCHIVO) -> void:
	if get_tree().get_script() != null and ruta == ARCHIVO:
		return
	var cfg := ConfigFile.new()
	for id in valores:
		cfg.set_value("juego", id, valores[id])
	for accion in controles:
		cfg.set_value("controles", accion, controles[accion])
	cfg.save(ruta)

func restaurar() -> void:
	valores = BASE.duplicate(true)
	controles.clear()
	_aplicar_controles()
	aplicar_pantalla()
	aplicar()
	guardar()

func reasignar(accion: String, evento: InputEvent) -> String:
	if not predeterminados.has(accion):
		return "Acción desconocida."
	for otra in predeterminados:
		if otra != accion and InputMap.action_get_events(otra).any(func(asignado): return asignado.is_match(evento, true)):
			return "Ya se usa para «%s»." % ACCIONES[otra]
	var eventos := InputMap.action_get_events(accion).filter(func(anterior):
		return anterior.get_class() != evento.get_class())
	eventos.append(evento)
	controles[accion] = eventos
	_aplicar_controles()
	guardar()
	cambiado.emit()
	return ""

func _aplicar_controles() -> void:
	for accion in predeterminados:
		InputMap.action_erase_events(accion)
		for evento in controles.get(accion, predeterminados[accion]):
			if evento is InputEvent:
				InputMap.action_add_event(accion, evento)

func indicacion(accion: String) -> String:
	for evento in InputMap.action_get_events(accion):
		if (mando and (evento is InputEventJoypadButton or evento is InputEventJoypadMotion)) or (not mando and evento is InputEventKey):
			return nombre_entrada(evento)
	return "—"

func nombre_entrada(evento: InputEvent) -> String:
	if evento is InputEventJoypadButton:
		var botones := ["A", "B", "X", "Y", "Ver", "Guía", "Menú", "Stick izq.", "Stick der.", "LB", "RB", "↑", "↓", "←", "→"]
		return botones[evento.button_index] if evento.button_index >= 0 and evento.button_index < botones.size() else "Botón %d" % (evento.button_index + 1)
	if evento is InputEventJoypadMotion:
		match evento.axis:
			JOY_AXIS_TRIGGER_LEFT: return "LT"
			JOY_AXIS_TRIGGER_RIGHT: return "RT"
			JOY_AXIS_LEFT_X, JOY_AXIS_RIGHT_X:
				return ("Stick izq." if evento.axis == JOY_AXIS_LEFT_X else "Stick der.") + (" ←" if evento.axis_value < 0 else " →")
			JOY_AXIS_LEFT_Y, JOY_AXIS_RIGHT_Y:
				return ("Stick izq." if evento.axis == JOY_AXIS_LEFT_Y else "Stick der.") + (" ↑" if evento.axis_value < 0 else " ↓")
	if evento is InputEventKey:
		var codigo: Key = evento.keycode
		if evento.physical_keycode:
			codigo = evento.physical_keycode
			if DisplayServer.get_name() != "headless":
				var localizado := DisplayServer.keyboard_get_keycode_from_physical(codigo)
				if localizado != KEY_NONE:
					codigo = localizado
		match codigo:
			KEY_BRACKETLEFT: return "["
			KEY_BRACKETRIGHT: return "]"
			KEY_ESCAPE: return "Esc"
			KEY_SPACE: return "Espacio"
			KEY_ENTER: return "Intro"
			KEY_BACKSPACE: return "Retroceso"
			KEY_UP: return "↑"
			KEY_DOWN: return "↓"
			KEY_LEFT: return "←"
			KEY_RIGHT: return "→"
		return OS.get_keycode_string(codigo)
	return "—"
