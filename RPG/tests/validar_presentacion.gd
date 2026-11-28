extends SceneTree

const Regiones = preload("res://scripts/presentacion/regiones.gd")
const MENU := "res://scenes/presentacion/menu_principal.tscn"

var bolsa: Script
var fallos := 0
var total := 0
var partidas: Node
var mundo: Node
var historia: Node
var gestor: Node
var menu: Node
var _audio: Node


func _initialize() -> void:
	_probar.call_deferred()

func _comprobar(ok: bool, texto: String) -> void:
	total += 1
	if not ok:
		fallos += 1
		push_error(texto)

func _esperar(cuadros: int = 3) -> void:
	for i in cuadros:
		await process_frame

func _mando(boton: JoyButton) -> void:
	var evento := InputEventJoypadButton.new()
	evento.device = 0
	evento.button_index = boton
	evento.pressed = true
	Input.parse_input_event(evento)
	await _esperar()
	evento = evento.duplicate()
	evento.pressed = false
	Input.parse_input_event(evento)
	await _esperar()

func _tecla(codigo: Key) -> void:
	var evento := InputEventKey.new()
	evento.physical_keycode = codigo
	evento.pressed = true
	Input.parse_input_event(evento)
	await _esperar()
	evento = evento.duplicate()
	evento.pressed = false
	Input.parse_input_event(evento)
	await _esperar()

func _capturar(id: String) -> void:
	if DisplayServer.get_name() == "headless" or not "--capturas" in OS.get_cmdline_user_args():
		return
	for i in 3:
		await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(partidas._raiz + "/" + id + ".png")

