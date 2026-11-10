extends SceneTree
const NATURE := "res://assets/naturaleza/glTF/"
const PROPS := "res://assets/objetos_medievales/glTF/"
var mapa := Node3D.new()
var rng := RandomNumberGenerator.new()
var rutas: Array[PackedVector3Array] = []
var cache: Dictionary = {}
var usados: Dictionary = {}
var madera := material(Color(.28,.17,.09))
var tablas := material(Color(.49,.33,.18))
var piedra := material(Color(.42,.46,.45))
var oscuro := material(Color(.035,.045,.045))
var tela := material(Color(.66,.43,.17))
var espuma := material(Color(.69,.88,.85))
var agua: ShaderMaterial
var minimo := INF
var maximo := -INF
const PERFIL := [Vector2(-72,29),Vector2(-42,27),Vector2(-26,26),Vector2(-23,18),Vector2(-10,17),Vector2(8,15),Vector2(11,7),Vector2(28,5),Vector2(42,3),Vector2(45,.8),Vector2(72,.2)]

func _initialize() -> void:
	call_deferred("construir")

func material(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = .93
	return m

func grupo(p: Node, nombre: String, pos := Vector3.ZERO) -> Node3D:
	var n := Node3D.new()
	n.name = nombre
	n.position = pos
	p.add_child(n)
	return n

func colision(p: Node3D, pos: Vector3, tam: Vector3) -> void:
	var b := StaticBody3D.new()
	b.position = pos
	p.add_child(b)
	var c := CollisionShape3D.new()
	var s := BoxShape3D.new()
	s.size = tam
	c.shape = s
	b.add_child(c)

func caja(p: Node3D, nombre: String, pos: Vector3, tam: Vector3, mat: Material, solida := false) -> Node3D:
	var n := grupo(p,nombre,pos)
	var m := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = tam
	m.mesh = mesh
	m.material_override = mat
	n.add_child(m)
	if solida: colision(n,Vector3.ZERO,tam)
	return n

func viga(p: Node3D, a: Vector3, b: Vector3, ancho: float, mat: Material, solida := false) -> void:
	var n := caja(p,"Viga",(a+b)*.5,Vector3(ancho,a.distance_to(b),ancho),mat,solida)
	n.quaternion = Quaternion(Vector3.UP,(b-a).normalized())

func modelo(p: Node3D, ruta: String, pos: Vector3, alto: float, giro: float, solido := false) -> void:
	if not cache.has(ruta):
		var prueba: Node3D = load(ruta).instantiate()
		mapa.add_child(prueba)
		var bounds := AABB()
		var primero := true
		for m in prueba.find_children("*","MeshInstance3D",true,false):
			var b: AABB = prueba.global_transform.affine_inverse()*m.global_transform*m.get_aabb()
			bounds = b if primero else bounds.merge(b)
			primero = false
		cache[ruta] = bounds
		prueba.free()
	var bounds: AABB = cache[ruta]
	var escala := alto/bounds.size.y
	var n: Node3D = load(ruta).instantiate()
	p.add_child(n)
	n.scale = Vector3.ONE*escala
	n.rotation.y = giro
	n.position = pos-(Vector3(bounds.get_center().x,bounds.position.y,bounds.get_center().z)*escala).rotated(Vector3.UP,giro)
	n.set_meta("original",ruta)
	usados[ruta] = int(usados.get(ruta,0))+1
	if solido:
		var ancho := .45 if "Pine" in ruta else minf(bounds.size.x*escala,.95)
		colision(p,pos+Vector3.UP*alto*.4,Vector3(ancho,alto*.8,ancho))

func rio_x(z: float) -> float:
	return -6.0+sin(z*.065)*4.0

func agua_y(z: float) -> float:
	for i in range(PERFIL.size()-1):
		if z<=PERFIL[i+1].x:
			return lerpf(PERFIL[i].y,PERFIL[i+1].y,inverse_lerp(PERFIL[i].x,PERFIL[i+1].x,z))
	return .2

func camino_cercano(p: Vector2) -> Vector2:
	var d := INF
	var y := 0.0
	var suma := 0.0
	var pesos := 0.0
	for ruta in rutas:
		for i in range(ruta.size()-1):
			var a := Vector2(ruta[i].x,ruta[i].z)
			var b := Vector2(ruta[i+1].x,ruta[i+1].z)
			var q := Geometry2D.get_closest_point_to_segment(p,a,b)
			var distancia := p.distance_to(q)
			var cota := lerpf(ruta[i].y,ruta[i+1].y,a.distance_to(q)/a.distance_to(b))
			# Mezclar tramos vecinos evita costuras de altura en las curvas.
			var peso := exp(-distancia*distancia/8.0)
			suma += cota*peso
			pesos += peso
			if distancia<d:
				d = distancia
				y = cota
	return Vector2(d,suma/pesos if pesos>.000001 else y)

func altura(p: Vector2) -> float:
	var c := camino_cercano(p)
	var base := 3.0+(55.0-p.y)*.25
	var ondulacion := 2.0*sin(p.x*.12)*cos(p.y*.09)+sin(p.x*.29+p.y*.13)
	# Crestas angulosas y terrazas erosionadas fuera de los senderos.
	ondulacion += smoothstep(9.0,17.0,c.x)*(absf(sin(p.x*.23+p.y*.14))*3.0+sin(p.y*.31)*1.4)
	var crestas := pow(smoothstep(28.0,69.0,absf(p.x)),1.3)*19.0
	var norte := smoothstep(42.0,72.0,-p.y)*15.0
	var h := base+ondulacion+crestas+norte
	for zona in [Vector3(28,12,10),Vector3(-32,23,-18),Vector3(30,29,-42),Vector3(45,20,-20)]:
		var d := p.distance_to(Vector2(zona.x,zona.z))
		h = lerpf(zona.y,h,smoothstep(7.0,13.0,d))
	h = lerpf(c.y,h,smoothstep(3.2,9.0,c.x))
	for zona in [Vector3(28,12,10),Vector3(-32,23,-18),Vector3(30,29,-42),Vector3(45,20,-20)]:
		h = lerpf(zona.y,h,smoothstep(7.0,20.0,p.distance_to(Vector2(zona.x,zona.z))))
	# Cuencas abiertas en los descansos: espacio para la orbita original, sin editarla.
	for zona in [Vector3(-52,2,48),Vector3(16,6,30),Vector3(28,12,10),Vector3(-32,23,-18),Vector3(30,29,-42),Vector3(45,20,-20)]:
		var distancia := p.distance_to(Vector2(zona.x,zona.z))
		var entrada: bool = zona.x== -52
		var techo: float = zona.y+1.0+distancia*(.15 if entrada else .48)
		h = lerpf(minf(h,techo),h,smoothstep(32.0 if entrada else 23.0,40.0 if entrada else 30.0,distancia))
	# Cauce excavado real: no se rellena bajo los tres puentes.
	var ancho := 3.3+1.0*sin(p.y*.11)*sin(p.y*.11)
	var cauce := 1.0-smoothstep(ancho,ancho+3.0,absf(p.x-rio_x(p.y)))
	h = lerpf(h,agua_y(p.y)-2.2,cauce)
	# Cubeta alpina conectada al nacimiento.
	var lago := Vector2((p.x+6)/10.0,(p.y+53)/8.0).length()
	h = lerpf(h,25.0,1.0-smoothstep(.85,1.25,lago))
	return h

func malla(p: Node3D, nombre: String, vertices: PackedVector3Array, mat: Material) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for v in vertices: st.add_vertex(v)
	st.generate_normals()
	var n := MeshInstance3D.new()
	n.name = nombre
	n.mesh = st.commit()
	n.material_override = mat
	p.add_child(n)
	return n

func terreno() -> void:
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.vertex_color_is_srgb = true
	mat.roughness = .96
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_smooth_group(-1)
	for z in range(-96,96):
		for x in range(-96,96):
			for o in [Vector2.ZERO,Vector2.RIGHT,Vector2.DOWN,Vector2.RIGHT,Vector2.ONE,Vector2.DOWN]:
				var p: Vector2 = Vector2(x,z)+o
				var h := altura(p)
				minimo = minf(minimo,h)
				maximo = maxf(maximo,h)
				var d := camino_cercano(p).x
				var color := Color(.29,.38,.23).lerp(Color(.43,.45,.43),smoothstep(18,40,h))
				var pendiente := absf(altura(p+Vector2.RIGHT)-h)+absf(altura(p+Vector2.DOWN)-h)
				color = color.lerp(Color(.39,.42,.42),smoothstep(.6,2.5,pendiente))
				color = color.lerp(Color(.57,.45,.29),1.0-smoothstep(2.0,3.1,d))
				color = color.lerp(Color(.80,.84,.82),smoothstep(42,51,h))
				st.set_color(color*(.95+.05*sin(p.x*2.4+p.y*1.9)))
				st.add_vertex(Vector3(p.x,h,p.y))
	st.generate_normals()
	var mesh := st.commit()
	mesh.surface_set_material(0,mat)
	assert(ResourceSaver.save(mesh,"res://scenes/montanas_terreno.res")==OK)
	var forma := mesh.create_trimesh_shape()
	assert(ResourceSaver.save(forma,"res://scenes/montanas_colision.res")==OK)
	var n := MeshInstance3D.new()
	n.name = "Terreno"
	n.mesh = load("res://scenes/montanas_terreno.res")
	mapa.add_child(n)
	var b := StaticBody3D.new()
	b.name = "Suelo"
	n.add_child(b)
	var c := CollisionShape3D.new()
	c.shape = load("res://scenes/montanas_colision.res")
	b.add_child(c)

func hidrografia() -> void:
	var g := grupo(mapa,"Hidrografia")
	agua = ShaderMaterial.new()
	agua.shader = load("res://scripts/agua_montanas.gdshader")
	var vertices := PackedVector3Array()
	for z in range(-54,70):
		var a := Vector3(rio_x(z),agua_y(z),z)
		var b := Vector3(rio_x(z+1),agua_y(z+1),z+1)
		var w := 3.4+sin(z*.11)*sin(z*.11)
		for v in [a+Vector3(-w,0,0),a+Vector3(w,0,0),b+Vector3(-w,0,0),a+Vector3(w,0,0),b+Vector3(w,0,0),b+Vector3(-w,0,0)]: vertices.append(v)
	malla(g,"RioDescendente",vertices,agua)
	vertices.clear()
	var centro := Vector3(-6,agua_y(-53),-53)
	for i in 48:
		var a := TAU*i/48.0
		var b := TAU*(i+1)/48.0
		vertices.append_array(PackedVector3Array([centro,centro+Vector3(sin(a)*10,0,cos(a)*8),centro+Vector3(sin(b)*10,0,cos(b)*8)]))
	malla(g,"LagoAlpino",vertices,agua)
	for z in [-23.0,11.0,45.0]:
		var n := grupo(g,"Cascada",Vector3(rio_x(z),agua_y(z),z))
		n.set_meta("inicio",Vector3(rio_x(z-3),agua_y(z-3),z-3))
		n.set_meta("fin",n.position)
		for i in 9:
			var m := MeshInstance3D.new()
			var s := SphereMesh.new()
			s.radius = .38
			s.height = .20
			s.radial_segments = 8
			s.rings = 3
			m.mesh = s
			m.material_override = espuma
			m.position = Vector3(-3.2+i*.8,.05,.4+sin(i*3.0)*.35)
			n.add_child(m)
	# Barreras de garganta continuas, con aperturas exclusivamente en puentes.
	for z in range(-64,65):
		if absf(z-30)<2.5 or absf(z+4)<2.5 or absf(z+34)<2.5: continue
		for lado in [-1.0,1.0]:
			var p := Vector2(rio_x(z)+lado*6.7,z)
			colision(g,Vector3(p.x,altura(p)+2.0,p.y),Vector3(.35,6,1.6))
	# Cierre de la cubeta alpina; salida sur conectada con las barreras del cauce.
	for i in 36:
		var a := i*TAU/36.0
		if cos(a)>.72: continue
		var p := Vector2(-6+sin(a)*12,-53+cos(a)*10)
		colision(g,Vector3(p.x,altura(p)+1,p.y),Vector3(2.4,5,2.4))

func puente(z: float, nombre: String) -> void:
	var x := rio_x(z)
	var y := camino_cercano(Vector2(x,z)).y
	var g := grupo(mapa.get_node("Puentes"),nombre,Vector3(x,y,z))
	g.set_meta("extremos",PackedVector3Array([Vector3(x-9,y,z),Vector3(x+9,y,z)]))
	caja(g,"Tablero",Vector3(0,-.18,0),Vector3(18,.36,4.4),madera,true)
	for i in 45:
		caja(g,"Tablon",Vector3(-8.8+i*.4,.015,0),Vector3(.37,.03,4.4),tablas)
	for lado in [-2.18,2.18]:
		for i in 7:
			caja(g,"Poste",Vector3(-9+i*3, .65,lado),Vector3(.18,1.6,.18),madera)
		caja(g,"Baranda",Vector3(0,1.15,lado),Vector3(18,.16,.16),tablas)
		colision(g,Vector3(0,.85,lado),Vector3(18,1.7,.18))
		viga(g,Vector3(-9,-.65,lado),Vector3(9,-.65,lado),.28,madera)
	for lado in [-8.4,8.4]:
		caja(g,"Estribo",Vector3(lado,-1,0),Vector3(1.1,2,5),piedra,true)

func tienda(p: Node3D, pos: Vector3) -> void:
	var g := grupo(p,"Tienda",pos)
	var v := PackedVector3Array([Vector3(-1.7,0,-1.6),Vector3(0,2,-1.6),Vector3(-1.7,0,1.6),Vector3(0,2,-1.6),Vector3(0,2,1.6),Vector3(-1.7,0,1.6),Vector3(0,2,-1.6),Vector3(1.7,0,-1.6),Vector3(1.7,0,1.6),Vector3(0,2,-1.6),Vector3(1.7,0,1.6),Vector3(0,2,1.6)])
	var mat := tela.duplicate()
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	malla(g,"Lona",v,mat)
	viga(g,Vector3(0,0,-1.6),Vector3(0,2.1,-1.6),.13,madera)
	colision(g,Vector3(0,.65,0),Vector3(3,1.3,2.8))

func puntos_interes() -> void:
	var g := grupo(mapa,"Campamento")
	for p in [Vector3(24,12,5),Vector3(24,12,16),Vector3(32,12,15)]: tienda(g,p)
	var fuego := material(Color(.95,.36,.06))
	fuego.emission_enabled = true
	fuego.emission = Color(.8,.15,.015)
	viga(g,Vector3(26.4,12.1,12.6),Vector3(27.6,12.1,13.4),.18,madera)
	viga(g,Vector3(26.4,12.1,13.4),Vector3(27.6,12.1,12.6),.18,madera)
	for i in 3:
		var llama := MeshInstance3D.new()
		var cono := CylinderMesh.new()
		cono.top_radius = .02
		cono.bottom_radius = .25
		cono.height = .65+i*.12
		cono.radial_segments = 5
		llama.mesh = cono
		llama.material_override = fuego
		llama.position = Vector3(26.75+i*.25,12.25+cono.height*.5,13)
		g.add_child(llama)
	for i in 8:
		var a := i*TAU/8
		modelo(g,NATURE+"Rock_Medium_1.gltf",Vector3(27+cos(a),12,13+sin(a)),.28,a)
	for p in [Vector3(22,12,11),Vector3(35,12,16)]:
		viga(g,p,p+Vector3(2,0,0),.38,madera,true)
	for par in [["Barrel",Vector3(22,12,8)],["Crate_Wooden",Vector3(23,12,6)],["Bag",Vector3(34,12,12)],["Lantern_Wall",Vector3(24,13.7,6)],["Pickaxe_Bronze",Vector3(33,12,13)]]:
		modelo(g,PROPS+par[0]+".gltf",par[1],.75,0)
	for i in 7: viga(g,Vector3(23,12.12+i*.09,16),Vector3(24.5,12.12+i*.09,16),.12,madera)
	g = grupo(mapa,"Mirador")
	var p := Vector3(-37,23,-18)
	for x in [-1.8,1.8]:
		for z in [-1.8,1.8]: caja(g,"Pilar",p+Vector3(x,3,z),Vector3(.35,6,.35),madera,true)
	caja(g,"PlataformaTorre",p+Vector3(0,4.8,0),Vector3(4.5,.3,4.5),tablas)
	caja(g,"Cubierta",p+Vector3(0,7,0),Vector3(5,.35,5),madera)
	for x in [-2.0,2.0]:
		viga(g,p+Vector3(x,0,-1.8),p+Vector3(x,4.8,1.8),.18,tablas)
		caja(g,"Cerramiento",p+Vector3(x,2,0),Vector3(.15,4,3.6),tablas,true)
	caja(g,"Mastil",p+Vector3(0,8,0),Vector3(.12,2,.12),madera)
	caja(g,"Estandarte",p+Vector3(.65,8.4,0),Vector3(1.2,.7,.05),material(Color(.42,.19,.12)))
	for x in [-38.0,-26.0]:
		viga(g,Vector3(x,24,-22),Vector3(x,24,-14),.17,madera,true)
	g = grupo(mapa,"RuinasAltas")
	caja(g,"Enlosado",Vector3(31,28.96,-48),Vector3(9,.08,7),piedra)
	for x in [27.5,34.5]:
		for z in [-50.0,-46.0]:
			caja(g,"Basamento",Vector3(x,29.2,z),Vector3(1.2,.4,1.2),piedra,true)
			caja(g,"Columna",Vector3(x,30.6,z),Vector3(.65,2.5 if z< -48 else 1.3,.65),piedra,true)
	for x in [29.0,33.0]: caja(g,"JambaArco",Vector3(x,30.6,-50),Vector3(.8,3.2,.9),piedra,true)
	viga(g,Vector3(29,32.3,-50),Vector3(31,33.2,-50),.7,piedra)
	viga(g,Vector3(31,33.2,-50),Vector3(33,32.3,-50),.7,piedra)
	for i in 4: caja(g,"MuroRoto",Vector3(26.5,29.3+i*.43,-48),Vector3(.8,.42,3.5-i*.65),piedra,true)
	modelo(g,NATURE+"Fern_1.gltf",Vector3(28,29,-46),.6,0)
	g = grupo(mapa,"EntradaMinas")
	var origen := Vector3(45,20,-20)
	caja(g,"FondoOscuro",origen+Vector3(0,1.8,-3.8),Vector3(4.3,3.6,.25),oscuro,true)
	for x in [-2.3,2.3]: caja(g,"Refuerzo",origen+Vector3(x,2,-3.5),Vector3(.5,4,.6),madera,true)
	caja(g,"Dintel",origen+Vector3(0,4,-3.5),Vector3(5.4,.6,.8),tablas,true)
	for x in [-.65,.65]: caja(g,"Rail",origen+Vector3(x,.05,-.6),Vector3(.08,.1,5.8),piedra)
	for i in 8: caja(g,"Traviesa",origen+Vector3(0,.03,1.8-i*.7),Vector3(1.8,.06,.16),madera)
	for x in [-2.5,2.5]: modelo(g,PROPS+"Lantern_Wall.gltf",origen+Vector3(x,2.4,-3.0),.6,0)
	modelo(g,PROPS+"Crate_Wooden.gltf",origen+Vector3(-3,0,-1),1,0,true)
	modelo(g,PROPS+"Barrel.gltf",origen+Vector3(3,0,4),1,0,true)
	modelo(g,PROPS+"Pickaxe_Bronze.gltf",origen+Vector3(3.2,0,0),1,0)
	for i in 5:
		modelo(g,NATURE+"Rock_Medium_2.gltf",origen+Vector3(-1.5+i*.7,0,-3.2),1.0, i*.7,true)
	for x in [-3.8,3.8]: modelo(g,NATURE+"Rock_Medium_3.gltf",origen+Vector3(x,-.1,-4.5),6.5,x)

func paisaje() -> void:
	var g := grupo(mapa,"Paisaje")
	for i in 390:
		var p := Vector2(rng.randf_range(-63,63),rng.randf_range(-62,62))
		var c := camino_cercano(p)
		if c.x<6.0 or absf(p.x-rio_x(p.y))<8: continue
		var reservado := false
		for zona in [Vector2(-52,48),Vector2(28,10),Vector2(-32,-18),Vector2(30,-42),Vector2(45,-20)]:
			if p.distance_to(zona)<9.5 or (absf(p.x-zona.x)<5.0 and p.y>zona.y and p.y<zona.y+24): reservado = true
		if reservado: continue
		var h := altura(p)
		if absf(altura(p+Vector2.RIGHT)-h)>1.3: continue
		if i%3==0:
			modelo(g,NATURE+"Rock_Medium_"+str(1+i%3)+".gltf",Vector3(p.x,h-.08,p.y),rng.randf_range(.6,2.7),rng.randf()*TAU,true)
		elif h<35:
			modelo(g,NATURE+"Pine_"+str(1+i%5)+".gltf",Vector3(p.x,h-.06,p.y),rng.randf_range(3.4,6.3),rng.randf()*TAU,true)
	for i in 100:
		var p := Vector2(rng.randf_range(-54,54),rng.randf_range(-52,52))
		if camino_cercano(p).x<3.3 or absf(p.x-rio_x(p.y))<7: continue
		modelo(g,NATURE+("Flower_3_Group.gltf" if i%3==0 else "Grass_Wispy_Short.gltf"),Vector3(p.x,altura(p),p.y),.3,rng.randf()*TAU)
	var cartel := grupo(mapa,"SenalEntrada",Vector3(-48,2,49.5))
	caja(cartel,"Poste",Vector3(0,1,0),Vector3(.18,2,.18),madera)
	caja(cartel,"Tabla",Vector3(0,1.7,0),Vector3(2.5,.5,.15),tablas)
	var rotulo := Label3D.new()
	rotulo.text = "MONTANAS / ALDEA"
	rotulo.font_size = 30
	rotulo.pixel_size = .004
	rotulo.position = Vector3(0,1.7,.09)
	cartel.add_child(rotulo)

func construir() -> void:
	rng.seed = 60661
	mapa.name = "Montanas"
	root.add_child(mapa)
	rutas = [PackedVector3Array([Vector3(-63,2,48),Vector3(-52,2,48),Vector3(-34,3,42),Vector3(-22,6,30),Vector3(16,6,30),Vector3(28,12,22),Vector3(28,12,10),Vector3(38,18,-4),Vector3(14,18,-4),Vector3(-23,18,-4),Vector3(-32,23,-18),Vector3(-24,28,-34),Vector3(16,28,-34),Vector3(30,29,-42)]),PackedVector3Array([Vector3(30,29,-42),Vector3(54,25,-36),Vector3(54,21,-18),Vector3(45,20,-20),Vector3(54,21,-18),Vector3(48,16,-4),Vector3(42,10,18),Vector3(28,12,22)])]
	var caminos := grupo(mapa,"Caminos")
	for i in rutas.size():
		var n := grupo(caminos,"Principal" if i==0 else "DescensoOriental")
		n.set_meta("eje",rutas[i])
		n.set_meta("ancho",6.4)
	terreno()
	grupo(mapa,"Puentes")
	puente(30,"Inferior")
	puente(-4,"Intermedio")
	puente(-34,"Elevado")
	hidrografia()
	puntos_interes()
	paisaje()
	var limites := grupo(mapa,"Limites")
	for x in [-65.0,65.0]: colision(limites,Vector3(x,25,0),Vector3(1,100,132))
	for z in [-65.0,65.0]: colision(limites,Vector3(0,25,z),Vector3(132,100,1))
	var marcadores := grupo(mapa,"Marcadores")
	for par in [["EntradaAldea",Vector3(-52,2.04,48)],["RetornoAldea",Vector3(-62,2.02,48)],["Valle",Vector3(16,6,30)],["Campamento",Vector3(28,12,10)],["Mirador",Vector3(-32,23,-18)],["Ruinas",Vector3(30,29,-42)],["Minas",Vector3(45,20,-20)],["Lago",Vector3(-6,28,-53)]]:
		var n := Marker3D.new()
		n.name = par[0]
		n.position = par[1]
		marcadores.add_child(n)
	marcadores.get_node("EntradaAldea").set_meta("direccion_visual","derecha")
	marcadores.get_node("Minas").set_meta("destino_previsto","Minas")
	marcadores.get_node("Minas").set_meta("activa",false)
	var futura := Marker3D.new()
	futura.name = "ConexionMinasFutura"
	futura.position = Vector3(45,20,-23.2)
	futura.set_meta("id_salida","montanas_minas_norte")
	futura.set_meta("destino_previsto","Minas")
	futura.set_meta("retorno_previsto","minas_montanas_sur")
	futura.set_meta("activa",false)
	marcadores.add_child(futura)
	mapa.set_meta("altura_minima",minimo)
	mapa.set_meta("altura_maxima",maximo)
	mapa.set_meta("assets_utilizados",usados)
	mapa.set_meta("semilla",60661)
	# Los ejes publicados registran la cota final tras mezclar las mesetas.
	for n in caminos.get_children():
		var eje: PackedVector3Array = n.get_meta("eje")
		for i in eje.size(): eje[i].y = altura(Vector2(eje[i].x,eje[i].z))
		n.set_meta("eje",eje)
	for n in mapa.find_children("*","",true,false):
		if n.owner==null: n.owner = mapa
	var packed := PackedScene.new()
	assert(packed.pack(mapa)==OK)
	assert(ResourceSaver.save(packed,"res://scenes/montanas.tscn")==OK)
	print("MONTANAS guardada; altura=",minimo,"..",maximo," assets=",usados)
	quit()
