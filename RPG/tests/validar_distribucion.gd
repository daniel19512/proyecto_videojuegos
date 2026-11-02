extends SceneTree
## Desde la raiz: godot --headless --path RPG --script res://tests/validar_distribucion.gd
## Sin --headless guarda vistas locales y una vista cenital temporal en user://.
var fallos: int = 0
var mundo: Node3D
var aldea: Node3D
var jugador: CharacterBody3D
var consulta := PhysicsShapeQueryParameters3D.new()
var muestras := 0
var solidos_panaderia: Array[PhysicsBody3D] = []
var solidos_herreria: Array[PhysicsBody3D] = []
var solidos_carpinteria: Array[PhysicsBody3D] = []
var solidos_herbolario: Array[PhysicsBody3D] = []
var solidos_exterior_e06: Array[PhysicsBody3D] = []
var solidos_e07: Array[PhysicsBody3D] = []
var solidos_rurales: Array[PhysicsBody3D] = []

func _initialize() -> void:
	call_deferred("validar")

func comprobar(condicion: bool, mensaje: String) -> void:
	if condicion:
		print("OK: ", mensaje)
	else:
		fallos += 1
		push_error("FALLO: " + mensaje)

func esperar(n: int) -> void:
	for i in n:
		await physics_frame
	await process_frame

func plano(marca: MeshInstance3D) -> Rect2:
	var caja: AABB = marca.global_transform * marca.get_aabb()
	return Rect2(Vector2(caja.position.x, caja.position.z), Vector2(caja.size.x, caja.size.z))

func area_comun(a: Rect2, b: Rect2) -> float:
	if not a.intersects(b):
		return 0.0
	return a.intersection(b).get_area()

func conflictos() -> PackedStringArray:
	var errores := PackedStringArray()
	var parcelas := aldea.get_node("Parcelas").get_children()
	var jardines := aldea.get_node("Jardines").get_children()
	var caminos := aldea.get_node("Caminos").get_children()
	var reservas: Array = parcelas + jardines
	for i in reservas.size():
		var a: Rect2 = plano(reservas[i].get_node("Marca"))
		for j in range(i + 1, reservas.size()):
			if area_comun(a, plano(reservas[j].get_node("Marca"))) > 0.001:
				errores.append(str(reservas[i].name) + "/" + str(reservas[j].name))
		for camino: Node3D in caminos:
			# Solo un acceso de esa misma parcela/zona puede atravesar su reserva.
			var propietario := String(camino.get_meta("acceso_parcela"))
			var zona := String(camino.get_meta("acceso_zona"))
			if String(reservas[i].name) in [propietario, zona]:
				continue
			if area_comun(a, plano(camino.get_node("Marca"))) > 0.001:
				errores.append(str(reservas[i].name) + "/" + str(camino.name))
	return errores

func conectadas(regiones: Array[Rect2]) -> int:
	var visitadas: Array[int] = [0]
	var pendientes: Array[int] = [0]
	while not pendientes.is_empty():
		var i: int = pendientes.pop_back()
		for j in regiones.size():
			if j in visitadas:
				continue
			# Permite uniones por borde con una abertura de al menos una capsula.
			if regiones[i].grow(0.001).intersects(regiones[j]):
				var cruce := regiones[i].grow(0.001).intersection(regiones[j])
				if maxf(cruce.size.x, cruce.size.y) >= 0.64:
					visitadas.append(j)
					pendientes.append(j)
	return visitadas.size()

func suelo_libre(punto: Vector2) -> bool:
	muestras += 1
	consulta.transform = Transform3D(Basis.IDENTITY, Vector3(punto.x, 0.82, punto.y))
	var estado := mundo.get_world_3d().direct_space_state
	if not estado.intersect_shape(consulta).is_empty():
		return false
	var rayo := PhysicsRayQueryParameters3D.create(Vector3(punto.x, 2, punto.y), Vector3(punto.x, -1, punto.y))
	rayo.exclude = [jugador.get_rid()]
	var golpe := estado.intersect_ray(rayo)
	return not golpe.is_empty() and golpe.collider == aldea.get_node("Terreno/Suelo") and absf(golpe.position.y) < 0.005

func caminar(accion: String, fotogramas: int) -> void:
	Input.action_press(accion)
	await esperar(fotogramas)
	Input.action_release(accion)
	await esperar(12)

func captura(nombre: String) -> void:
	await esperar(70)
	await RenderingServer.frame_post_draw
	comprobar(root.get_texture().get_image().save_png("user://distribucion_" + nombre + ".png") == OK, "Captura " + nombre)

func geometria_e06_permitida(malla: MeshInstance3D, reserva: Rect2) -> bool:
	var huella := plano(malla)
	if reserva.encloses(huella):
		return true
	# Solo el sendero puede salir de E06, exclusivamente dentro de su propio acceso.
	var camino := aldea.get_node("Edificios/E06/Exterior/CaminoEntrada")
	var acceso: Node3D = aldea.get_node("Caminos/AccesoE06_1")
	return camino.is_ancestor_of(malla) and acceso.get_meta("acceso_parcela") == "E06" and plano(acceso.get_node("Marca")).encloses(huella)

func validar_limites_depuracion() -> void:
	var limites: Array[MeshInstance3D] = aldea.obtener_limites()
	comprobar(limites.size() == 100, "Cien bordes de parcelas, jardines, reservas y plaza conservados")
	var originales: Array[Transform3D] = []
	var ocultos: bool = not aldea.mostrar_limites_parcelas
	for borde in limites:
		originales.append(borde.global_transform)
		ocultos = ocultos and not borde.is_visible_in_tree()
	comprobar(ocultos,"Limites amarillos desactivados por defecto en partida normal")
	if DisplayServer.get_name() != "headless":
		await esperar(2)
		await RenderingServer.frame_post_draw
		comprobar(root.get_texture().get_image().save_png("user://limites_parcelas_desactivados.png") == OK,"Captura sin limites")
	aldea.mostrar_limites_parcelas = true
	var visibles := true
	for borde in limites:
		visibles = visibles and borde.is_visible_in_tree()
	comprobar(visibles,"Propiedad de depuracion activa todos los bordes")
	if DisplayServer.get_name() != "headless":
		await esperar(2)
		await RenderingServer.frame_post_draw
		comprobar(root.get_texture().get_image().save_png("user://limites_parcelas_activados.png") == OK,"Captura con limites")
	aldea.mostrar_limites_parcelas = false
	var intactos := true
	for i in limites.size():
		intactos = intactos and limites[i].global_transform.is_equal_approx(originales[i]) and not limites[i].visible
	comprobar(intactos,"Conmutar limites no elimina nodos ni altera geometria")
	comprobar(not aldea.get_node("Parcelas/E06/Marca").visible and not aldea.get_node("Parcelas/E07/Marca").visible and not aldea.get_node("Parcelas/E08/Marca").visible and not aldea.get_node("Parcelas/E09/Marca").visible and not aldea.get_node("Parcelas/E10/Marca").visible and not aldea.get_node("Parcelas/E11/Marca").visible and aldea.get_node("Parcelas/E12/Marca").visible,"Depuracion no altera marcas de edificios y reservas")

