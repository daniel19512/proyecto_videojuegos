extends "res://scripts/npc/npc_aldeano.gd"
## Aldeano que recorre en bucle una lista de puntos del mundo. Se detiene
## mientras el jugador está en su zona de conversación y lo mira; hace una
## pausa breve en cada punto. Se mueve de forma cinemática, sin física, sobre
## una ruta que debe ir por suelo libre (los corredores de la aldea).

## Puntos del recorrido en coordenadas del mundo (Y se conserva la del NPC).
@export var puntos: PackedVector3Array = []
@export var velocidad: float = 1.6
@export var espera_en_punto: float = 1.5

var indice_destino: int = 0
var _espera: float = 0.0
var _caminando: bool = false


func _physics_process(delta: float) -> void:
	_caminando = false
	if puntos.is_empty() or hablando:
		return
	if jugador_cerca:
		if is_instance_valid(_jugador):
			var hacia := _jugador.global_position - global_position
			hacia.y = 0
			if hacia.length() > 0.01:
				mirada = hacia.normalized()
		return
	if _espera > 0.0:
		_espera -= delta
		return
	var destino := puntos[indice_destino]
	destino.y = global_position.y
	var resto := destino - global_position
	var paso := velocidad * delta
	if resto.length() <= paso:
		global_position = destino
		indice_destino = (indice_destino + 1) % puntos.size()
		_espera = espera_en_punto
		return
	mirada = resto.normalized()
	global_position += mirada * paso
	_caminando = true


func esta_caminando() -> bool:
	return _caminando
