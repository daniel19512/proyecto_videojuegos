extends SceneTree
var fallos := 0
var muestras := 0
var gestor: Node
var carpeta: String
var capturas: Array[String] = []
var negros := 0
var viajes := 0

func _initialize() -> void:
	call_deferred("validar")

func comprobar(ok: bool, texto: String) -> void:
	muestras += 1
	if not ok:
		fallos += 1
		push_error(texto)

func esperar(n: int) -> void:
	for i in n:
		await physics_frame
	await process_frame

func captura(nombre: String) -> void:
	if DisplayServer.get_name()=="headless":
		return
	await RenderingServer.frame_post_draw
	comprobar(root.get_texture().get_image().save_png(carpeta+"/"+nombre+".png")==OK,"Captura "+nombre)
	capturas.append(nombre)

func negro() -> void:
	negros += 1
	comprobar(gestor.negro.color.a>0.999,"Pantalla negra antes del cambio")
	comprobar(not current_scene.get_node("Jugador").is_physics_processing(),"Jugador bloqueado durante fundido")
	if negros==1:
		captura("02_negro")

func comprobar_region(id: StringName) -> void:
	comprobar(gestor.region_actual==id,"Region "+id)
	var personajes := 0
	var activas := 0
	for n in root.find_children("*","CharacterBody3D",true,false):
		if n.get_script()==load("res://scripts/jugador.gd"):
			personajes += 1
	for n in root.find_children("*","Camera3D",true,false):
		if n.current:
			activas += 1
	comprobar(personajes==1,"Un solo protagonista")
	comprobar(activas==1,"Una sola camara activa")
	var config := current_scene.get_node("Region")
	var entrada: Marker3D = config.obtener_entrada("bosque_aldea_sur" if id==&"Bosque" else "aldea_bosque_norte")
	var jugador := current_scene.get_node("Jugador")
	comprobar(jugador.global_position.distance_to(entrada.global_position)<0.3,"Aparicion en marcador seguro")
	comprobar(jugador.is_physics_processing(),"Control restaurado")
	comprobar(current_scene.get_node("CamaraPrincipal").is_processing(),"Camara restaurada")
	comprobar(jugador.velocidad==10.0,"Velocidad conservada")
	comprobar(gestor.negro.color.a<0.001,"Fundido final transparente")
	var areas := current_scene.find_children("*","Area3D",true,false)
	comprobar(areas.size()==(3 if id==&"Aldea" else 2),"Salidas autorizadas: tres en Aldea, dos en Bosque desde 6F")
	if id==&"Aldea":
		comprobar(current_scene.get_node("Region/SalidaCampos").escena_destino=="res://scenes/mundo_campos_granjas.tscn","Salida sur configurada sin sustituir bosque")
	for area in areas:
		comprobar(not area.overlaps_body(jugador),"Aparicion fuera del detector")
	await esperar(45)
	comprobar(not gestor.en_transicion and gestor.region_actual==id,"Sin bucle en reposo")

func caminar_salida(destino: StringName) -> void:
	var jugador := current_scene.get_node("Jugador") as CharacterBody3D
	var camara := current_scene.get_node("CamaraPrincipal")
	camara.angulo_horizontal = 0
	camara.actualizar_orbita()
	# Se recorre desde el marcador de aparición, sin emitir body_entered manualmente.
	var accion := "mover_arriba" if destino==&"Bosque" else "mover_abajo"
	Input.action_press(accion)
	var iniciado := false
	for i in 600:
		await physics_frame
		if gestor.en_transicion:
			iniciado = true
			break
	Input.action_release(accion)
	comprobar(iniciado,"Area activada caminando hacia "+destino)
	if not iniciado:
		return
	comprobar(not gestor.solicitar("res://scenes/mundo.tscn","aldea_bosque_norte"),"Solicitud repetida rechazada")
	if viajes==0:
		for fotograma in 120:
			await process_frame
			if gestor.negro.color.a>0.3:
				break
		comprobar(gestor.negro.color.a>0 and gestor.negro.color.a<1,"Fundido tiene estado intermedio")
		await captura("02a_fundido_parcial")
	for i in 900:
		await process_frame
		if not gestor.en_transicion:
			break
	comprobar(not gestor.en_transicion,"Transicion termina")
	await esperar(3)
	await comprobar_region(destino)
	viajes += 1
	print("TRAYECTO ",viajes," -> ",gestor.region_actual)