func validar_edificios() -> void:
	for id in ["E01", "E06"]:
		var edificio: Node3D = aldea.get_node("Edificios/" + id)
		var cuerpo: Vector2 = edificio.get_meta("cuerpo")
		var cubierta: Node3D = edificio.get_node("Cubierta")
		comprobar(edificio.scale.is_equal_approx(Vector3.ONE) and is_equal_approx(edificio.position.y, 0.003), id + ": cuerpo sin escalar apoyado en terreno")
		comprobar(cubierta.scale.is_equal_approx(Vector3(1, 0.55 if id == "E01" else 0.6, 1)) and is_equal_approx(cubierta.position.y, 3), id + ": tejado y frontones con proporcion aprobada")
		if id == "E01":
			comprobar(cubierta.get_node("PerfilBajo").scale.is_equal_approx(Vector3(1, 0.75, 1)), "E01: perfil bajo efectivo Y=0.4125")
			var huella: Vector2 = aldea.get_node("Parcelas/E01").get_meta("huella_cubierta")
			for m: MeshInstance3D in cubierta.get_node("PerfilBajo/Tejado").find_children("*", "MeshInstance3D", true, false):
				var real := plano(m)
				comprobar(Rect2(Vector2(-8,-20)-huella*0.5, huella).encloses(real), "E01: metadato de aleros contiene cubierta real")
		var reserva := plano(aldea.get_node("Parcelas/" + id + "/Marca"))
		var geometria_dentro := true
		for m: MeshInstance3D in edificio.find_children("*", "MeshInstance3D", true, false):
			geometria_dentro = geometria_dentro and (geometria_e06_permitida(m,reserva) if id == "E06" else reserva.encloses(plano(m)))
		comprobar(geometria_dentro, id + ": geometria en parcela; sendero E06 solo en su acceso propio")
		var paredes: StaticBody3D = edificio.get_node("Paredes")
		comprobar(paredes.get_child_count() == (8 if id == "E01" else 4), id + ": cuatro paredes delgadas, sin caja de volumen completo")
		var barridos := 0
		for dir in [Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT]:
			var distancia: float = cuerpo.y * 0.5 if dir.z != 0 else cuerpo.x * 0.5
			for lateral in [-0.65, 0.0, 0.65]:
				var origen: Vector3 = edificio.global_position + dir * (distancia + 1.2)
				origen += Vector3(-dir.z, 0, dir.x) * lateral * (cuerpo.x * 0.5 - 0.5 if dir.z != 0 else cuerpo.y * 0.5 - 0.5)
				origen.y = 1.1 # Barrido sobre mobiliario bajo; paredes hasta Y=3.12.
				var golpe := KinematicCollision3D.new()
				if jugador.test_move(Transform3D(Basis.IDENTITY, origen), -dir * 2, golpe) and golpe.get_collider() == paredes:
					barridos += 1
		comprobar(barridos == 12, id + ": doce barridos de capsula contra paredes")
		var puerta: Node3D = edificio.get_node("Muros/Puerta")
		var normal := Vector3.BACK if id == "E01" else Vector3.RIGHT
		var centro_puerta: Vector3 = puerta.to_global(Vector3(0.5, 0, 0))
		comprobar((puerta.global_basis * Vector3.FORWARD).dot(normal) > 0.99, id + ": orientacion de entrada")
		var cerca := centro_puerta + normal * 0.8
		comprobar(suelo_libre(Vector2(cerca.x, cerca.z)), id + ": aproximacion exterior a puerta libre")
		jugador.global_position = Vector3(cerca.x, 0.02, cerca.z)
		jugador.velocity = Vector3.ZERO
		await caminar("mover_arriba" if id == "E01" else "mover_izquierda", 30)
		comprobar(jugador.is_on_floor() and (jugador.global_position - centro_puerta).dot(normal) > 0.58, id + ": puerta cerrada detiene marcha real")
	# Control negativo fisico: la prueba de paso debe rechazar un obstaculo real.
	var bloqueo := StaticBody3D.new()
	var forma := CollisionShape3D.new()
	var caja := BoxShape3D.new()
	caja.size = Vector3(2, 3, 2)
	forma.shape = caja
	bloqueo.add_child(forma)
	aldea.add_child(bloqueo)
	bloqueo.position = Vector3(0, 1.5, -12)
	await esperar(2)
	comprobar(not suelo_libre(Vector2(0, -12)), "Detector fisico rechaza bloqueo real en calle norte")
	bloqueo.queue_free()
	await esperar(2)

# Solo se admite ocupacion por mobiliario y grupos de E06 comprobados individualmente.
# No se exceptuan reservas enteras ni corredores.
func muestra_mobiliario(punto: Vector2) -> bool:
	consulta.transform = Transform3D(Basis.IDENTITY, Vector3(punto.x, 0.82, punto.y))
	var golpes := mundo.get_world_3d().direct_space_state.intersect_shape(consulta)
	if golpes.is_empty():
		return false
	var mobiliario := aldea.get_node("Edificios/E01/DetallesTaberna/Mobiliario")
	for golpe in golpes:
		if golpe.collider != mobiliario and golpe.collider not in solidos_exterior_e06 and golpe.collider not in solidos_panaderia and golpe.collider not in solidos_herreria and golpe.collider not in solidos_carpinteria and golpe.collider not in solidos_herbolario and golpe.collider not in solidos_e07 and golpe.collider not in solidos_rurales:
			return false
	return true

func validar_detalles_taberna() -> void:
	var taberna: Node3D = aldea.get_node("Edificios/E01")
	var mobiliario: StaticBody3D = taberna.get_node("DetallesTaberna/Mobiliario")
	var reserva := plano(aldea.get_node("Parcelas/E01/Marca"))
	var formas := 0
	for forma: CollisionShape3D in mobiliario.find_children("*", "CollisionShape3D", true, false):
		formas += 1
		var caja: AABB = forma.global_transform * forma.shape.get_debug_mesh().get_aabb()
		var huella := Rect2(Vector2(caja.position.x, caja.position.z), Vector2(caja.size.x, caja.size.z))
		comprobar(reserva.encloses(huella), str(forma.name) + ": colision dentro de E01")
		var libre := true
		for camino in aldea.get_node("Caminos").get_children():
			libre = libre and area_comun(huella, plano(camino.get_node("Marca"))) < 0.001
		comprobar(libre, str(forma.name) + ": fuera de todos los corredores")
		consulta.transform = Transform3D(Basis.IDENTITY, Vector3(caja.get_center().x, 0.82, caja.get_center().z))
		var detectado := false
		for golpe in mundo.get_world_3d().direct_space_state.intersect_shape(consulta):
			detectado = detectado or golpe.collider == mobiliario
		comprobar(detectado, str(forma.name) + ": solido frente a capsula")
	comprobar(formas == 6, "Seis colisiones proporcionadas para barriles, caja, mesa y bancos")
	var puntos := [Vector2(-6.5,5.6), Vector2(4.6,5.6), Vector2(4.6,-5.5), Vector2(-6.5,-5.5), Vector2(-6.5,5.6)]
	var perimetro_libre := true
	for i in range(puntos.size()-1):
		var a: Vector2 = puntos[i] + Vector2(-8,-20)
		var b: Vector2 = puntos[i+1] + Vector2(-8,-20)
		var pasos := int(ceil(a.distance_to(b)/0.2))
		for k in range(pasos+1):
			perimetro_libre = suelo_libre(a.lerp(b,float(k)/pasos)) and perimetro_libre
	comprobar(perimetro_libre, "Circuito completo alrededor de taberna y terraza con capsula libre")
	jugador.global_position = Vector3(-8,0.02,-13.5)
	jugador.velocity = Vector3.ZERO
	await caminar("mover_arriba", 35)
	comprobar(jugador.is_on_floor() and jugador.position.z < -15.0 and jugador.position.z > -15.5, "Aproximacion caminando desde calle a puerta de taberna")

