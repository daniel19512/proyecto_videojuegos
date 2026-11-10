extends Node3D
## Laboratorio aislado: escala fuente, apoyo corregido solo en la instancia.
var rutas: Array[String] = []
var indice := 0
var expositor: Node3D
var camara: Camera3D
var titulo: Label
var jugadores_animacion: Array[AnimationPlayer] = []

func _ready() -> void:
	for carpeta in ["res://assets/granja/Farm_Harvest/glTF", "res://assets/granja/animales/FBX"]:
		for archivo in DirAccess.get_files_at(carpeta):
			if archivo.get_extension().to_lower() in ["glb", "fbx"]: rutas.append(carpeta.path_join(archivo))
	rutas.sort()
	var ambiente := WorldEnvironment.new()
	ambiente.environment = Environment.new()
	ambiente.environment.background_mode = Environment.BG_COLOR
	ambiente.environment.background_color = Color(.19,.23,.27)
	ambiente.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	ambiente.environment.ambient_light_color = Color(.72,.77,.85)
	ambiente.environment.ambient_light_energy = .6
	add_child(ambiente)
	var luz := DirectionalLight3D.new()
	luz.rotation_degrees = Vector3(-55,-30,0)
	luz.light_color = Color(1,.89,.72)
	luz.light_energy = 1.2
	luz.shadow_enabled = true
	add_child(luz)
	var suelo := MeshInstance3D.new()
	var plano := PlaneMesh.new()
	plano.size = Vector2(200,200)
	suelo.mesh = plano
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(.38,.42,.34)
	material.roughness = 1
	suelo.material_override = material
	suelo.position.y = -.02
	add_child(suelo)
	var protagonista = load("res://scenes/jugador.tscn").instantiate()
	protagonista.process_mode = Node.PROCESS_MODE_DISABLED
	protagonista.position = Vector3(-3,0,0)
	add_child(protagonista)
	var objetivo := Node3D.new()
	add_child(objetivo)
	camara = Camera3D.new()
	camara.set_script(load("res://scripts/camara_orbital.gd"))
	camara.objetivo = objetivo
	camara.position = Vector3(0,13.8,20.80435)
	camara.projection = Camera3D.PROJECTION_ORTHOGONAL
	camara.size = 15
	camara.far = 300
	add_child(camara)
	camara.current = true
	expositor = Node3D.new()
	add_child(expositor)
	var ui := CanvasLayer.new()
	add_child(ui)
	var panel := VBoxContainer.new()
	panel.position = Vector2(20,20)
	ui.add_child(panel)
	titulo = Label.new()
	titulo.add_theme_font_size_override("font_size",22)
	panel.add_child(titulo)
	var instrucciones := Label.new()
	instrucciones.text = "Escala fuente 1; protagonista original. Q/E: orbita. RePag/AvPag: modelo.\nAnimaciones importadas: vista previa local, sin IA ni movimiento regional."
	panel.add_child(instrucciones)
	var botones := HBoxContainer.new()
	panel.add_child(botones)
	for texto in ["Anterior", "Siguiente", "Animacion siguiente / pausa"]:
		var boton := Button.new()
		boton.text = texto
		boton.focus_mode = Control.FOCUS_NONE
		botones.add_child(boton)
		if texto == "Anterior": boton.pressed.connect(func(): mostrar(posmod(indice-1,rutas.size())))
		elif texto == "Siguiente": boton.pressed.connect(func(): mostrar((indice+1)%rutas.size()))
		else: boton.pressed.connect(animar)
	mostrar(0)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_PAGEDOWN: mostrar((indice+1)%rutas.size())
		if event.keycode == KEY_PAGEUP: mostrar(posmod(indice-1,rutas.size()))

