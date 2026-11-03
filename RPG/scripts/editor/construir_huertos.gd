extends SceneTree
## Herramienta de autoría, nunca se ejecuta durante el juego.
## Regenera únicamente las tres escenas de huerto; sin modificar assets ni la aldea.
## godot --headless --path RPG --script res://scripts/editor/construir_huertos.gd
var materiales: Dictionary = {}
var huerto: Node3D
var bancales: Node3D
var cultivos: Node3D
var cercas: Node3D
var utiles: Node3D
var colisiones: StaticBody3D
var numero := 0
var errores := 0

func _initialize() -> void:
	call_deferred("construir")

func material(nombre: String, color: Color) -> StandardMaterial3D:
	if not materiales.has(nombre):
		var nuevo := StandardMaterial3D.new()
		nuevo.resource_name = nombre
		nuevo.albedo_color = color
		nuevo.roughness = 0.96
		materiales[nombre] = nuevo
	return materiales[nombre]

func grupo(nombre: String) -> Node3D:
	var nodo := Node3D.new()
	nodo.name = nombre
	huerto.add_child(nodo)
	return nodo

func iniciar(nombre: String, tamano: Vector2, entrada: Vector2, recorrido: PackedVector2Array) -> void:
	huerto = Node3D.new()
	huerto.name = nombre
	huerto.set_meta("tamano", tamano)
	huerto.set_meta("entrada_local", entrada)
	huerto.set_meta("recorrido_local", recorrido)
	bancales = grupo("Bancales")
	cultivos = grupo("Cultivos")
	cercas = grupo("Cercas")
	utiles = grupo("Utileria")
	colisiones = StaticBody3D.new()
	colisiones.name = "Colisiones"
	huerto.add_child(colisiones)
	numero = 0

func malla(padre: Node3D, nombre: String, mesh: Mesh, posicion: Vector3, mat: Material) -> MeshInstance3D:
	var nodo := MeshInstance3D.new()
	numero += 1
	nodo.name = nombre+"%03d" % numero
	nodo.mesh = mesh
	nodo.material_override = mat
	nodo.position = posicion
	padre.add_child(nodo)
	return nodo

func caja(padre: Node3D, nombre: String, centro: Vector3, tamano: Vector3, mat: Material, solida: bool = false) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = tamano
	var nodo := malla(padre,nombre,mesh,centro,mat)
	if solida:
		colision(nombre,centro,tamano)
	return nodo

func colision(nombre: String, centro: Vector3, tamano: Vector3) -> void:
	var forma := CollisionShape3D.new()
	forma.name = nombre+str(colisiones.get_child_count())
	var box := BoxShape3D.new()
	box.size = tamano
	forma.shape = box
	forma.position = centro
	colisiones.add_child(forma)

func esfera(padre: Node3D, nombre: String, posicion: Vector3, escala: Vector3, mat: Material) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 8
	mesh.rings = 3
	var nodo := malla(padre,nombre,mesh,posicion,mat)
	nodo.scale = escala
	return nodo

func cilindro(padre: Node3D, nombre: String, posicion: Vector3, radio: float, altura: float, mat: Material) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radio
	mesh.bottom_radius = radio*1.12
	mesh.height = altura
	mesh.radial_segments = 7
	return malla(padre,nombre,mesh,posicion,mat)

func tierra(centro: Vector2, tamano: Vector2, semilla: int) -> void:
	# Contorno irregular biselado con volumen bajo, no un cubo de tierra.
	var puntos := PackedVector2Array()
	for i in 16:
		var angulo := TAU*float(i)/16.0
		var direccion := Vector2(cos(angulo),sin(angulo))
		var irregular := 1.0+0.035*sin(float(i*3+semilla))
		# Superelipse de esquinas suaves, conservando toda la planta dentro del tamaño.
		var p := Vector2(signf(direccion.x)*pow(absf(direccion.x),0.5),signf(direccion.y)*pow(absf(direccion.y),0.5))
		puntos.append(centro+p*tamano*0.46*irregular)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 16:
		var a: Vector2 = puntos[i]
		var b: Vector2 = puntos[(i+1)%16]
		var interior_a := centro+(a-centro)*0.91
		var interior_b := centro+(b-centro)*0.91
		var vertices := [Vector3(centro.x,0.12,centro.y),Vector3(interior_b.x,0.11,interior_b.y),Vector3(interior_a.x,0.11,interior_a.y),Vector3(interior_a.x,0.11,interior_a.y),Vector3(interior_b.x,0.11,interior_b.y),Vector3(b.x,0.008,b.y),Vector3(interior_a.x,0.11,interior_a.y),Vector3(b.x,0.008,b.y),Vector3(a.x,0.008,a.y)]
		# Godot considera frontal el orden horario.
		for inicio in [0,3,6]:
			st.add_vertex(vertices[inicio])
			st.add_vertex(vertices[inicio+2])
			st.add_vertex(vertices[inicio+1])
	st.generate_normals()
	malla(bancales,"Bancal",st.commit(),Vector3.ZERO,material("TierraCultivada",Color(0.30,0.20,0.115)))
	# Surcos cortos alternados, apoyados en la tierra; no tienen colisión.
	for i in int(tamano.x/0.35):
		var x := centro.x-tamano.x*0.38+float(i)*0.35
		if x > centro.x+tamano.x*0.38:
			break
		esfera(bancales,"Surco",Vector3(x,0.105,centro.y),Vector3(0.11,0.055,tamano.y*0.68),material("Surco",Color(0.36,0.25,0.15)))

