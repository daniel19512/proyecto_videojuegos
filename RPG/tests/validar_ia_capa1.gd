extends SceneTree
## Desde la raiz: godot --headless --path RPG --log-file logs/validar_ia_capa1.log --script res://tests/validar_ia_capa1.gd
## Capa 1 de NPC con IA sin red: el autoload IA usa un simulador. Comprueba la
## vuelta a lo fijo, la conversación (opciones, texto libre, recuerdos,
## hechos), el narrador, el recorte de contexto, el tope, la persistencia, el
## diario y el menú de pausa.

var fallos: int = 0
## Autoloads: en un script de pruebas no existen como identificadores al compilar.
var ia: Node
var historia: Node
var dialogo: CanvasLayer
var diario: CanvasLayer
var menu: CanvasLayer
var mundo: Node3D
var jugador: CharacterBody3D
## Llamadas recibidas por el simulador: {mensajes, esquema}.
var llamadas: Array = []
## Respuestas de conversación en cola; el narrador tiene la suya.
var cola_conversacion: Array = []
var fallar: bool = false
## Turnos mostrados por dialogo y los ya consumidos por la prueba.
var turnos_mostrados: int = 0
var turnos_esperados: int = 0

const NARRACION := {
	resumen = "El viajero ha prometido a Marta averiguar qué pasa con la harina.",
	hilos = [{id = "harina", titulo = "La harina que falta", estado = "abierto", nota = "El viajero investiga los sacos del molino."}],
	indicaciones = [{npc = "herrero", texto = "Sabes que el viajero investiga la harina."}],
	diario = "Prometes a Marta averiguar qué pasa con la harina.",
}


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


func simular(mensajes: Array, esquema: Dictionary) -> Dictionary:
	llamadas.append({mensajes = mensajes, esquema = esquema})
	if fallar:
		return {}
	if esquema.properties.has("hilos"):
		return NARRACION
	if cola_conversacion.is_empty():
		return {respuesta = "Hmm.", opciones = ["Vale"], terminar = false, recuerdo = "", evento = "", importante = false}
	return cola_conversacion.pop_front()


## Espera al siguiente turno mostrado (el simulador puede contestar antes).
func esperar_turno() -> void:
	turnos_esperados += 1
	for i in 120:
		if turnos_mostrados >= turnos_esperados:
			return
		await process_frame
	push_error("turno no recibido")


func acercarse(npc: Node3D) -> void:
	jugador.global_position = npc.global_position + Vector3(0.9, 0.5, 0)
	await esperar(12)


