extends SceneTree

var fallos := 0
var controles := 0


func _initialize() -> void:
	validar.call_deferred()


func validar() -> void:
	var mundo := root.get_node("EstadoMundo")
	var diario := root.get_node("Diario")
	var bolsa: GDScript = load("res://scripts/vida/bolsa.gd")
	var comercio: GDScript = load("res://scripts/vida/comercio.gd")
	var perfil := "%d_%d" % [Time.get_unix_time_from_system(), OS.get_process_id()]
	mundo.ruta = "res://logs/descubrimientos_%s.save" % perfil
	comprobar(mundo.nombre_protagonista() == "Viajero", "Partida anterior sin identidad")
	comprobar(mundo.asignar_nombre_protagonista("  Lucía  "), "Nombre válido")
	comprobar(not mundo.asignar_nombre_protagonista("Lucía\nSol"), "Rechaza nombres multilínea")
	comprobar(mundo.nombre_protagonista() == "Lucía", "Conserva el último nombre válido")
	comprobar(mundo.seleccionar_apariencia("viajero_22"), "Apariencia válida para la partida")

	await abrir("mundo_ruinas")
	var actividades := current_scene.get_node("Region/ActividadesVida")
	var jugador := current_scene.get_node("Jugador") as CharacterBody3D
	for id in ["ruinas_mojon", "ruinas_registro", "ruinas_ficha"]:
		var punto := actividades.get_node(NodePath(id)) as Node3D
		jugador.global_position = punto.global_position + Vector3.UP * 0.05
		jugador.velocity = Vector3.ZERO
		await physics_frame
		await physics_frame
		await pulsar(JOY_BUTTON_A)
		comprobar(diario.abierto and mundo.objeto("@descubrimientos", id).get("descubierto", false),
			"Examinar con A: " + id)
		await pulsar(JOY_BUTTON_B)
		comprobar(not diario.abierto and not paused, "B cierra el diario")
	comprobar(bolsa.cantidad(bolsa.jugador(), "ficha_pesaje") == 1, "Reliquia en la mochila común")
	comprobar(mundo.guardar(), "Guardado de descubrimientos e identidad")
	mundo.datos.zonas.clear()
	comprobar(mundo.cargar(), "Reapertura del archivo aislado")
	comprobar(mundo.nombre_protagonista() == "Lucía", "Nombre recuperado")
	comprobar(mundo.apariencia_protagonista() == "viajero_22", "Apariencia recuperada")
	await abrir("mundo_ruinas")
	current_scene.get_node("Region/ActividadesVida/ruinas_ficha").actuar()
	comprobar(bolsa.cantidad(bolsa.jugador(), "ficha_pesaje") == 1, "La reliquia no se duplica al volver")
	diario.cerrar()
	diario.abrir(true)
	comprobar("Registro de los graneros" in diario.texto_plano(), "Consulta del hallazgo anterior")
	diario.cerrar()
	await abrir("mundo_montanas")
	var mirador := current_scene.get_node("Region/ActividadesVida/mirador_antiguo")
	mirador.actuar()
	comprobar(mundo.objeto("@descubrimientos", "mirador_antiguo").get("descubierto", false), "Mirador integrado en el diario")
	diario.cerrar()
	comprobar_recurso(bolsa, "cobre_valle", "cobre", 2)
	await abrir("mundo_minas")
	comprobar_recurso(bolsa, "carbon_bocamina", "carbon", 2)
	await abrir("mundo_bosque")
	var tronco := current_scene.get_node("Region/ActividadesVida/tronco_sendero_sur")
	var madera: int = bolsa.cantidad(bolsa.jugador(), "madera")
	tronco.actuar()
	comprobar(bolsa.cantidad(bolsa.jugador(), "madera") == madera, "La tala exige hacha")
	bolsa.anadir(bolsa.jugador(), "hacha", 1)
	comprobar_recurso(bolsa, "tronco_sendero_sur", "madera", 3)
	await abrir("mundo_campos_granjas")
	comprobar(current_scene.has_node("Region/ActividadesVida/puesto_semillas"), "Puesto integrado")
	var saldo: int = mundo.datos.monedas
	var semillas: int = bolsa.cantidad(bolsa.jugador(), "semilla_trigo")
	comercio.comprar("semillas", "semilla_trigo")
	comprobar(mundo.datos.monedas == saldo - 3 and bolsa.cantidad(bolsa.jugador(), "semilla_trigo") == semillas + 1,
		"Compra de semillas con la economía común")
	print("Descubrimientos: %d fallos / %d comprobaciones" % [fallos, controles])
	quit(1 if fallos else 0)


func comprobar_recurso(bolsa: GDScript, id: String, producto: String, cantidad: int) -> void:
	var nodo := current_scene.get_node("Region/ActividadesVida/" + id) as Node3D
	var antes: int = bolsa.cantidad(bolsa.jugador(), producto)
	nodo.actuar()
	comprobar(not nodo.visible and bolsa.cantidad(bolsa.jugador(), producto) == antes + cantidad,
		"Extracción o tala usa la mochila y agota el punto: " + id)
	var reloj := root.get_node("Reloj")
	reloj.tiempo_juego += nodo.regeneracion
	nodo.refrescar()
	comprobar(nodo.visible, "Regeneración con reloj lógico: " + id)


func abrir(escena: String) -> void:
	change_scene_to_file("res://scenes/%s.tscn" % escena)
	await scene_changed
	await physics_frame


func pulsar(boton: JoyButton) -> void:
	for presionado in [true, false]:
		var evento := InputEventJoypadButton.new()
		evento.button_index = boton
		evento.pressed = presionado
		Input.parse_input_event(evento)
		await process_frame


func comprobar(condicion: bool, mensaje: String) -> void:
	controles += 1
	if not condicion:
		fallos += 1
		push_error(mensaje)
