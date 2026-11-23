extends "res://scripts/editor/construir_interiores_aldea.gd"
## Autoría offline de E12. Solo escribe la escena del molino.
const ESCENA := "res://scenes/interiores/molino_e12.tscn"


func construir() -> void:
	var datos := {
		id = "E12", ancho = 6.0, fondo = 8.0, color = "#b2a28b",
		textil = "#887048", escena = ESCENA,
		aparicion = Vector3(-1.85, 0.07, 0), salida = Vector3(-2.35, 0, 0),
		direccion = "derecha", texto_salida = "[F] Salir del molino",
		recorrido = PackedVector3Array([
			Vector3(-1.85, 0, 0), Vector3(-1.65, 0, -2.55),
			Vector3(1.95, 0, -2.55), Vector3(1.95, 0, 1.25),
			Vector3(0.15, 0, 1.75), Vector3(-1.55, 0, 2.15)])
	}
	base_sala(datos)
	var ventana := OmniLight3D.new()
	ventana.position = Vector3(-2.65, 1.8, 2.16)
	ventana.omni_range = 3.9
	ventana.light_energy = 0.0
	agregar(ventana, raiz, "LuzVentana")
	mover_marco_oeste()
	maquinaria()
	almacen()
	finalizar(datos)
	quit()


func mover_marco_oeste() -> void:
	var sur := paredes.get_node("Sur")
	var oeste := paredes.get_node("Oeste")
	for nombre in ["HojaPuerta", "Jamba", "Jamba2", "Dintel"]:
		var parte := sur.get_node(nombre) as Node3D
		parte.reparent(oeste, false)
		parte.owner = raiz
		parte.position = Vector3(-parte.position.z + 1.0, parte.position.y, parte.position.x)
		parte.rotation_degrees.y = -90
	for nombre in ["Umbral", "Felpudo", "Rotulo"]:
		var parte := arquitectura.get_node(nombre) as Node3D
		parte.position = Vector3(-parte.position.z + 1.0, parte.position.y, parte.position.x)
		parte.rotation_degrees.y = -90
	# Vigas abiertas para dejar visible la maquinaria desde arriba.
	for z in [-3.65, 3.65]:
		caja(arquitectura, "VigaTransversal", Vector3(0, 2.65, z), Vector3(5.8, 0.2, 0.21), oscura)


func maquinaria() -> void:
	var transmision := Node3D.new()
	agregar(transmision, mobiliario, "Transmision")
	transmision.position = Vector3(0.52, 0, -0.55)
	transmision.set_script(load("res://scripts/interiores/transmision_molino.gd"))
	var hierro := material(Color("#3d4143"))
	var madera_diente := material(Color("#87623c"))
	piedra.albedo_texture = load("res://assets/aldea/glTF/T_Plaster_BaseColor.png")
	piedra.uv1_triplanar = true
	piedra.uv1_scale = Vector3(2, 2, 2)
	var base := transmision.position
	caja(mobiliario, "Bancada", base + Vector3(0, 0.45, 0), Vector3(1.69, 0.19, 1.53), madera)
	colision("ResguardoMuelas", base + Vector3(0, 0.55, 0), Vector3(1.75, 1.1, 1.65))
	for x in [-0.74, 0.74]:
		for z in [-0.67, 0.67]:
			caja(transmision, "Puntal", Vector3(x, 1.32, z), Vector3(0.14, 2.64, 0.14), oscura)
	caja(transmision, "TravesanoTolva", Vector3(0, 2.08, -0.57), Vector3(1.62, 0.14, 0.16), oscura)
	cilindro("MuelaFija", Vector3(0, 0.67, 0), 0.72, 0.26, piedra, transmision)
	var vertical := Node3D.new()
	agregar(vertical, transmision, "EjeVertical")
	cilindro("Husillo", Vector3(0, 1.62, 0), 0.105, 1.56, hierro, vertical)
	cilindro("MuelaMovil", Vector3(0, 0.94, 0), 0.70, 0.24, piedra, vertical)
	caja(vertical, "ChavetaVisible", Vector3(0.32, 1.065, 0), Vector3(0.37, 0.025, 0.09), hierro)
	engranaje(vertical, Vector3(0, 2.22, 0), 0.30, 12, madera_diente, hierro)

	var horizontal := Node3D.new()
	agregar(horizontal, transmision, "EjeHorizontal")
	# Mismo centro en altura y Z que la rueda en el exterior.
	horizontal.position = Vector3(0.37, 2.5, 0.55)
	var eje := cilindro("ArbolDeLaRueda", Vector3(1.02, 0, 0), 0.105, 2.3, oscura, horizontal)
	eje.rotation_degrees.z = 90
	var rueda := Node3D.new()
	agregar(rueda, horizontal, "RuedaMotriz")
	rueda.rotation_degrees.z = 90
	engranaje(rueda, Vector3.ZERO, 0.40, 16, madera_diente, hierro)
	caja(horizontal, "MarcaDelEje", Vector3(0.85, 0.10, 0), Vector3(1.23, 0.035, 0.075), madera_diente)
	var cojinete := cilindro("CojineteMural", Vector3(2.37, 2.5, 0.55), 0.23, 0.20, hierro, transmision)
	cojinete.rotation_degrees.z = 90

	var tolva := Node3D.new()
	agregar(tolva, transmision, "Tolva")
	tolva.position = Vector3(0, 1.83, -0.53)
	for i in 4:
		var lado := Node3D.new()
		agregar(lado, tolva, "Lado")
		lado.rotation.y = i * PI / 2
		var tabla := caja(lado, "TablaInclinada", Vector3(0, 0, 0.31), Vector3(0.89, 0.62, 0.075), madera)
		tabla.rotation_degrees.x = 29
		caja(lado, "Borde", Vector3(0, 0.27, 0.45), Vector3(0.99, 0.08, 0.08), oscura)
	var grano := material(Color("#bc934c"))
	caja(tolva, "Grano", Vector3(0, 0.03, 0), Vector3(0.56, 0.04, 0.56), grano)
	var caida := caja(transmision, "Conducto", Vector3(0, 1.34, -0.39), Vector3(0.24, 0.60, 0.23), oscura)
	caida.rotation_degrees.x = -31


