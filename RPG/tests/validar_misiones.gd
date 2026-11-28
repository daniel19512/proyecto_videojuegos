extends SceneTree
## Recorre el catálogo con acontecimientos controlados. La regresión de oficios prueba sus emisores.

var misiones: CanvasLayer
var mundo: Node
var bolsa: GDScript
var oficios: GDScript
var reloj: Node
var historia: Node
var fallos := 0
var total := 0
var terminadas := 0
var perfil := "prueba"


func _initialize() -> void:
	_validar.call_deferred()


func _validar() -> void:
	misiones = root.get_node("Misiones")
	mundo = root.get_node("EstadoMundo")
	historia = root.get_node("Historia")
	reloj = root.get_node("Reloj")
	reloj.escala = 0.0
	oficios = load("res://scripts/vida/oficios.gd")
	bolsa = oficios.Bolsa
	for argumento in OS.get_cmdline_user_args():
		if argumento.begins_with("perfil="):
			perfil = argumento.trim_prefix("perfil=").validate_filename()
	mundo.ruta = "res://logs/misiones_%s.save" % perfil
	historia.ruta_guardado = "res://logs/misiones_historia_%s.json" % perfil
	if "leer" in OS.get_cmdline_user_args():
		_reapertura()
		return
	if "interfaz" in OS.get_cmdline_user_args():
		await _interfaz()
		return
	var tipos := {"principal": 0, "intro": 0, "personal": 0}
	for id in misiones.catalogo:
		var m: Dictionary = misiones.ficha(id)
		tipos[m.tipo] += 1
		_comprobar(historia.tiene_npc(m.npc) and historia.tiene_npc(m.get("receptor", m.npc)), id + " tiene interlocutores válidos")
		_comprobar(not m.has("receta") or oficios.RECETAS.has(m.get("receta")), id + " tiene receta válida")
		for objetivo in m.objetivos:
			_validar_objetivo(objetivo)
	_comprobar(tipos == {"principal": 15, "intro": 21, "personal": 21}, "57 misiones repartidas en las tres series")
	_comprobar(not misiones.entregar("principal_1", "guardia"), "no se entrega sin aceptar")
	_comprobar("Conociendo los caminos" in misiones.consulta_dialogo("guardia", "trabajo"), "la consulta ofrece un encargo válido")
	_comprobar(misiones.estado("principal_1") == "disponible" and misiones.consulta_dialogo("guardia", "entregar").is_empty(), "una consulta nunca ejecuta acciones")
	_comprobar(misiones.estado("principal_2") == "bloqueada", "la historia sigue el orden de capítulos")
	var recado: Node = load("res://scripts/npc/recado_pan.gd").new()
	root.add_child(recado)
	var antes := int(mundo.datos.monedas)
	recado.lineas_para(&"panadera")
	recado.lineas_para(&"guardia")
	recado.lineas_para(&"panadera")
	recado.lineas_para(&"panadera")
	_comprobar(misiones.estado("recado_pan") == "completada" and mundo.datos.monedas == antes + 12, "recado original conserva progreso y premio único")
	recado.queue_free()
	terminadas = 1
	_materiales_llenos()
	for npc in historia.nombres_npc():
		misiones.conversar(npc)
	for id in misiones.catalogo:
		if misiones.ficha(id).tipo == "intro" and id not in ["recado_pan", "intro_elias"]:
			_completar(id)
	for id in misiones.catalogo:
		var m: Dictionary = misiones.ficha(id)
		if m.tipo != "personal":
			continue
		_poner(misiones.ficha("recado_pan" if m.npc == "panadera" else "intro_" + m.npc).gustos[0], 1)
		var casilla := _buscar(misiones.ficha("recado_pan" if m.npc == "panadera" else "intro_" + m.npc).gustos[0])
		var amistad := int(misiones.relacion(m.npc).amistad)
		misiones.regalar(m.npc, casilla)
		_comprobar(misiones.relacion(m.npc).amistad == amistad + 10, m.npc + " reconoce su favorito")
		_comprobar("Ya compartiste" in misiones.regalar(m.npc, casilla), m.npc + " limita regalos diarios")
		_completar(id)
	for i in range(1, 16):
		_completar("principal_%d" % i)
	_comprobar(terminadas == 57, "las 57 misiones completan su flujo")
	var dinamica: String = misiones.solicitar("elias")
	_comprobar(not dinamica.is_empty() and misiones.solicitar("elias") == dinamica, "una oferta persistente por NPC")
	_comprobar(not misiones.aplicar_texto_encargo(dinamica, {"titulo": "falso", "motivo": "texto", "monedas": 9000}), "la IA no puede proponer un pago")
	var ia := root.get_node("IA")
	ia.simulador = func(_mensajes, _esquema): return {"titulo": "Muelas listas", "motivo": "Quiero preparar la próxima molienda."}
	await misiones.ambientar_encargo(dinamica)
	ia.simulador = Callable()
	_comprobar(misiones.ficha(dinamica).titulo == "Muelas listas", "la IA simulada solo redacta")
	_comprobar(misiones.aceptar(dinamica, "elias"), "acepta instancia repetible")
	_comprobar(misiones.abandonar(dinamica, "elias") and misiones.aceptar(dinamica, "elias"), "retoma la misma instancia")
	_comprobar(not misiones.materiales(dinamica, "elias"), "reactivar conserva el registro de provisión")
	_resolver(dinamica, "elias")
	_comprobar(misiones.entregar(dinamica, "elias"), "la instancia se puede entregar")
	_comprobar(misiones.solicitar("elias").is_empty(), "espera un día para una oferta nueva")
	reloj.tiempo_juego += reloj.DURACION_DIA
	var nueva: String = misiones.solicitar("elias")
	_comprobar(not nueva.is_empty() and nueva != dinamica, "el día siguiente crea otra instancia")
	_comprobar(not misiones.compartir_recuerdo("elias", "guardia").is_empty(), "el receptor aprende un acontecimiento real")
	_comprobar(misiones.compartir_recuerdo("elias", "guardia").is_empty(), "la charla no duplica el rumor")
	_comprobar(mundo.guardar(), "guardado escrito correctamente")
	_resumen()


