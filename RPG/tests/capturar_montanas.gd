extends "res://tests/validar_transiciones.gd"
## Capturas reales: no sustituye la prueba física independiente.
func validar() -> void:
	if DisplayServer.get_name()=="headless":
		push_error("Las capturas requieren render real")
		quit(1)
		return
	carpeta = "res://logs/fase6f_montanas/vistas_"+Time.get_datetime_string_from_system().replace(":","-")+"_"+str(Time.get_ticks_msec())
	DirAccess.make_dir_recursive_absolute(carpeta)
	root.size = Vector2i(1440,900)
	var mundo: Node3D = load("res://scenes/mundo_montanas.tscn").instantiate()
	root.add_child(mundo)
	current_scene = mundo
	await esperar(30)
	var j := mundo.get_node("Jugador")
	j.set_physics_process(false)
	var c := mundo.get_node("CamaraPrincipal")
	c.set_process(false)
	for zona in ["EntradaAldea","Valle","Campamento","Mirador","Ruinas","Minas","Lago"]:
		var p: Vector3 = mundo.get_node("Montanas/Marcadores/"+zona).position
		j.position = p
		c.centro_seguimiento = p
		c.size = 15
		for i in 4:
			c.angulo_horizontal = i*PI/2
			c.actualizar_orbita()
			await esperar(8)
			await captura(zona+"_"+str(i))
	for puente in mundo.get_node("Montanas/Puentes").get_children():
		j.position = puente.position
		c.centro_seguimiento = puente.position
		c.angulo_horizontal = PI/4
		c.actualizar_orbita()
		await esperar(8)
		await captura("Puente_"+puente.name)
	for par in [["Sendero_campamento",Vector3(28,12,22)],["Ascenso_mirador",Vector3(-23,19,-4)],["Ascenso_superior",Vector3(-24,28,-34)]]:
		j.position = par[1]
		c.centro_seguimiento = par[1]
		c.angulo_horizontal = PI/4
		c.actualizar_orbita()
		await esperar(8)
		await captura(par[0])
	for par in [["Superior",Vector3(0,145,4),Vector3(0,10,0),146.0],["Relieve_oblicuo",Vector3(105,91,115),Vector3(0,17,0),140.0],["Perfil_lateral",Vector3(108,48,10),Vector3(0,17,0),120.0],["Cascada_superior",Vector3(13,38,-11),Vector3(-6,22,-24),23.0],["Cascada_central",Vector3(14,29,29),Vector3(-5,13,9),23.0],["Rapidos",Vector3(13,16,62),Vector3(-4,2,44),20.0]]:
		c.size = par[3]
		c.position = par[1]
		c.look_at(par[2],Vector3.FORWARD if par[0]=="Superior" else Vector3.UP)
		await esperar(10)
		await captura(par[0])
	# Misma cámara y dos tiempos: evidencia de animación del agua.
	await create_timer(1.0).timeout
	await captura("Rapidos_movimiento")
	var html := "<!doctype html><meta charset='utf-8'><title>Montañas 6F</title><style>body{background:#20292b;color:#eee;font:18px sans-serif;margin:30px}img{width:100%;max-width:1200px}a{color:#edca8f}</style><h1>Montañas — relieve y puntos de interés</h1><p>Capturas automatizadas Forward+. Recorrido físico en validar_montanas.gd. Revisión artística del usuario pendiente.</p>"
	for n in capturas: html += "<h2>"+n+"</h2><a href='"+n+".png'><img loading='lazy' src='"+n+".png'></a>"
	FileAccess.open(carpeta+"/galeria.html",FileAccess.WRITE).store_string(html)
	print("6F_CAPTURAS: ",capturas.size()," PNG; ",carpeta)
	quit(1 if fallos else 0)
