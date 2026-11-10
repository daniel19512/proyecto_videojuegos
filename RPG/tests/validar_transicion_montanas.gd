extends "res://tests/validar_transicion_campos.gd"
## Cinco circuitos orientales y regresión caminada de las conexiones anteriores.
var ciclos_montanas := 0

func viajar(destino: StringName) -> bool:
	var origen: StringName = gestor.region_actual
	if origen!=&"Montanas" and destino!=&"Montanas": return await super.viajar(destino)
	var puntos: Array[Vector2] = []
	if origen==&"Aldea":
		var p: Vector3 = current_scene.get_node("Jugador").position
		if p.x<25:
			puntos = [Vector2(3.5,p.z),Vector2(3.5,10),Vector2(14,10),Vector2(14,0),Vector2(22,0),Vector2(30,0),Vector2(36,0)]
		puntos.append(Vector2(39.5,0))
	else:
		puntos = [Vector2(-62,48)]
	var entrada_id := "camino_montanas_aldea_oeste" if destino==&"Montanas" else "aldea_camino_este"
	var cruzo := await seguir(puntos,true)
	if not cruzo: print("RECORRIDO REGIONAL BLOQUEADO: ",current_scene.get_node("Jugador").position," ruta=",puntos)
	comprobar(cruzo,"Detector real caminando "+origen+" -> "+destino)
	if not gestor.en_transicion: return false
	comprobar(not gestor.solicitar("res://scenes/mundo.tscn","aldea_camino_este"),"Solicitud simultánea rechazada")
	var parcial := false
	for i in 900:
		await process_frame
		parcial = parcial or (gestor.negro.color.a>.05 and gestor.negro.color.a<.95)
		if not gestor.en_transicion: break
	comprobar(parcial and not gestor.en_transicion,"Fundido gradual de ida/vuelta")
	await esperar(3)
	# Comprobaciones locales para entradas este/oeste, sin asumir orientación norte/sur.
	comprobar(gestor.region_actual==destino,"Destino "+destino)
	var j: CharacterBody3D = current_scene.get_node("Jugador")
	var config := current_scene.get_node("Region")
	var marcador: Marker3D = config.obtener_entrada(entrada_id)
	comprobar(j.position.distance_to(marcador.global_position)<.3,"Aparición segura específica")
	comprobar(j.direccion_visual==StringName(marcador.get_meta("direccion_visual")),"Orientación al interior")
	comprobar(j.is_physics_processing() and current_scene.get_node("CamaraPrincipal").is_processing(),"Control y cámara restaurados")
	comprobar(root.find_children("*","CharacterBody3D",true,false).size()==1,"Un protagonista")
	for area in current_scene.find_children("*","Area3D",true,false):
		comprobar(not area.overlaps_body(j),"Aparición fuera de detectores")
	await esperar(45)
	comprobar(not gestor.en_transicion,"Reposo sin bucle")
	viajes += 1
	await captura(str(viajes)+"_"+destino)
	return gestor.region_actual==destino

func validar() -> void:
	carpeta = "res://logs/fase6f_montanas/transiciones_"+Time.get_datetime_string_from_system().replace(":","-")+"_"+str(Time.get_ticks_msec())
	if "--fase-minas" in OS.get_cmdline_user_args(): carpeta = carpeta.replace("fase6f_montanas/transiciones_","fase_minas/regresion_transiciones_")
	DirAccess.make_dir_recursive_absolute(carpeta)
	gestor = root.get_node("GestorRegiones")
	gestor.pantalla_negra.connect(negro)
	var inicial: Node3D = load("res://scenes/mundo.tscn").instantiate()
	root.add_child(inicial)
	current_scene = inicial
	await esperar(10)
	for i in 5:
		if not await viajar(&"Montanas"): break
		if not await viajar(&"Aldea"): break
		ciclos_montanas += 1
	comprobar(ciclos_montanas==5,"Cinco circuitos Aldea Montañas Aldea")
	if ciclos_montanas==5:
		comprobar(await seguir([Vector2(36,0),Vector2(22,0),Vector2(14,0),Vector2(14,10),Vector2(3.5,10),Vector2(3.5,-10),Vector2(0,-13),Vector2(0,-32)],false),"Vuelta sobre puente original hacia salida norte")
		for destino in [&"Bosque",&"Ruinas",&"Bosque",&"Aldea",&"CamposYGranjas",&"Aldea"]:
			if not await viajar(destino): break
	comprobar(viajes==16 and negros==16,"Dieciséis transiciones con negro y regresión de las cuatro conexiones")
	var html := "<!doctype html><meta charset='utf-8'><title>Transiciones 6F</title><style>body{background:#20292b;color:white;font:18px sans-serif}img{max-width:100%}</style><h1>Aldea ↔ Montañas</h1>"
	for n in capturas: html += "<h2>"+n+"</h2><img src='"+n+".png'>"
	FileAccess.open(carpeta+"/galeria.html",FileAccess.WRITE).store_string(html)
	print("6F_TRANSICIONES: ",fallos," fallos / ",muestras," comprobaciones; ciclos=",ciclos_montanas," viajes=",viajes," negros=",negros)
	quit(1 if fallos else 0)