func validar_exterior_e06() -> void:
	var casa: Node3D = aldea.get_node("Edificios/E06")
	var exterior: Node3D = casa.get_node("Exterior")
	var reserva := plano(aldea.get_node("Parcelas/E06/Marca"))
	var formas := 0
	for nombre in ["Vallas","Jardin","ZonaServicio","ZonaDescanso","Huerto"]:
		var grupo: StaticBody3D = exterior.get_node(nombre)
		var valido := true
		for forma: CollisionShape3D in grupo.find_children("*","CollisionShape3D",true,false):
			formas += 1
			var caja: AABB = forma.global_transform * forma.shape.get_debug_mesh().get_aabb()
			var rect := Rect2(Vector2(caja.position.x,caja.position.z),Vector2(caja.size.x,caja.size.z))
			valido = valido and reserva.encloses(rect)
			for camino: Node3D in aldea.get_node("Caminos").get_children():
				valido = valido and area_comun(rect,plano(camino.get_node("Marca"))) < 0.001
			# Cada forma debe ser realmente solida; rayos por su centro, sin ignorar otros cuerpos.
			var centro := caja.get_center()
			var rayo := PhysicsRayQueryParameters3D.create(centro+Vector3.UP*(caja.size.y+0.1),centro-Vector3.UP*(caja.size.y+0.1))
			rayo.exclude = [jugador.get_rid()]
			var golpe := mundo.get_world_3d().direct_space_state.intersect_ray(rayo)
			valido = valido and not golpe.is_empty() and golpe.collider == grupo
			comprobar(caja.position.y >= -0.01, nombre+"/"+str(forma.name)+": apoyo sin hundimiento")
		comprobar(valido,nombre+": todas sus colisiones activas dentro de E06 y fuera de corredores")
		if valido:
			solidos_exterior_e06.append(grupo)
	comprobar(formas == 16 and solidos_exterior_e06.size() == 5,"Dieciseis formas en cinco grupos verificados de E06")
	var visuales := true
	for m: MeshInstance3D in exterior.find_children("*","MeshInstance3D",true,false):
		visuales = visuales and geometria_e06_permitida(m,reserva)
		for i in m.mesh.get_surface_count():
			visuales = visuales and m.get_active_material(i) != null
	comprobar(visuales,"Decoracion E06 con materiales, dentro de parcela o sendero en acceso propio")
	var senda: Node3D = exterior.get_node("CaminoEntrada")
	comprobar(senda.get_child_count() == 14 and senda.transform.is_equal_approx(Transform3D.IDENTITY),"Sendero conserva catorce grupos de piedras independientes sin transformar su raiz")
	var huella_senda := AABB()
	var primera := true
	var rasante := true
	for m: MeshInstance3D in senda.find_children("*","MeshInstance3D",true,false):
		var caja: AABB = m.global_transform*m.get_aabb()
		huella_senda = caja if primera else huella_senda.merge(caja)
		primera = false
		rasante = rasante and caja.end.y < 0.06 and caja.position.y > -0.01
	comprobar(rasante and huella_senda.position.x < -21.4 and huella_senda.end.x >= -16.65,"Sendero a ras de suelo conecta puerta E06 con eje del ramal publico")
	comprobar(huella_senda.size.z >= 1.3 and huella_senda.size.z <= 2.5,"Sendero comodo dentro del ancho publico autorizado")
	var puntos := [Vector2(3.25,0),Vector2(3.25,-3.95),Vector2(-2.95,-3.95),Vector2(-2.95,3.95),Vector2(3.25,3.95),Vector2(3.25,0)]
	var libre := true
	for i in range(puntos.size()-1):
		var a: Vector2 = puntos[i]+Vector2(-24,-23)
		var b: Vector2 = puntos[i+1]+Vector2(-24,-23)
		var pasos := int(ceil(a.distance_to(b)/0.15))
		for k in range(pasos+1):
			libre = suelo_libre(a.lerp(b,float(k)/pasos)) and libre
	comprobar(libre,"Circuito completo de capsula alrededor de E06 entre casa, vallas y mobiliario")
	for punto in [Vector2(-4,-3.4),Vector2(-3.6,-2.8),Vector2(-1.1,4.0)]:
		comprobar(suelo_libre(punto+Vector2(-24,-23)),"Acceso libre a huerto o banco: "+str(punto))
	# Entrada de 2.5 unidades abierta: se verifica ademas con marcha real desde el ramal publico.
	jugador.global_position = casa.global_position+Vector3(6.5,0.02,0)
	jugador.velocity = Vector3.ZERO
	await caminar("mover_izquierda",75)
	comprobar(jugador.is_on_floor() and jugador.position.x < -21.0 and jugador.position.x > -21.5,"Marcha desde camino publico atraviesa abertura y llega a puerta E06")
	await caminar("mover_derecha",75)
	comprobar(jugador.is_on_floor() and jugador.position.x > -17.0,"Retorno real desde puerta E06 al ramal publico")
	jugador.global_position = casa.global_position+Vector3(-2.95,0.02,-3.95)
	jugador.velocity = Vector3.ZERO
	await caminar("mover_izquierda",18)
	comprobar(jugador.is_on_floor() and jugador.position.x < -27.6,"Entrada real al huerto por abertura norte")
	# Control negativo: una valla en la abertura debe rechazarse, sin cambiar la escena guardada.
	var valla: CollisionShape3D = exterior.get_node("Vallas/ColisionFrenteNorte")
	var anterior := valla.position
	valla.position.z = 0
	await esperar(2)
	comprobar(not suelo_libre(Vector2(-19.55,-23)),"Detector rechaza valla que cierre el acceso este")
	valla.position = anterior
	await esperar(2)