func _materiales_llenos() -> void:
	var id := "intro_elias"
	var casillas: Array = bolsa.jugador()
	var mochila := casillas.duplicate(true)
	for i in casillas.size():
		casillas[i] = {"id": "piedra", "cantidad": 1}
	_comprobar(misiones.ofrecer(id, "elias") and misiones.aceptar(id, "elias"), "mochila llena conserva la aceptación")
	_comprobar(not misiones.materiales(id, "elias") and not mundo.objeto("@encargos_oficio", id).get("materiales", false), "falta de espacio conserva la provisión pendiente")
	casillas.assign(mochila)
	_comprobar(misiones.materiales(id, "elias") and not misiones.materiales(id, "elias"), "recoge los materiales después una sola vez")
	_poner("harina", 1)
	_comprobar(not misiones.entregar(id, "elias"), "poseer harina no equivale a molerla")
	reloj.tiempo_juego += 10.0 * reloj.DURACION_DIA
	_comprobar(misiones.estado(id) in ["aceptada", "en_progreso"], "una misión no caduca después de diez días")
	_comprobar("EXP" in oficios.producir("moler", "molienda", 1) and misiones.estado(id) == "lista", "el resultado del oficio actualiza la misión")
	_comprobar(misiones.entregar(id, "elias"), "la entrega consume una sola harina")
	terminadas += 1


func _completar(id: String) -> void:
	var m: Dictionary = misiones.ficha(id)
	var receptor: String = m.get("receptor", m.npc)
	_comprobar(misiones.ofrecer(id, m.npc) and misiones.aceptar(id, m.npc), id + " oferta y aceptación")
	_comprobar(not misiones.entregar(id, "npc_incorrecto"), id + " exige receptor correcto")
	_resolver(id, receptor)
	_comprobar(misiones.estado(id) == "lista", id + " alcanza la fase lista")
	if misiones.entregar(id, receptor):
		terminadas += 1
	_comprobar(misiones.estado(id) == "completada", id + " completa")
	var saldo := int(mundo.datos.monedas)
	_comprobar(not misiones.entregar(id, receptor) and mundo.datos.monedas == saldo, id + " solo premia una vez")


