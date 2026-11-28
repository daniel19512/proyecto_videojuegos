extends RefCounted

const RUTA := "res://data/vida/objetos.json"
const MONEDA := "res://assets/inventario/iconos/larchrow-rpg-item-icons/PNG/misc/coin_gold.png"

static var fichas: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RUTA))


static func ficha(id: String) -> Dictionary:
	return fichas.get(id, {})


static func icono(id: String) -> Texture2D:
	return textura(ficha(id).get("icono", ""))


static func textura(ruta: String) -> Texture2D:
	if not ruta.is_empty() and ResourceLoader.exists(ruta, "Texture2D"):
		return load(ruta) as Texture2D
	return null
