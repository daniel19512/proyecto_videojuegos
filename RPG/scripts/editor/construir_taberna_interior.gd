extends SceneTree
## Autoría offline: guarda solo el interior E01. No se ejecuta durante el juego.
const CAFE := "res://assets/interiores_medievales/Taberna/medv-cafe/fbx/"
var raiz: Node3D
var arquitectura: Node3D
var mobiliario: Node3D
var paredes: Node3D
var madera: StandardMaterial3D
var piedra: StandardMaterial3D
var oscura: StandardMaterial3D
var usados: Array[String] = []

func _initialize() -> void:
	construir.call_deferred()

func agregar(n: Node, padre: Node, nombre: String) -> void:
	n.name = nombre
	padre.add_child(n, true)
	n.owner = raiz

## Punto de un minijuego de oficio (`id`: cerveza, pan o forja). Las
## propiedades se asignan antes de entrar al árbol porque _ready las usa.
func punto_minijuego(id: String, pos: Vector3, texto: String) -> void:
	var punto := (load("res://scenes/minijuegos/punto_minijuego.tscn") as PackedScene).instantiate() as Node3D
	punto.set("escena_minijuego", load("res://scenes/minijuegos/minijuego_%s.tscn" % id))
	punto.set("texto_aviso", texto)
	punto.position = pos
	agregar(punto, raiz, "PuntoMinijuego")

