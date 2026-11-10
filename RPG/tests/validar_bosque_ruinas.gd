extends "res://tests/validar_transiciones.gd"
## Cinco circuitos D y secuencia C con movimiento real por P01/P03.
var completados := 0
var ids_entrada: Array[String] = []
var regiones_orbita: Array[StringName] = []

func liberar() -> void:
	for a in ["mover_arriba","mover_abajo","mover_izquierda","mover_derecha","girar_camara_derecha"]:
		Input.action_release(a)

func orientar_entrada(d: Vector2) -> void:
	Input.action_press("mover_derecha",maxf(d.x,0))
	Input.action_press("mover_izquierda",maxf(-d.x,0))
	Input.action_press("mover_abajo",maxf(d.y,0))
	Input.action_press("mover_arriba",maxf(-d.y,0))

func eje(nombre: String, invertir: bool) -> Array[Vector2]:
	var puntos: PackedVector2Array = current_scene.get_node("Bosque/Caminos/"+nombre).get_meta("eje")
	if invertir:
		puntos.reverse()
	var salida: Array[Vector2] = []
	for p in puntos:
		salida.append(p)
	return salida

func desde_cerca(puntos: Array[Vector2]) -> Array[Vector2]:
	var p: Vector3 = current_scene.get_node("Jugador").position
	var mejor := 0
	for i in puntos.size():
		if Vector2(p.x,p.z).distance_squared_to(puntos[i])<Vector2(p.x,p.z).distance_squared_to(puntos[mejor]):
			mejor = i
	return puntos.slice(mejor)

func seguir(puntos: Array[Vector2], transicion: bool) -> bool:
	var jugador: CharacterBody3D = current_scene.get_node("Jugador")
	var indice := 0
	for paso in 8000:
		if gestor.en_transicion:
			liberar()
			return transicion
		var p := Vector2(jugador.position.x,jugador.position.z)
		while indice<puntos.size() and p.distance_to(puntos[indice])<0.65:
			indice += 1
		if indice==puntos.size():
			break
		orientar_entrada((puntos[indice]-p).normalized())
		await physics_frame
	liberar()
	if transicion:
		# Unos frames adicionales sincronizan el último solapamiento físico.
		await esperar(3)
		return gestor.en_transicion
	return indice==puntos.size()

func revisar_llegada(id: StringName, entrada_id: String) -> void:
	comprobar(gestor.region_actual==id,"Region esperada "+id)
	if gestor.region_actual!=id:
		return
	var config := current_scene.get_node("Region")
	var marcador: Marker3D = config.obtener_entrada(entrada_id)
	var jugador: CharacterBody3D = current_scene.get_node("Jugador")
	var camara := current_scene.get_node("CamaraPrincipal")
	comprobar(marcador!=null,"Entrada "+entrada_id)
	comprobar(jugador.position.distance_to(marcador.global_position)<0.35,"Aparicion correcta "+entrada_id)
	comprobar(jugador.direccion_visual==StringName(marcador.get_meta("direccion_visual","arriba")),"Orientacion al interior")
	comprobar(jugador.is_physics_processing() and camara.is_processing(),"Controles restaurados")
	comprobar(jugador.velocidad==10 and camara.size==15,"Velocidad y tamaño conservados")
	var protagonistas := 0
	var orbitales := 0
	var activas := 0
	for n in root.find_children("*","CharacterBody3D",true,false):
		if n.get_script()==load("res://scripts/jugador.gd"):
			protagonistas += 1
	for n in root.find_children("*","Camera3D",true,false):
		if n.get_script()==load("res://scripts/camara_orbital.gd"):
			orbitales += 1
		if n.current:
			activas += 1
	comprobar(protagonistas==1 and orbitales==1 and activas==1,"Jugador y camara unicos")
	var areas := current_scene.find_children("*","Area3D",true,false)
	comprobar(areas.size()==(3 if id==&"Aldea" else (2 if id==&"Bosque" else 1)),"Solo conexiones autorizadas, incluida salida este 6F")
	if id==&"Aldea":
		comprobar(current_scene.has_node("Region/SalidaCampos") and current_scene.has_node("Region/SalidaBosque"),"Dos salidas independientes de aldea")
	for area in areas:
		comprobar(not area.overlaps_body(jugador),"Aparicion fuera de todas las salidas")
	comprobar(gestor.negro.color.a<0.001,"Fundido transparente al llegar")
	await esperar(45)
	comprobar(not gestor.en_transicion and gestor.region_actual==id,"Sin bucle en reposo")
	ids_entrada.append(entrada_id)
	# Movimiento real al interior y órbita por Input, sin cambiar scripts.
	var antes := jugador.position
	Input.action_press("mover_abajo" if marcador.get_meta("direccion_visual","arriba")=="abajo" else "mover_arriba")
	await esperar(15)
	liberar()
	await esperar(25)
	comprobar(jugador.position.distance_to(antes)>0.5,"Movimiento recuperado")
	var angulo: float = camara.angulo_horizontal
	var recorrido := 0.0
	var vuelta_completa := not regiones_orbita.has(id)
	Input.action_press("girar_camara_derecha")
	for i in (310 if vuelta_completa else 15):
		await process_frame
		var actual: float = camara.angulo_horizontal
		recorrido += absf(wrapf(actual-angulo,-PI,PI))
		angulo = actual
	liberar()
	comprobar(recorrido>(TAU if vuelta_completa else 0.1),"Orbita por entrada real, acumulada sin perder vuelta en +/-PI")
	if vuelta_completa:
		regiones_orbita.append(id)
	camara.angulo_horizontal = 0
	camara.actualizar_orbita()

