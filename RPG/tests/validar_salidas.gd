extends "res://tests/validar_distribucion.gd"

func validar() -> void:
	print("VERSION: ",Engine.get_version_info().string)
	mundo=load("res://scenes/mundo.tscn").instantiate()
	root.add_child(mundo)
	current_scene=mundo
	aldea=mundo.get_node("Aldea")
	jugador=mundo.get_node("Jugador")
	await esperar(20)
	consulta.shape=jugador.get_node("ColisionJugador").shape
	consulta.exclude=[jugador.get_rid()]
	await validar_salidas_regionales()
	if DisplayServer.get_name()!="headless":
		await capturar_salidas()
	print("RESULTADO_SALIDAS: ",fallos," fallos; ",muestras," muestras")
	quit(0 if fallos==0 else 1)

func capturar_salidas() -> void:
	var carpeta:="res://logs/fase4b6_salidas/"+Time.get_datetime_string_from_system().replace(":","-")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(carpeta))
	var camara: Camera3D=mundo.get_node("CamaraPrincipal")
	camara.set_process(false); camara.far=250
	jugador.set_physics_process(false)
	var casos := [
		["bosque_interior",Vector3(0,0,-34),Vector3(0,9,15)],
		["bosque_retorno",Vector3(0,0,-34),Vector3(0,8,-13)],
		["campos_interior",Vector3(0,0,34),Vector3(0,9,-15)],
		["campos_retorno",Vector3(0,0,34),Vector3(0,8,13)],
		["este_interior",Vector3(38,0,0),Vector3(-15,10,0)],
		["este_retorno",Vector3(38,0,0),Vector3(13,8,0)],
		["puente_ruta_este",Vector3(30,0,0),Vector3(0,18,28)],
		["general_salidas",Vector3(0,0,0),Vector3(0,90,65)]
	]
	var html:="<!doctype html><meta charset='utf-8'><title>Salidas 4B.6</title><style>body{background:#20241c;color:#eee;font:16px sans-serif}img{width:80%}</style><h1>Salidas regionales</h1>"
	for caso in casos:
		var objetivo: Vector3=caso[1]+Vector3.UP*.7
		camara.size=9 if caso[0]!="puente_ruta_este" and caso[0]!="general_salidas" else 28 if caso[0]=="puente_ruta_este" else 95
		camara.position=objetivo+caso[2]
		camara.look_at(objetivo)
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
