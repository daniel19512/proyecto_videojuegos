extends SceneTree
## Valida el mundo guardado, no la herramienta de autoria.
var fallos := 0
var comprobaciones := 0
var mundo: Node3D
var jugador: CharacterBody3D
var carpeta: String
var imagenes: Array[String] = []
var bloqueos: Array = []

func _initialize() -> void:
	call_deferred("validar")

func comprobar(ok: bool, texto: String) -> void:
	comprobaciones += 1
	if not ok:
		fallos += 1
		push_error(texto)

func esperar(n: int) -> void:
	for i in n: await physics_frame
	await process_frame

func altura(p: Vector2) -> float:
	var q := PhysicsRayQueryParameters3D.create(Vector3(p.x,8,p.y),Vector3(p.x,-3,p.y),1,[jugador.get_rid()])
	var resultado := mundo.get_world_3d().direct_space_state.intersect_ray(q)
	return resultado.position.y if not resultado.is_empty() else -100.0

func caminar(puntos: PackedVector2Array) -> void:
	jugador.position = Vector3(puntos[0].x,.08,puntos[0].y)
	jugador.velocity = Vector3.ZERO
	await esperar(3)
	for b in puntos.slice(1):
		var frames := 0
		while frames<1200 and Vector2(jugador.position.x,jugador.position.z).distance_to(b)>.23:
			var d := (b-Vector2(jugador.position.x,jugador.position.z)).normalized()
			jugador.velocity = Vector3(d.x*5,-3,d.y*5)
			jugador.move_and_slide()
			await physics_frame
			frames += 1
		comprobar(Vector2(jugador.position.x,jugador.position.z).distance_to(b)<.3,"Recorrido hacia "+str(b)+" posicion="+str(jugador.position))
		comprobar(jugador.position.y>-.1,"Suelo continuo")
		if frames>=1200: break

func foto(nombre: String) -> void:
	await esperar(6)
	await RenderingServer.frame_post_draw
	comprobar(root.get_texture().get_image().save_png(carpeta+"/"+nombre+".png")==OK,"Captura "+nombre)
	imagenes.append(nombre)

