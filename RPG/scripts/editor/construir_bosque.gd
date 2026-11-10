extends SceneTree
## Autoria opcional: regenera SOLO bosque.tscn y sus dos recursos geometricos.
## No se ejecuta al jugar. Datos editables del plano quedan serializados en la escena.
const ZONAS := [
	["Z01", "Entrada", Vector2(0, 41), Vector2(6, 5), 0.35],
	["Z02", "ClaroCentral", Vector2(0, 0), Vector2(10, 9), 0.8],
	["Z03", "Campamento", Vector2(-25, -25), Vector2(9, 7), 1.4],
	["Z04", "Ruinas", Vector2(24, -26), Vector2(8, 7), 1.8],
	["Z05", "Mirador", Vector2(29, 20), Vector2(6, 5), 3.8],
	["Z06", "RiberaLaguna", Vector2(-18, 21), Vector2(4, 5), 0.45]]
var RUTAS := [
	["P01", 3.6, PackedVector2Array([Vector2(0,49),Vector2(0,41),Vector2(-3,31),Vector2(2,18),Vector2(-2,9),Vector2(0,0)])],
	["P02", 3.6, PackedVector2Array([Vector2(0,0),Vector2(-10,-5),Vector2(-16,-15),Vector2(-25,-25)])],
	["P03", 3.6, PackedVector2Array([Vector2(0,0),Vector2(10,-7),Vector2(15,-18),Vector2(24,-26),Vector2(22,-37),Vector2(20,-49)])],
	["P04", 3.6, PackedVector2Array([Vector2(0,0),Vector2(11,5),Vector2(18,14),Vector2(29,20)])],
	["P05", 3.6, PackedVector2Array([Vector2(0,0),Vector2(-9,8),Vector2(-13,16),Vector2(-18,21)])],
	["S01", 2.6, PackedVector2Array([Vector2(-25,-25),Vector2(-32,-17),Vector2(-33,-6),Vector2(-25,4),Vector2(-19,12),Vector2(-18,21)])],
	["S02", 2.6, PackedVector2Array([Vector2(24,-26),Vector2(33,-17),Vector2(36,-4),Vector2(34,8),Vector2(29,20)])]]

func _initialize() -> void:
	call_deferred("construir")

func nodo(nombre: String, padre: Node) -> Node3D:
	var n := Node3D.new()
	n.name = nombre
	padre.add_child(n)
	return n

func altura(p: Vector2) -> float:
	var y := 0.8 + 0.45*sin(p.x/14.0)*cos(p.y/17.0)
	y += 3.0*exp(-p.distance_squared_to(Vector2(30,20))/260.0)
	y += 1.5*exp(-p.distance_squared_to(Vector2(21,-30))/340.0)
	y -= 0.7*exp(-p.distance_squared_to(Vector2(-29,22))/140.0)
	for zona in ZONAS:
		var d: float = ((p-zona[2])/zona[3]).length()
		y = lerpf(y, zona[4], 1.0-smoothstep(0.65,1.6,d))
	# Cordon bajo perimetral; los dos accesos conservan pendientes suaves.
	var borde := maxf(absf(p.x),absf(p.y))
	var acceso := maxf(exp(-pow((p.x)/5.0,2))*smoothstep(35,46,p.y),exp(-pow((p.x-20)/5.0,2))*smoothstep(35,46,-p.y))
	return y + 2.8*smoothstep(40,50,borde)*(1.0-acceso)

func curva(puntos: PackedVector2Array) -> PackedVector2Array:
	var c := Curve3D.new()
	c.bake_interval = 0.7
	for i in puntos.size():
		var p := Vector3(puntos[i].x,0,puntos[i].y)
		var anterior: Vector2 = puntos[maxi(0,i-1)]
		var siguiente: Vector2 = puntos[mini(puntos.size()-1,i+1)]
		var tangente := Vector3(siguiente.x-anterior.x,0,siguiente.y-anterior.y)*0.14
		c.add_point(p,-tangente if i>0 else Vector3.ZERO,tangente if i<puntos.size()-1 else Vector3.ZERO)
	var salida := PackedVector2Array()
	for p in c.get_baked_points():
		salida.append(Vector2(p.x,p.z))
	return salida

func distancia(p: Vector2, puntos: PackedVector2Array) -> float:
	var d := INF
	for i in range(1,puntos.size()):
		d = minf(d,p.distance_to(Geometry2D.get_closest_point_to_segment(p,puntos[i-1],puntos[i])))
	return d

func caja(padre: Node, nombre: String, centro: Vector3, tamano: Vector3, giro: float = 0.0) -> void:
	var col := CollisionShape3D.new()
	col.name = nombre
	col.position = centro
	col.rotation.y = giro
	var forma := BoxShape3D.new()
	forma.size = tamano
	col.shape = forma
	padre.add_child(col)