func _probar() -> void:
	bolsa = load("res://scripts/vida/bolsa.gd")
	partidas = root.get_node("Partidas")
	mundo = root.get_node("EstadoMundo")
	historia = root.get_node("Historia")
	gestor = root.get_node("GestorRegiones")
	partidas._raiz = "res://logs/prompt5_presentacion_%s" % Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(partidas._raiz)
	var ignorar := FileAccess.open(partidas._raiz + "/.gdignore", FileAccess.WRITE)
	if ignorar:
		ignorar.close()
	if "--reabrir" in OS.get_cmdline_user_args():
		await _reabrir()
		return
	_migracion()
	_audio_opciones()
	_audio = root.get_node("AudioJuego")
	_audio.activar()
	_comprobar(change_scene_to_file(MENU) == OK, "La escena principal se puede cargar")
	await _esperar(8)
	menu = current_scene
	if not is_instance_valid(menu):
		quit(1)
		return
	_comprobar(paused and gestor.region_actual == &"", "La presentación pausa el mundo")
	_comprobar(partidas.reciente() == 0 and menu._contenido.get_child(2).disabled, "Continuar se desactiva sin partidas")
	_comprobar(menu._contenido.get_child(0).texture != null and menu._contenido.get_parent().size.y > 400.0, "Logotipo y panel principal con altura útil")
	await create_timer(0.9).timeout
	_comprobar(_audio._musica.playing and _audio._region == "menu", "El audio del menú comienza")
	await _capturar("menu")
	menu._lectura(true)
	_comprobar(menu._contenido.get_child(2).text.contains("Samuel Castro Carmona"), "Créditos con los nombres oficiales")
	await _capturar("creditos")
	menu._lectura(false)
	_comprobar(menu._contenido.get_child(1).text.contains("historia principal es opcional"), "Cómo jugar explica la libertad de explorar")
	menu._principal()
	await _probar_opciones()
	var angulo: Transform3D = menu._vista._camara.transform
	menu._vista._process(2.0)
	_comprobar(angulo != menu._vista._camara.transform, "La cámara cinematográfica se mueve")
	menu._reloj_fondo = menu.DURACION_FONDO
	await create_timer(1.3).timeout
	_comprobar(menu._fondo == 1 and not menu._fundiendo, "El menú rota automáticamente con fundido")
	await _mando(JOY_BUTTON_A)
	_comprobar(menu._pagina == "nueva", "A abre la selección de espacio")
	await _mando(JOY_BUTTON_A)
	_comprobar(menu._pagina == "crear" and menu._aspectos.size() == 8, "A abre las ocho apariencias")
	for aspecto in menu._aspectos:
		for direccion in ["izquierda", "derecha", "arriba", "abajo"]:
			for accion in ["idle", "walk"]:
				_comprobar(aspecto.frames.has_animation("%s_%s" % [accion, direccion]), "Vista previa de %s" % aspecto.id)
	await _capturar("creacion")
	await _mando(JOY_BUTTON_A)
	await _mando(JOY_BUTTON_A)
	_comprobar(menu._nombre.get_child_count() == 1, "Teclado virtual abre y recibe A")
	await _capturar("teclado")
	if menu._nombre.get_child_count() > 0:
		var teclado: Control = menu._nombre.get_child(0).get_node("Teclado")
		_comprobar(teclado._entrada.text == "a", "El mando introduce una letra")
		teclado.get_child(0).get_child(3).get_child(3).grab_focus()
		await _mando(JOY_BUTTON_A)
	await _esperar()
	_comprobar(menu._nombre.text == "a", "El teclado transfiere el nombre")
	menu._nombre.text = "Ángela Ñú"
	var escena_original: Node = menu._vista._escenario
	var instante_narrativo: float = root.get_node("Reloj").segundos
	for id in Regiones.DATOS:
		menu._vista.mostrar(id)
		_comprobar(menu._vista.get_child_count() == 2, "Una vista activa para " + id)
		_comprobar(Regiones.imagen(id) != null, "Ilustración importada para " + id)
		_comprobar(root.get_node("Aldeanos").nodos.is_empty(), "La vista no registra aldeanos")
		await _capturar(Regiones.DATOS[id][1])
	_comprobar(not escena_original.is_inside_tree() if is_instance_valid(escena_original) else true, "Se desaloja la vista anterior")
	await _esperar()
	for i in range(2, 6):
		_comprobar(not partidas.crear(i, "", "viajero_24"), "Valida nombre vacío")
		_comprobar(partidas.crear(i, "Viajero %d" % i, "viajero_24"), "Crea espacio %d" % i)
	_comprobar(root.get_node("Reloj").segundos == instante_narrativo, "La rotación no avanza el reloj")
	menu._nueva(1)
	_comprobar(menu.en_intro and paused, "Nueva partida activa la introducción")
	await _capturar("introduccion")
	await _mando(JOY_BUTTON_B)
	await _esperar(10)
	_comprobar(partidas.espacio == 1 and gestor.region_actual == &"Aldea" and not paused, "B omite y devuelve el control jugable")
	if partidas.espacio != 1:
		quit(1)
		return
	_comprobar(mundo.nombre_protagonista() == "Ángela Ñú", "Nombre con Unicode")
	_comprobar(not mundo.seleccionar_apariencia("viajero_24"), "La apariencia de un espacio activo es permanente")
	await _mando(JOY_BUTTON_RIGHT_SHOULDER)
	_comprobar(bolsa.seleccion().get("id") == "azada", "RB selecciona una casilla real de la mochila")
	await _mando(JOY_BUTTON_Y)
	_comprobar(root.get_node("InterfazVida").contexto == "inventario" and paused, "Y abre la mochila")
	await _capturar("inventario")
	await _mando(JOY_BUTTON_B)
	_comprobar(not paused, "B sale de la mochila")
	_comprobar(not partidas.crear(1, "Otro", "viajero_24"), "Nunca sobrescribe un espacio ocupado")
	_comprobar(not partidas.eliminar(1), "No elimina un espacio en uso")
	_comprobar(bolsa.anadir(bolsa.jugador(), "trigo", 3), "Añade trigo a la mochila")
	mundo.objeto("@relaciones", "guardia").amistad = 8
	mundo.objeto("@misiones", "principal_1").estado = "aceptada"
	historia.recordar(&"guardia", "Una historia de prueba.")
	mundo.datos.monedas = 78
	_comprobar(mundo.guardar_actual() and partidas.reciente() == 1, "Guarda la partida y actualiza la más reciente")
	var guardado: Dictionary = partidas.leer(1)
	_comprobar(guardado.monedas == 78 and guardado.historia.npcs.guardia.recuerdos.size() == 1, "Mundo y memoria quedan juntos")
	_comprobar(partidas.leer(2).monedas == 30 and partidas.leer(2).zonas.size() == 1, "Otro espacio permanece independiente")
	_comprobar(FileAccess.file_exists(partidas.ruta(1) + ".bak"), "Existe copia de respaldo")
	await _mando(JOY_BUTTON_BACK)
	_comprobar(root.get_node("MapaMundo").abierto and paused, "Ver abre el mapa con mando")
	await _capturar("mapa")
	await _mando(JOY_BUTTON_B)
	_comprobar(not root.get_node("MapaMundo").abierto and not paused, "B cierra mapa y devuelve el control")
	await _mando(JOY_BUTTON_START)
	_comprobar(root.get_node("MenuPausa").abierto and paused, "Menú pausa con mando")
	await _mando(JOY_BUTTON_B)
	_comprobar(not paused, "B continúa el juego")
	await create_timer(1.0).timeout
	_comprobar(_audio._musica.playing and _audio._ambiente.playing, "Música y ambiente regionales")
	_audio._musica.stop()
	_audio._musica.finished.emit()
	_comprobar(_audio._espera >= 30.0 and _audio._espera <= 90.0, "Intervalo variable de silencio musical")
	await _esperar()
	_comprobar(not _audio._musica.playing and _audio._ambiente.playing, "Sigue el ambiente durante el silencio musical")
	_audio.efecto("cofre")
	_comprobar(_audio._efecto.playing and _audio._efecto.bus == "Efectos", "Reproduce cofre en su bus")
	await _interior()
	await _vivienda()
	await _viajar("Bosque", "bosque_aldea_sur", true)
	await _viajar("Ruinas", "ruinas_bosque_sur", true)
	await _viajar("Bosque", "bosque_ruinas_norte", true)
	await _viajar("Aldea", "aldea_bosque_norte", true)
	await _viajar("CamposYGranjas", "campos_aldea_norte", true)
	await _viajar("Aldea", "aldea_campos_sur", true)
	await _viajar("Montanas", "camino_montanas_aldea_oeste", true)
	await _viajar("Minas", "minas_montanas_sur", true)
	await _viajar("Montanas", "montanas_minas_norte", true)
	await _viajar("Aldea", "aldea_camino_este", true)
	_comprobar(partidas.volver_al_menu(), "Regresa al menú")
	await _esperar(8)
	_comprobar(partidas.abrir(2), "Carga el segundo espacio")
	await _esperar(8)
	_comprobar(mundo.datos.monedas == 30 and mundo.nombre_protagonista() == "Viajero 2", "Identidad y economía aisladas al cambiar")
	_comprobar(historia.estado.npcs.guardia.recuerdos.is_empty() and not mundo.datos.zonas.has("@relaciones"), "Las memorias y relaciones no se mezclan")
	_comprobar(partidas.volver_al_menu(), "Puede volver otra vez")
	await _esperar(8)
	_comprobar(partidas.abrir(1), "Restaura el primer espacio")
	await _esperar(8)
	_comprobar(mundo.nombre_protagonista() == "Ángela Ñú" and mundo.datos.monedas == 78, "Nombre y monedas se restauran")
	_comprobar(mundo.datos.zonas["@misiones"].principal_1.estado == "aceptada", "Restaura misiones")
	_comprobar(mundo.datos.zonas["@relaciones"].guardia.amistad == 8, "Restaura relaciones")
	_comprobar(bolsa.cantidad(bolsa.jugador(), "trigo") == 3, "Restaura el inventario")
	_comprobar(partidas.volver_al_menu(), "Regresa para verificar el diálogo de eliminación")
	await _esperar(8)
	menu = current_scene
	menu._espacios(false)
	menu._confirmar_eliminar(5, false)
	await _esperar()
	var confirmar := menu.get_child(menu.get_child_count() - 1) as ConfirmationDialog
	_comprobar(is_instance_valid(confirmar) and partidas.existe(5), "Abrir confirmación conserva el espacio")
	await _mando(JOY_BUTTON_B)
	_comprobar(partidas.existe(5) and not is_instance_valid(confirmar), "B cierra la confirmación y conserva el espacio")
	menu._confirmar_eliminar(5, false)
	await _esperar()
	confirmar = menu.get_child(menu.get_child_count() - 1) as ConfirmationDialog
	confirmar.get_ok_button().grab_focus()
	await _mando(JOY_BUTTON_A)
	_comprobar(not partidas.existe(5), "A confirma la eliminación")
	_comprobar(not partidas.eliminar(6), "Protege los límites del selector")
	menu._crear(5)
	menu._nombre.text = "Íñigo"
	menu._nueva(5)
	await _tecla(KEY_ESCAPE)
	_comprobar(partidas.espacio == 5 and not paused, "Esc omite la introducción")
	print("RESULTADO_PRESENTACION: ", fallos, " fallos / ", total, " comprobaciones. Datos temporales: ", partidas._raiz)
	quit(0 if fallos == 0 else 1)

