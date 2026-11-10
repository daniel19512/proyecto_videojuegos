extends SceneTree
## Física real de los recorridos y capturas opcionales en Forward+/D3D12.
var fallos := 0
var comprobaciones := 0
var mundo: Node3D
var jugador: CharacterBody3D
var carpeta: String
var imagenes: Array[String] = []

func _initialize() -> void:
	call_deferred("validar")

func comprobar(ok: bool, texto: String) -> void:
	comprobaciones += 1
	if not ok:
		fallos += 1
		push_error(texto)

func esperar(n: int) -> void:
	for i in n:
		await physics_frame
	await process_frame

func caminar(a: Vector3, b: Vector3) -> void:
	jugador.position = a+Vector3.UP*0.08
	jugador.velocity = Vector3.ZERO
	await esperar(3)
	for i in 1000:
		var d := b-jugador.position
		d.y = 0
		if d.length()<0.22:
			break
		jugador.velocity = d.normalized()*5+Vector3.DOWN*3
		jugador.move_and_slide()
		await physics_frame
	comprobar(Vector2(jugador.position.x-b.x,jugador.position.z-b.z).length()<0.3,"Recorrido %s -> %s"%[a,b])
	comprobar(jugador.position.y> -0.1,"Apoyo continuo")

func foto(nombre: String) -> void:
	await esperar(4)
	await RenderingServer.frame_post_draw
	comprobar(root.get_texture().get_image().save_png(carpeta+"/"+nombre+".png")==OK,nombre)
	imagenes.append(nombre)

func validar() -> void:
	carpeta = "res://logs/fase6c_ruinas/"+Time.get_datetime_string_from_system().replace(":","-")+"_"+str(Time.get_ticks_msec())
	if "--fase6d" in OS.get_cmdline_user_args():
		carpeta = carpeta.replace("fase6c_ruinas","fase6d_bosque_ruinas/ruinas")
	if "--fase6e" in OS.get_cmdline_user_args():
		carpeta = carpeta.replace("fase6c_ruinas","fase6e_campos_granjas/ruinas")
	if "--fase6f" in OS.get_cmdline_user_args(): carpeta = carpeta.replace("fase6c_ruinas","fase6f_montanas/ruinas")
	DirAccess.make_dir_recursive_absolute(carpeta)
	mundo = load("res://scenes/mundo_ruinas.tscn").instantiate()
	root.add_child(mundo)
	current_scene = mundo
	jugador = mundo.get_node("Jugador")
	jugador.set_physics_process(false)
	await esperar(5)
	comprobar(mundo.get_node("Region").obtener_entrada("ruinas_bosque_sur")!=null,"Entrada regional")
	var salidas := mundo.find_children("*","Area3D",true,false)
	comprobar(salidas.size()==1 and mundo.has_node("Region/SalidaBosque"),"Solo retorno Bosque activo")
	# La fixture mide cierres físicos sin salir del mapa; las áreas se prueban en 6D.
	for salida in salidas:
		salida.monitoring = false
	comprobar(mundo.get_node("CamaraPrincipal").size==15,"Camara original tamaño 15")
	var ruta: Array[Vector3] = [Vector3(0,0,34),Vector3(0,0,24),Vector3(-7,0,13),Vector3(0,0,0),Vector3(0,0,-14),Vector3(0,0.3,-23),Vector3(0,0.3,-26)]
	for i in range(ruta.size()-1):
		await caminar(ruta[i],ruta[i+1])
		await caminar(ruta[i+1],ruta[i])
	await caminar(Vector3.ZERO,Vector3(23,0,2))
	await caminar(Vector3(23,0,2),Vector3.ZERO)
	await caminar(Vector3(-7,0,13),Vector3(-17,0,9))
	# Colisiones representativas: suelo, cada cuerpo sólido y los cuatro cierres.
	var espacio := mundo.get_world_3d().direct_space_state
	for cuerpo in mundo.find_children("*","StaticBody3D",true,false):
		for c in cuerpo.get_children():
			if not c is CollisionShape3D:
				continue
			comprobar(c.shape!=null and not c.disabled,"Forma sólida activa")
			var query := PhysicsShapeQueryParameters3D.new()
			var esfera := SphereShape3D.new()
			esfera.radius = 0.02
			query.shape = esfera
			query.transform = Transform3D(Basis.IDENTITY,c.global_position)
			var detectado := false
			for hit in espacio.intersect_shape(query,32):
				if hit.collider==cuerpo:
					detectado = true
			comprobar(detectado,"Cuerpo detectable "+str(cuerpo.get_path()))
	for par in [[Vector3(38,0,20),Vector3(43,0,20)],[Vector3(-38,0,20),Vector3(-43,0,20)],[Vector3(0,0,38),Vector3(0,0,43)],[Vector3(20,0,-38),Vector3(20,0,-43)]]:
		jugador.position = par[0]+Vector3.UP*0.1
		await esperar(2)
		for i in 100:
			jugador.velocity = (par[1]-par[0]).normalized()*5+Vector3.DOWN*3
			jugador.move_and_slide()
			await physics_frame
		comprobar(absf(jugador.position.x)<40 and absf(jugador.position.z)<40,"Cierre exterior")
	var camara := mundo.get_node("CamaraPrincipal")
	camara.set_process(false)
	for i in 8:
		camara.angulo_horizontal = float(i)*TAU/8
		camara.actualizar_orbita()
		comprobar(camara.global_position.is_finite(),"Orbita finita")
	if DisplayServer.get_name()!="headless":
		root.size = Vector2i(1440,900)
		for id in ["A","B","C","D","E"]:
			var marca: Marker3D = mundo.get_node("Ruinas/Marcadores/Zona"+id)
			jugador.position = marca.position+Vector3.UP*0.05
			camara.centro_seguimiento = jugador.position
			for i in [0,2,4,6]:
				camara.angulo_horizontal = float(i)*TAU/8
				camara.actualizar_orbita()
				await foto("zona_"+id+"_angulo_"+str(i*45))
		var superior := Camera3D.new()
		mundo.add_child(superior)
		superior.projection = Camera3D.PROJECTION_ORTHOGONAL
		superior.size = 94
		superior.position = Vector3(0,100,0)
		superior.rotation_degrees.x = -90
		superior.make_current()
		await foto("plano_superior")
		var html := "<!doctype html><meta charset='utf-8'><title>Ruinas Antiguas — 6C</title><style>body{background:#18211b;color:#eee;font:18px sans-serif;margin:30px}img{width:100%;max-width:1100px}figure{margin:30px 0}</style><h1>Ruinas Antiguas · revisión visual pendiente</h1>"
		for nombre in imagenes:
			html += "<figure><figcaption>"+nombre+"</figcaption><a href='"+nombre+".png'><img src='"+nombre+".png'></a></figure>"
		FileAccess.open(carpeta+"/galeria.html",FileAccess.WRITE).store_string(html)
	print("RUINAS: %d fallos / %d comprobaciones; evidencias %s"%[fallos,comprobaciones,carpeta])
	quit(1 if fallos else 0)
