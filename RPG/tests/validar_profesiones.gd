extends SceneTree

var oficios: GDScript
var bolsa: GDScript
var interfaz: Node
var estado: Node
var gestor: Node
var fallos := 0
var controles := 0


func _initialize() -> void:
	_validar.call_deferred()


func _validar() -> void:
	oficios = load("res://scripts/vida/oficios.gd")
	bolsa = oficios.Bolsa
	interfaz = root.get_node("InterfazVida")
	estado = root.get_node("EstadoMundo")
	gestor = root.get_node("GestorRegiones")
	var perfil := "local"
	for argumento in OS.get_cmdline_user_args():
		if argumento.begins_with("perfil="):
			perfil = argumento.trim_prefix("perfil=").validate_filename()
	estado.ruta = "res://logs/profesiones_%s.save" % perfil
	root.get_node("Historia").ruta_guardado = "res://logs/profesiones_historia_%s.json" % perfil
	root.get_node("Reloj").escala = 0.0

	if "leer" in OS.get_cmdline_user_args():
		comprobar(estado.cargar(), "Archivo cargado en un proceso nuevo")
		comprobar(oficios.xp("molienda") == 24 and oficios.nivel("panaderia") == 2, "XP y nivel recuperados")
		comprobar(bolsa.cantidad(bolsa.jugador(), "pan") == 1 and bolsa.cantidad(bolsa.jugador(), "harina") == 0, "Productos y consumo recuperados")
		comprobar(oficios.pendientes().get("carpa_dorada") == 2, "Captura reservada recuperada")
		comprobar(estado.objeto("@encargos_oficio", "demo_pan").get("completo"), "Encargo recuperado")
		_resumen()
		return

	await _viajar("res://scenes/mundo.tscn", "", "Aldea", true)
	var casillas: Array = bolsa.jugador()
	comprobar("Harina" in oficios.requisitos("hogaza", "panaderia", casillas.duplicate(true)), "Sin harina se bloquea la hogaza")
	comprobar(oficios.entregar_materiales("demo_pan", {"hierbas": 1}), "Encargo entrega materiales a la mochila")
	comprobar(not oficios.entregar_materiales("demo_pan", {"hierbas": 1}), "Materiales entregados una sola vez")
	await _viajar("res://scenes/mundo_campos_granjas.tscn", "campos_aldea_norte", "CamposYGranjas")
	var bancal := current_scene.get_node("Region/ActividadesVida/bancal_01") as Node3D
	var agricultor := current_scene.get_node("Jugador") as CharacterBody3D
	agricultor.global_position = bancal.global_position + Vector3(0, 0.12, 0)
	await _fijar(8)
	for indice in [0, 3, 1]:
		bolsa.elegir(indice)
		await _boton(JOY_BUTTON_A)
	root.get_node("Reloj").tiempo_juego += 46.0
	await _boton(JOY_BUTTON_A)
	comprobar(bolsa.cantidad(casillas, "trigo") == 2, "A prepara, siembra, riega y cosecha trigo")
	await _viajar("res://scenes/mundo.tscn", "aldea_campos_sur", "Aldea")
	await _viajar("res://scenes/interiores/molino_e12.tscn", "interior_e12", "InteriorE12")
	await _estacion("moler", true, true)
	comprobar(bolsa.cantidad(casillas, "trigo") == 2 and oficios.xp("molienda") == 0, "B cancela y conserva todo")
	await _estacion("moler", true)
	await _estacion("moler", true)
	comprobar(bolsa.cantidad(casillas, "harina") == 2 and bolsa.cantidad(casillas, "trigo") == 0, "Muelas entregan dos harinas y consumen el trigo")
	await _viajar("res://scenes/mundo.tscn", "aldea_e12", "Aldea")
	await _viajar("res://scenes/interiores/panaderia_e02.tscn", "interior_e02", "InteriorE02")
	comprobar("nivel 2" in oficios.requisitos("horneada", "panaderia", casillas.duplicate(true)), "La hornada queda bloqueada hasta nivel 2")
	await _estacion("hogaza")
	await _estacion("hogaza")
	comprobar(oficios.nivel("panaderia") == 2 and not "nivel" in oficios.requisitos("horneada", "panaderia", casillas.duplicate(true)), "La hornada se desbloquea al subir de nivel")
	comprobar(oficios.entregar_producto("demo_pan", "pan", 1, 4), "NPC recibe una hogaza")
	comprobar(not oficios.entregar_producto("demo_pan", "pan", 1, 4), "El encargo solo paga una vez")

	await _viajar("res://scenes/mundo.tscn", "aldea_e02", "Aldea")
	await _viajar("res://scenes/interiores/carpinteria_e04.tscn", "interior_e04", "InteriorE04")
	bolsa.anadir(casillas, "madera", 2)
	await _estacion("aserrar", true)
	await _estacion("aserrar", true)
	await _estacion("ensamblar", true)
	comprobar(bolsa.cantidad(casillas, "tablas") == 2 and bolsa.cantidad(casillas, "cuenco") == 1, "El banco transforma madera y tablas")

	await _viajar("res://scenes/mundo.tscn", "aldea_e04", "Aldea")
	await _viajar("res://scenes/interiores/herreria_e03.tscn", "interior_e03", "InteriorE03")
	bolsa.anadir(casillas, "hierro", 1)
	bolsa.anadir(casillas, "carbon", 1)
	bolsa.anadir(casillas, "madera", 1)
	await _estacion("refinar")
	await _estacion("forjar_hacha")
	comprobar(bolsa.cantidad(casillas, "hacha") == 1 and bolsa.cantidad(casillas, "lingote") == 0, "Se fabrica el hacha canónica")
	comprobar("Ya llevas" in oficios.requisitos("forjar_hacha", "herreria", casillas.duplicate(true)), "No repite una herramienta presente")
	await _viajar("res://scenes/mundo.tscn", "aldea_e03", "Aldea")
	await _viajar("res://scenes/interiores/taberna_e01.tscn", "taberna_e01_entrada", "TabernaE01")
	bolsa.anadir(casillas, "trigo", 1)
	await _estacion("cerveza_suave")
	comprobar(bolsa.cantidad(casillas, "cerveza") == 2 and bolsa.cantidad(casillas, "hierbas") == 0, "La taberna entrega dos cervezas")
	await _viajar("res://scenes/mundo.tscn", "aldea_taberna_e01", "Aldea")
	var comercio: GDScript = load("res://scripts/vida/comercio.gd")
	var cofre := current_scene.get_node("Region/ActividadesVida/cofre_mercado")
	var jugador := current_scene.get_node("Jugador") as CharacterBody3D
	jugador.global_position = cofre.global_position + Vector3(0, 0.08, 0)
	await _fijar(8)
	await _boton(JOY_BUTTON_A)
	comprobar(interfaz.contexto == "cofre", "A abre el cofre del Mercado")
	for i in casillas.size():
		if casillas[i] is Dictionary and casillas[i].id == "pan":
			var ranura := interfaz._contenido.find_child("inv%d" % i, true, false) as Button
			ranura.grab_focus()
			await _boton(JOY_BUTTON_A)
			break
	var pan_guardado: bool = bolsa.cantidad(casillas, "pan") == 0
	await _boton(JOY_BUTTON_B)
	comprobar(pan_guardado and bolsa.cantidad(cofre.estado.casillas, "pan") == 1, "El cofre real almacena pan producido")
	comprobar(comercio.comprar("mercado", "cana").begins_with("Compraste"), "La caña se compra en Mercado")
	var punto := current_scene.get_node("Aldea/PuntoPesca")
	jugador.global_position = punto.global_position + Vector3(0, 0.08, 0)
	await _fijar(8)
	await _boton(JOY_BUTTON_A)
	var panel := punto.get_node("MinijuegoPesca")
	comprobar(paused and panel.visible, "A abre pesca con caña")
	await _boton(JOY_BUTTON_A)
	panel.logica.puntuacion = 25
	panel.logica.tiempo_restante = 0.0
	await _fijar(3)
	panel.partida_terminada.emit(25)
	comprobar(bolsa.cantidad(casillas, "pescado") == 1 and oficios.xp("pesca") == 6, "La pesca no duplica su resultado")
	await _boton(JOY_BUTTON_B)
	for i in casillas.size():
		if casillas[i] is Dictionary and casillas[i].id == "pescado":
			comprobar(comercio.vender(i).begins_with("Vendiste"), "La captura se vende")
			break
	comprobar(bolsa.cantidad(casillas, "cana") == 1, "La caña se conserva")
	for i in casillas.size():
		if casillas[i] == null:
			casillas[i] = {"id": "piedra", "cantidad": 24}
	casillas[1] = {"id": "harina", "cantidad": 2}
	comprobar(oficios.producir("hogaza", "panaderia", 1) == "Mochila llena."
		and bolsa.cantidad(casillas, "harina") == 2 and oficios.xp("panaderia") == 24, "Sin espacio no consume ingredientes ni da XP")
	casillas[1] = {"id": "piedra", "cantidad": 24}
	oficios.capturar(60)
	comprobar(oficios.pendientes().get("carpa_dorada") == 2, "Mochila llena reserva captura")
	await _viajar("res://scenes/mundo_campos_granjas.tscn", "campos_aldea_norte", "CamposYGranjas")
	await _viajar("res://scenes/mundo.tscn", "aldea_campos_sur", "Aldea")
	cofre = current_scene.get_node("Region/ActividadesVida/cofre_mercado")
	var recuperado := false
	for i in cofre.estado.casillas.size():
		var pila: Variant = cofre.estado.casillas[i]
		if pila is Dictionary and pila.id == "pan":
			var liberar := casillas.size() - 1
			casillas[liberar] = null
			recuperado = bolsa.transferir(cofre.estado.casillas, i, casillas, 1)
			break
	comprobar(recuperado and oficios.xp("molienda") == 24 and bolsa.cantidad(casillas, "pan") == 1, "El cofre y la XP persisten al volver")
	estado.automatico = true
	await _boton(JOY_BUTTON_B)
	var pausa := root.get_node("MenuPausa")
	comprobar(pausa.abierto, "B abre el menú de pausa desde el mundo")
	var foco := root.gui_get_focus_owner()
	await _boton(JOY_BUTTON_DPAD_DOWN)
	comprobar(root.gui_get_focus_owner() != foco, "La cruceta mueve el foco de pausa")
	await _boton(JOY_BUTTON_DPAD_DOWN)
	await _boton(JOY_BUTTON_DPAD_DOWN)
	var guardar := root.gui_get_focus_owner() as Button
	comprobar(guardar != null and guardar.text == "Guardar partida", "La cruceta lleva a Guardar partida")
	await _boton(JOY_BUTTON_A)
	comprobar(FileAccess.file_exists(estado.ruta), "A en Guardar partida escribe el archivo")
	await _boton(JOY_BUTTON_A)
	comprobar(pausa.get_child_count() == 1, "A cierra el aviso de guardado")
	estado.automatico = false
	await _boton(JOY_BUTTON_B)
	comprobar(not paused, "B devuelve el control al mundo desde pausa")
	await _boton(JOY_BUTTON_Y)
	var consulta := interfaz._contenido.find_child("oficios", true, false) as Button
	consulta.grab_focus()
	await _boton(JOY_BUTTON_A)
	var evento := InputEventJoypadMotion.new()
	evento.axis = JOY_AXIS_LEFT_Y
	evento.axis_value = 0.85
	Input.parse_input_event(evento)
	await process_frame
	comprobar(root.gui_get_focus_owner().name == &"pesca", "El stick navega las profesiones")
	await _boton(JOY_BUTTON_A)
	comprobar(interfaz.contexto == "oficios" and interfaz._oficio_consultado == "pesca", "A consulta el oficio enfocado")
	evento = evento.duplicate() as InputEventJoypadMotion
	evento.axis_value = 0.0
	Input.parse_input_event(evento)
	await _boton(JOY_BUTTON_B)
	comprobar(not paused, "B cierra la consulta de oficios")
	_resumen()


