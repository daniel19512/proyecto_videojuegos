extends "res://scripts/editor/construir_taberna_interior.gd"
## Autoría offline E02–E11. Reutiliza solo primitivas/AABB de autoría de E01.
## No llama al constructor de taberna ni modifica su escena.
const MOB := "res://assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_"
const FOOD := "res://assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_"
const TOOLS := "res://assets/interiores_medievales/Herramientas/Props_Tools_Fencing/glTF/mdvl_props_"
const SMITH := "res://assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/"
const PROPS := "res://assets/objetos_medievales/glTF/"
const CONFIG := "res://scripts/interiores/edificios_interiores.json"
var ancho: float
var fondo: float
var pared_mat: Material
var tela: Material
var id_edificio: String
var manifest: Array = []

func mob(n: String) -> String: return MOB+n+"_01.glb"
func comida(n: String) -> String: return FOOD+n+"_01.glb"
func herramienta(n: String) -> String: return TOOLS+n+"_01.glb"

func pieza(ruta: String, pos: Vector3, giro := 0.0, solida := false, escala := 1.0, padre: Node = null) -> Node3D:
	assert(ResourceLoader.exists(ruta),ruta)
	var instancia := (load(ruta) as PackedScene).instantiate() as Node3D
	var contenedor := Node3D.new()
	agregar(contenedor,padre if padre != null else mobiliario,ruta.get_file().get_basename())
	contenedor.position = pos
	contenedor.rotation.y = deg_to_rad(giro)
	contenedor.add_child(instancia)
	instancia.owner = raiz
	instancia.scale *= escala
	var b := limites(instancia)
	instancia.position -= Vector3(b.get_center().x,b.position.y,b.get_center().z)
	contenedor.set_meta("asset",ruta)
	contenedor.set_meta("tamano",b.size)
	if not usados.has(ruta): usados.append(ruta)
	if solida:
		var caja_local := AABB(-Vector3(b.size.x,0,b.size.z)/2,b.size)
		var caja_mundo := Transform3D(Basis(Vector3.UP,deg_to_rad(giro)),pos)*caja_local
		colision(str(contenedor.name),caja_mundo.get_center(),caja_mundo.size)
	return contenedor

func cilindro(nombre: String, pos: Vector3, radio: float, altura: float, mat: Material, padre: Node = null) -> MeshInstance3D:
	var m := CylinderMesh.new()
	m.top_radius = radio
	m.bottom_radius = radio
	m.height = altura
	m.radial_segments = 12
	m.material = mat
	var n := MeshInstance3D.new()
	n.mesh = m
	agregar(n,padre if padre != null else mobiliario,nombre)
	n.position = pos
	return n

func rotulo(texto: String, pos: Vector3, padre: Node) -> void:
	var n := Label3D.new()
	agregar(n,padre,"Rotulo")
	n.text = texto
	n.position = pos
	n.font_size = 28
	n.pixel_size = 0.005
	n.rotation_degrees.x = -90

