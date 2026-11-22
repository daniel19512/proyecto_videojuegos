extends SceneTree
## Desde la raiz: godot --headless --path RPG --log-file logs/validar_npcs_aldea.log --script res://tests/validar_npcs_aldea.gd
## Panadera, herrero, tabernero y guardia de la aldea: sprites propios, colocacion fuera de
## caminos y puertas, patrulla del guardia, orientacion segun camara y el
## recado de ejemplo (llevar pan de la panadera al guardia).

var fallos: int = 0
var mundo: Node3D
var jugador: CharacterBody3D


func _initialize() -> void:
	call_deferred("validar")


func comprobar(condicion: bool, mensaje: String) -> void:
	if condicion:
		print("OK: ", mensaje)
	else:
		fallos += 1
		push_error("FALLO: " + mensaje)


func esperar(n: int) -> void:
	for i in n:
		await physics_frame
	await process_frame


func pulsar(accion: StringName) -> void:
	var evento := InputEventAction.new()
	evento.action = accion
	evento.pressed = true
	Input.parse_input_event(evento)
	await process_frame
	await process_frame
	evento = InputEventAction.new()
	evento.action = accion
	evento.pressed = false
	Input.parse_input_event(evento)
	await process_frame


## Avanza la caja hasta cerrarla; devuelve cuantas lineas mostro.
func leer_todo(caja: CanvasLayer) -> int:
	var vistas := 0
	for i in 20:
		if not caja.abierta:
			break
		vistas = maxi(vistas, caja.indice + 1)
		await pulsar(&"interactuar")
		await pulsar(&"interactuar")
	return vistas


## Coloca al jugador junto al NPC, pulsa F y lee la conversacion entera.
func conversar(npc: Node3D) -> PackedStringArray:
	jugador.global_position = npc.global_position + Vector3(0.9, 0.5, 0)
	await esperar(12)
	if not npc.jugador_cerca:
		return PackedStringArray(["<sin zona>"])
	await pulsar(&"interactuar")
	var caja: CanvasLayer = npc.get_node("CajaDialogo")
	var lineas: PackedStringArray = caja.lineas.duplicate()
	if not paused or not caja.abierta:
		return PackedStringArray(["<no abrio>"])
	await leer_todo(caja)
	return lineas


## Altura en el mundo de los pies (x) y de la cabeza (y) del primer fotograma
## idle_abajo, a partir de los pixeles opacos de la hoja, pixel_size y offset.
func alturas_sprite(sprite: AnimatedSprite3D) -> Vector2:
	var atlas: AtlasTexture = sprite.sprite_frames.get_frame_texture(&"idle_abajo", 0)
	var imagen := atlas.atlas.get_image()
	if imagen.is_compressed():
		imagen.decompress()
	var region := Rect2i(atlas.region)
	var arriba := region.size.y
	var abajo := 0
	for y in region.size.y:
		for x in region.size.x:
			if imagen.get_pixel(region.position.x + x, region.position.y + y).a > 0.08:
				arriba = mini(arriba, y)
				abajo = maxi(abajo, y + 1)
	var mitad := region.size.y * 0.5
	var pies := (mitad - abajo + sprite.offset.y) * sprite.pixel_size
	var cabeza := (mitad - arriba + sprite.offset.y) * sprite.pixel_size
	return Vector2(pies, cabeza)


func capsula_libre(p: Vector3, excluir: Array) -> Array:
	var forma := CapsuleShape3D.new()
	forma.radius = 0.34
	forma.height = 1.6
	var consulta := PhysicsShapeQueryParameters3D.new()
	consulta.shape = forma
	consulta.transform = Transform3D(Basis(), p + Vector3(0, 0.85, 0))
	consulta.exclude = excluir
	var choques := []
	for g in jugador.get_world_3d().direct_space_state.intersect_shape(consulta, 8):
		if not "Suelo" in str(g.collider.name):
			choques.append(g.collider)
	return choques


## Recorre en linea recta del NPC a la puerta: nunca deben activarse ambas F.
func sin_solape_con_puerta(npc: Node3D, puerta: Area3D) -> bool:
	var solapes := 0
	for i in 31:
		var t := i / 30.0
		jugador.global_position = npc.global_position.lerp(puerta.global_position, t) + Vector3(0, 0.5, 0)
		await esperar(3)
		if npc.jugador_cerca and puerta.habilitada:
			solapes += 1
	return solapes == 0


