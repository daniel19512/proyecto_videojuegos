extends "res://tests/validar_distribucion.gd"
## Capturas de inspeccion con la camara real; no guarda cambios en mundo ni jugador.
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
	await validar_vivienda_noreste()
	jugador.set_physics_process(false)
	jugador.global_position = Vector3(18.2, 0.02, -24)
	var camara: Camera3D = mundo.get_node("CamaraPrincipal")
	camara.set_process(false)
	var centro := Vector3(21, 2.1, -24)
	var carpeta := "res://logs/e07_vistas_finales"
	if DisplayServer.get_name() != "headless":
		comprobar(DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(carpeta)) == OK, "Carpeta de capturas E07")
	for grados in [0,45,90,135,180,225,270,315]:
		camara.global_position = centro + Vector3(0,13,20.80435).rotated(Vector3.UP,deg_to_rad(float(grados)))
		camara.look_at(centro)
		await esperar(12)
		comprobar(is_equal_approx(camara.size,15) and absf(camara.rotation_degrees.x+32)<0.1, "E07: camara 15/-32 en "+str(grados))
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			var destino := carpeta + "/vivienda_E07_%03d.png" % grados
			comprobar(not FileAccess.file_exists(destino), "No sobrescribir captura previa: "+destino)
			if not FileAccess.file_exists(destino):
				comprobar(root.get_texture().get_image().save_png(destino) == OK, "Captura E07 "+str(grados))
	print("RESULTADO_E07_360: %d fallos" % fallos)
	mundo.queue_free()
	await process_frame
	quit(0 if fallos == 0 else 1)
