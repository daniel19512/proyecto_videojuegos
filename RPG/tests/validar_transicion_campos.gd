extends "res://tests/validar_bosque_ruinas.gd"
## Cinco ida/vuelta mas cadena completa con las cuatro regiones. Input y areas reales.
var ciclos_campos := 0

func viajar(destino: StringName) -> bool:
	var origen: StringName = gestor.region_actual
	if origen==&"Aldea" and destino==&"Bosque":
		# Rodear el pozo de plaza por el corredor real, sin teletransportar.
		var p: Vector3 = current_scene.get_node("Jugador").position
		if p.z> -13:
			var ruta: Array[Vector2] = [Vector2(0,13),Vector2(3.5,5),Vector2(3.5,-10),Vector2(0,-13),Vector2(0,-32)]
			comprobar(await seguir(ruta,false),"Al sur -> salida bosque por plaza")
		return await super.viajar(destino)
	if origen!=&"CamposYGranjas" and destino!=&"CamposYGranjas": return await super.viajar(destino)
	var puntos: Array[Vector2] = []
	var entrada_id := "campos_aldea_norte" if destino==&"CamposYGranjas" else "aldea_campos_sur"
	if origen==&"Aldea":
		var p: Vector3 = current_scene.get_node("Jugador").position
		if p.z< -10: puntos = [Vector2(0,-13),Vector2(3.5,-10),Vector2(3.5,5),Vector2(0,13)]
		puntos.append(Vector2(0,35.5))
	else:
		puntos = [Vector2(0,-43)]
	comprobar(await seguir(puntos,true),"Area activa caminando %s -> %s"%[origen,destino])
	if not gestor.en_transicion: return false
	comprobar(not gestor.solicitar("res://scenes/mundo.tscn","aldea_campos_sur"),"Bloqueo simultaneo")
	var parcial := false
	for i in 900:
		await process_frame
		parcial = parcial or (gestor.negro.color.a>.05 and gestor.negro.color.a<.95)
		if not gestor.en_transicion: break
	comprobar(parcial and not gestor.en_transicion,"Fundido gradual completo")
	await esperar(3)
	await revisar_llegada(destino,entrada_id)
	viajes += 1
	print("6E VIAJE ",viajes," ",origen," -> ",destino," entrada=",entrada_id)
	return gestor.region_actual==destino

func validar() -> void:
	carpeta = "res://logs/fase6e_campos_granjas/transiciones_"+Time.get_datetime_string_from_system().replace(":","-")+"_"+str(Time.get_ticks_msec())
	DirAccess.make_dir_recursive_absolute(carpeta)
	root.size = Vector2i(1440,900)
	gestor = root.get_node("GestorRegiones")
	gestor.pantalla_negra.connect(negro)
	comprobar(gestor.DURACION==.35,"Gestor y fundido existentes .35 s")
	var inicial: Node3D = load("res://scenes/mundo.tscn").instantiate()
	root.add_child(inicial)
	current_scene = inicial
	await esperar(10)
	for i in 5:
		if not await viajar(&"CamposYGranjas"): break
		if i==0: await captura("01_llegada_campos")
		if not await viajar(&"Aldea"): break
		if i==0: await captura("03_regreso_aldea_sur")
		ciclos_campos += 1
	comprobar(ciclos_campos==5,"Cinco circuitos Aldea Granja Aldea sin teletransporte")
	if ciclos_campos==5:
		for destino in [&"Bosque",&"Ruinas",&"Bosque",&"Aldea",&"CamposYGranjas",&"Aldea"]:
			if not await viajar(destino): break
			await captura("cadena_"+str(viajes)+"_"+destino)
	comprobar(viajes==16 and negros==16,"Cadena completa y 16 cambios con negro, sin duplicados")
	comprobar(ids_entrada.has("aldea_campos_sur") and ids_entrada.has("aldea_bosque_norte"),"Entradas de aldea independientes")
	comprobar(regiones_orbita.size()==4,"Orbita 360 real en las cuatro regiones")
	var html := "<!doctype html><meta charset='utf-8'><title>Transicion Campos 6E</title><style>body{background:#232b20;color:white;font:18px sans-serif;margin:30px}img{max-width:100%}</style><h1>Aldea · Campos y Granjas</h1>"
	for n in capturas: html += "<h2>"+n+"</h2><img src='"+n+".png'>"
	FileAccess.open(carpeta+"/galeria.html",FileAccess.WRITE).store_string(html)
	print("6E_TRANSICIONES: %d fallos / %d comprobaciones; ciclos=%d viajes=%d; %s"%[fallos,muestras,ciclos_campos,viajes,carpeta])
	quit(1 if fallos else 0)
