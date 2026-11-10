extends SceneTree
## Autoría offline. Semilla y catálogo estables; nunca se ejecuta al jugar.
const SEMILLA := 62024
var rng := RandomNumberGenerator.new()
var bosque: Node3D
var salida := Node3D.new()
var modelos := {}
var grupos := {}
var puntos: Array[Vector2] = []
var radios: Array[float] = []
var registros: Array = []
var fisica := StaticBody3D.new()

func _initialize() -> void:
	call_deferred("construir")

func distancia(p: Vector2, eje: PackedVector2Array) -> float:
	var d := INF
	for i in range(1,eje.size()):
		d = minf(d,p.distance_to(Geometry2D.get_closest_point_to_segment(p,eje[i-1],eje[i])))
	return d

func libre(p: Vector2, radio: float, arbol: bool) -> bool:
	if maxf(absf(p.x),absf(p.y))+radio>49.0:
		return false
	for camino in bosque.get_node("Caminos").get_children():
		var margen := 2.6 if arbol else 0.55
		if distancia(p,camino.get_meta("eje"))<float(camino.get_meta("ancho"))*0.5+radio+margen:
			return false
	for zona in bosque.get_node("Reservas").get_children():
		if str(zona.name).begins_with("Z"):
			var centro := Vector2(zona.position.x,zona.position.z)
			var semiejes: Vector2 = zona.get_meta("semiejes")
			if ((p-centro)/(semiejes+Vector2.ONE*(radio+0.7))).length()<1.0:
				return false
	if ((p-Vector2(-29,22))/(Vector2(8,6)+Vector2.ONE*(radio+1))).length()<1:
		return false
	if distancia(p,bosque.get_node("Reservas/Arroyo").get_meta("eje"))<1.7+radio:
		return false
	for puente in [Vector2(-40,-30),Vector2(-39,9)]:
		if p.distance_to(puente)<3+radio:
			return false
	return true

func piezas(n: Node, t: Transform3D, lista: Array) -> void:
	var actual := t
	if n is Node3D:
		actual = t*n.transform
	if n is MeshInstance3D:
		lista.append([n.mesh,actual])
	for hijo in n.get_children():
		piezas(hijo,actual,lista)

func construir() -> void:
	if DisplayServer.get_name()=="headless":
		push_error("La autoria MultiMesh requiere render real para guardar buffers; usar sin --headless")
		quit(1)
		return
	rng.seed = SEMILLA
	bosque = load("res://scenes/bosque.tscn").instantiate()
	root.add_child(bosque)
	await physics_frame
	await physics_frame
	salida.name = "Vegetacion"
	salida.set_meta("semilla",SEMILLA)
	salida.add_child(fisica)
	fisica.name = "Obstaculos"
	var catalogo: Array = JSON.parse_string(FileAccess.get_file_as_string("res://tests/seleccion_assets_bosque.json"))
	var ids := ["A01","A02","A04","A05","A07","A08","A09","A10","A11","A12","A13","A14","B01","B02","B03","B04","B07","B08","B09","B10","B11","B12","B13","B14","B15","B18","B19","B20","C01","C03","C04","C08","C09","C10","C12","C13"]
	for dato in catalogo:
		if dato.id not in ids:
			continue
		var ruta: String = "res://"+str(dato.ruta).trim_prefix("RPG/")
		assert(ResourceLoader.exists(ruta))
		var instancia: Node3D = load(ruta).instantiate()
		var lista: Array = []
		piezas(instancia,Transform3D.IDENTITY,lista)
		var caja := AABB()
		var primero := true
		for pieza in lista:
			var aabb: AABB = pieza[1]*pieza[0].get_aabb()
			caja = aabb if primero else caja.merge(aabb)
			primero = false
		modelos[dato.id] = {"ruta":ruta,"escala":float(dato.escala),"piezas":lista,"aabb":caja,"nombre":dato.nombre}
		instancia.free()
	# Densidad según copas reales: separación variable 0.40 de diámetro,
	# cobertura solapada en periferia y respiración junto a rutas/reservas.
	for intento in 18000:
		var p := Vector2(rng.randf_range(-48,48),rng.randf_range(-48,48))
		var borde := maxf(absf(p.x),absf(p.y))
		var id: String
		if p.y>30:
			id = ["A02","A05","A09","A10","A02"][rng.randi_range(0,4)]
		elif p.x>12 and p.y< -12:
			id = ["A07","A08","A08","A11","A12","A01"][rng.randi_range(0,5)]
		elif p.x< -15 and p.y>8:
			id = ["A04","A04","A01","A02"][rng.randi_range(0,3)]
		else:
			id = ["A01","A01","A02","A05","A04","A07","A08"][rng.randi_range(0,6)]
		var m: Dictionary = modelos[id]
		var escala: float = m.escala*rng.randf_range(0.85,1.10)
		var diametro: float = maxf(m.aabb.size.x,m.aabb.size.z)*escala
		var r := maxf(1.35,diametro*(0.36 if borde>40 else 0.46))
		if not libre(p,0.55,true):
			continue
		var valido := true
		for i in puntos.size():
			if p.distance_to(puntos[i])<r+radios[i]:
				valido = false
		if not valido:
			continue
		puntos.append(p)
		radios.append(r)
		colocar(id,p,escala,"Arboles")
	# Grupos irregulares alrededor de árboles y núcleos libres.
	for intento in 5500:
		var centro: Vector2 = puntos[rng.randi_range(0,puntos.size()-1)] if intento%3!=0 else Vector2(rng.randf_range(-47,47),rng.randf_range(-47,47))
		var p := centro+Vector2.from_angle(rng.randf()*TAU)*rng.randf_range(0.9,4.5)
		var id: String = ["B01","B02","B03","B04","B07","B08","B09","B10","B11","B12","B13","B14","B15","B18","B19","B20"][rng.randi_range(0,15)]
		var categoria := "Arbustos" if id in ["B01","B02","B03","B04"] else "Plantas"
		var escala: float = modelos[id].escala*rng.randf_range(0.8,1.15)
		var aabb: AABB = modelos[id].aabb
		var radio := maxf(aabb.size.x,aabb.size.z)*escala*0.5
		if libre(p,radio,false):
			colocar(id,p,escala,categoria)
	for intento in 260:
		var p := Vector2(rng.randf_range(-47,47),rng.randf_range(-47,47))
		var id: String = ["C01","C03","C04","C08","C09","C10","C12","C13","A13","A14"][rng.randi_range(0,9)]
		var escala: float = modelos[id].escala*rng.randf_range(0.7,1.0)
		if id=="C01":
			escala *= 0.55
		var caja: AABB = modelos[id].aabb
		var radio := Vector2(caja.size.x,caja.size.z).length()*escala*0.5
		if libre(p,radio,false):
			colocar(id,p,escala,"Troncos" if id.begins_with("A") else "Rocas")
	for clave in grupos:
		var datos: Dictionary = grupos[clave]
		var padre := Node3D.new()
		padre.name = clave
		salida.add_child(padre)
		var m: Dictionary = modelos[datos.id]
		for k in m.piezas.size():
			var mm := MultiMesh.new()
			mm.transform_format = MultiMesh.TRANSFORM_3D
			mm.mesh = m.piezas[k][0]
			mm.instance_count = datos.transforms.size()
			for i in mm.instance_count:
				mm.set_instance_transform(i,datos.transforms[i]*m.piezas[k][1])
			var visual := MultiMeshInstance3D.new()
			visual.name = "Malla"+str(k)
			visual.multimesh = mm
			padre.add_child(visual)
	for n in salida.find_children("*","",true,false):
		n.owner = salida
	var escena := PackedScene.new()
	assert(escena.pack(salida)==OK)
	assert(ResourceSaver.save(escena,"res://scenes/vegetacion_bosque.tscn")==OK)
	FileAccess.open("res://scenes/vegetacion_bosque_datos.json",FileAccess.WRITE).store_string(JSON.stringify({"semilla":SEMILLA,"instancias":registros},"\t"))
	print("VEGETACION: ",puntos.size()," arboles; ",registros.size()," elementos; ",grupos.size()," grupos")
	salida.free()
	quit()

