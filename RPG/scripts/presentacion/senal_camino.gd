@tool
extends Node3D

@export var destino := "":
	set(valor):
		destino = valor
		if is_node_ready():
			_actualizar()

func _ready() -> void:
	_actualizar()

func _actualizar() -> void:
	$Frente.text = destino
	$Reverso.text = destino
