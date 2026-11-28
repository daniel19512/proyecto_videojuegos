extends Node3D
## Aldeano reutilizable: sprite propio, aviso «[F] Hablar» y caja de diálogo.
## Las líneas salen de un recado conectado (si tiene algo que decir) o de las
## líneas fijas exportadas. Al hablar pausa el mundo, como el pescador.
## La mirada se guarda en el mundo y se traduce a arriba/abajo/izquierda/derecha
## según la cámara, para que el sprite siga coherente al girarla.
## Ejecuta rutas de Aldeanos y se detiene al acercarse el viajero.
## Los habituales conservan la solidez del puesto. Los habitantes regionales
## comprueban suelo y obstáculos al caminar.

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
const TIENDAS_NPC := {&"panadera": "panaderia", &"herrero": "herreria", &"samuel": "semillas"}

var hablando: bool = false
## Mientras charla con otro aldeano (capa 3) no camina.
var conversando: bool = false
var conversaciones: int = 0
var regional := false
var orden_regional: Array = []
var replanificar_regional := false
var _bloqueado := 0.0
var _lado_cedido := 0.0
## Posición inicial en la escena: su puesto de trabajo y su casa.
var puesto: Vector3
## Última posición conocida (al salir del árbol ya no hay transformación global).
var ultima_posicion: Vector3
var _ruta: PackedVector3Array = []
var _paso: int = 0
var _caminando: bool = false
var _recalcular: float = 0.0

var _recado: Node
var _jugador: Node3D

@onready var _sprite: AnimatedSprite3D = $Visual/SpriteAnimado
@onready var _zona: Area3D = $Zona
@onready var _aviso: Label3D = $Aviso
@onready var _caja: CanvasLayer = $CajaDialogo


func _ready() -> void:
	conversaciones = int(EstadoMundo.objeto("Aldea", "npc_" + String(id_npc)).get("conversaciones", 0))
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
	puesto = global_position
	ultima_posicion = puesto
	if not id_npc.is_empty():
		Aldeanos.registrar(self)
		Misiones.actualizado.connect(_refrescar_aviso)
	Ajustes.dispositivo_cambiado.connect(_refrescar_aviso)
	Ajustes.cambiado.connect(_refrescar_aviso)


func _exit_tree() -> void:
	if not id_npc.is_empty():
		Aldeanos.baja(self)


func _process(_delta: float) -> void:
	# La cámara puede girar: recalcular la dirección en pantalla cada fotograma.
	actualizar_animacion(esta_caminando())
	# Con el árbol en pausa este nodo no se procesa, así que no reabre la caja.
	if jugador_cerca and Input.is_action_just_pressed("interactuar"):
		if InterfazVida.interaccion_mundo_consumida():
			return
		Aldeanos.interrumpir_charla(id_npc)
		if Historia.tiene_npc(id_npc):
			Misiones.abrir(id_npc, hablar, hablar.bind(true), TIENDAS_NPC.get(id_npc, ""))
		else:
			hablar()


func _unhandled_input(evento: InputEvent) -> void:
	if not jugador_cerca or hablando or conversando or GestorRegiones.en_transicion:
		return
	var tienda: String = TIENDAS_NPC.get(id_npc, "")
	if not tienda.is_empty() and evento.is_action_pressed("comerciar_npc"):
		InterfazVida.abrir("tienda", tienda)
		get_viewport().set_input_as_handled()


func esta_caminando() -> bool:
	return _caminando


func orden() -> Dictionary:
	return Aldeanos.estado_de(id_npc)


## Calcula la ruta hacia el destino de la orden actual (la llama Aldeanos).
func ejecutar() -> void:
	_ruta = PackedVector3Array()
	_paso = 0
	var estado := orden()
	if estado.llegado:
		_refrescar_aviso()
		return
	var destino := Aldeanos.destino(id_npc)
	_ruta = Aldeanos.ruta(global_position, destino, Aldeanos.obstaculos_personales(self, destino))
	if _ruta.is_empty():
		Aldeanos.llegada(id_npc)
	_refrescar_aviso()