func construir() -> void:
	var bosque := Node3D.new()
	bosque.name = "Bosque"
	bosque.set_meta("fase","6A.1")
	bosque.set_meta("limites",Rect2(-50,-50,100,100))
	var terreno := nodo("Terreno",bosque)
	var relieve := nodo("Relieve",bosque)
	relieve.set_meta("descripcion","Colinas suaves incorporadas a la unica malla fisica del terreno")
	var caminos := nodo("Caminos",bosque)
	var rutas: Array[PackedVector2Array] = []
	for ruta in RUTAS:
		var n := nodo(ruta[0],caminos)
		var puntos := curva(ruta[2])
		rutas.append(puntos)
		n.set_meta("id_camino",ruta[0])
		n.set_meta("ancho",ruta[1])
		n.set_meta("eje",puntos)
	var reservas := nodo("Reservas",bosque)
	for zona in ZONAS:
		var n := nodo(zona[0],reservas)
		n.position = Vector3(zona[2].x,altura(zona[2]),zona[2].y)
		n.set_meta("id_zona",zona[0])
		n.set_meta("descripcion",zona[1])
		n.set_meta("semiejes",zona[3])
		n.set_meta("excluir_vegetacion",true)
		var m := Marker3D.new()
		m.name = "PuntoInteres"
		n.add_child(m)
	for dato in [["Z02","ArbolCentralFuturo",Vector2(0,-5)],["Z02","DescansoFuturo",Vector2(4,7)],["Z01","SenalFutura",Vector2(3,44)]]:
		var m := Marker3D.new()
		m.name = dato[1]
		var zona: Node3D = reservas.get_node(dato[0])
		m.position = Vector3(dato[2].x,altura(dato[2]),dato[2].y)-zona.position
		zona.add_child(m)
	var laguna := nodo("Laguna",reservas)
	laguna.position = Vector3(-29,altura(Vector2(-29,22)),22)
	laguna.set_meta("semiejes",Vector2(8,6))
	laguna.set_meta("estado","Reserva seca cerrada; agua y orilla definitivas pendientes")
	var arroyo := nodo("Arroyo",reservas)
	var eje_agua := curva(PackedVector2Array([Vector2(-41,-50),Vector2(-40,-30),Vector2(-42,-10),Vector2(-39,10),Vector2(-34,19)]))
	arroyo.set_meta("eje",eje_agua)
	arroyo.set_meta("ancho",2.4)
	arroyo.set_meta("excluir_vegetacion",true)
	for punto in [Vector2(-40,-30),Vector2(-39,9)]:
		var m := Marker3D.new()
		m.name = "PuentePrevisto"+str(arroyo.get_child_count()+1)
		m.position = Vector3(punto.x,altura(punto),punto.y)
		m.set_meta("estado","Opcional, fuera de red peatonal actual; no construido")
		arroyo.add_child(m)
	var limites := nodo("LimitesNaturales",bosque)
	limites.set_meta("reserva_arbolado_denso","Banda perimetral |X| o |Z| >= 42; excluir accesos de 6 unidades")
	var cierre := StaticBody3D.new()
	cierre.name = "CierresProvisionales"
	limites.add_child(cierre)
	for x in [-49.5,49.5]:
		caja(cierre,"BordeX"+str(x),Vector3(x,3,0),Vector3(1,12,100))
	for z in [-49.5,49.5]:
		caja(cierre,"BordeZ"+str(z),Vector3(0,3,z),Vector3(100,12,1))
	var bloqueo := StaticBody3D.new()
	bloqueo.name = "ReservaLagunaCerrada"
	reservas.add_child(bloqueo)
	for i in 40:
		var a := Vector2(-29,22)+Vector2(cos(TAU*i/40.0)*8,sin(TAU*i/40.0)*6)
		var b := Vector2(-29,22)+Vector2(cos(TAU*(i+1)/40.0)*8,sin(TAU*(i+1)/40.0)*6)
		var centro := (a+b)*0.5
		caja(bloqueo,"Orilla%02d"%i,Vector3(centro.x,altura(centro)+0.6,centro.y),Vector3(a.distance_to(b)+0.12,3,0.25),-atan2(b.y-a.y,b.x-a.x))
	var marcadores := nodo("Marcadores",bosque)
	for datos in [["RetornoAldea","bosque_aldea_sur","Aldea","aldea_bosque_norte",Vector2(0,41),Vector2(0,48),Vector3.BACK,"P01"],["SalidaRuinas","bosque_ruinas_norte","Ruinas","ruinas_bosque_sur",Vector2(22,-37),Vector2(20,-48),Vector3.FORWARD,"P03"]]:
		var n := nodo(datos[0],marcadores)
		for par in [["id_salida",datos[1]],["destino_previsto",datos[2]],["retorno_previsto",datos[3]],["orientacion",datos[6]],["camino_conexion","Caminos/"+datos[7]],["limite_provisional","LimitesNaturales/CierresProvisionales"]]:
			n.set_meta(par[0],par[1])
		for par in [["Aproximacion",datos[4]],["TransicionFutura",datos[5]],["LimiteProvisional",Vector2(datos[5].x,49 if datos[5].y>0 else -49)],["AparicionSegura",datos[4]]]:
			var m := Marker3D.new()
			m.name = par[0]
			m.position = Vector3(par[1].x,altura(par[1])+0.05,par[1].y)
			n.add_child(m)
	# Una malla continua: colores de vertice codifican caminos y reservas secas.
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var vertices: Array[Vector3] = []
	var colores: Array[Color] = []
	for z in range(-50,51):
		for x in range(-50,51):
			var p := Vector2(x,z)
			vertices.append(Vector3(x,altura(p),z))
			var peso := 0.0
			for i in rutas.size():
				peso = maxf(peso,1.0-smoothstep(RUTAS[i][1]*0.5-0.35,RUTAS[i][1]*0.5+0.55,distancia(p,rutas[i])))
			for zona in ZONAS:
				peso = maxf(peso,(1.0-smoothstep(0.65,1.0,((p-zona[2])/zona[3]).length()))*0.78)
			var agua := 1.0-smoothstep(0.92,1.06,((p-Vector2(-29,22))/Vector2(8,6)).length())
			agua = maxf(agua,(1.0-smoothstep(0.9,1.5,distancia(p,eje_agua)))*0.7)
			colores.append(Color(peso,0,agua,1))
	for z in 100:
		for x in 100:
			var a := z*101+x
			for indice in [a,a+1,a+101,a+1,a+102,a+101]:
				st.set_color(colores[indice])
				st.add_vertex(vertices[indice])
	st.generate_normals()
	st.index()
	var mesh := st.commit()
	var material := ShaderMaterial.new()
	material.shader = load("res://scripts/terreno_bosque.gdshader")
	mesh.surface_set_material(0,material)
	assert(ResourceSaver.save(mesh,"res://scenes/bosque_terreno.res")==OK)
	var malla := MeshInstance3D.new()
	malla.name = "Superficie"
	malla.mesh = load("res://scenes/bosque_terreno.res")
	terreno.add_child(malla)
	var cuerpo := StaticBody3D.new()
	cuerpo.name = "Suelo"
	terreno.add_child(cuerpo)
	var forma := mesh.create_trimesh_shape()
	assert(ResourceSaver.save(forma,"res://scenes/bosque_colision.res")==OK)
	var col := CollisionShape3D.new()
	col.name = "SuperficieFisica"
	col.shape = load("res://scenes/bosque_colision.res")
	cuerpo.add_child(col)
	var luz := DirectionalLight3D.new()
	luz.name = "Iluminacion"
	luz.rotation_degrees = Vector3(-52,-28,0)
	luz.light_color = Color(1,0.91,0.77)
	luz.light_energy = 1.15
	luz.shadow_enabled = true
	bosque.add_child(luz)
	var entorno := WorldEnvironment.new()
	entorno.name = "Entorno"
	entorno.environment = Environment.new()
	entorno.environment.background_mode = Environment.BG_COLOR
	entorno.environment.background_color = Color(0.16,0.21,0.22)
	entorno.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	entorno.environment.ambient_light_color = Color(0.75,0.83,0.9)
	entorno.environment.ambient_light_energy = 0.65
	bosque.add_child(entorno)
	# Camara de inspeccion para F6; el laboratorio reutiliza jugador/orbita sin cambios.
	var camara := Camera3D.new()
	camara.name = "VistaGeneral"
	camara.projection = Camera3D.PROJECTION_ORTHOGONAL
	camara.size = 116
	camara.far = 250
	camara.position = Vector3(0,100,66)
	camara.rotation_degrees.x = -56.6
	bosque.add_child(camara)
	for n in bosque.find_children("*","",true,false):
		n.owner = bosque
	if ResourceLoader.exists("res://scenes/vegetacion_bosque.tscn"):
		var vegetacion: Node = load("res://scenes/vegetacion_bosque.tscn").instantiate()
		bosque.add_child(vegetacion)
		vegetacion.owner = bosque
	if ResourceLoader.exists("res://scenes/laguna_bosque.tscn"):
		var laguna: Node = load("res://scenes/laguna_bosque.tscn").instantiate()
		bosque.add_child(laguna)
		laguna.owner = bosque
	var escena := PackedScene.new()
	assert(escena.pack(bosque)==OK)
	assert(ResourceSaver.save(escena,"res://scenes/bosque.tscn")==OK)
	print("BOSQUE_GUARDADO: 20000 triangulos, 6 zonas, 7 rutas; sin generacion en juego")
	bosque.free()
	quit()
