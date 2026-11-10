extends SceneTree
## Fase 6A.0: inspección/capturas aisladas. Nunca abre el mundo del juego.
const BASE := "res://logs/seleccion_assets_bosque/"
var salida: String
var registros: Array = []
var escena: Node3D
var modelos: Node3D
var camara: Camera3D
var rotulos: Control
var fallos := 0
var general := false

func _initialize() -> void:
	call_deferred("ejecutar")

func archivos(carpeta: String) -> Array[String]:
	var lista: Array[String] = []
	for n in DirAccess.get_files_at(carpeta):
		if n.get_extension().to_lower() in ["gltf", "glb", "fbx", "obj"]: lista.append(carpeta.path_join(n))
	for n in DirAccess.get_directories_at(carpeta): lista.append_array(archivos(carpeta.path_join(n)))
	lista.sort(); return lista

func paquete(ruta: String) -> String:
	if "kaykit_forest" in ruta: return "KayKit"
	if "forest_nature_updated" in ruta: return "Forest Nature Updated"
	if "/naturaleza/" in ruta: return "Quaternius Nature"
	if "/objetos_medievales/" in ruta: return "Quaternius Props"
	return "Quaternius Village"

func grupo(ruta: String) -> String:
	var n := ruta.get_file().get_basename()
	if "Bare" in n or "DeadTree" in n or "Stump" in n or "Log" in n: return "03_secos_troncos"
	if "Tree" in n or "Pine" in n: return "01_arboles"
	if "Bush" in n: return "02_arbustos"
	if "Rock" in n or "Boulder" in n or "Pebble" in n or "Ground" in n: return "05_rocas_terreno"
	if paquete(ruta) in ["KayKit", "Forest Nature Updated", "Quaternius Nature"]: return "04_plantas"
	return "06_objetos"

func medir(nodo: Node, anterior: Transform3D, datos: Dictionary) -> void:
	var t := anterior
	if nodo is Node3D: t = anterior * nodo.transform
	if nodo is MeshInstance3D and nodo.mesh:
		var caja: AABB = t * nodo.mesh.get_aabb()
		datos.caja = datos.caja.merge(caja) if datos.has("caja") else caja
		datos.mallas += 1
		for s in nodo.mesh.get_surface_count():
			datos.superficies += 1
			var material = nodo.get_active_material(s)
			if material == null: datos.sin_material += 1
			elif material is BaseMaterial3D:
				var texturas := []
				for slot in [BaseMaterial3D.TEXTURE_ALBEDO, BaseMaterial3D.TEXTURE_NORMAL, BaseMaterial3D.TEXTURE_METALLIC, BaseMaterial3D.TEXTURE_ROUGHNESS]:
					var textura = material.get_texture(slot)
					if textura and not textura.resource_path in texturas: texturas.append(textura.resource_path)
				var info := {"nombre": material.resource_name, "texturas": texturas, "color": str(material.albedo_color), "vertex_color": material.vertex_color_use_as_albedo, "cull_mode": material.cull_mode, "transparencia": material.transparency}
				if not info in datos.materiales: datos.materiales.append(info)
			var a: Array = nodo.mesh.surface_get_arrays(s)
			if a.size() > Mesh.ARRAY_INDEX:
				if a[Mesh.ARRAY_INDEX] != null and a[Mesh.ARRAY_INDEX].size() > 0: datos.triangulos += int(a[Mesh.ARRAY_INDEX].size()/3)
				elif a[Mesh.ARRAY_VERTEX] != null: datos.triangulos += int(a[Mesh.ARRAY_VERTEX].size()/3)
	for hijo in nodo.get_children(): medir(hijo, t, datos)

func instanciar(ruta: String) -> Node3D:
	var recurso = load(ruta)
	if recurso is PackedScene: return recurso.instantiate()
	if recurso is Mesh:
		var nodo := MeshInstance3D.new(); nodo.mesh = recurso; return nodo
	return null

