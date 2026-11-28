extends Node

const RAIZ := "res://assets/audio/"
const FANTASIA := "interfaz/fantasia/"
const MUSICA := {
	"menu": ["maxstack/Gentle_Breeze.ogg"],
	"intro": ["alkakrab/1. Moonspire.ogg"],
	"Aldea": ["alkakrab/6. Silverbrook .ogg", "maxstack/Gentle_Breeze.ogg"],
	"Bosque": ["alkakrab/7. Mystic Grove .ogg", "alkakrab/10. Elven Dawn  .ogg"],
	"CamposYGranjas": ["maxstack/Gentle_Breeze.ogg", "alkakrab/6. Silverbrook .ogg"],
	"Montanas": ["alkakrab/4. Frostbound.ogg", "alkakrab/2. Winds of Valor.ogg"],
	"Minas": ["alkakrab/3. Darkwood Path.ogg", "alkakrab/8. Throne of Storms .ogg"],
	"Ruinas": ["alkakrab/9. Sorrow’s Edge  .ogg", "alkakrab/1. Moonspire.ogg"],
	"taberna": ["alkakrab/5. Emberlight .ogg", "maxstack/Gentle_Breeze.ogg"],
	"noche": ["alkakrab/1. Moonspire.ogg", "alkakrab/5. Emberlight .ogg"],
	"feria": ["alkakrab/10. Elven Dawn  .ogg"],
}
const VIENTO := "530908__nox_sound__ambiance_wind_forest_trees_loop_01.wav"
const AMBIENTES := {
	"Aldea": VIENTO,
	"Bosque": VIENTO,
	"CamposYGranjas": VIENTO,
	"Montanas": VIENTO,
	"Minas": "240607__lebaston100__water-dripping-in-cave.wav",
	"Ruinas": VIENTO,
	"noche": "446076__reklamacja__night-crickets-and-dogs.wav",
	"taberna": "695295__brunoboselli__pirate-tavern.wav",
	"herrería": "254370__emmaproductions__by-ther-blacksmith-002.wav",
	"carpintería": "60180__benboncan__coping-saw.wav",
	"molino": "164182__bmoreno__0359-water_mill.wav",
	"hogar": "874065__heyheytheree__fireplace-loop-weather-nature-sfx-free.wav",
}
const AVES := "723913__magnesus__forest-birds-ambient-seamless-loop.wav"
# Volumen y pausa aleatoria entre fragmentos diurnos por región.
const PRESENCIA_AVES := {
	"Bosque": Vector3(-16, 8, 18),
	"CamposYGranjas": Vector3(-23, 22, 45),
	"Aldea": Vector3(-29, 38, 75),
	"Ruinas": Vector3(-30, 40, 80),
	"Montanas": Vector3(-35, 70, 120),
}
const RIO := "548373__nox_sound__ambiance_stream_calm_loop_stereo.wav"
const EFECTOS := {
	"puerta": "efectos/15419__pagancow__dorm-door-opening.wav",
	"cofre": "efectos/771164__steprock__treasure-chest-open.mp3",
	"cosecha": "ambiente/872487__heyheytheree__harvest-cozy-game-sfx-free.wav",
	"monedas": "ambiente/350876__cabled_mess__coin_c_09.wav",
	"extraer": "efectos/184383__qubodup__gathering-stone-resources.wav",
}
const UI := {
	"navegar": "menu-hover-tick-3.wav", "confirmar": "ring-equip.wav",
	"salir": "compass-turn-2.wav", "error": "invalid-rattle.wav",
	"abrir": "parchment-unroll-2.wav", "aviso": "raven-wing-flap-2.wav",
}

var _musica: AudioStreamPlayer
var _ambiente: AudioStreamPlayer
var _aves: AudioStreamPlayer
var _region_aves := ""
var _espera_aves := 0.0
var _duracion_aves := 0.0
var _rio: AudioStreamPlayer3D
var _efecto: AudioStreamPlayer
var _interfaz: AudioStreamPlayer
var _region := ""
var _ultima_pista := ""
var _ruta_ambiente := ""
var _espera := 0.0
var _fundidos: Dictionary = {}
var _ultimo_toque := 0
var _navegacion := 0

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	set_process(false)
	if get_tree().get_script() == null and DisplayServer.get_name() != "headless":
		activar()

