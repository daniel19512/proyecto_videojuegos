extends Node
## Autoload `IA`: cliente de OpenRouter con salida JSON estructurada,
## configuración en user://ia.cfg (nunca en el repositorio) y tope de tokens
## por sesión. Si no hay clave, se supera el tope o falla la red, `disponible()`
## es falso o la petición devuelve {ok = false} y el juego usa lo fijo.
## En las pruebas (--script) nunca llama a la red: o está desactivada o usa
## `simulador`, un Callable(mensajes, esquema) -> Dictionary.

signal uso_actualizado(tokens: int, coste: float)

const URL := "https://openrouter.ai/api/v1/chat/completions"
const RUTA_CONFIG := "user://ia.cfg"
const MODELO_POR_DEFECTO := "z-ai/glm-5.3-flash"
const TOPE_POR_DEFECTO := 200000
const TIEMPO_LIMITE := 25.0

var activa: bool = true
var clave: String = ""
var modelo: String = MODELO_POR_DEFECTO
var tope_tokens: int = TOPE_POR_DEFECTO
var tokens_sesion: int = 0
var coste_sesion: float = 0.0
var peticiones_en_curso: int = 0
## Ejecución bajo un script de pruebas: sin red ni archivos del jugador.
var modo_pruebas: bool = false
## Solo en pruebas: sustituye a la red.
var simulador: Callable
## Modelos que rechazan el parámetro de razonamiento (se recuerda en la sesión).
var _sin_razonamiento: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	modo_pruebas = get_tree().get_script() != null
	if not modo_pruebas:
		cargar_config()


func disponible() -> bool:
	if modo_pruebas:
		return activa and simulador.is_valid() and tokens_sesion < tope_tokens
	return activa and not clave.strip_edges().is_empty() and tokens_sesion < tope_tokens


func cargar_config() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(RUTA_CONFIG) != OK:
		return
	activa = cfg.get_value("ia", "activa", true)
	clave = cfg.get_value("ia", "clave", "")
	modelo = cfg.get_value("ia", "modelo", MODELO_POR_DEFECTO)
	tope_tokens = cfg.get_value("ia", "tope_tokens", TOPE_POR_DEFECTO)


func guardar_config() -> void:
	if modo_pruebas:
		return
	var cfg := ConfigFile.new()
	cfg.set_value("ia", "activa", activa)
	cfg.set_value("ia", "clave", clave)
	cfg.set_value("ia", "modelo", modelo)
	cfg.set_value("ia", "tope_tokens", tope_tokens)
	cfg.save(RUTA_CONFIG)


## Pide una respuesta JSON que cumpla `esquema` (JSON Schema de un objeto).
## Devuelve {ok: bool, datos: Dictionary, error: String}.
func solicitar(mensajes: Array, nombre_esquema: String, esquema: Dictionary, max_tokens: int) -> Dictionary:
	if not disponible():
		return {ok = false, datos = {}, error = "IA no disponible"}
	peticiones_en_curso += 1
	var resultado: Dictionary
	if modo_pruebas:
		resultado = await _simular(mensajes, esquema)
	else:
		resultado = await _llamar(mensajes, nombre_esquema, esquema, max_tokens)
	peticiones_en_curso -= 1
	return resultado


func _simular(mensajes: Array, esquema: Dictionary) -> Dictionary:
	await get_tree().process_frame
	var datos: Variant = simulador.call(mensajes, esquema)
	if datos is Dictionary and not datos.is_empty():
		_contar(100, 0.0)
		return {ok = true, datos = datos, error = ""}
	return {ok = false, datos = {}, error = "simulador sin respuesta"}


