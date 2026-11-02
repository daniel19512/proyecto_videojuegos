extends SceneTree
## Ocho vistas de E04 en el mundo real; no exige cerrar las fachadas del taller abierto.
var fallos := 0
func _initialize() -> void:
	call_deferred("validar")
func comprobar(valor: bool, mensaje: String) -> void:
	if valor:
		print("OK: ",mensaje)
	else:
		fallos += 1
		push_error(mensaje)
func esperar(n: int) -> void:
	for i in n:
		await physics_frame
	await process_frame
func validar() -> void:
	print("VERSION: ",Engine.get_version_info().string)
	var mundo: Node3D = load("res://scenes/mundo.tscn").instantiate()
	root.add_child(mundo)
	current_scene = mundo
	await esperar(10)
	var edificio: Node3D = mundo.get_node("Aldea/Edificios/E04")
	var jugador: CharacterBody3D = mundo.get_node("Jugador")
	var camara: Camera3D = mundo.get_node("CamaraPrincipal")
	jugador.set_physics_process(false)
	jugador.global_position = edificio.global_position + Vector3(3.8,0.02,0)
	var consulta := PhysicsRayQueryParameters3D.new()
	consulta.exclude = [jugador.get_rid()]
	var estado := mundo.get_world_3d().direct_space_state
	# Desde el este hasta el centro no debe existir pared invisible.
	consulta.from = edificio.global_position + Vector3(4,1.4,0)
	consulta.to = edificio.global_position + Vector3(0,1.4,0)
	comprobar(estado.intersect_ray(consulta).is_empty(),"E04: fachada este abierta tambien en fisica")
	consulta.from = edificio.global_position + Vector3(-4,1.4,0)
	consulta.to = edificio.global_position + Vector3(-2.7,1.4,0)
	comprobar(not estado.intersect_ray(consulta).is_empty(),"E04: muro oeste solido")
	for ruta in ["ZonaTrabajo/Corte", "ZonaTrabajo/Banco", "Almacen/Tronco0", "MueblesEnProceso/Asiento"]:
		comprobar(edificio.has_node(ruta),"E04: elemento presente "+ruta)
	# Centrado de inspeccion; se conserva el script, la proyeccion y el tamano del mundo.
	camara.set_process(false)
	var centro := edificio.global_position + Vector3.UP*0.8
	for grados in [0,45,90,135,180,225,270,315]:
		var desplazamiento := Vector3(0,13,20.80435).rotated(Vector3.UP,deg_to_rad(float(grados)))
		camara.global_position = centro + desplazamiento
		camara.look_at(centro)
		await esperar(8)
		comprobar(is_equal_approx(camara.size,15) and absf(camara.rotation_degrees.x+32)<0.1,"E04: camara 15 y -32 grados en "+str(grados))
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			comprobar(root.get_texture().get_image().save_png("user://carpinteria_E04_%03d.png"%grados)==OK,"Captura E04 "+str(grados))
	print("CAPTURAS: ",ProjectSettings.globalize_path("user://"))
	print("RESULTADO_CARPINTERIA_360: %d fallos"%fallos)
	quit(0 if fallos == 0 else 1)
