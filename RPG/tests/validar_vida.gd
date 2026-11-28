extends SceneTree
## Dos procesos prueban la escritura y el arranque con archivos de perfil aislados.

const ALDEA := "res://scenes/mundo.tscn"
const CAMPOS := "res://scenes/mundo_campos_granjas.tscn"
const PANADERIA := "res://scenes/interiores/panaderia_e02.tscn"
const BOLSA := "res://scripts/vida/bolsa.gd"
const PARCELA := "res://scripts/vida/parcela.gd"
const COMERCIO := "res://scripts/vida/comercio.gd"

var mundo: Node
var historia: Node
var reloj: Node
var gestor: Node
var interfaz: Node
var bolsa: GDScript
var parcela: GDScript
var comercio: GDScript
var fallos := 0
var controles := 0


func _initialize() -> void:
	_validar.call_deferred()


func _validar() -> void:
	mundo = root.get_node("EstadoMundo")
	historia = root.get_node("Historia")
	reloj = root.get_node("Reloj")
	gestor = root.get_node("GestorRegiones")
	interfaz = root.get_node("InterfazVida")
	bolsa = load(BOLSA)
	parcela = load(PARCELA)
	comercio = load(COMERCIO)
	var perfil := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("perfil="):
			perfil = arg.trim_prefix("perfil=").validate_filename()
	if perfil.is_empty():
		push_error("Indica -- perfil=<nombre> y, para reabrir, añade leer.")
		quit(1)
		return
	mundo.ruta = "res://logs/prueba_vida_%s.save" % perfil
	historia.ruta_guardado = "res://logs/prueba_historia_vida_%s.json" % perfil
	reloj.escala = 0.0
	if "leer" in OS.get_cmdline_user_args():
		if "respaldo" in OS.get_cmdline_user_args():
			var roto := FileAccess.open(mundo.ruta, FileAccess.WRITE)
			roto.store_8(0)
			roto.close()
		comprobar(historia.cargar(), "El JSON de Historia sigue disponible")
		reloj.cargar()
		_instanciar()
		mundo._iniciar()
		for i in 2:
			await process_frame
		comprobar(gestor.en_transicion, "La partida inicia una restauración")
		await _esperar_transicion()
		comprobar(gestor.region_actual == &"CamposYGranjas", "Segunda ejecución restaura Campos")
		comprobar(current_scene.get_node("Jugador").position.distance_to(Vector3(-5.5, 0.02, -22.5)) < 0.3, "Posición restaurada")
		_comprobar_campo()
		comprobar(bolsa.cantidad(bolsa.jugador(), "trigo") == 2, "La cosecha reaparece en bolsa una sola vez")
		comprobar(mundo.datos.monedas == 41, "Saldo recuperado")
		comprobar(historia.estado.npcs.panadera.recuerdos.has("Prueba de memoria de Marta."), "Memoria narrativa recuperada")
		await _viajar(ALDEA, "aldea_campos_sur", &"Aldea")
		comprobar(current_scene.get_node("NPCs/RecadoPan").estado == 3, "El recado completado sobrevive al reinicio")
		_resumen()
		return
	_instanciar()
	for id in bolsa.Catalogo.fichas:
		comprobar(bolsa.Catalogo.icono(id) != null, "Icono disponible: " + id)
	await _viajar(CAMPOS, "campos_aldea_norte", &"CamposYGranjas")
	var casillas: Array = bolsa.jugador()
	var madera: Node = _punto("ramas_granja")
	await _interactuar(madera)
	_punto("canto_granja").actuar()
	_punto("cesta_zanahorias").actuar()
	comprobar(bolsa.cantidad(casillas, "madera") == 2 and bolsa.cantidad(casillas, "piedra") == 2 and bolsa.cantidad(casillas, "zanahoria") == 2, "Recolección y cantidades")
	comprobar(bolsa.mover(casillas, 6, 9, true), "Dividir una pila")
	comprobar(bolsa.mover(casillas, 9, 6), "Combinar una pila")
	var caja: Node = _punto("cofre_campos")
	await _interactuar(caja)
	comprobar(interfaz.contexto == "cofre", "F abre cofre")
	if interfaz.contexto == "cofre":
		interfaz._usar_casilla(6, false)
		comprobar(bolsa.cantidad(caja.estado.casillas, "madera") == 2, "Depositar pila")
		interfaz._usar_casilla(0, true)
		comprobar(bolsa.cantidad(casillas, "madera") == 2, "Recuperar pila")
		interfaz._usar_casilla(6, false)
		await _capturar("cofre", perfil)
		interfaz.cerrar()
	for i in 3:
		var suelo: Dictionary = _punto("bancal_0" + str(i + 1)).estado
		bolsa.elegir(0)
		if i == 0:
			await _interactuar(_punto("bancal_01"))
			comprobar(parcela.etapa(suelo) == 1, "F con la azada prepara un bancal")
		else:
			parcela.actuar(suelo)
		bolsa.elegir(3 + i)
		parcela.actuar(suelo)
		if i < 2:
			bolsa.elegir(1)
			parcela.actuar(suelo)
	comprobar(parcela.etapa(_punto("bancal_03").estado) == 2, "Una parcela quedó sin regar")
	await _acercar(_punto("bancal_04"))
	bolsa.elegir(7)
	comprobar(_actividades().soltar(), "Una piedra queda en el suelo")
	await _viajar(ALDEA, "aldea_campos_sur", &"Aldea")
	var marta := current_scene.get_node("NPCs/Panadera") as Node3D
	await _acercar(marta)
	await _tecla(KEY_T)
	comprobar(interfaz.contexto == "tienda" and interfaz.modo == "panaderia", "Marta ofrece su tienda sin reemplazar el diálogo")
	if interfaz.contexto == "tienda":
		interfaz.cerrar()
	await _esperar_fisica()
	bolsa.elegir(8)
	comprobar(_actividades().soltar(), "Se puede dejar un objeto en una zona de diálogo")
	await _tecla(KEY_F)
	comprobar(bolsa.cantidad(casillas, "zanahoria") == 2 and not paused, "Recoger al lado de Marta no abre diálogo con la misma pulsación")
	var recado := current_scene.get_node("NPCs/RecadoPan")
	recado.lineas_para(&"panadera")
	recado.lineas_para(&"guardia")
	recado.lineas_para(&"panadera")
	recado.lineas_para(&"panadera")
	historia.recordar(&"panadera", "Prueba de memoria de Marta.")
	comprobar(mundo.datos.monedas == 42, "El recado paga una sola vez")
	await _viajar(PANADERIA, "interior_e02", &"InteriorE02")
	var tienda: Node = _punto("mostrador_panaderia")
	await _interactuar(tienda)
	comprobar(interfaz.contexto == "tienda", "F abre mostrador de panadería")
	if interfaz.contexto == "tienda":
		await _capturar("tienda", perfil)
		interfaz.cerrar()
	comprobar(comercio.vender(7).begins_with("Vendiste") and mundo.datos.monedas == 44, "Vender actualiza el saldo exacto")
	comprobar(comercio.comprar("mercado", "semilla_trigo").begins_with("Compraste") and mundo.datos.monedas == 41, "Comprar semillas actualiza el saldo exacto")
	comprobar(comercio.stock("mercado", "semilla_trigo") == 11, "Se descuenta una unidad del stock")
	mundo.datos.monedas = 0
	comprobar(comercio.comprar("mercado", "semilla_trigo") == "Te faltan monedas.", "Rechazar compra sin dinero")
	mundo.datos.monedas = 41
	await _viajar(ALDEA, "aldea_e02", &"Aldea")
	var campos: Dictionary = mundo.zona("CamposYGranjas")
	comprobar(parcela.etapa(campos.bancal_01) == 3 and parcela.etapa(campos.bancal_02) == 3, "Dos bancales conservan el riego tras pasar por panadería")
	reloj.escala = 1.0
	reloj._process(46.0)
	reloj.escala = 0.0
	await _viajar(CAMPOS, "campos_aldea_norte", &"CamposYGranjas")
	comprobar(parcela.etapa(_punto("bancal_01").estado) == 5, "El trigo madura mientras el jugador está en Aldea")
	var copia := casillas.duplicate(true)
	for i in casillas.size():
		casillas[i] = {"id": "piedra", "cantidad": 24}
	var suelto := _punto("suelto_1")
	suelto.actuar()
	comprobar(suelto.visible, "Mochila llena conserva objeto del suelo")
	comprobar(comercio.comprar("mercado", "semilla_trigo") == "Inventario lleno.", "Rechazar compra sin espacio")
	comprobar(mundo.datos.monedas == 41 and comercio.stock("mercado", "semilla_trigo") == 11, "El fallo de compra respeta el saldo y stock")
	var madura: Dictionary = _punto("bancal_01").estado
	parcela.actuar(madura)
	comprobar(parcela.etapa(madura) == 5, "Mochila llena conserva cosecha")
	casillas.assign(copia)
	comprobar(parcela.actuar(madura).begins_with("Cosechaste"), "Cosechar trigo")
	comprobar(not parcela.actuar(madura).begins_with("Cosechaste"), "Impedir doble cosecha")
	var cuarta: Node = _punto("bancal_04")
	bolsa.elegir(0)
	parcela.actuar(cuarta.estado)
	bolsa.elegir(3)
	parcela.actuar(cuarta.estado)
	comprobar(parcela.etapa(cuarta.estado) == 2, "Sembrar con el inventario repuesto por el mercado")
	await _viajar(ALDEA, "aldea_campos_sur", &"Aldea")
	await _interactuar(_punto("mercado"))
	comprobar(interfaz.contexto == "tienda" and interfaz.modo == "mercado", "F abre el puesto del mercado")
	if interfaz.contexto == "tienda":
		interfaz.cerrar()
	await _viajar("res://scenes/mundo_bosque.tscn", "bosque_aldea_sur", &"Bosque")
	await _interactuar(_punto("ramas_entrada"))
	await _interactuar(_punto("hierbas_entrada"))
	comprobar(bolsa.cantidad(casillas, "hierbas") == 2 and bolsa.cantidad(casillas, "madera") == 3, "Recolección en Bosque con F")
	await _viajar(ALDEA, "aldea_bosque_norte", &"Aldea")
	await _viajar(PANADERIA, "interior_e02", &"InteriorE02")
	await _viajar(ALDEA, "aldea_e02", &"Aldea")
	await _comprobar_oficios_y_mineria()
	await _viajar(CAMPOS, "campos_aldea_norte", &"CamposYGranjas")
	comprobar(parcela.etapa(_punto("bancal_04").estado) == 2, "La parcela con semillas compradas también persiste")
	await _acercar(_punto("bancal_04"))
	await _capturar("bancales", perfil)
	await _tecla(KEY_I)
	comprobar(interfaz.contexto == "inventario", "I abre mochila")
	if interfaz.contexto == "inventario":
		await _capturar("mochila", perfil)
		await _tecla(KEY_I)
		comprobar(not paused, "I cierra mochila y devuelve controles")
	await _mando(JOY_BUTTON_Y)
	comprobar(interfaz.contexto == "inventario", "Y abre mochila con mando")
	if interfaz.contexto == "inventario":
		await _mando(JOY_BUTTON_DPAD_DOWN)
		await _mando(JOY_BUTTON_A)
		comprobar(bolsa.seleccion().get("id") == "regadera", "Cruceta y A seleccionan una casilla")
		await _mando(JOY_BUTTON_B)
		comprobar(not paused, "B cierra mochila con mando")
		if paused:
			interfaz.cerrar()
	_comprobar_campo()
	comprobar(mundo.guardar(), "Escritura temporal validada")
	comprobar(mundo.guardar(), "Rotación de guardado existente")
	comprobar(mundo.guardar(), "Reemplazo del respaldo anterior")
	_resumen()


