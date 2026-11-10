extends SceneTree
## AutorÃ­a offline determinista. Solo escribe minas.tscn; nunca se ejecuta al jugar.
const PROPS := "res://assets/objetos_medievales/glTF/"
const RUTAS := [
	[Vector2(0,7),Vector2(0,-10),Vector2(-6,-22),Vector2(0,-32),Vector2(8,-40),Vector2(7,-49),Vector2(-6,-60),Vector2(-5,-70),Vector2(0,-80),Vector2(0,-87)],
	[Vector2(0,-35),Vector2(-12,-37),Vector2(-23,-38)],
	[Vector2(-6,-60),Vector2(-19,-64),Vector2(-26,-72)],
]
const SALAS := [Vector4(0,0,6,10),Vector4(8,-40,13,11),Vector4(-23,-38,7,7),Vector4(-26,-72,5,6),Vector4(8,-82,21,15)]
var mapa := Node3D.new()
var rng := RandomNumberGenerator.new()
var celdas: Dictionary = {}
var roca: ShaderMaterial
var boveda: ShaderMaterial
var suelo := material(Color(.27,.25,.22))
var madera := material(Color(.27,.16,.085))
var metal := material(Color(.21,.24,.26))
var tablas := material(Color(.43,.29,.16))
var cache: Dictionary = {}

func _initialize() -> void:
	call_deferred("construir")