func base_sala(datos: Dictionary) -> void:
	id_edificio = datos.id
	ancho = datos.ancho
	fondo = datos.fondo
	raiz = Node3D.new()
	raiz.name = "Interior"+id_edificio
	root.add_child(raiz)
	usados = []
	for n in ["Arquitectura","Mobiliario","Colisiones","ParedesVisibles"]: agregar(Node3D.new(),raiz,n)
	arquitectura = raiz.get_node("Arquitectura")
	mobiliario = raiz.get_node("Mobiliario")
	paredes = raiz.get_node("ParedesVisibles")
	paredes.set_script(load("res://scripts/interiores/visibilidad_interior.gd"))
	madera = material(Color(0.35,0.22,0.12))
	oscura = material(Color(0.16,0.105,0.065))
	piedra = material(Color(0.40,0.39,0.35))
	pared_mat = material(Color.html(datos.color))
	pared_mat.albedo_texture = load("res://assets/aldea/glTF/T_Plaster_BaseColor.png")
	pared_mat.uv1_triplanar = true
	pared_mat.uv1_scale = Vector3(0.6,0.6,0.6)
	tela = material(Color.html(datos.textil))
	caja(arquitectura,"Cimiento",Vector3(0,-0.15,0),Vector3(ancho+0.2,0.3,fondo+0.2),oscura,true)
	var suelo_piedra: bool = id_edificio in ["E02","E03","E05"]
	if suelo_piedra:
		for x in int(ancho):
			for z in int(fondo):
				var mat := material(Color(0.36,0.35,0.31).lightened(float((x*7+z*3)%4)*0.025))
				caja(arquitectura,"Baldosa",Vector3(-ancho/2+x+0.5,0.005,-fondo/2+z+0.5),Vector3(0.98,0.025,0.98),mat)
	else:
		for i in int(ancho/0.25):
			var mat := material(Color(0.34,0.22,0.125).lightened(float(i%4)*0.025))
			caja(arquitectura,"Tabla",Vector3(-ancho/2+0.125+i*0.25,0,-0.0),Vector3(0.24,0.025,fondo),mat)
	for d in [["Norte",Vector3(0,1.4,-fondo/2),Vector3(ancho+0.2,2.8,0.2),Vector3.FORWARD],["Sur",Vector3(0,1.4,fondo/2),Vector3(ancho+0.2,2.8,0.2),Vector3.BACK],["Oeste",Vector3(-ancho/2,1.4,0),Vector3(0.2,2.8,fondo),Vector3.LEFT],["Este",Vector3(ancho/2,1.4,0),Vector3(0.2,2.8,fondo),Vector3.RIGHT]]:
		var grupo := Node3D.new()
		agregar(grupo,paredes,d[0])
		grupo.set_meta("normal",d[3])
		caja(grupo,"Muro",d[1],d[2],pared_mat,true)
		var tam: Vector3 = d[2]
		tam.y = 0.45
		caja(grupo,"Zocalo",Vector3(d[1].x,0.225,d[1].z),tam+Vector3(0.02,0,0.02),piedra)
		tam.y = 0.18
		caja(grupo,"Solera",Vector3(d[1].x,2.65,d[1].z),tam+Vector3(0.04,0,0.04),oscura)
	for x in [-ancho/2+0.12,ancho/2-0.12]:
		var g := paredes.get_node("Oeste" if x<0 else "Este")
		for z in [-fondo/2+0.12,0.0,fondo/2-0.12]:
			caja(g,"Poste",Vector3(x,1.4,z),Vector3(0.16,2.8,0.16),oscura)
		for z in [-fondo*0.27,fondo*0.27]:
			var vidrio := material(Color(0.30,0.43,0.44))
			caja(g,"Ventana",Vector3(x,1.9,z),Vector3(0.12,0.95,0.9),vidrio)
			caja(g,"Alfeizar",Vector3(x,1.38,z),Vector3(0.34,0.12,1.12),piedra)
			caja(g,"Parteluz",Vector3(x*0.985,1.9,z),Vector3(0.17,1.03,0.07),oscura)
	var sur := paredes.get_node("Sur")
	caja(sur,"HojaPuerta",Vector3(0,1.05,fondo/2-0.13),Vector3(1.15,2.1,0.12),madera)
	for x in [-0.66,0.66]: caja(sur,"Jamba",Vector3(x,1.15,fondo/2-0.15),Vector3(0.15,2.3,0.18),oscura)
	caja(sur,"Dintel",Vector3(0,2.3,fondo/2-0.15),Vector3(1.45,0.16,0.18),oscura)
	caja(arquitectura,"Umbral",Vector3(0,0.04,fondo/2-0.3),Vector3(1.5,0.08,0.45),piedra)
	caja(arquitectura,"Felpudo",Vector3(0,0.025,fondo/2-0.95),Vector3(1.3,0.03,0.7),tela)
	rotulo("SALIDA",Vector3(0,0.05,fondo/2-0.95),arquitectura)
	var entorno := WorldEnvironment.new()
	entorno.environment = Environment.new()
	entorno.environment.background_mode = Environment.BG_COLOR
	entorno.environment.background_color = Color(0.065,0.055,0.04)
	entorno.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	entorno.environment.ambient_light_color = Color(1,0.93,0.83)
	entorno.environment.ambient_light_energy = 0.75 if id_edificio != "E03" else 0.6
	agregar(entorno,raiz,"Ambiente")
	luz(arquitectura,Vector3(0,3,0),0.8,10)
	var vela := pieza(mob("lantern"),Vector3(ancho/2-0.28,1.5,1),0,false,1.5,paredes.get_node("Este"))
	luz(arquitectura,vela.position+Vector3(-0.2,0.3,0),0.7,4)

