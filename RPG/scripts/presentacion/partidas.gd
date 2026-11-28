extends Node
## Cada archivo contiene mundo, reloj y memoria. Los respaldos usan el mismo formato.

const CAPACIDAD := 5
const DIRECTORIO := "user://partidas"
const MENU := "res://scenes/presentacion/menu_principal.tscn"
const ALDEA := "res://scenes/mundo.tscn"
const Regiones = preload("res://scripts/presentacion/regiones.gd")

var espacio := 0
var ocupado := false
var _raiz := DIRECTORIO

func ruta(id: int) -> String:
	return "%s/%d.save" % [_raiz, id]

func _valido(id: int) -> bool:
	return id >= 1 and id <= CAPACIDAD

func existe(id: int) -> bool:
	return FileAccess.file_exists(ruta(id)) or FileAccess.file_exists(ruta(id) + ".bak")

func leer(id: int) -> Dictionary:
	if not _valido(id):
		return {}
	var datos := EstadoMundo._leer(ruta(id))
	return datos if not datos.is_empty() else EstadoMundo._leer(ruta(id) + ".bak")

func reciente() -> int:
	var resultado := 0
	var fecha := -1.0
	for id in range(1, CAPACIDAD + 1):
		var datos := leer(id)
		if datos.is_empty():
			continue
		var usada := float(datos.get("guardado", FileAccess.get_modified_time(ruta(id))))
		if usada > fecha:
			resultado = id
			fecha = usada
	return resultado

func migrar(origenes: Array[String] = []) -> void:
	var marca := _raiz + "/migracion_v1"
	if FileAccess.file_exists(marca):
		return
	var legado := carpeta_legada()
	var datos: Dictionary
	var origen := ""
	if origenes.is_empty():
		origenes = ["user://", legado + "/"]
	for carpeta in origenes:
		origen = carpeta
		datos = EstadoMundo._leer(carpeta + "mundo_v1.save")
		if datos.is_empty():
			datos = EstadoMundo._leer(carpeta + "mundo_v1.save.bak")
		if not datos.is_empty():
			break
	if datos.is_empty():
		return
	for id in range(1, CAPACIDAD + 1):
		if leer(id).get("migrado_v1", false):
			_marcar_migracion(marca)
			return
	for id in range(1, CAPACIDAD + 1):
		if existe(id):
			continue
		var memoria: Variant = JSON.parse_string(FileAccess.get_file_as_string(origen + "historia.json")) if FileAccess.file_exists(origen + "historia.json") else {}
		if Historia.memoria_valida(memoria):
			datos.historia = memoria
		datos.migrado_v1 = true
		datos.duracion_real = float(datos.get("duracion_real", datos.get("tiempo", 0.0)))
		datos.guardado = maxi(FileAccess.get_modified_time(origen + "mundo_v1.save"), FileAccess.get_modified_time(origen + "mundo_v1.save.bak"))
		if _preparar_directorio() and EstadoMundo.escribir_partida(ruta(id), datos):
			_marcar_migracion(marca)
		return

func carpeta_legada() -> String:
	return OS.get_user_data_dir().get_base_dir().path_join("RPG")

func _marcar_migracion(marca: String) -> void:
	var archivo := FileAccess.open(marca, FileAccess.WRITE)
	if archivo:
		archivo.store_string("1")

func _preparar_directorio() -> bool:
	return DirAccess.make_dir_recursive_absolute(_raiz) == OK

func eliminar(id: int) -> bool:
	if not _valido(id) or id == espacio or ocupado:
		return false
	for sufijo in [".tmp", ".bak", ""]:
		var archivo: String = ruta(id) + sufijo
		if FileAccess.file_exists(archivo) and DirAccess.remove_absolute(archivo) != OK:
			return false
	return true

func nombre(datos: Dictionary) -> String:
	var identidad: Dictionary = datos.get("zonas", {}).get("@jugador", {}).get("identidad", {})
	var texto := EstadoMundo._validar_nombre(identidad.get("nombre"), 32)
	return EstadoMundo.NOMBRE_PREDETERMINADO if texto.is_empty() else texto

func apariencia(datos: Dictionary) -> Dictionary:
	var identidad: Dictionary = datos.get("zonas", {}).get("@jugador", {}).get("identidad", {})
	var catalogo = EstadoMundo.Apariencias
	return catalogo.ficha(catalogo.JUGADOR.get(identidad.get("apariencia"), catalogo.JUGADOR[catalogo.PREDETERMINADA])[1])

