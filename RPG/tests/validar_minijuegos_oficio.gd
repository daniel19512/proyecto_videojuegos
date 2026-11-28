extends SceneTree
## Desde la raiz: godot --headless --path RPG --log-file logs/validar_minijuegos_oficio.log --script res://tests/validar_minijuegos_oficio.gd
## Minijuegos de oficio: reglas de cerveza, pan y forja, e integracion de su
## punto dentro de la taberna E01, la panaderia E02 y la herreria E03.

const INTERIORES := [
	["res://scenes/interiores/taberna_e01.tscn", "MinijuegoCerveza", "Elaborar cerveza"],
	["res://scenes/interiores/panaderia_e02.tscn", "MinijuegoPan", "Hornear pan"],
	["res://scenes/interiores/herreria_e03.tscn", "MinijuegoForja", "Forjar"],
]

## Tipos de evento de cada lógica que deben tener sonido.
const TIPOS := {
	"MinijuegoCerveza": [&"ingrediente", &"receta", &"error"],
	"MinijuegoPan": [&"dorado", &"crudo", &"quemado"],
	"MinijuegoForja": [&"golpe", &"pieza", &"flojo", &"frio", &"calentar"],
}

var fallos: int = 0


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


func validar() -> void:
	print("VERSION: ", Engine.get_version_info().string)
	validar_cerveza()
	validar_pan()
	validar_forja()
	for datos in INTERIORES:
		await validar_interior(datos[0], datos[1], datos[2])
	await validar_sonidos_pesca()
	print("RESULTADO_MINIJUEGOS_OFICIO: ", fallos, " fallos")
	quit(0 if fallos == 0 else 1)


func validar_cerveza() -> void:
	var l := LogicaCerveza.new(7)
	var orden := l.receta.duplicate()
	orden.sort()
	comprobar(orden == [0, 1, 2, 3] and l.paso == 0, "cerveza: la receta es un orden de los cuatro ingredientes")
	var otra := LogicaCerveza.new(7)
	comprobar(otra.receta == l.receta, "cerveza: misma semilla, misma receta")
	var equivocado: int = l.receta[1]
	l.echar(equivocado, Vector2.ZERO)
	comprobar(l.ultimos_eventos.back().tipo == &"error", "cerveza: el error lleva su tipo de sonido")
	comprobar(l.puntuacion == LogicaCerveza.PUNTOS_ERROR and l.paso == 0 and l.errores == 1, "cerveza: ingrediente fuera de orden resta y no avanza")
	for i in 4:
		l.echar(l.ingrediente_necesario(), Vector2.ZERO)
	var tipos_cerveza := l.ultimos_eventos.map(func(e): return e.tipo)
	comprobar(tipos_cerveza.slice(-4) == [&"ingrediente", &"ingrediente", &"ingrediente", &"receta"], "cerveza: ingredientes y receta completa llevan su tipo")
	comprobar(l.recetas_completadas == 1 and l.paso == 0 and l.puntuacion == LogicaCerveza.PUNTOS_ERROR + 4 * LogicaCerveza.PUNTOS_CORRECTO + LogicaCerveza.PUNTOS_RECETA, "cerveza: receta completa suma bonificacion y empieza otra")
	# Un ingrediente que cae sobre el caldero se echa solo.
	var c := LogicaCerveza.new(3)
	c.objetos.append({tipo = c.ingrediente_necesario(), pos = Vector2(c.caldero_x, LogicaCerveza.CALDERO_Y - 14), velocidad = 120.0})
	c.avanzar(0.05, 0.0)
	comprobar(c.aciertos == 1 and c.paso == 1, "cerveza: el caldero recoge lo que le cae encima")
	c.avanzar(0.1, 1.0)
	comprobar(c.caldero_x > LogicaCerveza.ANCHO * 0.5, "cerveza: el eje mueve el caldero")
	var apariciones := 0
	for i in 600:
		c.avanzar(0.1, 0.0)
		apariciones = maxi(apariciones, c.objetos.size())
	comprobar(apariciones > 0 and c.terminada() and c.tiempo_restante == 0.0, "cerveza: aparecen ingredientes y la partida dura 60 s")