func finalizar(datos: Dictionary) -> void:
	var jugador := (load("res://scenes/jugador.tscn") as PackedScene).instantiate() as CharacterBody3D
	agregar(jugador,raiz,"Jugador")
	jugador.position = Vector3(0,0.07,fondo/2-1.25)
	var camara := Camera3D.new()
	camara.set_script(load("res://scripts/camara_orbital.gd"))
	agregar(camara,raiz,"CamaraPrincipal")
	camara.projection = Camera3D.PROJECTION_ORTHOGONAL
	camara.current = true
	camara.size = maxf(ancho,fondo)+2.0
	camara.set("objetivo",jugador)
	camara.set("desplazamiento",Vector3(0,17,17))
	var region := Node.new()
	region.set_script(load("res://scripts/region_config.gd"))
	agregar(region,raiz,"Region")
	region.set("id_region",StringName("Interior"+id_edificio))
	var entradas: Dictionary[String,NodePath] = {("interior_"+id_edificio.to_lower()):^"Entrada"}
	region.set("entradas",entradas)
	var marcador := Marker3D.new()
	agregar(marcador,region,"Entrada")
	marcador.position = jugador.position
	marcador.set_meta("direccion_visual","arriba")
	var puerta := (load("res://scenes/interiores/puerta_interior.tscn") as PackedScene).instantiate() as Area3D
	agregar(puerta,raiz,"Salida")
	puerta.position = Vector3(0,0,fondo/2-0.95)
	puerta.set("escena_destino","res://scenes/mundo.tscn")
	puerta.set("entrada_destino","aldea_"+id_edificio.to_lower())
	puerta.set("texto","[F] Salir")
	raiz.set_meta("assets_utilizados",usados)
	raiz.set_meta("edificio",id_edificio)
	raiz.set_meta("dimensiones",Vector2(ancho,fondo))
	var visitas := {"E02":Vector3(-0.8,0,-2.6),"E03":Vector3(-0.75,0,0.55),"E04":Vector3(-1.5,0,-1.5),"E05":Vector3(0.9,0,-0.1),"E06":Vector3(-0.5,0,-1.6),"E07":Vector3(-0.8,0,-2),"E08":Vector3(0.7,0,-1.5),"E09":Vector3(-0.35,0,-0.7),"E10":Vector3(0.1,0,-1),"E11":Vector3(-0.1,0,-0.5)}
	raiz.set_meta("recorrido",PackedVector3Array([Vector3(0,0,fondo/2-1.25),Vector3(0,0,0.6),Vector3(0,0,-fondo/2+1.4),visitas[id_edificio]]))
	var recurso := PackedScene.new()
	assert(recurso.pack(raiz)==OK)
	assert(ResourceSaver.save(recurso,datos.escena)==OK)
	print("CONSTRUIDO ",id_edificio," assets=",usados.size()," escena=",datos.escena)
	manifest.append({"id":id_edificio,"assets":usados.duplicate(),"escena":datos.escena,"ancho":ancho,"fondo":fondo})
	root.remove_child(raiz)
	raiz.free()