func validar() -> void:
	carpeta = "res://logs/fase6e_campos_granjas/"+Time.get_datetime_string_from_system().replace(":","-")+"_"+str(Time.get_ticks_msec())
	if "--fase6f" in OS.get_cmdline_user_args(): carpeta = carpeta.replace("fase6e_campos_granjas","fase6f_montanas/campos")
	DirAccess.make_dir_recursive_absolute(carpeta)
	mundo = load("res://scenes/mundo_campos_granjas.tscn").instantiate()
	root.add_child(mundo)
	current_scene = mundo
	jugador = mundo.get_node("Jugador")
	jugador.set_physics_process(false)
	# Prueba local de cierres: solo esta fixture desactiva su salida, cubierta activa en otra prueba.
	mundo.get_node("Region/SalidaAldea").monitoring = false
	await esperar(6)
	var mapa := mundo.get_node("CamposYGranjas")
	comprobar(mundo.get_node("Region").id_region==&"CamposYGranjas","Identificador regional")
	comprobar(mundo.get_node("Region").obtener_entrada("campos_aldea_norte")!=null,"Entrada norte propia")
	comprobar(mapa.get_meta("dimensiones")==Vector2(100,90),"Terreno 100x90")
	comprobar(mapa.get_node("Caminos").get_child_count()==14,"Red de catorce caminos")
	for ruta in mapa.get_meta("assets_utilizados"):
		comprobar(ResourceLoader.exists(ruta) and not ruta.contains("/animales/"),"Asset autorizado "+ruta)
	for n in mapa.find_children("*","AnimationPlayer",true,false): comprobar(false,"No debe haber animacion animal "+str(n.get_path()))
	for n in mapa.find_children("*","MultiMeshInstance3D",true,false):
		comprobar(n.multimesh!=null and n.multimesh.instance_count>0,"MultiMesh guardado")
	var serializado := FileAccess.get_file_as_string("res://scenes/campos_granjas.tscn")
	comprobar(serializado.count("buffer = PackedFloat32Array(")==9,"Nueve buffers MultiMesh serializados, no solo contadores vacios")
	var plantas := 0
	for n in mapa.get_node("Trigo").get_children():
		if n is MultiMeshInstance3D: plantas += n.multimesh.instance_count
	comprobar(plantas==1408,"Trigo volumetrico en cuatro MultiMesh, 1408 plantas")
	# Muestra toda la anchura declarada con capsula real, sin exceptuar reservas enteras.
	var espacio := mundo.get_world_3d().direct_space_state
	for edificio in mapa.find_children("*","Node3D",true,false):
		if not edificio.has_meta("tipo"): continue
		var cuerpo: Vector2 = edificio.get_meta("cuerpo")
		for borde in [Vector3(cuerpo.x/2,1,0),Vector3(-cuerpo.x/2,1,0),Vector3(0,1,-cuerpo.y/2)]:
			var destino: Vector3 = edificio.global_position+borde
			var dir := Vector3(borde.x,0,borde.z).normalized()
			var ray := PhysicsRayQueryParameters3D.create(destino+dir,destino-dir,1,[jugador.get_rid()])
			comprobar(not espacio.intersect_ray(ray).is_empty(),"Muro real infranqueable "+edificio.name)
		if edificio.get_meta("tipo")!="establo":
			var destino: Vector3 = edificio.global_position+Vector3(0,1,cuerpo.y/2)
			var ray := PhysicsRayQueryParameters3D.create(destino+Vector3.BACK,destino+Vector3.FORWARD,1,[jugador.get_rid()])
			comprobar(not espacio.intersect_ray(ray).is_empty(),"Puerta cerrada solida "+edificio.name)
		else:
			# Dos huecos reales entre postes, sin caja que llene el cobertizo.
			for lado in [-1,1]:
				var destino: Vector3 = edificio.global_position+Vector3(lado*cuerpo.x/4,1,cuerpo.y/2)
				var ray := PhysicsRayQueryParameters3D.create(destino+Vector3.BACK,destino+Vector3.FORWARD,1,[jugador.get_rid()])
				comprobar(espacio.intersect_ray(ray).is_empty(),"Hueco abierto de establo "+edificio.name)
	var consulta := PhysicsShapeQueryParameters3D.new()
	var capsula := CapsuleShape3D.new()
	capsula.radius = .32
	capsula.height = 1.6
	consulta.shape = capsula
	consulta.exclude = [jugador.get_rid()]
	for camino in mapa.get_node("Caminos").get_children():
		var puntos: PackedVector2Array = camino.get_meta("eje")
		for i in range(puntos.size()-1):
			var a := puntos[i]
			var b := puntos[i+1]
			var perpendicular := Vector2(-(b-a).y,(b-a).x).normalized()
			var pasos := ceili(a.distance_to(b)*2)
			for paso in range(pasos+1):
				for lado in [-1,0,1]:
					var p: Vector2 = a.lerp(b,float(paso)/pasos)+perpendicular*lado*(float(camino.get_meta("ancho"))/2-.4)
					consulta.transform.origin = Vector3(p.x,.91,p.y)
					var hits := espacio.intersect_shape(consulta,32)
					if not hits.is_empty(): bloqueos.append({"camino":camino.name,"punto":str(p),"obstaculo":str(hits[0].collider.get_path())})
		comprobar(bloqueos.filter(func(x): return x.camino==camino.name).is_empty(),"Anchura libre "+camino.name)
		await caminar(puntos)
		puntos.reverse()
		await caminar(puntos)
	FileAccess.open(carpeta+"/bloqueos.json",FileAccess.WRITE).store_string(JSON.stringify(bloqueos,"\t"))
	# Cada collider serializado debe ser activo y detectable.
	for c in mapa.find_children("*","CollisionShape3D",true,false):
		comprobar(c.shape!=null and not c.disabled,"Colision activa")
		var q := PhysicsShapeQueryParameters3D.new()
		var s := SphereShape3D.new()
		s.radius = .02
		q.shape = s
		q.transform = c.global_transform
		q.exclude = [jugador.get_rid()]
		if c.shape is ConcavePolygonShape3D: continue
		var encontrado := false
		for hit in espacio.intersect_shape(q,32):
			if hit.collider==c.get_parent(): encontrado = true
		comprobar(encontrado,"Collider detectable "+str(c.get_path()))
	for par in [[Vector2(48,0),Vector2(53,0)],[Vector2(-48,0),Vector2(-53,0)],[Vector2(0,43),Vector2(0,48)],[Vector2(0,-43),Vector2(0,-48)]]:
		jugador.position = Vector3(par[0].x,altura(par[0])+.1,par[0].y)
		await esperar(2)
		for i in 100:
			var d: Vector2 = (par[1]-par[0]).normalized()
			jugador.velocity = Vector3(d.x*5,-3,d.y*5)
			jugador.move_and_slide()
			await physics_frame
		comprobar(absf(jugador.position.x)<50 and absf(jugador.position.z)<45,"Cierre exterior real")
	var camara := mundo.get_node("CamaraPrincipal")
	comprobar(camara.size==15 and jugador.velocidad==10,"Camara y jugador originales")
	camara.set_process(false)
	jugador.position = Vector3(0,.05,-15)
	camara.centro_seguimiento = jugador.position
	for i in 16:
		camara.angulo_horizontal = i*TAU/16
		camara.actualizar_orbita()
		comprobar(camara.global_position.is_finite(),"Orbita 360 finita")
	if DisplayServer.get_name()!="headless":
		await capturar_vistas()
	print("CAMPOS_RESULTADO: %d fallos / %d comprobaciones; bloqueos=%d; %s"%[fallos,comprobaciones,bloqueos.size(),carpeta])
	quit(1 if fallos else 0)

