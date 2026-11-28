extends SceneTree
## Encuentros locales visibles, abstractos y memoria en el diálogo del jugador.

var fallos := 0
var llamadas := 0


func _initialize() -> void:
	validar.call_deferred()


func validar() -> void:
	var ia := root.get_node("IA")
	var aldeanos := root.get_node("Aldeanos")
	var historia := root.get_node("Historia")
	var estado := root.get_node("EstadoMundo")
	var reloj := root.get_node("Reloj")
	reloj.escala = 0.0
	change_scene_to_file("res://scenes/mundo.tscn")
	await scene_changed
	await esperar(75)
	var jugador := current_scene.get_node("Jugador") as CharacterBody3D
	var herrero := current_scene.get_node("NPCs/Herrero") as Node3D
	var tabernero := current_scene.get_node("NPCs/Tabernero") as Node3D
	ia.simulador = simular
	aldeanos.velocidad = 15.0
	aldeanos.segundos_por_caracter = 0.0
	aldeanos.segundos_minimos_linea = 0.18
	jugador.global_position = Vector3(-9, 0.05, -12)
	await esperar(6)
	aldeanos.aplicar_planes([{npc = "herrero", accion = "hablar_con", objetivo = "tabernero", motivo = "Visita"}])
	for i in 900:
		if herrero.conversando:
			break
		await physics_frame
	comprobar(herrero.conversando and tabernero.conversando, "Ambos se detienen para conversar al llegar")
	var rumbo := tabernero.global_position - herrero.global_position
	comprobar(rumbo.length() >= 0.85 and herrero.mirada.dot(Vector3(rumbo.x, 0, rumbo.z).normalized()) > 0.9,
		"Distancia y orientación durante la charla")
	comprobar(herrero.hablando_en_bocadillo(), "Bocadillo inicial sobre quien habla")
	await esperar(40)
	comprobar(not herrero.conversando and not tabernero.conversando and not herrero.hablando_en_bocadillo()
		and not tabernero.hablando_en_bocadillo(), "Bocadillos y estados se limpian al terminar")
	var social: Dictionary = estado.objeto("@poblacion", "@social")
	comprobar(social.get("hechos", []).size() == 1 and llamadas == 0, "Suceso local registrado sin recurrir al modelo")
	var contexto: Dictionary = historia.contexto(&"tabernero")
	comprobar("hierro en la fragua" in PromptsIA.mensajes_conversacion(contexto, [], "hola")[0].content,
		"Lo aprendido llega al contexto del diálogo del jugador")

	jugador.global_position = Vector3(0, 0.05, 25)
	await esperar(6)
	aldeanos.aplicar_planes([{npc = "herrero", accion = "hablar_con", objetivo = "tabernero"}])
	await esperar(45)
	comprobar(social.hechos.size() == 1 and not tabernero.conversando, "El encuentro lejano omite bocadillos y deduplica el suceso")

	change_scene_to_file("res://scenes/mundo_ruinas.tscn")
	await scene_changed
	aldeanos.aplicar_planes([{npc = "guardia", accion = "hablar_con", objetivo = "herrero"}])
	comprobar(social.hechos.size() == 2 and llamadas == 0, "El encuentro fuera de escena se registra localmente")
	for i in 10:
		historia.aprender(&"guardia", "Rumor %d" % i)
	comprobar(historia.estado.npcs.guardia.rumores.size() == historia.RUMORES_MAXIMOS, "Memoria social acotada")
	print("RESULTADO_IA_CAPA3: ", fallos, " fallos")
	quit(1 if fallos else 0)


func esperar(fotogramas: int) -> void:
	for i in fotogramas:
		await physics_frame


func simular(_mensajes: Array, _esquema: Dictionary) -> Dictionary:
	llamadas += 1
	return {}


func comprobar(condicion: bool, mensaje: String) -> void:
	if condicion:
		print("OK: ", mensaje)
	else:
		fallos += 1
		push_error("FALLO: " + mensaje)
