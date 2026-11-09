extends Node3D
## Punto de pesca en la orilla: muestra el aviso cuando el protagonista entra
## en la zona y, al pulsar `interactuar`, pausa el mundo y abre el minijuego.

var jugador_cerca: bool = false

@onready var _zona: Area3D = $Zona
@onready var _aviso: Label3D = $Aviso
@onready var _minijuego: CanvasLayer = $MinijuegoPesca


func _ready() -> void:
	_aviso.visible = false
	_zona.body_entered.connect(_al_entrar)
	_zona.body_exited.connect(_al_salir)
	_minijuego.cerrado.connect(_al_cerrar_minijuego)


func _process(_delta: float) -> void:
	# Con el arbol en pausa este nodo no se procesa, asi que no reabre el panel.
	if jugador_cerca and Input.is_action_just_pressed("interactuar"):
		abrir_minijuego()


func abrir_minijuego() -> void:
	_aviso.visible = false
	get_tree().paused = true
	_minijuego.abrir()


func _al_cerrar_minijuego() -> void:
	get_tree().paused = false
	_aviso.visible = jugador_cerca


# El protagonista es el unico CharacterBody3D del mundo.
func _al_entrar(cuerpo: Node3D) -> void:
	if cuerpo is CharacterBody3D:
		jugador_cerca = true
		_aviso.visible = true


func _al_salir(cuerpo: Node3D) -> void:
	if cuerpo is CharacterBody3D:
		jugador_cerca = false
		_aviso.visible = false