func _comprobar_oficios_y_mineria() -> void:
	for tienda in [
		["herreria_e03", "e03", &"InteriorE03", "herreria"],
		["herbolario_e05", "e05", &"InteriorE05", "herbolario"],
	]:
		await _viajar("res://scenes/interiores/%s.tscn" % tienda[0], "interior_" + tienda[1], tienda[2])
		await _interactuar(_punto("mostrador_" + tienda[3]))
		comprobar(interfaz.contexto == "tienda" and interfaz.modo == tienda[3], "Mostrador activo: " + tienda[3])
		if interfaz.contexto == "tienda":
			interfaz.cerrar()
		await _viajar(ALDEA, "aldea_" + tienda[1], &"Aldea")
	await _viajar("res://scenes/mundo_montanas.tscn", "camino_montanas_aldea_oeste", &"Montanas")
	await _interactuar(_punto("cantos_valle"))
	comprobar(bolsa.cantidad(bolsa.jugador(), "piedra") == 3, "Se recoge piedra en Montañas")
	await _viajar("res://scenes/mundo_minas.tscn", "minas_montanas_sur", &"Minas")
	await _interactuar(_punto("cobre_galeria"))
	comprobar(bolsa.cantidad(bolsa.jugador(), "cobre") == 2, "Se extrae cobre con el pico en Minas")
	await _viajar("res://scenes/mundo_montanas.tscn", "montanas_minas_norte", &"Montanas")
	await _viajar(ALDEA, "aldea_camino_este", &"Aldea")


