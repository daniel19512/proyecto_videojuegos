extends SceneTree
## Auditoría aislada: no abre el mundo ni modifica recursos fuente.
const BASE := "res://logs/auditoria_assets_bosque/"
var salida: String
var registros: Array = []
var escenario: Node3D
var expositor: Node3D
var camara: Camera3D

func _initialize() -> void:
	call_deferred("ejecutar")

func archivos(carpeta: String) -> Array[String]:
	var resultado: Array[String] = []
	for nombre in DirAccess.get_files_at(carpeta):
		if nombre.get_extension() in ["gltf", "glb"]: resultado.append(carpeta.path_join(nombre))
	for nombre in DirAccess.get_directories_at(carpeta):
		resultado.append_array(archivos(carpeta.path_join(nombre)))
	resultado.sort()
	return resultado

func categoria(nombre: String, ruta: String) -> String:
	if nombre.begins_with("CommonTree") or nombre.begins_with("TwistedTree"): return "01_hoja_ancha"
	if nombre.begins_with("Pine"): return "02_coniferas"
	if nombre.begins_with("DeadTree"): return "03_secos_troncos"
	if nombre.begins_with("Bush"): return "04_arbustos"
	if "naturaleza" in ruta:
		if nombre.begins_with("Rock") or nombre.begins_with("Pebble"): return "06_rocas"
		return "05_plantas"
	if nombre.begins_with("Prop_Vine"): return "05_plantas"
	if nombre in ["Roof_Log", "Prop_Support", "Roof_FrontSupports", "Roof_Support2"]: return "07_madera"
	if "Fence" in nombre: return "08_estructuras"
	if nombre in ["Bag", "Barrel", "Bench", "Bucket_Wooden_1", "Bucket_Metal", "Cauldron", "Chest_Wood", "Crate_Wooden", "FarmCrate_Empty", "Lantern_Wall", "Mug", "Pot_1", "Pot_1_Lid", "Pouch_Large", "Rope_1", "Rope_2", "Rope_3", "Stool", "Table_Large", "Torch_Metal", "Axe_Bronze", "Prop_Crate", "Prop_Wagon", "Candle_1", "Candle_2"]: return "09_campamento"
	if nombre.begins_with("Prop_Brick") or nombre.begins_with("Vase") or nombre in ["Wall_Arch", "Wall_UnevenBrick_Straight", "Wall_UnevenBrick_Door_Round", "Floor_UnevenBrick", "Stairs_Exterior_Straight", "Corner_Exterior_Brick", "Corner_ExteriorWide_Brick"]: return "10_ruinas"
	return "00_no_prioritario"

func medir(nodo: Node, transformacion: Transform3D, datos: Dictionary) -> void:
	var transformada := transformacion
	if nodo is Node3D: transformada = transformacion * nodo.transform
	if nodo is MeshInstance3D and nodo.mesh:
		var caja: AABB = transformada * nodo.mesh.get_aabb()
		if datos.has("caja"): datos.caja = datos.caja.merge(caja)
		else: datos.caja = caja
		for s in nodo.mesh.get_surface_count():
			datos.superficies += 1
			var material = nodo.get_active_material(s)
			if material is BaseMaterial3D:
				datos.materiales_importados[material.resource_name] = {"vertex_color": material.vertex_color_use_as_albedo, "transparencia": material.transparency, "cull_mode": material.cull_mode, "albedo": material.albedo_texture.resource_path if material.albedo_texture else "color"}
			var arrays: Array = nodo.mesh.surface_get_arrays(s)
			if arrays.size() > Mesh.ARRAY_INDEX:
				var indices = arrays[Mesh.ARRAY_INDEX]
				if indices != null and indices.size() > 0: datos.triangulos += indices.size() / 3
				elif arrays[Mesh.ARRAY_VERTEX] != null: datos.triangulos += arrays[Mesh.ARRAY_VERTEX].size() / 3
	for hijo in nodo.get_children(): medir(hijo, transformada, datos)

