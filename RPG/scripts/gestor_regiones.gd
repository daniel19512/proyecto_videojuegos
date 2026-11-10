extends Node
## Autoload: intercambio transaccional de escenas, sin coordenadas regionales.
signal finalizada(region: StringName)
signal rechazada(motivo: String)
signal pantalla_negra
var en_transicion := false
var region_actual: StringName:
	get:
		var escena := get_tree().current_scene
		return escena.get_meta("id_region",&"") if is_instance_valid(escena) else &""
var capa: CanvasLayer
var negro: ColorRect
const DURACION := 0.35

func _ready() -> void:
	capa = CanvasLayer.new()
	capa.layer = 100
	add_child(capa)
	negro = ColorRect.new()
	negro.color = Color(0,0,0,0)
	negro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	negro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	capa.add_child(negro)

func solicitar(ruta: String, entrada: String) -> bool:
	if en_transicion:
		return false
	en_transicion = true
	_ejecutar.call_deferred(ruta,entrada)
	return true

func _rechazar(motivo: String, candidato: Node = null) -> void:
	if is_instance_valid(candidato):
		candidato.free()
	en_transicion = false
	push_warning("Transicion rechazada: "+motivo)
	rechazada.emit(motivo)

func _fundir(alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(negro,"color:a",alpha,DURACION)
	await tween.finished

func _ejecutar(ruta: String, entrada: String) -> void:
	var anterior := get_tree().current_scene
	if not is_instance_valid(anterior) or not anterior.has_node("Region"):
		_rechazar("La escena actual no tiene configuracion regional")
		return
	if not ResourceLoader.exists(ruta,"PackedScene"):
		_rechazar("No existe la escena "+ruta)
		return
	var origen := anterior.get_node("Region")
	var jugador := origen.get_node_or_null(origen.jugador) as CharacterBody3D
	var camara := origen.get_node_or_null(origen.camara) as Camera3D
	if jugador==null or camara==null:
		_rechazar("Origen sin jugador o camara")
		return
	var fisica_previa := jugador.is_physics_processing()
	var camara_previa := camara.is_processing()
	jugador.set_physics_process(false)
	jugador.velocity = Vector3.ZERO
	camara.set_process(false)
	await _fundir(1.0)
	pantalla_negra.emit()
	var recurso := ResourceLoader.load(ruta) as PackedScene
	if recurso==null or not recurso.can_instantiate():
		await _recuperar(jugador,camara,fisica_previa,camara_previa,"No se pudo cargar "+ruta)
		return
	var candidato := recurso.instantiate()
	var config := candidato.get_node_or_null("Region")
	if config==null or config.obtener_entrada(entrada)==null:
		await _recuperar(jugador,camara,fisica_previa,camara_previa,"Entrada inexistente: "+entrada,candidato)
		return
	var nuevo_jugador := config.get_node_or_null(config.jugador) as CharacterBody3D
	var nueva_camara := config.get_node_or_null(config.camara) as Camera3D
	if nuevo_jugador==null or nueva_camara==null or config.id_region==&"":
		await _recuperar(jugador,camara,fisica_previa,camara_previa,"Configuracion regional incompleta: "+ruta,candidato)
		return
	# El candidato ya fue validado; el origen se conserva hasta completar el cambio.
	get_tree().root.remove_child(anterior)
	get_tree().root.add_child(candidato)
	get_tree().current_scene = candidato
	var marcador: Marker3D = config.obtener_entrada(entrada)
	nuevo_jugador.set_physics_process(false)
	nueva_camara.set_process(false)
	nuevo_jugador.global_position = marcador.global_position+Vector3.UP*0.05
	nuevo_jugador.velocity = Vector3.ZERO
	# El controlador ya admite direccion_visual; no rotar el cuerpo físico.
	nuevo_jugador.direccion_visual = StringName(marcador.get_meta("direccion_visual","arriba"))
	nuevo_jugador.en_movimiento = false
	nuevo_jugador._actualizar_animacion()
	nueva_camara.centro_seguimiento = nuevo_jugador.global_position
	nueva_camara.angulo_horizontal = 0.0
	nueva_camara.actualizar_orbita()
	nueva_camara.make_current()
	anterior.queue_free()
	# Espera sincronización real de física, sin retrasos arbitrarios de inicialización.
	await get_tree().physics_frame
	await _fundir(0.0)
	nuevo_jugador.set_physics_process(fisica_previa)
	nueva_camara.set_process(camara_previa)
	en_transicion = false
	print("REGION_ACTUAL: ",region_actual," entrada=",entrada)
	finalizada.emit(region_actual)

func _recuperar(jugador: CharacterBody3D, camara: Camera3D, fisica: bool, proceso: bool, motivo: String, candidato: Node = null) -> void:
	await _fundir(0.0)
	jugador.set_physics_process(fisica)
	camara.set_process(proceso)
	_rechazar(motivo,candidato)