func estante(pos: Vector3, tipo := "provisiones") -> void:
	if tipo == "provisiones":
		pieza(PROPS+"Bookcase_2.gltf",pos,0,true,0.65)
		return
	# Baldas de despensa con cotas conocidas para apoyar productos y frascos.
	for x in [-0.6,0.6]: caja(mobiliario,"MontanteDespensa",pos+Vector3(x,0.9,0),Vector3(0.1,1.8,0.4),madera)
	for y in [0.5,1.0,1.5]: caja(mobiliario,"BaldaDespensa",pos+Vector3(0,y-0.04,0),Vector3(1.3,0.08,0.42),madera)
	colision("Despensa",pos+Vector3(0,0.9,0),Vector3(1.3,1.8,0.42))
	if tipo == "pan":
		for y in [0.5,1.0,1.5]:
			for x in [-0.28,0.25]: pieza(comida("loaf"),pos+Vector3(x,y,0.12),0,false,0.85)
	elif tipo == "hierbas":
		for y in [0.5,1,1.5]:
			for x in [-0.25,0.25]: pieza(PROPS+"SmallBottle.gltf",pos+Vector3(x,y,0.1),0,false,0.7)

func mesa_domestica(pos: Vector3, bancos := false) -> void:
	pieza(mob("table"),pos,90,true)
	for z in [-0.7,0.7]:
		pieza(mob("bench" if bancos else "chair"),pos+Vector3(0,0,z),0 if z<0 else 180,true)
	pieza(mob("pot"),pos+Vector3(0.15,0.78,0))
	pieza(comida("loaf"),pos+Vector3(-0.25,0.78,0))
	pieza(comida("ale_mug"),pos+Vector3(0.3,0.78,0.18))

func cama(pos: Vector3, giro := 90.0, rica := false) -> void:
	if id_edificio in ["E06","E08","E10"]:
		pieza(PROPS+("Bed_Twin2.gltf" if id_edificio=="E08" else "Bed_Twin1.gltf"),pos,0,true,0.75 if id_edificio=="E06" else 0.8)
	else:
		pieza(mob("bed"),pos,giro,true)
	if rica:
		pieza(mob("cushion"),pos+Vector3(0,0.68,0.1),0,false,1.1)
		caja(mobiliario,"DoselTapizado",pos+Vector3(0,1.4,-0.95),Vector3(1.4,0.65,0.12),tela)

func cofre(pos: Vector3) -> void:
	# Cuerpo y tapa del mismo paquete; apoyo de tapa medido sobre su cuerpo.
	var cuerpo := pieza(mob("chest"),pos,0,true,0.95)
	var altura: Vector3 = cuerpo.get_meta("tamano")
	pieza(mob("chest_lid"),pos+Vector3.UP*altura.y,0,false,0.95)

func hogar(pos: Vector3, horno := false) -> void:
	var ladrillo := material(Color(0.46,0.30,0.22))
	ladrillo.albedo_texture = load("res://assets/aldea/glTF/T_RedBrick_BaseColor.png")
	ladrillo.uv1_triplanar = true
	ladrillo.uv1_scale = Vector3(1,1,1)
	caja(mobiliario,"HogarBase",pos+Vector3(0,0.16,0),Vector3(1.5,0.32,1.1),piedra,true)
	for x in [-0.58,0.58]: caja(mobiliario,"JambaHogar",pos+Vector3(x,0.72,0),Vector3(0.3,1.05,0.95),ladrillo,true)
	caja(mobiliario,"FondoHogar",pos+Vector3(0,0.8,-0.42),Vector3(1.4,1.2,0.18),piedra,true)
	caja(mobiliario,"Campana",pos+Vector3(0,1.55,-0.06),Vector3(1.48,0.6,1),ladrillo,true)
	caja(mobiliario,"Conducto",pos+Vector3(0,2.12,-0.25),Vector3(0.65,0.65,0.6),piedra)
	var fuego := material(Color(0.85,0.22,0.025))
	fuego.emission_enabled = true
	fuego.emission = Color(1,0.22,0.03)
	fuego.emission_energy_multiplier = 1.3
	cilindro("Brasas",pos+Vector3(0,0.37,0.05),0.4,0.08,fuego)
	for x in [-0.23,0,0.23]:
		var leno := cilindro("Leno",pos+Vector3(x,0.41,0.12),0.07,0.55,oscura)
		leno.rotation_degrees.x = 90
	luz(arquitectura,pos+Vector3(0,0.8,0.45),1.1,4.5)
	if horno:
		pieza(comida("loaf"),pos+Vector3(0,0.44,0.13),0,false,0.9)
	else:
		pieza(mob("cauldron"),pos+Vector3(0,0.45,0.16),0,false,0.65)

