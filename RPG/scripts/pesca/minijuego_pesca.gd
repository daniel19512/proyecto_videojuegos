extends CanvasLayer
## Panel del minijuego de pesca. Dibuja el estado de LogicaPesca con formas
## simples y gestiona instrucciones, partida y resultado. Funciona con el arbol
## en pausa (process_mode ALWAYS); quien lo abre decide pausar o no.

signal cerrado
## Se emite al agotarse el tiempo de cada partida.
signal partida_terminada(puntuacion: int)

enum Estado { CERRADO, INSTRUCCIONES, JUGANDO, RESULTADO }

const COLOR_AGUA_1 := Color(0.16, 0.42, 0.62)
const COLOR_AGUA_2 := Color(0.20, 0.50, 0.70)
const COLOR_ESPUMA := Color(0.72, 0.88, 0.95)
const COLOR_FONDO := Color(0.30, 0.25, 0.16)
const COLORES_PEZ: Array[Color] = [Color(0.96, 0.58, 0.20), Color(0.98, 0.84, 0.30), Color(0.92, 0.42, 0.42)]
const COLOR_PIEDRA := Color(0.50, 0.50, 0.52)
const COLOR_PIEDRA_SOMBRA := Color(0.33, 0.33, 0.36)
const COLOR_RED := Color(0.55, 0.36, 0.18)
const COLOR_MALLA := Color(0.92, 0.88, 0.76, 0.85)
const COLOR_SUMA := Color(0.55, 1.0, 0.45)
const COLOR_RESTA := Color(1.0, 0.42, 0.36)
const VIDA_TEXTO: float = 0.8

var estado: Estado = Estado.CERRADO
var logica: LogicaPesca
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
	_area.draw.connect(_dibujar)


func abrir() -> void:
	logica = LogicaPesca.new(semilla)
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
	# La pulsacion que abrio el panel no debe iniciar la partida en el mismo fotograma.
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
				logica = LogicaPesca.new(semilla)
				_textos.clear()
				_cambiar_estado(Estado.JUGANDO)
		Estado.JUGANDO:
			logica.avanzar(delta, Input.get_axis("mover_izquierda", "mover_derecha"))
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
			_mensaje.text = "Mueve la red con A/D o las flechas.\nAtrapa peces (+%d). Si se escapan: %d.\nEvita las piedras (%d).\n\n[F] Empezar     [Esc] Salir" % [
				LogicaPesca.PUNTOS_PEZ, LogicaPesca.PUNTOS_PEZ_PERDIDO, LogicaPesca.PUNTOS_PIEDRA]
		Estado.JUGANDO:
			_mensaje.text = ""
		Estado.RESULTADO:
			_mensaje.text = "¡Tiempo!\n\nPuntuación: %d\nPeces atrapados: %d   Escapados: %d\nPiedras atrapadas: %d\n\n[F] Otra vez     [Esc] Salir" % [
				logica.puntuacion, logica.peces_atrapados, logica.peces_perdidos, logica.piedras_atrapadas]
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


func _dibujar() -> void:
	var ancho: float = LogicaPesca.ANCHO
	var alto: float = LogicaPesca.ALTO
	_area.draw_rect(Rect2(0, 0, ancho, alto), COLOR_AGUA_1)
	# Bandas de corriente que bajan lentamente.
	var recorrido: float = _tiempo_visual * 24.0
	var desplazamiento: float = fmod(recorrido, 40.0)
	var primera_banda: int = int(recorrido / 40.0)
	for i in range(-1, int(alto / 40.0) + 1):
		var y: float = i * 40.0 + desplazamiento
		_area.draw_rect(Rect2(0, y, ancho, 16), COLOR_AGUA_2)
		# Espuma irregular: cada banda conserva su patron mientras baja.
		var banda: int = i - primera_banda
		for j in 4:
			var semilla_espuma: int = absi(banda * 7919 + j * 104729)
			var x: float = fmod(semilla_espuma * 0.618, ancho)
			var largo: float = 8.0 + float(semilla_espuma % 13)
			var dy: float = float(semilla_espuma % 23)
			_area.draw_rect(Rect2(x, y + dy, largo, 2), COLOR_ESPUMA)
	_area.draw_rect(Rect2(0, alto - 8, ancho, 8), COLOR_FONDO)
	if logica == null:
		return
	for objeto in logica.objetos:
		if objeto.tipo == LogicaPesca.Tipo.PEZ:
			_dibujar_pez(objeto.pos, COLORES_PEZ[int(absf(objeto.velocidad)) % COLORES_PEZ.size()])
		else:
			_dibujar_piedra(objeto.pos)
	_dibujar_red(Vector2(logica.red_x, LogicaPesca.RED_Y))
	var fuente: Font = ThemeDB.fallback_font
	for texto in _textos:
		var valor: int = texto.puntos
		var cadena: String = ("+%d" if valor > 0 else "%d") % valor
		var color: Color = COLOR_SUMA if valor > 0 else COLOR_RESTA
		color.a = clampf(texto.vida / VIDA_TEXTO, 0.0, 1.0)
		_area.draw_string_outline(fuente, texto.pos - Vector2(12, 0), cadena, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, 4, Color(0, 0, 0, color.a))
		_area.draw_string(fuente, texto.pos - Vector2(12, 0), cadena, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, color)