func resumen(datos: Dictionary) -> String:
	var reloj: Dictionary = datos.get("historia", {}).get("reloj", {})
	var transcurrido := int(datos.get("duracion_real", datos.get("tiempo", 0.0)))
	var capitulo := 1
	for id in datos.zonas.get("@misiones", {}):
		var ficha: Dictionary = Misiones.catalogo.get(id, {})
		if datos.zonas["@misiones"][id].get("estado", "") != "disponible":
			capitulo = maxi(capitulo, int(ficha.get("capitulo", 1)))
	var guardado := int(datos.get("guardado", 0))
	var fecha := Time.get_datetime_dict_from_unix_time(guardado + int(Time.get_time_zone_from_system().bias) * 60)
	var sello := "%02d/%02d/%04d %02d:%02d" % [fecha.day, fecha.month, fecha.year, fecha.hour, fecha.minute] if guardado > 0 else "Fecha sin registrar"
	return "Día %d · %s · %s\nCapítulo %d · %02dh %02dm · %s" % [
		reloj.get("dia", 1), Regiones.hora(float(reloj.get("segundos", 0))),
		Regiones.nombre(datos.ubicacion.get("region", "Aldea")), capitulo, transcurrido / 3600, (transcurrido / 60) % 60, sello]

func crear(id: int, protagonista: String, aspecto: String) -> bool:
	if not _valido(id) or existe(id) or ocupado or espacio != 0:
		return false
	if EstadoMundo._validar_nombre(protagonista).is_empty() or not EstadoMundo.Apariencias.JUGADOR.has(aspecto):
		return false
	var datos := EstadoMundo.nueva_partida()
	datos.zonas["@jugador"] = {"identidad": {"nombre": protagonista.strip_edges(), "apariencia": aspecto}}
	datos.guardado = Time.get_unix_time_from_system()
	return _preparar_directorio() and EstadoMundo.escribir_partida(ruta(id), datos)

func abrir(id: int) -> bool:
	if ocupado or espacio != 0:
		return false
	var datos := leer(id)
	if datos.is_empty():
		return false
	var punto: Dictionary = datos.ubicacion
	var destino: String = punto.get("ruta", ALDEA)
	if not ResourceLoader.exists(destino, "PackedScene"):
		return false
	var recurso := load(destino) as PackedScene
	if recurso == null:
		return false
	var escena := recurso.instantiate()
	var region := escena.get_node_or_null("Region")
	if region == null or (not punto.is_empty() and String(region.id_region) != punto.region):
		escena.free()
		return false
	if not region.get_node_or_null(region.jugador) is CharacterBody3D or not region.get_node_or_null(region.camara) is Camera3D:
		escena.free()
		return false
	ocupado = true
	_abrir.call_deferred(id, datos, escena)
	return true

func _abrir(id: int, datos: Dictionary, escena: Node) -> void:
	var anterior := get_tree().current_scene
	espacio = id
	Aldeanos.reiniciar_sesion()
	EstadoMundo.ruta = ruta(id)
	EstadoMundo.activar_partida(datos)
	var region := escena.get_node("Region")
	var jugador := region.get_node(region.jugador) as CharacterBody3D
	var camara := region.get_node(region.camara) as Camera3D
	var punto: Dictionary = datos.ubicacion
	if not punto.is_empty():
		jugador.position = punto.pos
		jugador.direccion_visual = StringName(punto.get("mirada", "abajo"))
	anterior.get_parent().remove_child(anterior)
	anterior.queue_free()
	get_tree().root.add_child(escena)
	get_tree().current_scene = escena
	jugador._actualizar_animacion()
	camara.centro_seguimiento = jugador.global_position
	camara.actualizar_orbita()
	camara.make_current()
	get_tree().paused = false
	ocupado = false
	GestorRegiones.finalizada.emit(GestorRegiones.region_actual)
	EstadoMundo.guardar_actual()
	Aldeanos.planificar_si_falta()

func volver_al_menu() -> bool:
	if ocupado or GestorRegiones.en_transicion or IA.peticiones_en_curso > 0:
		return false
	if get_tree().change_scene_to_file(MENU) != OK:
		return false
	espacio = 0
	EstadoMundo.automatico = false
	EstadoMundo.restaurando = false
	get_tree().paused = false
	return true