func material(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = .9
	return m

func grupo(p: Node, nombre: String, pos := Vector3.ZERO) -> Node3D:
	var n := Node3D.new()
	n.name = nombre
	n.position = pos
	p.add_child(n)
	return n

func caja(p: Node3D, nombre: String, pos: Vector3, tam: Vector3, mat: Material, solido := false) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.name = nombre
	n.position = pos
	var mesh := BoxMesh.new()
	mesh.size = tam
	n.mesh = mesh
	n.material_override = mat
	p.add_child(n)
	if solido:
		var cuerpo := StaticBody3D.new()
		var forma := CollisionShape3D.new()
		var s := BoxShape3D.new()
		s.size = tam
		forma.shape = s
		n.add_child(cuerpo)
		cuerpo.add_child(forma)
	return n

func viga(p: Node3D, a: Vector3, b: Vector3, ancho: float, mat: Material, solido := false) -> void:
	var n := caja(p,"Viga",(a+b)*.5,Vector3(ancho,a.distance_to(b),ancho),mat,solido)
	n.quaternion = Quaternion(Vector3.UP,(b-a).normalized())

func altura(z: float) -> float:
	if z > -20: return 0.0
	if z > -34: return (z+20.0)*4.0/14.0
	if z > -48: return -4.0
	if z > -74: return -4.0+(z+48.0)*8.0/26.0
	return -12.0

func punto(p: Vector2) -> Vector3:
	return Vector3(p.x,altura(p.y),p.y)

func estanque(p: Vector2) -> float:
	return Vector2((p.x-16)/6.0,(p.y+84)/5.0).length()

func cota(p: Vector2) -> float:
	return altura(p.y)-2.5*(1.0-smoothstep(.65,1.15,estanque(p)))

func dentro(p: Vector2) -> bool:
	for s in SALAS:
		if Vector2((p.x-s.x)/s.z,(p.y-s.y)/s.w).length()<1.0: return true
	for ruta in RUTAS:
		for i in range(ruta.size()-1):
			var a: Vector2 = ruta[i]
			var d: Vector2 = ruta[i+1]-a
			var t := clampf((p-a).dot(d)/d.length_squared(),0,1)
			if p.distance_to(a+d*t)<(3.8 if ruta==RUTAS[0] else 2.8): return true
	return false

func superficie(p: Node3D, nombre: String, vertices: PackedVector3Array, mat: Material, solida: bool) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for v in vertices: st.add_vertex(v)
	st.generate_normals()
	var n := MeshInstance3D.new()
	n.name = nombre
	n.mesh = st.commit()
	n.material_override = mat
	p.add_child(n)
	if solida:
		n.create_trimesh_collision()
		var shape: ConcavePolygonShape3D = n.get_child(0).get_child(0).shape
		shape.backface_collision = true

func terreno() -> void:
	var g := grupo(mapa,"TerrenoYTuneles")
	var piso := PackedVector3Array()
	var paredes := PackedVector3Array()
	var techo := PackedVector3Array()
	for x in range(-35,33):
		for z in range(-99,13):
			if dentro(Vector2(x+.5,z+.5)): celdas[Vector2i(x,z)] = true
	for celda in celdas:
		var a := Vector2(celda.x,celda.y)
		var puntos := [a,a+Vector2(1,0),a+Vector2(1,1),a+Vector2(0,1)]
		var vs: Array[Vector3] = []
		var ts: Array[Vector3] = []
		for p in puntos:
			vs.append(Vector3(p.x,cota(p),p.y))
			var alto := 11.0 if p.y < -72 and p.x > -14 else 6.0
			ts.append(Vector3(p.x,altura(p.y)+alto,p.y))
		for i in [0,1,2,0,2,3]: piso.append(vs[i])
		for i in [0,2,1,0,3,2]: techo.append(ts[i])
		var vecinos := [Vector2i(0,-1),Vector2i(1,0),Vector2i(0,1),Vector2i(-1,0)]
		for i in 4:
			if celdas.has(celda+vecinos[i]): continue
			var j := (i+1)%4
			for v in [vs[i]-Vector3.UP*.2,vs[j]-Vector3.UP*.2,ts[j],vs[i]-Vector3.UP*.2,ts[j],ts[i]]: paredes.append(v)
	var acabado := ShaderMaterial.new()
	acabado.shader = load("res://scripts/suelo_minas.gdshader")
	superficie(g,"SueloExcavado",piso,acabado,true)
	superficie(g,"Paredes",paredes,roca,true)
	superficie(g,"Bovedas",techo,boveda,false)
	var r := grupo(mapa,"RocasDeBorde")
	var mesh := SphereMesh.new()
	mesh.radial_segments = 5
	mesh.rings = 3
	mesh.radius = 1
	mesh.height = 2
	for celda in celdas:
		if (celda.x+celda.y)%4 != 0: continue
		var borde := false
		for d in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
			if not celdas.has(celda+d): borde = true
		if not borde: continue
		var n := MeshInstance3D.new()
		n.mesh = mesh
		n.material_override = roca
		n.position = punto(Vector2(celda.x+.5,celda.y+.5))+Vector3.UP*2.8
		n.scale = Vector3(rng.randf_range(.8,1.4),3.2,rng.randf_range(.8,1.4))
		n.rotation.y = rng.randf()*TAU
		r.add_child(n)

func modelo(p: Node3D, nombre: String, pos: Vector3, alto: float, solido := false, fuente := PROPS) -> void:
	var ruta := fuente+nombre+".gltf"
	var n: Node3D = load(ruta).instantiate()
	p.add_child(n)
	var bounds := AABB()
	var primero := true
	for m in n.find_children("*","MeshInstance3D",true,false):
		var b: AABB = n.global_transform.affine_inverse()*m.global_transform*m.get_aabb()
		bounds = b if primero else bounds.merge(b)
		primero = false
	var escala := alto/bounds.size.y
	n.scale = Vector3.ONE*escala
	n.position = pos-Vector3(bounds.get_center().x,bounds.position.y,bounds.get_center().z)*escala
	if solido:
		var ancho := Vector3(bounds.size.x*escala,alto,bounds.size.z*escala)
		# ColisiÃ³n individual ajustada al modelo, sin bloquear la reserva completa.
		var fisica := caja(p,"Volumen_"+nombre,pos+Vector3.UP*alto*.5,ancho,metal,true)
		fisica.visible = false

func soporte(p: Node3D, centro: Vector3, ancho: float, deteriorado := false) -> void:
	for x in [-ancho*.5,ancho*.5]:
		caja(p,"Poste",centro+Vector3(x,2,0),Vector3(.32,4,.36),madera,true)
	var n := caja(p,"Dintel",centro+Vector3(0,4.1,0),Vector3(ancho+.7,.35,.45),tablas)
	if deteriorado: n.rotation.z = .07
	for x in [-1,1]: viga(p,centro+Vector3(x*ancho*.5,3,0),centro+Vector3(x*(ancho*.5-1),4,0),.21,madera)

func luz(p: Node3D, pos: Vector3, fria := false) -> void:
	var n := OmniLight3D.new()
	n.position = pos
	n.light_color = Color(.25,.55,.58) if fria else Color(1,.63,.30)
	n.light_energy = 1.0 if fria else 2.2
	n.omni_range = 14 if fria else 12
	n.shadow_enabled = false
	p.add_child(n)
	if not fria: modelo(p,"Lantern_Wall",pos-Vector3.UP*.25,.55)

func rail(p: Node3D, a: Vector3, b: Vector3) -> void:
	var lateral := Vector3(b.z-a.z,0,a.x-b.x).normalized()
	for signo in [-1,1]: viga(p,a+lateral*.65*signo+Vector3.UP*.07,b+lateral*.65*signo+Vector3.UP*.07,.08,metal)
	for i in range(int(a.distance_to(b)/.9)+1):
		var pos := a.lerp(b,float(i)/maxf(1,int(a.distance_to(b)/.9)))
		viga(p,pos-lateral*.95+Vector3.UP*.025,pos+lateral*.95+Vector3.UP*.025,.10,madera)

func vagoneta(p: Node3D, pos: Vector3) -> void:
	var g := grupo(p,"Vagoneta",pos)
	caja(g,"Cajon",Vector3(0,.8,0),Vector3(1.2,.85,1.7),metal,true)
	for x in [-.67,.67]:
		for z in [-.55,.55]:
			var n := MeshInstance3D.new()
			var m := CylinderMesh.new()
			m.top_radius = .23
			m.bottom_radius = .23
			m.height = .12
			m.radial_segments = 8
			n.mesh = m
			n.material_override = metal
			n.position = Vector3(x,.26,z)
			n.rotation.z = PI*.5
			g.add_child(n)
	caja(g,"InteriorOscuro",Vector3(0,1.232,0),Vector3(1.0,.02,1.48),madera)
	for y in [.5,.9]: caja(g,"Banda",Vector3(0,y,.86),Vector3(1.22,.08,.04),tablas)
	for i in 5: cristal(g,Vector3(rng.randf_range(-.4,.4),1.2,rng.randf_range(-.6,.6)),.35,material(Color(.37,.38,.36)))

func cristal(p: Node3D, pos: Vector3, tam: float, mat: Material) -> void:
	var n := MeshInstance3D.new()
	var m := CylinderMesh.new()
	m.top_radius = 0
	m.bottom_radius = tam*.3
	m.height = tam
	m.radial_segments = 5
	n.mesh = m
	n.material_override = mat
	n.position = pos
	n.rotation = Vector3(.2,rng.randf()*TAU,.3)
	p.add_child(n)

func macizo(p: Node3D, nombre: String, pos: Vector3, tam: Vector3, mat: Material) -> void:
	var n := MeshInstance3D.new()
	n.name = nombre
	var m := SphereMesh.new()
	m.radius = 1
	m.height = 2
	m.radial_segments = 7
	m.rings = 4
	n.mesh = m
	n.material_override = mat
	n.position = pos
	n.scale = tam*.5
	p.add_child(n)
	n.create_convex_collision()