func _physics_process(delta: float) -> void:
	_caminando = false
	ultima_posicion = global_position
	if hablando or conversando or GestorRegiones.en_transicion:
		return
	if regional:
		if jugador_cerca:
			_ceder_al_jugador(delta)
		elif not _ruta.is_empty():
			_lado_cedido = 0.0
			_avanzar_regional(delta)
		return
	var estado := orden()
	if estado.llegado or _ruta.is_empty():
		_actualizar_solidez()
		return
	if jugador_cerca:
		if estado.accion == "buscar_jugador":
			_llegar()
		return
	if estado.accion in ["hablar_con", "buscar_jugador"]:
		var objetivo := Aldeanos.destino(id_npc)
		if _plano(objetivo - global_position).length() <= Aldeanos.DISTANCIA_ENCUENTRO:
			mirar_a(objetivo)
			_llegar()
			return
		# El objetivo se mueve: se recalcula la ruta de vez en cuando.
		_recalcular -= delta
		if _recalcular <= 0.0:
			_recalcular = 1.5
			_ruta = Aldeanos.ruta(global_position, objetivo, Aldeanos.obstaculos_personales(self, objetivo))
			_paso = 0
			if _ruta.is_empty():
				return
	_avanzar(delta)


func ruta_regional(puntos: PackedVector3Array) -> void:
	_ruta = puntos
	_paso = 0
	_bloqueado = 0.0
	replanificar_regional = false


func ruta_regional_acabada() -> bool:
	return _ruta.is_empty()


func _avanzar_regional(delta: float) -> void:
	var objetivo := _ruta[_paso]
	var cambio := _plano(objetivo - global_position)
	var siguiente := global_position + cambio.limit_length(Aldeanos.velocidad * delta)
	if _pisar(siguiente):
		if cambio.length_squared() > 0.0001:
			mirada = cambio.normalized()
			_caminando = true
		if _plano(objetivo - siguiente).length_squared() < 0.0001:
			_paso += 1
			if _paso >= _ruta.size():
				_ruta.clear()
		_bloqueado = 0.0
		return
	_bloqueado += delta
	if _bloqueado > 2.0:
		_ruta.clear()
		replanificar_regional = true


func _ceder_al_jugador(delta: float) -> void:
	if not is_instance_valid(_jugador):
		return
	var separacion := _plano(global_position - _jugador.global_position)
	var rumbo := separacion.normalized()
	if separacion.length_squared() > 1.22 * 1.22 or _jugador.intencion_horizontal.dot(rumbo) < 0.55:
		_lado_cedido = 0.0
		return
	var lado := rumbo.cross(Vector3.UP)
	var primero := _lado_cedido if _lado_cedido != 0.0 else 1.0
	for signo: float in [primero, -primero]:
		var paso := (lado * signo + rumbo * 0.3).normalized()
		if _pisar(global_position + paso * Aldeanos.velocidad * delta):
			_lado_cedido = signo
			_caminando = true
			mirada = paso
			replanificar_regional = true
			return


func _pisar(siguiente: Vector3) -> bool:
	var cuerpo := $Cuerpo as StaticBody3D
	var rayo := PhysicsRayQueryParameters3D.create(siguiente + Vector3.UP * 0.65,
		siguiente - Vector3.UP * 0.6, 1, [cuerpo.get_rid()])
	var suelo := get_world_3d().direct_space_state.intersect_ray(rayo)
	if suelo.is_empty() or suelo.normal.y <= 0.75:
		return false
	siguiente.y = suelo.position.y
	if not _paso_libre(siguiente):
		return false
	global_position = siguiente
	return true


func _paso_libre(siguiente: Vector3) -> bool:
	if _ocupa_persona(siguiente):
		return false
	var cuerpo := $Cuerpo as StaticBody3D
	var forma := $Cuerpo/Colision as CollisionShape3D
	var consulta := PhysicsShapeQueryParameters3D.new()
	consulta.shape = forma.shape
	consulta.exclude = [cuerpo.get_rid()]
	consulta.transform.origin = siguiente + Vector3.UP * (forma.position.y + 0.16)
	consulta.collision_mask = 1
	return get_world_3d().direct_space_state.intersect_shape(consulta, 1).is_empty()


func _ocupa_persona(siguiente: Vector3) -> bool:
	var escena := get_tree().current_scene
	var jugador := escena.get_node_or_null("Jugador") as Node3D if escena else null
	if jugador and _acerca_demasiado(jugador.global_position, siguiente):
		return true
	for otro in Aldeanos.nodos.values():
		if otro != self and _acerca_demasiado(otro.global_position, siguiente):
			return true
	return false