func _resolver(id: String, receptor: String) -> void:
	for objetivo in misiones.ficha(id).objetivos:
		_cumplir(id, objetivo, receptor)


func _cumplir(id: String, objetivo: Array, receptor: String) -> void:
	var clave: String = objetivo[1]
	var cantidad := int(objetivo[2])
	match objetivo[0]:
		"cualquiera":
			for opcion in objetivo[3]:
				_cumplir(id, opcion, receptor)
		"descubrir", "reliquia":
			var datos: Dictionary = mundo.objeto("@descubrimientos", clave)
			datos.descubierto = true
			if objetivo[0] == "reliquia":
				datos.reliquia_recogida = true
		"entregar":
			_poner(clave.get_slice("/", 0), cantidad)
		"nivel":
			mundo.objeto("@jugador", "profesiones")[clave] = (cantidad - 1) * oficios.XP_POR_NIVEL
		"mision", "intro", "confianzas":
			pass
		"decision":
			misiones._npc = receptor
			misiones._decidir(id, 1)
		"feria":
			misiones._npc = receptor
			misiones._abrir_feria()
			for puesto in ["feria_campo", "feria_taller", "feria_caminos"]:
				misiones.visitar_puesto(puesto)
		_:
			mundo.registrar_actividad(objetivo[0], clave, cantidad)


func _validar_objetivo(o: Array) -> void:
	if o[0] in ["fabricar", "entregar", "recoger", "extraer", "sembrar", "cosechar"]:
		for objeto in String(o[1]).split("/"):
			_comprobar(not bolsa.Catalogo.ficha(objeto).is_empty(), "objeto definido: " + objeto)
	if o[0] == "hablar":
		_comprobar(historia.tiene_npc(o[1]), "interlocutor definido: " + str(o[1]))
	if o[0] == "cualquiera":
		for opcion in o[3]:
			_validar_objetivo(opcion)


func _poner(objeto: String, cantidad: int) -> void:
	var casillas: Array = bolsa.jugador()
	if not bolsa.anadir(casillas, objeto, cantidad):
		casillas.assign(bolsa.crear(16))
		bolsa.anadir(casillas, objeto, cantidad)


func _buscar(id: String) -> int:
	var casillas: Array = bolsa.jugador()
	for i in casillas.size():
		if casillas[i] is Dictionary and casillas[i].id == id:
			return i
	return -1


func _reapertura() -> void:
	var cargado: bool = mundo.cargar()
	_comprobar(cargado, "carga de proceso independiente")
	if not cargado:
		_resumen()
		return
	_comprobar(misiones.estado("principal_15") == "completada" and misiones.feria_abierta(), "desenlace y feria persistentes")
	_comprobar(misiones.estado("personal_leonor") == "completada", "historia personal persistente")
	_comprobar(misiones.relacion("leonor").amistad >= 20, "amistad persistente")
	_comprobar(misiones.relacion("leonor").confianza >= 15, "confianza persistente")
	_comprobar(not mundo.zona("@rumores").guardia.registros.is_empty(), "rumor persistente")
	_comprobar(misiones.solicitar("elias").begins_with("encargo_"), "instancia dinámica persistente")
	_comprobar(not misiones.entregar("principal_15", "guardia"), "guardado no repite la recompensa final")
	_resumen()


