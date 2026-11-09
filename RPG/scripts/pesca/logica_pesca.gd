class_name LogicaPesca
extends RefCounted
## Reglas del minijuego de pesca, sin nodos ni entrada: la vista le pasa el
## eje horizontal y dibuja el estado. Coordenadas en pixeles del area de juego.

enum Tipo { PEZ, PIEDRA }

const ANCHO: float = 480.0
const ALTO: float = 320.0
const DURACION: float = 60.0
const RED_ANCHO: float = 72.0
const RED_Y: float = 286.0
const RED_VELOCIDAD: float = 330.0
const RADIO_OBJETO: float = 12.0
const PUNTOS_PEZ: int = 10
const PUNTOS_PEZ_PERDIDO: int = -5
const PUNTOS_PIEDRA: int = -10
const PROBABILIDAD_PEZ: float = 0.7
const INTERVALO_INICIAL: float = 0.9
const INTERVALO_FINAL: float = 0.45
const VELOCIDAD_MIN: float = 90.0
const VELOCIDAD_MAX: float = 170.0

var puntuacion: int = 0
var tiempo_restante: float = DURACION
var red_x: float = ANCHO * 0.5
## Cada objeto: {tipo: Tipo, pos: Vector2, velocidad: float}.
var objetos: Array[Dictionary] = []
var peces_atrapados: int = 0
var peces_perdidos: int = 0
var piedras_atrapadas: int = 0
## Eventos del ultimo avanzar(): {puntos: int, pos: Vector2}. La vista los consume.
var ultimos_eventos: Array[Dictionary] = []

var _rng := RandomNumberGenerator.new()
var _espera_aparicion: float = 0.5


func _init(semilla: int = -1) -> void:
	if semilla >= 0:
		_rng.seed = semilla
	else:
		_rng.randomize()


func terminada() -> bool:
	return tiempo_restante <= 0.0


func avanzar(delta: float, eje_x: float) -> void:
	ultimos_eventos.clear()
	if terminada():
		return
	tiempo_restante = maxf(tiempo_restante - delta, 0.0)
	var medio: float = RED_ANCHO * 0.5
	red_x = clampf(red_x + clampf(eje_x, -1.0, 1.0) * RED_VELOCIDAD * delta, medio, ANCHO - medio)

	_espera_aparicion -= delta
	if _espera_aparicion <= 0.0 and not terminada():
		_generar_objeto()
		var progreso: float = 1.0 - tiempo_restante / DURACION
		_espera_aparicion = lerpf(INTERVALO_INICIAL, INTERVALO_FINAL, progreso)

	for objeto in objetos.duplicate():
		var pos: Vector2 = objeto.pos
		var y_anterior: float = pos.y
		pos.y += objeto.velocidad * delta
		objeto.pos = pos
		if y_anterior < RED_Y and pos.y >= RED_Y and absf(pos.x - red_x) <= medio + RADIO_OBJETO * 0.5:
			_resolver(objeto, true)
		elif pos.y - RADIO_OBJETO > ALTO:
			_resolver(objeto, false)

	if terminada():
		objetos.clear()


## Añade un objeto en una posicion concreta; lo usan las pruebas.
func agregar_objeto(tipo: Tipo, pos: Vector2, velocidad: float) -> void:
	objetos.append({tipo = tipo, pos = pos, velocidad = velocidad})


func _generar_objeto() -> void:
	var tipo: Tipo = Tipo.PEZ if _rng.randf() < PROBABILIDAD_PEZ else Tipo.PIEDRA
	var x: float = _rng.randf_range(RADIO_OBJETO * 2.0, ANCHO - RADIO_OBJETO * 2.0)
	agregar_objeto(tipo, Vector2(x, -RADIO_OBJETO), _rng.randf_range(VELOCIDAD_MIN, VELOCIDAD_MAX))


func _resolver(objeto: Dictionary, atrapado: bool) -> void:
	objetos.erase(objeto)
	var puntos: int = 0
	if objeto.tipo == Tipo.PEZ:
		if atrapado:
			puntos = PUNTOS_PEZ
			peces_atrapados += 1
		else:
			puntos = PUNTOS_PEZ_PERDIDO
			peces_perdidos += 1
	elif atrapado:
		puntos = PUNTOS_PIEDRA
		piedras_atrapadas += 1
	if puntos != 0:
		puntuacion += puntos
		ultimos_eventos.append({puntos = puntos, pos = Vector2(objeto.pos.x, minf(objeto.pos.y, RED_Y))})
