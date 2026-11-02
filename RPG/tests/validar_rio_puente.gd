extends "res://tests/validar_distribucion.gd"
## Headless: fisica. Con ventana y -- --capturas: vistas y secuencia temporal fija.
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
	await validar_ribera()
	if "--capturas" in OS.get_cmdline_user_args() and DisplayServer.get_name() != "headless":
		await capturar_mejoras()
	print("RESULTADO_FASE4A1: ",fallos," fallos")
	quit(0 if fallos==0 else 1)

func capturar_mejoras() -> void:
	jugador.set_physics_process(false)
	jugador.global_position = Vector3(27.5,.5,0)
	var camara: Camera3D = mundo.get_node("CamaraPrincipal")
	camara.set_process(false)
	var carpeta := "res://logs/fase4a1_rio_mejorado/"+Time.get_datetime_string_from_system().replace(":","-")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(carpeta))
	var vistas := [
		["01_extremo_norte",Vector3(30,0,-34.5),12,90],
		["02_extremo_sur",Vector3(30,0,34.5),12,90],
		["03_cauce_completo",Vector3(29,0,0),44,0],
		["04_puente",Vector3(30,.4,0),15,45],
		["05_molino_rueda",Vector3(26,1.7,-10),15,90],
		["06_orillas",Vector3(30,0,22),12,45],
		["07_mapa_elevado",Vector3(0,0,0),80,0]]
	for vista in vistas:
		camara.size = vista[2]
		var centro: Vector3 = vista[1]
		camara.global_position = centro+Vector3(0,13,20.80435).rotated(Vector3.UP,deg_to_rad(float(vista[3])))
		if vista[0]=="07_mapa_elevado": camara.global_position=centro+Vector3(0,70,.01)
		camara.look_at(centro)
		await esperar(12)
		await RenderingServer.frame_post_draw
		comprobar(root.get_texture().get_image().save_png(carpeta+"/"+vista[0]+".png")==OK,"Captura "+vista[0])
	# Vista cenital fija, lejos de rueda/jugador: solo el shader puede cambiar la imagen.
	camara.size=8
	camara.global_position=Vector3(30,15,20.01)
	camara.look_at(Vector3(30,.32,20))
	await esperar(12)
	var anterior: Image
	var csv := FileAccess.open(carpeta+"/tiempos_animacion.csv",FileAccess.WRITE)
	csv.store_line("fotograma,segundos_desde_inicio")
	var inicio := Time.get_ticks_msec()
	for i in range(45):
		await esperar(4)
		await RenderingServer.frame_post_draw
		var img := root.get_texture().get_image()
		img.save_png(carpeta+"/anim_%03d.png"%i)
		csv.store_line(str(i)+","+str(float(Time.get_ticks_msec()-inicio)/1000.0))
		if i in [0,15,30]:
			img.save_png(carpeta+"/agua_t%02d.png"%(i/15))
			if anterior != null:
				var diferencia := 0.0
				var cambiados := 0
				for x in range(img.get_width()/2-80,img.get_width()/2+80,2):
					for y in range(img.get_height()/2-80,img.get_height()/2+80,2):
						var a := img.get_pixel(x,y)
						var b := anterior.get_pixel(x,y)
						var d := (absf(a.r-b.r)+absf(a.g-b.g)+absf(a.b-b.b))/3.0
						diferencia+=d
						if d>.01: cambiados+=1
				print("ANIMACION: diferencia media=",diferencia/6400," fraccion cambiada=",float(cambiados)/6400)
				comprobar(diferencia/6400>.003 and cambiados>640,"Agua: patron cambia visiblemente entre fotogramas con camara fija")
			anterior=img
	csv.close()
	print("CAPTURAS: ",carpeta)
