extends Node
## Autoload `Historia`: estado persistente de la historia y de la memoria de
## los NPC, y narrador que la reorienta cada pocos hechos. El estado inicial
## sale de res://data/historia/premisa.json; se guarda en user://historia.json.
## En pruebas no lee ni escribe archivos salvo que se fije `ruta_guardado`.

signal historia_actualizada

const RUTA_PREMISA := "res://data/historia/premisa.json"
const RUTA_POBLACION := "res://data/historia/poblacion.json"
const RUTA_POR_DEFECTO := "user://historia.json"
const VERSION: int = 1
const RECUERDOS_MAXIMOS: int = 8
## Lo que cada aldeano sabe por otros aldeanos (capa 3).
const RUMORES_MAXIMOS: int = 6
const DIARIO_MAXIMO: int = 30
const LARGO_RECUERDO: int = 140
## Hechos acumulados que despiertan al narrador aunque ninguno sea importante.
const HECHOS_PARA_NARRAR: int = 4
const HECHOS_MAXIMOS: int = 10

var premisa: Dictionary = {}
var poblacion: Dictionary = {}
var ids_originales: Array = []
## {version, resumen, hilos: [], diario: [String], npcs: {id: {recuerdos, indicacion}}, hechos: []}
var estado: Dictionary = {}
var ruta_guardado: String = RUTA_POR_DEFECTO
var narrando: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	premisa = JSON.parse_string(FileAccess.get_file_as_string(RUTA_PREMISA))
	ids_originales = premisa.npcs.keys()
	poblacion = JSON.parse_string(FileAccess.get_file_as_string(RUTA_POBLACION))
	for id in poblacion:
		var p: Dictionary = poblacion[id]
		var relaciones := PackedStringArray()
		for otro in p.relaciones:
			var nombre: String = poblacion.get(otro, premisa.npcs.get(otro, {})).get("nombre", otro)
			relaciones.append("%s (%s)" % [nombre, p.relaciones[otro]])
		var ficha := p.duplicate()
		ficha.ficha = "%s, %s de %s. %s. %s %s Le gusta %s y le disgusta %s. Le interesa %s. Sabe: %s Relaciones: %s." % [
			p.edad, p.profesion, p.region, p.personalidad, p.historia, p.habla, p.gustos, p.disgustos, p.intereses, p.conoce, ", ".join(relaciones)]
		premisa.npcs[id] = ficha
	if get_tree().get_script() != null or ProjectSettings.get_setting("application/run/main_scene") == "res://scenes/presentacion/menu_principal.tscn":
		ruta_guardado = ""
	if not cargar():
		reiniciar()


func reiniciar() -> void:
	estado = {
		version = VERSION,
		resumen = premisa.resumen,
		hilos = premisa.hilos.duplicate(true),
		diario = [premisa.diario],
		npcs = {},
		hechos = [],
	}
	for id in premisa.npcs:
		estado.npcs[id] = {recuerdos = [], rumores = [], indicacion = ""}
	guardar()
	historia_actualizada.emit()


func cargar() -> bool:
	if ruta_guardado.is_empty() or not FileAccess.file_exists(ruta_guardado):
		return false
	var datos: Variant = JSON.parse_string(FileAccess.get_file_as_string(ruta_guardado))
	return restaurar_memoria(datos)


func memoria_valida(datos: Variant) -> bool:
	if not datos is Dictionary or datos.get("version") != VERSION or not datos.get("resumen") is String:
		return false
	for clave in ["diario", "hilos", "hechos"]:
		if not datos.get(clave) is Array:
			return false
	if not datos.get("npcs") is Dictionary:
		return false
	for npc in datos.npcs.values():
		if not npc is Dictionary or not npc.get("recuerdos") is Array:
			return false
	return datos.get("reloj", {}) is Dictionary and datos.get("aldeanos", {}) is Dictionary


func restaurar_memoria(datos: Variant) -> bool:
	if not memoria_valida(datos):
		return false
	estado = datos
	# NPC añadidos a la premisa después de empezar la partida.
	for id in premisa.npcs:
		if not estado.npcs.has(id):
			estado.npcs[id] = {recuerdos = [], rumores = [], indicacion = ""}
		if not estado.npcs[id].has("rumores"):
			estado.npcs[id].rumores = []
	return true


func guardar() -> void:
	if ruta_guardado.is_empty():
		return
	var archivo := FileAccess.open(ruta_guardado, FileAccess.WRITE)
	if archivo:
		archivo.store_string(JSON.stringify(estado, "\t"))