func panaderia() -> void:
	hogar(Vector3(-2.1,0,-2.7),true)
	pieza(mob("woodpile"),Vector3(-2.25,0,-0.9),90,true,0.8)
	var banco := pieza(mob("workbench"),Vector3(1.8,0,-2.6),0,true)
	pieza(comida("roll"),banco.position+Vector3(-0.25,1.02,0))
	# Artesa, masa, rodillo y pala de horno complementarios.
	for x in [-0.47,0.47]: caja(mobiliario,"ArtesaLateral",banco.position+Vector3(x,1.12,0),Vector3(0.08,0.18,0.4),madera)
	caja(mobiliario,"Masa",banco.position+Vector3(0,1.08,0),Vector3(0.6,0.12,0.3),material(Color(0.84,0.69,0.43)))
	var rodillo := cilindro("Rodillo",banco.position+Vector3(0,1.08,0.28),0.05,0.5,madera)
	rodillo.rotation_degrees.z = 90
	caja(mobiliario,"PalaHorno",Vector3(-2.8,1.12,-1.9),Vector3(0.3,0.44,0.05),madera)
	caja(mobiliario,"MangoPala",Vector3(-2.8,0.55,-1.9),Vector3(0.05,0.95,0.05),madera)
	estante(Vector3(2.35,0,-0.7),"pan")
	pieza(mob("table"),Vector3(-1.9,0,1.6),90,true)
	pieza(comida("scales"),Vector3(-1.7,0.78,1.6))
	for x in [-2.4,-1.9,-1.4]: pieza(comida("loaf"),Vector3(x,0.78,1.6))
	for z in [-0.2,0.4]: pieza(comida("grain_sack"),Vector3(-2.6,0,z),0,true,1.3)
	pieza(herramienta("basket"),Vector3(2.3,0,2.5),0,true,1.2)

func herreria() -> void:
	# Forja real del paquete: ajuste solo de instancia para altura 2,84.
	pieza(SMITH+"forge.glb",Vector3(-2.7,0,-1.5),0,true,0.7)
	luz(arquitectura,Vector3(-2.7,1.05,-0.8),1.6,5)
	pieza(SMITH+"bellows.glb",Vector3(-2.0,0.65,-1.7),90,false,0.7)
	pieza(PROPS+"Anvil_Log.gltf",Vector3(-1.65,0,0.55),0,true)
	pieza(mob("workbench"),Vector3(2.55,0,-1.8),0,true)
	pieza(SMITH+"ingot_stack.glb",Vector3(2.15,1.02,-1.8))
	pieza(SMITH+"smith_hammer.glb",Vector3(2.65,1.02,-1.8))
	pieza(SMITH+"tongs.glb",Vector3(3,1.02,-1.8),0,false,0.7)
	pieza(SMITH+"tool_rack.glb",Vector3(2.7,0,0.3),90,true,0.8)
	pieza(SMITH+"coal_pile.glb",Vector3(-3.0,0,1.7),0,true,0.55)
	pieza(PROPS+"Bucket_Metal.gltf",Vector3(-2.3,0,1.5),0,true,0.6)
	pieza(PROPS+"Barrel.gltf",Vector3(3.1,0,1.8),0,true,0.75)
	pieza(PROPS+"Whetstone.gltf",Vector3(1.9,0,1.6),90,true,0.65)
	for z in [-1.4,-0.9,-0.4]: pieza(SMITH+"horseshoe.glb",Vector3(3.8,1.2,z),90,false,0.75,paredes.get_node("Este"))

