extends Node
## Recado de ejemplo entre NPCs: la panadera pide llevar una hogaza al guardia
## y luego da las gracias. El estado solo dura la sesión (como la memoria de
## Tomás); no hay inventario: la hogaza es implícita en el estado.

signal estado_cambiado(estado: Estado)

enum Estado { SIN_EMPEZAR, LLEVANDO_PAN, ENTREGADO, COMPLETADO }

@export var id_quien_encarga: StringName = &"panadera"
@export var id_destinatario: StringName = &"guardia"

var estado: Estado = Estado.SIN_EMPEZAR


## Líneas del recado para ese NPC, avanzando el estado si corresponde.
## Vacío = el recado no tiene nada que decir y el NPC usa sus líneas fijas.
func lineas_para(id_npc: StringName) -> PackedStringArray:
	if id_npc == id_quien_encarga:
		match estado:
			Estado.SIN_EMPEZAR:
				_cambiar(Estado.LLEVANDO_PAN)
				return PackedStringArray([
					"¡Hola! Soy Marta, la panadera. Huele bien, ¿eh? Acaba de salir del horno.",
					"¿Me harías un favor? Bruno, el guardia, no ha venido a por su pan hoy.",
					"Da vueltas alrededor de la plaza. Llévale esta hogaza, por favor.",
				])
			Estado.LLEVANDO_PAN:
				return PackedStringArray(["Bruno estará patrullando alrededor de la plaza. ¡Que no se enfríe la hogaza!"])
			Estado.ENTREGADO:
				_cambiar(Estado.COMPLETADO)
				return PackedStringArray([
					"¿Ya se la diste? ¡Muchas gracias!",
					"Vuelve cuando quieras: siempre habrá algo recién horneado para ti.",
				])
	elif id_npc == id_destinatario and estado == Estado.LLEVANDO_PAN:
		_cambiar(Estado.ENTREGADO)
		return PackedStringArray([
			"¿Pan de Marta? ¡Por fin! Con tanta ronda no me dio tiempo a pasar.",
			"Dale las gracias de mi parte. Ahora sí puedo seguir vigilando.",
		])
	return PackedStringArray()


func _cambiar(nuevo: Estado) -> void:
	estado = nuevo
	estado_cambiado.emit(estado)