static func inspeccionar(nodo: Node, transformacion: Transform3D, datos: Dictionary) -> void:
	var t := transformacion
	if nodo is Node3D: t *= nodo.transform
	if nodo is MeshInstance3D and nodo.mesh:
		var caja: AABB = t * nodo.mesh.get_aabb()
		if nodo.is_inside_tree() and not nodo.skeleton.is_empty() and nodo.get_node_or_null(nodo.skeleton) is Skeleton3D:
			var esqueleto: Skeleton3D = nodo.get_node(nodo.skeleton)
			esqueleto.force_update_all_bone_transforms()
			# Medir vertices deformados en CPU: funciona tambien sin RenderingServer grafico.
			var primero := true
			var piel: Skin = nodo.skin
			if piel:
				for superficie in nodo.mesh.get_surface_count():
					var arrays: Array = nodo.mesh.surface_get_arrays(superficie)
					var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
					var huesos: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
					var pesos: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
					var influencias := huesos.size()/vertices.size()
					for v in vertices.size():
						var punto := Vector3.ZERO
						for j in influencias:
							var k: int = v*influencias+j
							if pesos[k] == 0: continue
							var bind: int = huesos[k]
							var bone := piel.get_bind_bone(bind)
							if not piel.get_bind_name(bind).is_empty(): bone = esqueleto.find_bone(piel.get_bind_name(bind))
							punto += (esqueleto.get_bone_global_pose(bone)*piel.get_bind_pose(bind)*vertices[v])*pesos[k]
						punto = t * nodo.global_transform.affine_inverse() * esqueleto.global_transform * punto
						if primero: caja = AABB(punto,Vector3.ZERO); primero = false
						else: caja = caja.expand(punto)
		datos.caja = datos.caja.merge(caja) if datos.has("caja") else caja
		datos.mallas += 1
		for s in nodo.mesh.get_surface_count():
			var mat = nodo.get_active_material(s)
			if not mat: datos.sin_material += 1
			elif mat is BaseMaterial3D:
				datos.materiales.append({"nombre":mat.resource_name,"color":mat.albedo_color.to_html(),"textura":mat.albedo_texture.resource_path if mat.albedo_texture else "sin textura", "vertex_color":mat.vertex_color_use_as_albedo})
	if nodo is Skeleton3D: datos.huesos += nodo.get_bone_count()
	if nodo is AnimationPlayer:
		for nombre in nodo.get_animation_list():
			var animacion: Animation = nodo.get_animation(nombre)
			datos.animaciones.append({"nombre":nombre,"duracion":animacion.length,"pistas":animacion.get_track_count(),"loop":animacion.loop_mode})
	for hijo in nodo.get_children(): inspeccionar(hijo,t,datos)

static func datos_modelo(nodo: Node) -> Dictionary:
	var datos := {"mallas":0,"sin_material":0,"materiales":[],"huesos":0,"animaciones":[]}
	inspeccionar(nodo,Transform3D.IDENTITY,datos)
	return datos

func mostrar(nuevo: int) -> void:
	indice = nuevo
	jugadores_animacion.clear()
	for hijo in expositor.get_children(): hijo.free()
	var instancia = load(rutas[indice]).instantiate()
	expositor.add_child(instancia)
	buscar_animadores(instancia)
	for animador in jugadores_animacion:
		if animador.has_animation("Armature|Idle"):
			animador.play("Armature|Idle")
			animador.seek(0,true)
			animador.pause()
	var datos := datos_modelo(instancia)
	var caja: AABB = datos.caja
	instancia.position -= Vector3(caja.get_center().x,caja.position.y,caja.get_center().z)
	titulo.text = "%d/%d %s | X/Y/Z %.3f / %.3f / %.3f m" % [indice+1,rutas.size(),rutas[indice].get_file(),caja.size.x,caja.size.y,caja.size.z]

func buscar_animadores(nodo: Node) -> void:
	if nodo is AnimationPlayer: jugadores_animacion.append(nodo)
	for hijo in nodo.get_children(): buscar_animadores(hijo)

func animar() -> void:
	for animador in jugadores_animacion:
		var lista := animador.get_animation_list()
		if lista.is_empty(): continue
		var actual := lista.find(animador.current_animation)
		if actual+1 >= lista.size(): animador.stop()
		else: animador.play(lista[actual+1])
