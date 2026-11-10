extends "res://tests/validar_bosque.gd"
## Conserva la regresión anterior completa y añade datos/render de vegetación.
func capturar() -> void:
	carpeta = "res://logs/fase6a2_vegetacion_bosque/"+Time.get_datetime_string_from_system().replace(":","-")+"_"+str(Time.get_ticks_msec())
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(carpeta))
	await super.capturar()
	var mediciones: Array = []
	var html := FileAccess.get_file_as_string(carpeta+"/galeria.html").replace("Bosque 6A.1","Bosque 6A.2").replace("base 6A.1","vegetación 6A.2")
	for centro in [Vector2(0,41),Vector2.ZERO,Vector2(-25,-25),Vector2(24,-26),Vector2(29,20),Vector2(-18,21),Vector2(-3,31),Vector2(0,-42)]:
		jugador.position = suelo(centro).position+Vector3.UP*0.05
		for angulo in [0,90,180,270]:
			var a := deg_to_rad(float(angulo))
			camara.size = 15
			var objetivo := jugador.position+Vector3.UP*0.8
			camara.position = objetivo+Vector3(sin(a)*21.2,13.25,cos(a)*21.2)
			camara.look_at(objetivo)
			await esperar(8)
			if angulo==0:
				var tiempos: Array[float] = []
				for fotograma in 120:
					var inicio := Time.get_ticks_usec()
					await process_frame
					tiempos.append((Time.get_ticks_usec()-inicio)/1000.0)
				tiempos.sort()
				mediciones.append({"x":centro.x,"z":centro.y,"mediana_ms":tiempos[60],"p95_ms":tiempos[114],"fps":1000.0/tiempos[60],"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"objetos":Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME),"memoria_video":Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)})
			await RenderingServer.frame_post_draw
			var nombre := "orbita_%s_%s_%s"%[centro.x,centro.y,angulo]
			comprobar(root.get_texture().get_image().save_png(carpeta+"/"+nombre+".png")==OK,"Captura orbital")
			html += "<section><h2>"+nombre+" · tamaño 15</h2><img src='"+nombre+".png'></section>"
	# Comparación idéntica de cámara con/sin vegetación; sin cambios guardados.
	camara.size = 112
	camara.position = Vector3(0,130,0.01)
	camara.look_at(Vector3.ZERO)
	for visible in [false,true]:
		bosque.get_node("Vegetacion").visible = visible
		await esperar(10)
		await RenderingServer.frame_post_draw
		var nombre := "despues" if visible else "antes"
		root.get_texture().get_image().save_png(carpeta+"/"+nombre+".png")
		html += "<section><h2>"+nombre+" · misma cámara</h2><img src='"+nombre+".png'></section>"
	FileAccess.open(carpeta+"/galeria.html",FileAccess.WRITE).store_string(html.replace("Vegetación y aprobación artística pendientes.","Vegetación construida; aprobación artística pendiente.").replace("Escena base sin vegetacion","Escena con vegetacion"))
	FileAccess.open(carpeta+"/rendimiento_zonas.json",FileAccess.WRITE).store_string(JSON.stringify(mediciones,"\t"))
	print("GALERIA_6A2: ",carpeta)

func validar() -> void:
	if "--solo-capturas" in OS.get_cmdline_user_args():
		mundo = load("res://scenes/pruebas_bosque.tscn").instantiate()
		root.add_child(mundo)
		current_scene = mundo
		bosque = mundo.get_node("Bosque")
		jugador = mundo.get_node("Jugador")
		camara = mundo.get_node("CamaraPrincipal")
		camara.set_process(false)
		await esperar(10)
		await capturar()
		quit(0 if fallos==0 else 1)
		return
	# Super ejecuta conectividad, cápsula, cierres y recorridos sin excepciones físicas.
	var datos: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://scenes/vegetacion_bosque_datos.json"))
	comprobar(datos.semilla==62024,"Semilla persistente")
	var region: Node3D = load("res://scenes/bosque.tscn").instantiate()
	root.add_child(region)
	await physics_frame
	await physics_frame
	var espacio := region.get_world_3d().direct_space_state
	var colisiones: StaticBody3D = region.get_node("Vegetacion/Obstaculos")
	if DisplayServer.get_name()!="headless":
		for visual in region.get_node("Vegetacion").find_children("*","MultiMeshInstance3D",true,false):
			comprobar(visual.multimesh.buffer.size()==visual.multimesh.instance_count*12,"Buffer MultiMesh persistido")
	var modelos := {}
	for dato in datos.instancias:
		modelos[dato.id] = true
		var p := Vector2(dato.x,dato.z)
		for camino in region.get_node("Caminos").get_children():
			var eje: PackedVector2Array = camino.get_meta("eje")
			var distancia := INF
			for k in range(1,eje.size()):
				distancia = minf(distancia,p.distance_to(Geometry2D.get_closest_point_to_segment(p,eje[k-1],eje[k])))
			comprobar(distancia>float(camino.get_meta("ancho"))*0.5+0.5,"Centro fuera de senderos")
		for zona in region.get_node("Reservas").get_children():
			if str(zona.name).begins_with("Z"):
				var semiejes: Vector2 = zona.get_meta("semiejes")
				comprobar(((p-Vector2(zona.position.x,zona.position.z))/semiejes).length()>1.0,"Reserva libre")
		comprobar(ResourceLoader.exists(dato.ruta),"Recurso "+dato.id)
		var q := PhysicsRayQueryParameters3D.create(Vector3(dato.x,20,dato.z),Vector3(dato.x,-10,dato.z))
		q.exclude = [colisiones.get_rid(),region.get_node("Reservas/ReservaLagunaCerrada").get_rid()]
		var hit := espacio.intersect_ray(q)
		comprobar(not hit.is_empty() and absf(hit.position.y-dato.y)<0.005,"Apoyo real "+dato.id)
	comprobar(colisiones.get_child_count()>300,"Colisiones simplificadas presentes")
	print("MODELOS_DISTINTOS: ",modelos.size()," COLISIONES: ",colisiones.get_child_count())
	region.queue_free()
	await physics_frame
	await super.validar()