func carpinteria() -> void:
	pieza(mob("workbench"),Vector3(-2.6,0,-1.5),90,true)
	pieza(herramienta("hammer"),Vector3(-2.6,1.02,-1.25))
	pieza(herramienta("axe"),Vector3(-2.6,1.02,-1.8),0,false,0.7)
	pieza(SMITH+"wood_log_pile.glb",Vector3(2.6,0,-2),0,true,0.65)
	for i in 5:
		caja(mobiliario,"Tablon",Vector3(3.5-i*0.08,1.0,-0.55+i*0.12),Vector3(0.16,2,0.08),madera).rotation_degrees.z = -8
	colision("Tablones",Vector3(3.3,1,-0.3),Vector3(0.6,2,1))
	pieza(PROPS+"Crate_Wooden.gltf",Vector3(-3,0,1.8),0,true,0.7)
	pieza(PROPS+"Barrel.gltf",Vector3(-2.1,0,1.8),0,true,0.65)
	pieza(herramienta("cart_wheel"),Vector3(2,0,1.1),0,true,0.8)
	# Banco de ensamblaje con silla en reparación y piezas sujetas.
	pieza(mob("table"),Vector3(1.9,0,-0.4),0,true)
	pieza(mob("chair"),Vector3(2.0,0.78,-0.4),0,false,1.0)
	for z in [-1.8,-1.5,-1.2]: caja(mobiliario,"Liston",Vector3(-2.6,1.08,z),Vector3(0.5,0.08,0.1),madera)
	var sierra := caja(mobiliario,"Sierra",Vector3(-2.6,1.1,-0.9),Vector3(0.12,0.035,0.55),material(Color(0.48,0.50,0.49)))
	sierra.rotation_degrees.y = 25
	caja(mobiliario,"MangoSierra",Vector3(-2.6,1.1,-0.55),Vector3(0.14,0.1,0.16),oscura)
	pieza(mob("shelf"),Vector3(-3.7,1.55,-1.4),90,false,1.0,paredes.get_node("Oeste"))

func herbolario() -> void:
	pieza(PROPS+"Shelf_Small_Bottles.gltf",Vector3(-2.35,0,-1.7),90,true,0.8)
	estante(Vector3(2.2,0,-2.4),"hierbas")
	pieza(mob("workbench"),Vector3(1.95,0,-0.3),90,true)
	pieza(comida("scales"),Vector3(1.95,1.02,-0.65))
	# Mortero con cuenco y mano propios, sin sustituirlo por una botella.
	cilindro("Mortero",Vector3(1.95,1.1,0),0.13,0.16,piedra)
	cilindro("HuecoMortero",Vector3(1.95,1.185,0),0.095,0.01,oscura)
	cilindro("ManoMortero",Vector3(2.0,1.24,0),0.035,0.25,piedra).rotation_degrees.z = -25
	pieza(mob("table"),Vector3(-2,0,1.3),90,true)
	for x in [-2.35,-2,-1.65]: pieza(PROPS+"SmallBottle.gltf",Vector3(x,0.78,1.3),0,false,0.6)
	for z in [-1.4,-0.8,-0.2]: pieza(comida("herb_bundle"),Vector3(-2.8,1.7,z),0,false,1,paredes.get_node("Oeste"))
	for pos in [Vector3(2.3,0,1.7),Vector3(-2.4,0,-0.2),Vector3(1.2,0,-2.4)]: pieza(mob("pottedplant"),pos,0,true,0.9)
	pieza(PROPS+"Book_5.gltf",Vector3(1.95,1.02,0.45),0,false,0.35)
	pieza(herramienta("basket"),Vector3(2.3,0,0.9),0,true)
	luz(arquitectura,Vector3(-2,2,-1),0.3,3)