func viajar(destino: StringName) -> bool:
	var origen: StringName = gestor.region_actual
	var ruta: Array[Vector2] = []
	var entrada_id := ""
	if origen==&"Aldea":
		ruta = [Vector2(0,-35.5)]
		entrada_id = "bosque_aldea_sur"
	elif origen==&"Ruinas":
		ruta = [Vector2(0,37)]
		entrada_id = "bosque_ruinas_norte"
	elif destino==&"Ruinas":
		if current_scene.get_node("Jugador").position.z>0:
			ruta = desde_cerca(eje("P01",false))
			ruta.append_array(eje("P03",false))
		else:
			ruta = desde_cerca(eje("P03",false))
		entrada_id = "ruinas_bosque_sur"
	else:
		ruta = desde_cerca(eje("P03",true))
		ruta.append_array(eje("P01",true))
		entrada_id = "aldea_bosque_norte"
	var activada: bool = await seguir(ruta,true)
	comprobar(activada,"Detector activado caminando %s -> %s"%[origen,destino])
	if not activada:
		print("POSICION_BLOQUEO ",current_scene.get_node("Jugador").position)
		return false
	comprobar(not gestor.solicitar("res://scenes/mundo.tscn","aldea_bosque_norte"),"Solicitud simultanea rechazada")
	var intermedio := false
	for i in 900:
		await process_frame
		if gestor.negro.color.a>0.05 and gestor.negro.color.a<0.95:
			intermedio = true
		if not gestor.en_transicion:
			break
	comprobar(intermedio,"Fundido gradual")
	comprobar(not gestor.en_transicion,"Cambio terminado")
	await esperar(3)
	await revisar_llegada(destino,entrada_id)
	viajes += 1
	print("6D TRAYECTO ",viajes," ",origen," -> ",gestor.region_actual," entrada=",entrada_id)
	return gestor.region_actual==destino

func capturar_accesos() -> void:
	if DisplayServer.get_name()=="headless":
		return
	var camara := current_scene.get_node("CamaraPrincipal")
	if gestor.region_actual==&"Bosque":
		if ids_entrada.back()=="bosque_ruinas_norte":
			await captura("04_retorno_bosque_desde_ruinas")
			return
		# La cámara temporal solo encuadra evidencia; el jugador no se teletransporta.
		var temporal := Camera3D.new()
		current_scene.add_child(temporal)
		temporal.projection = Camera3D.PROJECTION_ORTHOGONAL
		temporal.size = 20
		temporal.position = Vector3(21,15,-21)
		temporal.look_at(Vector3(21,1.5,-43))
		temporal.make_current()
		await esperar(4)
		await captura("01_acceso_bosque_ruinas")
		temporal.queue_free()
		camara.make_current()
	elif gestor.region_actual==&"Ruinas":
		await captura("02_llegada_ruinas")
		camara.angulo_horizontal = PI
		camara.actualizar_orbita()
		await esperar(4)
		await captura("03_regreso_ruinas_bosque")
		camara.angulo_horizontal = 0
		camara.actualizar_orbita()

func validar() -> void:
	carpeta = "res://logs/fase6d_bosque_ruinas/"+Time.get_datetime_string_from_system().replace(":","-")+"_"+str(Time.get_ticks_msec())
	if "--fase6e" in OS.get_cmdline_user_args():
		carpeta = carpeta.replace("fase6d_bosque_ruinas","fase6e_campos_granjas/bosque_ruinas")
	DirAccess.make_dir_recursive_absolute(carpeta)
	root.size = Vector2i(1280,800)
	gestor = root.get_node("GestorRegiones")
	gestor.pantalla_negra.connect(negro)
	comprobar(gestor.DURACION==0.35,"Fundido 0.35 s conservado")
	var inicial: Node3D = load("res://scenes/mundo.tscn").instantiate()
	root.add_child(inicial)
	current_scene = inicial
	await esperar(10)
	# Preparación inicial única junto a la salida; después todos los trayectos se caminan.
	current_scene.get_node("Jugador").position = current_scene.get_node("Region/EntradaBosque").global_position+Vector3.UP*0.05
	await esperar(5)
	for ciclo in 5:
		var ok := true
		for destino in [&"Bosque",&"Ruinas",&"Bosque",&"Aldea"]:
			if not await viajar(destino):
				ok = false
				break
			if ciclo==0 and destino in [&"Bosque",&"Ruinas"]:
				await capturar_accesos()
		if not ok:
			break
		completados += 1
	comprobar(completados==5,"Cinco circuitos D completos")
	if completados==5:
		for destino in [&"Bosque",&"Ruinas",&"Bosque",&"Ruinas",&"Bosque",&"Aldea"]:
			if not await viajar(destino):
				break
	comprobar(viajes==26,"A/B/C y cinco circuitos D: 26 cambios")
	comprobar(negros==viajes,"Un negro completo por cambio")
	comprobar(ids_entrada.has("bosque_aldea_sur") and ids_entrada.has("bosque_ruinas_norte"),"Dos entradas independientes al bosque")
	var html := "<!doctype html><meta charset='utf-8'><title>Conexión Bosque · Ruinas</title><style>body{background:#18211b;color:white;font:18px sans-serif;margin:32px}img{max-width:100%}</style><h1>Accesos y transiciones 6D</h1>"
	for nombre in capturas:
		html += "<h2>"+nombre+"</h2><img src='"+nombre+".png'>"
	FileAccess.open(carpeta+"/galeria.html",FileAccess.WRITE).store_string(html)
	print("RESULTADO_6D: %d fallos / %d comprobaciones; %d circuitos D; %d cambios. %s"%[fallos,muestras,completados,viajes,carpeta])
	quit(1 if fallos else 0)
