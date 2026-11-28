class_name MinijuegoBase
extends CanvasLayer
## Panel común de minijuegos de oficio: instrucciones, partida y resultado,
## marcador, Esc para salir y textos flotantes de puntos. Funciona con el árbol
## en pausa (process_mode ALWAYS); quien lo abre decide pausar o no.
## Cada minijuego aporta su lógica pura (RefCounted con `puntuacion`,
## `tiempo_restante`, `ultimos_eventos` y `terminada()`) y su dibujo.

signal cerrado
## Se emite al agotarse el tiempo de cada partida.
signal partida_terminada(puntuacion: int)

enum Estado { CERRADO, INSTRUCCIONES, JUGANDO, RESULTADO }

const COLOR_SUMA := Color(0.55, 1.0, 0.45)
const COLOR_RESTA := Color(1.0, 0.42, 0.36)
const COLOR_TEXTO := Color(0.98, 0.94, 0.82)
const VIDA_TEXTO: float = 0.8
const AUDIO_INTERFAZ := "res://assets/audio/kenney_interface_sounds/"
const AUDIO_IMPACTO := "res://assets/audio/kenney_impact_sounds/"
const AUDIO_RPG := "res://assets/audio/kenney_rpg_audio/"

var estado: Estado = Estado.CERRADO
var logica: RefCounted
## Semilla fija opcional para pruebas; -1 genera partidas distintas.
var semilla: int = -1

var _textos: Array[Dictionary] = []
var _tiempo_visual: float = 0.0
var _fotograma_apertura: int = -1
var sonido: ReproductorSonidos
var _resultado_oficio := false
var _confirmacion_raton := false

@onready var _area: Control = $Marco/AreaJuego
@onready var _puntos: Label = $Marco/Puntos
@onready var _tiempo: Label = $Marco/Tiempo
@onready var _mensaje: Label = $Marco/AreaJuego/Mensaje


func _ready() -> void:
	visible = false
	var tema := load("res://scenes/presentacion/sapientia.tres") as Theme
	$Marco.add_theme_stylebox_override("panel", tema.get_stylebox("panel", "PanelContainer"))
	var titulo := $Marco.get_node_or_null("Titulo") as Label
	if titulo:
		titulo.theme_type_variation = &"Titulo"
	_area.draw.connect(_dibujar_area)
	_mensaje.mouse_filter = Control.MOUSE_FILTER_STOP
	_mensaje.gui_input.connect(_confirmar_con_raton)
	sonido = ReproductorSonidos.new()
	sonido.name = "Sonido"
	sonido.sonidos = sonidos_comunes()
	sonido.sonidos.merge(_sonidos(), true)
	add_child(sonido)


func abrir() -> void:
	_resultado_oficio = false
	_confirmacion_raton = false
	logica = _crear_logica()
	_textos.clear()
	_fotograma_apertura = Engine.get_process_frames()
	visible = true
	sonido.reproducir(&"abrir")
	_cambiar_estado(Estado.INSTRUCCIONES)


func cerrar() -> void:
	if estado == Estado.CERRADO:
		return
	visible = false
	estado = Estado.CERRADO
	sonido.reproducir(&"cerrar")
	cerrado.emit()


func _process(delta: float) -> void:
	if estado == Estado.CERRADO:
		return
	_tiempo_visual += delta
	# La pulsación que abrió el panel no debe iniciar la partida en el mismo fotograma.
	var nueva_pulsacion: bool = Engine.get_process_frames() != _fotograma_apertura
	if nueva_pulsacion and Input.is_action_just_pressed("ui_cancel"):
		cerrar()
		return
	var confirmar: bool = nueva_pulsacion and (
		Input.is_action_just_pressed("interactuar") or Input.is_action_just_pressed("ui_accept") or _confirmacion_raton
	)
	_confirmacion_raton = false
	match estado:
		Estado.INSTRUCCIONES, Estado.RESULTADO:
			if confirmar and _resultado_oficio:
				cerrar()
				return
			if confirmar:
				logica = _crear_logica()
				_textos.clear()
				_cambiar_estado(Estado.JUGANDO)
		Estado.JUGANDO:
			_jugar(delta)
			for evento in logica.ultimos_eventos:
				sonido.reproducir(evento.get("tipo", &""))
				if evento.puntos != 0:
					_textos.append({puntos = evento.puntos, pos = evento.pos, vida = VIDA_TEXTO})
			if logica.terminada():
				_cambiar_estado(Estado.RESULTADO)
				partida_terminada.emit(logica.puntuacion)
	_actualizar_textos(delta)
	_actualizar_marcador()
	_area.queue_redraw()


