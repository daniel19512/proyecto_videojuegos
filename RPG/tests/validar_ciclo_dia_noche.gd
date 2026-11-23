extends "res://tests/validar_interior_taberna.gd"
## Con ventana también captura el framebuffer de Godot en perspectivas fijas.
const NOMBRES := ["manana", "tarde", "atardecer", "noche"]
const MUNDO := "res://scenes/mundo.tscn"

var reloj: Node
var historia: Node
var escenas_html := PackedStringArray()
var grafico := false


func iniciar() -> void:
	carpeta = "res://logs/e12_ciclo_" + Time.get_datetime_string_from_system().replace(":", "-") + "_" + str(Time.get_ticks_msec())
	DirAccess.make_dir_recursive_absolute(carpeta)
	grafico = DisplayServer.get_name() != "headless"
	gestor = root.get_node("GestorRegiones")
	reloj = root.get_node("Reloj")
	historia = root.get_node("Historia")
	historia.ruta_guardado = carpeta + "/historia_prueba.json"
	var mundo := (load(MUNDO) as PackedScene).instantiate()
	root.add_child(mundo)
	current_scene = mundo
	await cuadros(8)
	var ciclo := mundo.get_node("CicloDiaNoche")
	var antes: float = reloj.segundos
	await cuadros(8)
	comprobar(reloj.segundos > antes, "Reloj avanza en partida")
	var aldeanos := root.get_node("Aldeanos")
	for i in 4:
		fijar_hora(i * 180.0 + 90.0)
		comprobar(aldeanos._datos_planificador([]).momento == reloj.descripcion(), "Hora recibida por aldeanos en " + NOMBRES[i])
		comprobar(reloj.franja() == i and reloj.nombre_franja() == reloj.FRANJAS[i], "Índice y nombre narrativo de " + NOMBRES[i])
	fijar_hora(330.0)
	var energia_antes: float = ciclo.sol.light_energy
	await cuadros(22)
	comprobar(ciclo.sol.light_energy < energia_antes, "La luz avanza con el reloj sin intervención de la prueba")
	fijar_hora(358.0)
	var previo: float = ciclo.sol.light_energy
	fijar_hora(360.0)
	var borde: float = ciclo.sol.light_energy
	fijar_hora(362.0)
	comprobar(previo > borde and borde > ciclo.sol.light_energy and previo - ciclo.sol.light_energy < 0.05,
		"Interpolación a ambos lados del atardecer")
	fijar_hora(719.0)
	previo = ciclo.sol.light_energy
	fijar_hora(1.0)
	comprobar(absf(previo - ciclo.sol.light_energy) < 0.05, "Continuidad al pasar de noche a mañana")
	reloj.guardar()
	fijar_hora(630.0)
	historia.estado.erase("reloj")
	comprobar(historia.cargar(), "Historial de prueba se recupera del archivo")
	reloj.cargar()
	ciclo.actualizar()
	comprobar(is_equal_approx(reloj.segundos, 1.0) and absf(previo - ciclo.sol.light_energy) < 0.05,
		"Guardar y cargar la misma hora recupera la luz")
	paused = true
	antes = reloj.segundos
	previo = ciclo.sol.light_energy
	await create_timer(0.25, true).timeout
	comprobar(reloj.segundos == antes and ciclo.sol.light_energy == previo, "Reloj y luz quietos durante la pausa")
	paused = false
	await exterior("Aldea", Vector3(0, 0, -5), 26.0)

	await viajar("res://scenes/mundo_bosque.tscn", "bosque_aldea_sur", &"Bosque")
	await exterior("Bosque", current_scene.get_node("Jugador").position + Vector3(0, 0, -5), 24.0)
	await viajar("res://scenes/mundo_ruinas.tscn", "ruinas_bosque_sur", &"Ruinas")
	await exterior("Ruinas", current_scene.get_node("Jugador").position, 20.0, false)
	await viajar(MUNDO, "aldea_campos_sur", &"Aldea")
	await viajar("res://scenes/mundo_campos_granjas.tscn", "campos_aldea_norte", &"CamposYGranjas")
	await exterior("Campos", current_scene.get_node("Jugador").position + Vector3(0, 0, 9), 26.0)
	await viajar(MUNDO, "aldea_camino_este", &"Aldea")
	await viajar("res://scenes/mundo_montanas.tscn", "camino_montanas_aldea_oeste", &"Montanas")
	await exterior("Montanas", current_scene.get_node("Jugador").position, 20.0, false)
	await viajar("res://scenes/mundo_minas.tscn", "minas_montanas_sur", &"Minas")
	var nivel: float = current_scene.get_node("Ambiente").environment.ambient_light_energy
	fijar_hora(270.0)
	var entrada: OmniLight3D = current_scene.get_node("LuzBocamina")
	comprobar(entrada.light_energy > 0.0, "La bocamina recibe luz exterior de día")
	fijar_hora(630.0)
	comprobar(entrada.light_energy < 0.01 and current_scene.get_node("Ambiente").environment.ambient_light_energy == nivel,
		"La noche solo retira el aporte exterior de la bocamina")
	await viajar(MUNDO, "aldea_e12", &"Aldea")
	await pulsar_f()
	await esperar_transicion(&"InteriorE12")
	if gestor.region_actual != &"InteriorE12":
		quit(1)
		return
	await molino()
	await pulsar_f()
	await esperar_transicion(&"Aldea")
	ciclo = current_scene.get_node("CicloDiaNoche")
	comprobar(ciclo.sol.light_energy < 0.4 and reloj.franja() == 3, "Retorno conserva la iluminación de noche")
	if grafico:
		var archivo := FileAccess.open(carpeta + "/galeria.html", FileAccess.WRITE)
		archivo.store_string("<!doctype html><meta charset=utf-8><title>Molino E12 y ciclo día/noche</title>"
			+ "<style>body{background:#161b22;color:#f0ede7;font:16px system-ui;margin:2rem}main{display:grid;grid-template-columns:repeat(auto-fit,minmax(360px,1fr));gap:1rem}figure{margin:0}img{width:100%}figcaption{padding:.35rem}</style>"
			+ "<h1>Molino E12 y ciclo día/noche</h1><main>" + "".join(escenas_html) + "</main>")
	print("CICLO: ", fallos, " fallos / ", comprobaciones, " comprobaciones. Evidencias: ", carpeta)
	quit(1 if fallos else 0)


