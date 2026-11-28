extends SceneTree

const ESCENAS := ["mundo", "mundo_bosque", "mundo_campos_granjas", "mundo_montanas", "mundo_minas", "mundo_ruinas"]
const FOTOGRAMAS_POR_REGION := 3900
const INTERVALO_MUESTRA := 12
const SEPARACION_FISICA := 0.63
var fallos := 0
var muestras := 0
var avisados: Dictionary = {}


func _initialize() -> void:
	validar.call_deferred()


func validar() -> void:
	var reloj := root.get_node("Reloj")
	var aldeanos := root.get_node("Aldeanos")
	reloj.escala = 4.0
	for region in ESCENAS:
		if change_scene_to_file("res://scenes/" + region + ".tscn") != OK:
			push_error("No se pudo abrir " + region)
			quit(1)
			return
		await scene_changed
		var jugador := current_scene.get_node("Jugador") as Node3D
		for i in FOTOGRAMAS_POR_REGION:
			await physics_frame
			if i % INTERVALO_MUESTRA == 0:
				var actores: Array = aldeanos.nodos.values()
				actores.append(jugador)
				comprobar_separacion(actores, region)
	print("TRAFICO: %d fallos / %d pares observados; día %d, %.1f segundos." % [
		fallos, muestras, reloj.dia, reloj.tiempo_juego])
	quit(1 if fallos else 0)


func comprobar_separacion(actores: Array, region: String) -> void:
	for i in actores.size():
		for j in range(i + 1, actores.size()):
			var a: Node3D = actores[i]
			var b: Node3D = actores[j]
			var delta := a.global_position - b.global_position
			muestras += 1
			if absf(delta.y) >= 0.8 or Vector2(delta.x, delta.z).length() >= SEPARACION_FISICA:
				continue
			fallos += 1
			var clave := "%s/%s/%s" % [region, a.name, b.name]
			if not avisados.has(clave):
				avisados[clave] = true
				push_error("Separación insuficiente en %s (%.3f)" % [clave, Vector2(delta.x, delta.z).length()])
