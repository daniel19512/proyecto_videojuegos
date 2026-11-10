extends SceneTree
## Autoría offline: solo laguna_bosque.tscn; ni terreno físico ni vegetación existente.
var region: Node3D
var laguna := Node3D.new()
var rng := RandomNumberGenerator.new()

func _initialize() -> void:
	call_deferred("construir")

func altura(p: Vector2) -> float:
	var q := PhysicsRayQueryParameters3D.create(Vector3(p.x,20,p.y),Vector3(p.x,-10,p.y))
	q.exclude = [region.get_node("Vegetacion/Obstaculos").get_rid(),region.get_node("Reservas/ReservaLagunaCerrada").get_rid()]
	var hit := region.get_world_3d().direct_space_state.intersect_ray(q)
	return hit.position.y

func nodo(nombre: String) -> Node3D:
	var n := Node3D.new()
	n.name = nombre
	laguna.add_child(n)
	return n

func agregar_modelo(padre: Node3D, ruta: String, p: Vector2, escala: float, sumergido: float = 0.0) -> void:
	assert(ResourceLoader.exists(ruta))
	var n: Node3D = load(ruta).instantiate()
	padre.add_child(n)
	var caja := AABB()
	var primera := true
	for m in n.find_children("*","MeshInstance3D",true,false):
		var b: AABB = n.global_transform.affine_inverse()*m.global_transform*m.get_aabb()
		caja = b if primera else caja.merge(b)
		primera = false
	n.scale = Vector3.ONE*escala
	n.rotation.y = rng.randf()*TAU
	n.position = Vector3(p.x,altura(p)-caja.position.y*escala-sumergido,p.y)
	n.set_meta("ruta_original",ruta)

func construir() -> void:
	rng.seed = 70422
	region = load("res://scenes/bosque.tscn").instantiate()
	root.add_child(region)
	await physics_frame
	await physics_frame
	laguna.name = "Laguna"
	root.add_child(laguna)
	laguna.set_meta("centro",Vector2(-29,22))
	laguna.set_meta("semiejes",Vector2(8,6))
	laguna.set_meta("cota_agua",-0.12)
	laguna.set_meta("semilla",70422)
	laguna.set_meta("barrera_existente","../Reservas/ReservaLagunaCerrada")
	var geometria := nodo("Geometria")
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 96:
		st.set_normal(Vector3.UP)
		st.add_vertex(Vector3(-29,-0.12,22))
		for k in [i,i+1]:
			var a: float = TAU*float(k)/96.0
			st.set_normal(Vector3.UP)
			st.add_vertex(Vector3(-29+cos(a)*8,-0.12,22+sin(a)*6))
	var agua := MeshInstance3D.new()
	agua.name = "Agua"
	agua.mesh = st.commit()
	var material := ShaderMaterial.new()
	material.shader = load("res://scripts/agua_laguna.gdshader")
	agua.material_override = material
	agua.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	geometria.add_child(agua)
	var orillas := nodo("DecoracionOrillas")
	for i in 42:
		var a := rng.randf()*TAU
		# Dejar despejada la aproximación oriental desde Z06.
		if cos(a)>0.78 or rng.randf()<0.20:
			continue
		var r := rng.randf_range(0.99,1.065)
		var p := Vector2(-29,22)+Vector2(cos(a)*8,sin(a)*6)*r
		if rng.randf()<0.32:
			agregar_modelo(orillas,"res://assets/naturaleza/glTF/Rock_Medium_1.gltf",p,rng.randf_range(0.19,0.32),0.025)
		else:
			agregar_modelo(orillas,"res://assets/naturaleza/glTF/Grass_Wispy_Tall.gltf",p,rng.randf_range(0.35,0.53))
	for par in [[Vector2(-33.2,17.2),"Fern_1",0.43],[Vector2(-31.5,28.2),"Fern_1",0.48],[Vector2(-25.4,27.8),"Flower_3_Group",0.23],[Vector2(-35.5,19.2),"Flower_4_Group",0.24]]:
		agregar_modelo(orillas,"res://assets/naturaleza/glTF/"+par[1]+".gltf",par[0],par[2])
	var detalles := nodo("DetallesAgua")
	var verde := StandardMaterial3D.new()
	verde.albedo_color = Color(0.24,0.39,0.15)
	verde.roughness = 0.85
	for p in [Vector2(-32,20),Vector2(-31.4,20.3),Vector2(-31.9,20.65),Vector2(-27,24),Vector2(-27.5,24.3),Vector2(-26.8,24.65)]:
		var hoja := MeshInstance3D.new()
		hoja.name = "Nenufar"+str(detalles.get_child_count()+1)
		var disco := CylinderMesh.new()
		disco.top_radius = rng.randf_range(0.19,0.30)
		disco.bottom_radius = disco.top_radius
		disco.height = 0.018
		disco.radial_segments = 9
		hoja.mesh = disco
		hoja.material_override = verde
		hoja.position = Vector3(p.x,-0.10,p.y)
		hoja.rotation.y = rng.randf()*TAU
		detalles.add_child(hoja)
	for n in laguna.find_children("*","",true,false):
		if n.owner==null:
			n.owner = laguna
	var escena := PackedScene.new()
	assert(escena.pack(laguna)==OK)
	assert(ResourceSaver.save(escena,"res://scenes/laguna_bosque.tscn")==OK)
	print("LAGUNA_GUARDADA: agua Y=-0.12; orillas ",orillas.get_child_count(),"; nenufares 6; colisiones existentes conservadas")
	laguna.free()
	quit()
