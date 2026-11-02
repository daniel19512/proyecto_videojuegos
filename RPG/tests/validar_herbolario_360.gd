extends "res://tests/validar_distribucion.gd"
## Ejecuta los controles E05 compartidos y captura ocho vistas sin cambiar la camara persistida.
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
	await validar_herbolario()
	var edificio: Node3D = aldea.get_node("Edificios/E05")
	for ruta in ["JardinMedicinal/Lavanda", "JardinMedicinal/Romero", "JardinMedicinal/Salvia", "JardinMedicinal/Menta", "JardinMedicinal/Calendula", "SecaderoHierbas/Cuerda", "MesaPreparacion/Mortero", "Estanterias", "Entrada/Puerta"]:
		comprobar(edificio.has_node(ruta),"E05: presente "+ruta)
	jugador.set_physics_process(false)
	jugador.global_position = Vector3(18.2,0.02,8)
	var camara: Camera3D = mundo.get_node("CamaraPrincipal")
	camara.set_process(false)
	var centro := edificio.global_position + Vector3.UP*0.8
	if DisplayServer.get_name() != "headless":
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://e05_vistas_finales"))
	for grados in [0,45,90,135,180,225,270,315]:
		camara.global_position = centro + Vector3(0,13,20.80435).rotated(Vector3.UP,deg_to_rad(float(grados)))
		camara.look_at(centro)
		await esperar(8)
		comprobar(is_equal_approx(camara.size,15) and absf(camara.rotation_degrees.x+32)<0.1,"E05: camara 15/-32 en "+str(grados))
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			comprobar(root.get_texture().get_image().save_png("user://e05_vistas_finales/herbolario_E05_%03d.png"%grados)==OK,"Captura E05 "+str(grados))
	print("CAPTURAS: ",ProjectSettings.globalize_path("user://e05_vistas_finales"))
	print("RESULTADO_HERBOLARIO_360: %d fallos"%fallos)
	quit(0 if fallos == 0 else 1)
