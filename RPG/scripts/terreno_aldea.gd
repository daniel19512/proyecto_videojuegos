@tool
extends Node
## Acabado visual unico. Las marcas y los metadatos siguen siendo la fuente del plano.
## No genera cuerpos fisicos ni modifica la geometria de los corredores.
@export var activo: bool = true
const TAMANO := Vector2(80, 72)
const RESOLUCION := Vector2i(800, 720)
var material: ShaderMaterial
var marcas: Array[GeometryInstance3D] = []
var visibilidad: Array[bool] = []

func _ready() -> void:
	if not activo:
		return
	var aldea := get_parent()
	var imagen := Image.create(RESOLUCION.x, RESOLUCION.y, false, Image.FORMAT_RGBA8)
	imagen.fill(Color(0, 0, 0, 1))
	for camino in aldea.get_node("Caminos").get_children():
		var a: Vector2 = camino.get_meta("a")
		var b: Vector2 = camino.get_meta("b")
		var ancho: float = camino.get_meta("ancho")
		# Caja redondeada: conserva el ancho del eje, suaviza encuentros y terminales.
		pintar(imagen, (a+b)*0.5, (b-a).abs()*0.5+Vector2.ONE*ancho*0.5, 0.65, 0)
	pintar(imagen, Vector2.ZERO, Vector2(10,9), 1.3, 1)
	material = ShaderMaterial.new()
	material.shader = preload("res://scripts/terreno_aldea.gdshader")
	imagen.generate_mipmaps()
	material.set_shader_parameter("mascara", ImageTexture.create_from_image(imagen))
	aldea.get_node("Terreno/Suelo/MallaSuelo").material_override = material
	for grupo in ["Caminos", "Plaza", "Parcelas", "Jardines", "Reservas"]:
		for nodo in aldea.get_node(grupo).find_children("*", "GeometryInstance3D", true, false):
			if nodo.name == "Marca" or nodo is Label3D:
				marcas.append(nodo)
				visibilidad.append(nodo.visible)
				nodo.visible = false

func pintar(imagen: Image, centro: Vector2, semiejes: Vector2, radio: float, canal: int) -> void:
	var margen := 1.2
	var minimo := Vector2i(((centro-semiejes-Vector2.ONE*margen+TAMANO*0.5)*10).floor()).clamp(Vector2i.ZERO, RESOLUCION-Vector2i.ONE)
	var maximo := Vector2i(((centro+semiejes+Vector2.ONE*margen+TAMANO*0.5)*10).ceil()).clamp(Vector2i.ZERO, RESOLUCION-Vector2i.ONE)
	for y in range(minimo.y, maximo.y+1):
		for x in range(minimo.x, maximo.x+1):
			var p := (Vector2(x,y)+Vector2.ONE*0.5)*0.1-TAMANO*0.5
			var q := (p-centro).abs()-semiejes+Vector2.ONE*radio
			var distancia := q.max(Vector2.ZERO).length()+minf(maxf(q.x,q.y),0.0)-radio
			var valor := clampf(0.5-distancia/2.4,0,1)
			var color := imagen.get_pixel(x,y)
			var mezcla := maxf(0.0, 1.0-absf(color[canal]-valor)/0.18)
			color[canal] = minf(1.0, maxf(color[canal],valor)+mezcla*mezcla*0.045) if valor > 0.0 else color[canal]
			imagen.set_pixel(x,y,color)

func mostrar_original(original: bool) -> void:
	# Comparaciones reproducibles desde el capturador; no cambia escenas guardadas.
	get_parent().get_node("Terreno/Suelo/MallaSuelo").material_override = null if original else material
	for i in marcas.size():
		marcas[i].visible = visibilidad[i] if original else false
