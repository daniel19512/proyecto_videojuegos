extends "res://tests/validar_bosque.gd"
## Conserva todos los recorridos, barreras y pruebas de la base del bosque.
func validar() -> void:
	if "--solo-capturas" in OS.get_cmdline_user_args():
		mundo = load("res://scenes/pruebas_bosque.tscn").instantiate()
		root.add_child(mundo)
		current_scene = mundo
		bosque = mundo.get_node("Bosque")
		jugador = mundo.get_node("Jugador")
		camara = mundo.get_node("CamaraPrincipal")
		await esperar(15)
		await capturar()
		quit(0 if fallos==0 else 1)
		return
	var escena: Node3D = load("res://scenes/bosque.tscn").instantiate()
	root.add_child(escena)
	await physics_frame
	var laguna: Node3D = escena.get_node("Laguna")
	comprobar(laguna.get_meta("centro")==Vector2(-29,22),"Ubicacion original")
	comprobar(laguna.get_meta("cota_agua")==-0.12,"Cota agua bajo orillas")
	comprobar(laguna.find_children("*","CollisionObject3D",true,false).is_empty(),"Sin alterar ni duplicar colisiones")
	comprobar(escena.get_node("Reservas/ReservaLagunaCerrada").get_child_count()==40,"Cuarenta barreras originales")
	var agua: MeshInstance3D = laguna.get_node("Geometria/Agua")
	comprobar(agua.mesh.get_faces().size()==288,"Agua de 96 triangulos")
	comprobar(agua.material_override is ShaderMaterial,"ShaderMaterial local de agua")
	var caras: PackedVector3Array = agua.mesh.get_faces()
	for i in range(0,caras.size(),3):
		comprobar((caras[i+1]-caras[i]).cross(caras[i+2]-caras[i]).y<0,"Caras de agua orientadas hacia arriba en Godot")
	for p in caras:
		comprobar(is_equal_approx(p.y,-0.12),"Agua plana sin olas oceanicas")
	for n in laguna.get_node("DecoracionOrillas").get_children():
		comprobar(ResourceLoader.exists(n.get_meta("ruta_original")),"Recurso ribereño real")
		var p := Vector2(n.position.x,n.position.z)
		for camino in escena.get_node("Caminos").get_children():
			var eje: PackedVector2Array = camino.get_meta("eje")
			var d := INF
			for i in range(1,eje.size()):
				d = minf(d,p.distance_to(Geometry2D.get_closest_point_to_segment(p,eje[i-1],eje[i])))
			comprobar(d>float(camino.get_meta("ancho"))*0.5+0.65,"Decoracion fuera de senderos")
	comprobar(laguna.get_node("DetallesAgua").get_child_count()==6,"Seis nenufares decorativos")
	escena.queue_free()
	await physics_frame
	await super.validar()

func capturar() -> void:
	carpeta = "res://logs/laguna_bosque/"+Time.get_datetime_string_from_system().replace(":","-")+"_"+str(Time.get_ticks_msec())
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(carpeta))
	root.size = Vector2i(1600,1000)
	soltar()
	jugador.set_physics_process(false)
	jugador.position = suelo(Vector2(-18,21)).position+Vector3.UP*0.05
	camara.set_process(false)
	camara.far = 250
	var centro := Vector3(-29,0.1,22)
	var agua: MeshInstance3D = bosque.get_node("Laguna/Geometria/Agua")
	var material: ShaderMaterial = agua.material_override
	var html := "<!doctype html><meta charset='utf-8'><title>Laguna natural</title><style>body{background:#19251f;color:#eee;font:18px sans-serif;margin:25px}img{max-width:100%}</style><h1>Laguna natural del bosque</h1><p>Mismos caminos, árboles y barreras. Capturas reales Forward+/D3D12; aprobación visual pendiente.</p>"
	var muestra_agua := PackedByteArray()
	for i in 13:
		var nombre := "%02d"%i
		var objetivo := centro
		camara.size = 26
		if i==0:
			camara.position = centro+Vector3(0,45,0.01)
		elif i<9:
			var angulo := TAU*(i-1)/8.0
			camara.position = centro+Vector3(sin(angulo)*24,19,cos(angulo)*24)
		elif i==9:
			camara.size = 15
			objetivo = jugador.position+Vector3.UP*0.8
			camara.position = jugador.position+Vector3(16,13.8,14)
		elif i==10:
			camara.size = 112
			objetivo = Vector3.ZERO
			camara.position = Vector3(0,130,0.01)
		else:
			camara.size = 12
			objetivo = centro+Vector3(-1,0,0)
			camara.position = objetivo+Vector3(8,16,10)
			material.set_shader_parameter("tiempo",0.0 if i==11 else 4.0)
		camara.look_at(objetivo)
		await esperar(10)
		await RenderingServer.frame_post_draw
		var imagen := root.get_texture().get_image()
		if i==11:
			muestra_agua = imagen.get_data()
		elif i==12:
			comprobar(muestra_agua!=imagen.get_data(),"Ondulacion visible en tiempos 0 y 4 segundos")
		comprobar(imagen.save_png(carpeta+"/"+nombre+".png")==OK,"Captura "+nombre)
		html += "<h2>"+nombre+"</h2><img src='"+nombre+".png'>"
	material.set_shader_parameter("tiempo",-1.0)
	FileAccess.open(carpeta+"/galeria.html",FileAccess.WRITE).store_string(html)
	print("GALERIA_LAGUNA: ",carpeta+"/galeria.html")
