extends SceneTree
## --headless para fisica; sin headless genera 10 PNG, galeria y muestra de 180 frames.
var fallos := 0
var comprobaciones := 0
var mundo: Node3D
var bosque: Node3D
var jugador: CharacterBody3D
var camara: Camera3D
var carpeta: String
var max_pendiente := 0.0
var min_y := INF
var max_y := -INF

func _initialize() -> void:
	call_deferred("validar")

func comprobar(ok: bool, mensaje: String) -> void:
	comprobaciones += 1
	if not ok:
		fallos += 1
		push_error(mensaje)

func esperar(n: int) -> void:
	for i in n:
		await physics_frame
	await process_frame

func suelo(p: Vector2) -> Dictionary:
	var q := PhysicsRayQueryParameters3D.create(Vector3(p.x,20,p.y),Vector3(p.x,-10,p.y))
	q.exclude = [jugador.get_rid()] + obstaculos_vegetacion()
	return mundo.get_world_3d().direct_space_state.intersect_ray(q)

func soltar() -> void:
	for accion in ["mover_izquierda","mover_derecha","mover_arriba","mover_abajo"]:
		Input.action_release(accion)

func recorrer(eje: PackedVector2Array, nombre: String) -> void:
	soltar()
	jugador.set_physics_process(false)
	var apoyo := suelo(eje[0])
	if apoyo.is_empty():
		comprobar(false,nombre+": falta suelo inicial")
		return
	jugador.position = apoyo.position+Vector3.UP*0.05
	jugador.velocity = Vector3.ZERO
	jugador.set_physics_process(true)
	await esperar(15)
	var soportados := 0
	var total := 0
	for i in range(1,eje.size()):
		var objetivo := eje[i]
		var llego := false
		for frame in 100:
			var p := Vector2(jugador.position.x,jugador.position.z)
			var d := objetivo-p
			# v^2/(2a)=2.08 u a velocidad 10: soltar antes del destino final.
			var distancia_frenado: float = jugador.velocity.slide(Vector3.UP).length_squared()/(2.0*jugador.desaceleracion)
			if d.length() < (maxf(0.43,distancia_frenado+0.15) if i==eje.size()-1 else 0.43):
				llego = true
				break
			soltar()
			var entrada := d.normalized()
			Input.action_press("mover_derecha" if entrada.x>0 else "mover_izquierda",absf(entrada.x))
			Input.action_press("mover_abajo" if entrada.y>0 else "mover_arriba",absf(entrada.y))
			await physics_frame
			total += 1
			if jugador.is_on_floor():
				soportados += 1
			comprobar(jugador.position.y > -2,nombre+": sin caida")
		comprobar(llego,nombre+": punto "+str(i)+" alcanzado")
		if not llego:
			print("ATASCO: ",nombre," punto ",i," jugador=",jugador.position," destino=",objetivo)
			break
	soltar()
	await esperar(35)
	comprobar(Vector2(jugador.position.x,jugador.position.z).distance_to(eje[-1])<1.4,nombre+": llegada y frenado")
	comprobar(Vector2(jugador.velocity.x,jugador.velocity.z).length()<0.05,nombre+": detenido")
	comprobar(total>0 and float(soportados)/maxi(total,1)>0.88,nombre+": apoyo continuo sin saltos")
	print("RECORRIDO ",nombre," apoyo=",soportados,"/",total)