func salir_del_juego() -> void:
	set_process(false)
	_detener()
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().quit()

func _exit_tree() -> void:
	_detener()

func _detener() -> void:
	for tween in _fundidos.values():
		tween.kill()
	_fundidos.clear()
	for player in [_musica, _ambiente, _aves, _rio, _efecto, _interfaz]:
		if is_instance_valid(player):
			player.stop()
			player.stream = null

func activar() -> void:
	if _musica:
		return
	_musica = _canal("Música")
	_ambiente = _canal("Ambiente")
	_aves = _canal("Ambiente")
	_efecto = _canal("Efectos")
	_interfaz = _canal("Interfaz")
	_rio = AudioStreamPlayer3D.new()
	_rio.bus = "Ambiente"
	_rio.unit_size = 6.0
	_rio.max_distance = 24.0
	add_child(_rio)
	_musica.finished.connect(func(): _espera = randf_range(30.0, 90.0))
	EstadoMundo.actividad_registrada.connect(_actividad)
	for boton in get_tree().root.find_children("*", "BaseButton", true, false):
		_observar_boton(boton)
	get_tree().node_added.connect(_observar_boton)
	set_process(true)

func _actividad(tipo: String, _id: String) -> void:
	if tipo in ["cosechar", "extraer", "comercio"]:
		efecto({"cosechar": "cosecha", "comercio": "monedas"}.get(tipo, tipo))

func _canal(bus: String) -> AudioStreamPlayer:
	var reproductor := AudioStreamPlayer.new()
	reproductor.bus = bus
	add_child(reproductor)
	return reproductor

func _observar_boton(nodo: Node) -> void:
	if nodo is BaseButton:
		nodo.pressed.connect(sonido_interfaz.bind("confirmar"))
		nodo.focus_entered.connect(func():
			if Time.get_ticks_msec() - _navegacion < 120:
				_navegacion = 0
				sonido_interfaz("navegar"))

func _input(evento: InputEvent) -> void:
	if not _interfaz or not get_tree().paused:
		return
	if evento.is_action_pressed("ui_cancel"):
		sonido_interfaz("salir")
	elif evento.is_action_pressed("ui_up") or evento.is_action_pressed("ui_down") or evento.is_action_pressed("ui_left") or evento.is_action_pressed("ui_right"):
		_navegacion = Time.get_ticks_msec()

func sonido_interfaz(id: String) -> void:
	if not _interfaz or not UI.has(id) or Time.get_ticks_msec() - _ultimo_toque < 135:
		return
	_ultimo_toque = Time.get_ticks_msec()
	_reproducir(_interfaz, FANTASIA + UI[id], false, -16.0)

func efecto(id: String) -> void:
	if _efecto and EFECTOS.has(id):
		_reproducir(_efecto, EFECTOS[id], false, -10.0)

func _reproducir(player: Node, ruta: String, ciclo: bool, volumen: float) -> void:
	if not ResourceLoader.exists(RAIZ + ruta):
		return
	var fuente := load(RAIZ + ruta) as AudioStream
	if not fuente:
		return
	player.stream = fuente.duplicate()
	if player.stream is AudioStreamWAV:
		player.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if ciclo else AudioStreamWAV.LOOP_DISABLED
		if ciclo:
			player.stream.loop_end = int(player.stream.get_length() * player.stream.mix_rate)
	elif player.stream is AudioStreamOggVorbis or player.stream is AudioStreamMP3:
		player.stream.loop = ciclo
	player.volume_db = volumen
	player.play()

