extends SceneTree
## Desde la raiz: godot --headless --path RPG --script res://tests/validar_proporciones.gd
## Sin --headless guarda comparaciones original/propuesta y laterales en user://.
var fallos: int = 0
var escena: Node3D
var jugador: CharacterBody3D

func _initialize() -> void:
	call_deferred("validar")

func comprobar(condicion: bool, mensaje: String) -> void:
	if not condicion:
		fallos += 1
		push_error("FALLO: " + mensaje)
	else:
		print("OK: ", mensaje)

func esperar(n: int) -> void:
	for i in n:
		await physics_frame
	await process_frame

func limites(nodo: Node3D) -> AABB:
	var total := AABB()
	var primero := true
	for malla: MeshInstance3D in nodo.find_children("*", "MeshInstance3D", true, false):
		var caja: AABB = malla.global_transform * malla.get_aabb()
		total = caja if primero else total.merge(caja)
		primero = false
	return total

func paso_libre(a: Vector3, b: Vector3) -> bool:
	var consulta := PhysicsShapeQueryParameters3D.new()
	consulta.shape = jugador.get_node("ColisionJugador").shape
	consulta.exclude = [jugador.get_rid()]
	var pasos := int(ceil(a.distance_to(b) / 0.2))
	for i in range(pasos + 1):
		var punto := a.lerp(b, float(i) / max(1, pasos))
		consulta.transform = Transform3D(Basis.IDENTITY, punto + Vector3.UP * 0.82)
		if not escena.get_world_3d().direct_space_state.intersect_shape(consulta).is_empty():
			return false
	return true

# Rays geometricos contra triangulos reales de cubierta, sin agregar colisiones al tejado.
# Mide solo oclusion por cubierta de la puerta frontal, no toda oclusion del escenario.
func puerta_visible(edificio: Node3D, camara: Camera3D) -> int:
	var puerta: Node3D = edificio.get_node("Muros/Puerta")
	var origen := puerta.global_position
	var caras: Array[Vector3] = []
	for malla: MeshInstance3D in edificio.get_node("Cubierta").find_children("*", "MeshInstance3D", true, false):
		for punto in malla.mesh.get_faces():
			caras.append(malla.global_transform * punto)
	var visibles := 0
	for x in [-0.15, -0.5, -0.85]:
		for y in [0.35, 1.0, 1.8, 2.05]:
			var destino := origen + Vector3(x, y, 0.08)
			var desde := camara.project_ray_origin(camara.unproject_position(destino))
			var tapado := false
			for i in range(0, caras.size(), 3):
				if Geometry3D.segment_intersects_triangle(desde, destino, caras[i], caras[i + 1], caras[i + 2]) != null:
					tapado = true
					break
			if not tapado:
				visibles += 1
	return visibles

func captura(nombre: String) -> void:
	await esperar(75)
	await RenderingServer.frame_post_draw
	comprobar(root.get_texture().get_image().save_png("user://proporciones_" + nombre + ".png") == OK, "Captura " + nombre)

