extends SceneTree
## Desde la raiz: godot --headless --path RPG --log-file logs/validar_npc_pescador.log --script res://tests/validar_npc_pescador.gd
## Pescador junto al rio: dialogo segun partidas, pausa, cierre, colision y
## separacion de su zona respecto al punto de pesca.

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


## Avanza la caja hasta cerrarla; devuelve cuantas lineas mostro.
func leer_todo(caja: CanvasLayer) -> int:
	var vistas := 0
	for i in 20:
		if not caja.abierta:
			break
		vistas = maxi(vistas, caja.indice + 1)
		await pulsar(&"interactuar")  # completa la linea
		await pulsar(&"interactuar")  # pasa a la siguiente o cierra
	return vistas


func validar() -> void:
	print("VERSION: ", Engine.get_version_info().string)
	var mundo: Node3D = load("res://scenes/mundo.tscn").instantiate()
	root.add_child(mundo)
	current_scene = mundo
	var jugador: CharacterBody3D = mundo.get_node("Jugador")
	var npc: StaticBody3D = mundo.get_node("NPCs/Pescador")
	var punto: Node3D = mundo.get_node("Aldea/PuntoPesca")
	var caja: CanvasLayer = npc.get_node("CajaDialogo")
	var aviso: Label3D = npc.get_node("Aviso")
	await esperar(10)

	comprobar(not aviso.visible and not caja.visible, "al inicio no hay aviso ni dialogo")
	comprobar(npc.global_position.distance_to(punto.global_position) < 5.0, "el pescador esta junto al punto de pesca")

	# Colision: el jugador no atraviesa al pescador.
	jugador.global_position = npc.global_position + Vector3(-2.0, 0.5, 0)
	await esperar(10)
	var consulta := PhysicsShapeQueryParameters3D.new()
	consulta.shape = jugador.get_node("ColisionJugador").shape
	consulta.transform = Transform3D(Basis(), npc.global_position + Vector3(0, 0.8, 0))
	consulta.exclude = [jugador.get_rid()]
	var golpes := jugador.get_world_3d().direct_space_state.intersect_shape(consulta)
	comprobar(golpes.any(func(g): return g.collider == npc), "el pescador tiene colision solida")

	# Zonas separadas: en ninguna posicion se activan ambos avisos a la vez.
	var solapes := 0
	for i in 41:
		var t := i / 40.0
		jugador.global_position = punto.global_position.lerp(npc.global_position, t) + Vector3(-0.8, 0.5, 0)
		await esperar(3)
		if npc.jugador_cerca and punto.jugador_cerca:
			solapes += 1
	comprobar(solapes == 0, "las zonas de hablar y pescar no se solapan")

	# Primera conversacion, sin partidas.
	jugador.global_position = npc.global_position + Vector3(-0.9, 0.5, 0)
	await esperar(15)
	comprobar(npc.jugador_cerca and aviso.visible and not punto.jugador_cerca, "junto al pescador aparece solo [F] Hablar")
	await pulsar(&"interactuar")
	comprobar(paused and caja.visible and caja.indice == 0, "F abre el dialogo en la primera linea y pausa el mundo")
	comprobar(caja.lineas.size() == 3 and "Tomás" in caja.lineas[0], "presentacion de tres lineas")
	var vistas := await leer_todo(caja)
	comprobar(vistas == 3 and not caja.abierta and not paused, "F recorre las tres lineas, cierra y quita la pausa")
	comprobar(aviso.visible, "el aviso reaparece al cerrar")

	await pulsar(&"interactuar")
	comprobar(caja.lineas.size() == 1 and "probado" in caja.lineas[0], "sin partidas, segunda visita recuerda la red")
	await pulsar(&"ui_cancel")
	comprobar(not caja.abierta and not paused, "Esc cierra el dialogo")

	# Partidas comentadas: la señal del minijuego actualiza al pescador.
	var minijuego: CanvasLayer = punto.get_node("MinijuegoPesca")
	minijuego.partida_terminada.emit(150)
	minijuego.partida_terminada.emit(40)
	comprobar(npc.partidas == 2 and npc.mejor_puntuacion == 150 and npc.ultima_puntuacion == 40, "registra mejor y ultima puntuacion")
	var lineas: PackedStringArray = npc.lineas_dialogo()
	comprobar(lineas.size() == 2 and "150" in lineas[0] and "40" in lineas[1], "comenta la mejor marca y la ultima partida")

	var nuevo: StaticBody3D = load("res://scenes/npc_pescador.tscn").instantiate()
	nuevo.registrar_partida(-20)
	comprobar("-20" in nuevo.lineas_dialogo()[0], "una marca negativa tambien se comenta")
	nuevo.registrar_partida(260)
	comprobar("260" in nuevo.lineas_dialogo()[0] and nuevo.lineas_dialogo().size() == 1, "marca alta sin comentario de ultima partida")
	nuevo.free()

	# Flujo real: una partida completa del minijuego llega al pescador.
	jugador.global_position = punto.global_position + Vector3(-0.6, 0.5, 0)
	await esperar(15)
	await pulsar(&"interactuar")
	await pulsar(&"interactuar")
	minijuego.logica.puntuacion = 230
	minijuego.logica.tiempo_restante = 0.01
	await process_frame
	await process_frame
	await pulsar(&"ui_cancel")
	comprobar(npc.mejor_puntuacion == 230 and npc.partidas == 3 and not paused, "una partida real actualiza al pescador")

	jugador.global_position = npc.global_position + Vector3(-5, 0.5, 0)
	await esperar(15)
	comprobar(not npc.jugador_cerca and not aviso.visible, "al alejarse desaparece el aviso")
	print("RESULTADO_NPC_PESCADOR: ", fallos, " fallos")
	quit(0 if fallos == 0 else 1)
