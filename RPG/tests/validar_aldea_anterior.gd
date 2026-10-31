extends SceneTree
## Ejecutar con --path RPG --script res://tests/validar_aldea_anterior.gd desde la raiz.
## Conserva las comprobaciones del prototipo contra scenes/respaldos/mundo_etapa1.tscn.
## Con --headless omite la captura; con ventana la guarda en user://.

var fallos: int = 0
var mundo: Node3D
var jugador: CharacterBody3D
var camara: Camera3D


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
	mundo = (load("res://scenes/respaldos/mundo_etapa1.tscn") as PackedScene).instantiate()
	root.add_child(mundo)
	current_scene = mundo
	jugador = mundo.get_node("Jugador")
	camara = mundo.get_node("CamaraPrincipal")
	await esperar(20)
	comprobar(jugador.is_on_floor(), "El jugador descansa sobre el terreno")
	comprobar(camara.projection == Camera3D.PROJECTION_ORTHOGONAL, "Camara ortografica")
	comprobar(absf(camara.rotation_degrees.x + 32.0) < 0.1, "Inclinacion -32 grados / 58 desde la vertical")
	comprobar(is_equal_approx(camara.size, 23.0), "Tamano ortografico 23")
	comprobar(mundo.get_node("Aldea/Edificios").get_child_count() == 4, "Se conservan cuatro edificios")
	var inicio := jugador.global_position
	for caso in [["mover_arriba", Vector3.FORWARD, "arriba"], ["mover_abajo", Vector3.BACK, "abajo"], ["mover_izquierda", Vector3.LEFT, "izquierda"], ["mover_derecha", Vector3.RIGHT, "derecha"]]:
		jugador.global_position = inicio
		jugador.velocity = Vector3.ZERO
		Input.action_press(caso[0])
		await esperar(24)
		Input.action_release(caso[0])
		var avance := jugador.global_position - inicio
		comprobar(avance.dot(caso[1]) > 0.8, "WASD: " + caso[0])
		comprobar(String(jugador.get("direccion_visual")) == caso[2], "Animacion: " + caso[2])
		await esperar(20)
	jugador.global_position = inicio
	jugador.velocity = Vector3.ZERO
	await esperar(100)
	var destino: Vector3 = jugador.global_position + camara.get("desplazamiento")
	comprobar(camara.global_position.distance_to(destino) < 0.05, "Seguimiento converge suavemente al objetivo")
	var pantalla := camara.unproject_position(jugador.global_position + Vector3.UP * 0.8)
	comprobar(pantalla.distance_to(root.get_visible_rect().size * 0.5) < 4.0, "Personaje cerca del centro")
	# Barridos reales de la capsula contra cada objeto solido, en su eje local X.
	var cuerpos := mundo.find_children("*", "StaticBody3D", true, false)
	var solidos := 0
	for cuerpo in cuerpos:
		if cuerpo.name == "Suelo" or String(cuerpo.name).begins_with("Limite"):
			continue
		var colision := cuerpo.get_child(0) as CollisionShape3D
		if colision == null:
			continue
		var caja := colision.shape as BoxShape3D
		var centro: Vector3 = colision.global_position
		var confirmado := false
		for eje in [Vector3.RIGHT, Vector3.LEFT, Vector3.FORWARD, Vector3.BACK]:
			var direccion: Vector3 = (colision.global_basis * eje).normalized()
			var semiancho: float = (caja.size.x * colision.global_basis.x.length() if eje.x != 0 else caja.size.z * colision.global_basis.z.length()) * 0.5
			jugador.global_position = Vector3(centro.x, 0.01, centro.z) + direccion * (semiancho + 0.6)
			var golpe := KinematicCollision3D.new()
			if jugador.test_move(jugador.global_transform, -direccion * (semiancho + 0.8), golpe) and golpe.get_collider() == cuerpo:
				confirmado = true
		comprobar(confirmado, "Colision solida: " + String(cuerpo.get_parent().name))
		solidos += 1
	comprobar(solidos >= 18, "Cobertura de colisiones de edificios, vallas y suministros")
	# Comprueba capsula libre a lo largo de todos los caminos, no solo en sus centros.
	var consulta := PhysicsShapeQueryParameters3D.new()
	consulta.shape = jugador.get_node("ColisionJugador").shape
	consulta.exclude = [jugador.get_rid()]
	var libres := true
	for baldosa in mundo.get_node("Aldea/Caminos").get_children():
		for desplazamiento in [Vector3.ZERO, Vector3(0.4, 0, 0), Vector3(-0.4, 0, 0), Vector3(0, 0, 0.4), Vector3(0, 0, -0.4)]:
			consulta.transform = Transform3D(Basis.IDENTITY, Vector3(baldosa.position.x, 0.82, baldosa.position.z) + desplazamiento)
			if not mundo.get_world_3d().direct_space_state.intersect_shape(consulta).is_empty():
				libres = false
				push_error("Camino ocupado: " + String(baldosa.name))
	comprobar(libres, "Plaza y caminos libres para la capsula del protagonista")
	var accesos_libres := true
	for edificio in mundo.get_node("Aldea/Edificios").get_children():
		var acceso: Vector3 = edificio.to_global(Vector3(-0.5, 0, 3.3))
		consulta.transform = Transform3D(Basis.IDENTITY, Vector3(acceso.x, 0.82, acceso.z))
		if not mundo.get_world_3d().direct_space_state.intersect_shape(consulta).is_empty():
			accesos_libres = false
	comprobar(accesos_libres, "Espacio libre frente a las cuatro puertas cerradas")
	var materiales_completos := true
	var superficies := 0
	for nodo in mundo.find_children("*", "MeshInstance3D", true, false):
		for superficie in nodo.mesh.get_surface_count():
			superficies += 1
			if nodo.get_active_material(superficie) == null:
				materiales_completos = false
	comprobar(materiales_completos, "Materiales asignados en %d superficies" % superficies)
	jugador.global_position = inicio
	jugador.velocity = Vector3.ZERO
	await esperar(100)
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		var imagen := root.get_texture().get_image()
		var ruta := "user://aldea_etapa1_respaldada.png"
		comprobar(imagen.save_png(ruta) == OK, "Captura: " + ProjectSettings.globalize_path(ruta))
	print("RESULTADO: ", fallos, " fallos; ", solidos, " solidos comprobados.")
	quit(0 if fallos == 0 else 1)
