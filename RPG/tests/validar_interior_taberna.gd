extends SceneTree
## Fixture de integraciÃ³n E01: aproxima caminando desde delante de la fachada.
## No afirma recorrer toda la Aldea desde el origen; usa posiciones de ensayo.
var fallos := 0
var comprobaciones := 0
var carpeta: String
var gestor: Node

func _initialize() -> void:
	iniciar.call_deferred()

func comprobar(condicion: bool, mensaje: String) -> void:
	comprobaciones += 1
	if not condicion:
		fallos += 1
		push_error(mensaje)

func cuadros(cantidad: int) -> void:
	for i in cantidad:
		await physics_frame
		await process_frame

func pulsar_f() -> void:
	var evento := InputEventAction.new()
	evento.action = &"interactuar"
	evento.pressed = true
	Input.parse_input_event(evento)
	await cuadros(2)
	evento = InputEventAction.new()
	evento.action = &"interactuar"
	evento.pressed = false
	Input.parse_input_event(evento)

func esperar_transicion(id: StringName) -> void:
	for i in 240:
		await cuadros(1)
		if not gestor.en_transicion:
			break
	comprobar(not gestor.en_transicion and gestor.region_actual == id,"Destino esperado: " + String(id))
	comprobar(current_scene.get_node("Jugador").is_physics_processing(),"Control restaurado")
	comprobar(current_scene.get_node("CamaraPrincipal").is_processing(),"Camara restaurada")
	await cuadros(10)

func caminar(destino: Vector3) -> void:
	var jugador := current_scene.get_node("Jugador") as CharacterBody3D
	for i in 300:
		var diferencia := destino - jugador.global_position
		diferencia.y = 0
		if diferencia.length() < 0.15 and Vector2(jugador.velocity.x,jugador.velocity.z).length() < 0.5:
			break
		var frenado: float = Vector2(jugador.velocity.x,jugador.velocity.z).length_squared() / (2.0 * jugador.desaceleracion)
		if diferencia.length() < frenado + 0.12:
			for accion in ["mover_derecha","mover_izquierda","mover_abajo","mover_arriba"]:
				Input.action_release(accion)
			await cuadros(1)
			continue
		var camara := current_scene.get_node("CamaraPrincipal") as Camera3D
		var derecha := camara.global_basis.x
		derecha.y = 0
		var atras := camara.global_basis.z
		atras.y = 0
		var x := diferencia.dot(derecha.normalized())
		var z := diferencia.dot(atras.normalized())
		Input.action_press("mover_derecha",clampf(x*2,0,1))
		Input.action_press("mover_izquierda",clampf(-x*2,0,1))
		Input.action_press("mover_abajo",clampf(z*2,0,1))
		Input.action_press("mover_arriba",clampf(-z*2,0,1))
		await cuadros(1)
	for accion in ["mover_derecha","mover_izquierda","mover_abajo","mover_arriba"]:
		Input.action_release(accion)
	await cuadros(12)
	comprobar(Vector2(jugador.position.x-destino.x,jugador.position.z-destino.z).length()<0.3,"Recorrido alcanzable: "+str(destino)+" posicion="+str(jugador.position))
	comprobar(jugador.is_on_floor(),"Apoyo sobre suelo")

