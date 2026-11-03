extends "res://tests/validar_distribucion.gd"

func validar() -> void:
	print("VERSION: ",Engine.get_version_info().string)
	mundo=load("res://scenes/mundo.tscn").instantiate()
	root.add_child(mundo); current_scene=mundo
	aldea=mundo.get_node("Aldea"); jugador=mundo.get_node("Jugador")
	await esperar(20)
	consulta.shape=jugador.get_node("ColisionJugador").shape; consulta.exclude=[jugador.get_rid()]
	await validar_vegetacion_general()
	if DisplayServer.get_name()!="headless": await capturar_vegetacion()
	print("RESULTADO_VEGETACION: ",fallos," fallos; ",muestras," muestras")
	quit(0 if fallos==0 else 1)

func capturar_vegetacion() -> void:
	var carpeta:="res://logs/fase4b7_vegetacion/"+Time.get_datetime_string_from_system().replace(":","-")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(carpeta))
	var camara: Camera3D=mundo.get_node("CamaraPrincipal")
	camara.set_process(false); camara.far=250; jugador.set_physics_process(false)
	var casos := [
		["general",Vector3.ZERO,Vector3(0,92,68),95.0],
		["perimetro_norte",Vector3(-5,0,-31),Vector3(0,18,29),38.0],
		["perimetro_sur",Vector3(-4,0,31),Vector3(0,18,-29),38.0],
		["residencial_oeste",Vector3(-25,0,20),Vector3(18,18,24),30.0],
		["comercios",Vector3(-10,0,-10),Vector3(20,18,22),32.0],
		["plaza",Vector3(0,0,0),Vector3(0,22,30),26.0],
		["molino_puente",Vector3(28,0,-4),Vector3(18,18,24),30.0],
		["mirador",Vector3(36,0,8),Vector3(12,12,18),20.0],
		["salida_bosque",Vector3(0,0,-34),Vector3(10,10,15),16.0],
		["salida_campos",Vector3(0,0,34),Vector3(-10,10,-15),16.0],
		["salida_montanas",Vector3(37,0,0),Vector3(-14,12,14),18.0]
	]
	var html:="<!doctype html><meta charset='utf-8'><title>Vegetacion 4B.7</title><style>body{background:#20241c;color:#eee;font:16px sans-serif}img{width:80%}</style><h1>Vegetacion general</h1>"
	for caso in casos:
		var objetivo: Vector3=caso[1]+Vector3.UP*.8
		camara.size=caso[3]; camara.position=objetivo+caso[2]; camara.look_at(objetivo)
		jugador.position=caso[1]+Vector3.UP*.02
		await esperar(10); await RenderingServer.frame_post_draw
		comprobar(root.get_texture().get_image().save_png(carpeta+"/"+caso[0]+".png")==OK,"Captura "+caso[0])
		html+="<h2>"+caso[0]+"</h2><img src='"+caso[0]+".png'>"
	FileAccess.open(carpeta+"/galeria.html",FileAccess.WRITE).store_string(html)
	camara.size=15; camara.position=Vector3(0,13,20.80435); camara.look_at(Vector3.ZERO)
	await esperar(15)
	var tiempos: Array[float]=[]; var anterior:=Time.get_ticks_usec()
	for i in 120:
		await process_frame
		var ahora:=Time.get_ticks_usec(); tiempos.append(float(ahora-anterior)/1000.0); anterior=ahora
	tiempos.sort()
	print("RENDIMIENTO_120_FRAMES: mediana_ms=",tiempos[60],"; p95_ms=",tiempos[114],"; draw_calls=",Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"; primitivas=",Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME))
	print("CAPTURAS: ",carpeta)