func _cambiar_estado(nuevo: Estado) -> void:
	estado = nuevo
	match estado:
		Estado.INSTRUCCIONES:
			_mensaje.text = _texto_instrucciones() + "\n\n[F/A/Clic] Empezar     [Esc/B] Salir"
		Estado.JUGANDO:
			_mensaje.text = ""
			sonido.reproducir(&"empezar")
		Estado.RESULTADO:
			sonido.reproducir(&"fin")
			_mensaje.text = "¡Tiempo!\n\nPuntuación: %d\n%s\n\n[F] Otra vez     [Esc] Salir" % [logica.puntuacion, _texto_resultado()]
	_mensaje.visible = not _mensaje.text.is_empty()
	_actualizar_marcador()
	_area.queue_redraw()


func _actualizar_marcador() -> void:
	_puntos.text = "Puntos: %d" % logica.puntuacion
	_tiempo.text = "Tiempo: %d" % ceili(logica.tiempo_restante)


func _actualizar_textos(delta: float) -> void:
	for texto in _textos.duplicate():
		texto.vida -= delta
		texto.pos = texto.pos + Vector2(0.0, -30.0 * delta)
		if texto.vida <= 0.0:
			_textos.erase(texto)


func _dibujar_area() -> void:
	if logica == null:
		return
	_dibujar()
	var fuente: Font = _mensaje.get_theme_default_font()
	for texto in _textos:
		var valor: int = texto.puntos
		var cadena: String = ("+%d" if valor > 0 else "%d") % valor
		var color: Color = COLOR_SUMA if valor > 0 else COLOR_RESTA
		color.a = clampf(texto.vida / VIDA_TEXTO, 0.0, 1.0)
		escribir(texto.pos - Vector2(12, 0), cadena, 16, color)


## Texto con contorno sobre el área de juego.
func escribir(pos: Vector2, cadena: String, tamano: int, color: Color, ancho: float = -1, alineacion := HORIZONTAL_ALIGNMENT_LEFT) -> void:
	var fuente: Font = _mensaje.get_theme_default_font()
	_area.draw_string_outline(fuente, pos, cadena, alineacion, ancho, tamano, 4, Color(0, 0, 0, color.a))
	_area.draw_string(fuente, pos, cadena, alineacion, ancho, tamano, color)


## Sonidos de interfaz compartidos por todos los paneles (Kenney, CC0).
static func sonidos_comunes() -> Dictionary:
	return {
		&"abrir": [AUDIO_INTERFAZ + "open_001.ogg"],
		&"empezar": [AUDIO_INTERFAZ + "confirmation_001.ogg"],
		&"fin": [AUDIO_INTERFAZ + "bong_001.ogg"],
		&"cerrar": [AUDIO_INTERFAZ + "close_001.ogg"],
	}


## Rutas `prefijo + nombre + ".ogg"` para varias variantes de un sonido.
static func variantes(prefijo: String, nombres: Array) -> Array:
	return nombres.map(func(n): return prefijo + n + ".ogg")


# --- Métodos que cada minijuego sobrescribe ---------------------------------

## Sonidos propios: tipo de evento de la lógica -> rutas de audio.
func _sonidos() -> Dictionary:
	return {}


func _crear_logica() -> RefCounted:
	return null


## Avanza la partida leyendo la entrada que necesite el minijuego.
func _jugar(_delta: float) -> void:
	pass


func _texto_instrucciones() -> String:
	return ""


func _texto_resultado() -> String:
	return ""


func _dibujar() -> void:
	pass

func _confirmar_con_raton(evento: InputEvent) -> void:
	if evento is InputEventMouseButton and evento.pressed and evento.button_index == MOUSE_BUTTON_LEFT:
		_confirmacion_raton = true


func mostrar_resultado_oficio(mensaje: String) -> void:
	_resultado_oficio = true
	var resumen := _texto_resultado()
	if not resumen.is_empty():
		resumen += "\n"
	_mensaje.text = "Puntuación: %d\n%s\n%s\n\n[F/A/Clic] Continuar    [Esc/B] Salir" % [
		logica.puntuacion, resumen, mensaje]