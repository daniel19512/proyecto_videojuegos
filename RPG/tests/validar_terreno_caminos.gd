extends "res://tests/validar_distribucion.gd"
## Compara el acabado con la misma escena y camara; no altera el mundo persistido.
func validar() -> void:
	print("VERSION: ", Engine.get_version_info().string)
	mundo = load("res://scenes/mundo.tscn").instantiate()
	root.add_child(mundo)
	current_scene = mundo
	aldea = mundo.get_node("Aldea")
	jugador = mundo.get_node("Jugador")
	await esperar(20)
	var acabado = aldea.get_node("AcabadoTerreno")
	comprobar(aldea.get_node("Caminos").get_child_count() == 36, "36 corredores conservados")
	comprobar(acabado.material != null, "Material de terreno creado")
	var mascara: Image = acabado.material.get_shader_parameter("mascara").get_image()
	comprobar(mascara.get_size() == Vector2i(800,720), "Mascara compartida a 10 texeles por unidad")
	for camino in aldea.get_node("Caminos").get_children():
		var a: Vector2 = camino.get_meta("a")
		var b: Vector2 = camino.get_meta("b")
		var centro := (a+b)*0.5
		var pixel := Vector2i((centro+Vector2(40,36))*10).clamp(Vector2i.ZERO,Vector2i(799,719))
		comprobar(mascara.get_pixelv(pixel).r > 0.7, str(camino.name)+": eje legible en mascara")
		comprobar(not camino.get_node("Marca").visible, str(camino.name)+": sin plano superpuesto")
	# La segunda instancia verifica determinismo de la mascara sin depender de TIME.
	var copia: Node3D = load("res://scenes/aldea.tscn").instantiate()
	root.add_child(copia)
	var otra: Image = copia.get_node("AcabadoTerreno").material.get_shader_parameter("mascara").get_image()
	comprobar(mascara.get_data() == otra.get_data(), "Mascara identica entre instancias")
	copia.queue_free()
	await esperar(2)
	if DisplayServer.get_name() != "headless":
		await capturar()
	print("RESULTADO_TERRENO: ",fallos," fallos")
	quit(0 if fallos==0 else 1)

func capturar() -> void:
	jugador.set_physics_process(false)
	jugador.global_position = Vector3(0,0.05,0)
	var camara: Camera3D = mundo.get_node("CamaraPrincipal")
	camara.set_process(false)
	camara.far = 250.0
	var carpeta := "res://logs/fase4b1_terreno_caminos/"+Time.get_datetime_string_from_system().replace(":","-")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(carpeta))
	var vistas := [
		["01_general", Vector3(0,0,0), 94.0, Vector3(0,90,52)],
		["02_camino_principal", Vector3(0,0,-28), 17.0, Vector3(0,13,20.80435)],
		["03_interseccion", Vector3(-14,0,-12), 17.0, Vector3(0,18,14)],
		["04_taberna", Vector3(-8,0,-15), 17.0, Vector3(0,13,20.80435)],
		["05_talleres", Vector3(-20,0,0), 30.0, Vector3(20,24,4)],
		["06_plaza", Vector3(0,0,0), 30.0, Vector3(0,26,15)],
		["07_viviendas_sur", Vector3(0,0,23), 49.0, Vector3(0,32,-22)],
		["08_acceso_puente", Vector3(26,0,0), 21.0, Vector3(0,18,17)]]
	var html := "<!doctype html><meta charset='utf-8'><title>Fase 4B.1</title><style>body{background:#20241c;color:#eee;font:16px sans-serif;margin:24px}section{margin-bottom:32px}img{width:49%}h2{font-size:20px}</style><h1>Terreno y caminos · antes / después</h1><p>Misma cámara en cada pareja. La animación del río continúa.</p>"
	for vista in vistas:
		camara.size = vista[2]
		camara.global_position = vista[1]+vista[3]
		camara.look_at(vista[1])
		for original in [true,false]:
			aldea.get_node("AcabadoTerreno").mostrar_original(original)
			await esperar(12)
			await RenderingServer.frame_post_draw
			var sufijo := "_antes" if original else "_despues"
			comprobar(root.get_texture().get_image().save_png(carpeta+"/"+vista[0]+sufijo+".png")==OK,"Captura "+vista[0]+sufijo)
		html += "<section><h2>"+vista[0]+"</h2><img src='"+vista[0]+"_antes.png'><img src='"+vista[0]+"_despues.png'></section>"
	var archivo := FileAccess.open(carpeta+"/galeria.html",FileAccess.WRITE)
	archivo.store_string(html)
	print("CAPTURAS: ",carpeta)
