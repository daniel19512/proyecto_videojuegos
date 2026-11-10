extends SceneTree
## Autoria offline determinista. Solo escribe campos_granjas.tscn y sus dos recursos.
const FARM := "res://assets/granja/Farm_Harvest/glTF/mdvl_farm_"
const VILLAGE := "res://assets/aldea/glTF/"
const PROPS := "res://assets/objetos_medievales/glTF/"
const NATURE := "res://assets/naturaleza/glTF/"
var mapa := Node3D.new()
var rng := RandomNumberGenerator.new()
var caminos: Node3D
var reservas: Array[Rect2] = []
var suelos: Array[Rect2] = []
var usados: Dictionary = {}
var cache: Dictionary = {}
var madera := material(Color(.32,.19,.09))
var tablas := material(Color(.49,.32,.16))
var clara := material(Color(.63,.46,.26))
var piedra := material(Color(.43,.43,.36))
var yeso := material(Color(.78,.69,.50))
var tierra := material(Color(.31,.22,.12))
var paja := material(Color(.63,.48,.20))
var oscuro := material(Color(.11,.14,.12))
var agua := material(Color(.22,.39,.39))

func material(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = .94
	return m

func _initialize() -> void:
	call_deferred("construir")

func grupo(padre: Node, nombre: String, posicion := Vector3.ZERO) -> Node3D:
	var n := Node3D.new()
	n.name = nombre
	n.position = posicion
	padre.add_child(n)
	return n

func caja(padre: Node3D, nombre: String, p: Vector3, tam: Vector3, mat: Material, solida := false, giro := 0.0) -> Node3D:
	var n := grupo(padre,nombre,p)
	n.rotation.y = giro
	var m := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = tam
	m.mesh = mesh
	m.material_override = mat
	n.add_child(m)
	if solida: colision(n,Vector3.ZERO,tam)
	return n

func colision(padre: Node3D, p: Vector3, tam: Vector3) -> StaticBody3D:
	var b := StaticBody3D.new()
	padre.add_child(b)
	b.position = p
	var c := CollisionShape3D.new()
	var s := BoxShape3D.new()
	s.size = tam
	c.shape = s
	b.add_child(c)
	return b

func viga(padre: Node3D, a: Vector3, b: Vector3, grueso: float, mat: Material) -> void:
	var n := caja(padre,"Viga",(a+b)/2,Vector3(grueso,a.distance_to(b),grueso),mat)
	n.quaternion = Quaternion(Vector3.UP,(b-a).normalized())

func limites_modelo(n: Node3D) -> AABB:
	var primero := true
	var bounds := AABB()
	for m in n.find_children("*","MeshInstance3D",true,false):
		var b: AABB = n.global_transform.affine_inverse()*m.global_transform*m.get_aabb()
		bounds = b if primero else bounds.merge(b)
		primero = false
	return bounds

func fuente(ruta: String) -> Dictionary:
	if not cache.has(ruta):
		assert(ResourceLoader.exists(ruta),ruta)
		var n: Node3D = load(ruta).instantiate()
		mapa.add_child(n)
		cache[ruta] = {"escena":load(ruta),"caja":limites_modelo(n)}
		n.free()
	return cache[ruta]

func modelo(padre: Node3D, ruta: String, p: Vector3, escala := 1.0, giro := 0.0, solido := false) -> Node3D:
	var datos := fuente(ruta)
	var n: Node3D = datos.escena.instantiate()
	var bounds: AABB = datos.caja
	padre.add_child(n)
	n.scale *= escala
	n.rotation.y = giro
	var ajuste := Vector3(bounds.get_center().x,bounds.position.y,bounds.get_center().z)*escala
	n.position = p-ajuste.rotated(Vector3.UP,giro)
	n.set_meta("original",ruta)
	usados[ruta] = int(usados.get(ruta,0))+1
	if ruta.ends_with("Carrot.gltf"):
		n.owner = mapa
		mapa.set_editable_instance(n,true)
		for mesh in n.find_children("*","MeshInstance3D",true,false):
			for s in mesh.mesh.get_surface_count():
				var original = mesh.get_active_material(s)
				if original is StandardMaterial3D:
					var exclusivo: StandardMaterial3D = original.duplicate()
					exclusivo.vertex_color_use_as_albedo = true
					mesh.set_surface_override_material(s,exclusivo)
	if solido:
		var b := colision(padre,p+Vector3.UP*bounds.size.y*escala*.5,bounds.size*escala*Vector3(.88,.96,.88))
		b.rotation.y = giro
	return n

func agricola(padre: Node3D, nombre: String, p: Vector3, escala := 1.0, giro := 0.0, solido := false) -> Node3D:
	return modelo(padre,FARM+nombre+".glb",p,escala,giro,solido)

func camino(nombre: String, puntos: Array, ancho := 4.0) -> void:
	var n := grupo(caminos,nombre)
	n.set_meta("eje",PackedVector2Array(puntos))
	n.set_meta("ancho",ancho)

func distancia_camino(p: Vector2) -> float:
	var d := 1000.0
	for n in caminos.get_children():
		var eje: PackedVector2Array = n.get_meta("eje")
		for i in range(eje.size()-1):
			d = minf(d,p.distance_to(Geometry2D.get_closest_point_to_segment(p,eje[i],eje[i+1]))-float(n.get_meta("ancho"))/2)
	return d

func altura(p: Vector2) -> float:
	var libre := clampf(distancia_camino(p)/4.0,0,1)
	for r in reservas:
		if r.grow(1.5).has_point(p): return 0.0
	var borde := smoothstep(32.0,47.0,absf(p.x)) + smoothstep(32.0,44.0,absf(p.y))
	return (1.2+.5*sin(p.x*.13)+.4*cos(p.y*.17))*minf(borde,1.4)*libre

func terreno() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Faldon paisajistico fuera del recinto cerrado; evita ver el corte desde la orbita.
	for z in range(-65,65):
		for x in range(-70,70):
			for offset in [Vector2(0,0),Vector2(1,0),Vector2(0,1),Vector2(1,0),Vector2(1,1),Vector2(0,1)]:
				var p: Vector2 = Vector2(x,z)+offset
				var mancha := 1.0-smoothstep(-.1,.9,distancia_camino(p))
				for r in suelos:
					if r.has_point(p): mancha = 1.0
				st.set_color(Color(mancha,0,0,1))
				st.add_vertex(Vector3(p.x,altura(p),p.y))
	st.generate_normals()
	var mesh := st.commit()
	var mat := ShaderMaterial.new()
	mat.shader = load("res://scripts/terreno_campos.gdshader")
	var segmentos := PackedVector4Array()
	var anchuras := PackedFloat32Array()
	for camino_n in caminos.get_children():
		var eje: PackedVector2Array = camino_n.get_meta("eje")
		for i in range(eje.size()-1):
			segmentos.append(Vector4(eje[i].x,eje[i].y,eje[i+1].x,eje[i+1].y))
			anchuras.append(camino_n.get_meta("ancho"))
	mat.set_shader_parameter("cantidad_segmentos",segmentos.size())
	segmentos.resize(64)
	anchuras.resize(64)
	mat.set_shader_parameter("segmentos",segmentos)
	mat.set_shader_parameter("anchuras",anchuras)
	var patios := PackedVector4Array()
	for r in suelos: patios.append(Vector4(r.position.x,r.position.y,r.end.x,r.end.y))
	# Los cultivos tienen su malla de tierra; solo los cinco primeros rectangulos son patios.
	patios.resize(5)
	for parcela in mapa.get_node("Trigo").get_children():
		if parcela is MultiMeshInstance3D:
			var r: Rect2 = parcela.get_meta("reserva")
			patios.append(Vector4(r.position.x,r.position.y,r.end.x,r.end.y))
	mat.set_shader_parameter("cantidad_patios",patios.size())
	patios.resize(12)
	mat.set_shader_parameter("patios",patios)
	mesh.surface_set_material(0,mat)
	ResourceSaver.save(mesh,"res://scenes/campos_terreno.res",ResourceSaver.FLAG_CHANGE_PATH)
	var g := grupo(mapa,"Terreno")
	var m := MeshInstance3D.new()
	m.mesh = load("res://scenes/campos_terreno.res")
	g.add_child(m)
	var b := StaticBody3D.new()
	g.add_child(b)
	var c := CollisionShape3D.new()
	c.shape = mesh.create_trimesh_shape()
	ResourceSaver.save(c.shape,"res://scenes/campos_colision.res",ResourceSaver.FLAG_CHANGE_PATH)
	c.shape = load("res://scenes/campos_colision.res")
	b.add_child(c)
	var l := grupo(mapa,"Limites")
	for x in [-50.5,50.5]: colision(l,Vector3(x,3,0),Vector3(1,8,92))
	for z in [-45.5,45.5]: colision(l,Vector3(0,3,z),Vector3(100,8,1))

func cerca(padre: Node3D, a: Vector2, b: Vector2, abierta := false) -> void:
	var distancia := a.distance_to(b)
	var n := grupo(padre,"Cerca")
	n.set_meta("desde",a)
	n.set_meta("hasta",b)
	var tramos := maxi(1,ceili(distancia/2.1))
	for i in range(tramos+1):
		var p := a.lerp(b,float(i)/tramos)
		if abierta and absf(float(i)/tramos-.5)*distancia<1.2: continue
		caja(n,"Poste",Vector3(p.x,.54,p.y),Vector3(.16,1.08,.16),madera,true)
	for i in tramos:
		var p := a.lerp(b,(float(i)+.5)/tramos)
		if abierta and absf((float(i)+.5)/tramos-.5)*distancia<1.7: continue
		var largo := distancia/tramos
		for h in [.38,.78]:
			caja(n,"Travesano",Vector3(p.x,h,p.y),Vector3(.12,.14,largo),tablas,false,atan2(b.x-a.x,b.y-a.y))
		var fisica := colision(n,Vector3(p.x,.55,p.y),Vector3(.18,1.1,largo+.08))
		fisica.rotation.y = atan2(b.x-a.x,b.y-a.y)
	if abierta:
		# Hojas abiertas junto al cerramiento, nunca sobre la luz libre central.
		var medio := (a+b)/2
		caja(n,"PortonAbierto",Vector3(medio.x-1.6,.52,medio.y+.7),Vector3(.12,.85,1.3),clara,true)

func cercado(padre: Node3D, r: Rect2) -> void:
	cerca(padre,r.position,Vector2(r.end.x,r.position.y))
	cerca(padre,r.position,Vector2(r.position.x,r.end.y))
	cerca(padre,Vector2(r.end.x,r.position.y),r.end)
	cerca(padre,Vector2(r.position.x,r.end.y),r.end,true)

func tejado(padre: Node3D, ancho: float, fondo: float, base: float, subida: float, mat: Material) -> void:
	var medio := ancho/2+.55
	var largo := sqrt(medio*medio+subida*subida)
	var angulo := atan2(subida,medio)
	for lado in [-1,1]:
		var n := caja(padre,"Faldon",Vector3(lado*medio/2,base+subida/2,0),Vector3(largo,.16,fondo+1.1),mat)
		n.rotation.z = -lado*angulo
		for j in range(ceili((fondo+1.1)/.32)):
			var z := -fondo/2-.5+j*.32
			viga(padre,Vector3(lado*medio,base+.09,z),Vector3(0,base+subida+.09,z),.065,clara if j%7==0 else mat)
	for z in [-fondo/2,fondo/2]:
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		for p in [Vector3(-ancho/2,base,z),Vector3(0,base+subida-.1,z),Vector3(ancho/2,base,z)]: st.add_vertex(p)
		st.generate_normals()
		var m := MeshInstance3D.new()
		m.mesh = st.commit()
		var frontal: StandardMaterial3D = tablas.duplicate()
		frontal.cull_mode = BaseMaterial3D.CULL_DISABLED
		m.material_override = frontal
		padre.add_child(m)
		viga(padre,Vector3(-ancho/2,base,z),Vector3(0,base+subida,z),.16,madera)
		viga(padre,Vector3(ancho/2,base,z),Vector3(0,base+subida,z),.16,madera)

func edificio(padre: Node3D, nombre: String, p: Vector2, ancho: float, fondo: float, granero := false, abierto := false) -> Node3D:
	var n := grupo(padre,nombre,Vector3(p.x,.003,p.y))
	n.set_meta("cuerpo",Vector2(ancho,fondo))
	n.set_meta("tipo","establo" if abierto else "granero" if granero else "vivienda")
	var h := (3.8 if ancho>=6 else 2.6) if granero else 3.0
	var mat := tablas if granero or abierto else yeso
	# Cierres perimetrales separados: no caja de edificio completo.
	for x in [-ancho/2,ancho/2]: caja(n,"MuroLateral",Vector3(x,h/2,0),Vector3(.22,h,fondo),mat,true)
	caja(n,"MuroTrasero",Vector3(0,h/2,-fondo/2),Vector3(ancho,h,.22),mat,true)
	if not abierto: caja(n,"MuroFrontal",Vector3(0,h/2,fondo/2),Vector3(ancho,h,.22),mat,true)
	for x in [-ancho/2,0.0,ancho/2]:
		for z in [-fondo/2-.06,fondo/2+.06]: caja(n,"Entramado",Vector3(x,h/2,z),Vector3(.18,h,.16),madera,abierto)
	for z in [-fondo/2-.08,fondo/2+.08]:
		for y in [.35,h-.15]:
			if abierto and z>0 and y<1: continue
			caja(n,"VigaHorizontal",Vector3(0,y,z),Vector3(ancho+.2,.20,.18),madera)
	if abierto: caja(n,"TierraInterior",Vector3(0,.01,0),Vector3(ancho,.018,fondo),tierra)
	for x in [-ancho/2-.08,ancho/2+.08]:
		caja(n,"ZocaloPiedra",Vector3(x,.20,0),Vector3(.28,.4,fondo),piedra)
	if granero or abierto:
		for lado in [-1,1]:
			for j in range(ceili(fondo/.40)):
				caja(n,"JuntaTablones",Vector3(lado*(ancho/2+.13),h/2,-fondo/2+.2+j*.4),Vector3(.06,h-.35,.035),madera)
			for z in [-fondo*.3,fondo*.3]:
				caja(n,"RespiraderoLateral",Vector3(lado*(ancho/2+.17),h-.6,z),Vector3(.065,.40,.55),oscuro)
		for z in [-fondo/2-.13,fondo/2+.13]:
			for x in range(ceili(ancho/.38)):
				if abierto and z>0: continue
				caja(n,"Tablon",Vector3(-ancho/2+.2+x*.38,h/2,z),Vector3(.35,h-.4,.08),clara if x%5==0 else tablas)
		tejado(n,ancho,fondo,h,(2.1 if ancho>=6 else 1.2) if granero else 1.5,paja if granero else madera)
	else:
		# Familia 4x4/4x6: XZ=1, Y=.60 compartida por tejado/frontones originales.
		var cubierta := grupo(n,"Cubierta",Vector3(0,3,0))
		cubierta.scale.y = .6
		for par in [["Roof_RoundTiles_4x"+str(int(fondo)),Vector3.ZERO,0.0],["Roof_Front_Brick4",Vector3(0,0,fondo/2),0.0],["Roof_Front_Brick4",Vector3(0,0,-fondo/2),PI]]:
			var pieza: Node3D = load(VILLAGE+par[0]+".gltf").instantiate()
			cubierta.add_child(pieza)
			pieza.position = par[1]
			pieza.rotation.y = par[2]
			pieza.set_meta("original",VILLAGE+par[0]+".gltf")
			usados[VILLAGE+par[0]+".gltf"] = int(usados.get(VILLAGE+par[0]+".gltf",0))+1
	if not abierto:
		var puerta_ancho := 3.0 if granero else 1.05
		caja(n,"PuertaCerrada",Vector3(0,1.18,fondo/2+.18),Vector3(puerta_ancho,2.36,.10),madera)
		for lado in [-1,1]:
			viga(n,Vector3(lado*puerta_ancho/2,.2,fondo/2+.25),Vector3(0,2.2,fondo/2+.25),.09,clara)
		for j in range(ceili(puerta_ancho/.26)):
			caja(n,"TablonPuerta",Vector3(-puerta_ancho/2+.12+j*.26,1.16,fondo/2+.24),Vector3(.23,2.20,.035),madera if j%2 else tablas)
		for y in [.55,1.8]: caja(n,"Herraje",Vector3(0,y,fondo/2+.29),Vector3(puerta_ancho*.9,.07,.045),oscuro)
		for x in [-ancho*.32,ancho*.32]:
			caja(n,"Ventana",Vector3(x,2.15,fondo/2+.17),Vector3(.55,.7,.08),oscuro)
			for lado in [-1,1]: caja(n,"Postigo",Vector3(x+lado*.36,2.15,fondo/2+.19),Vector3(.18,.75,.12),tablas)
		if not granero:
			caja(n,"Chimenea",Vector3(-1,4.0,-fondo*.25),Vector3(.55,2,.55),piedra)
			caja(n,"Porche",Vector3(0,.08,fondo/2+.8),Vector3(2.6,.16,1.6),piedra)
			caja(n,"AleroPorche",Vector3(0,2.55,fondo/2+.7),Vector3(2.8,.15,1.7),tablas)
			for x in [-1.2,1.2]: caja(n,"PilarPorche",Vector3(x,1.28,fondo/2+1.4),Vector3(.12,2.56,.12),madera,true)
			for lado in [-1,1]:
				caja(n,"VentanaLateral",Vector3(lado*(ancho/2+.14),1.8,0),Vector3(.08,.75,.85),oscuro)
				for z in [-.52,.52]: caja(n,"PostigoLateral",Vector3(lado*(ancho/2+.19),1.8,z),Vector3(.11,.82,.18),tablas)
				for y in [1.35,2.25]: caja(n,"MarcoLateral",Vector3(lado*(ancho/2+.20),y,0),Vector3(.13,.10,1.15),madera)
			caja(n,"VentanaTrasera",Vector3(0,1.9,-fondo/2-.16),Vector3(.8,.8,.08),oscuro)
	return n

func leniera(padre: Node3D, p: Vector3) -> void:
	var n := grupo(padre,"Leniera",p)
	for fila in 3:
		for j in 5-fila:
			var m := MeshInstance3D.new()
			var cilindro := CylinderMesh.new()
			cilindro.height = 1.25
			cilindro.top_radius = .12
			cilindro.bottom_radius = .14
			cilindro.radial_segments = 7
			m.mesh = cilindro
			m.material_override = madera if j%2 else clara
			m.rotation_degrees.x = 90
			m.position = Vector3((j-(4-fila)*.5)*.27,.14+fila*.24,0)
			n.add_child(m)
	colision(n,Vector3(0,.35,0),Vector3(1.4,.7,1.25))
	caja(n,"Cubierta",Vector3(0,1.25,0),Vector3(1.9,.15,1.6),tablas)
	for x in [-.85,.85]: caja(n,"Pilar",Vector3(x,.6,0),Vector3(.12,1.2,.12),madera)

func huerto(padre: Node3D, nombre: String, r: Rect2, zanahorias := false) -> void:
	var n := grupo(padre,nombre)
	n.set_meta("reserva",r)
	suelos.append(r)
	reservas.append(r.grow(.4))
	cercado(n,r.grow(.7))
	for fila in range(int(r.size.y)):
		for columna in range(int(r.size.x)):
			# Los surcos se encajan por esquina fuente, sin normalizarlos.
			var p := r.position+Vector2(columna,fila)
			var surco: Node3D = load(FARM+"furrow_01.glb").instantiate()
			n.add_child(surco)
			surco.position = Vector3(p.x,0,p.y)
			usados[FARM+"furrow_01.glb"] = int(usados.get(FARM+"furrow_01.glb",0))+1
			for k in 2:
				var centro := p+Vector2(.26+.46*k,.48)
				if zanahorias:
					modelo(n,PROPS+"Carrot.gltf",Vector3(centro.x,.035,centro.y),.75,rng.randf()*TAU)
				else:
					var etapa := "03" if fila%3==0 else "02" if fila%3==1 else "01"
					agricola(n,"cabbage_stage_"+etapa,Vector3(centro.x,.06,centro.y),1.25,rng.randf()*TAU)
	agricola(n,"fruit_basket_01",Vector3(r.end.x+.1,0,r.end.y+1.3))

func trigo() -> void:
	var n := grupo(mapa,"Trigo")
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Espiga volumetrica de granos alternos, dos hojas y tallo: no lineas amarillas.
	for par in [[Vector3(0,.45,0),Vector3(.025,.9,.025)],[Vector3(-.08,.42,0),Vector3(.17,.035,.035)],[Vector3(.08,.59,0),Vector3(.17,.035,.035)]]:
		var b := BoxMesh.new()
		b.size = par[1]
		st.append_from(b,0,Transform3D(Basis.IDENTITY,par[0]))
	for fila in 5:
		for lado in [-1,1]:
			var grano := PrismMesh.new()
			grano.size = Vector3(.085,.14,.055)
			st.append_from(grano,0,Transform3D(Basis(Vector3.FORWARD,lado*.4),Vector3(lado*.035,.80+fila*.095,0)))
	var mesh := st.commit()
	var dorado := material(Color(.72,.55,.20))
	dorado.vertex_color_use_as_albedo = true
	mesh.surface_set_material(0,dorado)
	for r in [Rect2(-31,-8,7,7),Rect2(-21,-8,7,7),Rect2(-31,3,7,7),Rect2(-21,3,7,7)]:
		suelos.append(r.grow(.5))
		reservas.append(r.grow(.4))
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.use_colors = true
		mm.mesh = mesh
		mm.instance_count = 22*16
		var i := 0
		for fila in 16:
			for col in 22:
				var p: Vector2 = r.position+Vector2(.15+col*.31+rng.randf_range(-.04,.04),.2+fila*.43+rng.randf_range(-.07,.07))
				var escala := rng.randf_range(.78,1.13)
				mm.set_instance_transform(i,Transform3D(Basis(Vector3.UP,rng.randf()*TAU).scaled(Vector3.ONE*escala),Vector3(p.x,.025,p.y)))
				mm.set_instance_color(i,Color(1,rng.randf_range(.88,1),rng.randf_range(.80,1)))
				i += 1
		var m := MultiMeshInstance3D.new()
		m.name = "ParcelaTrigo"
		m.multimesh = mm
		m.set_meta("reserva",r)
		n.add_child(m)
	agricola(n,"scarecrow_01",Vector3(-33,0,0))
	agricola(n,"haystack_02",Vector3(-13,0,11))

func multimodelos(padre: Node3D, ruta: String, puntos: Array[Vector3], escala: float) -> void:
	if puntos.is_empty(): return
	var datos := fuente(ruta)
	var fuente_n: Node3D = datos.escena.instantiate()
	mapa.add_child(fuente_n)
	for m in fuente_n.find_children("*","MeshInstance3D",true,false):
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.mesh = m.mesh
		mm.instance_count = puntos.size()
		for i in puntos.size():
			mm.set_instance_transform(i,Transform3D(Basis(Vector3.UP,rng.randf()*TAU).scaled(Vector3.ONE*escala),puntos[i])*fuente_n.global_transform.affine_inverse()*m.global_transform)
		var n := MultiMeshInstance3D.new()
		n.multimesh = mm
		n.set_meta("original",ruta)
		padre.add_child(n)
	usados[ruta] = int(usados.get(ruta,0))+puntos.size()
	fuente_n.free()

func paisaje() -> void:
	var n := grupo(mapa,"Paisaje")
	for i in 64:
		var lado := i%4
		var p := Vector2(rng.randf_range(-47,47),rng.randf_range(39,43)*(1 if lado==0 else -1)) if lado<2 else Vector2(rng.randf_range(44,48)*(1 if lado==2 else -1),rng.randf_range(-40,40))
		if distancia_camino(p)<3.2: continue
		var bloqueado := false
		for r in reservas:
			if r.grow(4).has_point(p): bloqueado = true
		if bloqueado: continue
		var escala := rng.randf_range(.65,.95)
		var tree := modelo(n,NATURE+("CommonTree_1.gltf" if i%2==0 else "CommonTree_5.gltf"),Vector3(p.x,altura(p),p.y),escala,rng.randf()*TAU)
		var tronco := StaticBody3D.new()
		n.add_child(tronco)
		tronco.position = Vector3(p.x,altura(p)+1.6,p.y)
		var c := CollisionShape3D.new()
		var shape := CylinderShape3D.new()
		shape.radius = .38*escala
		shape.height = 3.2
		c.shape = shape
		tronco.add_child(c)
		tree.set_meta("tronco",true)
	# Isla de frutales y colmenas, junto a la entrada en lugar de bosque denso.
	for p in [Vector2(24,-31),Vector2(31,-29),Vector2(37,-32),Vector2(26,-38),Vector2(34,-38)]:
		agricola(n,"apple_tree_01",Vector3(p.x,altura(p),p.y),1,rng.randf()*TAU)
		colision(n,Vector3(p.x,altura(p)+1,p.y),Vector3(.45,2,.45))
	for p in [Vector2(23,-34),Vector2(30,-35)]: agricola(n,"beehive_01",Vector3(p.x,altura(p),p.y))
	var especies := ["Grass_Common_Short","Grass_Wispy_Short","Flower_3_Group","Flower_4_Group","Bush_Common_Flowers"]
	for especie in especies:
		var puntos: Array[Vector3] = []
		for i in 380:
			var p := Vector2(rng.randf_range(-48,48),rng.randf_range(-43,43))
			if distancia_camino(p)<.75: continue
			var bloqueado := false
			for r in reservas:
				if r.grow(.6).has_point(p): bloqueado = true
			if bloqueado: continue
			puntos.append(Vector3(p.x,altura(p),p.y))
		multimodelos(n,NATURE+especie+".gltf",puntos,.42 if especie.contains("Bush") else .34 if especie.contains("Flower") else .65)
	for i in 28:
		var p := Vector2(-45 if i%2==0 else 46,rng.randf_range(-39,40))
		if distancia_camino(p)<3: continue
		modelo(n,NATURE+"Rock_Medium_1.gltf",Vector3(p.x,altura(p),p.y),rng.randf_range(.32,.60),rng.randf()*TAU,true)
	for i in 28:
		var lado := i%4
		var p := Vector2(rng.randf_range(-63,63),rng.randf_range(54,60)*(1 if lado==0 else -1)) if lado<2 else Vector2(rng.randf_range(57,65)*(1 if lado==2 else -1),rng.randf_range(-53,53))
		modelo(n,NATURE+"CommonTree_1.gltf",Vector3(p.x,altura(p),p.y),rng.randf_range(.9,1.3),rng.randf()*TAU)

func construir() -> void:
	if DisplayServer.get_name()=="headless":
		push_error("La autoria requiere render real para guardar buffers MultiMesh, como vegetacion_bosque. No usar --headless.")
		quit(1)
		return
	rng.seed = 60615
	mapa.name = "CamposYGranjas"
	root.add_child(mapa)
	caminos = grupo(mapa,"Caminos")
	camino("Entrada",[Vector2(0,-44),Vector2(0,-35),Vector2(2,-29),Vector2(0,-15)],4.5)
	camino("Central",[Vector2(0,-15),Vector2(0,-5),Vector2(3,6),Vector2(0,15),Vector2(0,27),Vector2(-3,35)],4.5)
	camino("LazoOeste",[Vector2(0,-15),Vector2(-12,-14),Vector2(-24,-14),Vector2(-36,-9),Vector2(-36,8),Vector2(-25,13),Vector2(0,15)],3.6)
	camino("LazoEste",[Vector2(0,-15),Vector2(15,-14),Vector2(30,-12),Vector2(41,-5),Vector2(43,13),Vector2(43,25),Vector2(38,28),Vector2(23,28),Vector2(0,27)],4)
	camino("GranjaOeste",[Vector2(-25,13),Vector2(-17,19),Vector2(-17,29),Vector2(-12,34),Vector2(-3,35)],3.2)
	camino("CasaOeste",[Vector2(-17,29),Vector2(-25,29),Vector2(-35,30)],2.5)
	camino("GranjaSur",[Vector2(23,28),Vector2(28,30),Vector2(29,36),Vector2(28,41),Vector2(14,40)],3)
	camino("Establos",[Vector2(3,6),Vector2(16,7),Vector2(31,8),Vector2(42,8)],3.2)
	camino("Huertos",[Vector2(16,7),Vector2(16,-7)],2.6)
	camino("CruceTrigo",[Vector2(-36,1),Vector2(-22,1),Vector2(0,1)],2.2)
	camino("CorralOeste",[Vector2(24,28),Vector2(24,21)],2.5)
	camino("CorralEste",[Vector2(35,28),Vector2(35,21)],2.5)
	camino("CasaPrincipal",[Vector2(0,-15),Vector2(10,-17),Vector2(10,-20)],2.5)
	camino("Granero",[Vector2(-12,-14),Vector2(-12,-16)],3)
	# Reservas propias: excluyen vegetacion y aplanan solo apoyos, no limites logicos de aldea.
	reservas = [Rect2(-18,-30,12,14),Rect2(6,-30,10,13),Rect2(26,-4,10,12),Rect2(-30,19,10,10),Rect2(9,28,11,11),Rect2(20,31,7,6),Rect2(19,12,21,13)]
	suelos = [Rect2(-18,-18,35,8),Rect2(20,12,19,12),Rect2(26,5,11,5),Rect2(-30,26,13,5),Rect2(9,36,11,4)]
	var entrada := grupo(mapa,"Entrada")
	for lado in [-1,1]:
		cerca(entrada,Vector2(lado*3.4,-42),Vector2(lado*3.8,-33))
		for z in [-39,-35]:
			modelo(entrada,NATURE+"Flower_3_Group.gltf",Vector3(lado*4.8,altura(Vector2(lado*4.8,z)),z),.65)
	var cartel := grupo(entrada,"Cartel",Vector3(4.2,0,-37))
	caja(cartel,"Poste",Vector3(0,.9,0),Vector3(.18,1.8,.18),madera,true)
	caja(cartel,"Tabla",Vector3(.5,1.6,0),Vector3(2,.6,.15),tablas)
	var label := Label3D.new()
	label.text = "CAMPOS Y GRANJAS"
	label.font_size = 32
	label.pixel_size = .0038
	label.position = Vector3(.5,1.61,.09)
	cartel.add_child(label)
	var principal := grupo(mapa,"GranjaPrincipal")
	edificio(principal,"Granero",Vector2(-12,-24),8,10,true)
	edificio(principal,"CasaGranjero",Vector2(10,-25),4,6)
	leniera(principal,Vector3(6,0,-26))
	modelo(principal,PROPS+"Bench.gltf",Vector3(13.4,0,-20),.8,0,true)
	modelo(principal,PROPS+"Bucket_Wooden_1.gltf",Vector3(12.6,0,-20))
	modelo(principal,PROPS+"Pot_1.gltf",Vector3(8.2,0,-20),.7)
	modelo(principal,NATURE+"Flower_3_Group.gltf",Vector3(8.2,.35,-20),.22)
	modelo(principal,PROPS+"Workbench.gltf",Vector3(-17,0,-18),.95,0,true)
	modelo(principal,VILLAGE+"Prop_Wagon.gltf",Vector3(-8,0,-10),.75,PI/2,true)
	for par in [["Barrel",Vector3(-17,0,-21)],["Bag",Vector3(-17.5,0,-23)],["Crate_Wooden",Vector3(-7,0,-19)],["FarmCrate_Carrot",Vector3(-6,0,-18)],["FarmCrate_Apple",Vector3(14,0,-19)],["Rope_1",Vector3(-6,0,-21)],["Axe_Bronze",Vector3(-17,1,-17.8)]]:
		modelo(principal,PROPS+par[0]+".gltf",par[1],.85,0,par[0] in ["Barrel","Crate_Wooden"])
	for p in [Vector3(-18,0,-26),Vector3(-17,0,-25),Vector3(-18,0,-25),Vector3(-17,.52,-25)]: agricola(principal,"hay_bale_01",p)
	agricola(principal,"haystack_02",Vector3(-7,0,-27),1.15,0,true)
	agricola(principal,"well_cover_01",Vector3(6,0,-10),1,0,true)
	var cultivos := grupo(mapa,"Huertos")
	huerto(cultivos,"PlantelEntrada",Rect2(-9,-36,4,5))
	huerto(cultivos,"Coles",Rect2(8,-8,5,9))
	huerto(cultivos,"Zanahorias",Rect2(19,-8,5,9),true)
	huerto(cultivos,"DomesticoPrincipal",Rect2(18,-25,4,4))
	trigo()
	var corrales := grupo(mapa,"Corrales")
	edificio(corrales,"Establo",Vector2(31,1),6,8,false,true)
	cercado(corrales,Rect2(20,13,8,10))
	cercado(corrales,Rect2(31,13,8,10))
	for p in [Vector3(21,0,14),Vector3(32,0,14),Vector3(29,0,3)]: agricola(corrales,"feed_trough_01",p,1,PI/2,true)
	for p in [Vector3(26,0,15),Vector3(36,0,15),Vector3(28,0,-1)]: agricola(corrales,"hay_bale_01",p,1.4)
	agricola(corrales,"haystack_02",Vector3(36,0,-1),1,0,true)
	agricola(corrales,"chicken_coop_01",Vector3(16,0,12),1.3,PI/2,true)
	var bebedero := grupo(corrales,"Bebedero",Vector3(37,0,19))
	for z in [-.5,.5]: caja(bebedero,"Borde",Vector3(0,.3,z),Vector3(1.8,.6,.15),piedra,true)
	for x in [-.9,.9]: caja(bebedero,"Borde",Vector3(x,.3,0),Vector3(.15,.6,1),piedra,true)
	caja(bebedero,"AguaEstatica",Vector3(0,.42,0),Vector3(1.65,.05,.85),agua)
	for x in [22.0,37.0]:
		var pasto := MeshInstance3D.new()
		var parche := CylinderMesh.new()
		parche.top_radius = 1.5
		parche.bottom_radius = 1.5
		parche.height = .018
		parche.radial_segments = 11
		pasto.mesh = parche
		pasto.material_override = material(Color(.30,.38,.16))
		pasto.position = Vector3(x,.012,17.5)
		corrales.add_child(pasto)
		for i in 5: modelo(corrales,NATURE+"Grass_Common_Short.gltf",Vector3(x+rng.randf_range(-1.2,1.2),.025,17.5+rng.randf_range(-1,1)),.45)
	for p in [Vector3(21,0,21),Vector3(32,0,20)]: modelo(corrales,PROPS+"Bucket_Wooden_1.gltf",p)
	modelo(corrales,PROPS+"Bucket_Wooden_1.gltf",Vector3(33,0,5))
	agricola(corrales,"milking_stool_01",Vector3(28,0,5))
	var secundarias := grupo(mapa,"GranjasSecundarias")
	edificio(secundarias,"CasaHortelana",Vector2(-25,24),4,4)
	leniera(secundarias,Vector3(-29,0,23))
	edificio(secundarias,"CobertizoHortelana",Vector2(-33,16),3,3,false,true)
	huerto(cultivos,"HuertoHortelana",Rect2(-38,21,5,6))
	agricola(secundarias,"apple_tree_01",Vector3(-32,0,33),1,0)
	colision(secundarias,Vector3(-32,1,33),Vector3(.5,2,.5))
	modelo(secundarias,PROPS+"Barrel.gltf",Vector3(-28,0,27),.8,0,true)
	modelo(secundarias,PROPS+"Pot_1.gltf",Vector3(-23.1,0,26.8),.7)
	modelo(secundarias,NATURE+"Flower_4_Group.gltf",Vector3(-23.1,.35,26.8),.22)
	edificio(secundarias,"CasaCosechero",Vector2(14,33),4,6)
	edificio(secundarias,"AlmacenCosechero",Vector2(23,34),3,4,true)
	leniera(secundarias,Vector3(18.2,0,32))
	huerto(cultivos,"HuertoCosechero",Rect2(5,32,4,5),true)
	modelo(secundarias,VILLAGE+"Prop_Wagon.gltf",Vector3(20,0,37.5),.65,PI/2,true)
	for par in [["FarmCrate_Empty",Vector3(19,0,37)],["Bag",Vector3(20,0,37)],["FarmCrate_Apple",Vector3(-29,0,20)]]: modelo(secundarias,PROPS+par[0]+".gltf",par[1],.9)
	# Pequeños conjuntos de borde: almacen, descansos y labores, nunca en ejes.
	for p in [Vector3(-38,0,-4),Vector3(-28,0,12),Vector3(8,0,13),Vector3(43,0,26)]:
		agricola(principal,"hay_bale_01",p)
		modelo(principal,PROPS+"FarmCrate_Empty.gltf",p+Vector3(1,0,.5),.85)
	paisaje()
	terreno()
	var marcas := grupo(mapa,"Marcadores")
	for par in [["EntradaAldea",Vector3(0,.05,-39)],["RetornoAldea",Vector3(0,0,-43)],["Entrada",Vector3(0,0,-34)],["Patio",Vector3(0,0,-15)],["Granero",Vector3(-12,0,-16)],["CasaPrincipal",Vector3(10,0,-20)],["Trigo",Vector3(-22,0,1)],["Huertos",Vector3(16,0,-2)],["Establos",Vector3(31,0,8)],["Corrales",Vector3(24,0,21)],["GranjaOeste",Vector3(-25,0,29)],["GranjaSur",Vector3(14,0,39)],["Paisaje",Vector3(-36,0,8)]]:
		var m := Marker3D.new()
		m.name = par[0]
		m.position = par[1]
		marcas.add_child(m)
	marcas.get_node("EntradaAldea").set_meta("direccion_visual","abajo")
	marcas.get_node("RetornoAldea").set_meta("id_salida","campos_aldea_norte")
	mapa.set_meta("semilla",60615)
	mapa.set_meta("dimensiones",Vector2(100,90))
	mapa.set_meta("assets_utilizados",usados)
	for n in mapa.find_children("*","",true,false):
		if n.owner==null: n.owner = mapa
	var packed := PackedScene.new()
	assert(packed.pack(mapa)==OK)
	assert(ResourceSaver.save(packed,"res://scenes/campos_granjas.tscn")==OK)
	print("CAMPOS: escena serializada; semilla60615, caminos=",caminos.get_child_count()," assets=",usados)
	quit()
