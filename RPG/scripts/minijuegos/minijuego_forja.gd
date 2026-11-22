extends MinijuegoBase
## Vista del minijuego de la forja: pieza al rojo sobre el yunque, termómetro,
## medidor de fuerza con aguja y zona buena. F golpea; S o abajo la calienta.

const COLOR_PARED := Color(0.20, 0.19, 0.18)
const COLOR_PIEDRA := Color(0.27, 0.26, 0.25)
const COLOR_YUNQUE := Color(0.32, 0.33, 0.36)
const COLOR_FRIO := Color(0.45, 0.45, 0.48)
const COLOR_CALIENTE := Color(1.0, 0.38, 0.08)
const COLOR_FUEGO := Color(1.0, 0.55, 0.12)
const COLOR_ZONA := Color(0.45, 0.9, 0.35)


func _crear_logica() -> RefCounted:
	return LogicaForja.new(semilla)


func _jugar(delta: float) -> void:
	var golpear := Input.is_action_just_pressed("interactuar") or Input.is_action_just_pressed("ui_accept")
	logica.avanzar(delta, golpear, Input.is_action_just_pressed("mover_abajo"))


func _texto_instrucciones() -> String:
	return "Golpea con F cuando la aguja pase por la zona verde (+%d).\nCada %d golpes buenos terminan una pieza (+%d).\nFuera de la zona: %d. Si la pieza se enfría: %d.\nS o flecha abajo: volver a calentarla." % [
		LogicaForja.PUNTOS_GOLPE, LogicaForja.GOLPES_POR_PIEZA, LogicaForja.PUNTOS_PIEZA,
		LogicaForja.PUNTOS_FLOJO, LogicaForja.PUNTOS_FRIO]


func _texto_resultado() -> String:
	return "Piezas forjadas: %d\nGolpes buenos: %d   Flojos: %d   En frío: %d" % [
		logica.piezas, logica.golpes_buenos, logica.golpes_flojos, logica.golpes_en_frio]


func _dibujar() -> void:
	var l: LogicaForja = logica
	_area.draw_rect(Rect2(0, 0, LogicaForja.ANCHO, LogicaForja.ALTO), COLOR_PARED)
	for fila in 8:
		for k in 7:
			var desfase := 0.0 if fila % 2 == 0 else 35.0
			_area.draw_rect(Rect2(desfase + k * 70.0 + 2, fila * 40.0 + 2, 66, 36), COLOR_PIEDRA)
	_dibujar_fuego(Vector2(70, 250), l.calentando > 0.0)
	# Yunque.
	var p := LogicaForja.POS_PIEZA
	_area.draw_colored_polygon(PackedVector2Array([
		p + Vector2(-80, 14), p + Vector2(70, 14), p + Vector2(95, 4), p + Vector2(70, 34), p + Vector2(-80, 34)]), COLOR_YUNQUE)
	_area.draw_rect(Rect2(p.x - 40, p.y + 34, 80, 40), COLOR_YUNQUE.darkened(0.25))
	_area.draw_rect(Rect2(p.x - 60, p.y + 74, 120, 14), COLOR_YUNQUE.darkened(0.4))
	# Pieza: en el fuego mientras se calienta, sobre el yunque si no.
	var color := COLOR_FRIO.lerp(COLOR_CALIENTE, l.temperatura)
	if l.calentando > 0.0:
		_area.draw_rect(Rect2(40, 226, 60, 10), COLOR_CALIENTE)
		escribir(Vector2(p.x - 120, p.y - 20), "Calentando...", 16, COLOR_FUEGO, 240, HORIZONTAL_ALIGNMENT_CENTER)
	else:
		var largo := 90.0 - l.golpes * 8.0
		_area.draw_rect(Rect2(p.x - largo * 0.5, p.y + 2, largo, 12 + l.golpes * 1.5), color)
		if l.temperatura < LogicaForja.TEMPERATURA_MINIMA:
			escribir(Vector2(p.x - 120, p.y - 20), "¡Fría! Caliéntala (S)", 15, Color(0.7, 0.85, 1.0), 240, HORIZONTAL_ALIGNMENT_CENTER)
	escribir(Vector2(p.x - 120, p.y + 112), "Golpes: %d / %d" % [l.golpes, LogicaForja.GOLPES_POR_PIEZA], 14, COLOR_TEXTO, 240, HORIZONTAL_ALIGNMENT_CENTER)
	_dibujar_termometro(l.temperatura)
	_dibujar_medidor(l)


func _dibujar_fuego(c: Vector2, avivado: bool) -> void:
	_area.draw_rect(Rect2(c.x - 50, c.y - 10, 100, 60), Color(0.12, 0.10, 0.09))
	var fuerza := 1.4 if avivado else 1.0
	for k in 5:
		var alto := (18.0 + 10.0 * sin(_tiempo_visual * 9.0 + k * 1.7)) * fuerza
		var x := c.x - 36 + k * 18
		_area.draw_colored_polygon(PackedVector2Array([Vector2(x - 9, c.y), Vector2(x + 9, c.y), Vector2(x, c.y - alto)]), COLOR_FUEGO)


func _dibujar_termometro(temperatura: float) -> void:
	var x := 440.0
	var y := 60.0
	var alto := 200.0
	_area.draw_rect(Rect2(x, y, 18, alto), Color(0.1, 0.08, 0.07))
	var lleno := alto * temperatura
	_area.draw_rect(Rect2(x + 3, y + alto - lleno, 12, lleno), COLOR_FRIO.lerp(COLOR_CALIENTE, temperatura))
	var limite := y + alto * (1.0 - LogicaForja.TEMPERATURA_MINIMA)
	_area.draw_line(Vector2(x - 4, limite), Vector2(x + 22, limite), Color(0.7, 0.85, 1.0), 2.0)
	escribir(Vector2(x - 20, y - 8), "Calor", 12, COLOR_TEXTO)


func _dibujar_medidor(l: LogicaForja) -> void:
	var x := 60.0
	var y := 24.0
	var ancho := 360.0
	_area.draw_rect(Rect2(x, y, ancho, 18), Color(0.1, 0.08, 0.07))
	var zona_x := x + (LogicaForja.ZONA_CENTRO - LogicaForja.ZONA_MEDIA) * ancho
	_area.draw_rect(Rect2(zona_x, y, LogicaForja.ZONA_MEDIA * 2.0 * ancho, 18), COLOR_ZONA)
	var aguja_x := x + l.aguja * ancho
	_area.draw_rect(Rect2(aguja_x - 2, y - 5, 4, 28), Color.WHITE)
	escribir(Vector2(x, y + 36), "Fuerza", 12, COLOR_TEXTO)
