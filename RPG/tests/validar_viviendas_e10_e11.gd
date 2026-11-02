extends "res://tests/validar_distribucion.gd"
## Entrada específica y capturas; la regresión general invoca los mismos controles.
func vivienda_id() -> String:
	return "E10"

func validar() -> void:
	print("VERSION: ", Engine.get_version_info().string)
	mundo = load("res://scenes/mundo.tscn").instantiate()
	root.add_child(mundo)
	current_scene = mundo
	aldea = mundo.get_node("Aldea")
	jugador = mundo.get_node("Jugador")
	await esperar(20)
	consulta.shape = jugador.get_node("ColisionJugador").shape
	consulta.exclude = [jugador.get_rid()]
	var id := vivienda_id()
	await validar_vivienda_final(id)
	if "--capturas" in OS.get_cmdline_user_args() and DisplayServer.get_name() != "headless":
		jugador.set_physics_process(false)
		jugador.global_position = Vector3(8 if id == "E10" else 18, 0.02, 21.1 if id == "E10" else 20.1)
		var camara: Camera3D = mundo.get_node("CamaraPrincipal")
		camara.set_process(false)
		var centro := Vector3(8, 2, 25) if id == "E10" else Vector3(18, 2.6, 24)
		var carpeta := "res://logs/" + id.to_lower() + "_vistas_finales"
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(carpeta))
		for grados in [0,45,90,135,180,225,270,315]:
			comprobar(is_equal_approx(camara.size,15),"Tamaño ortografico 15")
			await guardar_vista(camara,centro,grados,carpeta+"/vivienda_%s_%03d.png" % [id,grados])
		if id == "E11":
			camara.size = 23
			await guardar_vista(camara,Vector3(13,2,24.5),180,carpeta+"/conjunto_E10_E11.png")
			camara.size = 15
	print("RESULTADO_",id,": ",fallos," fallos")
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