func vivienda06() -> void:
	cama(Vector3(-1.55,0,-1.8))
	# Tabique bajo del rincón de dormir, abierto hacia el pasillo central.
	caja(mobiliario,"CabeceroAlcoba",Vector3(-1.55,0.58,-3.12),Vector3(1.5,1.16,0.12),oscura,true)
	cofre(Vector3(-1.55,0,0.2))
	mesa_domestica(Vector3(1.5,0,0.6))
	pieza(mob("shelf"),Vector3(1.2,1.4,-3.25),0,false,1.2,paredes.get_node("Norte"))
	pieza(mob("pot"),Vector3(1.35,1.72,-3.2),0,false,1,paredes.get_node("Norte"))
	pieza(PROPS+"Bag.gltf",Vector3(1.8,0,-2.4),0,true,0.7)
	pieza(mob("candle"),Vector3(1.6,0.78,0.7))

func vivienda07() -> void:
	cama(Vector3(-2.3,0,-2),90,true)
	# Alcoba separada del salón por biombo bajo, con hueco central transitable.
	caja(mobiliario,"BiomboAlcoba",Vector3(-2.6,0.55,-0.45),Vector3(1.5,1.1,0.12),tela,true)
	mesa_domestica(Vector3(2.1,0,1.15))
	pieza(mob("rug"),Vector3(0,0.025,0),0,false,1.3)
	estante(Vector3(2.5,0,-2.8))
	cofre(Vector3(-2.6,0,1.8))
	cofre(Vector3(1.2,0,-2.8))
	# Armario de carpintería propio: puertas paneladas, cornisa y tiradores.
	caja(mobiliario,"Armario",Vector3(2.65,1.0,-0.5),Vector3(1.15,2,0.65),oscura,true)
	for x in [2.38,2.92]:
		caja(mobiliario,"HojaArmario",Vector3(x,1,-0.15),Vector3(0.5,1.8,0.06),madera)
		cilindro("Tirador",Vector3(x,1.05,-0.09),0.035,0.07,piedra).rotation_degrees.x = 90
	caja(mobiliario,"Cornisa",Vector3(2.65,2.08,-0.5),Vector3(1.3,0.16,0.8),madera)
	pieza(mob("painting"),Vector3(-3.3,1.3,1.6),90,false,1.2,paredes.get_node("Oeste"))
	pieza(mob("curtain"),Vector3(-3.3,1.4,-1.9),90,false,1,paredes.get_node("Oeste"))
	var norte := paredes.get_node("Norte")
	caja(norte,"TapizBorde",Vector3(0,1.6,-3.35),Vector3(0.9,1.4,0.045),material(Color(0.55,0.40,0.18)))
	caja(norte,"TapizAzul",Vector3(0,1.6,-3.31),Vector3(0.72,1.2,0.035),tela)
	caja(norte,"MotivoTapiz",Vector3(0,1.6,-3.28),Vector3(0.12,0.8,0.025),material(Color(0.65,0.53,0.28)))
	pieza(mob("candle"),Vector3(2.1,0.78,1.15))
	pieza(comida("cheese_wheel"),Vector3(2.1,0.78,0.9),0,false,0.7)

func vivienda08() -> void:
	cama(Vector3(1.85,0,-1.65),90)
	hogar(Vector3(-1.9,0,-2.35))
	pieza(mob("workbench"),Vector3(-1.9,0,0.7),90,true)
	pieza(herramienta("hammer"),Vector3(-1.9,1.02,0.6))
	pieza(herramienta("axe"),Vector3(-1.9,1.02,1),0,false,0.6)
	pieza(PROPS+"Crate_Wooden.gltf",Vector3(2.1,0,0.4),0,true,0.6)
	pieza(PROPS+"Bag.gltf",Vector3(2.15,0,1.3),0,true,0.6)
	pieza(PROPS+"Barrel.gltf",Vector3(-2,0,2),0,true,0.65)
	pieza(mob("shelf"),Vector3(1.6,1.65,-2.85),0,false,1.5,paredes.get_node("Norte"))
	pieza(mob("pot"),Vector3(1.6,2.05,-2.8),0,false,1,paredes.get_node("Norte"))

