extends Node3D

const Estilo = preload("res://scripts/presentacion/estilo.gd")
## Punto de pesca en la orilla: muestra el aviso cuando el protagonista entra
## en la zona y, al pulsar `interactuar`, pausa el mundo y abre el minijuego.

const Oficios = preload("res://scripts/vida/oficios.gd")

var jugador_cerca: bool = false
var _pesca_activa := false

@onready var _zona: Area3D = $Zona
@onready var _aviso: Label3D = $Aviso
@onready var _minijuego: CanvasLayer = $MinijuegoPesca


func _ready() -> void:
	var texto := _aviso.text
	_aviso.text = Estilo.aviso_interaccion(texto)
	Ajustes.dispositivo_cambiado.connect(func(): _aviso.text = Estilo.aviso_interaccion(texto))
	Ajustes.cambiado.connect(func(): _aviso.text = Estilo.aviso_interaccion(texto))
	_aviso.visible = false
	_zona.body_entered.connect(_al_entrar)
	_zona.body_exited.connect(_al_salir)
	_minijuego.cerrado.connect(_al_cerrar_minijuego)
	_minijuego.partida_terminada.connect(_al_terminar)


func _process(_delta: float) -> void:
	# Con el arbol en pausa este nodo no se procesa, asi que no reabre el panel.
	if jugador_cerca and Input.is_action_just_pressed("interactuar"):
		if InterfazVida.interaccion_mundo_consumida():
			return
		abrir_minijuego()


func abrir_minijuego() -> void:
	if not Oficios.pendientes().is_empty():
		InterfazVida.avisar(Oficios.recoger_pesca())
		return
	if Oficios.Bolsa.cantidad(Oficios.Bolsa.jugador(), "cana") == 0:
		InterfazVida.avisar("Necesitas una caña. Se vende en el Mercado.")
		return
	_aviso.visible = false
	get_tree().paused = true
	_pesca_activa = true
	_minijuego.abrir()


func _al_terminar(puntos: int) -> void:
	if not _pesca_activa:
		return
	_pesca_activa = false
	_minijuego.mostrar_captura(Oficios.capturar(puntos))


func _al_cerrar_minijuego() -> void:
	_pesca_activa = false
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