func sendero(puntos: PackedVector2Array) -> void:
	# Piedras terrosas bajas, irregulares y espaciadas: el shader general queda visible.
	for i in range(puntos.size()-1):
		var longitud := puntos[i].distance_to(puntos[i+1])
		for j in int((longitud-0.72)/0.48)+1:
			var p := puntos[i].lerp(puntos[i+1],(0.36+float(j)*0.48)/longitud)
			esfera(bancales,"PasoTierra",Vector3(p.x,0.012,p.y),Vector3(0.68,0.045,0.57),material("TierraPisada",Color(0.48,0.37,0.23)))

func cerca(a: Vector2, b: Vector2) -> void:
	var madera := material("MaderaEnvejecida",Color(0.37,0.26,0.15))
	var largo := a.distance_to(b)
	var centro := (a+b)*0.5
	var horizontal := absf(a.x-b.x)>0.1
	for altura in [0.23,0.49]:
		caja(cercas,"Travesano",Vector3(centro.x,altura,centro.y),Vector3(largo,0.09,0.09) if horizontal else Vector3(0.09,0.09,largo),madera)
	var pasos := maxi(1,int(ceil(largo/1.3)))
	for i in pasos+1:
		var p := a.lerp(b,float(i)/pasos)
		var altura := 0.66+0.035*sin(float(i)*2.0)
		cilindro(cercas,"Poste",Vector3(p.x,altura*0.5,p.y),0.065,altura,madera)
	colision("Cerca",Vector3(centro.x,0.33,centro.y),Vector3(largo+0.15,0.66,0.16) if horizontal else Vector3(0.16,0.66,largo+0.15))

func hojas(centro: Vector3, escala: float, tipo: String, indice: int) -> void:
	var verde := material("HojaVerde",Color(0.27,0.44,0.16))
	var claro := material("HojaClara",Color(0.46,0.59,0.25))
	for i in 7:
		var angulo := TAU*float(i)/7.0+float(indice)*0.65
		var p := centro+Vector3(cos(angulo)*0.15,0.14,sin(angulo)*0.15)*escala
		var hoja := esfera(cultivos,"Hoja"+tipo,p,Vector3(0.22,0.13,0.39)*escala,verde if i%2==0 else claro)
		hoja.rotation = Vector3(-0.35,angulo,0)
	esfera(cultivos,"Corazon"+tipo,centro+Vector3(0,0.22,0)*escala,Vector3(0.35,0.32,0.35)*escala,claro)

func cebolla(p: Vector2, escala: float) -> void:
	esfera(cultivos,"BulboCebolla",Vector3(p.x,0.16,p.y),Vector3(0.22,0.19,0.22)*escala,material("Cebolla",Color(0.75,0.62,0.36)))
	for i in 5:
		var hoja := cilindro(cultivos,"TalloCebolla",Vector3(p.x+sin(float(i))*0.06,0.34*escala,p.y+cos(float(i))*0.06),0.022*escala,0.36*escala,material("HojaCebolla",Color(0.27,0.43,0.19)))
		hoja.rotation = Vector3(0.18*cos(float(i)),0,0.18*sin(float(i)))