func vivienda09() -> void:
	cama(Vector3(-1.5,0,-1.2),90)
	mesa_domestica(Vector3(1.4,0,0.4))
	cofre(Vector3(-1.65,0,1.25))
	pieza(mob("shelf"),Vector3(1.0,1.4,-2.35),0,false,1.4,paredes.get_node("Norte"))
	pieza(mob("pot"),Vector3(1.0,1.77,-2.3),0,false,1,paredes.get_node("Norte"))
	pieza(mob("rug"),Vector3(0.1,0.02,0),0,false,0.7)
	pieza(mob("candle"),Vector3(1.4,0.78,0.4))
	# Rincón de cocina doméstica bajo, diferente del taller E08.
	caja(mobiliario,"FogonBajo",Vector3(1.55,0.3,-1.8),Vector3(1,0.6,0.7),piedra,true)
	pieza(mob("pot"),Vector3(1.55,0.61,-1.8),0,false,1.3)

func vivienda10() -> void:
	cama(Vector3(-2,0,-2.1),90)
	mesa_domestica(Vector3(1.9,0,0.25),true)
	cofre(Vector3(-2.3,0,0.2))
	for x in [1.2,1.8,2.4]: pieza(comida("grain_sack"),Vector3(x,0,-2.6),0,true,1.25)
	pieza(herramienta("basket"),Vector3(-2.6,0,1.5),0,true)
	pieza(PROPS+"Barrel.gltf",Vector3(2.7,0,2.1),0,true,0.7)
	pieza(herramienta("shovel"),Vector3(-3.05,0,1.8),0,false,0.75,paredes.get_node("Oeste"))
	pieza(mob("shelf"),Vector3(1.7,1.5,-3.35),0,false,1.6,paredes.get_node("Norte"))
	# Despensa rural delimitada por un listón bajo, sin cerrar el pasillo.
	caja(mobiliario,"ZocaloDespensa",Vector3(2.05,0.18,-1.75),Vector3(1.7,0.36,0.12),madera,true)
	pieza(comida("loaf"),Vector3(1.6,1.93,-3.25),0,false,1,paredes.get_node("Norte"))
	# Provisiones del huerto agrícola local, a escala de una cesta doméstica.
	pieza("res://assets/granja/Farm_Harvest/glTF/mdvl_farm_fruit_basket_01.glb",Vector3(-2.6,0,2.2),0,false,0.8)

func vivienda11() -> void:
	cama(Vector3(1.8,0,-1.7),90)
	mesa_domestica(Vector3(-1.8,0,0.5))
	pieza(mob("rug"),Vector3(0,0.025,0),0,false,1.0)
	cofre(Vector3(2.0,0,0.3))
	pieza(mob("curtain"),Vector3(2.8,1.4,-1.6),-90,false,1,paredes.get_node("Este"))
	pieza(mob("painting"),Vector3(0.6,1.4,-2.85),0,false,0.9,paredes.get_node("Norte"))
	for pos in [Vector3(-2.35,0,-2.2),Vector3(-1.3,0,-2.4),Vector3(2.25,0,1.7)]: pieza(mob("pottedplant"),pos,0,true,0.8)
	for x in [-1.9,-0.8]:
		pieza(mob("shelf"),Vector3(x,1.2,-2.85),0,false,0.8,paredes.get_node("Norte"))
		pieza(mob("pot"),Vector3(x,1.412,-2.75),0,false,0.8,paredes.get_node("Norte"))
		pieza("res://assets/naturaleza/glTF/Flower_3_Group.gltf",Vector3(x,1.60,-2.75),0,false,0.12,paredes.get_node("Norte"))
	pieza(mob("cushion"),Vector3(1.8,0.65,-1.7))

func construir() -> void:
	var datos: Array = JSON.parse_string(FileAccess.get_file_as_string(CONFIG))
	for d: Dictionary in datos:
		base_sala(d)
		call(d.diseno)
		finalizar(d)
	var archivo := FileAccess.open("res://logs/interiores_e02_e11/assets_construidos.json",FileAccess.WRITE)
	archivo.store_string(JSON.stringify(manifest,"\t"))
	quit()