func validar() -> void:
	print("VERSION: ",Engine.get_version_info().string," DISPLAY: ",DisplayServer.get_name())
	carpeta = "res://logs/fase6a1_bosque_base/"+Time.get_datetime_string_from_system().replace(":","-")+"_"+str(Time.get_ticks_msec())
	if "--fase6d" in OS.get_cmdline_user_args():
		carpeta = carpeta.replace("fase6a1_bosque_base","fase6d_bosque_ruinas/bosque")
	if "--fase6e" in OS.get_cmdline_user_args():
		carpeta = carpeta.replace("fase6a1_bosque_base","fase6e_campos_granjas/bosque")
	if "--fase6f" in OS.get_cmdline_user_args(): carpeta = carpeta.replace("fase6a1_bosque_base","fase6f_montanas/bosque")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(carpeta))
	mundo = load("res://scenes/pruebas_bosque.tscn").instantiate()
	root.add_child(mundo)
	current_scene = mundo
	bosque = mundo.get_node("Bosque")
	jugador = mundo.get_node("Jugador")
	camara = mundo.get_node("CamaraPrincipal")
	camara.set_process(false)
	camara.position = Vector3(0,80,40)
	camara.look_at(Vector3.ZERO)
	await esperar(20)
	var terreno: StaticBody3D = bosque.get_node("Terreno/Suelo")
	var caras: PackedVector3Array = bosque.get_node("Terreno/Superficie").mesh.get_faces()
	var fisicas: PackedVector3Array = terreno.get_node("SuperficieFisica").shape.get_faces()
	comprobar(caras.size()==60000,"20000 triangulos de terreno")
	comprobar(caras==fisicas,"Colision identica a geometria visible")
	comprobar(bosque.get_node("Caminos").get_child_count()==7,"Siete caminos")
	for id in ["Z01","Z02","Z03","Z04","Z05","Z06"]:
		comprobar(bosque.has_node("Reservas/"+id+"/PuntoInteres"),"Reserva "+id)
	# Cobertura real completa de suelo, incluyendo depresion y banda perimetral.
	for z in range(-48,49,2):
		for x in range(-48,49,2):
			var q := PhysicsRayQueryParameters3D.create(Vector3(x,20,z),Vector3(x,-10,z))
			q.exclude = [jugador.get_rid(),bosque.get_node("Reservas/ReservaLagunaCerrada").get_rid()] + obstaculos_vegetacion()
			var hit := mundo.get_world_3d().direct_space_state.intersect_ray(q)
			comprobar(not hit.is_empty() and hit.collider==terreno,"Cobertura de terreno "+str(Vector2(x,z)))
			if not hit.is_empty():
				min_y = minf(min_y,hit.position.y)
				max_y = maxf(max_y,hit.position.y)
				comprobar(rad_to_deg(hit.normal.angle_to(Vector3.UP))<35,"Relieve suave en malla completa")
	var consulta := PhysicsShapeQueryParameters3D.new()
	consulta.shape = jugador.get_node("ColisionJugador").shape
	consulta.exclude = [jugador.get_rid(),terreno.get_rid()]
	var ejes: Array[PackedVector2Array] = []
	for ruta in bosque.get_node("Caminos").get_children():
		var eje: PackedVector2Array = ruta.get_meta("eje")
		ejes.append(eje)
		var ancho: float = ruta.get_meta("ancho")
		for i in eje.size():
			var direccion := (eje[mini(i+1,eje.size()-1)]-eje[maxi(0,i-1)]).normalized()
			var lado := Vector2(-direccion.y,direccion.x)
			for offset in [-ancho*0.5+0.4,0.0,ancho*0.5-0.4]:
				var p: Vector2 = eje[i]+lado*offset
				# Los ultimos metros terminan ante cierre provisional, no lo atraviesan.
				if absf(p.y)>47.5:
					continue
				comprobar(((p-Vector2(-29,22))/Vector2(8.4,6.4)).length()>1,"Camino fuera de laguna reservada")
				var arroyo: PackedVector2Array = bosque.get_node("Reservas/Arroyo").get_meta("eje")
				var distancia_agua := INF
				for k in range(1,arroyo.size()):
					distancia_agua = minf(distancia_agua,p.distance_to(Geometry2D.get_closest_point_to_segment(p,arroyo[k-1],arroyo[k])))
				comprobar(distancia_agua>1.6,"Camino fuera del arroyo previsto")
				var hit := suelo(p)
				comprobar(not hit.is_empty() and hit.collider==terreno,str(ruta.name)+": suelo libre")
				if hit.is_empty():
					continue
				var pendiente := rad_to_deg(hit.normal.angle_to(Vector3.UP))
				max_pendiente = maxf(max_pendiente,pendiente)
				comprobar(pendiente<25,str(ruta.name)+": pendiente <25 grados")
				consulta.transform = Transform3D(Basis.IDENTITY,hit.position+Vector3.UP*1.05)
				comprobar(mundo.get_world_3d().direct_space_state.intersect_shape(consulta).is_empty(),str(ruta.name)+": ancho libre de obstaculos")
	# Grafo basado en puntos reales de la polilinea, no solo en nombres de caminos.
	var alcanzados: Array[int] = [0]
	for paso in ejes.size():
		for i in ejes.size():
			if i in alcanzados:
				continue
			for j in alcanzados.duplicate():
				var conectado := false
				for a in [ejes[i][0],ejes[i][-1]]:
					for b in ejes[j]:
						if a.distance_to(b)<0.75:
							conectado = true
				if conectado:
					alcanzados.append(i)
					break
	comprobar(alcanzados.size()==7,"Grafo conectado de siete rutas")
	for zona in bosque.get_node("Reservas").get_children():
		if not str(zona.name).begins_with("Z"):
			continue
		var cercano := false
		for eje in ejes:
			for p in eje:
				if p.distance_to(Vector2(zona.position.x,zona.position.z))<0.75:
					cercano = true
		comprobar(cercano,str(zona.name)+": conectada a entrada")
	for salida in bosque.get_node("Marcadores").get_children():
		for meta in ["id_salida","destino_previsto","orientacion","camino_conexion","limite_provisional","retorno_previsto"]:
			comprobar(salida.has_meta(meta),str(salida.name)+": contrato "+meta)
		comprobar(bosque.has_node(salida.get_meta("camino_conexion")),"Camino regional existe")
		comprobar(bosque.has_node(salida.get_meta("limite_provisional")),"Cierre regional existe")
		for nombre in ["Aproximacion","TransicionFutura","LimiteProvisional","AparicionSegura"]:
			comprobar(salida.has_node(nombre),"Marcador regional "+nombre)
	comprobar(bosque.get_node("Marcadores/RetornoAldea").get_meta("retorno_previsto")=="aldea_bosque_norte","Retorno compatible con aldea")
	comprobar(bosque.find_children("*","Area3D",true,false).is_empty(),"Sin transiciones funcionales")
	# Barrido de capsula contra cierres: todos los lados, incluidos accesos y esquinas.
	for t in range(-48,49,3):
		for par in [[Vector2(t,47),Vector3(0,0,6)],[Vector2(t,-47),Vector3(0,0,-6)],[Vector2(47,t),Vector3(6,0,0)],[Vector2(-47,t),Vector3(-6,0,0)]]:
			var hit := suelo(par[0])
			consulta.transform = Transform3D(Basis.IDENTITY,hit.position+Vector3.UP*1.05)
			consulta.motion = par[1]
			var fracciones := mundo.get_world_3d().direct_space_state.cast_motion(consulta)
			comprobar(fracciones[0]<1,"Cierre perimetral "+str(par[0]))
	consulta.motion = Vector3.ZERO
	# La reserva de agua futura tampoco admite entrar por huecos entre cajas.
	for i in 40:
		var radial := Vector2(cos(TAU*i/40.0),sin(TAU*i/40.0))
		var p := Vector2(-29,22)+radial*Vector2(10,8)
		consulta.transform = Transform3D(Basis.IDENTITY,suelo(p).position+Vector3.UP*1.05)
		consulta.motion = Vector3(-radial.x,0,-radial.y)*4
		comprobar(mundo.get_world_3d().direct_space_state.cast_motion(consulta)[0]<1,"Reserva laguna cerrada")
	consulta.motion = Vector3.ZERO
	# Control negativo: un bloqueo inyectado en el camino debe detectarse.
	var negativo := StaticBody3D.new()
	var col := CollisionShape3D.new()
	var caja := BoxShape3D.new()
	caja.size = Vector3(4,3,4)
	col.shape = caja
	negativo.add_child(col)
	mundo.add_child(negativo)
	negativo.position = Vector3(0,1.5,0)
	await esperar(2)
	consulta.transform = Transform3D(Basis.IDENTITY,Vector3(0,1.85,0))
	comprobar(not mundo.get_world_3d().direct_space_state.intersect_shape(consulta).is_empty(),"Control negativo detecta bloqueo real")
	negativo.queue_free()
	await esperar(2)
	# Recorridos con script, entradas, capsula, aceleracion y velocidad originales.
	for i in ejes.size():
		var eje := ejes[i].duplicate()
		# Acabar antes de los cierres fisicos; el acceso regional sigue bloqueado.
		while absf(eje[0].y)>46:
			eje.remove_at(0)
		while absf(eje[-1].y)>46:
			eje.remove_at(eje.size()-1)
		await recorrer(eje,"ruta "+str(i+1)+" ida")
		eje.reverse()
		await recorrer(eje,"ruta "+str(i+1)+" vuelta")
	print("TERRENO altura=[",min_y,",",max_y,"] pendiente maxima caminos=",max_pendiente)
	if DisplayServer.get_name()!="headless":
		await capturar()
	print("RESULTADO_BOSQUE: ",fallos," fallos / ",comprobaciones," comprobaciones")
	quit(0 if fallos==0 else 1)

