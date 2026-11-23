extends SceneTree
## Desde la raiz: godot --headless --path RPG --log-file logs/validar_ia_capa2.log --script res://tests/validar_ia_capa2.gd
## Capa 2 de NPC con IA, sin red (simulador): mapa de navegación, lugares,
## planificador y catálogo de acciones, ejecución caminando, solidez solo en
## el puesto, búsqueda del viajero, reloj, simulación fuera de escena,
## guardado y vuelta a la rutina al empezar una historia nueva.

var fallos: int = 0
var ia: Node
var historia: Node
var reloj: Node
var aldeanos: Node
var mundo: Node3D
var jugador: CharacterBody3D
var llamadas_plan: Array = []
var planes: Array = []


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


func simular(mensajes: Array, esquema: Dictionary) -> Dictionary:
	# Los encuentros (capa 3) se prueban aparte: aquí se usa la plantilla.
	if esquema.properties.has("aprende_a"):
		return {}
	if esquema.properties.has("planes"):
		llamadas_plan.append(mensajes)
		var por_npc := {}
		for plan in planes:
			por_npc[plan.npc] = {accion = plan.accion, objetivo = plan.objetivo, motivo = plan.motivo}
		return {planes = por_npc}
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


func plano(v: Vector3) -> Vector2:
	return Vector2(v.x, v.z)


func pos_lugar(id: String) -> Vector3:
	var p: Array = aldeanos.lugares[id].pos
	return Vector3(p[0], 0, p[1])


## Espera hasta que se cumpla `condicion` (Callable) o se agoten los fotogramas.
func esperar_hasta(condicion: Callable, maximo: int = 600) -> bool:
	for i in maximo:
		if condicion.call():
			return true
		await physics_frame
	return condicion.call()


func colision_activa(n: Node3D) -> bool:
	return not (n.get_node("Cuerpo/Colision") as CollisionShape3D).disabled


