extends SceneTree
## Autoría opcional: guarda únicamente jardin_hierbas.tscn; no se ejecuta al jugar.
var jardin := Node3D.new()
var numero := 0
var materiales: Dictionary = {}

func _initialize() -> void:
	call_deferred("construir")

func material(nombre: String, color: Color) -> StandardMaterial3D:
	if not materiales.has(nombre):
		var mat := StandardMaterial3D.new()
		mat.resource_name = nombre
		mat.albedo_color = color
		mat.roughness = 0.95
		materiales[nombre] = mat
	return materiales[nombre]

func malla(nombre: String, mesh: Mesh, posicion: Vector3, mat: Material) -> MeshInstance3D:
	var nodo := MeshInstance3D.new()
	numero += 1
	nodo.name = nombre+str(numero)
	nodo.mesh = mesh
	nodo.position = posicion
	nodo.material_override = mat
	jardin.add_child(nodo)
	return nodo

func esfera(nombre: String, posicion: Vector3, escala: Vector3, mat: Material) -> void:
	var mesh := SphereMesh.new()
	mesh.radial_segments = 8
	mesh.rings = 3
	mesh.radius = 0.5
	mesh.height = 1
	malla(nombre,mesh,posicion,mat).scale = escala

func original(ruta: String, nombre: String, centro: Vector3, tamano: Vector3) -> void:
	var nodo: Node3D = load(ruta).instantiate()
	jardin.add_child(nodo)
	nodo.name = nombre
	var caja := AABB()
	var primero := true
	for mesh: MeshInstance3D in nodo.find_children("*","MeshInstance3D",true,false):
		var local: AABB = mesh.transform*mesh.get_aabb()
		caja = local if primero else caja.merge(local)
		primero = false
	nodo.scale = tamano/caja.size
	nodo.position = centro-Vector3(caja.get_center().x,caja.position.y,caja.get_center().z)*nodo.scale

func propietarios(nodo: Node) -> void:
	for hijo in nodo.get_children():
		hijo.owner = jardin
		# Mantener intacta la propiedad interna de escenas importadas.
		if hijo.scene_file_path.is_empty():
			propietarios(hijo)

func construir() -> void:
	jardin.name = "JardinHierbas"
	jardin.set_meta("tamano",Vector2(4,4))
	jardin.set_meta("recorrido_local",PackedVector2Array([Vector2(-2,0),Vector2(-0.8,0),Vector2(0.4,0.1)]))
	root.add_child(jardin)
	var piedra := material("PiedraCalida",Color(0.48,0.46,0.36))
	var tierra := material("TierraLocal",Color(0.30,0.23,0.14))
	var hoja := material("HojaSalvia",Color(0.29,0.43,0.25))
	# Tres islas bajas de suelo; entrada oeste y claro central libres.
	for datos in [Vector3(-0.45,0,-1.28),Vector3(-0.25,0,1.28),Vector3(1.25,0,0.4)]:
		esfera("Tierra",datos+Vector3(0,0.012,0),Vector3(1.45,0.035,0.9),tierra)
	for i in 5:
		var mesh := CylinderMesh.new()
		mesh.top_radius = 0.24
		mesh.bottom_radius = 0.27
		mesh.height = 0.025
		mesh.radial_segments = 7
		malla("Losa",mesh,Vector3(-1.70+i*0.46,0.018,0.10*sin(i*1.8)),piedra).rotation.y = i*0.7
	original("res://assets/naturaleza/glTF/Flower_3_Group.gltf","FloresSilvestresNorte",Vector3(-0.55,0.025,-1.26),Vector3(1.15,0.64,0.65))
	original("res://assets/naturaleza/glTF/Flower_4_Group.gltf","FloresSilvestresSur",Vector3(-0.35,0.025,1.28),Vector3(1.2,0.55,0.66))
	# Bush_Common local usa follaje rojo; copa propia verde sin editar su textura.
	for i in 3:
		esfera("ArbustoEste",Vector3(1.20+i*0.16,0.25+0.06*(i%2),-1.25+0.12*sin(i*2)),Vector3(0.42,0.48,0.45),hoja)
	original("res://assets/naturaleza/glTF/Fern_1.gltf","HelechoEste",Vector3(1.35,0.02,1.3),Vector3(0.7,0.54,0.7))
	# Acentos propios legibles: corolas de cinco pétalos sobre follaje bajo.
	var colores := [Color(0.73,0.52,0.67),Color(0.88,0.79,0.43),Color(0.83,0.82,0.70),Color(0.52,0.46,0.68)]
	for i in 12:
		var centro := Vector3(0.85+0.38*sin(i*2.4),0.27+0.09*(i%3),-0.65+float(i)/11.0*1.3)
		esfera("Hojas",Vector3(centro.x,0.16,centro.z),Vector3(0.32,0.28,0.28),hoja)
		for petalo in 5:
			var angulo := petalo*TAU/5
			esfera("Petalo",centro+Vector3(cos(angulo)*0.085,0,sin(angulo)*0.085),Vector3(0.16,0.07,0.14),material("Flor"+str(i%4),colores[i%4]))
		esfera("CentroFlor",centro+Vector3(0,0.025,0),Vector3(0.075,0.065,0.075),material("Polen",Color(0.76,0.59,0.25)))
	# Maceta pequeña al noreste, sin colisión como las plantas bajas.
	original("res://assets/objetos_medievales/glTF/Pot_1.gltf","Maceta",Vector3(0.4,0.02,-1.55),Vector3(0.38,0.33,0.38))
	esfera("SalviaMaceta",Vector3(0.4,0.42,-1.55),Vector3(0.4,0.30,0.4),hoja)
	for i in 5:
		esfera("PiedraBorde",Vector3(-1.25+i*0.53,0.06,1.78-0.07*sin(i*2)),Vector3(0.25,0.13,0.22),piedra)
	propietarios(jardin)
	var escena := PackedScene.new()
	var error := escena.pack(jardin)
	if error == OK:
		error = ResourceSaver.save(escena,"res://scenes/jardin_hierbas.tscn")
	print("JARDIN_GUARDADO: ",error,"; nodos: ",jardin.get_child_count())
	quit(error)
