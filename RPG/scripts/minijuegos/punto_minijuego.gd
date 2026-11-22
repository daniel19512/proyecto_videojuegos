extends Node3D
## Punto de interacción para un minijuego de oficio, con el mismo patrón que
## el punto de pesca: aviso con el protagonista dentro de la zona y, al pulsar
## `interactuar`, pausa el mundo y abre el panel instanciado como hijo.

## Escena del panel (hereda de panel_minijuego.tscn).
@export var escena_minijuego: PackedScene
@export var texto_aviso: String = "[F] Jugar"

var jugador_cerca: bool = false
var minijuego: MinijuegoBase

@onready var _zona: Area3D = $Zona
@onready var _aviso: Label3D = $Aviso


func _ready() -> void:
	_aviso.text = texto_aviso
	_aviso.visible = false
	minijuego = escena_minijuego.instantiate()
	add_child(minijuego)
	_zona.body_entered.connect(_al_entrar)
	_zona.body_exited.connect(_al_salir)
	minijuego.cerrado.connect(_al_cerrar_minijuego)


func _process(_delta: float) -> void:
	# Con el árbol en pausa este nodo no se procesa, así que no reabre el panel.
	if jugador_cerca and Input.is_action_just_pressed("interactuar"):
		abrir_minijuego()


func abrir_minijuego() -> void:
	_aviso.visible = false
	get_tree().paused = true
	minijuego.abrir()


func _al_cerrar_minijuego() -> void:
	get_tree().paused = false
	_aviso.visible = jugador_cerca


# El protagonista es el único CharacterBody3D de cada escena.
func _al_entrar(cuerpo: Node3D) -> void:
	if cuerpo is CharacterBody3D:
		jugador_cerca = true
		_aviso.visible = true


func _al_salir(cuerpo: Node3D) -> void:
	if cuerpo is CharacterBody3D:
		jugador_cerca = false
		_aviso.visible = false
