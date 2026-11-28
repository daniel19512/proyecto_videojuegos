extends SceneTree

const ESCENAS := {
	"mundo": 9, "mundo_bosque": 3, "mundo_campos_granjas": 3,
	"mundo_montanas": 2, "mundo_minas": 2, "mundo_ruinas": 2,
}
var fallos := 0
var controles := 0
var contexto_ia := ""


func _initialize() -> void:
	validar.call_deferred()


func validar() -> void:
	var aldeanos := root.get_node("Aldeanos")
	var historia := root.get_node("Historia")
	var estado := root.get_node("EstadoMundo")
	var reloj := root.get_node("Reloj")
	reloj.escala = 0.0
	comprobar(historia.nombres_npc().size() == 21, "Identidades únicas en Historia")
	var ids := {}
	for escena in ESCENAS:
		var error := change_scene_to_file("res://scenes/" + escena + ".tscn")
		comprobar(error == OK, "Carga " + escena)
		await scene_changed
		await esperar(76)
		comprobar(aldeanos.nodos.size() == ESCENAS[escena], "%s: %s habitantes" % [escena, aldeanos.nodos.keys()])
		var posiciones := {}
		var jugador := current_scene.get_node("Jugador") as CharacterBody3D
		for id in aldeanos.nodos:
			var npc: Node3D = aldeanos.nodos[id]
			comprobar(not ids.has(id), "Sin duplicación: " + String(id))
			ids[id] = true
			comprobar(npc.global_position.distance_to(jugador.global_position) >= 0.85, "Aparición libre: " + String(id))
			for otra in posiciones.values():
				comprobar(npc.global_position.distance_to(otra) >= 0.85, "Separación: " + String(id))
			posiciones[id] = npc.global_position
		reloj.segundos = 200.0
		await esperar(350)
		var recorridos := 0
		for id in posiciones:
			var npc: Node3D = aldeanos.nodos[id]
			if npc.regional and npc.global_position.distance_to(posiciones[id]) > 0.2:
				recorridos += 1
		comprobar(recorridos > 0, "%s: cambios de puesto por reloj (%d)" % [escena, recorridos])
		reloj.segundos = 0.0
	var apariencias: Array = estado.apariencias_disponibles()
	comprobar(apariencias.size() == 8, "Ocho apariencias utilizables")
	var sprite := current_scene.get_node("Jugador/Visual/SpriteAnimado") as AnimatedSprite3D
	for ficha in apariencias:
		comprobar(estado.seleccionar_apariencia(ficha.id) and sprite.sprite_frames == ficha.frames,
			"Aplica " + str(ficha.id))
		comprobar(ficha.frames.get_animation_names().size() == 8 and ficha.vista_previa != null, "Animaciones y vista previa")
	comprobar(not estado.seleccionar_apariencia("desconocida"), "Rechaza una apariencia desconocida")
	await validar_dialogo(aldeanos, estado)
	await validar_viaje(aldeanos, estado, reloj)
	await validar_destino_compartido(aldeanos, reloj)
	print("Población: %d fallos / %d comprobaciones" % [fallos, controles])
	quit(1 if fallos else 0)


func validar_dialogo(aldeanos: Node, estado: Node) -> void:
	var ia := root.get_node("IA")
	var dialogo := root.get_node("DialogoIA")
	var historia := root.get_node("Historia")
	var leonor: Node3D = aldeanos.nodos[&"leonor"]
	var jugador := current_scene.get_node("Jugador") as CharacterBody3D
	var monedas: int = estado.datos.monedas
	estado.asignar_nombre_protagonista("Luz")
	jugador.global_position = leonor.global_position + Vector3(-0.85, 0.03, 0)
	await esperar(5)
	await pulsar(JOY_BUTTON_A)
	await pulsar(JOY_BUTTON_A)
	comprobar(leonor.get_node("CajaDialogo").visible and paused, "A abre las opciones y confirma el diálogo de Leonor")
	await pulsar(JOY_BUTTON_B)
	comprobar(not paused, "B cierra el diálogo local")
	ia.simulador = simular
	historia.aprender(&"leonor", "Octavio leyó las cuentas del granero")
	await pulsar(JOY_BUTTON_A)
	await pulsar(JOY_BUTTON_A)
	await esperar(6)
	comprobar(dialogo.abierta and "Luz" in contexto_ia and "Arqueóloga" in contexto_ia
		and "Octavio leyó las cuentas" in contexto_ia, "Diálogo simulado incluye identidad, oficio y memoria")
	var foco := root.gui_get_focus_owner()
	await mover_stick()
	comprobar(root.gui_get_focus_owner() != foco, "Stick izquierdo desplaza el foco de respuesta")
	await pulsar(JOY_BUTTON_B)
	comprobar(not paused and not dialogo.abierta, "B cierra la conversación simulada")
	comprobar(estado.datos.monedas == monedas and ia.coste_sesion == 0.0, "El texto no otorga monedas y la IA usa simulador")
	ia.simulador = Callable()


