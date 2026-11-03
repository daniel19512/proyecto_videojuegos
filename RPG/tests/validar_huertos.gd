extends "res://tests/validar_distribucion.gd"
## Sin ventana: geometría y recorridos. Con ventana: añade 31 vistas en logs/.
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
	await validar_huertos()
	comprobar(solidos_huertos.size()==3,"Los tres huertos superan validación geométrica y física")
	if DisplayServer.get_name()!="headless":
		await capturar_huertos()
	print("RESULTADO_HUERTOS: ",fallos," fallos; ",muestras," muestras")
	quit(0 if fallos==0 else 1)

func capturar_huertos() -> void:
	var carpeta := "res://logs/fase4b2_huertos/"+Time.get_datetime_string_from_system().replace(":","-")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(carpeta))
	var camara: Camera3D = mundo.get_node("CamaraPrincipal")
	camara.set_process(false)
	camara.far=250
	jugador.set_physics_process(false)
	var nombres := ["sur","sureste","este","noreste","norte","noroeste","oeste","suroeste"]
	var html := "<!doctype html><meta charset='utf-8'><title>Huertos 4B.2</title><style>body{background:#20241c;color:#eee;font:16px sans-serif}img{width:48%;margin:1%}</style><h1>Huertos de la aldea</h1>"
	for huerto: Node3D in aldea.get_node("Huertos").get_children():
		var centro := huerto.global_position+Vector3(0,0.4,0)
		var entrada: Vector2 = huerto.get_meta("entrada_local")
		jugador.global_position=huerto.global_position+Vector3(0,0.02,entrada.y)
		html+="<h2>"+String(huerto.name)+"</h2>"
		for i in 8:
			camara.size=15
			camara.global_position=centro+Vector3(0,13,20.80435).rotated(Vector3.UP,TAU*float(i)/8)
			camara.look_at(centro)
			var nombre: String = String(huerto.name)+"_"+nombres[i]
			await guardar_vista(carpeta,nombre)
			html+="<img src='"+nombre+".png'>"
		camara.size=8
		camara.global_position=centro+Vector3(2.5,8,6)
		camara.look_at(centro)
		await guardar_vista(carpeta,String(huerto.name)+"_cultivos")
		html+="<img src='"+String(huerto.name)+"_cultivos.png'>"
		camara.size=23
		var contexto := centro+Vector3(4,0,4) if huerto.name=="HuertoComunitario" else centro+Vector3(0,0,-4.5)
		camara.global_position=contexto+Vector3(0,22,17)
		camara.look_at(contexto)
		await guardar_vista(carpeta,String(huerto.name)+"_contexto")
		html+="<img src='"+String(huerto.name)+"_contexto.png'>"
	camara.size=66
	camara.global_position=Vector3(-10,80,24.01)
	camara.look_at(Vector3(-10,0,24))
	await guardar_vista(carpeta,"todos_los_huertos")
	html+="<h2>Conjunto</h2><img src='todos_los_huertos.png'>"
	var archivo := FileAccess.open(carpeta+"/galeria.html",FileAccess.WRITE)
	archivo.store_string(html)
	print("CAPTURAS: ",carpeta)

func guardar_vista(carpeta: String, nombre: String) -> void:
	await esperar(10)
	await RenderingServer.frame_post_draw
	comprobar(root.get_texture().get_image().save_png(carpeta+"/"+nombre+".png")==OK,"Captura "+nombre)