func validar() -> void:
	carpeta = "res://logs/fase6b_transiciones/"+Time.get_datetime_string_from_system().replace(":","-")+"_"+str(Time.get_ticks_msec())
	if "--fase6d" in OS.get_cmdline_user_args():
		carpeta = carpeta.replace("fase6b_transiciones","fase6d_bosque_ruinas/aldea_bosque")
	if "--fase6e" in OS.get_cmdline_user_args():
		carpeta = carpeta.replace("fase6b_transiciones","fase6e_campos_granjas/aldea_bosque")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(carpeta))
	root.size = Vector2i(1280,800)
	gestor = root.get_node("GestorRegiones")
	gestor.pantalla_negra.connect(negro)
	for tamano in [Vector2i(960,540),Vector2i(1280,800)]:
		root.size = tamano
		await esperar(2)
		print("COBERTURA_FUNDIDO: rect=",gestor.negro.size," viewport=",root.get_visible_rect().size," ventana=",root.size)
		comprobar(gestor.negro.size.is_equal_approx(root.get_visible_rect().size),"Fundido cubre viewport redimensionado")
	var escena: Node = load("res://scenes/mundo.tscn").instantiate()
	root.add_child(escena)
	current_scene = escena
	await esperar(30)
	comprobar(gestor.region_actual==&"Aldea","Inicio en aldea")
	var jugador: CharacterBody3D = escena.get_node("Jugador")
	var inicio := jugador.position
	Input.action_press("mover_arriba")
	await esperar(30)
	Input.action_release("mover_arriba")
	await esperar(40)
	comprobar(jugador.position.distance_to(inicio)>1,"Movimiento inicial en aldea")
	jugador.position = escena.get_node("Region/EntradaBosque").global_position+Vector3.UP*0.05
	jugador.velocity = Vector3.ZERO
	escena.get_node("CamaraPrincipal").centro_seguimiento = jugador.position
	await esperar(10)
	await captura("01_salida_aldea")
	# Errores deliberados deben conservar escena y controles, sin pantalla bloqueada.
	for par in [["res://scenes/no_existe_region.tscn","entrada"],["res://scenes/mundo_bosque.tscn","entrada_inexistente"],["res://scenes/jugador.tscn","entrada"]]:
		comprobar(gestor.solicitar(par[0],par[1]),"Solicitud de control negativo aceptada para validar")
		for fotograma in 300:
			await process_frame
			if not gestor.en_transicion:
				break
		comprobar(not gestor.en_transicion,"Error libera gestor")
		comprobar(current_scene==escena and jugador.is_physics_processing(),"Error conserva origen y control")
	for ciclo in 5:
		await caminar_salida(&"Bosque")
		if gestor.region_actual!=&"Bosque":
			break
		if ciclo==0:
			await captura("03_entrada_bosque")
			var p := current_scene.get_node("Jugador")
			var antes: Vector3 = p.position
			Input.action_press("mover_arriba")
			await esperar(25)
			Input.action_release("mover_arriba")
			await esperar(40)
			comprobar(p.position.distance_to(antes)>1,"Movimiento en bosque")
			var camara := current_scene.get_node("CamaraPrincipal")
			var angulo: float = camara.angulo_horizontal
			Input.action_press("girar_camara_derecha")
			await esperar(30)
			Input.action_release("girar_camara_derecha")
			comprobar(absf(camara.angulo_horizontal-angulo)>0.1,"Orbita por entrada real")
		await caminar_salida(&"Aldea")
		if gestor.region_actual!=&"Aldea":
			break
		if ciclo==0:
			await captura("04_retorno_aldea")
	comprobar(viajes==10,"Cinco viajes completos de ida y vuelta")
	comprobar(negros==12,"Diez fundidos de viaje y dos recuperaciones de error")
	var html := "<!doctype html><meta charset='utf-8'><title>Transiciones 6B</title><style>body{background:#17221e;color:#eee;font:18px sans-serif}img{max-width:100%}</style><h1>Aldea ↔ Bosque</h1>"
	for nombre in capturas:
		html += "<h2>"+nombre+"</h2><img src='"+nombre+".png'>"
	FileAccess.open(carpeta+"/galeria.html",FileAccess.WRITE).store_string(html)
	print("RESULTADO_TRANSICIONES: ",fallos," fallos / ",muestras," comprobaciones; ",viajes," trayectos. Evidencias: ",carpeta)
	quit(0 if fallos==0 else 1)
