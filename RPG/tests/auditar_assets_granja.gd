extends SceneTree
const Galeria = preload("res://scripts/galeria_granja.gd")
var salida: String
var fallos := 0
var html := "<!doctype html><meta charset='utf-8'><title>Auditoria granja 6E.0</title><style>body{font:18px sans-serif;background:#20282e;color:#eee;margin:30px}img{width:100%;max-width:1200px}a{color:#afd9ff}</style><h1>Granja y animales — 6E.0</h1><p>Escala fuente 1 y protagonista original; camara ortografica 15, inclinacion habitual. Acercamientos separados para piezas diminutas. La aprobacion visual corresponde al usuario.</p>"

func _initialize() -> void:
	call_deferred("ejecutar")

func ejecutar() -> void:
	salida = "res://logs/auditoria_assets_granja/" + Time.get_datetime_string_from_system().replace(":","-") + "_" + str(Time.get_ticks_msec()) + "/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(salida))
	var registros: Array = []
	for carpeta in ["res://assets/granja/Farm_Harvest/glTF", "res://assets/granja/Farm_Harvest/FBX", "res://assets/granja/animales/FBX", "res://assets/granja/animales/OBJ"]:
		for archivo in DirAccess.get_files_at(carpeta):
			if not archivo.get_extension().to_lower() in ["glb","fbx","obj"]: continue
			var ruta: String = carpeta.path_join(archivo)
			var recurso = load(ruta)
			var nodo: Node
			if recurso is PackedScene: nodo = recurso.instantiate()
			elif recurso is Mesh:
				nodo = MeshInstance3D.new()
				nodo.mesh = recurso
			if nodo:
				root.add_child(nodo)
				await process_frame
			var datos: Dictionary = Galeria.datos_modelo(nodo) if nodo else {}
			datos.ruta = ruta.replace("res://","RPG/")
			datos.importa = datos.has("caja") and datos.get("sin_material",1) == 0
			if datos.has("caja"):
				var caja: AABB = datos.caja
				datos.dimensiones_xyz = [caja.size.x,caja.size.y,caja.size.z]
				datos.minimo_xyz = [caja.position.x,caja.position.y,caja.position.z]
				datos.erase("caja")
			if not datos.importa: fallos += 1
			registros.append(datos)
			if nodo: nodo.free()
	FileAccess.open(salida+"mediciones.json",FileAccess.WRITE).store_string(JSON.stringify({"motor":Engine.get_version_info().string,"fallos":fallos,"formatos":registros},"\t"))
	print("FORMATOS: ",registros.size()," FALLOS: ",fallos," SALIDA: ",salida)
	if DisplayServer.get_name() == "headless": quit(fallos); return
	root.size = Vector2i(1600,1000)
	var galeria = load("res://scenes/pruebas_granja.tscn").instantiate()
	root.add_child(galeria)
	for i in galeria.rutas.size():
		galeria.mostrar(i)
		galeria.camara.set_process(false)
		var nombre: String = galeria.rutas[i].get_file().get_basename()
		html += "<h2>"+nombre+"</h2>"
		for angulo in [0,90,180,270]:
			galeria.camara.size = 15
			galeria.camara.position = Vector3(0,13.8,20.80435).rotated(Vector3.UP,deg_to_rad(angulo))
			galeria.camara.look_at(Vector3(0,.8,0))
			await captura(nombre+"_"+str(angulo)+".png")
		var datos: Dictionary = Galeria.datos_modelo(galeria.expositor.get_child(0))
		var caja: AABB = datos.caja
		if caja.size.length() < 1.5:
			galeria.camara.size = maxf(.5,caja.size.length()*2)
			galeria.camara.position = Vector3(0,13.8,20.80435) + Vector3.UP*(caja.size.y/2-.8)
			galeria.camara.look_at(Vector3.UP*(caja.size.y/2))
			html += "<p>Detalle: camara %.2f; modelo sin escalar.</p>" % galeria.camara.size
			await captura(nombre+"_detalle.png")
		for animador in galeria.jugadores_animacion:
			for clip in animador.get_animation_list():
				if clip == "RESET": continue
				var animacion: Animation = animador.get_animation(clip)
				animador.play(clip)
				animador.pause()
				html += "<p>Clip: "+clip.xml_escape()+"; duracion %.3f s; fotogramas 0, 1/3, 2/3.</p>" % animacion.length
				for paso in 3:
					animador.seek(animacion.length*paso/3.0,true)
					await captura(nombre+"_"+clip.validate_filename()+"_"+str(paso)+".png")
	FileAccess.open(salida+"galeria.html",FileAccess.WRITE).store_string(html)
	print("GALERIA: ",salida,"galeria.html")
	quit(fallos)

func captura(nombre: String) -> void:
	for i in 6: await process_frame
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png(salida+nombre)
	if error != OK: fallos += 1
	html += "<a href='"+nombre+"'><img loading='lazy' src='"+nombre+"'></a>"