func _interfaz() -> void:
	var escena: Node3D = load("res://scenes/mundo.tscn").instantiate()
	root.add_child(escena)
	current_scene = escena
	var jugador: CharacterBody3D = escena.get_node("Jugador")
	var guardia: Node3D = escena.get_node("NPCs/Guardia")
	await _esperar(12)
	jugador.global_position = guardia.global_position + Vector3(0.8, 0.35, 0)
	await _esperar(16)
	await _mando(JOY_BUTTON_A)
	_comprobar(paused and misiones._panel.is_visible_in_tree(), "A abre el menú al acercarse a Bruno")
	_comprobar(root.gui_get_focus_owner().text == "Conversar", "entrada con foco de mando")
	for intento in 8:
		if root.gui_get_focus_owner().text == "Bienvenido a la Aldea":
			break
		await _mando(JOY_BUTTON_DPAD_DOWN)
	_comprobar(root.gui_get_focus_owner().text == "Bienvenido a la Aldea", "la cruceta alcanza la primera misión")
	await _mando(JOY_BUTTON_A)
	_comprobar(misiones.estado("principal_1") == "ofrecida", "A abre el ofrecimiento")
	await _capturar("mision")
	await _mando(JOY_BUTTON_A)
	_comprobar(misiones.estado("principal_1") == "aceptada", "A confirma la aceptación")
	await _mando(JOY_BUTTON_B)
	_comprobar(not paused, "B regresa al mundo")
	var diario := root.get_node("Diario")
	diario.abrir(true)
	await _mando(JOY_BUTTON_DPAD_RIGHT)
	await _mando(JOY_BUTTON_A)
	_comprobar(misiones.seguida() == "principal_1", "A cambia el seguimiento en el diario")
	await _mando(JOY_BUTTON_B)
	_poner("pan", 1)
	await _mando(JOY_BUTTON_A)
	for intento in 12:
		if root.gui_get_focus_owner().text == "Dar un regalo":
			break
		await _mando(JOY_BUTTON_DPAD_DOWN)
	await _mando(JOY_BUTTON_A)
	for intento in 8:
		if root.gui_get_focus_owner().text == "Pan":
			break
		await _mando(JOY_BUTTON_DPAD_DOWN)
	await _mando(JOY_BUTTON_A)
	_comprobar(bolsa.cantidad(bolsa.jugador(), "pan") == 1, "la vista de confirmación conserva el regalo")
	await _mando(JOY_BUTTON_A)
	_comprobar(bolsa.cantidad(bolsa.jugador(), "pan") == 0 and misiones.relacion("guardia").amistad == 10, "A confirma el regalo favorito de Bruno")
	await _mando(JOY_BUTTON_B)
	for i in range(1, 15):
		mundo.objeto("@misiones", "principal_%d" % i).estado = "completada"
	_comprobar(misiones.ofrecer("principal_15", "guardia") and misiones.aceptar("principal_15", "guardia"), "Bruno ofrece el desenlace")
	misiones._abrir_feria()
	var actividades := escena.get_node("Region/ActividadesVida")
	for id in ["feria_campo", "feria_taller", "feria_caminos"]:
		var punto: Node3D = actividades.get_node(id)
		jugador.global_position = punto.global_position + Vector3(-0.55, 0.17, 0)
		await _esperar(12)
		await _mando(JOY_BUTTON_A)
		_comprobar(mundo.objeto("@social", "feria").get(id, false), "A visita puesto " + id)
	await _capturar("feria")
	_comprobar(misiones.entregar("principal_15", "guardia") and not paused, "el desenlace devuelve el mundo jugable")
	diario.abrir(true)
	_comprobar("Una comunidad unida" in diario.texto_plano(), "el diario refleja el desenlace y responde a la cruceta")
	await _capturar("diario")
	await _mando(JOY_BUTTON_B)
	_comprobar(not paused, "B cierra el diario")
	_resumen()


func _esperar(fotogramas: int) -> void:
	for i in fotogramas:
		await physics_frame
	await process_frame


func _mando(indice: JoyButton) -> void:
	for presionado in [true, false]:
		var evento := InputEventJoypadButton.new()
		evento.button_index = indice
		evento.pressed = presionado
		Input.parse_input_event(evento)
		await process_frame
		await process_frame


func _capturar(nombre: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	var imagen := root.get_texture().get_image()
	_comprobar(imagen != null and imagen.save_png("res://logs/misiones_%s_%s.png" % [perfil, nombre]) == OK, "fotograma renderizado " + nombre)


func _comprobar(condicion: bool, mensaje: String) -> void:
	total += 1
	if not condicion:
		fallos += 1
		push_error(mensaje)


func _resumen() -> void:
	print("Misiones: %d fallos / %d comprobaciones (%d misiones completadas)" % [fallos, total, terminadas])
	quit(0 if fallos == 0 else 1)

