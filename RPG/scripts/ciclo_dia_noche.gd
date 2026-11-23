extends Node
## Lee la hora del autoload; las paletas se ordenan igual que Reloj.FRANJAS.
const SOL := [Color("#ffe0ab"), Color("#fff3de"), Color("#ffab68"), Color("#a1baff")]
const ENERGIA := [0.92, 1.30, 0.78, 0.31]
const AMBIENTE := [Color("#c4d5ee"), Color("#e5e9f3"), Color("#e8b99d"), Color("#a1b6e3")]
const RELLENO := [0.77, 0.85, 0.66, 0.56]
const CIELO := [Color("#8faec8"), Color("#a6c1d2"), Color("#ad756d"), Color("#252e48")]
const ALTURA := [36.0, 64.0, 19.0, 49.0]
const AZIMUT := [-52.0, -14.0, 57.0, 121.0]
const APORTE_VENTANA := [0.12, 0.20, 0.08, 0.0]

@export var ambiente: WorldEnvironment
@export var sol: DirectionalLight3D
@export var luz_de_acceso: OmniLight3D
@export var tono_region := Color.WHITE
@export_range(0.7, 1.2) var intensidad_region := 1.0

var _entorno: Environment
var _relleno_interior: float
var _color_interior: Color
var _ultima_hora := -1.0
var _espera := 0.0
var _anterior := -1
var _mezcla := -1.0


func _ready() -> void:
	# Instancias independientes incluso durante el fundido entre escenas.
	if ambiente == null:
		actualizar()
		return
	_entorno = ambiente.environment.duplicate() as Environment
	ambiente.environment = _entorno
	_relleno_interior = _entorno.ambient_light_energy
	_color_interior = _entorno.ambient_light_color
	actualizar()


func _process(delta: float) -> void:
	_espera -= delta
	if _espera <= 0.0:
		_espera = 0.1
		actualizar()


func actualizar() -> void:
	var hora := Reloj.segundos
	if hora == _ultima_hora:
		return
	_ultima_hora = hora
	var fase := fposmod(hora / Reloj.DURACION_DIA * SOL.size(), float(SOL.size()))
	# Mantiene la paleta alrededor del centro de cada franja y cruza
	# gradualmente los límites, incluido el paso de noche a mañana.
	var tramo := fase - 0.5
	var anterior := posmod(floori(tramo), SOL.size())
	var siguiente := (anterior + 1) % SOL.size()
	var mezcla := smoothstep(0.22, 0.78, fposmod(tramo, 1.0))
	# En la meseta de una franja no se vuelven a enviar parámetros al renderizador.
	if anterior == _anterior and mezcla == _mezcla:
		return
	_anterior = anterior
	_mezcla = mezcla
	var color_ambiente: Color = AMBIENTE[anterior].lerp(AMBIENTE[siguiente], mezcla)
	var aporte := lerpf(APORTE_VENTANA[anterior], APORTE_VENTANA[siguiente], mezcla)
	if luz_de_acceso != null:
		luz_de_acceso.light_color = color_ambiente
		luz_de_acceso.light_energy = aporte * 2.5
	if _entorno == null:
		return
	if sol == null:
		_entorno.ambient_light_energy = _relleno_interior + aporte
		_entorno.ambient_light_color = _color_interior.lerp(color_ambiente, aporte)
		return
	sol.light_color = SOL[anterior].lerp(SOL[siguiente], mezcla) * tono_region
	sol.light_energy = lerpf(ENERGIA[anterior], ENERGIA[siguiente], mezcla) * intensidad_region
	sol.rotation = Vector3(
		-deg_to_rad(lerpf(ALTURA[anterior], ALTURA[siguiente], mezcla)),
		lerp_angle(deg_to_rad(AZIMUT[anterior]), deg_to_rad(AZIMUT[siguiente]), mezcla), 0.0)
	_entorno.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	_entorno.ambient_light_color = color_ambiente * tono_region
	_entorno.ambient_light_energy = lerpf(RELLENO[anterior], RELLENO[siguiente], mezcla) * intensidad_region
	_entorno.background_mode = Environment.BG_COLOR
	_entorno.background_color = CIELO[anterior].lerp(CIELO[siguiente], mezcla) * tono_region