func _comprobar_campo() -> void:
	comprobar(parcela.etapa(_punto("bancal_01").estado) == 1, "La cosecha deja tierra preparada")
	comprobar(parcela.etapa(_punto("bancal_02").estado) == 4, "La zanahoria sigue creciendo")
	comprobar(parcela.etapa(_punto("bancal_03").estado) == 2, "La patata sin regar sigue sembrada")
	comprobar(_punto("suelto_1").visible, "La piedra descartada sigue en Campos")
	comprobar(not _punto("ramas_granja").visible, "El recurso recogido no se reinicia")
	comprobar(bolsa.cantidad(_punto("cofre_campos").estado.casillas, "madera") == 2, "El cofre conserva su contenido")


func _instanciar() -> void:
	var escena: Node = load(ALDEA).instantiate()
	root.add_child(escena)
	current_scene = escena


func _viajar(ruta: String, entrada: String, region: StringName) -> void:
	comprobar(gestor.solicitar(ruta, entrada), "Solicitar viaje a " + region)
	await _esperar_transicion()
	comprobar(gestor.region_actual == region, "Viaje a " + region)


func _esperar_transicion() -> void:
	for i in 240:
		await process_frame
		if not gestor.en_transicion:
			break
	await _esperar_fisica()


func _esperar_fisica() -> void:
	for i in 4:
		await physics_frame


