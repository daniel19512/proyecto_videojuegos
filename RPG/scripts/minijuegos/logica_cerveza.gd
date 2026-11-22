class_name LogicaCerveza
extends RefCounted
## Reglas del minijuego de la cerveza, sin nodos ni entrada: caen ingredientes
## y el caldero debe recogerlos en el orden de la receta. La vista le pasa el
## eje horizontal y dibuja el estado. Coordenadas en píxeles del área de juego.

enum Ingrediente { CEBADA, LUPULO, AGUA, LEVADURA }

const NOMBRES: PackedStringArray = ["Cebada", "Lúpulo", "Agua", "Levadura"]
const ANCHO: float = 480.0
const ALTO: float = 320.0
const DURACION: float = 60.0
const CALDERO_ANCHO: float = 76.0
const CALDERO_Y: float = 282.0
const CALDERO_VELOCIDAD: float = 330.0
const RADIO_OBJETO: float = 12.0
## La receta ocupa la franja superior; los ingredientes nacen debajo.
const ALTURA_RECETA: float = 34.0
const PUNTOS_CORRECTO: int = 5
const PUNTOS_ERROR: int = -5
const PUNTOS_RECETA: int = 20
## Probabilidad de que el ingrediente que aparece sea el que pide la receta.
const PROBABILIDAD_NECESARIO: float = 0.45
const INTERVALO_INICIAL: float = 0.85
const INTERVALO_FINAL: float = 0.45
const VELOCIDAD_MIN: float = 85.0
const VELOCIDAD_MAX: float = 160.0

var puntuacion: int = 0
var tiempo_restante: float = DURACION
var caldero_x: float = ANCHO * 0.5
## Cada objeto: {tipo: Ingrediente, pos: Vector2, velocidad: float}.
var objetos: Array[Dictionary] = []
## Orden de los cuatro ingredientes de la receta actual y paso siguiente.
var receta: Array[int] = []
var paso: int = 0
var recetas_completadas: int = 0
var aciertos: int = 0
var errores: int = 0
## Eventos del último avanzar(): {puntos: int, pos: Vector2, tipo: StringName}
## (ingrediente, receta o error). La vista los consume.
var ultimos_eventos: Array[Dictionary] = []

var _rng := RandomNumberGenerator.new()
var _espera_aparicion: float = 0.4


func _init(semilla: int = -1) -> void:
	if semilla >= 0:
		_rng.seed = semilla
	else:
		_rng.randomize()
	_nueva_receta()


func terminada() -> bool:
	return tiempo_restante <= 0.0


func ingrediente_necesario() -> int:
	return receta[paso]


func avanzar(delta: float, eje: float) -> void:
	ultimos_eventos.clear()
	if terminada():
		return
	tiempo_restante = maxf(tiempo_restante - delta, 0.0)
	var medio := CALDERO_ANCHO * 0.5
	caldero_x = clampf(caldero_x + eje * CALDERO_VELOCIDAD * delta, medio, ANCHO - medio)
	var progreso := 1.0 - tiempo_restante / DURACION
	_espera_aparicion -= delta
	if _espera_aparicion <= 0.0:
		_aparecer(progreso)
		_espera_aparicion = lerpf(INTERVALO_INICIAL, INTERVALO_FINAL, progreso)
	for objeto in objetos.duplicate():
		objeto.pos.y += objeto.velocidad * delta
		var dentro_x := absf(objeto.pos.x - caldero_x) <= medio + RADIO_OBJETO * 0.5
		if dentro_x and objeto.pos.y >= CALDERO_Y - RADIO_OBJETO and objeto.pos.y <= CALDERO_Y + 10.0:
			objetos.erase(objeto)
			echar(objeto.tipo, objeto.pos)
		elif objeto.pos.y > ALTO + RADIO_OBJETO:
			objetos.erase(objeto)


## Echa un ingrediente al caldero: suma si es el siguiente de la receta.
func echar(tipo: int, pos: Vector2) -> void:
	if tipo == receta[paso]:
		aciertos += 1
		paso += 1
		var puntos := PUNTOS_CORRECTO
		var evento := &"ingrediente"
		if paso >= receta.size():
			puntos += PUNTOS_RECETA
			recetas_completadas += 1
			evento = &"receta"
			_nueva_receta()
		_sumar(puntos, pos, evento)
	else:
		errores += 1
		_sumar(PUNTOS_ERROR, pos, &"error")


func _sumar(puntos: int, pos: Vector2, tipo: StringName) -> void:
	puntuacion += puntos
	ultimos_eventos.append({puntos = puntos, pos = pos, tipo = tipo})


func _nueva_receta() -> void:
	receta = [Ingrediente.CEBADA, Ingrediente.LUPULO, Ingrediente.AGUA, Ingrediente.LEVADURA]
	for i in range(receta.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var tmp := receta[i]
		receta[i] = receta[j]
		receta[j] = tmp
	paso = 0


func _aparecer(progreso: float) -> void:
	var tipo: int = receta[paso] if _rng.randf() < PROBABILIDAD_NECESARIO else _rng.randi_range(0, 3)
	var velocidad_max := lerpf(VELOCIDAD_MIN + 20.0, VELOCIDAD_MAX, progreso)
	objetos.append({
		tipo = tipo,
		pos = Vector2(_rng.randf_range(RADIO_OBJETO * 2.0, ANCHO - RADIO_OBJETO * 2.0), ALTURA_RECETA),
		velocidad = _rng.randf_range(VELOCIDAD_MIN, velocidad_max),
	})
