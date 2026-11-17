extends "res://tests/validar_interior_taberna.gd"
## Tres circuitos por edificio. Aproximación exterior desde fixture próxima;
## recorridos interiores mediante Input y controlador original, sin teletransporte.
var datos: Array
var resultados: Array = []
var caminatas_animadas: Dictionary = {}

func observar_animaciones() -> void:
	if not is_instance_valid(current_scene): return
	var j := current_scene.get_node_or_null("Jugador") as CharacterBody3D
	if j == null or not j.en_movimiento: return
	var sprite := j.get_node("Visual/SpriteAnimado") as AnimatedSprite3D
	if sprite.is_playing() and String(sprite.animation).begins_with("walk_"):
		caminatas_animadas[String(gestor.region_actual)] = true

func vector(a: Array) -> Vector3:
	return Vector3(a[0],a[1],a[2])

func iniciar() -> void:
	carpeta = "res://logs/interiores_e02_e11/ejecucion_"+Time.get_datetime_string_from_system().replace(":","-")+"_"+str(Time.get_ticks_msec())
	DirAccess.make_dir_recursive_absolute(carpeta)
	datos = JSON.parse_string(FileAccess.get_file_as_string("res://scripts/interiores/edificios_interiores.json"))
	for argumento in OS.get_cmdline_user_args():
		if argumento.begins_with("--edificios="):
			var ids := argumento.trim_prefix("--edificios=").split(",")
			datos = datos.filter(func(d: Dictionary) -> bool: return d.id in ids)
	gestor = root.get_node("GestorRegiones")
	process_frame.connect(observar_animaciones)
	var mundo := (load("res://scenes/mundo.tscn") as PackedScene).instantiate()
	root.add_child(mundo)
	current_scene = mundo
	await cuadros(15)
	for d: Dictionary in datos:
		var antes := fallos
		var punto := vector(d.puerta)
		var normal := vector(d.normal)
		for ciclo in 3:
			var jugador := current_scene.get_node("Jugador") as CharacterBody3D
			jugador.position = punto + normal*2.7 + Vector3.UP*0.07
			jugador.velocity = Vector3.ZERO
			await cuadros(15)
			comprobar(not current_scene.get_node("Puerta"+d.id+"/Aviso").visible,d.id+" aviso fuera de rango")
			await pulsar_f()
			comprobar(not gestor.en_transicion,d.id+" F fuera de rango no entra")
			await caminar(punto)
			comprobar(current_scene.get_node("Puerta"+d.id+"/Aviso").visible,d.id+" aviso frente al acceso real")
			var cercanas := 0
			for puerta in current_scene.find_children("*","Area3D",true,false):
				if puerta.get_script()==load("res://scripts/interiores/puerta_interior.gd") and puerta.habilitada: cercanas += 1
			comprobar(cercanas == 1,d.id+" solo una puerta habilitada")
			if ciclo == 0: await captura(d.id+"_exterior")
			await pulsar_f()
			comprobar(gestor.en_transicion,d.id+" F inicia fundido")
			comprobar(not gestor.solicitar(d.escena,"interior_"+String(d.id).to_lower()),d.id+" bloqueo simultaneo")
			await esperar_transicion(StringName("Interior"+d.id))
			if gestor.region_actual!=StringName("Interior"+d.id):
				quit(1)
				return
			jugador = current_scene.get_node("Jugador")
			var entrada: Marker3D = current_scene.get_node("Region/Entrada")
			comprobar(jugador.position.distance_to(entrada.position)<0.2,d.id+" aparicion segura")
			comprobar(jugador.get_node("Visual/SpriteAnimado") is AnimatedSprite3D and jugador.velocidad == 10,d.id+" protagonista sin alterar")
			comprobar(root.find_children("*","CharacterBody3D",true,false).size()==1,d.id+" jugador unico")
			comprobar(root.find_children("*","Camera3D",true,false).size()==1,d.id+" camara unica")
			if ciclo == 0: await captura(d.id+"_entrada")
			var recorrido: PackedVector3Array = current_scene.get_meta("recorrido")
			for p in recorrido: await caminar(p)
			if ciclo == 0:
				await comprobar_escena(d)
			for i in range(recorrido.size()-1,-1,-1): await caminar(recorrido[i])
			comprobar(String(jugador.get_node("Visual/SpriteAnimado").animation).begins_with("idle"),d.id+" animacion reposo")
			comprobar(caminatas_animadas.has("Interior"+d.id),d.id+" animacion walk reproducida durante recorrido")
			comprobar(current_scene.get_node("Salida/Aviso").visible,d.id+" salida alcanzable")
			await pulsar_f()
			await esperar_transicion(&"Aldea")
			jugador = current_scene.get_node("Jugador")
			var retorno := current_scene.get_node("Region/Entrada"+d.id) as Marker3D
			comprobar(jugador.position.distance_to(retorno.position)<0.2,d.id+" retorna a su acceso propio")
			comprobar(current_scene.get_node("CamaraPrincipal").size == 15,d.id+" camara exterior conservada")
			await cuadros(30)
			comprobar(not gestor.en_transicion and gestor.region_actual==&"Aldea",d.id+" sin reentrada automatica")
		resultados.append({"id":d.id,"fallos":fallos-antes,"ciclos":3})
		print("INTERIOR_RESULTADO ",d.id," fallos=",fallos-antes," ciclos=3")
	var archivo := FileAccess.open(carpeta+"/resultados.json",FileAccess.WRITE)
	archivo.store_string(JSON.stringify({"fallos":fallos,"comprobaciones":comprobaciones,"edificios":resultados},"\t"))
	print("INTERIORES: ",fallos," fallos / ",comprobaciones," comprobaciones; ",datos.size()*3," ciclos / ",datos.size()*6," viajes. Evidencias: ",carpeta)
	quit(1 if fallos else 0)

