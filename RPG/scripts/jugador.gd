extends CharacterBody3D

const Apariencias = preload("res://scripts/npc/apariencias.gd")

# Velocidad temporal para pruebas de exploracion (base original: 4.0).
@export_range(0.1, 20.0, 0.1) var velocidad: float = 10.0
@export_range(0.1, 100.0, 0.1) var aceleracion: float = 18.0
@export_range(0.1, 100.0, 0.1) var desaceleracion: float = 24.0

# Direccion relativa a la pantalla para las animaciones de cuatro orientaciones.
var direccion_visual: StringName = &"abajo"
var en_movimiento: bool = false
var intencion_horizontal := Vector3.ZERO

@onready var sprite: AnimatedSprite3D = $Visual/SpriteAnimado


func _ready() -> void:
	# Las muestras y respaldos conservan su presentación original.
	if get_parent().has_node("Region"):
		EstadoMundo.apariencia_cambiada.connect(aplicar_apariencia)
		aplicar_apariencia(EstadoMundo.apariencia_protagonista())


func aplicar_apariencia(id: String) -> void:
	if not Apariencias.JUGADOR.has(id):
		return
	var visual := Apariencias.ficha(Apariencias.JUGADOR[id][1])
	if visual.is_empty():
		return
	sprite.sprite_frames = visual.frames
	sprite.pixel_size = visual.escala
	sprite.offset = visual.offset
	Apariencias.colocar_sombra(self)
	_actualizar_animacion()


func _physics_process(delta: float) -> void:
	var entrada: Vector2 = Input.get_vector(
		"mover_izquierda", "mover_derecha", "mover_arriba", "mover_abajo"
	)
	var derecha: Vector3 = Vector3.RIGHT
	var atras: Vector3 = Vector3.BACK
	var camara: Camera3D = get_viewport().get_camera_3d()
	if is_instance_valid(camara):
		derecha = camara.global_basis.x
		derecha.y = 0.0
		derecha = derecha.normalized()
		atras = camara.global_basis.z
		atras.y = 0.0
		atras = atras.normalized()

	var direccion: Vector3 = derecha * entrada.x + atras * entrada.y
	intencion_horizontal = direccion.normalized()
	var ritmo: float = Ajustes.VELOCIDADES.get(Ajustes.valores.velocidad, Ajustes.VELOCIDADES.normal) if Partidas.espacio > 0 else velocidad
	var objetivo: Vector3 = direccion * ritmo
	var cambio: float = aceleracion if not entrada.is_zero_approx() else desaceleracion
	var horizontal: Vector3 = Vector3(velocity.x, 0.0, velocity.z)
	horizontal = horizontal.move_toward(objetivo, cambio * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z

	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0.0

	velocity = Aldeanos.separar_jugador(global_position, velocity * delta) / delta
	move_and_slide()
	en_movimiento = Vector2(velocity.x, velocity.z).length() > 0.05
	if not entrada.is_zero_approx():
		_actualizar_direccion_visual(entrada)
	_actualizar_animacion()


func _actualizar_direccion_visual(entrada: Vector2) -> void:
	if absf(entrada.x) > absf(entrada.y):
		direccion_visual = &"derecha" if entrada.x > 0.0 else &"izquierda"
	else:
		direccion_visual = &"abajo" if entrada.y > 0.0 else &"arriba"


func _actualizar_animacion() -> void:
	var estado: String = "walk" if en_movimiento else "idle"
	var animacion: StringName = StringName(estado + "_" + String(direccion_visual))
	if sprite.animation != animacion or not sprite.is_playing():
		sprite.play(animacion)
