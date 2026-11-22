extends Node3D
## Aldeano reutilizable: sprite propio, aviso «[F] Hablar» y caja de diálogo.
## Las líneas salen de un recado conectado (si tiene algo que decir) o de las
## líneas fijas exportadas. Al hablar pausa el mundo, como el pescador.
## La mirada se guarda en el mundo y se traduce a arriba/abajo/izquierda/derecha
## según la cámara, para que el sprite siga coherente al girarla.

signal conversacion_terminada

@export var id_npc: StringName = &""
@export var nombre: String = "Aldeano"
@export var frames: SpriteFrames
## Escala del sprite para igualar la altura del protagonista de frente (33 px a
## 0.045 en idle_abajo): tamano_pixel = 0.045 * 33 / altura visible del NPC de frente.
@export var tamano_pixel: float = 0.045
## Desplazamiento en píxeles para apoyar los pies a la altura de los del
## protagonista (0.09 u): 24 - (48 - fila inferior de los pies) + 0.09 / tamano_pixel.
@export var desplazamiento: Vector2 = Vector2(0, 19)
## Dirección del mundo hacia la que mira cuando está quieto (Y se ignora).
@export var mirada: Vector3 = Vector3(0, 0, 1)
@export var lineas_primera_visita: PackedStringArray = []
@export var lineas_habituales: PackedStringArray = []
## Recado compartido entre NPCs (por ejemplo `RecadoPan`); opcional.
@export var recado: NodePath
## Sin cuerpo sólido el NPC no bloquea caminos (lo usa el guardia que patrulla).
@export var solido: bool = true

var jugador_cerca: bool = false
var hablando: bool = false
var conversaciones: int = 0

var _recado: Node
var _jugador: Node3D

@onready var _sprite: AnimatedSprite3D = $Visual/SpriteAnimado
@onready var _zona: Area3D = $Zona
@onready var _aviso: Label3D = $Aviso
@onready var _caja: CanvasLayer = $CajaDialogo


func _ready() -> void:
	if frames:
		_sprite.sprite_frames = frames
	_sprite.pixel_size = tamano_pixel
	_sprite.offset = desplazamiento
	if not solido:
		var cuerpo := get_node("Cuerpo")
		remove_child(cuerpo)
		cuerpo.free()
	if not recado.is_empty():
		_recado = get_node(recado)
	_aviso.visible = false
	_zona.body_entered.connect(_al_entrar)
	_zona.body_exited.connect(_al_salir)
	_caja.cerrado.connect(_al_cerrar_dialogo)
	actualizar_animacion(false)


func _process(_delta: float) -> void:
	# La cámara puede girar: recalcular la dirección en pantalla cada fotograma.
	actualizar_animacion(esta_caminando())
	# Con el árbol en pausa este nodo no se procesa, así que no reabre la caja.
	if jugador_cerca and Input.is_action_just_pressed("interactuar"):
		hablar()


## Las subclases que se desplazan (patrulla) devuelven true mientras caminan.
func esta_caminando() -> bool:
	return false


func hablar() -> void:
	if is_instance_valid(_jugador):
		var hacia := _jugador.global_position - global_position
		hacia.y = 0
		if hacia.length() > 0.01:
			mirada = hacia.normalized()
	actualizar_animacion(false)
	_aviso.visible = false
	hablando = true
	get_tree().paused = true
	_caja.mostrar(nombre, lineas_dialogo())
	conversaciones += 1


func lineas_dialogo() -> PackedStringArray:
	if _recado:
		var del_recado: PackedStringArray = _recado.lineas_para(id_npc)
		if not del_recado.is_empty():
			return del_recado
	if conversaciones == 0 and not lineas_primera_visita.is_empty():
		return lineas_primera_visita
	return lineas_habituales


## Elige idle_/walk_ + dirección en pantalla a partir de la mirada en el mundo.
func actualizar_animacion(caminando: bool) -> void:
	var animacion := ("walk_" if caminando else "idle_") + direccion_en_pantalla(mirada)
	if _sprite.animation != animacion or not _sprite.is_playing():
		_sprite.play(animacion)


func direccion_en_pantalla(direccion: Vector3) -> String:
	var camara := get_viewport().get_camera_3d()
	var local := direccion
	if camara:
		local = camara.global_basis.inverse() * direccion
	# La cámara mira hacia -Z local: +Z local es hacia el espectador (abajo).
	if absf(local.x) > absf(local.z):
		return "derecha" if local.x > 0 else "izquierda"
	return "abajo" if local.z > 0 else "arriba"


func _al_cerrar_dialogo() -> void:
	hablando = false
	get_tree().paused = false
	_aviso.visible = jugador_cerca
	conversacion_terminada.emit()


func _al_entrar(cuerpo: Node3D) -> void:
	if cuerpo is CharacterBody3D:
		_jugador = cuerpo
		jugador_cerca = true
		_aviso.visible = true


func _al_salir(cuerpo: Node3D) -> void:
	if cuerpo is CharacterBody3D:
		jugador_cerca = false
		_aviso.visible = false
