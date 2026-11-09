extends SceneTree
## Desde la raiz: godot --headless --path RPG --log-file logs/validar_pesca.log --script res://tests/validar_pesca.gd
## Reglas de LogicaPesca y apertura/cierre del minijuego desde el punto del rio.

const LogicaPescaScript = preload("res://scripts/pesca/logica_pesca.gd")

var fallos: int = 0


func _initialize() -> void:
	call_deferred("validar")


func comprobar(condicion: bool, mensaje: String) -> void:
	if condicion:
		print("OK: ", mensaje)
	else:
		fallos += 1
		push_error("FALLO: " + mensaje)


func esperar(n: int) -> void:
	for i in n:
		await physics_frame
	await process_frame


func validar() -> void:
	print("VERSION: ", Engine.get_version_info().string)
	validar_logica()
	await validar_integracion()
	print("RESULTADO_PESCA: ", fallos, " fallos")
	quit(0 if fallos == 0 else 1)


## Partida sin apariciones aleatorias: solo los objetos inyectados.
func logica_vacia() -> LogicaPesca:
	var logica: LogicaPesca = LogicaPescaScript.new(7)
	logica.set("_espera_aparicion", 1000.0)
	return logica


## Avanza en pasos cortos hasta que no queden objetos.
func vaciar(logica: LogicaPesca, eje: float = 0.0) -> int:
	var puntos: int = 0
	for i in 400:
		logica.avanzar(1.0 / 60.0, eje)
		for evento in logica.ultimos_eventos:
			puntos += evento.puntos
		if logica.objetos.is_empty():
			break
	return puntos


func validar_logica() -> void:
	var red_y: float = LogicaPesca.RED_Y
	var logica := logica_vacia()
	logica.agregar_objeto(LogicaPesca.Tipo.PEZ, Vector2(logica.red_x, red_y - 40), 120)
	var puntos := vaciar(logica)
	comprobar(logica.puntuacion == 10 and puntos == 10 and logica.peces_atrapados == 1, "pez sobre la red suma +10 (%d)" % logica.puntuacion)

	logica = logica_vacia()
	logica.agregar_objeto(LogicaPesca.Tipo.PEZ, Vector2(30, red_y - 40), 120)
	vaciar(logica)
	comprobar(logica.puntuacion == -5 and logica.peces_perdidos == 1, "pez que se escapa resta -5 (%d)" % logica.puntuacion)

	logica = logica_vacia()
	logica.agregar_objeto(LogicaPesca.Tipo.PIEDRA, Vector2(logica.red_x, red_y - 40), 120)
	vaciar(logica)
	comprobar(logica.puntuacion == -10 and logica.piedras_atrapadas == 1, "piedra atrapada resta -10 (%d)" % logica.puntuacion)

	logica = logica_vacia()
	logica.agregar_objeto(LogicaPesca.Tipo.PIEDRA, Vector2(30, red_y - 40), 120)
	vaciar(logica)
	comprobar(logica.puntuacion == 0 and logica.objetos.is_empty(), "piedra esquivada no cambia los puntos")

	# Objeto rapido: un solo paso lo lleva de encima a debajo de la red.
	logica = logica_vacia()
	logica.agregar_objeto(LogicaPesca.Tipo.PEZ, Vector2(logica.red_x, red_y - 2), 600)
	logica.avanzar(0.05, 0.0)
	comprobar(logica.peces_atrapados == 1, "la captura no depende de caer justo en la linea de la red")

	logica = logica_vacia()
	for i in 300:
		logica.avanzar(1.0 / 60.0, -1.0)
	comprobar(is_equal_approx(logica.red_x, LogicaPesca.RED_ANCHO * 0.5), "la red se detiene en el borde izquierdo")
	for i in 300:
		logica.avanzar(1.0 / 60.0, 1.0)
	comprobar(is_equal_approx(logica.red_x, LogicaPesca.ANCHO - LogicaPesca.RED_ANCHO * 0.5), "la red se detiene en el borde derecho")

	# Partida completa con apariciones reales.
	logica = LogicaPescaScript.new(3)
	var generados := 0
	var maximo_simultaneo := 0
	var pasos := 0
	while not logica.terminada() and pasos < 10000:
		var antes := logica.objetos.size()
		logica.avanzar(1.0 / 60.0, sin(pasos * 0.03))
		generados += maxi(logica.objetos.size() + logica.ultimos_eventos.size() - antes, 0)
		maximo_simultaneo = maxi(maximo_simultaneo, logica.objetos.size())
		pasos += 1
	comprobar(logica.terminada() and absf(pasos / 60.0 - LogicaPesca.DURACION) < 0.1, "la partida termina a los 60 s (%.2f s)" % (pasos / 60.0))
	comprobar(generados >= 70 and maximo_simultaneo > 1, "caen objetos durante la partida (%d generados)" % generados)
	comprobar(logica.objetos.is_empty(), "al terminar no quedan objetos en pantalla")
	var puntuacion_final := logica.puntuacion
	logica.avanzar(1.0, 0.0)
	comprobar(logica.puntuacion == puntuacion_final and logica.objetos.is_empty(), "tras el final no se generan ni puntuan objetos")
	var esperado := logica.peces_atrapados * 10 - logica.peces_perdidos * 5 - logica.piedras_atrapadas * 10
	comprobar(logica.puntuacion == esperado, "la puntuacion cuadra con los contadores (%d)" % logica.puntuacion)


