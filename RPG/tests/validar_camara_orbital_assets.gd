extends SceneTree
## Godot --headless --path RPG --script res://tests/validar_camara_orbital_assets.gd
var fallos := 0
var escena: Node3D
var camara: Camera3D
var jugador: CharacterBody3D

# Punto de extension explicito: la entrada del mundo sobrescribe este selector.
func probar_mundo() -> bool:
	return "--mundo" in OS.get_cmdline_user_args()

func _initialize() -> void:
	call_deferred("validar")

func comprobar(valor: bool, mensaje: String) -> void:
	if valor:
		print("OK: ", mensaje)
	else:
		fallos += 1
		push_error("FALLO: " + mensaje)

func esperar(n: int) -> void:
	for i in n:
		await physics_frame
	await process_frame

func tecla(codigo: Key, pulsada: bool) -> void:
	var evento := InputEventKey.new()
	evento.physical_keycode = codigo
	evento.pressed = pulsada
	Input.parse_input_event(evento)
	Input.flush_buffered_events()

func stick(eje: JoyAxis, valor: float) -> void:
	var evento := InputEventJoypadMotion.new()
	evento.device = 0
	evento.axis = eje
	evento.axis_value = valor
	Input.parse_input_event(evento)
	Input.flush_buffered_events()

func firma_movimiento() -> Array[String]:
	var resultado: Array[String] = []
	for accion in ["mover_izquierda", "mover_derecha", "mover_arriba", "mover_abajo"]:
		resultado.append(str(InputMap.action_get_deadzone(accion)))
		for evento in InputMap.action_get_events(accion):
			resultado.append(evento.as_text())
	return resultado