func validar_pan() -> void:
	var l := LogicaPan.new(5)
	comprobar(l.hornos.size() == LogicaPan.HORNOS and l.punto(0) == LogicaPan.Punto.VACIO, "pan: cuatro bocas vacias al empezar")
	l.avanzar(1.3, 0, false)
	var ocupados := 0
	for i in LogicaPan.HORNOS:
		ocupados += int(l.hornos[i].ocupado)
	comprobar(ocupados == LogicaPan.HORNOS, "pan: las hogazas entran solas al horno")
	l.hornos[0].coccion = 0.7
	l.ultimos_eventos.clear()
	l.sacar_hogaza(0)
	comprobar(l.ultimos_eventos.back().tipo == &"dorado", "pan: la hogaza dorada lleva su tipo")
	comprobar(l.puntuacion == LogicaPan.PUNTOS_DORADO and l.doradas == 1 and not l.hornos[0].ocupado, "pan: hogaza dorada suma")
	l.hornos[1].coccion = 0.3
	l.sacar_hogaza(1)
	comprobar(l.crudas == 1 and l.puntuacion == LogicaPan.PUNTOS_DORADO + LogicaPan.PUNTOS_CRUDO, "pan: hogaza cruda resta")
	l.hornos[2].coccion = 0.9
	l.sacar_hogaza(2)
	comprobar(l.quemadas == 1, "pan: hogaza quemada resta")
	l.hornos[3].coccion = LogicaPan.CARBONIZADO - 0.01
	l.avanzar(0.1, 0, false)
	comprobar(l.quemadas == 2 and not l.hornos[3].ocupado, "pan: si se deja demasiado se carboniza sola")
	var puntos_antes := l.puntuacion
	l.sacar_hogaza(3)
	comprobar(l.puntuacion == puntos_antes, "pan: sacar de una boca vacia no cuenta")
	l.avanzar(0.01, 1, false)
	l.avanzar(0.01, 1, false)
	l.avanzar(0.01, 1, false)
	l.avanzar(0.01, 1, false)
	comprobar(l.seleccion == LogicaPan.HORNOS - 1, "pan: la seleccion se queda en la ultima boca")
	for i in 700:
		l.avanzar(0.1, 0, false)
	comprobar(l.terminada(), "pan: la partida termina a los 60 s")


func validar_forja() -> void:
	var l := LogicaForja.new()
	l.aguja = LogicaForja.ZONA_CENTRO
	for i in LogicaForja.GOLPES_POR_PIEZA:
		l.golpe()
	comprobar(l.piezas == 1 and l.golpes == 0 and l.puntuacion == LogicaForja.GOLPES_POR_PIEZA * LogicaForja.PUNTOS_GOLPE + LogicaForja.PUNTOS_PIEZA, "forja: cinco golpes en la zona terminan una pieza")
	l.aguja = 0.05
	l.golpe()
	comprobar(l.golpes_flojos == 1, "forja: golpe fuera de la zona resta")
	l.aguja = LogicaForja.ZONA_CENTRO
	l.temperatura = LogicaForja.TEMPERATURA_MINIMA - 0.05
	l.golpe()
	comprobar(l.golpes_en_frio == 1 and l.golpes == 0, "forja: golpear en frio resta y no avanza")
	l.avanzar(0.016, false, true)
	comprobar(l.calentando > 0.0 and l.ultimos_eventos.back().tipo == &"calentar" and l.ultimos_eventos.back().puntos == 0, "forja: abajo mete la pieza al fuego (evento sin puntos)")
	var antes := l.golpes_buenos + l.golpes_flojos + l.golpes_en_frio
	l.avanzar(0.016, true, false)
	comprobar(l.golpes_buenos + l.golpes_flojos + l.golpes_en_frio == antes, "forja: no se golpea mientras se calienta")
	for i in 80:
		l.avanzar(0.016, false, false)
	comprobar(l.calentando == 0.0 and l.temperatura > 0.95, "forja: al salir del fuego vuelve al rojo")
	var minimo := 1.0
	var maximo := 0.0
	for i in 200:
		l.avanzar(0.016, false, false)
		minimo = minf(minimo, l.aguja)
		maximo = maxf(maximo, l.aguja)
	comprobar(minimo >= 0.0 and maximo <= 1.0 and maximo - minimo > 0.9, "forja: la aguja recorre todo el medidor sin salirse")
	for i in 4000:
		l.avanzar(0.016, false, false)
	comprobar(l.terminada() and l.temperatura < LogicaForja.TEMPERATURA_MINIMA, "forja: la pieza se enfria y la partida termina")


## Cada nombre tiene al menos una ruta y todas cargan como audio.
func comprobar_sonidos(reproductor: ReproductorSonidos, id: String, nombres: Array) -> void:
	var correctos := true
	for nombre in nombres:
		var rutas: Array = reproductor.sonidos.get(nombre, [])
		if rutas.is_empty():
			correctos = false
			push_error("sin sonido: %s %s" % [id, nombre])
		for ruta in rutas:
			if not load(ruta) is AudioStream:
				correctos = false
				push_error("audio no carga: " + ruta)
	comprobar(correctos and reproductor.get_child_count() == ReproductorSonidos.CANALES, id + ": todos sus sonidos existen y cargan")


func validar_sonidos_pesca() -> void:
	var panel: CanvasLayer = load("res://scenes/minijuego_pesca.tscn").instantiate()
	root.add_child(panel)
	await process_frame
	comprobar_sonidos(panel.sonido, "pesca", [&"abrir", &"empezar", &"fin", &"cerrar", &"pez", &"escapado", &"piedra"])
	comprobar(panel._sonido_de(LogicaPesca.PUNTOS_PEZ) == &"pez" and panel._sonido_de(LogicaPesca.PUNTOS_PEZ_PERDIDO) == &"escapado" and panel._sonido_de(LogicaPesca.PUNTOS_PIEDRA) == &"piedra", "pesca: cada suceso tiene su sonido")
	panel.abrir()
	comprobar(panel.sonido.ultimo == &"abrir", "pesca: suena al abrir")
	panel.cerrar()
	comprobar(panel.sonido.ultimo == &"cerrar", "pesca: suena al cerrar")
	panel.queue_free()