func ejecutar() -> void:
	salida = BASE + Time.get_datetime_string_from_system().replace(":", "-") + "/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(salida))
	print("VERSION: ",Engine.get_version_info().string)
	var argumentos := OS.get_cmdline_user_args()
	var manifest: Array = []
	if argumentos.size() > 0: manifest = JSON.parse_string(FileAccess.get_file_as_string(argumentos[0]))
	var rutas: Array[String] = []
	if manifest.is_empty(): rutas = archivos("res://assets")
	for item in manifest: rutas.append(item.ruta.replace("RPG/", "res://"))
	for ruta in rutas:
		var r := {"ruta": ruta.replace("res://", "RPG/"), "nombre": ruta.get_file().get_basename(), "paquete": paquete(ruta), "grupo": grupo(ruta), "importa": false}
		var nodo := instanciar(ruta)
		if nodo:
			var datos := {"mallas": 0, "superficies": 0, "triangulos": 0, "sin_material": 0, "materiales": []}
			medir(nodo, Transform3D.IDENTITY, datos)
			r.importa = datos.has("caja") and datos.sin_material == 0
			if datos.has("caja"):
				var caja: AABB = datos.caja
				r.dimensiones = [caja.size.x,caja.size.y,caja.size.z]; r.minimo = [caja.position.x,caja.position.y,caja.position.z]
				datos.erase("caja")
			r.merge(datos)
			nodo.free()
		if not r.importa: fallos += 1
		if not manifest.is_empty():
			for item in manifest:
				if item.ruta == r.ruta: r.merge(item,true); break
		registros.append(r)
	FileAccess.open(salida+"mediciones.json", FileAccess.WRITE).store_string(JSON.stringify(registros,"\t"))
	if DisplayServer.get_name() == "headless":
		print("RESULTADO: ",registros.size()," recursos; fallos=",fallos,"; ",salida); quit(0 if fallos==0 else 1); return
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.content_scale_size = Vector2i.ZERO
	root.content_scale_factor = 1.0
	root.size = Vector2i(1800,1100)
	entorno()
	var grupos := {}
	for r in registros:
		var clave: String = r.get("seccion", r.grupo+"_"+r.paquete.replace(" ","_"))
		if not grupos.has(clave): grupos[clave] = []
		grupos[clave].append(r)
	var claves: Array = grupos.keys(); claves.sort()
	var html := "<!doctype html><meta charset='utf-8'><title>Selección bosque 6A.0</title><style>body{font:18px system-ui;background:#22282a;color:#eee;margin:30px}img{width:100%;max-width:1800px}a{color:#bce5ca}</style><h1>Selección de assets del bosque · 6A.0</h1><p>Capturas reales en Godot 4.7.2. Paneles normalizados para inspección; medidas fuente y escala de uso propuestas indicadas. No es la región construida.</p>"
	for clave in claves:
		var lista: Array = grupos[clave]
		for inicio in range(0,lista.size(),6):
			limpiar()
			camara.position = Vector3(7,22,30); camara.look_at(Vector3(7,1,5.25)); camara.size = 21
			for i in range(inicio,mini(inicio+6,lista.size())):
				var local := i-inicio
				colocar(lista[i],Vector3((local%3)*7,0,(local/3)*10.5),true)
				var r: Dictionary = lista[i]; var d: Array = r.dimensiones
				var texto: String = r.get("id","")+" "+r.nombre+"\n"+r.paquete+"\nFuente %.2f × %.2f × %.2f" % [d[0],d[1],d[2]]
				if r.has("escala"): texto += "\nEscala propuesta ×%.2f" % r.escala
				var ancla := camara.unproject_position(Vector3((local%3)*7,0,(local/3)*10.5+2.5))
				etiqueta_ui(texto,ancla+Vector2(-175,0),Vector2(350,95),17)
			etiqueta_ui(clave+" · "+str(inicio+1)+"–"+str(mini(inicio+6,lista.size())),Vector2(30,15),Vector2(1740,55),26)
			var archivo: String = clave+"_"+str(inicio/6+1)+".png"
			await captura(archivo)
			html += "<h2>"+clave+"</h2><a href='"+archivo+"'><img loading='lazy' src='"+archivo+"'></a>"
	if not manifest.is_empty() and manifest[0].has("seccion"):
		for clave in claves:
			limpiar()
			var r: Dictionary = grupos[clave][0]
			colocar(r,Vector3.ZERO,true)
			for grados in [0,90,180,270]:
				for hijo in rotulos.get_children(): hijo.free()
				var objetivo := Vector3(0,1.5,0)
				var angulo := deg_to_rad(float(grados))
				camara.position = objetivo+Vector3(sin(angulo)*11,7,cos(angulo)*11)
				camara.look_at(objetivo); camara.size = 7
				etiqueta_ui("Orbita "+str(grados)+"° · "+r.id+" "+r.nombre+" · "+r.paquete,Vector2(30,20),Vector2(1740,50),24)
				var archivo: String = "orbita_"+r.id+"_"+str(grados)+".png"
				await captura(archivo)
				html += "<h2>Órbita "+r.id+" · "+str(grados)+"°</h2><img loading='lazy' src='"+archivo+"'>"
	limpiar()
	general = true
	var g := 0
	for clave in claves:
		var i := 0
		for r in grupos[clave]:
			colocar(r,Vector3((g%3)*48+(i%6)*7,0,(g/3)*48+(i/6)*9),true)
			i += 1
		g += 1
	var centro := Vector3(69,0,24+int((g-1)/3)*24)
	camara.position = centro+Vector3(0,100,120); camara.look_at(centro); camara.size = maxf(115,ceilf(g/3.0)*48)
	await captura("vista_general.png")
	html += "<h2>Vista general del catálogo normalizado</h2><img src='vista_general.png'>"
	for hijo in escena.get_children(): hijo.owner = escena
	for hijo in modelos.get_children(): hijo.owner = escena
	var packed := PackedScene.new(); packed.pack(escena)
	var guardado := ResourceSaver.save(packed,salida+"catalogo_temporal.tscn")
	var recargada: PackedScene = load(salida+"catalogo_temporal.tscn")
	var copia := recargada.instantiate()
	var cuenta := copia.get_node("Modelos").get_child_count(); copia.free()
	print("CATALOGO: guardado=",guardado,"; elementos_recargados=",cuenta)
	FileAccess.open(salida+"galeria.html",FileAccess.WRITE).store_string(html)
	print("RESULTADO: ",registros.size()," recursos; fallos=",fallos,"; ",salida)
	quit(0 if fallos==0 and guardado==OK else 1)