func tiene_npc(id: StringName) -> bool:
	return premisa.npcs.has(String(id))


func nombres_npc() -> Dictionary:
	var nombres := {}
	for id in premisa.npcs:
		nombres[id] = premisa.npcs[id].nombre
	return nombres


func encargo_de(id: StringName) -> Dictionary:
	var ficha: Dictionary = premisa.npcs.get(String(id), {})
	var encargo: Dictionary = ficha.get("encargo", {})
	return encargo.duplicate()


## Lo que el NPC necesita saber para hablar, ya recortado.
func contexto(id: StringName) -> Dictionary:
	var ficha: Dictionary = premisa.npcs[String(id)]
	var memoria: Dictionary = estado.npcs[String(id)]
	var hilos := PackedStringArray()
	for hilo in estado.hilos:
		if hilo.estado == "abierto":
			hilos.append("%s: %s" % [hilo.titulo, hilo.nota])
	return {
		mundo = premisa.mundo,
		nombre = ficha.nombre,
		ficha = ficha.ficha,
		resumen = estado.resumen,
		hilos = hilos,
		indicacion = memoria.indicacion,
		recuerdos = PackedStringArray(memoria.recuerdos),
		rumores = PackedStringArray(memoria.get("rumores", [])),
	}


func recordar(id: StringName, texto: String) -> void:
	texto = texto.strip_edges().left(LARGO_RECUERDO)
	if texto.is_empty() or not tiene_npc(id):
		return
	var recuerdos: Array = estado.npcs[String(id)].recuerdos
	recuerdos.append(texto)
	while recuerdos.size() > RECUERDOS_MAXIMOS:
		recuerdos.pop_front()
	guardar()


## Algo que un aldeano ha sabido por otro (no del viajero).
func aprender(id: StringName, texto: String) -> void:
	texto = texto.strip_edges().left(LARGO_RECUERDO)
	if texto.is_empty() or not tiene_npc(id):
		return
	var rumores: Array = estado.npcs[String(id)].get("rumores", [])
	rumores.append(texto)
	while rumores.size() > RUMORES_MAXIMOS:
		rumores.pop_front()
	estado.npcs[String(id)].rumores = rumores
	guardar()


## Hecho para el narrador. Lo despierta si es importante o se acumulan varios.
func registrar_hecho(texto: String, importante: bool = false) -> void:
	texto = texto.strip_edges().left(LARGO_RECUERDO)
	if texto.is_empty():
		return
	var hechos: Array = estado.hechos
	hechos.append(texto)
	while hechos.size() > HECHOS_MAXIMOS:
		hechos.pop_front()
	guardar()
	if (importante or hechos.size() >= HECHOS_PARA_NARRAR) and not narrando and IA.disponible():
		narrar()


func narrar() -> void:
	if estado.hechos.is_empty():
		return
	narrando = true
	var hechos: Array = estado.hechos.duplicate()
	var ids: Array = premisa.npcs.keys()
	var mensajes := PromptsIA.mensajes_narrador(estado, nombres_npc(), hechos)
	var resultado: Dictionary = await IA.solicitar(mensajes, "narrador", PromptsIA.esquema_narrador(ids), PromptsIA.MAX_TOKENS_NARRADOR)
	narrando = false
	if not resultado.ok:
		return
	# Solo se descartan los hechos ya narrados; los llegados mientras tanto quedan.
	estado.hechos = estado.hechos.slice(hechos.size())
	aplicar_narracion(resultado.datos)


func aplicar_narracion(datos: Dictionary) -> void:
	if str(datos.get("resumen", "")).strip_edges() != "":
		estado.resumen = str(datos.resumen).left(700)
	var hilos: Array = datos.get("hilos", [])
	if not hilos.is_empty():
		estado.hilos = hilos.slice(0, 5)
	for indicacion in datos.get("indicaciones", []):
		if tiene_npc(indicacion.get("npc", "")):
			estado.npcs[indicacion.npc].indicacion = str(indicacion.get("texto", "")).left(LARGO_RECUERDO)
	var entrada := str(datos.get("diario", "")).strip_edges()
	if not entrada.is_empty():
		estado.diario.append(entrada.left(300))
		while estado.diario.size() > DIARIO_MAXIMO:
			estado.diario.pop_front()
	guardar()
	historia_actualizada.emit()
