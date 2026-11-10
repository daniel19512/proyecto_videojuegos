extends "res://tests/validar_campos_granjas.gd"
## Solo evidencia visual para iterar composicion; no sustituye validacion fisica.
func validar() -> void:
	if DisplayServer.get_name()=="headless": quit(1); return
	carpeta = "res://logs/fase6e_campos_granjas/vistas_"+Time.get_datetime_string_from_system().replace(":","-")+"_"+str(Time.get_ticks_msec())
	DirAccess.make_dir_recursive_absolute(carpeta)
	mundo = load("res://scenes/mundo_campos_granjas.tscn").instantiate()
	root.add_child(mundo)
	current_scene = mundo
	jugador = mundo.get_node("Jugador")
	jugador.set_physics_process(false)
	mundo.get_node("Region/SalidaAldea").monitoring = false
	await esperar(6)
	await capturar_vistas()
	print("SOLO_CAPTURAS: %d imagenes; fallos captura/buffers=%d; %s"%[imagenes.size(),fallos,carpeta])
	quit(1 if fallos else 0)
