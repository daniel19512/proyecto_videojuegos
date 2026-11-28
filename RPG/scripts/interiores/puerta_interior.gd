extends Area3D

const Estilo = preload("res://scripts/presentacion/estilo.gd")
## Interacción explícita reutilizable; solo acepta el jugador de la región actual.
@export_file("*.tscn") var escena_destino: String
@export var entrada_destino: String
@export var texto := "[F] Entrar a la taberna"
@onready var aviso: Label3D = $Aviso
var habilitada := false

func _process(_delta: float) -> void:
	var escena := get_tree().current_scene
	var config := escena.get_node_or_null("Region") if is_instance_valid(escena) else null
	var jugador: Node3D = config.get_node_or_null(config.jugador) if config else null
	var gestor := get_node("/root/GestorRegiones")
	habilitada = is_instance_valid(jugador) and overlaps_body(jugador) and not gestor.en_transicion and not get_tree().paused
	if habilitada:
		aviso.text = Estilo.aviso_interaccion(texto)
	aviso.visible = habilitada

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interactuar") and not event.is_echo() and habilitada:
		if get_node("/root/GestorRegiones").solicitar(escena_destino, entrada_destino):
			habilitada = false
			aviso.hide()
			get_viewport().set_input_as_handled()
