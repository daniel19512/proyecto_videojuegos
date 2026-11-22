extends MinijuegoBase
## Vista del minijuego del pan: cuatro bocas de horno con hogazas que cambian
## de color. A/D o flechas eligen la boca y F saca la hogaza.

const COLOR_LADRILLO := Color(0.50, 0.24, 0.16)
const COLOR_JUNTA := Color(0.36, 0.17, 0.11)
const COLOR_BOCA := Color(0.10, 0.05, 0.03)
const COLOR_BRASAS := Color(1.0, 0.42, 0.10)
const COLOR_CRUDO := Color(0.93, 0.86, 0.68)
const COLOR_DORADO := Color(0.83, 0.55, 0.20)
const COLOR_QUEMADO := Color(0.22, 0.14, 0.09)
const COLOR_SELECCION := Color(1.0, 0.88, 0.45)


func _crear_logica() -> RefCounted:
	return LogicaPan.new(semilla)


func _jugar(delta: float) -> void:
	var mover := int(Input.is_action_just_pressed("mover_derecha")) - int(Input.is_action_just_pressed("mover_izquierda"))
	var sacar := Input.is_action_just_pressed("interactuar") or Input.is_action_just_pressed("ui_accept")
	logica.avanzar(delta, mover, sacar)


func _texto_instrucciones() -> String:
	return "Elige la boca del horno con A/D o las flechas y saca la hogaza con F.\nDorada: +%d. Cruda: %d. Quemada: %d.\nSi la dejas demasiado, se carboniza sola." % [
		LogicaPan.PUNTOS_DORADO, LogicaPan.PUNTOS_CRUDO, LogicaPan.PUNTOS_QUEMADO]


func _texto_resultado() -> String:
	return "Doradas: %d   Crudas: %d   Quemadas: %d" % [logica.doradas, logica.crudas, logica.quemadas]


func _dibujar() -> void:
	var l: LogicaPan = logica
	_area.draw_rect(Rect2(0, 0, LogicaPan.ANCHO, LogicaPan.ALTO), COLOR_LADRILLO)
	for fila in 12:
		var y := fila * 28.0
		_area.draw_rect(Rect2(0, y, LogicaPan.ANCHO, 2), COLOR_JUNTA)
		var desfase := 0.0 if fila % 2 == 0 else 24.0
		for k in 11:
			_area.draw_rect(Rect2(desfase + k * 48.0, y, 2, 28), COLOR_JUNTA)
	for i in LogicaPan.HORNOS:
		var c: Vector2 = l.centro_horno(i)
		# Boca abovedada con brasas.
		_area.draw_rect(Rect2(c.x - 48, c.y - 40, 96, 74), COLOR_BOCA)
		_area.draw_circle(Vector2(c.x, c.y - 40), 48.0, COLOR_BOCA)
		var pulso := 0.75 + 0.25 * sin(_tiempo_visual * 5.0 + i)
		_area.draw_rect(Rect2(c.x - 44, c.y + 24, 88, 8), COLOR_BRASAS * Color(pulso, pulso, pulso, 1.0))
		var punto: int = l.punto(i)
		if punto != LogicaPan.Punto.VACIO:
			_dibujar_hogaza(c, l.hornos[i].coccion)
			_dibujar_barra(c, l.hornos[i].coccion)
		if i == l.seleccion:
			_area.draw_rect(Rect2(c.x - 52, c.y - 92, 104, 132), COLOR_SELECCION, false, 3.0)
			escribir(Vector2(c.x - 50, c.y + 62), "[F] Sacar", 13, COLOR_TEXTO, 100, HORIZONTAL_ALIGNMENT_CENTER)


func _color_hogaza(coccion: float) -> Color:
	if coccion < LogicaPan.DORADO_DESDE:
		return COLOR_CRUDO.lerp(COLOR_DORADO, coccion / LogicaPan.DORADO_DESDE * 0.55)
	if coccion < LogicaPan.QUEMADO_DESDE:
		return COLOR_DORADO
	var t := clampf((coccion - LogicaPan.QUEMADO_DESDE) / (LogicaPan.CARBONIZADO - LogicaPan.QUEMADO_DESDE), 0.0, 1.0)
	return COLOR_DORADO.lerp(COLOR_QUEMADO, 0.5 + t * 0.5)


func _dibujar_hogaza(c: Vector2, coccion: float) -> void:
	var color := _color_hogaza(coccion)
	_area.draw_set_transform(c + Vector2(0, 6), 0.0, Vector2(1.6, 1.0))
	_area.draw_circle(Vector2.ZERO, 20.0, color)
	_area.draw_set_transform(Vector2.ZERO)
	for k in 3:
		var x := c.x - 14 + k * 14
		_area.draw_line(Vector2(x - 4, c.y), Vector2(x + 4, c.y + 6), color.darkened(0.3), 2.0)
	if coccion >= LogicaPan.QUEMADO_DESDE:
		# Humo.
		for k in 3:
			var fase := fmod(_tiempo_visual * 0.8 + k * 0.33, 1.0)
			_area.draw_circle(c + Vector2(-10 + k * 10, -20 - fase * 40), 6.0 + fase * 4.0, Color(0.6, 0.6, 0.6, 0.5 * (1.0 - fase)))


## Barra de cocción sobre la boca: franja dorada marcada.
func _dibujar_barra(c: Vector2, coccion: float) -> void:
	var x := c.x - 40.0
	var y := c.y - 84.0
	var ancho := 80.0
	var escala := ancho / LogicaPan.CARBONIZADO
	_area.draw_rect(Rect2(x, y, ancho, 8), Color(0.1, 0.07, 0.05))
	_area.draw_rect(Rect2(x + LogicaPan.DORADO_DESDE * escala, y, (LogicaPan.QUEMADO_DESDE - LogicaPan.DORADO_DESDE) * escala, 8), COLOR_DORADO)
	_area.draw_rect(Rect2(x + minf(coccion, LogicaPan.CARBONIZADO) * escala - 1, y - 3, 3, 14), Color.WHITE)
