class_name ReproductorSonidos
extends Node
## Efectos de sonido de un panel de minijuego. Cada nombre se asocia a una o
## varias rutas de audio; al reproducir se elige una variante al azar con un
## ligero cambio de tono. Varios canales permiten solapar efectos. Hereda el
## process_mode del panel, así que suena con el árbol en pausa.

const CANALES: int = 4
const VOLUMEN_DB: float = -6.0
const VARIACION_TONO: float = 0.06

## nombre -> Array de rutas res:// de audio.
var sonidos: Dictionary = {}
## Último sonido reproducido; lo consultan las pruebas.
var ultimo: StringName = &""

var _canales: Array[AudioStreamPlayer] = []
var _siguiente: int = 0
var _cache: Dictionary = {}


func _ready() -> void:
	for i in CANALES:
		var canal := AudioStreamPlayer.new()
		canal.volume_db = VOLUMEN_DB
		add_child(canal)
		_canales.append(canal)


func reproducir(nombre: StringName) -> void:
	if not sonidos.has(nombre):
		return
	var rutas: Array = sonidos[nombre]
	if rutas.is_empty():
		return
	var ruta: String = rutas[randi() % rutas.size()]
	if not _cache.has(ruta):
		_cache[ruta] = load(ruta)
	var canal := _canales[_siguiente]
	_siguiente = (_siguiente + 1) % _canales.size()
	canal.stream = _cache[ruta]
	canal.pitch_scale = 1.0 + randf_range(-VARIACION_TONO, VARIACION_TONO)
	canal.play()
	ultimo = nombre