func _estacion(id: String, precision := false, cancelar := false) -> void:
	var punto := current_scene.get_node("PuntoMinijuego") as Node3D
	var jugador := current_scene.get_node("Jugador") as CharacterBody3D
	jugador.global_position = punto.global_position + Vector3(0, 0.07, 0)
	jugador.velocity = Vector3.ZERO
	await _fijar(8)
	await _boton(JOY_BUTTON_A)
	comprobar(interfaz.contexto == "estacion" and paused, id + ": A abre estación desde el mundo")
	var receta := interfaz._contenido.find_child(id, true, false) as Button
	comprobar(receta != null and not receta.disabled, id + ": receta habilitada")
	if receta == null or receta.disabled:
		interfaz.cerrar()
		return
	comprobar(root.gui_get_focus_owner() == receta, id + ": foco inicial en receta disponible")
	await _boton(JOY_BUTTON_A)
	var panel: MinijuegoBase = punto.minijuego
	comprobar(panel.estado == panel.Estado.INSTRUCCIONES, id + ": A selecciona")
	if cancelar:
		await _boton(JOY_BUTTON_B)
		comprobar(not paused and not panel.visible, id + ": B cierra antes de empezar")
		return
	await _boton(JOY_BUTTON_A)
	var exp_anterior: int = oficios.xp(punto.estacion)
	if precision:
		var velocidad := 0.6 if id == "moler" else 0.85
		for _i in (1 if id == "moler" else 2):
			panel.logica.tiempo_restante = 12.0 - 0.5 / velocidad
			await _boton(JOY_BUTTON_A)
	else:
		match punto.estacion:
			"panaderia":
				panel.logica.doradas = 1
			"herreria":
				panel.logica.piezas = 1
			"cerveza":
				panel.logica.recetas_completadas = 1
		panel.logica.tiempo_restante = 0.0
	await _fijar(3)
	panel.partida_terminada.emit(10)
	comprobar(panel.estado == panel.Estado.RESULTADO and oficios.xp(punto.estacion) == exp_anterior + oficios.RECETAS[id].xp, id + ": liquida una sola vez")
	await _boton(JOY_BUTTON_B)
	comprobar(not paused and not panel.visible, id + ": B cierra resultado")


func _viajar(ruta: String, entrada: String, region: String, inicial := false) -> void:
	if inicial:
		change_scene_to_file(ruta)
		await scene_changed
	else:
		comprobar(gestor.solicitar(ruta, entrada), "Solicita " + region)
		for i in 300:
			if not gestor.en_transicion:
				break
			await process_frame
	await _fijar(8)
	comprobar(String(gestor.region_actual) == region, "En " + region)


func _fijar(cantidad: int) -> void:
	for _i in cantidad:
		await physics_frame


func _boton(indice: JoyButton) -> void:
	var evento := InputEventJoypadButton.new()
	evento.button_index = indice
	evento.pressed = true
	Input.parse_input_event(evento)
	await process_frame
	await process_frame
	var soltar := evento.duplicate() as InputEventJoypadButton
	soltar.pressed = false
	Input.parse_input_event(soltar)
	await process_frame


func comprobar(condicion: bool, mensaje: String) -> void:
	controles += 1
	if not condicion:
		fallos += 1
	print(("OK: " if condicion else "FALLO: ") + mensaje)


func _resumen() -> void:
	print("PROFESIONES: %d fallos / %d comprobaciones" % [fallos, controles])
	quit(fallos)

