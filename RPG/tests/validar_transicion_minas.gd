extends "res://tests/validar_transicion_montanas.gd"
## Cinco circuitos por detectores reales y cadena completa desde/hasta Aldea.

func viajar_mina(destino: StringName) -> bool:
	var origen: StringName = gestor.region_actual
	var puntos: Array[Vector2] = []
	puntos.append(Vector2(45,-22) if origen==&"Montanas" else Vector2(0,9))
	comprobar(await seguir(puntos,true),"Detector caminando "+origen+" -> "+destino)
	if not gestor.en_transicion: return false
	comprobar(not gestor.solicitar("res://scenes/mundo_minas.tscn","minas_montanas_sur"),"Solicitud simultanea bloqueada")
	var parcial := false
	for i in 900:
		await process_frame
		parcial = parcial or (gestor.negro.color.a>.05 and gestor.negro.color.a<.95)
		if not gestor.en_transicion: break
	await esperar(20)
	comprobar(parcial and not gestor.en_transicion,"Fundido gradual .35 s completo")
	comprobar(gestor.region_actual==destino,"Region destino "+destino)
	if gestor.region_actual!=destino: return false
	var entrada_id := "minas_montanas_sur" if destino==&"Minas" else "montanas_minas_norte"
	var j: CharacterBody3D = current_scene.get_node("Jugador")
	var camara := current_scene.get_node("CamaraPrincipal")
	var marcador: Marker3D = current_scene.get_node("Region").obtener_entrada(entrada_id)
	comprobar(j.position.distance_to(marcador.global_position)<.35 and j.is_on_floor(),"Aparicion segura sobre suelo")
	comprobar(j.is_physics_processing() and camara.is_processing(),"Control y camara restaurados")
	comprobar(root.find_children("*","CharacterBody3D",true,false).size()==1,"Un jugador")
	comprobar(root.find_children("*","Camera3D",true,false).size()==1,"Una camara")
	for area in current_scene.find_children("*","Area3D",true,false): comprobar(not area.overlaps_body(j),"Aparicion fuera del detector")
	await esperar(60)
	comprobar(not gestor.en_transicion and gestor.region_actual==destino,"Sin bucle en reposo")
	var angulo: float = camara.angulo_horizontal
	Input.action_press("girar_camara_derecha")
	await esperar(20)
	liberar()
	comprobar(absf(camara.angulo_horizontal-angulo)>.1,"Orbita restaurada por Input")
	camara.angulo_horizontal = 0
	camara.actualizar_orbita()
	viajes += 1
	await captura(str(viajes)+"_"+destino)
	return true

func validar() -> void:
	carpeta = "res://logs/fase_minas/transiciones_"+Time.get_datetime_string_from_system().replace(":","-")+"_"+str(Time.get_ticks_msec())
	DirAccess.make_dir_recursive_absolute(carpeta)
	root.size = Vector2i(1280,800)
	gestor = root.get_node("GestorRegiones")
	gestor.pantalla_negra.connect(negro)
	var inicial: Node3D = load("res://scenes/mundo.tscn").instantiate()
	root.add_child(inicial)
	current_scene = inicial
	await esperar(20)
	if not await viajar(&"Montanas"):
		quit(1)
		return
	var ruta: Array[Vector2] = [Vector2(-34,42),Vector2(-22,30),Vector2(16,30),Vector2(28,22),Vector2(42,18),Vector2(48,-4),Vector2(54,-18),Vector2(45,-18)]
	comprobar(await seguir(ruta,false),"Aproximacion exterior desde llegada Aldea por senderos existentes")
	var ciclos := 0
	for i in 5:
		if not await viajar_mina(&"Minas"): break
		# Caminar al interior y volver por el túnel: control real tras cada carga.
		comprobar(await seguir([Vector2(0,-5)],false),"Movimiento interior tras aparecer")
		if not await viajar_mina(&"Montanas"): break
		ciclos += 1
	comprobar(ciclos==5,"Cinco viajes de ida y vuelta")
	var vuelta: Array[Vector2] = [Vector2(54,-18),Vector2(48,-4),Vector2(42,18),Vector2(28,22),Vector2(16,30),Vector2(-22,30),Vector2(-34,42),Vector2(-52,48)]
	comprobar(await seguir(vuelta,false),"Regreso por senderos y puente exterior")
	comprobar(await viajar(&"Aldea"),"Cadena Aldea Montanas Minas Montanas Aldea")
	comprobar(viajes==12 and negros==12,"Doce cambios y doce negros sin duplicados")
	var html := "<!doctype html><meta charset='utf-8'><title>Minas · transiciones</title><style>body{background:#171e23;color:white;font:18px sans-serif}img{max-width:100%}</style><h1>Cinco circuitos Montañas ↔ Minas y conexión Aldea</h1>"
	for n in capturas: html += "<h2>"+n+"</h2><img loading='lazy' src='"+n+".png'>"
	FileAccess.open(carpeta+"/galeria.html",FileAccess.WRITE).store_string(html)
	print("MINAS_TRANSICIONES: ",fallos," fallos / ",muestras," comprobaciones; ciclos=",ciclos," viajes=",viajes," negros=",negros," carpeta=",carpeta)
	quit(1 if fallos else 0)
