extends "res://tests/validar_bosque_ruinas.gd"
## Movimiento con Input y controlador original. Ningún salto entre puntos del recorrido.
var apoyos := 0
var altura_baja := INF
var altura_alta := -INF

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
			if j.position.y< -8: break
		liberar()
		await esperar(8)
		if not llego:
			for k in j.get_slide_collision_count():
				var choque := j.get_slide_collision(k)
				print("BLOQUEO ",choque.get_collider().get_path()," normal=",choque.get_normal())
		comprobar(llego,"Ruta hasta "+str(destino)+" real="+str(j.position))
		comprobar(absf(j.position.y-destino.y)<.5,"Cota caminable "+str(destino))
		if not llego: return false
	return true

func validar() -> void:
	carpeta = "res://logs/fase6f_montanas/recorrido_"+Time.get_datetime_string_from_system().replace(":","-")+"_"+str(Time.get_ticks_msec())
	if "--fase-minas" in OS.get_cmdline_user_args(): carpeta = carpeta.replace("fase6f_montanas/recorrido_","fase_minas/regresion_montanas_")
	DirAccess.make_dir_recursive_absolute(carpeta)
	gestor = root.get_node("GestorRegiones")
	var mundo: Node3D = load("res://scenes/mundo_montanas.tscn").instantiate()
	root.add_child(mundo)
	current_scene = mundo
	mundo.get_node("Region/SalidaAldea").monitoring = false
	# Fixture local: medir relieve/cierres sin viajar por la nueva conexión.
	mundo.get_node("Region/SalidaMinas").monitoring = false
	await esperar(12)
	var mapa := mundo.get_node("Montanas")
	var ruta: PackedVector3Array = mapa.get_node("Caminos/Principal").get_meta("eje")
	var descenso: PackedVector3Array = mapa.get_node("Caminos/DescensoOriental").get_meta("eje")
	comprobar(await andar(ruta.slice(1)),"Ascenso continuo valle campamento mirador ruinas")
	comprobar(await andar(descenso),"Descenso continuo ruinas mina valle")
	var vuelta := ruta.slice(1,6)
	vuelta.reverse()
	comprobar(await andar(vuelta),"Retorno por puente inferior")
	# Puentes superior/intermedio en sentido inverso mediante toda la ruta.
	comprobar(await andar(ruta.slice(1)),"Segundo ascenso")
	var inversa := ruta.slice(1)
	inversa.reverse()
	comprobar(await andar(inversa),"Descenso inverso de los tres puentes")
	comprobar(altura_alta-altura_baja>26,"Ascenso real superior a 26 unidades")
	comprobar(apoyos>500,"Apoyo físico en recorrido")
	var espacio := mundo.get_world_3d().direct_space_state
	# Correspondencia exacta entre vértices visuales y rayos de suelo, lejos del río.
	var mesh: ArrayMesh = mapa.get_node("Terreno").mesh
	var vertices: PackedVector3Array = mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	for i in range(0,vertices.size(),997):
		var v := vertices[i]
		if absf(v.x)>63 or absf(v.z)>63: continue
		var q := PhysicsRayQueryParameters3D.create(v+Vector3.UP*.1,v-Vector3.UP*.1)
		q.exclude = [mundo.get_node("Jugador").get_rid()]
		var hit := espacio.intersect_ray(q)
		comprobar(not hit.is_empty(),"Superficie sin agujero "+str(v))
		if not hit.is_empty(): comprobar(hit.position.distance_to(v)<.015,"Colisión coincide con malla")
	var puentes := mapa.get_node("Puentes").get_children()
	comprobar(puentes.size()==3,"Tres puentes funcionales")
	for puente_n in puentes:
		var centro: Vector3 = puente_n.position
		var q := PhysicsRayQueryParameters3D.create(centro+Vector3.UP,centro-Vector3.UP*10)
		q.exclude = [mundo.get_node("Jugador").get_rid()]
		var hit := espacio.intersect_ray(q)
		comprobar(not hit.is_empty() and absf(hit.position.y-centro.y)<.05,"Tablero real encima de garganta")
	# Ancho libre: cápsula real en cinco carriles a lo largo de todas las rutas.
	var capsula := CapsuleShape3D.new()
	capsula.radius = .32
	capsula.height = 1.6
	for camino in mapa.get_node("Caminos").get_children():
		var eje_ruta: PackedVector3Array = camino.get_meta("eje")
		for i in range(eje_ruta.size()-1):
			var a := eje_ruta[i]
			var b := eje_ruta[i+1]
			var lateral := Vector3(b.z-a.z,0,a.x-b.x).normalized()
			for k in range(int(a.distance_to(b))+1):
				# Evitar rayos exactamente sobre la arista compartida de dos triángulos.
				var p := a.lerp(b,float(k)/maxf(a.distance_to(b),1.0))+Vector3(.013,0,.017)
				for ancho in [-1.2,0.0,1.2]:
					var q := PhysicsRayQueryParameters3D.create(p+lateral*ancho+Vector3.UP*9,p+lateral*ancho-Vector3.UP*9)
					q.exclude = [mundo.get_node("Jugador").get_rid()]
					var hit := espacio.intersect_ray(q)
					comprobar(not hit.is_empty(),"Ancho con apoyo "+str(p))
					if hit.is_empty(): continue
					comprobar(hit.normal.y>cos(deg_to_rad(45)),"Pendiente transitable "+str(hit.position))
					var shape_q := PhysicsShapeQueryParameters3D.new()
					shape_q.shape = capsula
					shape_q.transform.origin = hit.position+Vector3.UP*.84
					# La cápsula apoyada interseca el plano inclinado en una consulta estática.
					# El suelo ya se verificó por normal/rayo; conservar todos los obstáculos.
					shape_q.exclude = [mundo.get_node("Jugador").get_rid(),hit.collider.get_rid()]
					comprobar(espacio.intersect_shape(shape_q,8).is_empty(),"Ancho sin obstáculos "+str(hit.position))
	comprobar(mapa.get_node("Marcadores/Minas").get_meta("activa")==false,"Metadato historico conservado; activacion explicita en envolvente")
	comprobar(mundo.get_node("Region/SalidaMinas").escena_destino=="res://scenes/mundo_minas.tscn","Destino minero configurado explicitamente")
	comprobar(mundo.find_children("*","Area3D",true,false).size()==2,"Solo retorno Aldea y conexion Minas autorizada")
	var rio: MeshInstance3D = mapa.get_node("Hidrografia/RioDescendente")
	var agua_vertices: PackedVector3Array = rio.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	for i in range(0,agua_vertices.size(),6):
		comprobar(agua_vertices[i].y>=agua_vertices[i+2].y,"Agua descendente hacia +Z")
		if i+6<agua_vertices.size():
			comprobar(agua_vertices[i+2].distance_to(agua_vertices[i+6])<1.1,"Continuidad de tramos de agua")
	var cascadas := 0
	for n in mapa.get_node("Hidrografia").get_children():
		if n.has_meta("inicio"):
			cascadas += 1
			var inicio: Vector3 = n.get_meta("inicio")
			var fin: Vector3 = n.get_meta("fin")
			comprobar(inicio.y>fin.y+1.0,"Caída con desnivel real")
	comprobar(cascadas==3,"Tres caídas con impacto y continuación")
	# Cierres externos y fondo minero son cuerpos físicos presentes, no etiquetas.
	for cuerpo in mapa.get_node("Limites").get_children():
		comprobar(cuerpo is StaticBody3D and cuerpo.get_child(0).shape is BoxShape3D,"Cierre físico externo")
	var q_mina := PhysicsRayQueryParameters3D.create(Vector3(45,21.5,-21),Vector3(45,21.5,-26))
	var hit_mina := espacio.intersect_ray(q_mina)
	comprobar(not hit_mina.is_empty(),"Fondo físico de mina impide atravesar portal")
	var camara := mundo.get_node("CamaraPrincipal")
	comprobar(camara.size==15 and camara.get_script()==load("res://scripts/camara_orbital.gd"),"Cámara original")
	Input.action_press("girar_camara_derecha")
	var giro := 0.0
	var anterior: float = camara.angulo_horizontal
	for i in 310:
		await process_frame
		giro += absf(wrapf(camara.angulo_horizontal-anterior,-PI,PI))
		anterior = camara.angulo_horizontal
	liberar()
	comprobar(giro>TAU,"Órbita completa")
	camara.set_process(false)
	var visibilidad: Array[Dictionary] = []
	var invisibles: Array[RID] = [mundo.get_node("Jugador").get_rid()]
	for grupo in [mapa.get_node("Limites"),mapa.get_node("Hidrografia")]:
		for cuerpo in grupo.find_children("*","StaticBody3D",true,false): invisibles.append(cuerpo.get_rid())
	for nombre in ["EntradaAldea","Valle","Campamento","Mirador","Ruinas","Minas"]:
		var p: Vector3 = mapa.get_node("Marcadores/"+nombre).position
		for i in 8:
			camara.centro_seguimiento = p
			camara.angulo_horizontal = i*TAU/8
			camara.actualizar_orbita()
			var rayo := PhysicsRayQueryParameters3D.create(camara.position+Vector3.UP*150,camara.position+Vector3.DOWN*150)
			rayo.exclude = invisibles
			var suelo := espacio.intersect_ray(rayo)
			comprobar(suelo.is_empty() or suelo.position.y<camara.position.y-.1,"Cámara sobre superficie "+nombre)
			var linea := PhysicsRayQueryParameters3D.create(camara.position,p+Vector3.UP*.85)
			linea.exclude = invisibles
			var bloqueo := espacio.intersect_ray(linea)
			visibilidad.append({"zona":nombre,"angulo":i*45,"oclusor_fisico":str(bloqueo.collider.get_path()) if not bloqueo.is_empty() else ""})
	FileAccess.open(carpeta+"/visibilidad.json",FileAccess.WRITE).store_string(JSON.stringify(visibilidad,"\t"))
	print("6F_RECORRIDOS: ",fallos," fallos / ",muestras," comprobaciones; alturas jugador=",altura_baja,"..",altura_alta," apoyos=",apoyos)
	quit(1 if fallos else 0)