func _actividades() -> Node:
	return current_scene.get_node("Region/ActividadesVida")


func _punto(id: String) -> Node:
	return _actividades().get_node(id)


func _acercar(punto: Node3D) -> void:
	current_scene.get_node("Jugador").global_position = punto.global_position + Vector3.UP * 0.12
	await _esperar_fisica()


func _interactuar(punto: Node3D) -> void:
	await _acercar(punto)
	await _tecla(KEY_F)


func _tecla(codigo: Key) -> void:
	var evento := InputEventKey.new()
	evento.physical_keycode = codigo
	evento.pressed = true
	Input.parse_input_event(evento)
	await process_frame
	evento = evento.duplicate()
	evento.pressed = false
	Input.parse_input_event(evento)
	await process_frame


func _mando(boton: JoyButton) -> void:
	var evento := InputEventJoypadButton.new()
	evento.button_index = boton
	evento.pressed = true
	Input.parse_input_event(evento)
	await process_frame
	evento = evento.duplicate()
	evento.pressed = false
	Input.parse_input_event(evento)
	await process_frame


func _capturar(id: String, perfil: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://logs/vida_%s_%s.png" % [perfil, id])


func comprobar(condicion: bool, nombre: String) -> void:
	controles += 1
	if not condicion:
		fallos += 1
		push_error("VIDA: " + nombre)


func _resumen() -> void:
	print("VIDA: %d fallos / %d comprobaciones" % [fallos, controles])
	quit(0 if fallos == 0 else 1)