func _acerca_demasiado(otra: Vector3, siguiente: Vector3) -> bool:
	if absf(otra.y - siguiente.y) > 1.6:
		return false
	var distancia := _plano(otra - siguiente).length_squared()
	return distancia < 0.95 * 0.95 and distancia < _plano(otra - global_position).length_squared()


func _avanzar(delta: float) -> void:
	var paso := Aldeanos.velocidad * delta
	while paso > 0.0 and _paso < _ruta.size():
		var hacia := _ruta[_paso] - global_position
		var plano := _plano(hacia)
		var siguiente := global_position + plano.limit_length(paso)
		if _ocupa_persona(siguiente):
			_bloqueado += delta
			if _bloqueado > 2.0:
				_bloqueado = 0.0
				ejecutar()
			return
		_bloqueado = 0.0
		if plano.length() <= paso:
			global_position = _ruta[_paso]
			paso -= plano.length()
			_paso += 1
		else:
			mirada = plano.normalized()
			global_position += mirada * paso
			global_position.y = Aldeanos.altura(global_position)
			paso = 0.0
	_caminando = true
	_actualizar_solidez()
	if _paso >= _ruta.size():
		_llegar()


func _llegar() -> void:
	_ruta = PackedVector3Array()
	_caminando = false
	Aldeanos.llegada(id_npc)
	_actualizar_solidez()
	_refrescar_aviso()


## Sólido solo en su puesto: en camino podría encerrar al viajero o tapar un paso.
func _actualizar_solidez() -> void:
	var forma := get_node_or_null("Cuerpo/Colision") as CollisionShape3D
	if forma:
		var en_puesto := _plano(global_position - puesto).length() < 0.3
		if forma.disabled == en_puesto:
			forma.set_deferred("disabled", not en_puesto)


func mirar_a(punto: Vector3) -> void:
	var hacia := _plano(punto - global_position)
	if hacia.length() > 0.01:
		mirada = hacia.normalized()


func _plano(v: Vector3) -> Vector3:
	return Vector3(v.x, 0.0, v.z)


## Muestra `texto` en un bocadillo sobre la cabeza durante `segundos` (el
## temporizador se para con el árbol en pausa) y lo oculta al terminar.
func decir(texto: String, segundos: float) -> void:
	var bocadillo := _bocadillo()
	bocadillo.text = texto
	bocadillo.visible = true
	_aviso.visible = false
	# Fondo a la medida del texto (alineado abajo: crece desde el origen hacia
	# arriba). El desplazamiento va dentro de la malla para girar con el
	# billboard, igual que los glifos de la etiqueta.
	var fuente: Font = bocadillo.font if bocadillo.font else ThemeDB.fallback_font
	var medida := fuente.get_multiline_string_size(texto, HORIZONTAL_ALIGNMENT_CENTER, bocadillo.width, bocadillo.font_size) * bocadillo.pixel_size
	var quad := (bocadillo.get_node("Fondo") as MeshInstance3D).mesh as QuadMesh
	quad.size = medida + Vector2(0.16, 0.1)
	quad.center_offset = Vector3(0, medida.y * 0.5, -0.01)
	await get_tree().create_timer(segundos, false).timeout
	if is_instance_valid(bocadillo):
		bocadillo.visible = false
		_refrescar_aviso()


func _bocadillo() -> Label3D:
	var bocadillo := get_node_or_null("Bocadillo") as Label3D
	if bocadillo:
		return bocadillo
	bocadillo = Label3D.new()
	bocadillo.name = "Bocadillo"
	bocadillo.position = Vector3(0, 2.15, 0)
	bocadillo.pixel_size = 0.0075
	bocadillo.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	bocadillo.no_depth_test = true
	bocadillo.font_size = 36
	bocadillo.outline_size = 14
	bocadillo.modulate = Color(1, 1, 0.94)
	bocadillo.outline_modulate = Color(0.12, 0.08, 0.04)
	bocadillo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bocadillo.width = 420
	bocadillo.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	bocadillo.render_priority = 2
	bocadillo.outline_render_priority = 1
	bocadillo.visible = false
	# Fondo oscuro semitransparente para leerlo sobre fachadas y carteles.
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(0.08, 0.05, 0.03, 0.72)
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.no_depth_test = true
	material.render_priority = 0
	var fondo := MeshInstance3D.new()
	fondo.name = "Fondo"
	fondo.mesh = QuadMesh.new()
	fondo.material_override = material
	fondo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	bocadillo.add_child(fondo)
	add_child(bocadillo)
	return bocadillo


