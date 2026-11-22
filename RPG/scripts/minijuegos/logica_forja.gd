class_name LogicaForja
extends RefCounted
## Reglas del minijuego de la forja, sin nodos ni entrada: una aguja de fuerza
## oscila y hay que golpear cuando pasa por la zona buena mientras la pieza
## sigue caliente; se puede volver a calentar a costa de tiempo.

const ANCHO: float = 480.0
const ALTO: float = 320.0
const DURACION: float = 60.0
## La temperatura baja de 1 (al rojo) a 0 (fría).
const ENFRIAMIENTO: float = 0.11
const TEMPERATURA_MINIMA: float = 0.3
const CALENTAR_SEGUNDOS: float = 1.2
## La aguja recorre 0..1 de ida y vuelta; velocidad en recorridos por segundo.
const AGUJA_LENTA: float = 0.9
const AGUJA_RAPIDA: float = 1.6
const ZONA_CENTRO: float = 0.5
const ZONA_MEDIA: float = 0.09
const GOLPES_POR_PIEZA: int = 5
const PUNTOS_GOLPE: int = 4
const PUNTOS_PIEZA: int = 20
const PUNTOS_FLOJO: int = -2
const PUNTOS_FRIO: int = -3
const POS_PIEZA := Vector2(240.0, 170.0)

var puntuacion: int = 0
var tiempo_restante: float = DURACION
var temperatura: float = 1.0
var aguja: float = 0.0
var golpes: int = 0
var piezas: int = 0
var golpes_buenos: int = 0
var golpes_flojos: int = 0
var golpes_en_frio: int = 0
## Segundos que faltan para sacar la pieza del fuego (0 = en el yunque).
var calentando: float = 0.0
## Eventos del último avanzar(): {puntos: int, pos: Vector2}. La vista los consume.
var ultimos_eventos: Array[Dictionary] = []

var _sentido: float = 1.0


func _init(_semilla: int = -1) -> void:
	# Sin azar: la semilla se acepta por simetría con el resto de minijuegos.
	pass


func terminada() -> bool:
	return tiempo_restante <= 0.0


func en_zona() -> bool:
	return absf(aguja - ZONA_CENTRO) <= ZONA_MEDIA


func avanzar(delta: float, golpear: bool, calentar: bool) -> void:
	ultimos_eventos.clear()
	if terminada():
		return
	tiempo_restante = maxf(tiempo_restante - delta, 0.0)
	var progreso := 1.0 - tiempo_restante / DURACION
	aguja += _sentido * lerpf(AGUJA_LENTA, AGUJA_RAPIDA, progreso) * 2.0 * delta
	if aguja >= 1.0:
		aguja = 2.0 - aguja
		_sentido = -1.0
	elif aguja <= 0.0:
		aguja = -aguja
		_sentido = 1.0
	if calentando > 0.0:
		calentando -= delta
		if calentando <= 0.0:
			calentando = 0.0
			temperatura = 1.0
		return
	temperatura = maxf(temperatura - ENFRIAMIENTO * delta, 0.0)
	if calentar:
		calentando = CALENTAR_SEGUNDOS
	elif golpear:
		golpe()


func golpe() -> void:
	if calentando > 0.0:
		return
	if temperatura < TEMPERATURA_MINIMA:
		golpes_en_frio += 1
		_sumar(PUNTOS_FRIO)
	elif en_zona():
		golpes_buenos += 1
		golpes += 1
		var puntos := PUNTOS_GOLPE
		if golpes >= GOLPES_POR_PIEZA:
			puntos += PUNTOS_PIEZA
			piezas += 1
			golpes = 0
			temperatura = 1.0
		_sumar(puntos)
	else:
		golpes_flojos += 1
		_sumar(PUNTOS_FLOJO)


func _sumar(puntos: int) -> void:
	puntuacion += puntos
	ultimos_eventos.append({puntos = puntos, pos = POS_PIEZA + Vector2(0, -40)})
