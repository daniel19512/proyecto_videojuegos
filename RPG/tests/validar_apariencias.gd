extends SceneTree

const APARIENCIAS := "res://scripts/npc/apariencias.gd"
const RAIZ := "res://assets/personajes"
const DIRECCIONES := ["abajo", "arriba", "izquierda", "derecha"]
var fallos := 0
var comprobaciones := 0


func _initialize() -> void:
	validar.call_deferred()


func validar() -> void:
	var catalogo: GDScript = load(APARIENCIAS)
	var estado := root.get_node("EstadoMundo")
	var historia := root.get_node("Historia")
	comprobar(historia.nombres_npc().size() == 21, "21 identidades")
	comprobar(estado.apariencias_disponibles().size() == 8, "Ocho opciones")
	var vistas := {}
	for id in range(1, 25):
		var ficha: Dictionary = catalogo.ficha(id)
		if not comprobar(not ficha.is_empty(), "Recurso %d" % id):
			continue
		var frames: SpriteFrames = ficha.frames
		comprobar(frames.get_animation_names().size() == 8, "Ocho animaciones: %d" % id)
		var frente: Texture2D = ficha.vista_previa
		var firma := frente.get_image().get_data().hex_encode()
		comprobar(not vistas.has(firma), "Vista frontal única: %d" % id)
		vistas[firma] = true
		for direccion in DIRECCIONES:
			for estado_visual in ["idle", "walk"]:
				validar_animacion(frames, estado_visual + "_" + direccion, id)
		comprobar(is_equal_approx((ficha.offset.y - 24) * ficha.escala, 0.09), "Apoyo: %d" % id)
	for nombre in ["rodrigo", "alba", "viajero"]:
		for estado_visual in ["idle", "walk"]:
			var archivo := "%s_%s.png" % [nombre, estado_visual]
			var grupo := "protagonista" if nombre == "viajero" else "npcs"
			var anterior := FileAccess.get_sha256("%s/npcs/prueba_estilo/%s" % [RAIZ, archivo])
			var definitivo := FileAccess.get_sha256("%s/definitivos/%s/hojas/%s" % [RAIZ, grupo, archivo])
			comprobar(not anterior.is_empty() and anterior == definitivo, "Piloto preservado: " + archivo)
	print("APARIENCIAS: %d fallos / %d comprobaciones. Mandos detectados: %d" % [
		fallos, comprobaciones, Input.get_connected_joypads().size()])
	quit(1 if fallos else 0)


func validar_animacion(frames: SpriteFrames, animacion: String, id: int) -> void:
	if not comprobar(frames.has_animation(animacion) and frames.get_frame_count(animacion) == 4,
			"Secuencia %s: %d" % [animacion, id]):
		return
	var fotogramas := {}
	for i in 4:
		var atlas := frames.get_frame_texture(animacion, i) as AtlasTexture
		var imagen := atlas.get_image()
		var silueta := imagen.get_used_rect()
		comprobar(atlas.filter_clip and imagen.get_size() == Vector2i(40, 48)
			and imagen.get_pixel(0, 0).a == 0.0 and silueta.has_area() and silueta.position.x > 0
			and silueta.end.x < 40 and silueta.position.y > 0 and silueta.end.y == 48,
			"Encuadre, transparencia y apoyo %d / %s / %d" % [id, animacion, i])
		fotogramas[imagen.get_data().hex_encode()] = true
	comprobar(fotogramas.size() >= 2, "Movimiento visible %d / %s" % [id, animacion])


func comprobar(valor: bool, etiqueta: String) -> bool:
	comprobaciones += 1
	if not valor:
		fallos += 1
		push_error(etiqueta)
	return valor
