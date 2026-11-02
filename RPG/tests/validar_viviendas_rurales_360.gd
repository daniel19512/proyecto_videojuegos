extends "res://tests/validar_distribucion.gd"
## Capturas reproducibles. Las escenas y camara persistidas no se modifican.
func vivienda_id() -> String:
	return "E08"

func guardar_vista(camara: Camera3D, centro: Vector3, grados: int, destino: String) -> void:
	camara.global_position = centro+Vector3(0,13,20.80435).rotated(Vector3.UP,deg_to_rad(float(grados)))
	camara.look_at(centro)
	await esperar(12)
	comprobar(absf(camara.rotation_degrees.x+32)<0.1,"Inclinacion -32: "+str(grados))
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	comprobar(not FileAccess.file_exists(destino),"Captura nueva sin sobrescribir: "+destino)
	if not FileAccess.file_exists(destino):
		comprobar(root.get_texture().get_image().save_png(destino) == OK,"Captura guardada")

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
	var id := vivienda_id()
	await validar_vivienda_rural(id)
	jugador.set_physics_process(false)
	var centro := Vector3(-24,1.9,23) if id == "E08" else Vector3(-8,2.1,24)
	jugador.global_position = Vector3(centro.x,0.02,centro.z-2.8)
	var camara: Camera3D = mundo.get_node("CamaraPrincipal")
	camara.set_process(false)
	var carpeta := "res://logs/"+id.to_lower()+"_vistas_finales"
	if DisplayServer.get_name() != "headless":
		comprobar(DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(carpeta)) == OK,"Carpeta de capturas "+id)
	for grados in [0,45,90,135,180,225,270,315]:
		comprobar(is_equal_approx(camara.size,15),"Camara 15 conservada")
		await guardar_vista(camara,centro,grados,carpeta+"/vivienda_"+id+"_%03d.png" % grados)
	if id == "E09":
		# Solo la toma conjunta amplia el encuadre temporal para cubrir las dos parcelas.
		camara.size = 26
		await guardar_vista(camara,Vector3(-16,1.7,23.5),180,carpeta+"/conjunto_E08_E09.png")
		camara.size = 15
	print("RESULTADO_",id,"_360: %d fallos" % fallos)
	mundo.queue_free()
	await process_frame
	quit(0 if fallos == 0 else 1)