func engranaje(padre: Node3D, centro: Vector3, radio: float, dientes: int,
		material_dientes: Material, metal: Material) -> void:
	cilindro("Disco", centro, radio, 0.13, madera, padre)
	cilindro("Cubo", centro, 0.13, 0.22, metal, padre)
	for i in dientes:
		var angulo := TAU * i / dientes
		var radial := Vector3(sin(angulo), 0, cos(angulo))
		var diente := caja(padre, "Diente", centro + radial * (radio + 0.025),
			Vector3(0.075, 0.11, 0.11), material_dientes)
		diente.rotation.y = angulo


func almacen() -> void:
	pieza("res://assets/objetos_medievales/glTF/Barrel.gltf", Vector3(-2.37, 0, -3.2), 0, true, 0.8)
	pieza("res://assets/objetos_medievales/glTF/Crate_Wooden.gltf", Vector3(2.24, 0, 3.1), 0, true, 0.8)
	pieza(comida("grain_sack"), Vector3(-1.42, 0, -3.34), 17, true)
	pieza(comida("grain_sack"), Vector3(-0.68, 0, -3.39), -27, true, 0.86)
	pieza(herramienta("basket"), Vector3(1.9, 0, -3.34), 15, true)
	pieza(mob("workbench"), Vector3(-1.68, 0, 3.36), 0, true)
	pieza(comida("scales"), Vector3(-1.48, 0.9, 3.29), 10, false, 0.8)
	pieza(herramienta("basket"), Vector3(-0.85, 0, 3.42), -12, true, 0.75)
	var lona := material(Color("#e1d8be"))
	for x in [0.35, 0.93]:
		var saco := MeshInstance3D.new()
		var malla := SphereMesh.new()
		malla.radial_segments = 9
		malla.rings = 5
		malla.radius = 0.31
		malla.height = 0.70
		malla.material = lona
		saco.mesh = malla
		saco.position = Vector3(x, 0.31, 3.24)
		saco.scale = Vector3(1, 1, 0.85)
		agregar(saco, mobiliario, "SacoHarina")
		cilindro("CuelloSaco", Vector3(x, 0.65, 3.24), 0.1, 0.13, lona)
		cilindro("Cordon", Vector3(x, 0.65, 3.24), 0.108, 0.035, oscura)
		colision("SacoHarina", Vector3(x, 0.33, 3.24), Vector3(0.5, 0.66, 0.5))
	for y in [0.65, 1.22, 1.8]:
		caja(mobiliario, "Anaquel", Vector3(2.57, y, -1.63), Vector3(0.53, 0.09, 1.17), madera)
	for z in [-2.17, -1.09]:
		caja(mobiliario, "PieAnaquel", Vector3(2.78, 0.92, z), Vector3(0.12, 1.85, 0.12), oscura)
	colision("Estanteria", Vector3(2.59, 0.92, -1.63), Vector3(0.54, 1.85, 1.17))
	pieza(herramienta("basket"), Vector3(2.52, 1.27, -1.6), 0, false, 0.6)