func entorno() -> void:
	escena = Node3D.new(); escena.name = "ExhibicionBosque6A0"; root.add_child(escena)
	modelos = Node3D.new(); modelos.name = "Modelos"; escena.add_child(modelos)
	rotulos = Control.new(); root.add_child(rotulos)
	var ambiente := WorldEnvironment.new(); ambiente.environment = Environment.new()
	ambiente.environment.background_mode = Environment.BG_COLOR; ambiente.environment.background_color = Color(.28,.31,.33)
	ambiente.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR; ambiente.environment.ambient_light_color = Color.WHITE; ambiente.environment.ambient_light_energy = .65; escena.add_child(ambiente)
	var luz := DirectionalLight3D.new(); luz.rotation_degrees = Vector3(-50,-30,0); luz.light_energy = 1.1; luz.shadow_enabled = true; escena.add_child(luz)
	var suelo := MeshInstance3D.new(); var plano := PlaneMesh.new(); plano.size = Vector2(2000,2000); suelo.mesh = plano; suelo.position.y = -.04
	var m := StandardMaterial3D.new(); m.albedo_color = Color(.35,.38,.37); m.roughness = 1; suelo.material_override = m; escena.add_child(suelo)
	camara = Camera3D.new(); camara.projection = Camera3D.PROJECTION_ORTHOGONAL; camara.far = 2000; escena.add_child(camara); camara.current = true

func limpiar() -> void:
	for hijo in modelos.get_children(): hijo.free()
	for hijo in rotulos.get_children(): hijo.free()

func colocar(r: Dictionary, sitio: Vector3, normalizar: bool) -> void:
	if not r.importa: return
	var contenedor := Node3D.new(); contenedor.name = r.get("id",r.nombre)
	contenedor.set_meta("ruta_original",r.ruta); contenedor.set_meta("paquete",r.paquete); contenedor.set_meta("dimensiones_fuente",r.dimensiones)
	contenedor.position = sitio; modelos.add_child(contenedor)
	var instancia := instanciar(r.ruta.replace("RPG/","res://"))
	var d: Array = r.dimensiones; var p: Array = r.minimo
	var factor: float = 4.0/maxf(d[0],maxf(d[1],d[2])) if normalizar else float(r.get("escala",1))
	# Conservar la traslación fuente del nodo raíz antes de compensar su AABB.
	# Algunos GLB no tienen la raíz en el origen de su geometría.
	instancia.position = (instancia.position-Vector3(p[0]+d[0]*.5,p[1],p[2]+d[2]*.5))*factor
	instancia.scale *= factor
	var comprobacion := {"mallas": 0, "superficies": 0, "triangulos": 0, "sin_material": 0, "materiales": []}
	medir(instancia,Transform3D.IDENTITY,comprobacion)
	if absf(comprobacion.caja.position.y) > .001:
		fallos += 1; push_error("Apoyo incorrecto en catálogo: "+r.nombre)
	contenedor.add_child(instancia); instancia.owner = escena
	var rotulo := Label3D.new(); rotulo.text = r.get("id","")+" "+r.nombre+"\n"+r.paquete
	rotulo.visible = general
	rotulo.font_size = 64; rotulo.pixel_size = .004; rotulo.billboard = BaseMaterial3D.BILLBOARD_ENABLED; rotulo.no_depth_test = true; rotulo.position = Vector3(0,0,3)
	contenedor.add_child(rotulo); rotulo.owner = escena

func etiqueta_ui(texto: String, sitio: Vector2, tamano: Vector2, fuente: int) -> void:
	var label := Label.new(); label.text = texto; label.position = sitio; label.size = tamano; label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size",fuente); label.add_theme_color_override("font_outline_color",Color.BLACK); label.add_theme_constant_override("outline_size",6); rotulos.add_child(label)

func captura(nombre: String) -> void:
	for i in 10: await process_frame
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png(salida+nombre)
	if error != OK: fallos += 1
	print("CAPTURA: ",nombre,"; error=",error)