func captura(nombre: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await process_frame
	await RenderingServer.frame_post_draw
	get_root().get_texture().get_image().save_png(carpeta+"/"+nombre+".png")

func iniciar() -> void:
	carpeta = "res://logs/taberna_e01_"+Time.get_datetime_string_from_system().replace(":","-")+"_"+str(Time.get_ticks_msec())
	DirAccess.make_dir_recursive_absolute(carpeta)
	gestor = root.get_node("GestorRegiones")
	var mundo := load("res://scenes/mundo.tscn").instantiate() as Node3D
	root.add_child(mundo)
	current_scene = mundo
	await cuadros(15)
	await pulsar_f()
	comprobar(not gestor.en_transicion,"F fuera del rango no abre interior")
	comprobar(not mundo.get_node("PuertaTabernaE01/Aviso").visible,"Aviso oculto fuera de rango")
	comprobar(mundo.get_node("Aldea/Edificios/E01").position == Vector3(-8,0.003,-20),"E01 exterior conservado")
	comprobar(mundo.has_node("Aldea/PuntoPesca") and mundo.has_node("NPCs/Pescador"),"Pesca y NPC existentes")
	for ciclo in 5:
		# PosiciÃ³n de ensayo exterior; la aproximaciÃ³n final se realiza con Input.
		var jugador := current_scene.get_node("Jugador") as CharacterBody3D
		jugador.position = Vector3(-8,0.05,-12)
		jugador.velocity = Vector3.ZERO
		await cuadros(12)
		await caminar(Vector3(-8,0,-14.75))
		comprobar(current_scene.get_node("PuertaTabernaE01/Aviso").visible,"Aviso frente a puerta")
		await captura("exterior_"+str(ciclo))
		await pulsar_f()
		comprobar(gestor.en_transicion,"F cercano inicia fundido")
		comprobar(not gestor.solicitar("res://scenes/mundo.tscn","aldea_taberna_e01"),"Solicitud simultanea rechazada")
		await esperar_transicion(&"TabernaE01")
		jugador = current_scene.get_node("Jugador")
		comprobar(jugador.position.distance_to(Vector3(0,0,3.65))<0.2,"Aparicion interior segura")
		comprobar(jugador.get_node("Visual/SpriteAnimado") is AnimatedSprite3D,"Protagonista 2D original")
		comprobar(jugador.velocidad == 10.0,"Velocidad original")
		comprobar(current_scene.get_meta("assets_utilizados").size() == 23,"23 modelos medv-cafe serializados")
		if ciclo == 0:
			await captura("interior_entrada")
		await caminar(Vector3(0,0,0.25))
		await caminar(Vector3(-0.35,0,-0.4))
		await caminar(Vector3(-0.4,0,-1.62))
		await caminar(Vector3(-2.15,0,-1.62))
		await caminar(Vector3(-2.15,0,-3.5))
		await caminar(Vector3(0,0,-3.5))
		if ciclo == 0:
			await captura("interior_barra_almacen")
		await caminar(Vector3(-2.15,0,-3.5))
		await caminar(Vector3(-2.15,0,-1.62))
		await caminar(Vector3(-0.4,0,-1.62))
		await caminar(Vector3(0,0,0.25))
		await caminar(Vector3(0,0,1.1))
		if ciclo == 0:
			await inspeccionar()
		await caminar(Vector3(0,0,3.75))
		await cuadros(8)
		comprobar(current_scene.get_node("Salida/Aviso").visible,"Salida alcanzable y aviso visible")
		if ciclo == 0:
			await captura("interior_salida")
		await pulsar_f()
		await esperar_transicion(&"Aldea")
		jugador = current_scene.get_node("Jugador")
		comprobar(jugador.position.distance_to(Vector3(-8,0,-14.75))<0.2,"Retorno frente a E01")
		comprobar(current_scene.get_node("CamaraPrincipal").size == 15,"Camara exterior 15")
		await cuadros(30)
		comprobar(gestor.region_actual == &"Aldea" and not gestor.en_transicion,"Sin reentrada automatica")
	print("E01: ",fallos," fallos / ",comprobaciones," comprobaciones. Evidencias: ",carpeta)
	quit(1 if fallos else 0)

func inspeccionar() -> void:
	var jugador := current_scene.get_node("Jugador") as CharacterBody3D
	var camara := current_scene.get_node("CamaraPrincipal") as Camera3D
	# Colisiones reales mediante barrido de la cÃ¡psula, sin mover muebles.
	for datos in [[Vector3(0,0.02,0),Vector3(-3,0,0),"Mesa"], [Vector3(0,0.02,0),Vector3(6,0,0),"Pared"], [Vector3(0,0.02,-3.5),Vector3(0,0,2),"Barra"], [Vector3(-2.3,0.02,-2.8),Vector3(0,0,-2),"Barril"], [Vector3(1.85,0.02,-3.5),Vector3(0,0,-2),"Estanteria"]]:
		var t := jugador.global_transform
		t.origin = datos[0]
		comprobar(jugador.test_move(t,datos[1]),"Capsula bloqueada por "+datos[2])
	Input.action_press("girar_camara_derecha")
	await cuadros(30)
	Input.action_release("girar_camara_derecha")
	comprobar(absf(camara.angulo_horizontal)>0.1,"Q/E orbital interior")
	camara.set_process(false)
	for i in 8:
		camara.angulo_horizontal = i*PI/4
		camara.centro_seguimiento = Vector3(0,0,0)
		camara.actualizar_orbita()
		await cuadros(3)
		await captura("interior_angulo_%02d"%i)
	camara.angulo_horizontal = 0
	camara.centro_seguimiento = jugador.position
	camara.actualizar_orbita()
	camara.set_process(true)