func calabaza(p: Vector2, escala: float, clara: bool) -> void:
	var naranja := material("CalabazaDorada",Color(0.81,0.39,0.09))
	if clara:
		naranja = material("CalabazaCrema",Color(0.76,0.66,0.35))
	for i in 7:
		var angulo := TAU*float(i)/7.0
		esfera(cultivos,"LobuloCalabaza",Vector3(p.x+cos(angulo)*0.13*escala,0.25*escala,p.y+sin(angulo)*0.13*escala),Vector3(0.38,0.38,0.38)*escala,naranja)
	cilindro(cultivos,"Pedunculo",Vector3(p.x,0.47*escala,p.y),0.045,0.16*escala,material("Tallo",Color(0.26,0.31,0.10)))
	for i in 3:
		var hoja := esfera(cultivos,"HojaCalabaza",Vector3(p.x+(float(i)-1)*0.37,0.17,p.y+0.2),Vector3(0.31,0.07,0.29),material("HojaCalabaza",Color(0.25,0.39,0.14)))
		hoja.rotation.y = float(i)

func prop(nombre: String, p: Vector2, escala: float, solido: bool) -> Node3D:
	var original: PackedScene = load("res://assets/objetos_medievales/glTF/"+nombre+".gltf")
	var nodo: Node3D = original.instantiate()
	nodo.name = nombre
	utiles.add_child(nodo)
	nodo.scale = Vector3.ONE*escala
	# Correcciones de apoyo medidas en originales, sin editar fuentes.
	var y := 0.017*escala if nombre.begins_with("FarmCrate") else 0.003
	nodo.position = Vector3(p.x,y,p.y)
	if nombre == "FarmCrate_Carrot":
		colores_instancia(nodo)
	if solido:
		var tamano := Vector3(0.72,0.42,0.72) if nombre == "FarmCrate_Carrot" else Vector3(0.70,0.91,0.70)
		if nombre == "Bag": tamano=Vector3(0.67,0.81,0.56)
		colision(nombre,Vector3(p.x,tamano.y*escala*0.5,p.y),tamano*escala)
	return nodo

func zanahoria(p: Vector2, escala: float) -> void:
	var nodo: Node3D = load("res://assets/objetos_medievales/glTF/Carrot.gltf").instantiate()
	numero += 1
	nodo.name = "Zanahoria%03d"%numero
	cultivos.add_child(nodo)
	nodo.position = Vector3(p.x,0.27*escala,p.y)
	nodo.scale = Vector3.ONE*escala
	nodo.rotation.y = float(numero)*1.37
	colores_instancia(nodo)

func colores_instancia(nodo: Node3D) -> void:
	# Estos originales codifican el naranja/verde en COLOR_0. Nunca editar su material.
	nodo.owner = huerto
	huerto.set_editable_instance(nodo,true)
	for mesh: MeshInstance3D in nodo.find_children("*","MeshInstance3D",true,false):
		for superficie in mesh.mesh.get_surface_count():
			var original: Material = mesh.get_active_material(superficie)
			if original is StandardMaterial3D:
				var exclusivo: StandardMaterial3D = original.duplicate()
				exclusivo.vertex_color_use_as_albedo = true
				mesh.set_surface_override_material(superficie,exclusivo)

func tutores() -> void:
	var madera := material("Tutores",Color(0.49,0.35,0.19))
	for x in [-1.8,0.0,1.8]:
		caja(cercas,"Tutor",Vector3(x,0.64,-1.1),Vector3(0.09,1.28,0.09),madera,true)
	for y in [0.56,1.15]:
		caja(cercas,"ListonTutor",Vector3(0,y,-1.1),Vector3(3.85,0.065,0.07),madera,true)
	for x in [-1.35,-0.45,0.45,1.35]:
		cilindro(cultivos,"TalloTomate",Vector3(x,0.59,-1.03),0.025,0.94,material("TalloTomate",Color(0.23,0.36,0.12)))
		for nivel in 3:
			var y := 0.34+float(nivel)*0.27
			for lado in [-1,1]:
				var hoja := esfera(cultivos,"HojaTomate",Vector3(x+lado*0.12,y,-1.00),Vector3(0.28,0.07,0.18),material("HojaTomate",Color(0.29,0.43,0.15)))
				hoja.rotation.z = lado*0.35
			esfera(cultivos,"Tomate",Vector3(x+0.12*cos(x*8+float(nivel)),y-0.045,-0.87),Vector3.ONE*0.16,material("TomateRojo",Color(0.73,0.20,0.09)) if nivel<2 else material("TomateVerde",Color(0.47,0.56,0.17)))

func herramienta(p: Vector2) -> void:
	var madera := material("Mango",Color(0.55,0.39,0.21))
	cilindro(utiles,"MangoRastrillo",Vector3(p.x,0.5,p.y),0.024,0.96,madera)
	caja(utiles,"CabezaRastrillo",Vector3(p.x,0.13,p.y),Vector3(0.43,0.07,0.09),madera)
	for i in 5:
		caja(utiles,"DienteRastrillo",Vector3(p.x-0.17+i*0.085,0.08,p.y+0.03),Vector3(0.027,0.13,0.035),madera)

