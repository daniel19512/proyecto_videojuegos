extends Node
## Partida de juego complementaria a historia.json. Nunca serializa nodos ni IA.

const RUTA := "user://mundo_v1.save"
const VERSION := 1
const Bolsa = preload("res://scripts/vida/bolsa.gd")
const Apariencias = preload("res://scripts/npc/apariencias.gd")
const NOMBRE_PREDETERMINADO := "Viajero"
const MAX_NOMBRE := 24
var datos: Dictionary = {"zonas": {}, "monedas": 30, "ubicacion": {}, "serie": 0, "tiempo": 0.0}
var ruta := RUTA
var automatico := false
var restaurando := false
var _intervalo := 0.0
var gestionada := false
signal apariencia_cambiada(id: String)
signal actividad_registrada(tipo: String, id: String)


func registrar_actividad(tipo: String, id: String, cantidad: int = 1) -> void:
	if cantidad <= 0:
		return
	var cuentas := objeto("@actividades", tipo)
	cuentas[id] = int(cuentas.get(id, 0)) + cantidad
	actividad_registrada.emit(tipo, id)


func _ready() -> void:
	# Los scripts de validación y F6 no cargan ni modifican la partida normal.
	if get_tree().get_script() == null and ProjectSettings.get_setting("application/run/main_scene") != "res://scenes/presentacion/menu_principal.tscn":
		await get_tree().process_frame
		_iniciar()


func _iniciar() -> void:
	var escena := get_tree().current_scene
	if escena == null or escena.scene_file_path != "res://scenes/mundo.tscn":
		return
	automatico = true
	if not cargar():
		return
	var punto: Dictionary = datos.ubicacion
	if not punto.is_empty():
		restaurando = true
		GestorRegiones.rechazada.connect(_finalizar_restauracion, CONNECT_ONE_SHOT)
		GestorRegiones.finalizada.connect(_finalizar_restauracion, CONNECT_ONE_SHOT)
		GestorRegiones.solicitar(punto.ruta, "", punto)


func _finalizar_restauracion(_resultado: Variant) -> void:
	restaurando = false
	if GestorRegiones.rechazada.is_connected(_finalizar_restauracion):
		GestorRegiones.rechazada.disconnect(_finalizar_restauracion)
	if GestorRegiones.finalizada.is_connected(_finalizar_restauracion):
		GestorRegiones.finalizada.disconnect(_finalizar_restauracion)


func zona(region: String) -> Dictionary:
	if not datos.zonas.has(region):
		datos.zonas[region] = {}
	return datos.zonas[region]


func objeto(region: String, id: String) -> Dictionary:
	var objetos := zona(region)
	if not objetos.has(id):
		objetos[id] = {}
	return objetos[id]


func nombre_protagonista() -> String:
	var identidad: Dictionary = datos.zonas.get("@jugador", {}).get("identidad", {})
	var nombre := _validar_nombre(identidad.get("nombre"), 32)
	return NOMBRE_PREDETERMINADO if nombre.is_empty() else nombre


func asignar_nombre_protagonista(texto: String) -> bool:
	if gestionada:
		return false
	var nombre := _validar_nombre(texto)
	if nombre.is_empty():
		return false
	objeto("@jugador", "identidad").nombre = nombre
	return true


func apariencia_protagonista() -> String:
	var identidad: Dictionary = datos.zonas.get("@jugador", {}).get("identidad", {})
	var id: Variant = identidad.get("apariencia")
	return id if id is String and Apariencias.JUGADOR.has(id) else Apariencias.PREDETERMINADA


func apariencias_disponibles() -> Array[Dictionary]:
	var resultado: Array[Dictionary] = []
	for id in Apariencias.JUGADOR:
		var entrada: Array = Apariencias.JUGADOR[id]
		var visual := Apariencias.ficha(entrada[1]).duplicate()
		if not visual.is_empty():
			visual.merge({"id": id, "nombre": entrada[0]})
			resultado.append(visual)
	return resultado


func seleccionar_apariencia(id: String) -> bool:
	if gestionada:
		return false
	if not Apariencias.JUGADOR.has(id) or Apariencias.ficha(Apariencias.JUGADOR[id][1]).is_empty():
		return false
	objeto("@jugador", "identidad").apariencia = id
	apariencia_cambiada.emit(id)
	return true


func _validar_nombre(texto: Variant, limite: int = MAX_NOMBRE) -> String:
	if not texto is String:
		return ""
	var nombre: String = texto.strip_edges()
	if nombre.length() > limite:
		return ""
	for caracter in nombre:
		if caracter.unicode_at(0) < 32 or caracter.unicode_at(0) in [127, 8232, 8233] or caracter in ["/", "\\", "<", ">", "[", "]"]:
			return ""
	return nombre


func _process(delta: float) -> void:
	if not automatico or restaurando:
		return
	datos.duracion_real = float(datos.get("duracion_real", 0.0)) + delta
	_intervalo += delta
	if _intervalo >= 20.0 and not GestorRegiones.en_transicion:
		_intervalo = 0.0
		guardar()


func guardar_actual() -> bool:
	return not automatico or (not restaurando and guardar())


func nueva_partida() -> Dictionary:
	return {"zonas": {}, "monedas": 30, "ubicacion": {}, "serie": 0, "tiempo": 0.0, "duracion_real": 0.0}