func fijar_hora(segundos: float) -> void:
	reloj.segundos = segundos
	current_scene.get_node("CicloDiaNoche").actualizar()


func viajar(ruta: String, entrada: String, region: StringName) -> void:
	comprobar(gestor.solicitar(ruta, entrada), "Inicia cambio a " + String(region))
	await esperar_transicion(region)


func encuadrar(centro: Vector3, tamano: float, azimut: float) -> void:
	var camara := current_scene.get_node("CamaraPrincipal") as Camera3D
	camara.set_process(false)
	camara.size = tamano
	camara.angulo_horizontal = azimut
	camara.centro_seguimiento = centro
	camara.actualizar_orbita()


func vista(nombre: String) -> float:
	await cuadros(4)
	if not grafico:
		return 0
	await RenderingServer.frame_post_draw
	var imagen := root.get_texture().get_image()
	comprobar(imagen.save_png(carpeta + "/" + nombre + ".png") == OK, "Captura " + nombre)
	escenas_html.append('<figure><a href="%s.png"><img src="%s.png"></a><figcaption>%s</figcaption></figure>' % [nombre, nombre, nombre.replace("_", " ")])
	var luminancia := 0.0
	for y in range(30, 75, 3):
		for x in range(25, 75, 3):
			luminancia += imagen.get_pixel(x * imagen.get_width() / 100, y * imagen.get_height() / 100).get_luminance()
	return luminancia / (15.0 * 17.0)


func exterior(nombre: String, centro: Vector3, tamano: float, capturar := true) -> void:
	var ciclo := current_scene.get_node("CicloDiaNoche")
	comprobar(current_scene.find_children("*", "DirectionalLight3D", true, false).size() == 1, nombre + " tiene una luz direccional")
	comprobar(current_scene.get_node("Jugador").velocidad == 10.0, nombre + " usa velocidad normal")
	if not grafico or not capturar:
		fijar_hora(270.0)
		var energia: float = ciclo.sol.light_energy
		fijar_hora(630.0)
		comprobar(ciclo.sol.light_energy < energia and ciclo.ambiente.environment.ambient_light_energy > 0.45,
			nombre + " aplica noche con relleno")
		return
	encuadrar(centro, tamano, 0.1)
	await create_timer(1.25).timeout
	var luminancias: Array[float] = []
	for i in 4:
		fijar_hora(i * 180.0 + 90.0)
		luminancias.append(await vista(nombre + "_" + NOMBRES[i]))
	print("LUMINANCIA ", nombre, ": ", luminancias, " FPS: ", Engine.get_frames_per_second())
	comprobar(luminancias[3] > 0.045 and luminancias[1] > luminancias[3] + 0.10,
		nombre + " fotograma nocturno visible y distinto del diurno")
	current_scene.get_node("CamaraPrincipal").set_process(true)


func molino() -> void:
	var transmision := current_scene.get_node("Mobiliario/Transmision")
	var horizontal := transmision.get_node("EjeHorizontal") as Node3D
	var vertical := transmision.get_node("EjeVertical") as Node3D
	var anterior_x := horizontal.rotation.x
	var anterior_y := vertical.rotation.y
	var luces := current_scene.find_children("*", "OmniLight3D", true, false).size()
	var ambiente: Environment = current_scene.get_node("Ambiente").environment
	var noche := ambiente.ambient_light_energy
	comprobar(reloj.franja() == 3 and noche >= 0.60, "Molino entra de noche con relleno y luz cálida")
	fijar_hora(270.0)
	comprobar(ambiente.ambient_light_energy > noche and current_scene.find_children("*", "OmniLight3D", true, false).size() == luces,
		"Molino gana claridad diurna sin duplicar lámparas")
	await cuadros(18)
	var giro_x := horizontal.rotation.x - anterior_x
	var giro_y := vertical.rotation.y - anterior_y
	comprobar(giro_x < 0.0 and is_equal_approx(giro_y / giro_x, -16.0 / 12.0),
		"Eje motriz y muela giran en relación inversa 16:12")
	comprobar(current_scene.get_node("Colisiones/ResguardoMuelas") is StaticBody3D and
		transmision.find_children("*", "PhysicsBody3D", true, false).is_empty(), "Protección estática independiente de las piezas móviles")
	if grafico:
		encuadrar(Vector3(0, 0, 0), 9.7, 0.65)
		await vista("Molino_general_con_protagonista")
		encuadrar(Vector3(0.52, 0.95, -0.55), 3.5, -0.85)
		await vista("Molino_muelas_y_tolva")
		encuadrar(Vector3(0.9, 2.13, -0.2), 3.8, 1.6)
		await vista("Molino_engranajes_y_transmision")
		encuadrar(Vector3(0, 0.65, 2.5), 6.0, -0.3)
		await vista("Molino_almacenamiento")
		fijar_hora(630.0)
		encuadrar(Vector3(0, 0, 0), 9.7, 0.65)
		await vista("Molino_noche")
		current_scene.get_node("CamaraPrincipal").set_process(true)
	fijar_hora(630.0)
