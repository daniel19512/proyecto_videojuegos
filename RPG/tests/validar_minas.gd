extends "res://tests/validar_montanas.gd"
## Recorridos reales, apoyo, límites, lago y capturas orbitales en la nueva región.

func andar(puntos: PackedVector3Array) -> bool:
	var j: CharacterBody3D = current_scene.get_node("Jugador")
	for destino in puntos:
		var llego := false
		for i in 1200:
			var d := Vector2(destino.x-j.position.x,destino.z-j.position.z)
			if d.length()<.35:
				llego = true
				break
			orientar_entrada(d.normalized())
			await physics_frame
			altura_baja = minf(altura_baja,j.position.y)
			altura_alta = maxf(altura_alta,j.position.y)
			if j.is_on_floor(): apoyos += 1
			if j.position.y< -20: break
		liberar()
		await esperar(8)
		comprobar(llego,"Ruta hasta "+str(destino)+" real="+str(j.position))
		comprobar(absf(j.position.y-destino.y)<.5,"Cota caminable "+str(destino))
		if not llego:
			for k in j.get_slide_collision_count(): print("BLOQUEO ",j.get_slide_collision(k).get_collider().get_path())
			return false
	return true

func vistas(nombre: String) -> void:
	var camara := current_scene.get_node("CamaraPrincipal")
	camara.set_process(false)
	camara.centro_seguimiento = current_scene.get_node("Jugador").position
	for i in 8:
		camara.angulo_horizontal = i*TAU/8
		camara.actualizar_orbita()
		await esperar(2)
		await captura(nombre+"_"+str(i*45))
	camara.angulo_horizontal = 0
	camara.actualizar_orbita()
	camara.set_process(true)

