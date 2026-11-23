class_name MapaAldea
extends RefCounted
## Cuadrícula de navegación de la aldea para los NPC (AStarGrid2D de 1 u),
## construida una vez a partir de las colisiones reales: una casilla es
## transitable si una cápsula algo mayor que la del protagonista cabe sobre su
## suelo. Guarda la altura del suelo (puente y rampas) y abarata las casillas
## de los 36 corredores para que los NPC vayan por los caminos.

const ORIGEN := Vector2i(-40, -36)
const TAMANO := Vector2i(80, 72)
const RADIO: float = 0.36
const ALTURA_CAPSULA: float = 1.6
## Suelo más alto que esto es un obstáculo (mesas, muros bajos), no un piso.
const SUELO_MAXIMO: float = 0.7
const PESO_CAMINO: float = 1.0
const PESO_CAMPO: float = 4.0
## Distancia máxima entre la última casilla libre y el destino exacto.
const CIERRE: float = 1.5

var rejilla := AStarGrid2D.new()
var alturas := PackedFloat32Array()


## `excluir`: RID de cuerpos que no cuentan como obstáculo (jugador y NPC).
func construir(mundo: Node3D, excluir: Array[RID]) -> void:
	rejilla.region = Rect2i(ORIGEN, TAMANO)
	rejilla.cell_size = Vector2.ONE
	rejilla.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	rejilla.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	rejilla.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	rejilla.update()
	alturas.resize(TAMANO.x * TAMANO.y)
	var espacio := mundo.get_world_3d().direct_space_state
	var forma := CapsuleShape3D.new()
	forma.radius = RADIO
	forma.height = ALTURA_CAPSULA
	var consulta := PhysicsShapeQueryParameters3D.new()
	consulta.shape = forma
	consulta.exclude = excluir
	var caminos := _rectangulos_caminos(mundo)
	for x in TAMANO.x:
		for z in TAMANO.y:
			var celda := Vector2i(ORIGEN.x + x, ORIGEN.y + z)
			var centro := Vector2(celda) + Vector2(0.5, 0.5)
			var rayo := PhysicsRayQueryParameters3D.create(Vector3(centro.x, 1.5, centro.y), Vector3(centro.x, -0.5, centro.y))
			rayo.exclude = excluir
			var golpe := espacio.intersect_ray(rayo)
			var transitable: bool = not golpe.is_empty() and golpe.position.y <= SUELO_MAXIMO
			var altura: float = golpe.position.y if transitable else 0.0
			if transitable:
				consulta.transform = Transform3D(Basis(), Vector3(centro.x, altura + 0.15 + ALTURA_CAPSULA * 0.5, centro.y))
				transitable = espacio.intersect_shape(consulta, 1).is_empty()
			alturas[x * TAMANO.y + z] = altura
			rejilla.set_point_solid(celda, not transitable)
			if transitable:
				var en_camino := caminos.any(func(r: Rect2): return r.has_point(centro))
				rejilla.set_point_weight_scale(celda, PESO_CAMINO if en_camino else PESO_CAMPO)


func celda_de(pos: Vector3) -> Vector2i:
	return Vector2i(floori(pos.x), floori(pos.z))


func transitable(pos: Vector3) -> bool:
	var celda := celda_de(pos)
	return rejilla.is_in_boundsv(celda) and not rejilla.is_point_solid(celda)


func altura(pos: Vector3) -> float:
	var celda := celda_de(pos) - ORIGEN
	if celda.x < 0 or celda.y < 0 or celda.x >= TAMANO.x or celda.y >= TAMANO.y:
		return 0.0
	return alturas[celda.x * TAMANO.y + celda.y]


## Casilla transitable más cercana a `pos` (búsqueda en anillos hasta 4 u).
func celda_libre_cercana(pos: Vector3) -> Vector2i:
	var base := celda_de(pos)
	for radio in 5:
		var mejor := Vector2i(-9999, -9999)
		var mejor_distancia := INF
		for dx in range(-radio, radio + 1):
			for dz in range(-radio, radio + 1):
				var celda := base + Vector2i(dx, dz)
				if rejilla.is_in_boundsv(celda) and not rejilla.is_point_solid(celda):
					var distancia := (Vector2(celda) + Vector2(0.5, 0.5)).distance_to(Vector2(pos.x, pos.z))
					if distancia < mejor_distancia:
						mejor_distancia = distancia
						mejor = celda
		if mejor_distancia < INF:
			return mejor
	return base


## Puntos del mundo (centros de casilla, con la altura del suelo) de `desde` a
## `hasta`. Termina exactamente en `hasta` si está a menos de `CIERRE` de la
## última casilla: un puesto junto a una pared puede caer en una casilla cuyo
## centro no está libre aunque él sí lo esté. Vacío si no hay ruta.
func ruta(desde: Vector3, hasta: Vector3) -> PackedVector3Array:
	var puntos := PackedVector3Array()
	var origen := celda_libre_cercana(desde)
	var destino := celda_libre_cercana(hasta)
	if rejilla.is_point_solid(origen) or rejilla.is_point_solid(destino):
		return puntos
	var celdas := rejilla.get_id_path(origen, destino)
	if celdas.is_empty():
		return puntos
	for celda in celdas:
		var centro := Vector3(celda.x + 0.5, 0.0, celda.y + 0.5)
		centro.y = altura(centro)
		puntos.append(centro)
	var final := Vector3(hasta.x, altura(hasta), hasta.z)
	if Vector2(final.x, final.z).distance_to(Vector2(puntos[-1].x, puntos[-1].z)) <= CIERRE:
		puntos.append(final)
	return puntos


func _rectangulos_caminos(mundo: Node3D) -> Array[Rect2]:
	var rectangulos: Array[Rect2] = []
	var caminos := mundo.get_node_or_null("Aldea/Caminos")
	if caminos == null:
		return rectangulos
	for camino in caminos.get_children():
		if not camino.has_meta("a"):
			continue
		var a: Vector2 = camino.get_meta("a")
		var b: Vector2 = camino.get_meta("b")
		var medio: float = float(camino.get_meta("ancho")) * 0.5
		rectangulos.append(Rect2(a, Vector2.ZERO).expand(b).grow(medio))
	return rectangulos
