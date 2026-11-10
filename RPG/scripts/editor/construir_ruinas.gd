extends SceneTree
## Autoría offline: regenera solo ruinas.tscn. No se ejecuta durante el juego.
var mapa := Node3D.new()
var rng := RandomNumberGenerator.new()
var piedra := piedra_material(Color(0.47,0.48,0.43))
var clara := piedra_material(Color(0.59,0.57,0.51))
var musgo := material(Color(0.22,0.32,0.16))
var tierra := material(Color(0.32,0.27,0.18))
var hierba := material(Color(0.25,0.35,0.19))

func piedra_material(color: Color) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = load("res://scripts/piedra_ruinas.gdshader")
	m.set_shader_parameter("color_piedra",color)
	return m

func material(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.95
	return m

func _initialize() -> void:
	call_deferred("construir")

func grupo(nombre: String) -> Node3D:
	var n := Node3D.new()
	n.name = nombre
	mapa.add_child(n)
	return n

func caja(padre: Node3D, nombre: String, p: Vector3, tam: Vector3, mat: Material, solida := true, giro := 0.0) -> Node3D:
	var n: Node3D = StaticBody3D.new() if solida else Node3D.new()
	n.name = nombre
	n.position = p
	n.rotation.y = giro
	padre.add_child(n)
	var m := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = tam
	m.mesh = mesh
	m.material_override = mat
	n.add_child(m)
	if solida:
		var c := CollisionShape3D.new()
		var s := BoxShape3D.new()
		s.size = tam
		c.shape = s
		n.add_child(c)
	return n

func columna(padre: Node3D, p: Vector2, h: float) -> void:
	caja(padre,"Basamento",Vector3(p.x,0.18,p.y),Vector3(1.6,0.36,1.6),clara)
	var cuerpo := StaticBody3D.new()
	padre.add_child(cuerpo)
	cuerpo.position = Vector3(p.x,0.36+h/2,p.y)
	var m := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.42
	mesh.bottom_radius = 0.53
	mesh.height = h
	mesh.radial_segments = 7
	m.mesh = mesh
	m.material_override = piedra
	cuerpo.add_child(m)
	var c := CollisionShape3D.new()
	var s := CylinderShape3D.new()
	s.radius = 0.53
	s.height = h
	c.shape = s
	cuerpo.add_child(c)
	if h>3:
		caja(padre,"Capitel",Vector3(p.x,h+0.5,p.y),Vector3(1.4,0.28,1.3),clara)

func modelo(padre: Node3D, ruta: String, p: Vector2, ancho: float, solido := false) -> void:
	assert(ResourceLoader.exists(ruta),ruta)
	var n: Node3D = load(ruta).instantiate()
	padre.add_child(n)
	var bounds := AABB()
	var primero := true
	for m in n.find_children("*","MeshInstance3D",true,false):
		var b: AABB = n.global_transform.affine_inverse()*m.global_transform*m.get_aabb()
		bounds = b if primero else bounds.merge(b)
		primero = false
	var escala := ancho/maxf(bounds.size.x,bounds.size.z)
	n.scale = Vector3.ONE*escala
	n.rotation.y = rng.randf()*TAU
	n.position = Vector3(p.x,-bounds.position.y*escala,p.y)
	n.set_meta("original",ruta)
	if solido:
		# Troncos y rocas: envolvente simple ajustada al volumen bajo visible.
		var altura := bounds.size.y*escala
		var radio := ancho*0.13 if altura>ancho else ancho*0.38
		var h := altura*0.38 if altura>ancho else altura*0.80
		var b := StaticBody3D.new()
		padre.add_child(b)
		b.position = Vector3(p.x,h/2,p.y)
		var c := CollisionShape3D.new()
		if ruta.contains("Fallen_Log"):
			var s := BoxShape3D.new()
			s.size = bounds.size*escala*Vector3(0.94,0.80,0.94)
			c.shape = s
			b.rotation.y = n.rotation.y
			var centro := (bounds.get_center()*escala).rotated(Vector3.UP,n.rotation.y)
			b.position = n.position+centro
		else:
			var s := CylinderShape3D.new()
			s.radius = radio
			s.height = h
			c.shape = s
		b.add_child(c)

func sendero(padre: Node3D, a: Vector2, b: Vector2, ancho: float) -> void:
	var medio := (a+b)/2
	var n := caja(padre,"Sendero",Vector3(medio.x,0.009,medio.y),Vector3(ancho,0.016,a.distance_to(b)+0.6),tierra,false,atan2(b.x-a.x,b.y-a.y))
	n.set_meta("desde",a)
	n.set_meta("hasta",b)
	n.set_meta("ancho",ancho)
	n.visible = false # La mezcla del terreno evita planos superpuestos.

func construir() -> void:
	rng.seed = 60481
	mapa.name = "Ruinas"
	root.add_child(mapa)
	var suelo := grupo("Terreno")
	var terreno := caja(suelo,"Suelo",Vector3(0,-0.3,0),Vector3(80,0.6,80),hierba)
	var acabado := ShaderMaterial.new()
	acabado.shader = load("res://scripts/terreno_ruinas.gdshader")
	terreno.get_child(0).material_override = acabado
	var limites := grupo("Limites")
	for x in [-40.5,40.5]:
		caja(limites,"LimiteX",Vector3(x,2,0),Vector3(1,4,82),hierba).get_child(0).visible = false
	for z in [-40.5,40.5]:
		caja(limites,"LimiteZ",Vector3(0,2,z),Vector3(80,4,1),hierba).get_child(0).visible = false
	var caminos := grupo("Caminos")
	for par in [[Vector2(0,36),Vector2(0,24)],[Vector2(0,24),Vector2(-7,13)],[Vector2(-7,13),Vector2(0,0)],[Vector2(0,0),Vector2(0,-24)],[Vector2(0,0),Vector2(23,2)],[Vector2(-7,13),Vector2(-17,9)]]:
		sendero(caminos,par[0],par[1],4.5)
	var entrada := grupo("Entrada")
	for p in [Vector2(-5,29),Vector2(6,26),Vector2(-6,20)]:
		caja(entrada,"MuroRoto",Vector3(p.x,0.65,p.y),Vector3(2.8,1.3,0.9),piedra,true,rng.randf_range(-0.3,0.3))
	var camino := grupo("CaminoAntiguo")
	for p in [Vector2(-11,17),Vector2(-3,17),Vector2(-11,6),Vector2(-18,6)]:
		columna(camino,p,rng.randf_range(0.7,2.7))
	caja(camino,"ColumnaCaida",Vector3(-13,0.48,16),Vector3(3.8,0.96,1),piedra,true,0.35)
	var plaza := grupo("Plaza")
	# Losas irregulares, bajas y sin colisión: suelo continuo debajo.
	for x in range(-5,6):
		for z in range(-4,5):
			if rng.randf()<0.12:
				continue
			caja(plaza,"Losa",Vector3(x*1.65+rng.randf_range(-0.08,0.08),0.025,z*1.7),Vector3(rng.randf_range(1.3,1.52),0.045,1.52),clara if rng.randf()<0.35 else piedra,false,rng.randf_range(-0.04,0.04))
	for p in [Vector2(-10,-7),Vector2(-10,1),Vector2(-9,7),Vector2(10,-6),Vector2(10,5),Vector2(5,-9)]:
		columna(plaza,p,rng.randf_range(0.8,3.8))
	caja(plaza,"PedestalVacio",Vector3(-5,0.6,-4),Vector3(2,1.2,2),clara)
	var santuario := grupo("Santuario")
	# Plataforma baja: rampa continua 1:10, sin exigir salto al controlador.
	caja(santuario,"Plataforma",Vector3(0,0.15,-25),Vector3(17,0.3,14),piedra)
	var rampa := caja(santuario,"RampaAcceso",Vector3(0,0.10,-16.5),Vector3(4.5,0.10,3.1),clara)
	rampa.rotation.x = deg_to_rad(5.71)
	for x in [-5.0,5.0]:
		columna(santuario,Vector2(x,-18.8),4.4)
	# Dintel partido: paso central abierto incluso desde arriba.
	caja(santuario,"DintelRotoOeste",Vector3(-3.6,4.8,-18.8),Vector3(3.8,0.6,1.1),clara,true,0.04)
	for par in [[Vector2(-8,-24),true,5],[Vector2(8,-26),true,3],[Vector2(-4,-32),false,4],[Vector2(5,-32),false,3]]:
		var centro: Vector2 = par[0]
		var lateral: bool = par[1]
		var cantidad: int = par[2]
		for tramo in cantidad:
			var altura: int = rng.randi_range(2,5)
			for nivel in altura:
				var desplazamiento: float = (float(tramo)-float(cantidad-1)/2)*1.65
				var p := Vector3(centro.x,0.3+0.325+float(nivel)*0.65,centro.y)
				p += Vector3(0,0,desplazamiento) if lateral else Vector3(desplazamiento,0,0)
				var tam := Vector3(0.9,0.64,1.62) if lateral else Vector3(1.62,0.64,0.9)
				caja(santuario,"SillarMuro",p,tam,clara if nivel%3==0 else piedra,true,rng.randf_range(-0.035,0.035))
	caja(santuario,"Altar",Vector3(0,0.9,-29),Vector3(3,1.2,1.6),clara)
	var jardin := grupo("Jardin")
	for x in [18,28]:
		caja(jardin,"BancoPiedra",Vector3(x,0.48,-3),Vector3(3.1,0.96,0.8),piedra,true,-0.12)
	for p in [Vector2(18,-7),Vector2(29,7),Vector2(30,-9)]:
		modelo(jardin,"res://assets/naturaleza/glTF/Rock_Medium_1.gltf",p,2.8,true)
	var vegetacion := grupo("Vegetacion")
	for i in 108:
		var lado := i%4
		var t := rng.randf_range(-37,37)
		var borde := rng.randf_range(31,38)
		var p := Vector2(t,borde if lado==0 else -borde) if lado<2 else Vector2(borde if lado==2 else -borde,t)
		if absf(p.x)<7 and p.y>28 or absf(p.x)<12 and p.y< -29:
			continue
		modelo(vegetacion,"res://assets/bosque/forest_nature_updated/Trees/Oak/Flat_Tree_Oak_medium_green.glb",p,rng.randf_range(4.4,6.8),true)
	for p in [Vector2(25,-10),Vector2(32,1),Vector2(19,10),Vector2(-20,18),Vector2(-22,-12)]:
		modelo(vegetacion,"res://assets/bosque/forest_nature_updated/Trees/Oak/Flat_Tree_Oak_large_green.glb",p,7,true)
	for i in 180:
		var p := Vector2(rng.randf_range(-36,36),rng.randf_range(-35,35))
		# Reservar plaza, santuario y todos los corredores.
		if absf(p.x)<13 and p.y<10 and p.y> -34:
			continue
		var cerca := false
		for n in caminos.get_children():
			var a: Vector2 = n.get_meta("desde")
			var b: Vector2 = n.get_meta("hasta")
			if p.distance_to(Geometry2D.get_closest_point_to_segment(p,a,b))<3.5:
				cerca = true
		if cerca:
			continue
		var nombre: String = ["Fern_1","Grass_Wispy_Short","Flower_3_Group","Bush_Common_Flowers"][i%4]
		modelo(vegetacion,"res://assets/naturaleza/glTF/"+nombre+".gltf",p,rng.randf_range(0.6,1.3))
	# Musgo y fragmentos en bordes de arquitectura, nunca en el eje de paso.
	for i in 32:
		var p := Vector3(rng.randf_range(-0.25,0.25)+( -8.9 if i%2==0 else 9.1),0.12,rng.randf_range(-29,5))
		caja(plaza,"FragmentoMusgoso",p,Vector3(0.7,0.24,0.6),musgo,false,rng.randf()*TAU)
	for i in 36:
		var lado := -1.0 if i%2==0 else 1.0
		var p := Vector3(lado*rng.randf_range(11.5,16),0.22,rng.randf_range(-30,20))
		var despejado := true
		for n in caminos.get_children():
			if Vector2(p.x,p.z).distance_to(Geometry2D.get_closest_point_to_segment(Vector2(p.x,p.z),n.get_meta("desde"),n.get_meta("hasta")))<3.5:
				despejado = false
		if not despejado:
			continue
		caja(camino,"Escombro",p,Vector3(rng.randf_range(0.5,1.3),0.44,rng.randf_range(0.6,1.2)),piedra,true,rng.randf()*TAU)
	for p in [Vector2(-7.4,-29),Vector2(7.3,-27),Vector2(-9,-6),Vector2(9,5),Vector2(-10,16),Vector2(19,-3)]:
		modelo(vegetacion,"res://assets/naturaleza/glTF/Fern_1.gltf",p,1.3)
		if p.y< -20:
			vegetacion.get_child(vegetacion.get_child_count()-1).position.y += 0.3
	modelo(jardin,"res://assets/bosque/forest_nature_updated/Extras/Flat_Fallen_Log.glb",Vector2(27,11),4,true)
	var marcas := grupo("Marcadores")
	for par in [["EntradaBosque",Vector3(0,0.05,34)],["RetornoBosque",Vector3(0,0,37)],["ZonaA",Vector3(0,0,29)],["ZonaB",Vector3(-7,0,13)],["ZonaC",Vector3(0,0,0)],["ZonaD",Vector3(0,0.3,-25)],["ZonaE",Vector3(23,0,2)]]:
		var m := Marker3D.new()
		m.name = par[0]
		m.position = par[1]
		marcas.add_child(m)
	marcas.get_node("RetornoBosque").set_meta("id_salida","ruinas_bosque_sur")
	marcas.get_node("RetornoBosque").set_meta("destino_previsto","Bosque")
	marcas.get_node("RetornoBosque").set_meta("activa",false)
	for n in mapa.find_children("*","",true,false):
		if n.owner==null:
			n.owner = mapa
	var packed := PackedScene.new()
	assert(packed.pack(mapa)==OK)
	assert(ResourceSaver.save(packed,"res://scenes/ruinas.tscn")==OK)
	print("RUINAS: escena serializada, semilla 60481")
	quit()