func material(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.92
	return m

func caja(padre: Node, nombre: String, pos: Vector3, medidas: Vector3, mat: Material, solida := false) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = medidas
	mesh.material = mat
	var visual := MeshInstance3D.new()
	visual.mesh = mesh
	agregar(visual, padre, nombre)
	visual.position = pos
	if solida:
		colision(nombre, pos, medidas)
	return visual

func colision(nombre: String, pos: Vector3, medidas: Vector3) -> void:
	var cuerpo := StaticBody3D.new()
	agregar(cuerpo, raiz.get_node("Colisiones"), nombre)
	cuerpo.position = pos
	var forma := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = medidas
	forma.shape = shape
	agregar(forma, cuerpo, "Forma")

func limites(n: Node, t := Transform3D.IDENTITY) -> AABB:
	var transformacion := t
	if n is Node3D:
		transformacion = t * n.transform
	var resultado := AABB()
	if n is MeshInstance3D:
		resultado = transformacion * n.get_aabb()
	for hijo in n.get_children():
		var b := limites(hijo, transformacion)
		if b.size.length() > 0:
			resultado = b if resultado.size.length() == 0 else resultado.merge(b)
	return resultado

func modelo(nombre: String, pos: Vector3, giro := 0.0, solido := false, padre: Node = null) -> Node3D:
	var ruta := CAFE + nombre + ".fbx"
	var recurso := load(ruta) as PackedScene
	assert(recurso != null, ruta)
	var soporte := Node3D.new()
	agregar(soporte, padre if padre != null else mobiliario, nombre)
	soporte.position = pos
	soporte.rotation.y = deg_to_rad(giro)
	var instancia := recurso.instantiate() as Node3D
	soporte.add_child(instancia)
	instancia.owner = raiz
	var b := limites(instancia)
	instancia.position -= Vector3(b.get_center().x, b.position.y, b.get_center().z)
	soporte.set_meta("asset", ruta)
	if not usados.has(ruta):
		usados.append(ruta)
	if solido:
		var medidas := b.size
		if absf(sin(deg_to_rad(giro))) > 0.99:
			medidas = Vector3(b.size.z, b.size.y, b.size.x)
		colision(str(soporte.name), pos + Vector3.UP * medidas.y / 2, medidas)
	return soporte

func luz(padre: Node, pos: Vector3, energia: float, alcance: float) -> void:
	var l := OmniLight3D.new()
	agregar(l, padre, "LuzVela")
	l.position = pos
	l.light_color = Color(1, 0.67, 0.32)
	l.light_energy = energia
	l.omni_range = alcance
	l.shadow_enabled = false

func mesa(nombre: String, pos: Vector3, giro: float) -> void:
	modelo(nombre, pos, giro, true)
	for signo in [-1.0, 1.0]:
		modelo("chair01", pos + Vector3(signo * 0.95, 0, 0), -90 * signo, true)
	modelo("table-candle", pos + Vector3(0, 0.815, 0))
	luz(mobiliario, pos + Vector3(0, 1.03, 0), 0.35, 2.2)
	modelo("mug01", pos + Vector3(-0.25, 0.815, 0.2))
	modelo("mug02", pos + Vector3(0.26, 0.815, -0.23))
	modelo("platter-meal01", pos + Vector3(-0.25, 0.815, -0.25))
	modelo("bowl-of-stew", pos + Vector3(0.27, 0.815, 0.23))

# La sala se separa para serializar el ambiente base, antes de que el ciclo lo aplique.
func completar_luz_interior(luz_ventana: OmniLight3D = null) -> void:
	root.remove_child(raiz)
	var ciclo := Node.new()
	ciclo.set_script(load("res://scripts/ciclo_dia_noche.gd"))
	ciclo.set("ambiente", raiz.get_node("Ambiente"))
	ciclo.set("luz_de_acceso", luz_ventana)
	agregar(ciclo, raiz, "CicloDiaNoche")

func construir() -> void:
	raiz = Node3D.new()
	raiz.name = "TabernaE01"
	root.add_child(raiz)
	for nombre in ["Arquitectura", "Mobiliario", "Colisiones", "ParedesVisibles"]:
		agregar(Node3D.new(), raiz, nombre)
	arquitectura = raiz.get_node("Arquitectura")
	mobiliario = raiz.get_node("Mobiliario")
	paredes = raiz.get_node("ParedesVisibles")
	paredes.set_script(load("res://scripts/interiores/visibilidad_interior.gd"))
	madera = material(Color(0.37, 0.22, 0.105))
	oscura = material(Color(0.16, 0.085, 0.04))
	piedra = material(Color(0.36, 0.34, 0.29))
	caja(arquitectura, "Base", Vector3(0,-0.16,0), Vector3(8.4,0.3,10.4), oscura, true)
	for i in 26:
		var mat := material(Color(0.34 + (i % 4) * 0.022, 0.20 + (i % 3) * 0.012, 0.095))
		caja(arquitectura, "Tabla%02d" % i, Vector3(-3.85 + i * 0.308, -0.025, 0), Vector3(0.30,0.05,10), mat)
	# Muros de altura completa con corte visual independiente de sus colisiones.
	for datos in [["Norte",Vector3(0,1.4,-5),Vector3(8.4,2.8,0.25),Vector3.FORWARD], ["Sur",Vector3(0,1.4,5),Vector3(8.4,2.8,0.25),Vector3.BACK], ["Este",Vector3(4,1.4,0),Vector3(0.25,2.8,10),Vector3.RIGHT], ["Oeste",Vector3(-4,1.4,0),Vector3(0.25,2.8,10),Vector3.LEFT]]:
		var grupo := Node3D.new()
		agregar(grupo, paredes, datos[0])
		grupo.set_meta("normal", datos[3])
		caja(grupo,"Muro",datos[1],datos[2],madera,true)
		var zocalo: Vector3 = datos[2]
		zocalo.y = 0.55
		caja(grupo,"ZocaloPiedra",Vector3(datos[1].x,0.275,datos[1].z),zocalo+Vector3(0.02,0,0.02),piedra)
		caja(grupo,"VigaAlta",Vector3(datos[1].x,2.65,datos[1].z),Vector3(zocalo.x,0.22,zocalo.z),oscura)
	# Postes y marcos adheridos a las paredes; ningún techo sobre la cámara.
	for x in [-3.82,3.82]:
		for z in [-4.8,0.0,4.8]:
			var grupo := paredes.get_node("Oeste" if x < 0 else "Este")
			caja(grupo,"Poste",Vector3(x,1.4,z),Vector3(0.18,2.8,0.18),oscura,true)
	var sur := paredes.get_node("Sur")
	caja(sur,"Puerta",Vector3(0,1.05,4.84),Vector3(1.15,2.1,0.12),oscura)
	for x in [-0.7,0.7]:
		caja(sur,"Jamba",Vector3(x,1.15,4.75),Vector3(0.18,2.3,0.25),piedra)
	caja(sur,"Dintel",Vector3(0,2.3,4.75),Vector3(1.58,0.25,0.25),piedra)
	# Ventanales de vidrio oscuro, travesaños y alféizares de piedra.
	var vidrio := material(Color(0.18,0.29,0.32))
	for x in [-3.84,3.84]:
		var grupo := paredes.get_node("Oeste" if x < 0 else "Este")
		for z in [-2.9,2.7]:
			caja(grupo,"Ventana",Vector3(x,1.8,z),Vector3(0.08,1.05,1.2),vidrio)
			caja(grupo,"Alfeizar",Vector3(x,1.22,z),Vector3(0.3,0.12,1.4),piedra)
			caja(grupo,"Parteluz",Vector3(x*0.993,1.8,z),Vector3(0.12,1.16,0.08),oscura)
			caja(grupo,"Travesano",Vector3(x*0.993,1.8,z),Vector3(0.12,0.08,1.3),oscura)
	mesa("table03",Vector3(-2.2,0,-0.1),90)
	mesa("table01",Vector3(-2.1,0,2.65),0)
	mesa("table01",Vector3(2.05,0,2.65),0)
	# Barra de tres módulos, pasillo de servicio por el oeste.
	for datos in [["counter_L",-0.85],["counter_M",0.70],["counter_R",2.25]]:
		modelo(datos[0],Vector3(datos[1],0,-2.5),0,true)
	for x in [0.7,2.2]:
		modelo("stool",Vector3(x,0,-1.25),0,true)
	modelo("shelf01",Vector3(1.85,0,-4.5),0,true)
	modelo("shelf02",Vector3(0.35,0,-4.5),0,true)
	for x in [-3.25,-2.3]:
		modelo("keg02",Vector3(x,0,-4.2),0,true)
	modelo("keg01",Vector3(-3.25,0,-3.1),90,true)
	modelo("jug01",Vector3(0.25,1.15,-2.5))
	modelo("pitcher",Vector3(1.05,1.15,-2.5))
	modelo("basket-of-pastries",Vector3(-0.8,1.15,-2.5))
	modelo("platter-meal02",Vector3(2.1,1.15,-2.5))
	for x in [0.25,0.55,1.6,1.95,2.25]:
		modelo("mug02",Vector3(x,0.98,-4.4))
	modelo("pitcher",Vector3(1.6,1.42,-4.4))
	modelo("jug01",Vector3(2.1,1.42,-4.4))
	modelo("jug01",Vector3(0.35,0.49,-4.4))
	# Umbral y felpudo permanecen visibles cuando se recorta la pared sur.
	caja(arquitectura,"UmbralSalida",Vector3(0,0.025,4.72),Vector3(1.6,0.05,0.45),piedra)
	var alfombra := material(Color(0.29,0.12,0.08))
	caja(arquitectura,"FelpudoSalida",Vector3(0,0.008,4.05),Vector3(1.3,0.016,0.75),alfombra)
	var cartel := Label3D.new()
	agregar(cartel,arquitectura,"RotuloSalida")
	cartel.text = "SALIDA"
	cartel.font_size = 34
	cartel.pixel_size = 0.006
	cartel.position = Vector3(0,0.03,4.1)
	cartel.rotation_degrees.x = -90
	for datos in [["tapestry01",-2.25],["tapestry02",3.1]]:
		modelo(datos[0],Vector3(datos[1],0.9,-4.82),0,false,paredes.get_node("Norte"))
	for x in [-1.2,2.8]:
		modelo("wall-candle",Vector3(x,1.7,-4.75),0,false,paredes.get_node("Norte"))
		luz(arquitectura,Vector3(x,2,-4.4),0.8,4)
	# Ambiente propio, sin sol exterior ni sombras dinámicas múltiples.
	var entorno := WorldEnvironment.new()
	entorno.environment = Environment.new()
	entorno.environment.background_mode = Environment.BG_COLOR
	entorno.environment.background_color = Color(0.055,0.038,0.025)
	entorno.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	entorno.environment.ambient_light_color = Color(1,0.9,0.78)
	entorno.environment.ambient_light_energy = 0.7
	agregar(entorno,raiz,"Ambiente")
	luz(arquitectura,Vector3(0,3,0),1.2,9)
	var jugador := load("res://scenes/jugador.tscn").instantiate() as CharacterBody3D
	agregar(jugador,raiz,"Jugador")
	jugador.position = Vector3(0,0.05,3.65)
	var camara := Camera3D.new()
	camara.set_script(load("res://scripts/camara_orbital.gd"))
	agregar(camara,raiz,"CamaraPrincipal")
	camara.projection = Camera3D.PROJECTION_ORTHOGONAL
	camara.size = 12
	camara.current = true
	camara.set("objetivo",jugador)
	camara.set("desplazamiento",Vector3(0,17,17))
	var region := Node.new()
	region.set_script(load("res://scripts/region_config.gd"))
	agregar(region,raiz,"Region")
	region.set("id_region",&"TabernaE01")
	var entradas: Dictionary[String,NodePath] = {"taberna_e01_entrada":^"Entrada"}
	region.set("entradas",entradas)
	var entrada := Marker3D.new()
	agregar(entrada,region,"Entrada")
	entrada.position = jugador.position
	entrada.set_meta("direccion_visual","arriba")
	var puerta := load("res://scenes/interiores/puerta_interior.tscn").instantiate() as Area3D
	agregar(puerta,raiz,"Salida")
	puerta.position = Vector3(0,0,4.05)
	puerta.set("escena_destino","res://scenes/mundo.tscn")
	puerta.set("entrada_destino","aldea_taberna_e01")
	puerta.set("texto","[F] Salir de la taberna")
	punto_minijuego("cerveza",Vector3(-1.3,0,-3.6),"[F] Elaborar cerveza")
	raiz.set_meta("assets_utilizados",usados)
	completar_luz_interior()
	var escena := PackedScene.new()
	assert(escena.pack(raiz) == OK)
	assert(ResourceSaver.save(escena,"res://scenes/interiores/taberna_e01.tscn") == OK)
	print("Interior E01 guardado: ",usados.size()," modelos distintos")
	quit()
