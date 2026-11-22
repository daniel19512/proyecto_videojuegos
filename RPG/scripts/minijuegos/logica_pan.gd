class_name LogicaPan
extends RefCounted
## Reglas del minijuego del pan, sin nodos ni entrada: varias hogazas se
## cuecen a la vez y hay que sacarlas cuando están doradas. La vista le pasa
## el cambio de selección y si se pulsa sacar. Coordenadas en píxeles.

enum Punto { VACIO, CRUDO, DORADO, QUEMADO }

const ANCHO: float = 480.0
const ALTO: float = 320.0
const DURACION: float = 60.0
const HORNOS: int = 4
## Cocción 0..1: crudo hasta DORADO_DESDE, dorado hasta QUEMADO_DESDE.
const DORADO_DESDE: float = 0.6
const QUEMADO_DESDE: float = 0.85
## Más allá de esta cocción la hogaza se carboniza y se retira sola.
const CARBONIZADO: float = 1.15
## Segundos que tarda en llegar a cocción 1 al principio y al final.
const COCCION_LENTA: float = 8.0
const COCCION_RAPIDA: float = 5.0
const ESPERA_MIN: float = 0.5
const ESPERA_MAX: float = 1.6
const PUNTOS_DORADO: int = 10
const PUNTOS_CRUDO: int = -3
const PUNTOS_QUEMADO: int = -5
const Y_HOGAZA: float = 190.0

var puntuacion: int = 0
var tiempo_restante: float = DURACION
var seleccion: int = 0
## Cada horno: {ocupado: bool, coccion: float, velocidad: float, espera: float}.
var hornos: Array[Dictionary] = []
var doradas: int = 0
var crudas: int = 0
var quemadas: int = 0
## Eventos del último avanzar(): {puntos: int, pos: Vector2, tipo: StringName}
## (dorado, crudo o quemado). La vista los consume.
var ultimos_eventos: Array[Dictionary] = []

var _rng := RandomNumberGenerator.new()


func _init(semilla: int = -1) -> void:
	if semilla >= 0:
		_rng.seed = semilla
	else:
		_rng.randomize()
	for i in HORNOS:
		hornos.append({ocupado = false, coccion = 0.0, velocidad = 0.0, espera = _rng.randf_range(0.2, 1.2)})


func terminada() -> bool:
	return tiempo_restante <= 0.0


func punto(i: int) -> Punto:
	var horno: Dictionary = hornos[i]
	if not horno.ocupado:
		return Punto.VACIO
	if horno.coccion < DORADO_DESDE:
		return Punto.CRUDO
	if horno.coccion < QUEMADO_DESDE:
		return Punto.DORADO
	return Punto.QUEMADO


func centro_horno(i: int) -> Vector2:
	return Vector2(ANCHO * (i + 0.5) / HORNOS, Y_HOGAZA)


## `mover`: -1, 0 o 1 (pulsación de este fotograma). `sacar`: pulsación de sacar.
func avanzar(delta: float, mover: int, sacar: bool) -> void:
	ultimos_eventos.clear()
	if terminada():
		return
	tiempo_restante = maxf(tiempo_restante - delta, 0.0)
	seleccion = clampi(seleccion + mover, 0, HORNOS - 1)
	var progreso := 1.0 - tiempo_restante / DURACION
	for i in HORNOS:
		var horno: Dictionary = hornos[i]
		if horno.ocupado:
			horno.coccion += horno.velocidad * delta
			if horno.coccion >= CARBONIZADO:
				quemadas += 1
				_vaciar(i, PUNTOS_QUEMADO, &"quemado")
		else:
			horno.espera -= delta
			if horno.espera <= 0.0:
				horno.ocupado = true
				horno.coccion = 0.0
				var segundos := lerpf(COCCION_LENTA, COCCION_RAPIDA, progreso) * _rng.randf_range(0.85, 1.15)
				horno.velocidad = 1.0 / segundos
	if sacar:
		sacar_hogaza(seleccion)


func sacar_hogaza(i: int) -> void:
	match punto(i):
		Punto.CRUDO:
			crudas += 1
			_vaciar(i, PUNTOS_CRUDO, &"crudo")
		Punto.DORADO:
			doradas += 1
			_vaciar(i, PUNTOS_DORADO, &"dorado")
		Punto.QUEMADO:
			quemadas += 1
			_vaciar(i, PUNTOS_QUEMADO, &"quemado")


func _vaciar(i: int, puntos: int, tipo: StringName) -> void:
	var horno: Dictionary = hornos[i]
	horno.ocupado = false
	horno.coccion = 0.0
	horno.espera = _rng.randf_range(ESPERA_MIN, ESPERA_MAX)
	puntuacion += puntos
	ultimos_eventos.append({puntos = puntos, pos = centro_horno(i) + Vector2(0, -30), tipo = tipo})