func hablando_en_bocadillo() -> bool:
	var bocadillo := get_node_or_null("Bocadillo") as Label3D
	return bocadillo != null and bocadillo.visible


func ocultar_bocadillo() -> void:
	var bocadillo := get_node_or_null("Bocadillo") as Label3D
	if bocadillo:
		bocadillo.hide()
	conversando = false
	_refrescar_aviso()


## «!» sobre la cabeza cuando ha llegado buscando al viajero.
func _refrescar_aviso() -> void:
	var esperando: bool = not regional and Aldeanos.activo() and orden().accion == "buscar_jugador" and orden().llegado
	var invitacion := "[%s] Hablar" % Ajustes.indicacion("interactuar")
	_aviso.text = invitacion if jugador_cerca or not esperando else "¡!"
	if jugador_cerca and Misiones.tiene_aviso(id_npc):
		_aviso.text += " · Encargo"
	if jugador_cerca and TIENDAS_NPC.has(id_npc):
		_aviso.text += "  [%s] Tienda" % Ajustes.indicacion("comerciar_npc")
	_aviso.visible = ((jugador_cerca and not hablando) or esperando) and not conversando


func hablar(fijo: bool = false) -> void:
	if is_instance_valid(_jugador):
		var hacia := _jugador.global_position - global_position
		hacia.y = 0
		if hacia.length() > 0.01:
			mirada = hacia.normalized()
	actualizar_animacion(false)
	_aviso.visible = false
	hablando = true
	get_tree().paused = true
	# Con IA disponible conversa el modelo; si su primera respuesta falla, lo fijo.
	if not fijo and not _presenta_la_casa() and IA.disponible() and Historia.tiene_npc(id_npc):
		var exito := await DialogoIA.conversar(id_npc, nombre)
		if exito:
			_recordar_conversacion()
		if exito or DialogoIA.cancelada:
			_al_cerrar_dialogo()
			return
	_caja.mostrar(nombre, lineas_dialogo(), frames.get_frame_texture(&"idle_abajo", 0) if frames else null)
	_recordar_conversacion()


func _recordar_conversacion() -> void:
	Misiones.conversar(id_npc)
	conversaciones += 1
	EstadoMundo.objeto("Aldea", "npc_" + String(id_npc)).conversaciones = conversaciones


func _presenta_la_casa() -> bool:
	return id_npc == &"guardia" and conversaciones == 0 and Partidas.espacio > 0


func lineas_dialogo() -> PackedStringArray:
	if _presenta_la_casa():
		return PackedStringArray([
			"¡Bienvenido a la Aldea, %s! La casa al noroeste de la plaza es tuya." % EstadoMundo.nombre_protagonista(),
			"Puedes guardar tus cosas en el cofre y dormir hasta las seis de la mañana. El mapa te indica dónde está.",
		])
	if _recado:
		var del_recado: PackedStringArray = _recado.lineas_para(id_npc)
		if not del_recado.is_empty():
			return del_recado
	if conversaciones == 0 and not lineas_primera_visita.is_empty():
		if regional:
			var bienvenida := lineas_primera_visita.duplicate()
			bienvenida[0] = "Mucho gusto, %s. %s" % [EstadoMundo.nombre_protagonista(), bienvenida[0]]
			return bienvenida
		return lineas_primera_visita
	var saludo := Misiones.saludo(id_npc)
	if not saludo.is_empty():
		var lineas := PackedStringArray([saludo])
		lineas.append_array(lineas_habituales)
		return lineas
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
	Aldeanos.cumplido(id_npc)
	_refrescar_aviso()
	conversacion_terminada.emit()


func _al_entrar(cuerpo: Node3D) -> void:
	if cuerpo is CharacterBody3D:
		_jugador = cuerpo
		jugador_cerca = true
		_refrescar_aviso()


func _al_salir(cuerpo: Node3D) -> void:
	if cuerpo is CharacterBody3D:
		jugador_cerca = false
		_refrescar_aviso()
