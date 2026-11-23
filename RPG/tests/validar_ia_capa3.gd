extends SceneTree
## Desde la raiz: godot --headless --path RPG --log-file logs/validar_ia_capa3.log --script res://tests/validar_ia_capa3.gd
## Capa 3 de NPC con IA, sin red (simulador): encuentros entre aldeanos con
## bocadillos si el viajero está cerca, solo resumen si está lejos o fuera de
## la aldea, rumores que pasan de uno a otro y llegan a la conversación, y
## plantilla si el modelo falla.

var fallos: int = 0
var ia: Node
var historia: Node
var aldeanos: Node
var mundo: Node3D
var jugador: CharacterBody3D
var llamadas_encuentro: Array = []
var fallar: bool = false


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


func esperar_hasta(condicion: Callable, maximo: int = 900) -> bool:
	for i in maximo:
		if condicion.call():
			return true
		await physics_frame
	return condicion.call()


func simular(mensajes: Array, esquema: Dictionary) -> Dictionary:
	if esquema.properties.has("aprende_a"):
		llamadas_encuentro.append(mensajes)
		if fallar:
			return {}
		var ids: Array = esquema.properties.lineas.items.properties.quien.enum
		var con_dialogo: bool = PromptsIA.DIALOGO_COMPLETO in mensajes[1].content
		var lineas: Array = []
		if con_dialogo:
			lineas = [
				{quien = ids[0], texto = "Necesito clavos para la puerta del molino."},
				{quien = ids[1], texto = "Te guardo una caja, pero cuéntame qué pasa allí."},
				{quien = ids[0], texto = "Dicen que de noche se oyen ruidos."},
			]
		return {lineas = lineas, resumen = "Hablaron de los ruidos del molino", aprende_a = "Le guardarán una caja de clavos", aprende_b = "De noche hay ruidos en el molino", importante = false}
	if esquema.properties.has("planes"):
		return {planes = {}}
	if esquema.properties.has("hilos"):
		return {resumen = historia.estado.resumen, hilos = historia.estado.hilos, indicaciones = [], diario = ""}
	return {respuesta = "Hola.", opciones = ["Adiós"], terminar = true, recuerdo = "", evento = "", importante = false}


func cargar_mundo() -> void:
	mundo = load("res://scenes/mundo.tscn").instantiate()
	for salida in ["Region/SalidaBosque", "Region/SalidaCampos", "Region/SalidaMontanas"]:
		mundo.get_node(salida).monitoring = false
	root.add_child(mundo)
	current_scene = mundo
	jugador = mundo.get_node("Jugador")
	await esperar(8)


func npc(nombre: String) -> Node3D:
	return mundo.get_node("NPCs/" + nombre)


func bocadillo(n: Node3D) -> String:
	var b := n.get_node_or_null("Bocadillo") as Label3D
	return b.text if b and b.visible else ""


