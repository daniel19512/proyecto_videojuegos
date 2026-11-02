extends "res://tests/validar_distribucion.gd"
## Headless: controles E12. Con ventana y -- --capturas: ocho vistas y contexto.
func validar() -> void:
	print("VERSION: ",Engine.get_version_info().string)
	mundo = load("res://scenes/mundo.tscn").instantiate()
	root.add_child(mundo)
	current_scene = mundo
	aldea = mundo.get_node("Aldea")
	jugador = mundo.get_node("Jugador")
	await esperar(20)
	consulta.shape = jugador.get_node("ColisionJugador").shape
	consulta.exclude = [jugador.get_rid()]
	await validar_molino()
	var regiones: Array[Rect2] = [plano(aldea.get_node("Plaza/Marca"))]
	var libres := true
	for camino: Node3D in aldea.get_node("Caminos").get_children():
		regiones.append(plano(camino.get_node("Marca")))
		var a: Vector2 = camino.get_meta("a")
		var b: Vector2 = camino.get_meta("b")
		var ancho: float = camino.get_meta("ancho")
		var lateral := (b-a).normalized().orthogonal()
		var n := int(ceil(a.distance_to(b)/.5))
		for k in range(n+1):
			for t in [-1.0,-.5,0.0,.5,1.0]:
				libres = suelo_libre(a.lerp(b,float(k)/maxi(n,1))+lateral*t*(ancho*.5-.36)) and libres
	comprobar(regiones.size() == 37 and conectadas(regiones) == 37 and libres,"E12: 36 corredores libres y conectados a plaza")
	if "--capturas" in OS.get_cmdline_user_args() and DisplayServer.get_name() != "headless":
		jugador.set_physics_process(false)
		jugador.global_position = Vector3(17,.02,-10)
		var camara: Camera3D = mundo.get_node("CamaraPrincipal")
		camara.set_process(false)
		var carpeta := "res://logs/e12_vistas_finales"
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(carpeta))
		for grados in [0,45,90,135,180,225,270,315]:
			await guardar_vista(camara,Vector3(23,2.6,-10),grados,carpeta+"/molino_E12_%03d.png" % grados)
		camara.size = 27
		aldea.mostrar_limites_parcelas = true
		await guardar_vista(camara,Vector3(25,0,-6),90,carpeta+"/contexto_cauce_cruce.png")
		camara.size = 15
	print("RESULTADO_E12: ",fallos," fallos")
	mundo.queue_free()
	await process_frame
	quit(0 if fallos == 0 else 1)

func guardar_vista(camara: Camera3D, centro: Vector3, grados: int, destino: String) -> void:
	camara.global_position = centro+Vector3(0,13,20.80435).rotated(Vector3.UP,deg_to_rad(float(grados)))
	camara.look_at(centro)
	await esperar(12)
	await RenderingServer.frame_post_draw
	comprobar(not FileAccess.file_exists(destino),"Captura nueva: "+destino)
	if not FileAccess.file_exists(destino):
		comprobar(root.get_texture().get_image().save_png(destino) == OK,"Captura guardada")