func capturar() -> void:
	soltar()
	jugador.set_physics_process(false)
	root.size = Vector2i(1600,1000)
	camara.far = 250
	var vistas := [
		["01_superior",Vector2(0,0),112.0,Vector3(0,130,0.01)],
		["02_entrada",Vector2(0,40),22.0,Vector3(0,14,21)],
		["03_claro_central",Vector2(0,0),29.0,Vector3(0,20,25)],
		["04_campamento",Vector2(-25,-25),26.0,Vector3(0,20,25)],
		["05_ruinas",Vector2(24,-26),26.0,Vector3(0,20,25)],
		["06_mirador",Vector2(29,20),26.0,Vector3(24,14,15)],
		["07_laguna_reservada",Vector2(-27,22),29.0,Vector3(0,24,20)],
		["08_red_caminos",Vector2(0,0),114.0,Vector3(0,110,55)],
		["09_relieve",Vector2(10,10),90.0,Vector3(70,36,20)],
		["10_limites",Vector2(0,-38),44.0,Vector3(0,20,22)]]
	var html := "<!doctype html><meta charset='utf-8'><title>Bosque 6A.1</title><style>body{background:#18231f;color:#e3e6d7;font:16px sans-serif;margin:30px}img{width:100%;max-width:1400px}section{margin:32px 0}</style><h1>Bosque · base 6A.1</h1><p>100×100. Norte = −Z. Reservas sin decorar; arcilla gris = agua futura seca, no agua terminada. Protagonista original como escala. Vegetación y aprobación artística pendientes.</p>"
	var rotulos: Array[Label3D] = []
	for zona in bosque.get_node("Reservas").get_children():
		if not str(zona.name).begins_with("Z"):
			continue
		var rotulo := Label3D.new()
		rotulo.text = str(zona.name)+" · "+str(zona.get_meta("descripcion"))
		rotulo.font_size = 48
		rotulo.pixel_size = 0.05
		rotulo.outline_size = 10
		rotulo.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		rotulo.no_depth_test = true
		mundo.add_child(rotulo)
		rotulo.position = zona.position+Vector3.UP*1.5
		rotulos.append(rotulo)
	for vista in vistas:
		for rotulo in rotulos:
			rotulo.visible = vista[0] in ["01_superior","08_red_caminos"]
		var hit := suelo(vista[1])
		var centro: Vector3 = hit.position
		# La laguna permanece cerrada; referencia siempre en ribera.
		var referencia: Vector2 = Vector2(-18,21) if vista[0]=="07_laguna_reservada" else vista[1]
		jugador.position = suelo(referencia).position+Vector3.UP*0.05
		camara.size = vista[2]
		camara.position = centro+vista[3]
		camara.look_at(centro)
		await esperar(12)
		await RenderingServer.frame_post_draw
		comprobar(root.get_texture().get_image().save_png(carpeta+"/"+vista[0]+".png")==OK,"Captura "+vista[0])
		html += "<section><h2>"+vista[0]+"</h2><img src='"+vista[0]+".png'></section>"
	var archivo := FileAccess.open(carpeta+"/galeria.html",FileAccess.WRITE)
	archivo.store_string(html)
	for rotulo in rotulos:
		rotulo.queue_free()
	# Muestra sin fixed-fps: escena base, sin vegetacion, no representa carga futura.
	camara.size = 15
	jugador.position = suelo(Vector2.ZERO).position+Vector3.UP*0.05
	camara.position = jugador.position+Vector3(0,13.8,20.80435)
	camara.look_at(jugador.position+Vector3.UP*0.8)
	await esperar(30)
	var tiempos: Array[float] = []
	for i in 180:
		var inicio := Time.get_ticks_usec()
		await process_frame
		tiempos.append((Time.get_ticks_usec()-inicio)/1000.0)
	tiempos.sort()
	var rendimiento := "180 frames; mediana %.3f ms; p95 %.3f ms; draw calls %s; primitivas %s. Escena base sin vegetacion; no garantiza rendimiento futuro."%[tiempos[90],tiempos[171],Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)]
	if bosque.has_node("Vegetacion"):
		rendimiento = rendimiento.replace("Escena base sin vegetacion; no garantiza rendimiento futuro.","Escena con vegetacion; muestra puntual, no benchmark prolongado.")
	FileAccess.open(carpeta+"/rendimiento.txt",FileAccess.WRITE).store_string(rendimiento)
	print("RENDIMIENTO: ",rendimiento)
	print("GALERIA: ",carpeta+"/galeria.html")

# Rayos de cota independientes; barridos y recorridos conservan todos los obstáculos.
func obstaculos_vegetacion() -> Array[RID]:
	var r: Array[RID] = []
	if bosque.has_node("Vegetacion/Obstaculos"):
		r.append(bosque.get_node("Vegetacion/Obstaculos").get_rid())
	return r
