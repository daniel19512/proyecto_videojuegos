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

var estado: Estado = Estado.CERRADO
var logica: RefCounted
## Semilla fija opcional para pruebas; -1 genera partidas distintas.
var semilla: int = -1

var _textos: Array[Dictionary] = []
var _tiempo_visual: float = 0.0
var _fotograma_apertura: int = -1

@onready var _area: Control = $Marco/AreaJuego
@onready var _puntos: Label = $Marco/Puntos
@onready var _tiempo: Label = $Marco/Tiempo
@onready var _mensaje: Label = $Marco/AreaJuego/Mensaje


func _ready() -> void:
	visible = false
	_area.draw.connect(_dibujar_area)


func abrir() -> void:
	logica = _crear_logica()
	_textos.clear()
	_fotograma_apertura = Engine.get_process_frames()
	visible = true
	_cambiar_estado(Estado.INSTRUCCIONES)


func cerrar() -> void:
	if estado == Estado.CERRADO:
		return
	visible = false
	estado = Estado.CERRADO
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
		Input.is_action_just_pressed("interactuar") or Input.is_action_just_pressed("ui_accept")
	)
	match estado:
		Estado.INSTRUCCIONES, Estado.RESULTADO:
			if confirmar:
				logica = _crear_logica()
				_textos.clear()
				_cambiar_estado(Estado.JUGANDO)
		Estado.JUGANDO:
			_jugar(delta)
			for evento in logica.ultimos_eventos:
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
			_mensaje.text = _texto_instrucciones() + "\n\n[F] Empezar     [Esc] Salir"
		Estado.JUGANDO:
			_mensaje.text = ""
		Estado.RESULTADO:
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
	var fuente: Font = ThemeDB.fallback_font
	for texto in _textos:
		var valor: int = texto.puntos
		var cadena: String = ("+%d" if valor > 0 else "%d") % valor
		var color: Color = COLOR_SUMA if valor > 0 else COLOR_RESTA
		color.a = clampf(texto.vida / VIDA_TEXTO, 0.0, 1.0)
		escribir(texto.pos - Vector2(12, 0), cadena, 16, color)


## Texto con contorno sobre el área de juego.
func escribir(pos: Vector2, cadena: String, tamano: int, color: Color, ancho: float = -1, alineacion := HORIZONTAL_ALIGNMENT_LEFT) -> void:
	var fuente: Font = ThemeDB.fallback_font
	_area.draw_string_outline(fuente, pos, cadena, alineacion, ancho, tamano, 4, Color(0, 0, 0, color.a))
	_area.draw_string(fuente, pos, cadena, alineacion, ancho, tamano, color)


# --- Métodos que cada minijuego sobrescribe ---------------------------------

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
