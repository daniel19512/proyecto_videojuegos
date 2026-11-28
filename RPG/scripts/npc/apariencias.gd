extends RefCounted

const RAIZ := "res://assets/personajes/definitivos"
const PREDETERMINADA := "viajero_19"
const JUGADOR := {
	"viajero_17": ["Cabello largo y vestido ciruela", 17],
	"viajero_18": ["Chaleco de artesano y cartera", 18],
	"viajero_19": ["Jubón gris azulado y bandolera", 19],
	"viajero_20": ["Trenza y capa malva", 20],
	"viajero_21": ["Cabello castaño y morral de campo", 21],
	"viajero_22": ["Moño oscuro y vestido verde", 22],
	"viajero_23": ["Barba corta y chaleco azul", 23],
	"viajero_24": ["Cabello rojizo y túnica de tierra", 24],
}
const NPCS := {
	1: "rodrigo", 2: "elias", 3: "ines", 4: "baltasar",
	5: "martin", 6: "alba", 7: "hernan", 8: "mateo",
	9: "clara", 10: "samuel", 11: "esteban", 12: "aurora",
	13: "diego", 14: "ramiro", 15: "octavio", 16: "leonor",
}
const ESCALA := 0.045 * 33.0 / 46.0

static var _cache: Dictionary = {}
static var _sombra: QuadMesh


static func ficha(numero: int) -> Dictionary:
	if _cache.has(numero):
		return _cache[numero]
	var grupo := "npcs" if NPCS.has(numero) else "protagonista"
	var nombre: String = NPCS.get(numero, "viajero_%d" % numero)
	if numero == JUGADOR[PREDETERMINADA][1]:
		nombre = "viajero"
	elif grupo == "protagonista" and not JUGADOR.has(nombre):
		return {}
	var ruta := "%s/%s/frames/%s.tres" % [RAIZ, grupo, nombre]
	var frames := load(ruta) as SpriteFrames
	if not frames:
		return {}
	var resultado := {
		"frames": frames,
		"escala": ESCALA,
		"offset": Vector2(0, 24.0 + 0.09 / ESCALA),
		"vista_previa": frames.get_frame_texture(&"idle_abajo", 0),
	}
	_cache[numero] = resultado
	return resultado


static func colocar_sombra(personaje: Node3D) -> void:
	if personaje.has_node("SombraPersonaje"):
		return
	if not _sombra:
		var degradado := Gradient.new()
		degradado.colors = PackedColorArray([Color(0.06, 0.04, 0.025, 0.32), Color(0.06, 0.04, 0.025, 0)])
		var textura := GradientTexture2D.new()
		textura.width = 32
		textura.height = 32
		textura.gradient = degradado
		textura.fill = GradientTexture2D.FILL_RADIAL
		textura.fill_from = Vector2(0.5, 0.5)
		textura.fill_to = Vector2(1.0, 0.5)
		var material := StandardMaterial3D.new()
		material.albedo_texture = textura
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_sombra = QuadMesh.new()
		_sombra.size = Vector2(1.05, 0.82)
		_sombra.material = material
	var nodo := MeshInstance3D.new()
	nodo.name = "SombraPersonaje"
	nodo.mesh = _sombra
	nodo.position.y = 0.025
	nodo.rotation.x = -PI * 0.5
	nodo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	personaje.add_child(nodo)
