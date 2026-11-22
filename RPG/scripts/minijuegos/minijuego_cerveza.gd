extends MinijuegoBase
## Vista del minijuego de la cerveza: receta arriba, ingredientes cayendo y
## caldero que se mueve con A/D o las flechas.

const COLOR_FONDO := Color(0.25, 0.16, 0.10)
const COLOR_TABLAS := Color(0.30, 0.20, 0.12)
const COLOR_FRANJA := Color(0.12, 0.08, 0.05, 0.85)
const COLOR_CALDERO := Color(0.22, 0.22, 0.24)
const COLOR_MOSTO := Color(0.85, 0.62, 0.22)
const COLORES: Array[Color] = [
	Color(0.93, 0.80, 0.42),  # cebada
	Color(0.45, 0.75, 0.30),  # lúpulo
	Color(0.40, 0.68, 0.95),  # agua
	Color(0.95, 0.93, 0.85),  # levadura
]


func _crear_logica() -> RefCounted:
	return LogicaCerveza.new(semilla)


func _sonidos() -> Dictionary:
	return {
		&"ingrediente": variantes(AUDIO_INTERFAZ, ["drop_001", "drop_002", "drop_003"]),
		&"receta": variantes(AUDIO_RPG, ["metalPot1", "metalPot2", "metalPot3"]),
		&"error": [AUDIO_INTERFAZ + "error_004.ogg"],
	}


func _jugar(delta: float) -> void:
	logica.avanzar(delta, Input.get_axis("mover_izquierda", "mover_derecha"))


func _texto_instrucciones() -> String:
	return "Mueve el caldero con A/D o las flechas.\nEcha los ingredientes en el orden de la receta (+%d).\nReceta completa: +%d. Ingrediente equivocado: %d." % [
		LogicaCerveza.PUNTOS_CORRECTO, LogicaCerveza.PUNTOS_RECETA, LogicaCerveza.PUNTOS_ERROR]


func _texto_resultado() -> String:
	return "Recetas completas: %d\nAciertos: %d   Errores: %d" % [logica.recetas_completadas, logica.aciertos, logica.errores]


func _dibujar() -> void:
	var l: LogicaCerveza = logica
	_area.draw_rect(Rect2(0, 0, LogicaCerveza.ANCHO, LogicaCerveza.ALTO), COLOR_FONDO)
	for i in 8:
		_area.draw_rect(Rect2(0, 40 + i * 36, LogicaCerveza.ANCHO, 2), COLOR_TABLAS)
	# Receta: cuatro casillas, la siguiente resaltada y las hechas atenuadas.
	_area.draw_rect(Rect2(0, 0, LogicaCerveza.ANCHO, LogicaCerveza.ALTURA_RECETA - 6), COLOR_FRANJA)
	escribir(Vector2(8, 19), "Receta:", 13, COLOR_TEXTO)
	for i in l.receta.size():
		var x := 70.0 + i * 102.0
		var tipo: int = l.receta[i]
		var hecho := i < l.paso
		var color: Color = COLORES[tipo]
		if hecho:
			color = color.darkened(0.55)
		if i == l.paso:
			_area.draw_rect(Rect2(x - 3, 2, 98, 24), Color(1, 0.85, 0.4, 0.35))
		_dibujar_ingrediente(Vector2(x + 10, 14), tipo, 0.7, color)
		escribir(Vector2(x + 22, 19), "%d. %s" % [i + 1, LogicaCerveza.NOMBRES[tipo]], 12, COLOR_TEXTO if not hecho else COLOR_TEXTO.darkened(0.5))
	for objeto in l.objetos:
		_dibujar_ingrediente(objeto.pos, objeto.tipo, 1.0, COLORES[objeto.tipo])
	_dibujar_caldero(Vector2(l.caldero_x, LogicaCerveza.CALDERO_Y))


func _dibujar_ingrediente(c: Vector2, tipo: int, escala: float, color: Color) -> void:
	_area.draw_set_transform(c, 0.0, Vector2(escala, escala))
	match tipo:
		LogicaCerveza.Ingrediente.CEBADA:
			# Espiga: granos alternos sobre un tallo.
			_area.draw_line(Vector2(0, 12), Vector2(0, -12), color.darkened(0.3), 2.0)
			for k in 4:
				var y := -9.0 + k * 5.0
				_area.draw_circle(Vector2(-3, y), 3.0, color)
				_area.draw_circle(Vector2(3, y + 2), 3.0, color)
		LogicaCerveza.Ingrediente.LUPULO:
			# Piña de lúpulo: escamas superpuestas.
			for k in 3:
				_area.draw_circle(Vector2(0, -6 + k * 6), 7.0 - k, color.darkened(k * 0.12))
			_area.draw_line(Vector2(0, -12), Vector2(3, -16), color.darkened(0.4), 2.0)
		LogicaCerveza.Ingrediente.AGUA:
			# Gota.
			_area.draw_colored_polygon(PackedVector2Array([Vector2(0, -12), Vector2(7, 2), Vector2(0, 10), Vector2(-7, 2)]), color)
			_area.draw_circle(Vector2(0, 3), 7.0, color)
			_area.draw_circle(Vector2(-2, 1), 2.0, Color(1, 1, 1, 0.7))
		LogicaCerveza.Ingrediente.LEVADURA:
			# Saquito atado.
			_area.draw_rect(Rect2(-8, -4, 16, 14), color)
			_area.draw_colored_polygon(PackedVector2Array([Vector2(-8, -4), Vector2(0, -11), Vector2(8, -4)]), color.darkened(0.1))
			_area.draw_rect(Rect2(-8, -6, 16, 3), Color(0.55, 0.36, 0.18))
	_area.draw_set_transform(Vector2.ZERO)


func _dibujar_caldero(c: Vector2) -> void:
	var medio := LogicaCerveza.CALDERO_ANCHO * 0.5
	_area.draw_rect(Rect2(c.x - medio, c.y - 10, LogicaCerveza.CALDERO_ANCHO, 6), COLOR_MOSTO)
	_area.draw_colored_polygon(PackedVector2Array([
		Vector2(c.x - medio - 4, c.y - 6), Vector2(c.x + medio + 4, c.y - 6),
		Vector2(c.x + medio - 6, c.y + 22), Vector2(c.x - medio + 6, c.y + 22)]), COLOR_CALDERO)
	_area.draw_rect(Rect2(c.x - medio - 6, c.y - 10, LogicaCerveza.CALDERO_ANCHO + 12, 5), COLOR_CALDERO.lightened(0.2))
	for x in [-medio + 10, medio - 14]:
		_area.draw_rect(Rect2(c.x + x, c.y + 22, 4, 8), COLOR_CALDERO.darkened(0.3))
