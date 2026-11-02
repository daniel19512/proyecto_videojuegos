extends "res://tests/validar_distribucion.gd"
## Validacion individual reproducible; la regresion general usa validar_aldea.gd.
func validar() -> void:
	print("VERSION: ",Engine.get_version_info().string)
	mundo = load("res://scenes/mundo.tscn").instantiate()
	root.add_child(mundo)
	current_scene = mundo
	aldea = mundo.get_node("Aldea")
	jugador = mundo.get_node("Jugador")
	await esperar(20)
	consulta.shape = jugador.get_node("ColisionJugador").shape
	consulta.exclude = [jugador.get_rid()]
	await validar_vivienda_rural("E08")
	print("RESULTADO_E08: %d fallos" % fallos)
	mundo.queue_free()
	await process_frame
	quit(0 if fallos == 0 else 1)
