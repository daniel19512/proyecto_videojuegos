extends SceneTree
## Valida materiales, cierres geometricos y vistas de E01/E02/E06 con camara principal.
var fallos := 0
var mundo: Node3D
func _initialize() -> void:
	call_deferred("validar")
func comprobar(valor: bool, texto: String) -> void:
	if not valor:
		fallos += 1
		push_error(texto)
	else:
		print("OK: ",texto)
func esperar(n: int) -> void:
	for i in n:
		await physics_frame
	await process_frame
func intersecta(caras: PackedVector3Array, a: Vector3, b: Vector3) -> bool:
	for i in range(0,caras.size(),3):
		if Geometry3D.segment_intersects_triangle(a,b,caras[i],caras[i+1],caras[i+2]) != null:
			return true
	return false
func validar() -> void:
	print("VERSION: ",Engine.get_version_info().string)
	mundo=load("res://scenes/mundo.tscn").instantiate()
	root.add_child(mundo)
	current_scene=mundo
	var jugador: CharacterBody3D=mundo.get_node("Jugador")
	var camara: Camera3D=mundo.get_node("CamaraPrincipal")
	await esperar(20)
	jugador.set_physics_process(false)
	for id in ["E01","E02","E06"]:
		var edificio: Node3D=mundo.get_node("Aldea/Edificios/"+id)
		var cuerpo: Vector2=edificio.get_meta("cuerpo")
		var caras := PackedVector3Array()
		var materiales := true
		for m: MeshInstance3D in edificio.find_children("*","MeshInstance3D",true,false):
			for superficie in m.mesh.get_surface_count():
				materiales = materiales and m.get_active_material(superficie)!=null
			for punto in m.mesh.get_faces():
				caras.append(m.global_transform*punto)
		comprobar(materiales,id+": todas las superficies con material")
		var cierre := true
		var rayos := 0
		for normal in [Vector3.RIGHT,Vector3.LEFT,Vector3.BACK,Vector3.FORWARD]:
			var horizontal: Vector3=Vector3(-normal.z,0,normal.x)
			var mitad: float=cuerpo.x*0.5 if normal.x!=0 else cuerpo.y*0.5
			var longitud: float=cuerpo.y if normal.x!=0 else cuerpo.x
			for i in range(int(longitud*4)):
				var lateral: float=-longitud*0.5+(i+0.5)*0.25
				for altura in [0.25,1.0,2.65]:
					var pared: Vector3=edificio.global_position+horizontal*lateral+Vector3.UP*altura+normal*mitad
					var golpe := intersecta(caras,pared+normal*0.6,pared-normal*0.5)
					if not golpe:
						print("HUECO ",id," ",normal," lateral ",lateral," altura ",altura)
					cierre=cierre and golpe
					rayos+=1
		comprobar(cierre,id+": continuidad geometrica de cuatro fachadas (%d rayos)"%rayos)
		for grados in [0,45,90,135,180,225,270,315]:
			var angulo := deg_to_rad(float(grados))
			var salida := Vector3.BACK.rotated(Vector3.UP,angulo)
			var retiro: float=(cuerpo.x*0.5 if absf(salida.x)>0.9 else cuerpo.y*0.5)+1.4
			if id == "E06":
				# Situar al jugador en la banda transitable interior, sin meterlo en el huerto o el servicio.
				var limite_x: float = 3.25 if salida.x >= 0 else 2.95
				retiro = minf(limite_x/maxf(absf(salida.x),0.001),3.95/maxf(absf(salida.z),0.001))
			if id == "E02":
				# Rodear el horno exterior por el borde oeste de la parcela.
				var limite_x: float = 3.9 if salida.x >= 0 else 4.3
				retiro = minf(limite_x/maxf(absf(salida.x),0.001),4.5/maxf(absf(salida.z),0.001))
			jugador.global_position=edificio.global_position+salida*retiro
			jugador.global_position.y=0.02
			jugador.velocity=Vector3.ZERO
			if id in ["E02", "E06"]:
				var consulta := PhysicsShapeQueryParameters3D.new()
				consulta.shape = jugador.get_node("ColisionJugador").shape
				consulta.exclude = [jugador.get_rid()]
				consulta.transform = Transform3D(Basis.IDENTITY,jugador.global_position+Vector3.UP*0.8)
				comprobar(mundo.get_world_3d().direct_space_state.intersect_shape(consulta).is_empty(),"%s: punto de observacion libre en %d"%[id,grados])
			camara.set("angulo_horizontal",angulo)
			await esperar(45)
			comprobar(is_equal_approx(camara.size,15) and absf(camara.rotation_degrees.x+32)<0.05,id+": camara 15 e inclinacion en %d"%grados)
			if DisplayServer.get_name()!="headless":
				await RenderingServer.frame_post_draw
				comprobar(root.get_texture().get_image().save_png("user://edificios_360_%s_%03d.png"%[id,grados])==OK,"Captura "+id+" "+str(grados))
	jugador.set_physics_process(true)
	print("RESULTADO_EDIFICIOS_360: %d fallos"%fallos)
	quit(0 if fallos==0 else 1)