func validar() -> void:
	print("VERSION: ", Engine.get_version_info().string)
	var recurso := load("res://scenes/mundo.tscn") as PackedScene
	comprobar(recurso != null, "Carga del mundo")
	if recurso == null:
		quit(1)
		return
	mundo = recurso.instantiate()
	root.add_child(mundo)
	current_scene = mundo
	aldea = mundo.get_node("Aldea")
	jugador = mundo.get_node("Jugador")
	var camara: Camera3D = mundo.get_node("CamaraPrincipal")
	comprobar(aldea.transform.is_equal_approx(Transform3D.IDENTITY), "Aldea a identidad")
	comprobar(jugador.position.is_equal_approx(Vector3(0, 0.05, 0)), "Aparicion original (0, 0.05, 0)")
	await esperar(20)
	consulta.shape = jugador.get_node("ColisionJugador").shape
	consulta.exclude = [jugador.get_rid()]
	comprobar(jugador.is_on_floor(), "Apoyo en suelo")
	comprobar(camara.projection == Camera3D.PROJECTION_ORTHOGONAL and is_equal_approx(camara.size, 15.0) and absf(camara.rotation_degrees.x + 32) < 0.1, "Camara ortografica aprobada: 15, inclinacion conservada")
	var forma: CollisionShape3D = aldea.get_node("Terreno/Suelo/Forma")
	var caja: AABB = forma.global_transform * AABB(-forma.shape.size * 0.5, forma.shape.size)
	comprobar(caja.position.is_equal_approx(Vector3(-40, -0.5, -36)) and caja.size.is_equal_approx(Vector3(80, 0.5, 72)), "Terreno fisico 80x72 centrado, superficie Y=0")
	var malla: MeshInstance3D = aldea.get_node("Terreno/Suelo/MallaSuelo")
	comprobar((malla.global_transform * malla.get_aabb()).is_equal_approx(caja), "Suelo visual coincide con colision")
	comprobar(aldea.find_children("*", "StaticBody3D", true, false).size() == 22, "Suelo, limites y solidos de los once edificios E01-E11")
	comprobar(aldea.get_node("Edificios").get_child_count() == 11, "Solo E01-E11 construidos")
	var plaza := plano(aldea.get_node("Plaza/Marca"))
	comprobar(plaza.is_equal_approx(Rect2(-10, -9, 20, 18)), "Plaza central 20x18")
	var inicio := jugador.global_position
	for caso in [["mover_arriba", Vector3.FORWARD, "arriba"], ["mover_abajo", Vector3.BACK, "abajo"], ["mover_izquierda", Vector3.LEFT, "izquierda"], ["mover_derecha", Vector3.RIGHT, "derecha"]]:
		jugador.global_position = inicio
		jugador.velocity = Vector3.ZERO
		Input.action_press(caso[0])
		await esperar(24)
		Input.action_release(caso[0])
		var sprite: AnimatedSprite3D = jugador.get_node("Visual/SpriteAnimado")
		comprobar((jugador.global_position - inicio).dot(caso[1]) > 0.8 and String(sprite.animation) == "walk_" + caso[2], "Movimiento y animacion " + caso[2])
		await esperar(25)
		comprobar(String(sprite.animation) == "idle_" + caso[2], "Reposo " + caso[2])
	await validar_limites_depuracion()
	await validar_edificios()
	await validar_detalles_taberna()
	await validar_exterior_e06()
	await validar_panaderia()
	await validar_herreria()
	await validar_carpinteria()
	await validar_herbolario()
	await validar_vivienda_noreste()
	await validar_vivienda_rural("E08")
	await validar_vivienda_rural("E09")
	await validar_vivienda_final("E10")
	await validar_vivienda_final("E11")
	var nivelado := true
	for x in range(-39, 40, 2):
		for z in range(-35, 36, 2):
			# Solo se admite ocupacion de cuerpos y decoracion con colisiones verificadas.
			# Los corredores y accesos se comprueban completos, sin exclusiones.
			var ocupado := false
			for edificio: Node3D in aldea.get_node("Edificios").get_children():
				var cuerpo: Vector2 = edificio.get_meta("cuerpo")
				var centro := Vector2(edificio.position.x, edificio.position.z)
				ocupado = ocupado or Rect2(centro - cuerpo * 0.5, cuerpo).grow(0.55).has_point(Vector2(x,z))
			if not ocupado and not muestra_mobiliario(Vector2(x, z)):
				nivelado = suelo_libre(Vector2(x, z)) and nivelado
	for x in [-39.5, 39.5]:
		for z in [-35.5, 35.5]:
			# Solo se admite ocupacion de cuerpos y decoracion con colisiones verificadas.
			# Los corredores y accesos se comprueban completos, sin exclusiones.
			var ocupado := false
			for edificio: Node3D in aldea.get_node("Edificios").get_children():
				var cuerpo: Vector2 = edificio.get_meta("cuerpo")
				var centro := Vector2(edificio.position.x, edificio.position.z)
				ocupado = ocupado or Rect2(centro - cuerpo * 0.5, cuerpo).grow(0.55).has_point(Vector2(x,z))
			if not ocupado and not muestra_mobiliario(Vector2(x, z)):
				nivelado = suelo_libre(Vector2(x, z)) and nivelado
	comprobar(nivelado, "Suelo libre fuera de edificios y solidos decorativos verificados")
	var centros := [Vector2(-8,-20), Vector2(8,-20), Vector2(-23,-6), Vector2(-23,7), Vector2(21,8), Vector2(-24,-23), Vector2(21,-24), Vector2(-24,23), Vector2(-8,24), Vector2(8,25), Vector2(18,24), Vector2(21,-10)]
	var parcelas := aldea.get_node("Parcelas").get_children()
	comprobar(parcelas.size() == 12, "Doce parcelas")
	for i in parcelas.size():
		var parcela: Node3D = parcelas[i]
		var rect := plano(parcela.get_node("Marca"))
		var meta: Rect2 = parcela.get_meta("reserva_local")
		meta.position += Vector2(parcela.global_position.x, parcela.global_position.z)
		comprobar(rect.is_equal_approx(meta) and Rect2(-40,-36,80,72).encloses(rect), str(parcela.name) + ": marca y reserva dentro del terreno")
		comprobar(Vector2(parcela.position.x, parcela.position.z).is_equal_approx(centros[i]), str(parcela.name) + ": centro del plano")
		var huella: Vector2 = parcela.get_meta("huella_cubierta")
		var centro: Vector2 = centros[i]
		comprobar(rect.encloses(Rect2(centro - huella * 0.5, huella)), str(parcela.name) + ": aleros futuros caben")
		comprobar(is_equal_approx(float(parcela.get_meta("escala_y_cubierta")), 0.55 if i in [0, 11] else 0.60), str(parcela.name) + ": proporcion aprobada registrada")
		var acceso: Vector2 = parcela.get_meta("acceso")
		comprobar(suelo_libre(acceso), str(parcela.name) + ": acceso con apoyo y sin obstaculos")
	var errores := conflictos()
	comprobar(errores.is_empty(), "Reservas sin solapes ajenos: " + str(errores))
	# Control negativo: el comprobador debe detectar el error original de E10.
	var e10: Node3D = aldea.get_node("Parcelas/E10")
	e10.position.x = 0
	comprobar(not conflictos().is_empty(), "Detector rechaza parcela sobre entrada sur")
	e10.position.x = 8
	var regiones: Array[Rect2] = [plaza]
	var pasos_libres := true
	var marcas_correctas := true
	var principales := 0
	for camino: Node3D in aldea.get_node("Caminos").get_children():
		var a: Vector2 = camino.get_meta("a")
		var b: Vector2 = camino.get_meta("b")
		var ancho: float = camino.get_meta("ancho")
		var rect := plano(camino.get_node("Marca"))
		regiones.append(rect)
		var esperada := Rect2(Vector2(a.x - ancho * 0.5, minf(a.y,b.y)), Vector2(ancho, absf(a.y-b.y))) if is_equal_approx(a.x,b.x) else Rect2(Vector2(minf(a.x,b.x), a.y - ancho * 0.5), Vector2(absf(a.x-b.x), ancho))
		marcas_correctas = marcas_correctas and rect.is_equal_approx(esperada)
		if camino.get_meta("acceso_parcela") == "" and camino.get_meta("acceso_zona") == "":
			principales += 1
			marcas_correctas = marcas_correctas and is_equal_approx(ancho, 4.0)
		var lateral := (b-a).normalized().orthogonal()
		var cantidad := int(ceil(a.distance_to(b) / 0.5))
		for k in range(cantidad + 1):
			for proporcion in [-1.0, -0.5, 0.0, 0.5, 1.0]:
				var punto: Vector2 = a.lerp(b, float(k)/maxi(1,cantidad)) + lateral * proporcion * (ancho*0.5-0.36)
				pasos_libres = suelo_libre(punto) and pasos_libres
	comprobar(marcas_correctas and principales == 8, "Ocho corredores principales de 4 unidades y marcas coherentes con todos los anchos")
	comprobar(pasos_libres, "Capsula y apoyo a lo largo y ancho de todos los corredores")
	comprobar(conectadas(regiones) == regiones.size(), "Todos los corredores conectados a plaza")
	var ribera: Rect2 = aldea.get_node("Reservas/Ribera").get_meta("reserva")
	var puente: Rect2 = aldea.get_node("Reservas/Puente").get_meta("reserva")
	comprobar(ribera.is_equal_approx(Rect2(26,-34,10,68)) and puente.is_equal_approx(Rect2(26,-2,8,4)), "Ribera y cruce futuro reservados")
	for parcela: Node3D in parcelas:
		comprobar(area_comun(plano(parcela.get_node("Marca")), ribera) < 0.001, str(parcela.name) + ": fuera de ribera")
	# Caminar realmente por la reserva de rio: hoy debe seguir siendo suelo continuo.
	jugador.global_position = Vector3(24, 0.02, 0)
	jugador.velocity = Vector3.ZERO
	await caminar("mover_derecha", 180)
	comprobar(jugador.is_on_floor() and jugador.position.x > 35.5, "Cruce real de ribera sin cauce ni bloqueo")
	var barridos := 0
	for caso in [["Norte", Vector3.FORWARD, "mover_arriba", 36.0], ["Sur", Vector3.BACK, "mover_abajo", 36.0], ["Oeste", Vector3.LEFT, "mover_izquierda", 40.0], ["Este", Vector3.RIGHT, "mover_derecha", 40.0]]:
		var dir: Vector3 = caso[1]
		for lateral in [-0.85, 0.0, 0.85]:
			var borde: float = caso[3]
			var punto: Vector3 = dir * (borde - 0.8) + Vector3(-dir.z, 0, dir.x) * lateral * (39.0 if dir.z != 0 else 35.0)
			punto.y = 0.02
			jugador.global_position = punto
			jugador.velocity = Vector3.ZERO
			var golpe := KinematicCollision3D.new()
			if jugador.test_move(jugador.global_transform, dir * 2, golpe) and golpe.get_collider() == aldea.get_node("Colisiones/Limite" + caso[0]):
				barridos += 1
		jugador.global_position = dir * (float(caso[3])-1.5) + Vector3.UP * 0.02
		jugador.velocity = Vector3.ZERO
		await caminar(caso[2], 45)
		comprobar(jugador.is_on_floor() and jugador.position.dot(dir) < float(caso[3])-0.30, "Limite " + caso[0] + " detiene marcha sin caida")
	comprobar(barridos == 12, "Doce barridos contra los cuatro limites")
	var materiales := true
	for mesh: MeshInstance3D in aldea.find_children("*", "MeshInstance3D", true, false):
		for i in mesh.mesh.get_surface_count():
			materiales = materiales and mesh.get_active_material(i) != null
	comprobar(materiales, "Marcas con materiales")
	jugador.global_position = inicio
	jugador.velocity = Vector3.ZERO
	await esperar(100)
	comprobar(camara.global_position.distance_to(jugador.global_position + camara.get("desplazamiento")) < 0.05, "Seguimiento original converge")
	var pantalla := camara.unproject_position(jugador.global_position + Vector3.UP * 0.8)
	comprobar(pantalla.distance_to(root.get_visible_rect().size * 0.5) < 4, "Protagonista centrado")
	if DisplayServer.get_name() != "headless":
		var vistas := {"plaza": Vector3(0,0.02,0), "norte": Vector3(-8,0.02,-13), "taberna_terraza": Vector3(-12,0.02,-15), "vivienda": Vector3(-20,0.02,-20), "sur": Vector3(8,0.02,22), "oeste": Vector3(-24,0.02,10), "ribera": Vector3(30,0.02,0)}
		for nombre in vistas:
			jugador.global_position = vistas[nombre]
			jugador.velocity = Vector3.ZERO
			await captura(nombre)
		# Camara solo de diagnostico; no se guarda ni se modifica la principal.
		var cenital := Camera3D.new()
		mundo.add_child(cenital)
		cenital.projection = Camera3D.PROJECTION_ORTHOGONAL
		cenital.size = 84
		cenital.position = Vector3(0,85,0)
		cenital.look_at(Vector3.ZERO, Vector3.FORWARD)
		cenital.make_current()
		await captura("cenital")
		camara.make_current()
		cenital.queue_free()
	print("RESULTADO_DISTRIBUCION: %d fallos; %d muestras de capsula/suelo; %d corredores" % [fallos,muestras,regiones.size()-1])
	quit(0 if fallos == 0 else 1)