func _viajar(id: String, entrada: String, ilustrada: bool) -> void:
	var ruta := Regiones.ruta(id)
	_comprobar(gestor.solicitar(ruta, entrada), "Solicita viaje a " + id)
	_comprobar(not gestor.solicitar(ruta, entrada), "Rechaza viaje simultáneo")
	await gestor.pantalla_negra
	await _esperar()
	_comprobar(gestor.cartel.visible == ilustrada and gestor.cartel._destino == id and paused, "Muestra el destino con controles bloqueados")
	await _capturar("transicion_" + id)
	await gestor.finalizada
	_comprobar(gestor.region_actual == StringName(id) and not paused and not gestor.cartel.visible, "Recupera el control al llegar")
	_comprobar(partidas.leer(partidas.espacio).ubicacion.region == id, "Persiste el destino al llegar")

func _vivienda() -> void:
	var reloj := root.get_node("Reloj")
	var ajustes := root.get_node("Ajustes")
	_comprobar(reloj.DURACION_REAL_DIA == 1800.0 and Regiones.hora(0.0) == "06:00", "Reloj de 30 minutos y comienzo a las 06:00")
	_comprobar(ajustes.BASE.velocidad == "normal", "Velocidad Normal predeterminada")
	var anterior: bool = ajustes.mando
	ajustes.mando = false
	_comprobar(ajustes.indicacion("ranura_anterior") == "[" and ajustes.indicacion("ranura_siguiente") == "]", "La barra traduce los corchetes")
	ajustes.mando = anterior
	_comprobar(current_scene.get_node("CartelCasa/Rotulo").text == "Casa de " + mundo.nombre_protagonista(), "El cartel exterior identifica al propietario")
	var puerta := current_scene.get_node("PuertaE06")
	_comprobar(gestor.solicitar(puerta.escena_destino, puerta.entrada_destino), "La primera vivienda abre sin requisitos narrativos")
	await gestor.finalizada
	var config := current_scene.get_node("Region")
	var cama := config.find_child("cama_personal", true, false) as Node3D
	var cofre := config.find_child("cofre_personal", true, false) as Node3D
	_comprobar(is_instance_valid(cama) and is_instance_valid(cofre), "E06 reutiliza su cama y su cofre")
	if not cama or not cofre:
		return
	cofre.actuar()
	_comprobar(paused, "El cofre personal abre el inventario compartido")
	await _mando(JOY_BUTTON_B)
	var casillas: Array = mundo.objeto("InteriorE06", "cofre_personal").casillas
	var carga: Array = bolsa.crear(2)
	bolsa.anadir(carga, "madera", 3)
	_comprobar(bolsa.transferir(carga, 0, casillas, 3) and bolsa.transferir(casillas, 0, carga, 1),
		"El cofre personal deposita y retira cantidades")
	_comprobar(bolsa.cantidad(casillas, "madera") == 2 and bolsa.cantidad(carga, "madera") == 1, "El cofre y la mochila conservan el total")
	await _visitas(reloj)
	var dia: int = reloj.dia
	var hora: float = reloj.segundos
	cama.actuar()
	_comprobar(paused and cama.has_node("ConfirmacionSapientia"), "Descanso abre confirmación y pausa el mundo")
	await _mando(JOY_BUTTON_B)
	_comprobar(not paused and reloj.dia == dia and reloj.segundos - hora < 1.0, "B cancela el descanso")
	cama.actuar()
	var dialogo := cama.get_node("ConfirmacionSapientia") as ConfirmationDialog
	dialogo.get_ok_button().grab_focus()
	await _mando(JOY_BUTTON_A)
	await create_timer(0.85, true).timeout
	var guardado: Dictionary = partidas.leer(partidas.espacio)
	_comprobar(not paused and reloj.dia == dia + 1, "A confirma y devuelve el control al día siguiente")
	_comprobar(guardado.historia.reloj.segundos == 0.0 and guardado.ubicacion.region == "InteriorE06", "El autoguardado conserva las 06:00 en E06")
	_comprobar(bolsa.cantidad(guardado.zonas.InteriorE06.cofre_personal.casillas, "madera") == 2, "El descanso guarda el cofre")
	_comprobar(not partidas.leer(2).zonas.has("InteriorE06"), "El cofre es independiente por espacio")
	_comprobar(guardado.zonas["@poblacion"].baltasar.region == "Aldea", "Dormir finaliza la visita a E06")
	_comprobar(gestor.solicitar(Regiones.ruta("Aldea"), "aldea_e06"), "Salida libre de la vivienda")
	await gestor.finalizada