func validar() -> void:
	print("VERSION: ", Engine.get_version_info().string)
	ia = root.get_node("IA")
	historia = root.get_node("Historia")
	aldeanos = root.get_node("Aldeanos")
	await cargar_mundo()
	ia.simulador = simular
	aldeanos.velocidad = 15.0
	aldeanos.segundos_por_caracter = 0.0
	aldeanos.segundos_minimos_linea = 0.15
	historia.reiniciar()

	# Encuentro visible: el viajero junto a la taberna.
	jugador.global_position = Vector3(-9, 0.05, -12)
	await esperar(6)
	aldeanos.aplicar_planes([{npc = "herrero", accion = "hablar_con", objetivo = "tabernero", motivo = "Pedir clavos"}])
	var herrero := npc("Herrero")
	var tabernero := npc("Tabernero")
	var vistos: Array = []
	var empezado := await esperar_hasta(func(): return herrero.conversando)
	comprobar(empezado and tabernero.conversando, "al llegar, herrero y tabernero se paran a conversar")
	comprobar(llamadas_encuentro.size() == 1 and PromptsIA.DIALOGO_COMPLETO in llamadas_encuentro[0][1].content and "herrero (Gonzalo)" in llamadas_encuentro[0][1].content and "Motivo: Pedir clavos" in llamadas_encuentro[0][1].content, "con el viajero cerca se pide el diálogo completo")
	var hacia: Vector3 = tabernero.global_position - herrero.global_position
	comprobar(herrero.mirada.dot(Vector3(hacia.x, 0, hacia.z).normalized()) > 0.9, "el herrero mira al tabernero")
	for i in 600:
		var texto_h := bocadillo(herrero)
		var texto_t := bocadillo(tabernero)
		if not texto_h.is_empty() and (vistos.is_empty() or vistos.back() != "h:" + texto_h):
			vistos.append("h:" + texto_h)
		if not texto_t.is_empty() and (vistos.is_empty() or vistos.back() != "t:" + texto_t):
			vistos.append("t:" + texto_t)
		if not herrero.conversando:
			break
		await process_frame
	comprobar(vistos == ["h:Necesito clavos para la puerta del molino.", "t:Te guardo una caja, pero cuéntame qué pasa allí.", "h:Dicen que de noche se oyen ruidos."], "los bocadillos aparecen por turnos sobre quien habla %s" % [vistos])
	comprobar(not herrero.conversando and not tabernero.conversando and bocadillo(herrero).is_empty() and bocadillo(tabernero).is_empty(), "al terminar se ocultan los bocadillos y vuelven a lo suyo")
	await esperar(3)
	comprobar("De noche hay ruidos en el molino" in historia.estado.npcs.tabernero.rumores and "Le guardarán una caja de clavos" in historia.estado.npcs.herrero.rumores, "cada uno aprende algo del otro")
	comprobar(historia.estado.hechos.any(func(h): return "Gonzalo y Anselmo: Hablaron de los ruidos del molino" in h), "el resumen llega al narrador como hecho")
	var contexto: Dictionary = historia.contexto(&"tabernero")
	var sistema: String = PromptsIA.mensajes_conversacion(contexto, [], "hola")[0].content
	comprobar("Te han contado otros aldeanos: De noche hay ruidos en el molino" in sistema, "el rumor llega a la conversación con el viajero")

	# Encuentro lejano: solo resumen, sin bocadillos.
	jugador.global_position = Vector3(0, 0.05, 25)
	await esperar(6)
	aldeanos.aplicar_planes([{npc = "pescador", accion = "hablar_con", objetivo = "panadera", motivo = "Contarle lo de las luces"}])
	var lejos := await esperar_hasta(func(): return llamadas_encuentro.size() >= 2)
	await esperar(4)
	comprobar(lejos and PromptsIA.DIALOGO_RESUMEN in llamadas_encuentro[1][1].content, "con el viajero lejos solo se pide el resumen")
	comprobar(not npc("Pescador").conversando and bocadillo(npc("Pescador")).is_empty() and "De noche hay ruidos en el molino" in historia.estado.npcs.panadera.rumores, "sin bocadillos, pero el rumor se transmite")

	# Fuera de la aldea: resumen en abstracto.
	mundo.queue_free()
	await esperar(3)
	aldeanos.aplicar_planes([{npc = "guardia", accion = "hablar_con", objetivo = "herrero", motivo = "Preguntar por los clavos"}])
	var ausente := await esperar_hasta(func(): return llamadas_encuentro.size() >= 3)
	comprobar(ausente and PromptsIA.DIALOGO_RESUMEN in llamadas_encuentro[2][1].content, "fuera de la aldea el encuentro se resume en abstracto")
	await esperar(3)
	comprobar("De noche hay ruidos en el molino" in historia.estado.npcs.herrero.rumores, "el rumor sigue pasando aunque no estés")

	# Fallo del modelo: plantilla (narrador bloqueado para que no consuma el hecho).
	historia.narrando = true
	fallar = true
	aldeanos.aplicar_planes([{npc = "tabernero", accion = "hablar_con", objetivo = "guardia", motivo = "Pedirle ayuda"}])
	await esperar_hasta(func(): return llamadas_encuentro.size() >= 4)
	await esperar(3)
	comprobar(historia.estado.hechos.any(func(h): return "Anselmo fue a hablar con Bruno: Pedirle ayuda" in h) and aldeanos.encuentros_en_curso.is_empty(), "si el modelo falla queda la frase de plantilla")
	fallar = false
	historia.narrando = false

	# Tope de rumores.
	for i in 10:
		historia.aprender(&"guardia", "Rumor %d" % i)
	comprobar(historia.estado.npcs.guardia.rumores.size() == historia.RUMORES_MAXIMOS, "los rumores por aldeano tienen tope")
	ia.simulador = Callable()
	print("RESULTADO_IA_CAPA3: ", fallos, " fallos")
	quit(0 if fallos == 0 else 1)