func validar() -> void:
	carpeta = "res://logs/fase_minas/recorrido_"+Time.get_datetime_string_from_system().replace(":","-")+"_"+str(Time.get_ticks_msec())
	DirAccess.make_dir_recursive_absolute(carpeta)
	root.size = Vector2i(1280,800)
	gestor = root.get_node("GestorRegiones")
	var mundo: Node3D = load("res://scenes/mundo_minas.tscn").instantiate()
	root.add_child(mundo)
	current_scene = mundo
	mundo.get_node("Region/SalidaMontanas").monitoring = false
	await esperar(20)
	var j: CharacterBody3D = mundo.get_node("Jugador")
	comprobar(j.is_on_floor() and absf(j.position.y)<.1,"Aparicion sobre suelo superior")
	await vistas("A_entrada")
	var principal: PackedVector3Array = mundo.get_node("Minas/Recorridos/Principal").get_meta("eje")
	comprobar(await andar(principal.slice(2,5)),"Entrada galeria y extraccion caminando")
	await vistas("C_extraccion")
	var deposito: PackedVector3Array = mundo.get_node("Minas/Recorridos/Deposito").get_meta("eje")
	comprobar(await andar(deposito),"Acceso al deposito")
	await vistas("F_deposito")
	deposito.reverse()
	comprobar(await andar(deposito),"Retorno del deposito")
	comprobar(await andar(principal.slice(4,7)),"Descenso a galerias profundas")
	await vistas("D_profunda")
	var abandonado: PackedVector3Array = mundo.get_node("Minas/Recorridos/Abandonado").get_meta("eje")
	comprobar(await andar(abandonado),"Ramal abandonado explorable")
	await vistas("F_abandonado")
	abandonado.reverse()
	comprobar(await andar(abandonado),"Retorno ramal abandonado")
	comprobar(await andar(principal.slice(6)),"Acceso a gran caverna")
	await vistas("E_caverna")
	comprobar(await andar(PackedVector3Array([Vector3(3,-12,-87),Vector3(7,-12,-87)])),"Plataforma y pasarela transitables")
	await vistas("E_estanque")
	if DisplayServer.get_name()!="headless":
		var camara_agua := mundo.get_node("CamaraPrincipal")
		camara_agua.set_process(false)
		await captura("agua_t0")
		var inicial := root.get_texture().get_image()
		await esperar(120)
		await captura("agua_t2")
		var final := root.get_texture().get_image()
		var cambios := 0
		# Muestreo restringido a la proyección del estanque, con cámara fija.
		var centro_agua: Vector2 = camara_agua.unproject_position(Vector3(16,-13.1,-84))
		for x in range(maxi(0,int(centro_agua.x)-70),mini(inicial.get_width(),int(centro_agua.x)+70),2):
			for y in range(maxi(0,int(centro_agua.y)-35),mini(inicial.get_height(),int(centro_agua.y)+35),2):
				if inicial.get_pixel(x,y)!=final.get_pixel(x,y): cambios += 1
		comprobar(cambios>20,"Agua animada visible con camara fija")
		FileAccess.open(carpeta+"/agua_movimiento.json",FileAccess.WRITE).store_string(JSON.stringify({"pixeles_distintos":cambios,"centro":str(centro_agua)},"\t"))
		camara_agua.set_process(true)
	var antes := j.position
	orientar_entrada(Vector2(16-j.position.x,-84-j.position.z).normalized())
	await esperar(120)
	liberar()
	await esperar(10)
	comprobar(j.position.x<10 and j.position.y> -12.4,"Orilla impide caminar sobre agua profunda")
	comprobar(j.position.distance_to(antes)<5,"Barrera fisica del estanque")
	comprobar(await andar(PackedVector3Array([Vector3(7,-12,-87),Vector3(3,-12,-87),Vector3(0,-12,-87)])),"Retorno de la orilla")
	var inversa := principal.slice(1)
	inversa.reverse()
	comprobar(await andar(inversa),"Subida completa sin salto")
	comprobar(altura_baja< -11.8 and altura_alta> -.1 and apoyos>400,"Tres elevaciones reales y apoyo continuo")
	var espacio := mundo.get_world_3d().direct_space_state
	var piso: MeshInstance3D = mundo.get_node("Minas/TerrenoYTuneles/SueloExcavado")
	var agua: MeshInstance3D = mundo.get_node("Minas/AguaYOrillas/Estanque")
	var normales_agua: PackedVector3Array = agua.mesh.surface_get_arrays(0)[Mesh.ARRAY_NORMAL]
	for normal in normales_agua: comprobar(normal.y>.99,"Agua orientada hacia la camara superior")
	var vertices: PackedVector3Array = piso.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	for i in range(0,vertices.size()-2,30):
		var v := (vertices[i]+vertices[i+1]+vertices[i+2])/3.0
		var q := PhysicsRayQueryParameters3D.create(v+Vector3.UP*.25,v-Vector3.UP*.35)
		q.exclude = [j.get_rid()]
		var hit := espacio.intersect_ray(q)
		comprobar(not hit.is_empty(),"Suelo continuo y colision real "+str(v))
	# El fondo real del estanque está por debajo del agua: no hay collider a su cota.
	var q := PhysicsRayQueryParameters3D.create(Vector3(16,-12.8,-84),Vector3(16,-16,-84))
	var hit := espacio.intersect_ray(q)
	comprobar(not hit.is_empty() and hit.position.y< -14,"Cubeta excavada bajo agua Y=-13.1")
	var paredes: MeshInstance3D = mundo.get_node("Minas/TerrenoYTuneles/Paredes")
	var vs: PackedVector3Array = paredes.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	for i in range(0,vs.size(),6):
		var centro := (vs[i]+vs[i+1])*.5+Vector3.UP
		var normal := (vs[i+1]-vs[i]).cross(Vector3.UP).normalized()
		var consulta := PhysicsRayQueryParameters3D.create(centro-normal*.3,centro+normal*.3)
		consulta.hit_back_faces = true
		comprobar(not espacio.intersect_ray(consulta).is_empty(),"Cierre de pared "+str(i))
	var camara := mundo.get_node("CamaraPrincipal")
	comprobar(camara.size==15 and camara.get_script()==load("res://scripts/camara_orbital.gd"),"Camara compartida intacta")
	Input.action_press("girar_camara_derecha")
	var giro := 0.0
	var previo: float = camara.angulo_horizontal
	for i in 310:
		await process_frame
		giro += absf(wrapf(camara.angulo_horizontal-previo,-PI,PI))
		previo = camara.angulo_horizontal
	liberar()
	comprobar(giro>TAU,"Orbita completa por Input")
	var html := "<!doctype html><meta charset='utf-8'><title>Minas</title><style>body{background:#171e23;color:#ddd;font:18px sans-serif}img{max-width:100%}</style><h1>Minas · recorrido y ocho angulos</h1>"
	for n in capturas: html += "<h2>"+n+"</h2><img loading='lazy' src='"+n+".png'>"
	FileAccess.open(carpeta+"/galeria.html",FileAccess.WRITE).store_string(html)
	print("MINAS_RECORRIDO: ",fallos," fallos / ",muestras," comprobaciones; cotas=",altura_baja,"..",altura_alta," apoyos=",apoyos," carpeta=",carpeta)
	quit(1 if fallos else 0)