func _visitas(reloj: Node) -> void:
	var aldeanos := root.get_node("Aldeanos")
	var rutinas: RefCounted = aldeanos._rutinas
	reloj.dia = 1
	reloj.segundos = 235.0
	for paso in 4:
		rutinas.actualizar(current_scene, historia.poblacion)
		reloj.tiempo_juego += 19.0
	var ines: Dictionary = mundo.objeto("@poblacion", "ines")
	var rodrigo: Dictionary = mundo.objeto("@poblacion", "rodrigo")
	_comprobar(ines.region == "InteriorE11" and rodrigo.region == "InteriorE11", "La casa de Inés recibe una visita fuera de escena")
	_comprobar(not aldeanos.nodos.has(&"ines") and not aldeanos.nodos.has(&"rodrigo"), "Las visitas fuera de escena son únicamente lógicas")
	reloj.dia = 2
	mundo.objeto("@relaciones", "baltasar").amistad = 30
	rutinas.actualizar(current_scene, historia.poblacion)
	reloj.tiempo_juego += 19.0
	await physics_frame
	rutinas.actualizar(current_scene, historia.poblacion)
	var baltasar: Dictionary = mundo.objeto("@poblacion", "baltasar")
	_comprobar(baltasar.region == "InteriorE06" and is_instance_valid(aldeanos.nodos.get(&"baltasar")), "Baltasar visita la casa del protagonista si existe amistad")