func capturar_vistas() -> void:
	root.size = Vector2i(1440,900)
	var mapa := mundo.get_node("CamposYGranjas")
	var camara := mundo.get_node("CamaraPrincipal")
	camara.set_process(false)
	var rendimiento: Array = []
	for nombre in ["Entrada","Patio","Granero","CasaPrincipal","Trigo","Huertos","Establos","Corrales","GranjaOeste","GranjaSur","Paisaje"]:
		var marca: Marker3D = mapa.get_node("Marcadores/"+nombre)
		jugador.position = marca.position+Vector3.UP*.06
		camara.centro_seguimiento = jugador.position
		for angulo in [0,90,180,270]:
			camara.angulo_horizontal = deg_to_rad(angulo)
			camara.actualizar_orbita()
			await foto(nombre+"_"+str(angulo))
		if nombre in ["Trigo","Patio","Corrales"]:
			for i in 30: await process_frame
			var inicio := Time.get_ticks_usec()
			for i in 90: await process_frame
			rendimiento.append({"vista":nombre,"fotogramas":90,"ms_por_frame":(Time.get_ticks_usec()-inicio)/90000.0,"dibujos":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"objetos":Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME),"primitivas":Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)})
	for n in mapa.find_children("*","MultiMeshInstance3D",true,false):
		comprobar(n.multimesh.buffer.size()>=n.multimesh.instance_count*12,"Buffer grafico no vacio "+str(n.get_path()))
	var superior := Camera3D.new()
	mundo.add_child(superior)
	superior.projection = Camera3D.PROJECTION_ORTHOGONAL
	superior.size = 115
	superior.far = 250
	superior.position = Vector3(0,110,0)
	superior.rotation_degrees.x = -90
	superior.make_current()
	await foto("PlanoSuperior")
	FileAccess.open(carpeta+"/rendimiento.json",FileAccess.WRITE).store_string(JSON.stringify(rendimiento,"\t"))
	var html := "<!doctype html><meta charset='utf-8'><title>Campos y Granjas 6E</title><style>body{background:#20261b;color:#eee;font:18px sans-serif;margin:32px}img{max-width:100%}figure{margin:32px 0}</style><h1>Campos y Granjas · revision visual</h1><p>Camara habitual 15 y cuatro orientaciones; plano final ampliado. Sin animales ni mecanicas agricolas.</p>"
	for n in imagenes: html += "<figure><figcaption>"+n+"</figcaption><img loading='lazy' src='"+n+".png'></figure>"
	FileAccess.open(carpeta+"/galeria.html",FileAccess.WRITE).store_string(html)