func validar_interior(ruta: String, nombre_panel: String, texto: String) -> void:
	var escena: Node3D = load(ruta).instantiate()
	root.add_child(escena)
	current_scene = escena
	await esperar(10)
	var id := ruta.get_file().get_basename()
	var jugador: CharacterBody3D = escena.get_node("Jugador")
	var punto: Node3D = escena.get_node("PuntoMinijuego")
	var salida: Area3D = escena.get_node("Salida")
	var panel: MinijuegoBase = punto.minijuego
	comprobar(panel.name == nombre_panel and texto in punto.get_node("Aviso").text, id + ": punto con su minijuego y aviso propio")
	comprobar_sonidos(panel.sonido, id, [&"abrir", &"empezar", &"fin", &"cerrar"] + TIPOS[nombre_panel])

	# Se puede estar de pie en el centro del punto.
	var consulta := PhysicsShapeQueryParameters3D.new()
	consulta.shape = jugador.get_node("ColisionJugador").shape
	consulta.transform = Transform3D(Basis(), punto.global_position + Vector3(0, 0.82, 0))
	consulta.exclude = [jugador.get_rid()]
	var choques := escena.get_world_3d().direct_space_state.intersect_shape(consulta, 8)
	comprobar(choques.filter(func(c): return not "Suelo" in str(c.collider.name) and not "Cimiento" in str(c.collider.name)).is_empty(), id + ": el punto esta en suelo libre")

	# Nunca se activan a la vez el minijuego y la salida (comparten F). El jugador
	# aparece junto a la salida: primero se asienta en el punto.
	jugador.global_position = punto.global_position + Vector3(0, 0.05, 0)
	await esperar(10)
	var solapes := 0
	for i in 31:
		jugador.global_position = punto.global_position.lerp(salida.global_position, i / 30.0) + Vector3(0, 0.05, 0)
		jugador.velocity = Vector3.ZERO
		await esperar(3)
		if punto.jugador_cerca and salida.habilitada:
			solapes += 1
	comprobar(solapes == 0, id + ": la zona del minijuego no se solapa con la salida")

	jugador.global_position = punto.global_position + Vector3(0, 0.05, 0)
	jugador.velocity = Vector3.ZERO
	await esperar(12)
	comprobar(punto.jugador_cerca and punto.get_node("Aviso").visible and not salida.habilitada, id + ": junto al punto solo aparece su aviso")
	var recetas := {
		"cerveza": ["cerveza_suave", {"trigo": 1, "hierbas": 1}],
		"panaderia": ["hogaza", {"harina": 1}],
		"herreria": ["refinar", {"hierro": 1, "carbon": 1}],
	}
	var oficios: GDScript = load("res://scripts/vida/oficios.gd")
	var ficha: Array = recetas[punto.estacion]
	for ingrediente in ficha[1]:
		oficios.Bolsa.anadir(oficios.Bolsa.jugador(), ingrediente, ficha[1][ingrediente])
	await pulsar(&"interactuar")
	var interfaz := root.get_node("InterfazVida")
	comprobar(paused and interfaz.contexto == "estacion", id + ": F abre el selector de recetas")
	interfaz._elegir_receta(ficha[0])
	await process_frame
	comprobar(paused and panel.visible and panel.estado == MinijuegoBase.Estado.INSTRUCCIONES and panel.sonido.ultimo == &"abrir", id + ": F abre las instrucciones, pausa y suena")
	await pulsar(&"interactuar")
	comprobar(panel.estado == MinijuegoBase.Estado.JUGANDO and panel.sonido.ultimo == &"empezar", id + ": F empieza la partida con su sonido")
	var resultados := []
	panel.partida_terminada.connect(func(p): resultados.append(p))
	panel.logica.puntuacion = 42
	match punto.estacion:
		"cerveza":
			panel.logica.recetas_completadas = 1
		"panaderia":
			panel.logica.doradas = 1
		"herreria":
			panel.logica.piezas = 1
	# 0 y no un margen pequeño: en headless dos fotogramas pueden durar menos.
	panel.logica.tiempo_restante = 0.0
	await process_frame
	await process_frame
	comprobar(panel.estado == MinijuegoBase.Estado.RESULTADO and resultados == [42] and panel.sonido.ultimo == &"fin", id + ": al acabar el tiempo suena el final y muestra el resultado")
	comprobar(oficios.xp(punto.estacion) == 12, id + ": el resultado concede experiencia una vez")
	await pulsar(&"ui_cancel")
	comprobar(not panel.visible and not paused and punto.get_node("Aviso").visible and panel.sonido.ultimo == &"cerrar", id + ": Esc cierra, suena y quita la pausa")
	escena.queue_free()
	await esperar(2)