func pulsar(accion: StringName) -> void:
	var evento := InputEventAction.new()
	evento.action = accion
	evento.pressed = true
	Input.parse_input_event(evento)
	await process_frame
	await process_frame
	evento = InputEventAction.new()
	evento.action = accion
	evento.pressed = false
	Input.parse_input_event(evento)
	await process_frame


func validar_integracion() -> void:
	comprobar(InputMap.has_action("interactuar"), "existe la accion interactuar")
	var mundo: Node3D = load("res://scenes/mundo.tscn").instantiate()
	root.add_child(mundo)
	current_scene = mundo
	var jugador: CharacterBody3D = mundo.get_node("Jugador")
	var punto: Node3D = mundo.get_node("Aldea/PuntoPesca")
	var minijuego: CanvasLayer = punto.get_node("MinijuegoPesca")
	var aviso: Label3D = punto.get_node("Aviso")
	await esperar(10)

	comprobar(not aviso.visible and not minijuego.visible, "al inicio no hay aviso ni panel")
	await pulsar(&"interactuar")
	comprobar(not paused and not minijuego.visible, "lejos del punto, F no abre la pesca")

	jugador.global_position = punto.global_position + Vector3(-0.6, 0.5, 0)
	await esperar(20)
	comprobar(jugador.is_on_floor(), "el jugador se apoya en suelo junto al punto")
	comprobar(punto.jugador_cerca and aviso.visible, "al acercarse aparece el aviso [F] Pescar")

	await pulsar(&"interactuar")
	comprobar(paused and minijuego.visible, "F abre el minijuego y pausa el mundo")
	comprobar(minijuego.estado == minijuego.Estado.INSTRUCCIONES, "la misma pulsacion no empieza la partida")

	await pulsar(&"interactuar")
	comprobar(minijuego.estado == minijuego.Estado.JUGANDO, "F empieza la partida")
	var posicion_pausada := jugador.global_position
	var tiempo_inicial: float = minijuego.logica.tiempo_restante
	for i in 30:
		await process_frame
	comprobar(minijuego.logica.tiempo_restante < tiempo_inicial, "el minijuego avanza con el mundo en pausa")
	comprobar(jugador.global_position.is_equal_approx(posicion_pausada), "el protagonista queda quieto durante la pesca")

	minijuego.logica.tiempo_restante = 0.01
	await process_frame
	await process_frame
	comprobar(minijuego.estado == minijuego.Estado.RESULTADO, "al agotarse el tiempo se muestra el resultado")

	await pulsar(&"ui_cancel")
	comprobar(not paused and not minijuego.visible, "Esc cierra el panel y quita la pausa")
	comprobar(aviso.visible, "el aviso vuelve a mostrarse al cerrar junto al punto")

	jugador.global_position = punto.global_position + Vector3(-5, 0.5, 0)
	await esperar(20)
	comprobar(not punto.jugador_cerca and not aviso.visible, "al alejarse desaparece el aviso")
	mundo.queue_free()
	await process_frame