func validar() -> void:
	print("VERSION: ", Engine.get_version_info().string)
	ia = root.get_node("IA")
	historia = root.get_node("Historia")
	reloj = root.get_node("Reloj")
	aldeanos = root.get_node("Aldeanos")
	await cargar_mundo()

	# Sin IA nadie se mueve ni cambia su colisión.
	var antes := plano(npc("Panadera").global_position)
	await esperar(60)
	comprobar(not aldeanos.activo() and plano(npc("Panadera").global_position) == antes and colision_activa(npc("Panadera")), "sin IA los aldeanos siguen en su puesto y sólidos")

	# Mapa de navegación.
	var t0 := Time.get_ticks_msec()
	comprobar(aldeanos._asegurar_mapa(), "el mapa se construye en la aldea")
	print("mapa construido en %d ms" % (Time.get_ticks_msec() - t0))
	var mapa: MapaAldea = aldeanos.mapa
	# Cada lugar y cada puesto se alcanza desde la plaza y la ruta acaba en él.
	var sin_ruta := PackedStringArray()
	var destinos := {}
	for id in aldeanos.lugares:
		destinos[id] = pos_lugar(id)
	for nombre in ["Panadera", "Herrero", "Tabernero", "Pescador", "Guardia"]:
		destinos[nombre] = npc(nombre).puesto
	for id in destinos:
		var r: PackedVector3Array = mapa.ruta(pos_lugar("plaza"), destinos[id])
		if r.is_empty() or plano(r[-1]).distance_to(plano(destinos[id])) > 0.01:
			sin_ruta.append(id)
	comprobar(sin_ruta.is_empty(), "desde la plaza se llega exactamente a cada lugar y puesto %s" % sin_ruta)
	var al_este := mapa.ruta(pos_lugar("plaza"), pos_lugar("camino_este"))
	var por_puente := false
	var por_agua := false
	for p in al_este:
		if p.x > 26.5 and p.x < 33.5:
			if absf(p.z) < 1.5 and p.y > 0.3:
				por_puente = true
			elif absf(p.z) >= 1.5:
				por_agua = true
	comprobar(por_puente and not por_agua, "para cruzar el río la ruta sube al puente y no pisa el agua")
	var rectangulos: Array[Rect2] = mapa._rectangulos_caminos(mundo)
	var de_herreria := mapa.ruta(pos_lugar("panaderia"), pos_lugar("herreria"))
	var en_camino := 0
	for p in de_herreria:
		if rectangulos.any(func(r: Rect2): return r.has_point(plano(p))):
			en_camino += 1
	comprobar(de_herreria.size() > 10 and float(en_camino) / de_herreria.size() > 0.7, "las rutas prefieren los caminos (%d de %d puntos)" % [en_camino, de_herreria.size()])

	# Con IA simulada: planificación y ejecución.
	ia.simulador = simular
	aldeanos.velocidad = 15.0
	historia.reiniciar()
	planes = [
		{npc = "panadera", accion = "ir", objetivo = "plaza", motivo = "Comprar fruta"},
		{npc = "herrero", accion = "hablar_con", objetivo = "tabernero", motivo = "Pedirle clavos"},
		{npc = "guardia", accion = "buscar_jugador", objetivo = "", motivo = "Avisarle de las luces"},
		{npc = "tabernero", accion = "trabajar", objetivo = "", motivo = "Servir"},
		{npc = "pescador", accion = "ir", objetivo = "castillo", motivo = "Lugar que no existe"},
	]
	jugador.global_position = Vector3(0, 0.05, 6)
	aldeanos.planificar_si_falta()
	await esperar_hasta(func(): return not llamadas_plan.is_empty() and not aldeanos.planificando, 60)
	comprobar(llamadas_plan.size() == 1 and historia.estado.ultimo_plan == [reloj.dia, reloj.franja()], "sin plan para la franja actual se planifica enseguida, con una sola llamada")
	aldeanos.planificar_si_falta()
	await esperar(3)
	comprobar(llamadas_plan.size() == 1, "con la franja ya planificada no se repite la llamada")
	var usuario: String = llamadas_plan[0][1].content
	comprobar("Lugares:" in usuario and "plaza (la plaza)" in usuario and "herrero (Gonzalo)" in usuario and "Ahora: rutina." in usuario and "día 1, mañana" in usuario, "el planificador recibe momento, lugares y aldeanos")
	var esquema_plan: Dictionary = PromptsIA.esquema_planificador(historia.premisa.npcs.keys())
	comprobar(esquema_plan.properties.planes.required.size() == 5 and esquema_plan.properties.planes.properties.has("guardia"), "el esquema exige un plan por aldeano")
	comprobar(aldeanos.estado_de(&"pescador").accion == "rutina", "un lugar inexistente se convierte en rutina")
	comprobar(aldeanos.estado_de(&"panadera").accion == "ir" and not aldeanos.estado_de(&"panadera").llegado, "la panadera recibe su orden")
	await esperar(6)
	comprobar(not colision_activa(npc("Panadera")) and npc("Panadera").esta_caminando(), "lejos de su puesto la panadera camina y no es sólida")
	var llega := await esperar_hasta(func(): return aldeanos.estado_de(&"panadera").llegado)
	comprobar(llega and plano(npc("Panadera").global_position).distance_to(plano(pos_lugar("plaza"))) < 1.0, "la panadera llega a la plaza")
	var encuentro := await esperar_hasta(func(): return aldeanos.estado_de(&"herrero").llegado)
	comprobar(encuentro and plano(npc("Herrero").global_position).distance_to(plano(npc("Tabernero").global_position)) <= aldeanos.DISTANCIA_ENCUENTRO + 0.3, "el herrero llega hasta el tabernero")
	comprobar(historia.estado.hechos.any(func(h): return "Gonzalo fue a hablar con Anselmo" in h), "el encuentro queda como hecho para el narrador")
	var hallado := await esperar_hasta(func(): return aldeanos.estado_de(&"guardia").llegado)
	var guardia := npc("Guardia")
	comprobar(hallado and guardia.jugador_cerca and guardia.get_node("Aviso").visible and guardia.get_node("Aviso").text == "[F] Hablar", "el guardia encuentra al viajero y ofrece hablar")
	jugador.global_position = Vector3(0, 0.05, -3)
	await esperar(10)
	comprobar(guardia.get_node("Aviso").visible and guardia.get_node("Aviso").text == "¡!", "si el viajero se aleja, el guardia muestra «¡!» y espera")
	aldeanos.cumplido(&"guardia")
	comprobar(aldeanos.estado_de(&"guardia").accion == "rutina", "tras hablar con él, el guardia vuelve a su rutina")
	comprobar("Comprar fruta" in aldeanos.descripcion(&"panadera") and "mañana" in aldeanos.descripcion(&"panadera"), "la conversación sabe qué hace y a qué hora")

	# De vuelta al puesto: sólida de nuevo (el viajero, lejos, para no frenarla).
	jugador.global_position = Vector3(0, 0.05, 25)
	await esperar(4)
	aldeanos.aplicar_planes([{npc = "panadera", accion = "trabajar", objetivo = "", motivo = "Hornear"}])
	await esperar_hasta(func(): return aldeanos.estado_de(&"panadera").llegado)
	await esperar(3)
	comprobar(plano(npc("Panadera").global_position).distance_to(plano(npc("Panadera").puesto)) < 0.3 and colision_activa(npc("Panadera")), "en su puesto la panadera vuelve a ser sólida")

	# Reloj: el cambio de franja replanifica (con un plan neutro).
	planes = []
	var antes_plan := llamadas_plan.size()
	aldeanos._ultimo_plan_ms = -1000000
	var franjas: Array = []
	reloj.franja_cambiada.connect(func(d, f): franjas.append([d, f]))
	reloj.escala = 400.0
	await esperar_hasta(func(): return franjas.size() >= 1, 120)
	reloj.escala = 1.0
	await esperar(4)
	comprobar(not franjas.is_empty() and franjas[0][1] == 1 and reloj.nombre_franja() == "mediodía", "el reloj pasa de la mañana al mediodía")
	comprobar(llamadas_plan.size() > antes_plan, "cada franja nueva vuelve a planificar")
	comprobar(historia.estado.reloj.dia == reloj.dia and historia.estado.has("aldeanos"), "hora y aldeanos se guardan con la historia")

	# Fuera de escena: llegada abstracta y recuperación al volver.
	mundo.queue_free()
	await esperar(3)
	comprobar(aldeanos.nodos.is_empty(), "al salir de la aldea no quedan nodos registrados")
	aldeanos.aplicar_planes([{npc = "herrero", accion = "ir", objetivo = "mercado", motivo = "Ver la fruta"}])
	var herrero_estado: Dictionary = aldeanos.estado_de(&"herrero")
	comprobar(herrero_estado.llegado and Vector2(herrero_estado.pos[0], herrero_estado.pos[1]).distance_to(plano(pos_lugar("mercado"))) < 0.01, "ausente, el herrero llega al mercado en abstracto")
	await cargar_mundo()
	await esperar(4)
	comprobar(plano(npc("Herrero").global_position).distance_to(plano(pos_lugar("mercado"))) < 0.5, "al volver a la aldea el herrero está en el mercado")
	comprobar(plano(npc("Guardia").global_position).distance_to(plano(npc("Guardia").puesto)) < 0.5, "en rutina el guardia reaparece al inicio de su ronda")

	# Nueva historia: todos a su rutina.
	historia.reiniciar()
	await esperar(3)
	comprobar(aldeanos.estado_de(&"herrero").accion == "rutina" and reloj.dia == 1 and reloj.segundos < 1.0, "una historia nueva reinicia órdenes y reloj")
	ia.simulador = Callable()
	print("RESULTADO_IA_CAPA2: ", fallos, " fallos")
	quit(0 if fallos == 0 else 1)