func validar() -> void:
	print("VERSION: ", Engine.get_version_info().string)
	mundo = load("res://scenes/mundo.tscn").instantiate()
	for salida in ["Region/SalidaBosque", "Region/SalidaCampos", "Region/SalidaMontanas"]:
		mundo.get_node(salida).monitoring = false
	root.add_child(mundo)
	current_scene = mundo
	jugador = mundo.get_node("Jugador")
	var panadera: Node3D = mundo.get_node("NPCs/Panadera")
	var herrero: Node3D = mundo.get_node("NPCs/Herrero")
	var guardia: Node3D = mundo.get_node("NPCs/Guardia")
	var tabernero: Node3D = mundo.get_node("NPCs/Tabernero")
	var pescador: StaticBody3D = mundo.get_node("NPCs/Pescador")
	var recado: Node = mundo.get_node("NPCs/RecadoPan")
	await esperar(10)

	# Sprites propios: nadie usa ya el sprite del protagonista.
	var frames_jugador: SpriteFrames = load("res://scenes/jugador_frames.tres")
	for npc: Node3D in [pescador, panadera, herrero, guardia, tabernero]:
		var sprite: AnimatedSprite3D = npc.get_node("Visual/SpriteAnimado")
		var textura: AtlasTexture = sprite.sprite_frames.get_frame_texture(&"idle_abajo", 0)
		comprobar(sprite.sprite_frames != frames_jugador and "/npcs/" in textura.atlas.resource_path, "%s usa su propia hoja (%s)" % [npc.name, textura.atlas.resource_path.get_file()])
		comprobar(sprite.modulate == Color.WHITE, "%s sin tinte de color" % npc.name)
		for anim in ["idle_abajo", "idle_arriba", "idle_izquierda", "idle_derecha", "walk_abajo", "walk_arriba", "walk_izquierda", "walk_derecha"]:
			if not sprite.sprite_frames.has_animation(anim) or sprite.sprite_frames.get_frame_count(anim) != 4:
				comprobar(false, "%s tiene la animacion %s con 4 fotogramas" % [npc.name, anim])

	# Tamano: la altura visible y la de los pies coinciden con las del protagonista.
	var ref := alturas_sprite(jugador.get_node("Visual/SpriteAnimado"))
	for npc: Node3D in [pescador, panadera, herrero, guardia, tabernero]:
		var medida := alturas_sprite(npc.get_node("Visual/SpriteAnimado"))
		comprobar(absf(medida.y - ref.y) < 0.06 and absf(medida.x - ref.x) < 0.03, "%s mide como el protagonista (cabeza %.2f/%.2f, pies %.2f/%.2f)" % [npc.name, medida.y, ref.y, medida.x, ref.x])

	# Colocacion: panadera junto a E02, herrero en el patio de E03, ambos solidos y fuera de caminos.
	comprobar(panadera.global_position.distance_to(Vector3(5, 0, -21.6)) < 3.0, "la panadera esta junto al horno de E02")
	comprobar(herrero.global_position.distance_to(Vector3(-21.7, 0, -4.1)) < 5.0, "el herrero esta en el patio del yunque de E03")
	comprobar(tabernero.global_position.distance_to(Vector3(-8, 0, -15)) < 5.0, "el tabernero esta junto a la puerta de la taberna E01")
	for npc: Node3D in [panadera, herrero, tabernero]:
		var choques := capsula_libre(npc.global_position, [jugador.get_rid()])
		comprobar(choques.size() == 1 and choques[0] == npc.get_node("Cuerpo"), "%s es solido y no se solapa con la escena" % npc.name)
		var excluir := [jugador.get_rid(), npc.get_node("Cuerpo").get_rid()]
		comprobar(capsula_libre(npc.global_position, excluir).is_empty(), "%s ocupa suelo libre" % npc.name)
	comprobar(await sin_solape_con_puerta(panadera, mundo.get_node("PuertaE02")), "la zona de la panadera no se solapa con la puerta de E02")
	comprobar(await sin_solape_con_puerta(herrero, mundo.get_node("PuertaE03")), "la zona del herrero no se solapa con la puerta de E03")
	comprobar(await sin_solape_con_puerta(tabernero, mundo.get_node("PuertaTabernaE01")), "la zona del tabernero no se solapa con la puerta de la taberna")

	# Guardia: sin cuerpo solido, ruta por suelo libre del anillo y movimiento real.
	comprobar(not guardia.has_node("Cuerpo"), "el guardia no tiene cuerpo solido (no bloquea calles)")
	var puntos: PackedVector3Array = guardia.puntos
	var ruta_libre := true
	for i in puntos.size():
		var a := puntos[i]
		var b := puntos[(i + 1) % puntos.size()]
		for k in 40:
			if not capsula_libre(a.lerp(b, k / 40.0), [jugador.get_rid()]).is_empty():
				ruta_libre = false
	comprobar(puntos.size() >= 4 and ruta_libre, "la ruta del guardia recorre suelo libre")
	jugador.global_position = Vector3(0, 0.05, 0)
	await esperar(10)
	var inicio := guardia.global_position
	await esperar(120)
	comprobar(guardia.global_position.distance_to(inicio) > 1.0, "el guardia camina por su ronda")
	comprobar(guardia.get_node("Visual/SpriteAnimado").animation.begins_with("walk_") or guardia._espera > 0.0, "usa la animacion de caminar al desplazarse")

	# Se detiene cuando el jugador se acerca.
	jugador.global_position = guardia.global_position + Vector3(0.9, 0.5, 0)
	await esperar(12)
	var parado := guardia.global_position
	await esperar(60)
	comprobar(guardia.jugador_cerca and guardia.global_position.distance_to(parado) < 0.01, "el guardia se detiene con el jugador cerca")
	comprobar(guardia.get_node("Visual/SpriteAnimado").animation.begins_with("idle_"), "parado usa idle")

	# Orientacion relativa a la camara.
	var camara := mundo.get_viewport().get_camera_3d()
	var adelante := -camara.global_basis.z
	adelante.y = 0
	var derecha := camara.global_basis.x
	derecha.y = 0
	comprobar(herrero.direccion_en_pantalla(adelante.normalized()) == "arriba" and herrero.direccion_en_pantalla(-adelante.normalized()) == "abajo", "mirar lejos de la camara es arriba; hacia ella, abajo")
	comprobar(herrero.direccion_en_pantalla(derecha.normalized()) == "derecha" and herrero.direccion_en_pantalla(-derecha.normalized()) == "izquierda", "derecha e izquierda segun la camara")

	# Recado: guardia antes de empezar -> lineas propias.
	var lineas := await conversar(guardia)
	comprobar("Bruno" in lineas[0] and recado.estado == recado.Estado.SIN_EMPEZAR, "sin recado, el guardia se presenta")
	comprobar(not paused, "cerrar el dialogo quita la pausa")
	lineas = await conversar(herrero)
	comprobar(lineas.size() == 3 and "Gonzalo" in lineas[0] and "Marta" in lineas[2], "el herrero se presenta y menciona el recado")
	lineas = await conversar(tabernero)
	comprobar(lineas.size() == 3 and "Anselmo" in lineas[0] and recado.estado == recado.Estado.SIN_EMPEZAR, "el tabernero se presenta sin alterar el recado")
	lineas = await conversar(panadera)
	comprobar(lineas.size() == 3 and "Marta" in lineas[0] and recado.estado == recado.Estado.LLEVANDO_PAN, "la panadera encarga llevar pan al guardia")
	lineas = await conversar(panadera)
	comprobar(lineas.size() == 1 and "Bruno" in lineas[0], "la panadera recuerda el recado pendiente")
	lineas = await conversar(guardia)
	comprobar("Pan de Marta" in lineas[0] and recado.estado == recado.Estado.ENTREGADO, "el guardia recibe el pan")
	lineas = await conversar(guardia)
	comprobar(lineas.size() == 1 and "Sin novedad" in lineas[0], "despues el guardia vuelve a sus lineas habituales")
	lineas = await conversar(panadera)
	comprobar("gracias" in lineas[0] and recado.estado == recado.Estado.COMPLETADO, "la panadera agradece y el recado se completa")
	lineas = await conversar(panadera)
	comprobar(lineas.size() == 1 and "centeno" in lineas[0], "recado completado: lineas habituales de la panadera")
	comprobar(not paused, "el mundo queda sin pausa al terminar")

	# Al alejarse desaparecen los avisos.
	jugador.global_position = Vector3(0, 0.5, 0)
	await esperar(15)
	for npc: Node3D in [panadera, herrero, tabernero]:
		comprobar(not npc.jugador_cerca and not npc.get_node("Aviso").visible, "%s oculta el aviso al alejarse" % npc.name)
	print("RESULTADO_NPCS_ALDEA: ", fallos, " fallos")
	quit(0 if fallos == 0 else 1)
