extends MinijuegoBase

@export var molienda := false
var _pulso_raton := false


class Precision extends RefCounted:
	var tiempo_restante := 12.0
	var puntuacion := 0
	var intentos := 0
	var posicion := 0.0
	var ultimos_eventos: Array = []

	func terminada() -> bool:
		return tiempo_restante <= 0.0


func _ready() -> void:
	super._ready()
	$Marco/Titulo.text = "Muelas del molino" if molienda else "Banco de carpintería"
	$Marco/Ayuda.text = "F / A / clic: confirmar   ·   Esc / B: salir"
	_area.gui_input.connect(_al_pulsar_area)


func _crear_logica() -> RefCounted:
	_pulso_raton = false
	return Precision.new()


func _jugar(delta: float) -> void:
	var partida := logica as Precision
	partida.tiempo_restante = maxf(0.0, partida.tiempo_restante - delta)
	partida.posicion = pingpong((12.0 - partida.tiempo_restante) * (0.6 if molienda else 0.85), 1.0)
	if Input.is_action_just_pressed("interactuar") or Input.is_action_just_pressed("ui_accept") or _pulso_raton:
		_pulso_raton = false
		partida.intentos += 1
		if absf(partida.posicion - 0.5) <= (0.18 if molienda else 0.15):
			partida.puntuacion += 1
		if partida.puntuacion >= (1 if molienda else 2) or partida.intentos >= 3:
			partida.tiempo_restante = 0.0


func _al_pulsar_area(evento: InputEvent) -> void:
	if estado == Estado.JUGANDO and evento is InputEventMouseButton and evento.pressed and evento.button_index == MOUSE_BUTTON_LEFT:
		_pulso_raton = true


func _texto_instrucciones() -> String:
	if molienda:
		return "Ajusta la molienda. Pulsa F o A cuando el indicador llegue a la zona dorada."
	return "Haz dos cortes precisos en tres intentos. Pulsa F o A al cruzar la zona dorada."


func _dibujar() -> void:
	var partida := logica as Precision
	var margen := 0.18 if molienda else 0.15
	_area.draw_rect(Rect2(60, 135, 360, 42), Color("#291a10"))
	_area.draw_rect(Rect2(240 - 360 * margen, 135, 720 * margen, 42), Color("#cd9e48"))
	_area.draw_rect(Rect2(56 + 360 * partida.posicion, 128, 8, 56), Color("#fff4d1"))
	if estado == Estado.JUGANDO:
		escribir(Vector2(60, 210), "Intentos restantes: %d" % (3 - partida.intentos), 16, COLOR_TEXTO)