func validar_herreria() -> void:
	var edificio: Node3D = aldea.get_node("Edificios/E03")
	var reserva := plano(aldea.get_node("Parcelas/E03/Marca"))
	comprobar(edificio.position.is_equal_approx(Vector3(-23,0.003,-6)) and edificio.scale == Vector3.ONE and edificio.get_meta("cuerpo") == Vector2(6,4), "E03: centro aprobado, cuerpo 6x4 y escala original")
	var visuales := true
	for m: MeshInstance3D in edificio.find_children("*","MeshInstance3D",true,false):
		var caja := m.global_transform * m.get_aabb()
		if not reserva.encloses(plano(m)) or caja.position.y < -0.04:
			print("FUERA E03: ",m.get_path()," ",caja)
		visuales = visuales and reserva.encloses(plano(m)) and caja.position.y >= -0.04
		for superficie in m.mesh.get_surface_count():
			visuales = visuales and m.get_active_material(superficie) != null
	comprobar(visuales,"E03: materiales presentes, mallas apoyadas y contenidas en reserva")
	var solido: StaticBody3D = edificio.get_node("Colisiones")
	var valido := true
	for forma: CollisionShape3D in solido.get_children():
		var caja: AABB = forma.global_transform * AABB(-forma.shape.size*0.5,forma.shape.size)
		var huella := Rect2(Vector2(caja.position.x,caja.position.z),Vector2(caja.size.x,caja.size.z))
		valido = valido and reserva.encloses(huella)
		for camino: Node3D in aldea.get_node("Caminos").get_children():
			valido = valido and not huella.intersects(plano(camino.get_node("Marca")))
		# Consulta la forma exacta en fisica, incluso en encuentros entre muros y postes.
		var sonda := PhysicsShapeQueryParameters3D.new()
		sonda.shape = forma.shape
		sonda.transform = forma.global_transform
		sonda.exclude = [jugador.get_rid()]
		var detectado := false
		for golpe in mundo.get_world_3d().direct_space_state.intersect_shape(sonda):
			detectado = detectado or golpe.collider == solido
		valido = detectado and valido
	comprobar(valido and solido.get_child_count() == 23,"E03: 23 cajas individuales verificadas, dentro de parcela y fuera de corredores")
	if valido and solido.get_child_count() == 23:
		solidos_herreria.append(solido)
	var libre := true
	# Camino publico este -> taller abierto; pasillo al sur del yunque.
	for i in 71:
		libre = suelo_libre(Vector2(lerpf(-14,-22,float(i)/70),-6)) and libre
	for i in 31:
		libre = suelo_libre(Vector2(lerpf(-22,-23,float(i)/30),-6)) and libre
	comprobar(libre,"E03: acceso publico, taller y espacio frente al yunque libres para capsula")
	jugador.global_position = Vector3(-18,0.02,-6)
	jugador.velocity = Vector3.ZERO
	await caminar("mover_izquierda",45)
	comprobar(jugador.is_on_floor() and jugador.position.x < -20.6,"E03: marcha real entra al cobertizo abierto")
	await caminar("mover_derecha",60)
	comprobar(jugador.position.x > -18.5,"E03: retorno real hacia camino publico")
	var control: CollisionShape3D = solido.get_node("Yunque")
	var original := control.position
	control.position = Vector3(3.9,0.54,0)
	await esperar(2)
	comprobar(not suelo_libre(Vector2(-19.1,-6)),"E03: control negativo detecta yunque bloqueando acceso")
	control.position = original
	await esperar(2)

func validar_vivienda_noreste() -> void:
	var edificio: Node3D = aldea.get_node("Edificios/E07")
	var parcela: Node3D = aldea.get_node("Parcelas/E07")
	var reserva := plano(parcela.get_node("Marca"))
	comprobar(edificio.position.is_equal_approx(Vector3(21,0.003,-24)) and edificio.scale == Vector3.ONE and edificio.get_meta("cuerpo") == Vector2(4,4), "E07: centro aprobado, cuerpo 4x4 sin escalar")
	comprobar(reserva.is_equal_approx(Rect2(17,-29,8,10)) and parcela.get_meta("acceso") == Vector2(18.2,-24), "E07: reserva 8x10 y acceso oeste originales")
	var visuales := true
	var cubierta := Rect2(Vector2(21,-24)-Vector2(2.8,2.8), Vector2(5.6,5.6))
	for m: MeshInstance3D in edificio.find_children("*","MeshInstance3D",true,false):
		var caja := m.global_transform * m.get_aabb()
		var valida := reserva.encloses(plano(m)) and caja.position.y >= -0.04
		for superficie in m.mesh.get_surface_count():
			valida = valida and m.get_active_material(superficie) != null
		if not valida:
			print("GEOMETRIA E07: ", m.get_path(), " ", caja)
		visuales = visuales and valida
		if edificio.get_node("Tejado").is_ancestor_of(m):
			comprobar(cubierta.encloses(plano(m)), "E07: cubierta dentro de huella 5.6x5.6: "+str(m.name))
	comprobar(visuales,"E07: recursos con material, dentro de parcela y sin objetos bajo suelo")
	var baja := plano(edificio.get_node("PlantaBaja/Norte"))
	var alta := plano(edificio.get_node("PlantaAlta/Norte"))
	comprobar(is_equal_approx(baja.size.x,4) and is_equal_approx(alta.size.x,4.5), "E07: planta alta 4.5x4.5, voladizo moderado de 0.25 por lado")
	var caras: PackedVector3Array = edificio.get_node("Tejado/Cubierta").mesh.get_faces()
	var cerrada := true
	var normales := true
	for i in range(0,caras.size(),3):
		normales = normales and (caras[i+1]-caras[i]).cross(caras[i+2]-caras[i]).y < 0
	for x in [-2.5,-1.0,0.0,1.0,2.5]:
		for z in [-2.5,-1.0,0.0,1.0,2.5]:
			var golpe := false
			for i in range(0,caras.size(),3):
				golpe = golpe or Geometry3D.segment_intersects_triangle(Vector3(x,8,z),Vector3(x,4.8,z),caras[i],caras[i+1],caras[i+2]) != null
			cerrada = cerrada and golpe
	comprobar(cerrada and normales,"E07: cubierta cerrada en 25 rayos, caras exteriores orientadas hacia arriba")
	var apoyados := true
	for nombre in ["Banco","BarrilAgua","Cubo","Saco"]:
		for m: MeshInstance3D in edificio.get_node("DecoracionExterior/"+nombre).find_children("*","MeshInstance3D",true,false):
			var caja := m.global_transform * m.get_aabb()
			apoyados = apoyados and caja.position.y >= -0.01 and caja.position.y <= 0.05
	comprobar(apoyados,"E07: banco, barril, cubo y saco apoyados a menos de 5 cm del terreno")
	var solido: StaticBody3D = edificio.get_node("Colisiones")
	var valido := solido.get_child_count() == 12
	for forma: CollisionShape3D in solido.get_children():
		var caja: AABB = forma.global_transform * AABB(-forma.shape.size*0.5,forma.shape.size)
		var huella := Rect2(Vector2(caja.position.x,caja.position.z),Vector2(caja.size.x,caja.size.z))
		valido = valido and reserva.encloses(huella) and not forma.disabled
		for camino: Node3D in aldea.get_node("Caminos").get_children():
			valido = valido and not huella.intersects(plano(camino.get_node("Marca")))
		var sonda := PhysicsShapeQueryParameters3D.new()
		sonda.shape = forma.shape
		sonda.transform = forma.global_transform
		sonda.exclude = [jugador.get_rid()]
		var detectado := false
		for golpe in mundo.get_world_3d().direct_space_state.intersect_shape(sonda):
			detectado = detectado or golpe.collider == solido
		valido = valido and detectado
	comprobar(valido,"E07: doce formas individuales activas, contenidas y fuera de todos los corredores")
	if valido:
		solidos_e07.append(solido)
	var barridos := 0
	for dir in [Vector3.FORWARD,Vector3.BACK,Vector3.LEFT,Vector3.RIGHT]:
		for lateral in [-1.0,0.0,1.0]:
			var origen: Vector3 = edificio.global_position + dir*3.0 + Vector3(-dir.z,0,dir.x)*lateral
			origen.y = 1.0
			var golpe := KinematicCollision3D.new()
			if jugador.test_move(Transform3D(Basis.IDENTITY,origen),-dir*1.5,golpe) and golpe.get_collider() == solido:
				barridos += 1
	comprobar(barridos == 12,"E07: doce barridos de capsula contra cuatro muros perimetrales")
	var libre := true
	for i in 51:
		libre = suelo_libre(Vector2(lerpf(14.25,18.5,float(i)/50),-24)) and libre
	comprobar(libre,"E07: acceso oeste desde ramal publico hasta puerta libre")
	var puntos := [Vector2(17.5,-24),Vector2(17.5,-28.5),Vector2(24.65,-28.5),Vector2(24.65,-19.5),Vector2(17.5,-19.5),Vector2(17.5,-24)]
	var circuito := true
	for i in range(puntos.size()-1):
		for j in 81:
			circuito = suelo_libre(puntos[i].lerp(puntos[i+1],float(j)/80)) and circuito
	comprobar(circuito,"E07: circuito exterior completo con capsula y apoyo")
	jugador.global_position = Vector3(17.5,0.02,-24)
	jugador.velocity = Vector3.ZERO
	await caminar("mover_derecha",50)
	comprobar(jugador.is_on_floor() and jugador.position.x > 18.3 and jugador.position.x < 18.75,"E07: marcha real llega a puerta oeste cerrada")
	var control: CollisionShape3D = solido.get_node("BarrilAgua")
	var original := control.position
	control.position = Vector3(-2.8,0.5,0)
	await esperar(2)
	comprobar(not suelo_libre(Vector2(18.2,-24)),"E07: control negativo detecta barril bloqueando acceso")
	control.position = original
	await esperar(2)