func _audio_opciones() -> void:
	var ajustes := root.get_node("Ajustes")
	for nombre in ajustes.BUS:
		_comprobar(AudioServer.get_bus_index(nombre) != -1, "Bus de audio " + nombre)
	ajustes.valores.silencio = true
	ajustes.aplicar()
	_comprobar(AudioServer.is_bus_mute(0), "Silencio general")
	ajustes.valores.silencio = false
	ajustes.aplicar()
	_comprobar(not AudioServer.is_bus_mute(0), "Restauración de volumen general")
	var tema := load("res://scenes/presentacion/sapientia.tres") as Theme
	for caracter in "ÁÉÍÓÚÑÜ¿?¡!áéíóúñü":
		_comprobar(tema.default_font.has_char(caracter.unicode_at(0)), "Alegreya incluye " + caracter)
		_comprobar(tema.get_font("font", "Titulo").has_char(caracter.unicode_at(0)), "Cinzel incluye " + caracter)


func _interior() -> void:
	const TABERNA := "res://scenes/interiores/taberna_e01.tscn"
	var escena := load(TABERNA).instantiate() as Node
	var entradas: Dictionary = escena.get_node("Region").entradas
	escena.free()
	_comprobar(gestor.solicitar(TABERNA, entradas.keys()[0]), "Solicita entrada a la taberna")
	await gestor.pantalla_negra
	await _esperar()
	_comprobar(not gestor.cartel.visible and paused, "Un interior utiliza fundido sin ilustración")
	await gestor.finalizada
	_comprobar(gestor.region_actual == &"TabernaE01", "Entra a la taberna")
	_comprobar(gestor.solicitar(Regiones.ruta("Aldea"), "aldea_taberna_e01"), "Solicita retorno desde el interior")
	await gestor.pantalla_negra
	await _esperar()
	_comprobar(not gestor.cartel.visible, "El retorno de interior conserva el fundido corto")
	await gestor.finalizada