## Pide razonamiento mínimo: algunos modelos baratos (GLM Flash) razonan
## siempre y, sin límite, gastan los tokens de salida antes de escribir el JSON.
## Si el modelo no admite el parámetro (404 sin proveedores), se repite sin él
## y se recuerda. Una respuesta cortada o sin JSON válido se reintenta una vez
## con el doble de margen.
func _llamar(mensajes: Array, nombre_esquema: String, esquema: Dictionary, max_tokens: int) -> Dictionary:
	var razonar := not _sin_razonamiento.has(modelo)
	var resultado := await _peticion(mensajes, nombre_esquema, esquema, max_tokens, razonar)
	if not resultado.ok and razonar and resultado.codigo == 404:
		_sin_razonamiento[modelo] = true
		razonar = false
		resultado = await _peticion(mensajes, nombre_esquema, esquema, max_tokens, false)
	if not resultado.ok and resultado.reintentable:
		resultado = await _peticion(mensajes, nombre_esquema, esquema, max_tokens * 2, razonar)
	return resultado


func _peticion(mensajes: Array, nombre_esquema: String, esquema: Dictionary, max_tokens: int, razonar: bool) -> Dictionary:
	var cuerpo := {
		model = modelo,
		messages = mensajes,
		max_tokens = max_tokens,
		temperature = 0.8,
		response_format = {
			type = "json_schema",
			json_schema = {name = nombre_esquema, strict = true, schema = esquema},
		},
		provider = {require_parameters = true},
	}
	if razonar:
		cuerpo.reasoning = {effort = "minimal"}
	var cabeceras := PackedStringArray([
		"Authorization: Bearer " + clave.strip_edges(),
		"Content-Type: application/json",
		"X-Title: RPG aldea medieval",
	])
	var http := HTTPRequest.new()
	http.timeout = TIEMPO_LIMITE
	add_child(http)
	var error := http.request(URL, cabeceras, HTTPClient.METHOD_POST, JSON.stringify(cuerpo))
	if error != OK:
		http.queue_free()
		return _fallo("no se pudo enviar (%d)" % error)
	var respuesta: Array = await http.request_completed
	http.queue_free()
	var codigo: int = respuesta[1]
	var texto: String = (respuesta[3] as PackedByteArray).get_string_from_utf8()
	if respuesta[0] != HTTPRequest.RESULT_SUCCESS or codigo != 200:
		push_warning("IA: error HTTP %d %s" % [codigo, texto.left(300)])
		return _fallo("HTTP %d" % codigo, codigo)
	var json: Variant = _analizar(texto)
	if not json is Dictionary or not json.has("choices"):
		return _fallo("respuesta sin choices")
	var uso: Dictionary = json.get("usage", {})
	_contar(int(uso.get("total_tokens", 0)), float(uso.get("cost", 0.0)))
	var eleccion: Dictionary = json.choices[0]
	var contenido := str(eleccion.get("message", {}).get("content", ""))
	var datos: Variant = _analizar(_limpiar_json(contenido))
	if not datos is Dictionary:
		push_warning("IA: JSON no válido (fin: %s, %d tokens de salida): %s" % [
			eleccion.get("finish_reason", "?"), int(uso.get("completion_tokens", 0)), contenido.left(200)])
		return _fallo("JSON no válido", 200, true)
	return {ok = true, datos = datos, error = "", codigo = 200, reintentable = false}


func _fallo(error: String, codigo: int = 0, reintentable: bool = false) -> Dictionary:
	return {ok = false, datos = {}, error = error, codigo = codigo, reintentable = reintentable}


## Analiza JSON sin llenar el registro de errores del motor.
func _analizar(texto: String) -> Variant:
	var json := JSON.new()
	return json.data if json.parse(texto) == OK else null


func _contar(tokens: int, coste: float) -> void:
	tokens_sesion += tokens
	coste_sesion += coste
	uso_actualizado.emit(tokens_sesion, coste_sesion)


## Algunos modelos envuelven el JSON en ```json ... ```; se recorta.
func _limpiar_json(texto: String) -> String:
	var inicio := texto.find("{")
	var fin := texto.rfind("}")
	if inicio == -1 or fin <= inicio:
		return texto
	return texto.substr(inicio, fin - inicio + 1)