func validar_panaderia() -> void:
	var edificio: Node3D = aldea.get_node("Edificios/E02")
	var reserva := plano(aldea.get_node("Parcelas/E02/Marca"))
	comprobar(edificio.position.is_equal_approx(Vector3(8,0.003,-20)) and edificio.get_meta("cuerpo") == Vector2(4,6), "E02: centro aprobado y cuerpo 4x6")
	var visuales := true
	for m: MeshInstance3D in edificio.find_children("*", "MeshInstance3D", true, false):
		if not reserva.encloses(plano(m)):
			print("FUERA E02: ",m.get_path()," ",plano(m))
		visuales = visuales and reserva.encloses(plano(m))
		for superficie in m.mesh.get_surface_count():
			visuales = visuales and m.get_active_material(superficie) != null
	comprobar(visuales,"E02: todas las mallas con materiales y contenidas en parcela")
	var cubierta: Node3D = edificio.get_node("Tejado/Cubierta")
	comprobar(cubierta.position.is_equal_approx(Vector3(0,3,0)) and cubierta.scale.is_equal_approx(Vector3(1,0.6,1)),"E02: cubierta y frontones con proporcion aprobada, sin escalar cuerpo")
	var conducto: MeshInstance3D = edificio.get_node("Horno/Conducto")
	var libre_cubierta := true
	for m: MeshInstance3D in cubierta.find_children("*","MeshInstance3D",true,false):
		libre_cubierta = libre_cubierta and not plano(conducto).intersects(plano(m))
	comprobar(libre_cubierta,"E02: conducto exterior separado de la cubierta")
	var solido: StaticBody3D = edificio.get_node("Colisiones")
	var formas := 0
	var valido := true
	for forma: CollisionShape3D in solido.get_children():
		var caja: AABB = forma.global_transform * AABB(-forma.shape.size*0.5,forma.shape.size)
		var huella := Rect2(Vector2(caja.position.x,caja.position.z),Vector2(caja.size.x,caja.size.z))
		valido = valido and reserva.encloses(huella)
		for camino: Node3D in aldea.get_node("Caminos").get_children():
			valido = valido and not huella.intersects(plano(camino.get_node("Marca")))
		formas += 1
	comprobar(valido and formas == 8,"E02: ocho cajas simples, paredes perimetrales, mostrador, horno, barril y caja; fuera de corredores")
	if valido and formas == 8:
		solidos_panaderia.append(solido)
	var circuito := true
	for i in 41:
		var t := float(i)/40.0
		for punto in [Vector2(lerpf(3.7,11.5,t),-24.5),Vector2(lerpf(3.7,11.5,t),-15.5),Vector2(3.7,lerpf(-24.5,-15.5,t)),Vector2(11.5,lerpf(-24.5,-15.5,t))]:
			circuito = suelo_libre(punto) and circuito
	comprobar(circuito,"E02: circuito exterior de capsula libre rodea edificio y horno dentro de parcela")
	var ruta_libre := true
	# Desde el eje publico hasta la puerta sur desplazada medio metro.
	for i in 31:
		var z := -12.0-float(i)*0.14
		ruta_libre = suelo_libre(Vector2(8.5,z)) and ruta_libre
	comprobar(ruta_libre,"E02: capsula libre desde calle norte hasta aproximacion a puerta")
	jugador.global_position = Vector3(8.5,0.02,-14)
	jugador.velocity = Vector3.ZERO
	await caminar("mover_arriba",70)
	comprobar(jugador.is_on_floor() and jugador.position.z < -16.1 and jugador.position.z > -16.6,"E02: marcha real alcanza puerta cerrada sin bloqueo comercial")
	await caminar("mover_abajo",70)
	comprobar(jugador.position.z > -13.0,"E02: retorno desde entrada al camino publico")
	var control: CollisionShape3D = solido.get_node("Mostrador")
	var original := control.position
	control.position = Vector3(0.5,0.89,4.2)
	await esperar(2)
	comprobar(not suelo_libre(Vector2(8.5,-15.8)),"E02: control negativo detecta mostrador bloqueando entrada")
	control.position = original
	await esperar(2)
func validar_carpinteria() -> void:
	var edificio: Node3D = aldea.get_node("Edificios/E04")
	var reserva := plano(aldea.get_node("Parcelas/E04/Marca"))
	comprobar(edificio.position.is_equal_approx(Vector3(-23,0.003,7)) and edificio.scale == Vector3.ONE and edificio.get_meta("cuerpo") == Vector2(6,4), "E04: centro aprobado, cuerpo 6x4 y escala original")
	var visuales := true
	for m: MeshInstance3D in edificio.find_children("*","MeshInstance3D",true,false):
		var caja := m.global_transform * m.get_aabb()
		if not reserva.encloses(plano(m)) or caja.position.y < -0.04:
			print("FUERA E04: ",m.get_path()," ",caja)
		visuales = visuales and reserva.encloses(plano(m)) and caja.position.y >= -0.04
		for superficie in m.mesh.get_surface_count():
			visuales = visuales and m.get_active_material(superficie) != null
	comprobar(visuales,"E04: materiales presentes, mallas apoyadas y contenidas en reserva")
	var solido: StaticBody3D = edificio.get_node("Colisiones")
	var valido := true
	for forma: CollisionShape3D in solido.get_children():
		var caja: AABB = forma.global_transform * AABB(-forma.shape.size*0.5,forma.shape.size)
		var huella := Rect2(Vector2(caja.position.x,caja.position.z),Vector2(caja.size.x,caja.size.z))
		valido = valido and reserva.encloses(huella)
		for camino: Node3D in aldea.get_node("Caminos").get_children():
			valido = valido and not huella.intersects(plano(camino.get_node("Marca")))
		# Consulta la forma exacta en fisica, incluso en encuentros entre muros y postes.
		var sonda := PhysicsShapeQueryParameters3D.new()
		sonda.shape = forma.shape
		sonda.transform = forma.global_transform
		sonda.exclude = [jugador.get_rid()]
		var detectado := false
		for golpe in mundo.get_world_3d().direct_space_state.intersect_shape(sonda):
			detectado = detectado or golpe.collider == solido
		valido = detectado and valido
	comprobar(valido and solido.get_child_count() == 13,"E04: 13 cajas individuales verificadas, dentro de parcela y fuera de corredores")
	if valido and solido.get_child_count() == 13:
		solidos_carpinteria.append(solido)
	var libre := true
	# Camino publico este -> taller abierto; pasillo al sur del puesto de corte.
	for i in 71:
		libre = suelo_libre(Vector2(lerpf(-14,-22,float(i)/70),7)) and libre
	for i in 31:
		libre = suelo_libre(Vector2(lerpf(-22,-23,float(i)/30),7)) and libre
	comprobar(libre,"E04: acceso publico, taller y espacio frente al puesto de corte libres para capsula")
	var puestos_libres := true
	for i in 41:
		var x := lerpf(-24.1,-20.8,float(i)/40)
		puestos_libres = suelo_libre(Vector2(x,7)) and puestos_libres
	comprobar(puestos_libres,"E04: pasillo continuo frente al banco y los caballetes accesible")
	jugador.global_position = Vector3(-18,0.02,7)
	jugador.velocity = Vector3.ZERO
	await caminar("mover_izquierda",45)
	comprobar(jugador.is_on_floor() and jugador.position.x < -20.6,"E04: marcha real entra al taller abierto")
	await caminar("mover_derecha",60)
	comprobar(jugador.position.x > -18.5,"E04: retorno real hacia camino publico")
	var control: CollisionShape3D = solido.get_node("Corte")
	var original := control.position
	control.position = Vector3(3.9,0.54,0)
	await esperar(2)
	comprobar(not suelo_libre(Vector2(-19.1,7)),"E04: control negativo detecta puesto de corte bloqueando acceso")
	control.position = original
	await esperar(2)

