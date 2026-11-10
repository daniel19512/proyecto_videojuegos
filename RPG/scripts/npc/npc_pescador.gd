extends StaticBody3D
## Pescador junto al rio. Dialogo fijo escrito a mano que comenta las partidas
## de pesca del jugador. Al hablar pausa el mundo, como los minijuegos.

@export var nombre: String = "Tomás, el pescador"
## Punto de pesca cuyas partidas comenta (su hijo MinijuegoPesca).
@export var punto_pesca: NodePath

var jugador_cerca: bool = false
var conversaciones: int = 0
var partidas: int = 0
var mejor_puntuacion: int = 0
var ultima_puntuacion: int = 0

@onready var _zona: Area3D = $Zona
@onready var _aviso: Label3D = $Aviso
@onready var _caja: CanvasLayer = $CajaDialogo


func _ready() -> void:
	_aviso.visible = false
	_zona.body_entered.connect(_al_entrar)
	_zona.body_exited.connect(_al_salir)
	_caja.cerrado.connect(_al_cerrar_dialogo)
	if not punto_pesca.is_empty():
		var minijuego: Node = get_node(punto_pesca).get_node("MinijuegoPesca")
		minijuego.partida_terminada.connect(registrar_partida)


func _process(_delta: float) -> void:
	# Con el arbol en pausa este nodo no se procesa, asi que no reabre la caja.
	if jugador_cerca and Input.is_action_just_pressed("interactuar"):
		hablar()


func hablar() -> void:
	_aviso.visible = false
	get_tree().paused = true
	_caja.mostrar(nombre, lineas_dialogo())
	conversaciones += 1


func registrar_partida(puntuacion: int) -> void:
	if partidas == 0 or puntuacion > mejor_puntuacion:
		mejor_puntuacion = puntuacion
	ultima_puntuacion = puntuacion
	partidas += 1


func lineas_dialogo() -> PackedStringArray:
	if partidas == 0:
		if conversaciones == 0:
			return PackedStringArray([
				"¡Buenas! Soy Tomás. Llevo media vida pescando en este río.",
				"Si quieres probar suerte, coge la red de la orilla, aquí al lado, y pulsa F.",
				"Atrapa los peces, pero ojo con las piedras: la corriente arrastra de todo.",
			])
		return PackedStringArray(["¿Todavía no has probado? La red te espera junto a la orilla."])
	var lineas := PackedStringArray()
	if mejor_puntuacion <= 0:
		lineas.append("Bueno... el río no siempre es generoso. Tu mejor marca es %d puntos." % mejor_puntuacion)
		lineas.append("Mueve la red con calma y deja pasar las piedras. ¡Ya verás!")
	elif mejor_puntuacion < 100:
		lineas.append("Tu mejor marca: %d puntos. No está mal para empezar." % mejor_puntuacion)
	elif mejor_puntuacion < 200:
		lineas.append("¡%d puntos! Tienes buena mano con la red." % mejor_puntuacion)
	else:
		lineas.append("¿%d puntos? ¡A este paso me vas a dejar sin peces!" % mejor_puntuacion)
	if partidas > 1 and ultima_puntuacion < mejor_puntuacion:
		lineas.append("La última vez hiciste %d. Seguro que puedes repetir lo de antes." % ultima_puntuacion)
	return lineas


func _al_cerrar_dialogo() -> void:
	get_tree().paused = false
	_aviso.visible = jugador_cerca


func _al_entrar(cuerpo: Node3D) -> void:
	if cuerpo is CharacterBody3D:
		jugador_cerca = true
		_aviso.visible = true


func _al_salir(cuerpo: Node3D) -> void:
	if cuerpo is CharacterBody3D:
		jugador_cerca = false
		_aviso.visible = false
