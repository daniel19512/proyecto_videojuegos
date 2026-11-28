extends CanvasLayer

const Estilo = preload("res://scripts/presentacion/estilo.gd")
const Regiones = preload("res://scripts/presentacion/regiones.gd")
const Hallazgos = preload("res://scripts/vida/descubrimientos.gd")

var abierto := false
var _previa := false
var _fondo: ColorRect
var _detalle: Label
var _imagen: TextureRect
var _foco_anterior: Control

func _ready() -> void:
	layer = 50
	process_mode = PROCESS_MODE_ALWAYS

func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_echo():
		return
	if abierto and (evento.is_action_pressed("ui_cancel") or evento.is_action_pressed("abrir_mapa_mundo")):
		cerrar()
	elif not get_tree().paused and not GestorRegiones.en_transicion and evento.is_action_pressed("abrir_mapa_mundo") and GestorRegiones.region_actual != &"":
		abrir()
	else:
		return
	get_viewport().set_input_as_handled()

func abrir() -> void:
	if abierto or GestorRegiones.en_transicion:
		return
	AudioJuego.sonido_interfaz("abrir")
	abierto = true
	_previa = get_tree().paused
	_foco_anterior = get_viewport().gui_get_focus_owner()
	get_tree().paused = true
	_fondo = ColorRect.new()
	_fondo.color = Color(0.1, 0.07, 0.04, 0.8)
	add_child(_fondo)
	_fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var centro := CenterContainer.new()
	_fondo.add_child(centro)
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var papel := PanelContainer.new()
	papel.theme_type_variation = &"Pergamino"
	centro.add_child(papel)
	var pila := VBoxContainer.new()
	pila.custom_minimum_size.x = minf(680, get_viewport().get_visible_rect().size.x - 48)
	papel.add_child(pila)
	var titulo := Estilo.titulo("Mapa de SapientIA")
	titulo.theme_type_variation = &"TituloTinta"
	pila.add_child(titulo)
	var actual := String(GestorRegiones.region_actual)
	if not Regiones.DATOS.has(actual):
		actual = "Aldea"
	var regla := Estilo.texto("Las líneas indican los caminos entre regiones.")
	regla.theme_type_variation = &"Tinta"
	pila.add_child(regla)
	var mapa := Control.new()
	mapa.custom_minimum_size.y = 155
	pila.add_child(mapa)
	var posiciones := {
		"Ruinas": Vector2(0.16, 0.18), "Bosque": Vector2(0.38, 0.18),
		"Aldea": Vector2(0.46, 0.52), "CamposYGranjas": Vector2(0.34, 0.85),
		"Montanas": Vector2(0.73, 0.52), "Minas": Vector2(0.87, 0.18)}
	var botones: Dictionary = {}
	for id in posiciones:
		var marca := " · Aquí" if id == actual else ""
		var boton := Estilo.boton(Regiones.nombre(id) + marca, _mostrar.bind(id, actual))
		boton.focus_entered.connect(_mostrar.bind(id, actual))
		mapa.add_child(boton)
		botones[id] = boton
	mapa.resized.connect(func():
		for id in posiciones:
			var boton: Button = botones[id]
			boton.position = mapa.size * posiciones[id] - boton.size * 0.5
		mapa.queue_redraw())
	mapa.draw.connect(func():
		for conexion in Regiones.RUTAS:
			mapa.draw_line(mapa.size * posiciones[conexion[0]], mapa.size * posiciones[conexion[1]], Color("#795937"), 3.0, true))
	var detalle := HBoxContainer.new()
	pila.add_child(detalle)
	_imagen = Estilo.textura(null, Vector2(205, 118))
	_imagen.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	detalle.add_child(_imagen)
	_detalle = Estilo.texto("")
	_detalle.theme_type_variation = &"Tinta"
	_detalle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detalle.add_child(_detalle)
	pila.add_child(Estilo.boton("Cerrar mapa", cerrar))
	(botones[actual] as Button).grab_focus()
	_mostrar(actual, actual)

func _mostrar(id: String, actual: String) -> void:
	var actividad: Dictionary = EstadoMundo.datos.zonas.get("@actividades", {}).get("visitar", {})
	var descubierto := actividad.has(id) or id == actual or id == "Aldea"
	_imagen.texture = Regiones.imagen(id) if descubierto else null
	if not descubierto:
		_detalle.text = Regiones.nombre(id) + "\nPor descubrir"
		return
	var partes := PackedStringArray([Regiones.nombre(id) + (" · Región actual" if id == actual else " · Descubierta"), Regiones.DATOS[id][3]])
	if id == "Aldea":
		partes.append("Casa de %s · Casa 1, al noroeste de la plaza" % EstadoMundo.nombre_protagonista())
	for hallazgo in Hallazgos.PUNTOS:
		if Hallazgos.PUNTOS[hallazgo].region == id and EstadoMundo.datos.zonas.get("@descubrimientos", {}).get(hallazgo, {}).get("descubierto", false):
			partes.append(Hallazgos.PUNTOS[hallazgo].titulo)
	var mision := Misiones.ficha(Misiones.seguida())
	var destino: bool = mision.get("region", "") == id
	for objetivo in mision.get("objetivos", []):
		if objetivo.size() >= 2 and objetivo[0] == "visitar" and objetivo[1] == id:
			destino = true
			break
	if destino:
		partes.append("Destino de la misión seguida")
	_detalle.text = "\n".join(partes)

func cerrar() -> void:
	if not abierto:
		return
	abierto = false
	_fondo.hide()
	_fondo.queue_free()
	get_tree().paused = _previa
	if is_instance_valid(_foco_anterior):
		_foco_anterior.grab_focus()