func validar_herbolario() -> void:
	var edificio: Node3D = aldea.get_node("Edificios/E05")
	var reserva := plano(aldea.get_node("Parcelas/E05/Marca"))
	comprobar(edificio.position.is_equal_approx(Vector3(21,0.003,8)) and edificio.scale == Vector3.ONE and edificio.get_meta("cuerpo") == Vector2(4,4), "E05: centro, cuerpo y escala aprobados")
	var visuales := true
	for m: MeshInstance3D in edificio.find_children("*","MeshInstance3D",true,false):
		var caja := m.global_transform * m.get_aabb()
		if not reserva.encloses(plano(m)) or caja.position.y < -0.04:
			print("FUERA E05: ",m.get_path()," ",caja)
		visuales = visuales and reserva.encloses(plano(m)) and caja.position.y >= -0.04
		for superficie in m.mesh.get_surface_count():
			visuales = visuales and m.get_active_material(superficie) != null
	comprobar(visuales,"E05: materiales y mallas dentro de parcela, sin geometria bajo suelo")
	var solido: StaticBody3D = edificio.get_node("Colisiones")
	var valido := true
	for forma: CollisionShape3D in solido.get_children():
		var caja: AABB = forma.global_transform * AABB(-forma.shape.size*0.5,forma.shape.size)
		var huella := Rect2(Vector2(caja.position.x,caja.position.z),Vector2(caja.size.x,caja.size.z))
		valido = valido and reserva.encloses(huella) and not forma.disabled
		for camino: Node3D in aldea.get_node("Caminos").get_children():
			valido = valido and not huella.intersects(plano(camino.get_node("Marca")))
		var sonda := PhysicsShapeQueryParameters3D.new()
		sonda.shape = forma.shape
		sonda.transform = forma.global_transform
		sonda.exclude = [jugador.get_rid()]
		var detectado := false
		for golpe in mundo.get_world_3d().direct_space_state.intersect_shape(sonda):
			detectado = detectado or golpe.collider == solido
		valido = detectado and valido
	comprobar(valido and solido.get_child_count() == 16,"E05: 16 formas activas individuales, contenidas y fuera de corredores")
	if valido and solido.get_child_count() == 16:
		solidos_herbolario.append(solido)
	var libre := true
	for i in 51:
		libre = suelo_libre(Vector2(lerpf(14,18.5,float(i)/50),8)) and libre
	comprobar(libre,"E05: acceso oeste continuo hasta puerta")
	# Recorrido exterior y aproximaciones a mesa, secadero y jardin.
	var puntos := [Vector2(17.25,8),Vector2(17.25,11.1),Vector2(17.25,12.8),Vector2(24.65,12.8),Vector2(24.65,3.35),Vector2(17.25,3.35),Vector2(17.25,8)]
	var circuito := true
	for i in range(puntos.size()-1):
		for j in 51:
			circuito = suelo_libre(puntos[i].lerp(puntos[i+1],float(j)/50)) and circuito
	comprobar(circuito,"E05: circuito con capsula alrededor de jardin y anexos")
	comprobar(suelo_libre(Vector2(18.05,11.4)) and suelo_libre(Vector2(21,10.5)) and suelo_libre(Vector2(21,3.8)), "E05: aproximacion a mesa, bancales y secadero")
	jugador.global_position = Vector3(17.4,0.02,8)
	jugador.velocity = Vector3.ZERO
	await caminar("mover_derecha",50)
	comprobar(jugador.is_on_floor() and jugador.position.x > 18.3 and jugador.position.x < 18.75,"E05: marcha real llega a puerta cerrada sin atravesarla")
	var control: CollisionShape3D = solido.get_node("Mesa")
	var original := control.position
	control.position = Vector3(-2.8,0.52,0)
	await esperar(2)
	comprobar(not suelo_libre(Vector2(18.2,8)),"E05: control negativo detecta mesa bloqueando acceso")
	control.position = original
	await esperar(2)

# Viviendas rurales independientes. Ninguna excepcion sobre corredores o huertos.
func validar_vivienda_final(id: String) -> void:
	var edificio: Node3D = aldea.get_node("Edificios/"+id)
	var centro := Vector2(8,25) if id == "E10" else Vector2(18,24)
	var parcela: Node3D = aldea.get_node("Parcelas/"+id)
	var reserva := plano(parcela.get_node("Marca"))
	comprobar(edificio.position.is_equal_approx(Vector3(centro.x,0.003,centro.y)) and edificio.scale == Vector3.ONE and edificio.get_meta("cuerpo") == Vector2(4,4),id+": centro original y cuerpo 4x4")
	comprobar(reserva.is_equal_approx(Rect2(centro-Vector2(4 if id == "E10" else 5,5),Vector2(8 if id == "E10" else 10,10))) and parcela.get_meta("acceso") == centro+Vector2(0,-2.8),id+": reserva y acceso norte originales")
	var visuales := true
	for m: MeshInstance3D in edificio.find_children("*","MeshInstance3D",true,false):
		var caja := m.global_transform*m.get_aabb()
		var valida := reserva.encloses(plano(m)) and caja.position.y >= -0.04
		for superficie in m.mesh.get_surface_count():
			valida = valida and m.get_active_material(superficie) != null
		for jardin: Node3D in aldea.get_node("Jardines").get_children():
			valida = valida and not plano(jardin.get_node("Marca")).intersects(plano(m))
		for camino: Node3D in aldea.get_node("Caminos").get_children():
			if camino.get_meta("acceso_parcela") != id:
				valida = valida and not plano(camino.get_node("Marca")).intersects(plano(m))
		if not valida:
			print("GEOMETRIA ",m.get_path()," ",caja)
		visuales = visuales and valida
	comprobar(visuales,id+": materiales, apoyos, parcelas, corredores y reservas")
	var cubierta_dentro := true
	var envolvente := Rect2(centro-Vector2(2.8,2.8),Vector2(5.6,5.6))
	for m: MeshInstance3D in edificio.get_node("Tejado").find_children("*","MeshInstance3D",true,false):
		cubierta_dentro = envolvente.encloses(plano(m)) and cubierta_dentro
	comprobar(cubierta_dentro,id+": cubierta principal dentro de huella original 5.6x5.6")
	var apoyados := true
	var utileria := ["Semillas","Verduras","Barril","Cubo","SacoTrasero"] if id == "E10" else ["Banco","Barril"]
	for nombre in utileria:
		var minimo := INF
		for m: MeshInstance3D in edificio.get_node("Exterior/"+nombre).find_children("*","MeshInstance3D",true,false):
			minimo = minf(minimo,(m.global_transform*m.get_aabb()).position.y)
		apoyados = minimo >= -0.02 and minimo <= 0.05 and apoyados
	comprobar(apoyados,id+": utileria importada apoyada en suelo")
	var solido: StaticBody3D = edificio.get_node("Colisiones")
	var valido := solido.get_child_count() == (12 if id == "E10" else 15)
	for forma: CollisionShape3D in solido.get_children():
		var caja: AABB = forma.global_transform*AABB(-forma.shape.size*.5,forma.shape.size)
		var huella := Rect2(Vector2(caja.position.x,caja.position.z),Vector2(caja.size.x,caja.size.z))
		valido = valido and reserva.encloses(huella) and not forma.disabled
		for camino: Node3D in aldea.get_node("Caminos").get_children():
			valido = valido and not huella.intersects(plano(camino.get_node("Marca")))
		var sonda := PhysicsShapeQueryParameters3D.new()
		sonda.shape = forma.shape
		sonda.transform = forma.global_transform
		sonda.exclude = [jugador.get_rid()]
		var detectado := false
		for golpe in mundo.get_world_3d().direct_space_state.intersect_shape(sonda):
			detectado = detectado or golpe.collider == solido
		if not detectado or not reserva.encloses(huella):
			print("FORMA INVALIDA ",id," ",forma.name," ",huella," detectada ",detectado)
		for camino: Node3D in aldea.get_node("Caminos").get_children():
			if huella.intersects(plano(camino.get_node("Marca"))):
				print("FORMA EN CAMINO ",id," ",forma.name," ",camino.name)
		valido = valido and detectado
	comprobar(valido,id+": formas individuales activas y fuera de corredores: "+str(solido.get_child_count()))
	if valido and solido not in solidos_rurales:
		solidos_rurales.append(solido)
	var cerrada := true
	for x in [-1.8,-.9,0.0,.9,1.8]:
		for z in [-1.8,-.9,0.0,.9,1.8]:
			var golpe := false
			for m: MeshInstance3D in edificio.get_node("Tejado").find_children("Base*","MeshInstance3D",true,false):
				var caras := m.mesh.get_faces()
				for i in range(0,caras.size(),3):
					golpe = golpe or Geometry3D.segment_intersects_triangle(Vector3(centro.x+x,8,centro.y+z),Vector3(centro.x+x,2.5,centro.y+z),m.global_transform*caras[i],m.global_transform*caras[i+1],m.global_transform*caras[i+2]) != null
			cerrada = cerrada and golpe
	comprobar(cerrada,id+": cubierta continua en 25 rayos")
	var barridos := 0
	for dir in [Vector3.FORWARD,Vector3.BACK,Vector3.LEFT,Vector3.RIGHT]:
		for lateral in [-1.0,0.0,1.0]:
			var origen: Vector3 = edificio.global_position+dir*2.65+Vector3(-dir.z,0,dir.x)*lateral
			origen.y = 1.5
			var golpe := KinematicCollision3D.new()
			if jugador.test_move(Transform3D(Basis.IDENTITY,origen),-dir,golpe) and golpe.get_collider() == solido:
				barridos += 1
	comprobar(barridos == 12,id+": doce barridos de muros")
	var libre := true
	for i in 101:
		libre = suelo_libre(centro+Vector2(0,lerpf(-7,-2.8,float(i)/100))) and libre
	comprobar(libre,id+": acceso norte desde camino publico libre")
	var dx := 3.62 if id == "E10" else 4.6
	var puntos := [Vector2(-dx,-4.6),Vector2(dx,-4.6),Vector2(dx,4.6),Vector2(-dx,4.6),Vector2(-dx,-4.6)]
	var circuito := true
	for i in range(4):
		for j in 101:
			circuito = suelo_libre(centro+puntos[i].lerp(puntos[i+1],float(j)/100)) and circuito
	comprobar(circuito,id+": circuito completo con capsula")
	jugador.global_position = Vector3(centro.x,.02,centro.y-4)
	jugador.velocity = Vector3.ZERO
	await caminar("mover_abajo",45)
	comprobar(jugador.is_on_floor() and jugador.position.z > centro.y-2.7 and jugador.position.z < centro.y-2.28,id+": marcha real a puerta norte cerrada")
	await caminar("mover_arriba",20)
	comprobar(jugador.position.z < centro.y-4,id+": retorno real al camino")
	var control: CollisionShape3D = solido.get_node("Barril")
	var original := control.position
	control.position = Vector3(0,.5,-2.8)
	await esperar(2)
	comprobar(not suelo_libre(centro+Vector2(0,-2.8)),id+": control negativo de bloqueo")
	control.position = original
	await esperar(2)
	comprobar(edificio.has_node("Anexo/FondoAnexo") if id == "E10" else edificio.has_node("Portico/Arco8"),id+": arquitectura diferenciada")

