extends RefCounted
## Las operaciones preparan el resultado en una copia y publican solo al completarse.

const Catalogo = preload("res://scripts/vida/catalogo.gd")
const CAPACIDAD := 16


static func crear(capacidad: int) -> Array:
	var casillas: Array = []
	casillas.resize(capacidad)
	return casillas


static func jugador() -> Array:
	var estado := EstadoMundo.objeto("@jugador", "bolsa")
	if not estado.get("casillas") is Array:
		estado.casillas = crear(CAPACIDAD)
		for id in ["azada", "regadera", "pico", "semilla_trigo", "semilla_zanahoria", "semilla_patata"]:
			anadir(estado.casillas, id, 2 if id.begins_with("semilla_") else 1)
	return estado.casillas


static func seleccion() -> Dictionary:
	var bolsa := jugador()
	var indice := int(EstadoMundo.objeto("@jugador", "bolsa").get("seleccion", -1))
	if indice >= 0 and indice < bolsa.size() and bolsa[indice] is Dictionary:
		return bolsa[indice]
	return {}


static func elegir(indice: int) -> void:
	EstadoMundo.objeto("@jugador", "bolsa").seleccion = indice


static func cantidad(casillas: Array, id: String) -> int:
	var total := 0
	for pila in casillas:
		if pila is Dictionary and pila.id == id:
			total += pila.cantidad
	return total


static func anadir(casillas: Array, id: String, total: int) -> bool:
	var ficha := Catalogo.ficha(id)
	if ficha.is_empty() or total <= 0:
		return false
	var copia := casillas.duplicate(true)
	var restante := total
	for pila in copia:
		if pila is Dictionary and pila.id == id:
			var suma := mini(restante, int(ficha.pila) - pila.cantidad)
			pila.cantidad += suma
			restante -= suma
	for i in copia.size():
		if restante == 0:
			break
		if copia[i] == null:
			var suma := mini(restante, int(ficha.pila))
			copia[i] = {"id": id, "cantidad": suma}
			restante -= suma
	if restante > 0:
		return false
	casillas.assign(copia)
	return true


static func quitar(casillas: Array, indice: int, total: int) -> bool:
	if indice < 0 or indice >= casillas.size() or total <= 0:
		return false
	var pila: Variant = casillas[indice]
	if not pila is Dictionary or pila.cantidad < total:
		return false
	pila.cantidad -= total
	if pila.cantidad == 0:
		casillas[indice] = null
	return true


static func mover(casillas: Array, origen: int, destino: int, dividir: bool = false) -> bool:
	if origen == destino or mini(origen, destino) < 0 or maxi(origen, destino) >= casillas.size():
		return false
	var pila: Variant = casillas[origen]
	var otra: Variant = casillas[destino]
	if not pila is Dictionary:
		return false
	if dividir:
		if otra != null or pila.cantidad < 2:
			return false
		var mitad := floori(pila.cantidad / 2.0)
		casillas[destino] = {"id": pila.id, "cantidad": mitad}
		return quitar(casillas, origen, mitad)
	if otra is Dictionary and otra.id == pila.id:
		var suma := mini(pila.cantidad, int(Catalogo.ficha(pila.id).pila) - otra.cantidad)
		if suma <= 0:
			return false
		otra.cantidad += suma
		return quitar(casillas, origen, suma)
	casillas[origen] = otra
	casillas[destino] = pila
	return true


static func transferir(origen: Array, indice: int, destino: Array, total: int) -> bool:
	if is_same(origen, destino) or indice < 0 or indice >= origen.size() or total <= 0:
		return false
	var pila: Variant = origen[indice]
	if not pila is Dictionary or pila.cantidad < total or not anadir(destino, pila.id, total):
		return false
	return quitar(origen, indice, total)


static func valida(casillas: Variant) -> bool:
	if not casillas is Array or casillas.is_empty() or casillas.size() > 128:
		return false
	for pila in casillas:
		if pila == null:
			continue
		if not pila is Dictionary or not pila.get("id") is String or not pila.get("cantidad") is int:
			return false
		var ficha := Catalogo.ficha(pila.id)
		if ficha.is_empty() or pila.cantidad < 1 or pila.cantidad > int(ficha.pila):
			return false
	return true