func _fundir(player: Node, ruta: String, ciclo: bool, volumen: float) -> void:
	if _fundidos.has(player):
		_fundidos[player].kill()
	var tween := create_tween()
	_fundidos[player] = tween
	if player.playing:
		tween.tween_property(player, "volume_db", -42.0, 0.45)
	tween.tween_callback(player.stop)
	if not ruta.is_empty():
		tween.tween_callback(_reproducir.bind(player, ruta, ciclo, -36.0))
		tween.tween_property(player, "volume_db", volumen, 0.8)
	tween.finished.connect(func(): _fundidos.erase(player))

func _pista(region: String) -> void:
	var opciones: Array = MUSICA[region].duplicate()
	if opciones.size() > 1:
		opciones.erase(_ultima_pista)
	_ultima_pista = opciones.pick_random()
	_fundir(_musica, "musica/" + _ultima_pista, region in ["menu", "intro", "feria"], -7.0)

func _process(delta: float) -> void:
	var region := String(GestorRegiones.region_actual)
	var actual := get_tree().current_scene
	if region.is_empty():
		if actual == null or not actual.has_method("confirmar_salida"):
			return
		region = "intro" if actual.en_intro else "menu"
	var ambiente := region
	var pista := region
	var noche := Reloj.franja() == 3
	match region:
		"TabernaE01":
			ambiente = "taberna"
			pista = "taberna"
		"InteriorE03", "InteriorE04":
			ambiente = "hogar"
			if not noche:
				ambiente = "herrería" if region == "InteriorE03" else "carpintería"
		"InteriorE12":
			ambiente = "molino" if not noche else "hogar"
		_:
			if region.begins_with("Interior"):
				ambiente = "hogar"
	if not MUSICA.has(pista):
		pista = "Aldea"
	if noche and region in ["Aldea", "Bosque", "CamposYGranjas", "Montanas", "Ruinas"]:
		pista = "noche"
		ambiente = "noche"
	if region == "Aldea" and Misiones.feria_en_curso():
		pista = "feria"
	if _region != pista:
		_region = pista
		_espera = 0.0
		_pista(pista)
	if not _musica.playing and not _fundidos.has(_musica):
		_espera -= delta
		if _espera <= 0.0:
			_pista(pista)
	var archivo: String = AMBIENTES.get(ambiente, "")
	if _ruta_ambiente != archivo:
		_ruta_ambiente = archivo
		_fundir(_ambiente, "" if archivo.is_empty() else "ambiente/" + archivo, true, -26.0 if archivo == VIENTO else -13.0)
	var jugador := actual.get_node_or_null("Jugador") as Node3D if is_instance_valid(actual) and region == "Aldea" else null
	_actualizar_rio(jugador)
	_actualizar_aves(region if not noche and not GestorRegiones.en_transicion else "", delta)

func _actualizar_aves(region: String, delta: float) -> void:
	var perfil: Vector3 = PRESENCIA_AVES.get(region, Vector3.ZERO)
	if region != _region_aves:
		_region_aves = region
		_fundir(_aves, "", false, 0.0)
		_espera_aves = randf_range(perfil.y, perfil.z)
		_duracion_aves = 0.0
	if perfil == Vector3.ZERO or _fundidos.has(_aves):
		return
	if _aves.playing:
		_duracion_aves -= delta
		if _duracion_aves <= 0.0:
			_fundir(_aves, "", false, 0.0)
		return
	_espera_aves -= delta
	if _espera_aves <= 0.0:
		_fundir(_aves, "ambiente/" + AVES, false, perfil.x)
		_duracion_aves = randf_range(5.0, 10.0)
		_espera_aves = randf_range(perfil.y, perfil.z)

func _actualizar_rio(jugador: Node3D) -> void:
	var cerca := is_instance_valid(jugador) and absf(jugador.global_position.x - 30.0) < 16.0
	if cerca:
		_rio.position = Vector3(30.0, 0.3, clampf(jugador.global_position.z, -36.0, 36.0))
	if cerca != _rio.has_meta("activo"):
		if cerca:
			_rio.set_meta("activo", true)
		else:
			_rio.remove_meta("activo")
		_fundir(_rio, "ambiente/" + RIO if cerca else "", true, -12.0)