func ejecutar() -> void:
	salida = BASE + Time.get_datetime_string_from_system().replace(":", "-") + "/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(salida))
	print("VERSION: ", Engine.get_version_info().string)
	for ruta in archivos("res://assets"):
		var nombre := ruta.get_file().get_basename()
		var registro := {"nombre": nombre, "ruta": ruta.replace("res://", "RPG/"), "categoria": categoria(nombre, ruta), "importa": false, "triangulos": 0, "superficies": 0}
		var recurso = load(ruta)
		if recurso is PackedScene:
			var instancia = recurso.instantiate()
			var datos := {"triangulos": 0, "superficies": 0, "materiales_importados": {}}
			medir(instancia, Transform3D.IDENTITY, datos)
			registro.importa = datos.has("caja")
			registro.triangulos = datos.triangulos
			registro.superficies = datos.superficies
			registro.materiales_importados = datos.materiales_importados
			if datos.has("caja"):
				var caja: AABB = datos.caja
				registro.dimensiones = [caja.size.x, caja.size.y, caja.size.z]
				registro.minimo = [caja.position.x, caja.position.y, caja.position.z]
			instancia.free()
		var json = JSON.parse_string(FileAccess.get_file_as_string(ruta))
		registro.materiales = json.get("materials", [])
		registro.imagenes = json.get("images", [])
		registros.append(registro)
	FileAccess.open(salida + "mediciones.json", FileAccess.WRITE).store_string(JSON.stringify(registros, "\t"))
	if DisplayServer.get_name() == "headless":
		print("AUDITORIA: ", registros.size(), " modelos; salida ", salida)
		quit(); return
	root.size = Vector2i(1600, 1000)
	construir_entorno()
	var grupos := {}
	for r in registros:
		if not grupos.has(r.categoria): grupos[r.categoria] = []
		grupos[r.categoria].append(r)
	var html := "<!doctype html><meta charset='utf-8'><title>Auditoria bosque</title><style>body{background:#25292b;color:#eee;font:18px sans-serif;margin:30px}img{width:100%;max-width:1600px}a{color:#bde3ba}</style><h1>Auditoria visual de assets del bosque</h1><p>Vistas normalizadas por pieza; medidas reales en mediciones.json e informe. Se incluyen piezas no prioritarias para contrastar la selección.</p>"
	var orden: Array = grupos.keys(); orden.sort()
	for grupo in orden:
		var lista: Array = grupos[grupo]
		for inicio in range(0, lista.size(), 12):
			limpiar()
			for i in range(inicio, mini(inicio + 12, lista.size())):
				colocar(lista[i], Vector3(((i-inicio)%4)*6, 0, ((i-inicio)/4)*7), true)
			camara.position = Vector3(9, 24, 35)
			camara.look_at(Vector3(9, 0, 7)); camara.size = 28
			var titulo := Label.new()
			titulo.text = grupo + " — " + str(inicio+1) + " a " + str(mini(inicio+12,lista.size())) + " | tamaño visual normalizado"
			titulo.add_theme_font_size_override("font_size", 28)
			titulo.position = Vector2(25,20); escenario.add_child(titulo)
			var archivo: String = grupo + "_" + str(inicio/12+1) + ".png"
			await captura(archivo)
			titulo.free()
			html += "<h2>" + grupo + "</h2><a href='"+archivo+"'><img loading='lazy' src='"+archivo+"'></a>"
	limpiar()
	var indice := 0
	var fila := 0
	for grupo in orden:
		if grupo == "00_no_prioritario": continue
		var columna := 0
		for r in grupos[grupo]:
			colocar(r, Vector3(columna*18, 0, fila*20), false)
			indice += 1; columna += 1
			if columna == 12: columna = 0; fila += 1
		if columna > 0: fila += 1
		fila += 1
	camara.position = Vector3(99,450,fila*10+350); camara.look_at(Vector3(99,0,fila*10)); camara.size = fila*20; camara.far = 1500
	await captura("vista_general.png")
	var empaquetada := PackedScene.new()
	for hijo in escenario.get_children(): hijo.owner = escenario
	for hijo in expositor.get_children(): hijo.owner = escenario
	empaquetada.pack(escenario)
	ResourceSaver.save(empaquetada, salida+"catalogo_temporal.tscn")
	html += "<h2>Vista general a escala fuente 1</h2><img src='vista_general.png'>"
	FileAccess.open(salida+"galeria.html",FileAccess.WRITE).store_string(html)
	print("AUDITORIA: ",registros.size()," modelos; utiles ",indice,"; salida ",salida)
	quit()

func construir_entorno() -> void:
	escenario = Node3D.new(); escenario.name = "CatalogoBosqueTemporal"; root.add_child(escenario)
	expositor = Node3D.new(); expositor.name = "ModelosEtiquetados"; escenario.add_child(expositor)
	var ambiente := WorldEnvironment.new(); ambiente.environment = Environment.new()
	ambiente.environment.background_mode = Environment.BG_COLOR; ambiente.environment.background_color = Color(.30,.33,.36)
	ambiente.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	ambiente.environment.ambient_light_color = Color.WHITE; ambiente.environment.ambient_light_energy = .65
	escenario.add_child(ambiente)
	var luz := DirectionalLight3D.new(); luz.rotation_degrees = Vector3(-50,-25,0); luz.light_energy = 1.2; luz.shadow_enabled = true; escenario.add_child(luz)
	var suelo := MeshInstance3D.new(); var plano := PlaneMesh.new(); plano.size = Vector2(600,600); suelo.mesh = plano
	var material := StandardMaterial3D.new(); material.albedo_color = Color(.43,.44,.43); material.roughness = 1; suelo.material_override = material; suelo.position = Vector3(100,-.04,100); escenario.add_child(suelo)
	camara = Camera3D.new(); camara.projection = Camera3D.PROJECTION_ORTHOGONAL; camara.far = 600; escenario.add_child(camara); camara.current = true

func limpiar() -> void:
	for hijo in expositor.get_children(): hijo.free()

func colocar(r: Dictionary, lugar: Vector3, normalizado: bool) -> void:
	if not r.importa: return
	var instancia = load(r.ruta.replace("RPG/", "res://")).instantiate()
	var d: Array = r.dimensiones; var m: Array = r.minimo
	var factor: float = 3.8 / maxf(d[0], maxf(d[1], d[2])) if normalizado else 1.0
	instancia.scale *= factor
	instancia.position = lugar - Vector3(m[0]+d[0]/2, m[1], m[2]+d[2]/2)*factor
	expositor.add_child(instancia)
	var etiqueta := Label3D.new(); etiqueta.text = r.nombre + "\n%.2f × %.2f × %.2f" % [d[0],d[1],d[2]]
	etiqueta.font_size = 70; etiqueta.pixel_size = .006 if normalizado else .018
	etiqueta.billboard = BaseMaterial3D.BILLBOARD_ENABLED; etiqueta.no_depth_test = true
	etiqueta.position = lugar + Vector3(0,-.10,2.5 if normalizado else 7)
	expositor.add_child(etiqueta)

func captura(nombre: String) -> void:
	for i in 8: await process_frame
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png(salida+nombre)
	print("CAPTURA ",nombre," ",error)