func validar() -> void:
	print("VERSION: ", Engine.get_version_info().string)
	ia = root.get_node("IA")
	historia = root.get_node("Historia")
	dialogo = root.get_node("DialogoIA")
	diario = root.get_node("Diario")
	menu = root.get_node("MenuPausa")
	dialogo.turno_listo.connect(func(): turnos_mostrados += 1)
	comprobar(ia.modo_pruebas and not ia.disponible() and historia.ruta_guardado.is_empty(), "en pruebas la IA no usa red ni archivos del jugador")
	mundo = load("res://scenes/mundo.tscn").instantiate()
	for salida in ["Region/SalidaBosque", "Region/SalidaCampos", "Region/SalidaMontanas"]:
		mundo.get_node(salida).monitoring = false
	root.add_child(mundo)
	current_scene = mundo
	jugador = mundo.get_node("Jugador")
	var panadera: Node3D = mundo.get_node("NPCs/Panadera")
	var herrero: Node3D = mundo.get_node("NPCs/Herrero")
	var pescador: Node3D = mundo.get_node("NPCs/Pescador")
	await esperar(10)

	# Sin ia: diálogo fijo de siempre.
	await acercarse(panadera)
	await pulsar(&"interactuar")
	var caja: CanvasLayer = panadera.get_node("CajaDialogo")
	comprobar(caja.abierta and not dialogo.abierta, "sin IA la panadera usa su diálogo fijo")
	await pulsar(&"ui_cancel")
	comprobar(not paused, "cerrar el diálogo fijo quita la pausa")

	# Con ia simulada: conversación de dos turnos.
	ia.simulador = simular
	historia.reiniciar()
	cola_conversacion = [
		{respuesta = "¡Hola, viajero! Soy Marta. ¿Te apetece un bollo?", opciones = ["¿Qué pasa con la harina?", "Solo estoy de paso"], terminar = false, recuerdo = "", evento = "", importante = false},
		{respuesta = "Me llegan menos sacos del molino de los que pago. ¿Me ayudarías?", opciones = ["Lo averiguaré"], terminar = true, recuerdo = "El viajero se interesó por la harina.", evento = "El viajero promete averiguar lo de la harina.", importante = true},
	]
	await acercarse(panadera)
	await pulsar(&"interactuar")
	await esperar_turno()
	comprobar(paused and dialogo.abierta and "Marta" in dialogo.respuesta_actual, "con IA la panadera responde con el modelo y pausa")
	comprobar(Array(dialogo.opciones_actuales) == ["¿Qué pasa con la harina?", "Solo estoy de paso", dialogo.TEXTO_ESCRIBIR, dialogo.TEXTO_DESPEDIRSE], "muestra las opciones, escribir y despedirse")
	var sistema: String = llamadas[0].mensajes[0].content
	comprobar("Panadera alegre" in sistema and "harina" in sistema and sistema.begins_with(PromptsIA.REGLAS_NPC), "el contexto lleva reglas fijas primero, ficha e hilos")
	comprobar(sistema.length() < 2600, "el contexto del NPC es compacto (%d caracteres)" % sistema.length())

	dialogo.elegir("¿Qué pasa con la harina?")
	await esperar_turno()
	var segunda: Array = llamadas[1].mensajes
	var roles := segunda.map(func(m): return m.role)
	comprobar(roles == ["system", "user", "assistant", "user"] and segunda[3].content == "Viajero: ¿Qué pasa con la harina?", "el segundo turno reenvía la charla alternando jugador y NPC")
	comprobar(dialogo.terminada and Array(dialogo.opciones_actuales) == [dialogo.TEXTO_DESPEDIRSE], "al terminar solo queda despedirse")
	comprobar("El viajero se interesó por la harina." in historia.estado.npcs.panadera.recuerdos, "el recuerdo del modelo se guarda en la panadera")
	await esperar(4)
	comprobar(llamadas.any(func(l): return l.esquema.properties.has("hilos")), "un hecho importante despierta al narrador")
	comprobar(historia.estado.resumen == NARRACION.resumen and historia.estado.npcs.herrero.indicacion == NARRACION.indicaciones[0].texto, "el narrador actualiza el resumen e indica al herrero")
	comprobar(historia.estado.diario.back() == NARRACION.diario and historia.estado.hechos.is_empty(), "el narrador escribe en el diario y consume los hechos")
	var narrador_usuario: String = llamadas.filter(func(l): return l.esquema.properties.has("hilos"))[0].mensajes[1].content
	comprobar("Marta: El viajero promete averiguar lo de la harina." in narrador_usuario, "el narrador recibe el hecho con el nombre del aldeano")
	dialogo.elegir(dialogo.TEXTO_DESPEDIRSE)
	await esperar(3)
	comprobar(not dialogo.abierta and not paused and panadera.get_node("Aviso").visible, "despedirse cierra, quita la pausa y vuelve el aviso")

	# Texto libre y contexto del narrador en el herrero.
	await acercarse(herrero)
	await pulsar(&"interactuar")
	await esperar_turno()
	comprobar("investiga la harina" in llamadas.back().mensajes[0].content, "el herrero recibe la indicación del narrador")
	dialogo.elegir(dialogo.TEXTO_ESCRIBIR)
	comprobar(dialogo._entrada.visible and dialogo._entrada.has_focus(), "«Escribir otra cosa» muestra el campo de texto")
	dialogo._al_enviar_texto("¿Has visto luces en el puente?")
	await esperar_turno()
	comprobar(llamadas.back().mensajes.back().content == "Viajero: ¿Has visto luces en el puente?", "el texto libre llega al modelo")
	# Recorte: muchas réplicas no hacen crecer el contexto sin límite.
	for i in 6:
		dialogo.elegir("Vale")
		await esperar_turno()
	var ultimos: Array = llamadas.back().mensajes
	comprobar(ultimos.size() <= PromptsIA.TURNOS_MAXIMOS + 2 and ultimos[1].role == "user", "solo se reenvían los últimos turnos, empezando por el jugador")
	await pulsar(&"ui_cancel")
	await esperar(3)
	comprobar(not dialogo.abierta and not paused, "Esc cierra la conversación con IA")

	# Fallo en la primera respuesta: vuelta al diálogo fijo.
	fallar = true
	await acercarse(herrero)
	await pulsar(&"interactuar")
	await esperar(4)
	comprobar(herrero.get_node("CajaDialogo").abierta and not dialogo.abierta and paused, "si el modelo falla, el herrero usa su diálogo fijo")
	await pulsar(&"ui_cancel")
	fallar = false

	# Tope de tokens: sin ia hasta la próxima sesión.
	var tope: int = ia.tope_tokens
	ia.tope_tokens = ia.tokens_sesion
	comprobar(not ia.disponible(), "al llegar al tope la IA deja de estar disponible")
	ia.tope_tokens = tope

	# Tomás recuerda las partidas de pesca.
	pescador.registrar_partida(120)
	comprobar("120" in historia.estado.npcs.pescador.recuerdos.back(), "las partidas de pesca quedan como recuerdo de Tomás")
	for i in 12:
		historia.recordar(&"pescador", "Recuerdo %d" % i)
	comprobar(historia.estado.npcs.pescador.recuerdos.size() == historia.RECUERDOS_MAXIMOS, "los recuerdos por NPC tienen tope")

	# Persistencia.
	historia.ruta_guardado = "user://prueba_historia_ia.json"
	historia.guardar()
	var resumen: String = historia.estado.resumen
	historia.estado = {}
	comprobar(historia.cargar() and historia.estado.resumen == resumen and historia.estado.npcs.herrero.indicacion != "", "la historia se guarda y se recupera")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(historia.ruta_guardado))
	historia.ruta_guardado = ""

	# diario con J.
	await esperar(3)
	await pulsar(&"abrir_diario")
	comprobar(diario.abierto and paused and "La harina que falta" in diario.texto_plano() and NARRACION.diario in diario.texto_plano(), "J abre el diario con hilos y sucesos")
	await pulsar(&"abrir_diario")
	comprobar(not diario.abierto and not paused, "J cierra el diario")

	# Menú de pausa con Esc y opciones de ia.
	await pulsar(&"ui_cancel")
	comprobar(menu.abierto and paused, "Esc con el juego en marcha abre el menú de pausa")
	menu.mostrar_opciones()
	var clave_anterior: String = ia.clave
	menu._clave.text = "  sk-or-prueba  "
	menu._tope.value = 50
	menu.aplicar_opciones()
	comprobar(ia.clave == "sk-or-prueba" and ia.tope_tokens == 50000, "las opciones de IA aplican clave y tope")
	ia.clave = clave_anterior
	ia.tope_tokens = tope
	await pulsar(&"ui_cancel")
	comprobar(menu.abierto and menu._principal.visible, "Esc en opciones vuelve al menú")
	await pulsar(&"ui_cancel")
	comprobar(not menu.abierto and not paused, "Esc en el menú lo cierra y quita la pausa")
	print("RESULTADO_IA_CAPA1: ", fallos, " fallos")
	quit(0 if fallos == 0 else 1)
