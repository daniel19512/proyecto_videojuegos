extends Node
## Autoload `Reloj`: día de 30 minutos reales en cuatro franjas (mañana,
## mediodía, tarde y noche). Se para con el árbol en pausa (diálogos, menús,
## minijuegos). Su estado se guarda dentro de la historia (estado.reloj).
## También alimenta el ciclo visual y el progreso de los cultivos.

signal franja_cambiada(dia: int, franja: int)

const DURACION_REAL_DIA: float = 1800.0
const Calendario = preload("res://scripts/ia/calendario.gd")
const DURACION_DIA: float = Calendario.UNIDADES_DIA
const FRANJAS: PackedStringArray = ["mañana", "mediodía", "tarde", "noche"]
## Guardado periódico: parar el juego desde el editor no avisa al cerrarse.
const GUARDAR_CADA: float = 30.0

var dia: int = 1
var segundos: float = 0.0
## Tiempo lógico acumulado para el mundo jugable, incluso si se reinicia la historia.
var tiempo_juego: float = 0.0
## Multiplicador de velocidad (pruebas).
var escala: float = 1.0
var _desde_guardado: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	cargar()
	_anotar()
	Historia.historia_actualizada.connect(_al_reiniciar_historia)


func franja() -> int:
	return mini(int(segundos / (DURACION_DIA / FRANJAS.size())), FRANJAS.size() - 1)


func nombre_franja() -> String:
	return FRANJAS[franja()]


func descripcion() -> String:
	return "día %d, %s" % [dia, nombre_franja()]


func _process(delta: float) -> void:
	if GestorRegiones.en_transicion or GestorRegiones.region_actual == &"":
		return
	_avanzar(delta * escala * DURACION_DIA / DURACION_REAL_DIA)
	_desde_guardado += delta
	if _desde_guardado >= GUARDAR_CADA:
		_desde_guardado = 0.0
		guardar()


func descansar_hasta_manana() -> void:
	_avanzar(DURACION_DIA - segundos)


func _avanzar(avance: float) -> void:
	var antes := franja()
	var total := segundos + avance
	var dias := floori(total / DURACION_DIA)
	segundos = fposmod(total, DURACION_DIA)
	tiempo_juego += avance
	dia += dias
	if dias > 0 or franja() != antes:
		_cambio()


func cargar() -> void:
	var guardado: Dictionary = Historia.estado.get("reloj", {})
	dia = int(guardado.get("dia", 1))
	segundos = float(guardado.get("segundos", 0.0))


func guardar() -> void:
	_anotar()
	Historia.guardar()


## Deja la hora en el estado de la historia (se escribe al guardar).
func _anotar() -> void:
	Historia.estado.reloj = {dia = dia, segundos = segundos}


func _cambio() -> void:
	guardar()
	franja_cambiada.emit(dia, franja())


## «Nueva historia» crea un estado sin hora: el reloj vuelve al día 1 por la
## mañana. Las demás actualizaciones (narrador) ya traen la clave y no la tocan.
func _al_reiniciar_historia() -> void:
	if not Historia.estado.has("reloj"):
		dia = 1
		segundos = 0.0
		_anotar()


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_CLOSE_REQUEST:
		guardar()