func validar() -> void:
	print("VERSION: ", Engine.get_version_info().string)
	var recurso := load("res://scenes/pruebas_proporciones.tscn") as PackedScene
	comprobar(recurso != null, "Carga de escena")
	if recurso == null:
		quit(1)
		return
	escena = recurso.instantiate()
	root.add_child(escena)
	current_scene = escena
	jugador = escena.get_node("Jugador")
	var camara: Camera3D = escena.get_node("CamaraPrincipal")
	await esperar(30)
	comprobar(jugador.is_on_floor(), "Apoyo del protagonista")
	comprobar(jugador.scale.is_equal_approx(Vector3.ONE) and is_equal_approx(jugador.get("velocidad"), 4.0), "Escala y velocidad originales")
	var capsula: CapsuleShape3D = jugador.get_node("ColisionJugador").shape
	comprobar(is_equal_approx(capsula.radius, 0.32) and is_equal_approx(capsula.height, 1.6), "Capsula original")
	comprobar(camara.projection == Camera3D.PROJECTION_ORTHOGONAL and is_equal_approx(camara.size, 23.0), "Camara ortografica 23")
	var inicio := jugador.global_position
	for caso in [["mover_arriba", Vector3.FORWARD, "arriba"], ["mover_abajo", Vector3.BACK, "abajo"], ["mover_izquierda", Vector3.LEFT, "izquierda"], ["mover_derecha", Vector3.RIGHT, "derecha"]]:
		jugador.global_position = inicio
		jugador.velocity = Vector3.ZERO
		Input.action_press(caso[0])
		await esperar(24)
		Input.action_release(caso[0])
		comprobar((jugador.global_position - inicio).dot(caso[1]) > 0.8, "Movimiento " + caso[0])
		var sprite: AnimatedSprite3D = jugador.get_node("Visual/SpriteAnimado")
		comprobar(String(jugador.get("direccion_visual")) == caso[2] and String(sprite.animation) == "walk_" + caso[2], "Animacion caminar " + caso[2])
		await esperar(25)
		comprobar(String(sprite.animation) == "idle_" + caso[2], "Animacion reposo " + caso[2])
	var cantidad := 0
	for edificio: Node3D in escena.get_node("Edificios").get_children():
		cantidad += 1
		var cuerpo: StaticBody3D = edificio.get_node("Cuerpo")
		var forma: CollisionShape3D = cuerpo.get_node("Colision")
		var muros := limites(edificio.get_node("Muros"))
		var techo := limites(edificio.get_node("Cubierta"))
		comprobar(abs(muros.position.y) < 0.01, edificio.name + ": muros apoyados")
		var cuerpo_tamano: Vector2 = edificio.get_meta("cuerpo")
		comprobar(techo.size.x > cuerpo_tamano.x and techo.size.z > cuerpo_tamano.y, edificio.name + ": cubierta corresponde al cuerpo y conserva aleros")
		comprobar(techo.position.y < muros.end.y and techo.position.y > 2.5, edificio.name + ": cubierta encajada sobre muros")
		var puerta := limites(edificio.get_node("Muros/Puerta"))
		comprobar(puerta.size.y > capsula.height and puerta.size.x > capsula.radius * 2.0, edificio.name + ": puerta mayor que capsula (no valida hueco interior)")
		var centro := edificio.global_position
		var semiejes: Vector3 = forma.shape.size * 0.5
		for direccion in [Vector3.RIGHT, Vector3.LEFT, Vector3.FORWARD, Vector3.BACK]:
			var ancho: float = semiejes.x if direccion.x != 0 else semiejes.z
			jugador.global_position = Vector3(centro.x, 0.02, centro.z) + direccion * (ancho + 0.8)
			var golpe := KinematicCollision3D.new()
			comprobar(jugador.test_move(jugador.global_transform, -direccion * 1.5, golpe) and golpe.get_collider() == cuerpo, edificio.name + ": barrido " + str(direccion))
		var frente := Vector3(centro.x - cuerpo_tamano.x * 0.5 + 1, 0, centro.z + cuerpo_tamano.y * 0.5 + 1)
		comprobar(paso_libre(Vector3(0, 0, 3), Vector3(frente.x, 0, 3)) and paso_libre(Vector3(frente.x, 0, 3), frente), edificio.name + ": conexion a puerta libre")
		# Perimetro completo por fuera de la caja, con margen para la capsula.
		var r := Vector2(semiejes.x + 0.8, semiejes.z + 0.8)
		var esquinas: Array[Vector3] = [centro + Vector3(-r.x, 0, -r.y), centro + Vector3(r.x, 0, -r.y), centro + Vector3(r.x, 0, r.y), centro + Vector3(-r.x, 0, r.y)]
		var libre := true
		for i in 4:
			esquinas[i].y = 0
		for i in 4:
			libre = paso_libre(esquinas[i], esquinas[(i + 1) % 4]) and libre
		comprobar(libre, edificio.name + ": perimetro transitable")
		# Colision real durante movimiento, no solo consulta de forma.
		jugador.global_position = frente + Vector3.UP * 0.02
		jugador.velocity = Vector3.ZERO
		Input.action_press("mover_arriba")
		await esperar(60)
		Input.action_release("mover_arriba")
		await esperar(20)
		comprobar(jugador.is_on_floor() and jugador.global_position.z >= centro.z + semiejes.z + 0.30, edificio.name + ": caminar se detiene ante fachada")
		# Misma vista de camara para comparar altura original y propuesta.
		jugador.global_position = frente + Vector3(0, 0.02, 1.5)
		jugador.velocity = Vector3.ZERO
		await esperar(100)
		var cubierta: Node3D = edificio.get_node("Cubierta")
		var escala := cubierta.scale
		var visibles := puerta_visible(edificio, camara)
		print("MEDIDAS ", edificio.name, " muros=", muros, " cubierta=", techo, " puerta_visible=", visibles, "/12")
		comprobar(visibles >= 10, edificio.name + ": puerta visible en al menos 10/12 muestras")
		if DisplayServer.get_name() != "headless":
			await captura(String(edificio.name) + "_propuesta")
			cubierta.scale = Vector3.ONE
			print("PUERTA_ORIGINAL ", edificio.name, " ", puerta_visible(edificio, camara), "/12")
			await captura(String(edificio.name) + "_original")
			cubierta.scale = escala
			jugador.global_position = centro + Vector3(cuerpo_tamano.x * 0.5 + 2, 0.02, 1)
			await captura(String(edificio.name) + "_lateral")
			# Orientacion este de acceso: muestra el faldon y el muro lateral sin cambiar la camara.
			edificio.rotation_degrees.y = 90
			jugador.global_position = centro + Vector3(0, 0.02, cuerpo_tamano.x * 0.5 + 2.5)
			await captura(String(edificio.name) + "_orientacion_este")
			edificio.rotation_degrees.y = 0
	comprobar(cantidad == 3, "Tres variantes comparables")
	escena.get_node("Comparador/Panel/Opciones/Originales").button_pressed = true
	var originales := true
	for edificio: Node3D in escena.get_node("Edificios").get_children():
		originales = originales and edificio.get_node("Cubierta").scale.is_equal_approx(Vector3.ONE)
	comprobar(originales, "Comparador activa las tres cubiertas originales")
	escena.get_node("Comparador/Panel/Opciones/Originales").button_pressed = false
	var propuestas := true
	for edificio: Node3D in escena.get_node("Edificios").get_children():
		propuestas = propuestas and is_equal_approx(edificio.get_node("Cubierta").scale.y, float(edificio.get_meta("escala_cubierta_propuesta")))
	comprobar(propuestas, "Comparador restaura las tres proporciones propuestas")
	jugador.global_position = inicio
	jugador.velocity = Vector3.ZERO
	await esperar(100)
	comprobar(camara.global_position.distance_to(jugador.global_position + camara.get("desplazamiento")) < 0.05, "Seguimiento original converge")
	print("RESULTADO_PROPORCIONES: %d fallos; %d edificios" % [fallos, cantidad])
	if DisplayServer.get_name() != "headless":
		print("CAPTURAS: ", ProjectSettings.globalize_path("user://"))
	quit(0 if fallos == 0 else 1)