func validar_vivienda_rural(id: String) -> void:
	var edificio: Node3D = aldea.get_node("Edificios/" + id)
	var centro := Vector2(-24,23) if id == "E08" else Vector2(-8,24)
	var parcela: Node3D = aldea.get_node("Parcelas/" + id)
	var reserva := plano(parcela.get_node("Marca"))
	comprobar(edificio.position.is_equal_approx(Vector3(centro.x,0.003,centro.y)) and edificio.scale == Vector3.ONE and edificio.get_meta("cuerpo") == Vector2(4,4),id+": centro aprobado y cuerpo 4x4 sin escalar")
	comprobar(reserva.is_equal_approx(Rect2(centro-Vector2(5,5),Vector2(10,10))) and parcela.get_meta("acceso") == centro+Vector2(0,-2.8),id+": reserva 10x10 y acceso norte originales")
	var visuales := true
	var huella_cubierta := Rect2(centro-Vector2(2.8,2.8),Vector2(5.6,5.6))
	for m: MeshInstance3D in edificio.find_children("*","MeshInstance3D",true,false):
		var caja := m.global_transform*m.get_aabb()
		var valida := reserva.encloses(plano(m)) and caja.position.y >= -0.04
		for superficie in m.mesh.get_surface_count():
			valida = valida and m.get_active_material(superficie) != null
		for jardin: Node3D in aldea.get_node("Jardines").get_children():
			valida = valida and not plano(jardin.get_node("Marca")).intersects(plano(m))
		if not valida:
			print("GEOMETRIA ",id,": ",m.get_path()," ",caja)
		visuales = visuales and valida
		if edificio.get_node("Tejado").is_ancestor_of(m):
			if not huella_cubierta.encloses(plano(m)):
				print("CUBIERTA ",id,": ",m.name," ",plano(m))
			visuales = visuales and huella_cubierta.encloses(plano(m))
	comprobar(visuales,id+": materiales, apoyos, parcela, huertos y envolvente de cubierta respetados")
	var apoyados := true
	var nombres := ["Banco","Barril","Cubo","Saco","CajaAgricola"] if id == "E08" else ["Banco","Barril","CestaVerduras","Semillas"]
	for nombre in nombres:
		var minimo := INF
		for m: MeshInstance3D in edificio.get_node("Exterior/"+nombre).find_children("*","MeshInstance3D",true,false):
			var caja := m.global_transform*m.get_aabb()
			minimo = minf(minimo,caja.position.y)
		apoyados = apoyados and minimo >= -0.02 and minimo <= 0.05
	comprobar(apoyados,id+": utileria apoyada en suelo, sin objetos flotantes")
	if id == "E09":
		comprobar(suelo_libre(centro+Vector2(3.1,0.1)) and suelo_libre(centro+Vector2(3.2,1.65)),id+": galeria transitable entre mesa, banco y postes")
	var cerrada := true
	for x in [-1.8,-0.9,0.0,0.9,1.8]:
		for z in [-1.8,-0.9,0.0,0.9,1.8]:
			var golpe := false
			for m: MeshInstance3D in edificio.get_node("Tejado").find_children("*","MeshInstance3D",true,false):
				if not (String(m.name).begins_with("Base") or String(m.name).begins_with("Haz") or String(m.name).begins_with("Placa")):
					continue
				var caras := m.mesh.get_faces()
				for i in range(0,caras.size(),3):
					var a: Vector3 = m.global_transform*caras[i]
					var b: Vector3 = m.global_transform*caras[i+1]
					var c: Vector3 = m.global_transform*caras[i+2]
					golpe = golpe or Geometry3D.segment_intersects_triangle(Vector3(centro.x+x,7,centro.y+z),Vector3(centro.x+x,2.5,centro.y+z),a,b,c) != null
			cerrada = cerrada and golpe
	comprobar(cerrada,id+": 25 rayos verifican cobertura continua")
	var solido: StaticBody3D = edificio.get_node("Colisiones")
	var esperado := 10 if id == "E08" else 12
	var valido := solido.get_child_count() == esperado
	for forma: CollisionShape3D in solido.get_children():
		var caja: AABB = forma.global_transform*AABB(-forma.shape.size*0.5,forma.shape.size)
		var huella := Rect2(Vector2(caja.position.x,caja.position.z),Vector2(caja.size.x,caja.size.z))
		valido = valido and reserva.encloses(huella) and not forma.disabled
		for camino: Node3D in aldea.get_node("Caminos").get_children():
			valido = valido and not huella.intersects(plano(camino.get_node("Marca")))
		var sonda := PhysicsShapeQueryParameters3D.new()
		sonda.shape = forma.shape
		sonda.transform = forma.global_transform
		sonda.exclude = [jugador.get_rid()]
		var detectado := false
		for golpe in mundo.get_world_3d().direct_space_state.intersect_shape(sonda):
			detectado = detectado or golpe.collider == solido
		valido = valido and detectado
		if not valido:
			print("FORMA ",id,": ",forma.name," ",huella)
	comprobar(valido,id+": "+str(esperado)+" colisiones individuales activas, contenidas y fuera de corredores")
	if valido and solido not in solidos_rurales:
		solidos_rurales.append(solido)
	var barridos := 0
	for dir in [Vector3.FORWARD,Vector3.BACK,Vector3.LEFT,Vector3.RIGHT]:
		for lateral in [-1.0,0.0,1.0]:
			var origen: Vector3 = edificio.global_position+dir*2.65+Vector3(-dir.z,0,dir.x)*lateral
			origen.y = 1.5
			var golpe := KinematicCollision3D.new()
			if jugador.test_move(Transform3D(Basis.IDENTITY,origen),-dir*1.0,golpe) and golpe.get_collider() == solido:
				barridos += 1
	comprobar(barridos == 12,id+": doce barridos de capsula contra muros")
	var dx := 0.0 if id == "E08" else -0.55
	var libre := true
	for i in 61:
		libre = suelo_libre(centro+Vector2(0,lerpf(-7,-2.8,float(i)/60))) and libre
		libre = suelo_libre(centro+Vector2(lerpf(0,dx,float(i)/60),-2.8)) and libre
	comprobar(libre,id+": acceso desde camino publico y aproximacion a puerta libres")
	var puntos := [Vector2(-4.6,-4.6),Vector2(4.6,-4.6),Vector2(4.6,4.6),Vector2(-4.6,4.6),Vector2(-4.6,-4.6)]
	var circuito := true
	for i in range(puntos.size()-1):
		for j in 101:
			circuito = suelo_libre(centro+puntos[i].lerp(puntos[i+1],float(j)/100)) and circuito
	comprobar(circuito,id+": circuito exterior completo con capsula y apoyo")
	jugador.global_position = Vector3(centro.x+dx,0.02,centro.y-4)
	jugador.velocity = Vector3.ZERO
	await caminar("mover_abajo",45)
	comprobar(jugador.is_on_floor() and jugador.position.z > centro.y-2.7 and jugador.position.z < centro.y-2.28,id+": marcha real alcanza puerta cerrada")
	await caminar("mover_arriba",20)
	comprobar(jugador.position.z < centro.y-4,id+": retorno real al camino publico")
	var control: CollisionShape3D = solido.get_node("Barril")
	var original := control.position
	control.position = Vector3(0,0.5,-2.8)
	await esperar(2)
	comprobar(not suelo_libre(centro+Vector2(0,-2.8)),id+": control negativo detecta barril en acceso")
	control.position = original
	await esperar(2)
	if id == "E08":
		comprobar(edificio.get_node("Tejado").find_children("Haz*","MeshInstance3D",true,false).size() == 144,id+": paja con haces en relieve y cumbrera, sin segunda planta")
	else:
		comprobar(edificio.has_node("Galeria/CubiertaSecundaria") and edificio.get_node("Tejado").find_children("Placa*","MeshInstance3D",true,false).size() == 108,id+": pizarra en placas, cumbrera descentrada y galeria lateral")