func _migracion() -> void:
	var raiz: String = partidas._raiz
	var origen := raiz + "/legado/"
	var destino := raiz + "/migrado"
	var origenes: Array[String] = [origen]
	DirAccess.make_dir_recursive_absolute(origen)
	var datos: Dictionary = mundo.nueva_partida()
	datos.monedas = 147
	_comprobar(mundo.escribir_partida(origen + "mundo_v1.save.bak", datos), "Prepara una partida anterior en copia de respaldo")
	var legado := FileAccess.open(origen + "historia.json", FileAccess.WRITE)
	var memoria: Dictionary = historia.estado.duplicate(true)
	memoria.npcs.panadera.recuerdos.append("Recuerdo anterior")
	legado.store_string(JSON.stringify(memoria))
	legado.close()
	partidas._raiz = destino
	partidas.migrar(origenes)
	var migracion: Dictionary = partidas.leer(1)
	_comprobar(migracion.get("monedas") == 147, "Migra el respaldo anterior al primer espacio")
	_comprobar(migracion.get("historia", {}).get("npcs", {}).get("panadera", {}).get("recuerdos", []) == ["Recuerdo anterior"], "Migra la memoria anterior")
	_comprobar(FileAccess.file_exists(origen + "mundo_v1.save.bak") and FileAccess.file_exists(origen + "historia.json"), "Los originales se conservan")
	partidas.migrar(origenes)
	_comprobar(not partidas.existe(2), "La migración es idempotente")
	partidas._raiz = raiz