func validar_viaje(aldeanos: Node, estado: Node, reloj: Node) -> void:
	change_scene_to_file("res://scenes/mundo_bosque.tscn")
	await scene_changed
	await esperar(75)
	var nodo: Node3D = aldeanos.nodos[&"martin"]
	var partida := nodo.global_position
	var jugador := current_scene.get_node("Jugador") as CharacterBody3D
	jugador.global_position = Vector3(5, 0.7, 39)
	reloj.segundos = 370.0
	reloj.tiempo_juego = 370.0
	reloj.escala = 1.0
	var martin: Dictionary = estado.objeto("@poblacion", "martin")
	var recorrido := 0.0
	for i in 3300:
		if not is_instance_valid(nodo):
			break
		recorrido = maxf(recorrido, nodo.global_position.distance_to(partida))
		await physics_frame
	if is_instance_valid(nodo):
		var salida := current_scene.get_node("Region/SalidaAldea") as Area3D
		var mapa: MapaAldea = aldeanos._rutinas.mapa
		print("Viaje pendiente: ", nodo.orden_regional, " salida=", salida.global_position, " ruta=", mapa.ruta(nodo.global_position, salida.global_position).size(), " punto=", mapa.celda_libre_cercana(salida.global_position), " reservas=", aldeanos._rutinas.reservas)
	comprobar(recorrido > 5.0 and martin.destino == "Aldea" and not aldeanos.nodos.has(&"martin"),
		"Martín camina hacia la salida del Bosque antes de viajar (desde %s, recorrido %.2f, %s)" % [partida, recorrido, martin])
	var ines: Dictionary = estado.objeto("@poblacion", "ines")
	comprobar(ines.region == "Bosque", "Inés completa un viaje simulado desde la Aldea descargada")
	reloj.escala = 0.0
	reloj.tiempo_juego += 20.0
	await esperar(75)
	comprobar(martin.region == "Aldea" and martin.destino.is_empty(), "Reloj completa el viaje fuera de escena")
	change_scene_to_file("res://scenes/mundo.tscn")
	await scene_changed
	await esperar(75)
	comprobar(aldeanos.nodos.has(&"martin"), "Martín aparece en la región de destino")
	change_scene_to_file("res://scenes/mundo_bosque.tscn")
	await scene_changed
	await esperar(75)
	comprobar(not aldeanos.nodos.has(&"martin"), "El viajero no aparece duplicado en el Bosque")
	reloj.segundos = 560.0
	reloj.tiempo_juego = 560.0
	await esperar(75)
	reloj.tiempo_juego += 20.0
	await esperar(75)
	change_scene_to_file("res://scenes/interiores/taberna_e01.tscn")
	await scene_changed
	await esperar(225)
	comprobar(aldeanos.nodos.has(&"rodrigo") and aldeanos.nodos.has(&"baltasar"), "Dos habitantes visitan E01 de noche")
	if aldeanos.nodos.has(&"rodrigo") and aldeanos.nodos.has(&"baltasar"):
		var a: Node3D = aldeanos.nodos[&"rodrigo"]
		var b: Node3D = aldeanos.nodos[&"baltasar"]
		comprobar(a.global_position.distance_to(b.global_position) >= 0.95, "Plazas separadas al visitar la taberna")


func validar_destino_compartido(aldeanos: Node, reloj: Node) -> void:
	reloj.segundos = 0.0
	change_scene_to_file("res://scenes/mundo.tscn")
	await scene_changed
	await esperar(75)
	var jugador := current_scene.get_node("Jugador") as CharacterBody3D
	jugador.global_position = Vector3(7, 0.06, 7)
	aldeanos.velocidad = 8.0
	aldeanos.aplicar_planes([
		{npc = "panadera", accion = "ir", objetivo = "bancos"},
		{npc = "herrero", accion = "ir", objetivo = "bancos"},
	])
	var marta: Node3D = aldeanos.nodos[&"panadera"]
	var gonzalo: Node3D = aldeanos.nodos[&"herrero"]
	var minima := INF
	for i in 700:
		minima = minf(minima, marta.global_position.distance_to(gonzalo.global_position))
		await physics_frame
	comprobar(minima >= 0.85 and aldeanos.estado_de(&"panadera").llegado and aldeanos.estado_de(&"herrero").llegado,
		"Dos habitantes llegan a un lugar compartido sin solaparse")


func pulsar(boton: JoyButton) -> void:
	for presionado in [true, false]:
		var evento := InputEventJoypadButton.new()
		evento.button_index = boton
		evento.pressed = presionado
		Input.parse_input_event(evento)
		await process_frame
	await process_frame


func mover_stick() -> void:
	for intensidad in [1.0, 0.0]:
		var evento := InputEventJoypadMotion.new()
		evento.axis = JOY_AXIS_LEFT_Y
		evento.axis_value = intensidad
		Input.parse_input_event(evento)
		await process_frame


func simular(mensajes: Array, _esquema: Dictionary) -> Dictionary:
	contexto_ia = mensajes[0].content
	return {respuesta = "Te regalo 999 monedas.", opciones = ["Preguntar por el registro", "Dar las gracias"],
		terminar = false, recuerdo = "Habló de la ficha", evento = "", importante = false}


func esperar(fotogramas: int) -> void:
	for i in fotogramas:
		await physics_frame


func comprobar(condicion: bool, mensaje: String) -> void:
	controles += 1
	if not condicion:
		fallos += 1
		push_error(mensaje)