func comprobar_escena(d: Dictionary) -> void:
	var dimensiones: Vector2 = current_scene.get_meta("dimensiones")
	var mallas := current_scene.find_children("*","MeshInstance3D",true,false)
	for m: MeshInstance3D in mallas:
		for superficie in m.mesh.get_surface_count():
			comprobar(m.get_active_material(superficie)!=null,d.id+" material presente "+str(m.name))
	# Contención de modelos importados, con tolerancia del marco decorativo.
	for n: Node3D in current_scene.get_node("Mobiliario").get_children():
		if n.has_meta("asset"):
			for m: MeshInstance3D in n.find_children("*","MeshInstance3D",true,false):
				var caja := m.global_transform*m.get_aabb()
				comprobar(caja.position.x > -dimensiones.x/2-0.12 and caja.end.x < dimensiones.x/2+0.12 and caja.position.z > -dimensiones.y/2-0.12 and caja.end.z < dimensiones.y/2+0.12,d.id+" modelo contenido "+str(n.name))
	var jugador := current_scene.get_node("Jugador") as CharacterBody3D
	var origen := jugador.global_transform
	origen.origin = Vector3(0,0.04,0)
	comprobar(jugador.test_move(origen,Vector3(dimensiones.x,0,0)),d.id+" pared bloquea capsula")
	# Cada cuerpo mayor tiene forma física propia; consulta con cápsula en volumen.
	for cuerpo in current_scene.get_node("Colisiones").get_children():
		comprobar(cuerpo.get_child_count()>0,d.id+" cuerpo con colision "+str(cuerpo.name))
		var forma := cuerpo.get_child(0) as CollisionShape3D
		var consulta := PhysicsShapeQueryParameters3D.new()
		consulta.shape = jugador.get_node("ColisionJugador").shape
		consulta.transform = Transform3D(Basis.IDENTITY,cuerpo.global_position + forma.position)
		consulta.exclude = [jugador.get_rid()]
		var contactos := jugador.get_world_3d().direct_space_state.intersect_shape(consulta,64)
		comprobar(contactos.any(func(c: Dictionary) -> bool: return c.collider == cuerpo),d.id+" capsula detecta cuerpo solido "+str(cuerpo.name))
	var camara := current_scene.get_node("CamaraPrincipal") as Camera3D
	var previo: float = camara.angulo_horizontal
	Input.action_press("girar_camara_derecha")
	await cuadros(25)
	Input.action_release("girar_camara_derecha")
	comprobar(absf(camara.angulo_horizontal-previo)>0.1,d.id+" Q/E orbital")
	camara.set_process(false)
	for i in 8:
		camara.angulo_horizontal = i*PI/4
		camara.centro_seguimiento = Vector3.ZERO
		camara.actualizar_orbita()
		await cuadros(3)
		await captura(d.id+"_orbita_%02d"%i)
	camara.angulo_horizontal = 0
	camara.centro_seguimiento = jugador.position
	camara.actualizar_orbita()
	camara.set_process(true)