func _reabrir() -> void:
	for argumento in OS.get_cmdline_user_args():
		if argumento.begins_with("perfil=prompt5_presentacion_") and argumento.trim_prefix("perfil=prompt5_presentacion_").is_valid_int():
			partidas._raiz = "res://logs/" + argumento.trim_prefix("perfil=")
	_comprobar(change_scene_to_file(MENU) == OK, "Arranca un segundo proceso en el menú")
	await _esperar(8)
	_comprobar(partidas.reciente() == 5 and partidas.abrir(1), "Recupera selección y fecha entre procesos")
	await _esperar(8)
	_comprobar(mundo.nombre_protagonista() == "Ángela Ñú" and mundo.datos.monedas == 78, "Restaura un espacio desde disco tras reiniciar")
	_comprobar(partidas.espacio == 1 and not paused, "Carga directa sin repetir cinemática")
	var cofre: Dictionary = mundo.datos.zonas.get("InteriorE06", {}).get("cofre_personal", {})
	_comprobar(bolsa.cantidad(cofre.get("casillas", []), "madera") == 2, "Reabre el cofre personal desde disco")
	print("RESULTADO_REAPERTURA: ", fallos, " fallos / ", total, " comprobaciones.")
	quit(0 if fallos == 0 else 1)

func _probar_opciones() -> void:
	menu._mostrar_opciones()
	var opciones: Control = menu._opciones
	var ajustes := root.get_node("Ajustes")
	opciones._seccion("Accesibilidad")
	opciones._contenido.get_child(1).get_child(1).value = 27
	opciones._cambiar("escala", 1.15)
	opciones._contenido.get_child(2).get_child(1).button_pressed = true
	var tema := load("res://scenes/presentacion/sapientia.tres") as Theme
	_comprobar(tema.default_font_size == 27 and is_equal_approx(root.content_scale_factor, 1.15), "Escala y tamaño de texto se aplican")
	_comprobar(tema.get_color("font_color", "Label") == Color.WHITE, "El contraste cambia el tema")
	await _capturar("accesibilidad")
	opciones._seccion("Controles")
	var tecla := InputEventKey.new()
	tecla.physical_keycode = KEY_F
	_comprobar(not ajustes.reasignar("abrir_mapa_mundo", tecla).is_empty(), "Detecta un conflicto de controles")
	tecla = tecla.duplicate()
	tecla.physical_keycode = KEY_N
	_comprobar(ajustes.reasignar("abrir_mapa_mundo", tecla).is_empty() and InputMap.action_has_event("abrir_mapa_mundo", tecla), "Aplica una reasignación al InputMap")
	var ruta := String(partidas._raiz) + "/opciones_prueba.cfg"
	ajustes.guardar(ruta)
	ajustes.restaurar()
	ajustes.cargar_configuracion(ruta)
	_comprobar(ajustes.valores.texto == 27 and ajustes.controles.has("abrir_mapa_mundo"), "Persiste accesibilidad y asignaciones en un archivo global")
	ajustes.restaurar()
	opciones._seccion("Gráficos")
	if DisplayServer.get_name() != "headless":
		opciones._probar_pantalla("modo", 2)
		await _esperar()
		_comprobar(root.mode == Window.MODE_WINDOWED and root.borderless, "La ventana sin bordes se aplica")
		opciones._probar_pantalla("modo", 1)
		await _esperar()
		_comprobar(root.mode == Window.MODE_FULLSCREEN, "La pantalla completa se aplica")
		opciones._restante = 0.0
		await _esperar()
		_comprobar(root.mode == Window.MODE_WINDOWED and not root.borderless, "El modo previo se restaura al vencer el plazo")
		opciones._probar_pantalla("resolucion", Vector2i(960, 600))
		await _esperar()
		_comprobar(root.size == Vector2i(960, 600), "La resolución de ventana se aplica")
		opciones._seccion("Gráficos")
	opciones._cambiar("calidad", 2)
	_comprobar(root.msaa_3d == Viewport.MSAA_4X, "La calidad aplica antialiasing 3D")
	ajustes.restaurar()
	opciones._seccion("Gráficos")
	await _capturar("opciones")
	(opciones._pestanas.get_child(0) as Button).grab_focus()
	await _mando(JOY_BUTTON_B)
	_comprobar(menu._pagina == "principal" and not is_instance_valid(menu._opciones), "B sale de opciones y devuelve el foco")
