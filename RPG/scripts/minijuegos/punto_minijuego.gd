extends Node3D

const Estilo = preload("res://scripts/presentacion/estilo.gd")
## La estación selecciona la receta y liquida una sola vez cada resultado.

const Oficios = preload("res://scripts/vida/oficios.gd")

@export var escena_minijuego: PackedScene
@export var texto_aviso: String = "[F/A] Trabajar"
@export var estacion: String

var jugador_cerca := false
var minijuego: MinijuegoBase
var _receta := ""

@onready var _zona: Area3D = $Zona
@onready var _aviso: Label3D = $Aviso


func _ready() -> void:
	_aviso.text = Estilo.aviso_interaccion(texto_aviso)
	Ajustes.dispositivo_cambiado.connect(func(): _aviso.text = Estilo.aviso_interaccion(texto_aviso))
	Ajustes.cambiado.connect(func(): _aviso.text = Estilo.aviso_interaccion(texto_aviso))
	_aviso.visible = false
	minijuego = escena_minijuego.instantiate()
	add_child(minijuego)
	_zona.body_entered.connect(_al_entrar)
	_zona.body_exited.connect(_al_salir)
	minijuego.cerrado.connect(_al_cerrar_minijuego)
	minijuego.partida_terminada.connect(_al_terminar)


func _process(_delta: float) -> void:
	if jugador_cerca and Input.is_action_just_pressed("interactuar"):
		if not InterfazVida.interaccion_mundo_consumida() and not GestorRegiones.en_transicion:
			abrir_minijuego()


func abrir_minijuego() -> void:
	InterfazVida.abrir_estacion(estacion, _iniciar)


func _iniciar(id: String) -> void:
	var error := Oficios.requisitos(id, estacion, Oficios.Bolsa.jugador().duplicate(true))
	if not error.is_empty():
		InterfazVida.avisar(error)
		return
	_receta = id
	_aviso.hide()
	get_tree().paused = true
	minijuego.abrir()


func _al_terminar(puntos: int) -> void:
	if _receta.is_empty():
		return
	var id := _receta
	_receta = ""
	var completadas := puntos
	match estacion:
		"panaderia":
			completadas = minijuego.logica.doradas
		"herreria":
			completadas = minijuego.logica.piezas
		"cerveza":
			completadas = minijuego.logica.recetas_completadas
	minijuego.mostrar_resultado_oficio(Oficios.producir(id, estacion, completadas))


func _al_cerrar_minijuego() -> void:
	_receta = ""
	get_tree().paused = false
	_aviso.visible = jugador_cerca


func _al_entrar(cuerpo: Node3D) -> void:
	if cuerpo is CharacterBody3D:
		jugador_cerca = true
		_aviso.visible = true


func _al_salir(cuerpo: Node3D) -> void:
	if cuerpo is CharacterBody3D:
		jugador_cerca = false
		_aviso.visible = false
