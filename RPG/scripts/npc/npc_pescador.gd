extends "res://scripts/npc/npc_aldeano.gd"
## Tomás, el pescador junto al río: aldeano con diálogo fijo propio que comenta
## las partidas de pesca del jugador (señal `partida_terminada` del minijuego).
## Con IA conversa y actúa como los demás; sus partidas quedan como recuerdos.

## Punto de pesca cuyas partidas comenta (su hijo MinijuegoPesca).
@export var punto_pesca: NodePath

var partidas: int = 0
var mejor_puntuacion: int = 0
var ultima_puntuacion: int = 0


func _ready() -> void:
	super._ready()
	var memoria := EstadoMundo.objeto("Aldea", "npc_pescador")
	partidas = int(memoria.get("partidas", 0))
	mejor_puntuacion = int(memoria.get("mejor", 0))
	ultima_puntuacion = int(memoria.get("ultima", 0))
	if not punto_pesca.is_empty():
		var minijuego: Node = get_node(punto_pesca).get_node("MinijuegoPesca")
		minijuego.partida_terminada.connect(registrar_partida)



func registrar_partida(puntuacion: int) -> void:
	if partidas == 0 or puntuacion > mejor_puntuacion:
		mejor_puntuacion = puntuacion
	ultima_puntuacion = puntuacion
	partidas += 1
	EstadoMundo.objeto("Aldea", "npc_pescador").merge({
		"partidas": partidas, "mejor": mejor_puntuacion, "ultima": ultima_puntuacion
	}, true)
	# Recuerdo persistente para la conversación con IA (vale también sin ella).
	Historia.recordar(&"pescador", "El viajero pescó en el río y logró %d puntos." % puntuacion)


func lineas_dialogo() -> PackedStringArray:
	if partidas == 0:
		if conversaciones == 0:
			return PackedStringArray([
				"¡Buenas! Soy Tomás. Llevo media vida pescando en este río.",
				"Si quieres probar suerte, consigue una caña en el Mercado y acércate a la orilla.",
				"Atrapa los peces, pero ojo con las piedras: la corriente arrastra de todo.",
			])
		return PackedStringArray(["¿Todavía no has probado? Trae una caña a la orilla."])
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