## Pez cayendo de cabeza: cuerpo ovalado, cola arriba y ojos.
func _dibujar_pez(c: Vector2, color: Color) -> void:
	_area.draw_set_transform(c, 0.0, Vector2(1.3, 1.3))
	c = Vector2.ZERO
	var cuerpo := PackedVector2Array([
		c + Vector2(0, 12), c + Vector2(6, 6), c + Vector2(7, -2),
		c + Vector2(4, -8), c + Vector2(-4, -8), c + Vector2(-7, -2), c + Vector2(-6, 6)])
	_area.draw_colored_polygon(cuerpo, color)
	var cola := PackedVector2Array([c + Vector2(0, -7), c + Vector2(7, -16), c + Vector2(-7, -16)])
	_area.draw_colored_polygon(cola, color.darkened(0.25))
	_area.draw_rect(Rect2(c + Vector2(-4, 4), Vector2(2, 2)), Color.BLACK)
	_area.draw_rect(Rect2(c + Vector2(2, 4), Vector2(2, 2)), Color.BLACK)
	_area.draw_rect(Rect2(c + Vector2(-1, -2), Vector2(2, 6)), color.lightened(0.3))
	_area.draw_set_transform(Vector2.ZERO)


func _dibujar_piedra(c: Vector2) -> void:
	var forma := PackedVector2Array([
		c + Vector2(-11, 3), c + Vector2(-8, -8), c + Vector2(2, -11),
		c + Vector2(10, -6), c + Vector2(11, 5), c + Vector2(3, 10), c + Vector2(-7, 9)])
	_area.draw_colored_polygon(forma, COLOR_PIEDRA_SOMBRA)
	var brillo := PackedVector2Array([
		c + Vector2(-8, 1), c + Vector2(-6, -6), c + Vector2(2, -8), c + Vector2(7, -4), c + Vector2(4, 2)])
	_area.draw_colored_polygon(brillo, COLOR_PIEDRA)


## Red de mano vista desde arriba: aro de madera, malla y mango hacia abajo.
func _dibujar_red(c: Vector2) -> void:
	var medio: float = LogicaPesca.RED_ANCHO * 0.5
	_area.draw_rect(Rect2(c.x - 3, c.y + 6, 6, 22), COLOR_RED.darkened(0.2))
	_area.draw_rect(Rect2(c.x - medio, c.y - 8, LogicaPesca.RED_ANCHO, 14), Color(0.1, 0.2, 0.25, 0.35))
	for i in range(1, 9):
		var x: float = c.x - medio + i * LogicaPesca.RED_ANCHO / 9.0
		_area.draw_line(Vector2(x, c.y - 8), Vector2(x, c.y + 6), COLOR_MALLA, 1.0)
	_area.draw_line(Vector2(c.x - medio, c.y - 1), Vector2(c.x + medio, c.y - 1), COLOR_MALLA, 1.0)
	_area.draw_rect(Rect2(c.x - medio, c.y - 10, LogicaPesca.RED_ANCHO, 4), COLOR_RED)
	_area.draw_rect(Rect2(c.x - medio, c.y + 4, LogicaPesca.RED_ANCHO, 4), COLOR_RED)
	_area.draw_rect(Rect2(c.x - medio - 3, c.y - 10, 4, 18), COLOR_RED)
	_area.draw_rect(Rect2(c.x + medio - 1, c.y - 10, 4, 18), COLOR_RED)