func validar() -> void:
	print("VERSION: ", Engine.get_version_info().string)
	var original := firma_movimiento()
	escena = load("res://scenes/mundo.tscn" if probar_mundo() else "res://scenes/pruebas_assets.tscn").instantiate()
	root.add_child(escena)
	current_scene = escena
	camara = escena.get_node("CamaraPrincipal")
	jugador = escena.get_node("Jugador")
	await esperar(20)
	comprobar(camara.projection == Camera3D.PROJECTION_ORTHOGONAL and is_equal_approx(camara.size,15), "Inicio ortografico 15")
	comprobar(InputMap.has_action("girar_camara_izquierda") and InputMap.has_action("girar_camara_derecha"), "Acciones persistentes de orbita disponibles")
	comprobar(is_equal_approx(InputMap.action_get_deadzone("girar_camara_derecha"),0.2), "Zona muerta persistente 0.20")
	var inicio := jugador.global_position
	var rotacion_jugador := jugador.global_basis
	camara.set_process(false)
	var distancia: float = camara.get("desplazamiento").length()
	for codigo in [KEY_Q, KEY_E]:
		tecla(codigo,true)
		var angulo_inicial: float = camara.get("angulo_horizontal")
		var sin_saltos := true
		var anterior := camara.global_position
		# Dos vueltas exactas con paso fijo, incluida la frontera +/-PI.
		for i in 576:
			camara._process(1.0/60.0)
			sin_saltos = sin_saltos and camara.global_position.distance_to(anterior) < 0.6
			anterior = camara.global_position
		tecla(codigo,false)
		comprobar(sin_saltos and absf(angle_difference(angulo_inicial,camara.get("angulo_horizontal"))) < 0.001, "Dos vueltas continuas con " + OS.get_keycode_string(codigo))
	comprobar(jugador.global_position.distance_to(inicio)<0.02 and jugador.global_basis.is_equal_approx(rotacion_jugador), "Giro no desplaza ni rota al jugador")
	var antes: float = camara.get("angulo_horizontal")
	stick(JOY_AXIS_RIGHT_X,0.15)
	for i in 60:
		camara._process(1.0/60.0)
	comprobar(is_equal_approx(antes,camara.get("angulo_horizontal")), "Stick derecho bajo zona muerta no gira")
	stick(JOY_AXIS_RIGHT_X,0.7)
	camara._process(0.5)
	comprobar(absf(angle_difference(antes,camara.get("angulo_horizontal")))>0.1, "Stick derecho gira de forma analogica")
	stick(JOY_AXIS_RIGHT_X,0)
	# WASD y flechas deben coincidir con los ejes de pantalla en cuatro orientaciones.
	var relativo := true
	var animaciones := true
	for angulo in [0.0, PI*0.5, PI, -PI*0.5]:
		camara.set("angulo_horizontal",angulo)
		camara.set("centro_seguimiento",Vector3.ZERO)
		camara.actualizar_orbita()
		relativo = relativo and absf(camara.global_position.length()-distancia)<0.01
		relativo = relativo and absf(camara.rotation_degrees.x+32)<0.05
		for caso in [[KEY_W,Vector2.UP,"arriba"], [KEY_UP,Vector2.UP,"arriba"], [KEY_A,Vector2.LEFT,"izquierda"], [KEY_D,Vector2.RIGHT,"derecha"], [KEY_S,Vector2.DOWN,"abajo"]]:
			jugador.global_position = inicio
			jugador.velocity = Vector3.ZERO
			var derecha := camara.global_basis.x
			var atras := camara.global_basis.z
			atras.y=0
			atras=atras.normalized()
			var deseada: Vector3 = derecha*caso[1].x+atras*caso[1].y
			tecla(caso[0],true)
			await esperar(22)
			tecla(caso[0],false)
			relativo = relativo and (jugador.global_position-inicio).dot(deseada)>0.8
			animaciones = animaciones and String(jugador.get_node("Visual/SpriteAnimado").animation)=="walk_"+caso[2]
			await esperar(18)
	comprobar(relativo, "Movimiento relativo, radio e inclinacion en 0/90/180/270 grados")
	comprobar(animaciones, "Animaciones coherentes con direccion de pantalla al orbitar")
	jugador.global_position=inicio
	jugador.velocity=Vector3.ZERO
	camara.set("angulo_horizontal",0.0)
	camara.set("centro_seguimiento",inicio)
	camara.actualizar_orbita()
	stick(JOY_AXIS_LEFT_Y,-0.8)
	await esperar(24)
	stick(JOY_AXIS_LEFT_Y,0)
	comprobar((jugador.global_position-inicio).dot(Vector3.FORWARD)>0.8, "Stick izquierdo mueve al protagonista")
	await esperar(20)
	jugador.global_position=inicio
	jugador.velocity=Vector3.ZERO
	camara.set_process(true)
	tecla(KEY_W,true)
	tecla(KEY_E,true)
	await esperar(60)
	tecla(KEY_W,false)
	tecla(KEY_E,false)
	await esperar(100)
	var centro: Vector3 = camara.get("centro_seguimiento")
	comprobar(centro.distance_to(jugador.global_position)<0.05 and jugador.is_on_floor(), "Seguimiento converge tras mover y girar simultaneamente")
	comprobar(camara.unproject_position(jugador.global_position+Vector3.UP*0.8).distance_to(root.get_visible_rect().size*0.5)<4, "Encuadre centrado despues del seguimiento")
	if DisplayServer.get_name()!="headless":
		jugador.global_position=Vector3(0,0.02,0) if probar_mundo() else Vector3(-6,0.02,-2.5)
		jugador.velocity=Vector3.ZERO
		for grados in [0,90,180,270]:
			camara.set("angulo_horizontal",deg_to_rad(grados))
			await esperar(90)
			await RenderingServer.frame_post_draw
			comprobar(root.get_texture().get_image().save_png(("user://orbita_mundo_%d.png" if probar_mundo() else "user://orbita_assets_%d.png")%grados)==OK,"Captura orbital %d"%grados)
	if not probar_mundo():
		var selector = escena.get_node("SelectorDistancia")
		var angulo_previo: float = camara.get("angulo_horizontal")
		var seleccion_correcta := true
		for i in 4:
			selector.seleccionar(i)
			seleccion_correcta = seleccion_correcta and is_equal_approx(camara.size,[23.0,19.0,17.0,15.0][i])
			seleccion_correcta = seleccion_correcta and is_equal_approx(camara.get("angulo_horizontal"),angulo_previo)
		comprobar(seleccion_correcta, "Selector 23/19/17/15 conserva orientacion orbital")
	stick(JOY_AXIS_LEFT_X,0.8)
	escena.queue_free()
	await esperar(3)
	comprobar(firma_movimiento()==original and InputMap.has_action("girar_camara_izquierda") and InputMap.has_action("girar_camara_derecha"), "InputMap persistente conservado al salir")
	comprobar(not Input.is_action_pressed("mover_derecha"), "Salir con stick sostenido no deja movimiento atascado")
	stick(JOY_AXIS_LEFT_X,0)
	var mundo: Node3D = load("res://scenes/mundo.tscn").instantiate()
	root.add_child(mundo)
	await esperar(20)
	var principal: Camera3D = mundo.get_node("CamaraPrincipal")
	comprobar(principal.get_script().resource_path=="res://scripts/camara_orbital.gd" and is_equal_approx(principal.size,15), "Mundo principal usa orbita compartida")
	mundo.queue_free()
	print("RESULTADO_ORBITA: %d fallos"%fallos)
	quit(0 if fallos==0 else 1)
