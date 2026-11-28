extends RefCounted

const Bolsa = preload("res://scripts/vida/bolsa.gd")
const ICONO := "res://assets/inventario/iconos/larchrow-rpg-item-icons/PNG/magic/scroll_open.png"
const PUNTOS := {
	"mirador_antiguo": {
		"region": "Montanas", "marcador": "Montanas/Marcadores/Mirador",
		"titulo": "Mirador de las rutas",
		"texto": "Una marca señala el paso de las carretas entre la cantera y la Aldea. Desde aquí vigilaban los convoyes cuando subía el río.",
	},
	"ruinas_mojon": {
		"region": "Ruinas", "marcador": "Ruinas/Marcadores/ZonaA",
		"titulo": "Mojón del bosque",
		"texto": "La inscripción pide dejar libres las veredas para quienes traían madera y plantas al mercado.",
	},
	"ruinas_registro": {
		"region": "Ruinas", "marcador": "Ruinas/Marcadores/ZonaB",
		"titulo": "Registro de los graneros",
		"texto": "Las cuentas describen un acuerdo. Los agricultores entregaban trigo y recibían harina y herramientas del valle.",
	},
	"ruinas_ficha": {
		"region": "Ruinas", "marcador": "Ruinas/Marcadores/ZonaC",
		"titulo": "Puesto de pesaje",
		"texto": "Aquí anotaban las cargas de carbón de las Minas. Una ficha de arcilla lleva las mismas marcas que el registro.",
		"reliquia": "ficha_pesaje",
	},
}


static func examinar(id: String, posicion: Vector3) -> String:
	var ficha: Dictionary = PUNTOS[id]
	var estado := EstadoMundo.objeto("@descubrimientos", id)
	if not estado.get("descubierto", false):
		for npc in Aldeanos.nodos.values():
			if npc.global_position.distance_squared_to(posicion) <= 16.0:
				Historia.aprender(npc.id_npc, "Viste a %s examinar %s." % [EstadoMundo.nombre_protagonista(), ficha.titulo])
	estado.descubierto = true
	EstadoMundo.registrar_actividad("examinar", id)
	if not ficha.has("reliquia") or estado.get("reliquia_recogida", false):
		return ""
	if not Bolsa.anadir(Bolsa.jugador(), ficha.reliquia, 1):
		return "La ficha sigue aquí. Libera espacio en la mochila para recogerla."
	estado.reliquia_recogida = true
	EstadoMundo.actividad_registrada.emit("reliquia", id)
	return "Guardaste la ficha de pesaje en la mochila."
