extends SceneTree
## Ejecutar con --headless --path RPG --script res://tests/validar_pruebas_assets.gd.
## Con ventana guarda cuatro capturas en user://, sin cambiar la escena principal.

var fallos: int = 0
var escena: Node3D
var jugador: CharacterBody3D


func _initialize() -> void:
	call_deferred("validar")


func comprobar(condicion: bool, mensaje: String) -> void:
	if condicion:
		print("OK: ", mensaje)
	else:
		fallos += 1
		push_error("FALLO: " + mensaje)


func esperar(fotogramas: int) -> void:
	for i in fotogramas:
		await physics_frame
	await process_frame


func validar() -> void:
	var recurso := load("res://scenes/pruebas_assets.tscn") as PackedScene
	comprobar(recurso != null, "Escena cargada")
	if recurso == null:
		quit(1)
		return
	escena = recurso.instantiate()
	root.add_child(escena)
	current_scene = escena
	jugador = escena.get_node("Jugador")
	var camara: Camera3D = escena.get_node("CamaraPrincipal")
	await esperar(20)
	comprobar(jugador.is_on_floor(), "Jugador apoyado en el suelo")
	comprobar(camara.projection == Camera3D.PROJECTION_ORTHOGONAL and is_equal_approx(camara.size, 23.0), "Camara ortografica original")
	var inicio := jugador.global_position
	for caso in [["mover_arriba", Vector3.FORWARD, "arriba"], ["mover_abajo", Vector3.BACK, "abajo"], ["mover_izquierda", Vector3.LEFT, "izquierda"], ["mover_derecha", Vector3.RIGHT, "derecha"]]:
		jugador.global_position = inicio
		jugador.velocity = Vector3.ZERO
		Input.action_press(caso[0])
		await esperar(24)
		Input.action_release(caso[0])
		comprobar((jugador.global_position - inicio).dot(caso[1]) > 0.8, "Movimiento: " + caso[0])
		comprobar(String(jugador.get("direccion_visual")) == caso[2], "Animacion: " + caso[2])
		await esperar(20)
	var solidos := 0
	for cuerpo in escena.find_children("*", "StaticBody3D", true, false):
		if cuerpo.name == "Suelo" or cuerpo.name == "Limites":
			continue
		var colision := cuerpo.get_node("Colision") as CollisionShape3D
		var forma := colision.shape
		var confirmado := false
		for eje in [Vector3.RIGHT, Vector3.LEFT, Vector3.FORWARD, Vector3.BACK]:
			var semiancho: float
			if forma is BoxShape3D:
				semiancho = (forma.size.x * colision.global_basis.x.length() if eje.x != 0 else forma.size.z * colision.global_basis.z.length()) * 0.5
			else:
				semiancho = forma.radius
			var direccion: Vector3 = (colision.global_basis * eje).normalized()
			var centro := colision.global_position
			jugador.global_position = Vector3(centro.x, 0.02, centro.z) + direccion * (semiancho + 0.7)
			var golpe := KinematicCollision3D.new()
			if jugador.test_move(jugador.global_transform, -direccion * (semiancho + 1.0), golpe) and golpe.get_collider() == cuerpo:
				confirmado = true
		comprobar(confirmado, "Barrido de capsula: " + String(cuerpo.get_path()))
		solidos += 1
	comprobar(solidos == 13, "Trece obstaculos principales con colision")
	var consulta := PhysicsShapeQueryParameters3D.new()
	consulta.shape = jugador.get_node("ColisionJugador").shape
	consulta.exclude = [jugador.get_rid()]
	var libres := true
	# Ejes de conexion, acceso a la casa y contorno completo del puesto.
	var puntos: Array[Vector3] = [Vector3(-6.5, 0, -2.6)]
	for i in range(-13, 14):
		puntos.append(Vector3(i, 0, 0))
		puntos.append(Vector3(0, 0, i))
	for x in [4.3, 6.0, 7.7]:
		for z in [-6.2, -3.8]:
			puntos.append(Vector3(x, 0, z))
	for punto in puntos:
		consulta.transform = Transform3D(Basis.IDENTITY, punto + Vector3.UP * 0.82)
		if not escena.get_world_3d().direct_space_state.intersect_shape(consulta).is_empty():
			libres = false
			push_error("Paso ocupado: " + str(punto))
	comprobar(libres, "Conexiones y contorno del mercado libres")
	var materiales := true
	var superficies := 0
	for malla in escena.find_children("*", "MeshInstance3D", true, false):
		for superficie in malla.mesh.get_surface_count():
			superficies += 1
			if malla.get_active_material(superficie) == null:
				materiales = false
	comprobar(materiales and superficies > 40, "Materiales presentes: %d superficies" % superficies)
	jugador.global_position = inicio
	jugador.velocity = Vector3.ZERO
	await esperar(100)
	comprobar(camara.global_position.distance_to(jugador.global_position + camara.get("desplazamiento")) < 0.05, "Seguimiento converge")
	if DisplayServer.get_name() != "headless":
		var zonas := {"arquitectura": Vector3(-6, 0.05, -2.5), "mercado": Vector3(6, 0.05, -2.5), "herreria": Vector3(-6, 0.05, 7), "naturaleza": Vector3(7, 0.05, 9)}
		for zona in zonas:
			jugador.global_position = zonas[zona]
			jugador.velocity = Vector3.ZERO
			await esperar(90)
			await RenderingServer.frame_post_draw
			comprobar(root.get_texture().get_image().save_png("user://pruebas_assets_" + zona + ".png") == OK, "Captura: " + zona)
	print("RESULTADO_ASSETS: %d fallos; %d solidos" % [fallos, solidos])
	quit(0 if fallos == 0 else 1)