func activar_partida(partida: Dictionary) -> void:
	gestionada = true
	datos = partida
	Historia.ruta_guardado = ""
	if not Historia.restaurar_memoria(datos.get("historia", {})):
		Historia.reiniciar()
	Reloj.cargar()
	Reloj.tiempo_juego = float(datos.get("tiempo", 0))
	_intervalo = 0.0
	automatico = true
	apariencia_cambiada.emit(apariencia_protagonista())


func guardar() -> bool:
	var escena := get_tree().current_scene
	if is_instance_valid(escena):
		var config := escena.get_node_or_null("Region")
		if config:
			var jugador := config.get_node_or_null(config.jugador) as CharacterBody3D
			if jugador:
				datos.ubicacion = {"ruta": escena.scene_file_path, "region": String(config.id_region),
					"pos": jugador.global_position, "mirada": String(jugador.direccion_visual)}
	for npc in Aldeanos.nodos.values():
		if is_instance_valid(npc) and npc.regional:
			var actividad := objeto("@poblacion", String(npc.id_npc))
			if str(actividad.get("destino", "")).is_empty():
				actividad.pos = npc.global_position
		elif is_instance_valid(npc):
			Aldeanos.estado_de(npc.id_npc).pos = [npc.global_position.x, npc.global_position.z]
	datos.tiempo = Reloj.tiempo_juego
	if gestionada:
		Reloj._anotar()
		datos.historia = Historia.estado
		datos.guardado = Time.get_unix_time_from_system()
	elif automatico:
		Reloj.guardar()
	return escribir_partida(ruta, datos)


func escribir_partida(destino: String, partida: Dictionary) -> bool:
	var temporal := destino + ".tmp"
	var previo := destino + ".bak"
	var archivo := FileAccess.open(temporal, FileAccess.WRITE)
	if archivo == null:
		push_warning("No se pudo abrir el archivo temporal de partida: " + error_string(FileAccess.get_open_error()))
		return false
	archivo.store_var({"version": VERSION, "datos": partida}, false)
	archivo.flush()
	var error := archivo.get_error()
	archivo.close()
	if error != OK or _leer(temporal).is_empty():
		return false
	if FileAccess.file_exists(destino) and _leer(destino).is_empty():
		if DirAccess.remove_absolute(destino) != OK:
			return false
	elif FileAccess.file_exists(destino):
		if DirAccess.rename_absolute(destino, previo) != OK:
			return false
	if DirAccess.rename_absolute(temporal, destino) != OK:
		return false
	return true


func cargar() -> bool:
	var partida := _leer(ruta)
	if partida.is_empty():
		partida = _leer(ruta + ".bak")
	if partida.is_empty():
		return false
	# Mantiene referencias adquiridas por los nodos de la escena inicial.
	for region in datos.zonas:
		for estado in datos.zonas[region].values():
			estado.clear()
	for region in partida.zonas:
		for id in partida.zonas[region]:
			objeto(region, id).merge(partida.zonas[region][id], true)
	partida.zonas = datos.zonas
	datos = partida
	Reloj.tiempo_juego = float(datos.get("tiempo", 0.0))
	apariencia_cambiada.emit(apariencia_protagonista())
	return true


func _leer(origen: String) -> Dictionary:
	var archivo := FileAccess.open(origen, FileAccess.READ)
	if archivo == null or archivo.get_length() < 8 or archivo.get_length() > 8_000_000:
		return {}
	var paquete: Variant = archivo.get_var(false)
	if not paquete is Dictionary or paquete.get("version") != VERSION:
		return {}
	var partida: Variant = paquete.get("datos")
	if not partida is Dictionary or not partida.get("zonas") is Dictionary:
		return {}
	for region in partida.zonas:
		if not region is String or not partida.zonas[region] is Dictionary:
			return {}
		for id in partida.zonas[region]:
			if not id is String or not partida.zonas[region][id] is Dictionary:
				return {}
			var estado: Dictionary = partida.zonas[region][id]
			if estado.has("casillas") and not Bolsa.valida(estado.casillas):
				return {}
			if id.begins_with("suelto_") and (not estado.get("pos") is Vector3 or not estado.pos.is_finite()
					or not estado.get("producto") is String or Bolsa.Catalogo.ficha(estado.producto).is_empty()):
				return {}
	var tiempo: Variant = partida.get("tiempo", 0.0)
	if not (tiempo is float or tiempo is int) or not is_finite(float(tiempo)) or tiempo < 0:
		return {}
	if not partida.get("monedas") is int or partida.monedas < 0:
		return {}
	if not partida.get("serie") is int or partida.serie < 0:
		return {}
	var punto: Variant = partida.get("ubicacion", {})
	if not punto is Dictionary:
		return {}
	if not punto.is_empty():
		if not punto.get("region") is String or not punto.get("ruta") is String:
			return {}
		if not punto.ruta.begins_with("res://scenes/") or not punto.ruta.ends_with(".tscn"):
			return {}
		if not punto.get("pos") is Vector3 or not punto.pos.is_finite():
			return {}
	partida.ubicacion = punto
	return partida


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_CLOSE_REQUEST and not gestionada:
		guardar_actual()
