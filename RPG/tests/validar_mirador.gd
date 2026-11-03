extends "res://tests/validar_distribucion.gd"

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
	await validar_mirador()
	if DisplayServer.get_name()!="headless":
		await capturar_mirador()
	print("RESULTADO_MIRADOR: ",fallos," fallos; ",muestras," muestras")
	quit(0 if fallos==0 else 1)

func capturar_mirador() -> void:
	var carpeta := "res://logs/fase4b4_mirador/"+Time.get_datetime_string_from_system().replace(":","-")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(carpeta))
	var camara: Camera3D = mundo.get_node("CamaraPrincipal")
	camara.set_process(false)
	camara.far = 250
	jugador.set_physics_process(false)
	jugador.position = Vector3(37,0.02,7.7)
	var centro := Vector3(37,0.45,8)
	var nombres := ["sur","sureste","este","noreste","norte","noroeste","oeste","suroeste","detalle","acceso","rio","contexto","aldea"]
	var html := "<!doctype html><meta charset='utf-8'><title>Mirador 4B.4</title><style>body{background:#20241c;color:#eee;font:16px sans-serif}img{width:80%}</style><h1>Mirador de ribera</h1>"
	for i in nombres.size():
		var objetivo := centro
		if i<8:
			camara.size = 15
			camara.position = centro+Vector3(0,13,20.80435).rotated(Vector3.UP,TAU*i/8.0)
		elif i==8:
			camara.size = 6
			camara.position = centro+Vector3(5,6,7)
		elif i==9:
			camara.size = 9
			objetivo = Vector3(37,0.3,7)
			camara.position = objetivo+Vector3(0,9,-12)
		elif i==10:
			camara.size = 12
			objetivo = Vector3(34,0.4,8)
			camara.position = objetivo+Vector3(12,10,4)
		elif i==11:
			camara.size = 28
			objetivo = Vector3(30,0.5,3)
			camara.position = objetivo+Vector3(18,22,24)
		else:
			camara.size = 95
			objetivo = Vector3.ZERO
			camara.position = Vector3(0,95,65)
		camara.look_at(objetivo)
		await esperar(10)
		await RenderingServer.frame_post_draw
		comprobar(root.get_texture().get_image().save_png(carpeta+"/"+nombres[i]+".png")==OK,"Captura "+nombres[i])
		html += "<h2>"+nombres[i]+"</h2><img src='"+nombres[i]+".png'>"
	FileAccess.open(carpeta+"/galeria.html",FileAccess.WRITE).store_string(html)
	camara.size = 15
	camara.position = centro+Vector3(0,13,20.80435)
	camara.look_at(centro)
	await esperar(15)
	var tiempos: Array[float] = []
	var anterior := Time.get_ticks_usec()
	for i in 120:
		await process_frame
		var ahora := Time.get_ticks_usec()
		tiempos.append(float(ahora-anterior)/1000.0)
		anterior = ahora
	tiempos.sort()
	print("RENDIMIENTO_120_FRAMES: mediana_ms=",tiempos[60],"; p95_ms=",tiempos[114],"; draw_calls=",Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"; primitivas=",Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME))
	print("CAPTURAS: ",carpeta)