func colocar(id: String, p: Vector2, escala: float, categoria: String) -> void:
	var q := PhysicsRayQueryParameters3D.create(Vector3(p.x,20,p.y),Vector3(p.x,-10,p.y))
	q.collision_mask = 1
	if bosque.has_node("Vegetacion/Obstaculos"):
		q.exclude = [bosque.get_node("Vegetacion/Obstaculos").get_rid()]
	var hit := bosque.get_world_3d().direct_space_state.intersect_ray(q)
	if hit.is_empty() or hit.collider!=bosque.get_node("Terreno/Suelo"):
		return
	var m: Dictionary = modelos[id]
	var caja: AABB = m.aabb
	var giro := rng.randf()*TAU
	var t := Transform3D(Basis(Vector3.UP,giro).scaled(Vector3.ONE*escala),hit.position-Vector3.UP*caja.position.y*escala)
	var sector := Vector2i(floori((p.x+50)/25),floori((p.y+50)/25))
	var clave := categoria+"_"+str(sector.x)+"_"+str(sector.y)+"_"+id
	if not grupos.has(clave):
		grupos[clave] = {"id":id,"transforms":[]}
	grupos[clave].transforms.append(t)
	registros.append({"id":id,"ruta":m.ruta,"categoria":categoria,"sector":[sector.x,sector.y],"x":p.x,"z":p.y,"y":hit.position.y,"escala":escala,"giro":giro,"base_y":caja.position.y,"alto":caja.size.y*escala})
	if categoria=="Arboles" or categoria=="Troncos" or (categoria=="Rocas" and caja.size.y*escala>0.65):
		var col := CollisionShape3D.new()
		if categoria=="Arboles":
			var forma := CylinderShape3D.new()
			forma.radius = 0.30 if id in ["A04","A11","A12"] else 0.42
			forma.height = minf(3.0,caja.size.y*escala)
			col.shape = forma
			col.position = hit.position+Vector3.UP*forma.height*0.5
		else:
			var forma := BoxShape3D.new()
			forma.size = caja.size*escala*Vector3(0.85,0.8,0.85)
			col.shape = forma
			col.transform = t*Transform3D(Basis.IDENTITY,caja.get_center())
		fisica.add_child(col)