func asignar_owner(nodo: Node) -> void:
	for hijo in nodo.get_children():
		hijo.owner = huerto
		if hijo.scene_file_path.is_empty():
			asignar_owner(hijo)

func guardar(ruta: String) -> void:
	asignar_owner(huerto)
	var escena := PackedScene.new()
	var error := escena.pack(huerto)
	if error == OK:
		error = ResourceSaver.save(escena,ruta)
	print("HUERTO_GUARDADO: ",ruta," error=",error," formas=",colisiones.get_child_count())
	if error != OK:
		errores += 1
	huerto.free()

func construir() -> void:
	iniciar("HuertoComunitario",Vector2(6,5),Vector2(3,1),PackedVector2Array([Vector2(3,1),Vector2(-2.2,1)]))
	sendero(huerto.get_meta("recorrido_local"))
	tierra(Vector2(-0.55,-1.6),Vector2(4.2,0.9),1)
	tierra(Vector2(-0.45,-0.25),Vector2(4.4,0.95),2)
	tierra(Vector2(-0.75,1.92),Vector2(3.8,0.65),3)
	for i in 6:
		for fila in 2:
			zanahoria(Vector2(-2.22+i*0.61,-1.76+fila*0.32),0.92+float(i%3)*0.09)
	for i in 5:
		hojas(Vector3(-2.15+i*0.85,0.12,-0.25),0.90+float(i%2)*0.13,"Col",i)
	for i in 6:
		cebolla(Vector2(-2.2+i*0.57,1.92),0.8+float(i%3)*0.1)
	cerca(Vector2(-2.8,-2.23),Vector2(-2.8,2.22))
	cerca(Vector2(-2.8,-2.23),Vector2(2.7,-2.23))
	cerca(Vector2(-2.7,2.3),Vector2(-0.7,2.3))
	prop("Barrel",Vector2(2.25,-1.5),0.73,true)
	prop("FarmCrate_Carrot",Vector2(2.15,-0.35),0.95,true)
	guardar("res://scenes/huerto_comunitario.tscn")

	iniciar("HuertoE09",Vector2(6,4),Vector2(3,0),PackedVector2Array([Vector2(3,0),Vector2(-2.05,0)]))
	sendero(huerto.get_meta("recorrido_local"))
	tierra(Vector2(-1.05,-1.12),Vector2(2.8,0.98),4)
	tierra(Vector2(-1.05,1.07),Vector2(2.2,1.05),5)
	tierra(Vector2(1.43,1.1),Vector2(1.6,1.0),6)
	for i in 3:
		hojas(Vector3(-1.95+i*0.87,0.12,-1.12),0.87+float(i)*0.08,"Lechuga",i+3)
	calabaza(Vector2(-1.35,1.0),1.0,false)
	calabaza(Vector2(-0.5,1.13),0.66,true)
	calabaza(Vector2(1.4,1.06),0.90,false)
	cerca(Vector2(-2.8,-1.7),Vector2(-2.8,1.7))
	cerca(Vector2(-2.65,1.78),Vector2(-1.55,1.78))
	prop("Bucket_Wooden_1",Vector2(2.35,-1.1),1.2,false)
	prop("FarmCrate_Carrot",Vector2(1.15,-1.13),1.05,true)
	herramienta(Vector2(-2.55,0.8))
	guardar("res://scenes/huerto_e09.tscn")

	iniciar("HuertoE10",Vector2(6,4),Vector2(-3,0),PackedVector2Array([Vector2(-3,0),Vector2(1.6,0)]))
	sendero(huerto.get_meta("recorrido_local"))
	tierra(Vector2(0,-1.08),Vector2(4.25,0.93),7)
	tierra(Vector2(-0.9,1.15),Vector2(2.7,0.85),8)
	tutores()
	for i in 4:
		cebolla(Vector2(-1.9+i*0.60,1.15),0.75+float(i)*0.06)
	hojas(Vector3(0.45,0.12,1.1),0.66,"Plantin",1)
	cerca(Vector2(-2.65,1.8),Vector2(2.65,1.8))
	cerca(Vector2(-2.65,-1.8),Vector2(-1.9,-1.8))
	prop("Bag",Vector2(2.35,1.06),0.70,true)
	prop("FarmCrate_Empty",Vector2(2.35,-1.2),0.8,false)
	guardar("res://scenes/huerto_e10.tscn")
	quit(0 if errores==0 else 1)
