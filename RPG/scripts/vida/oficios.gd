extends RefCounted
## Recetas y producción comparten la mochila y el guardado del mundo.

const Bolsa = preload("res://scripts/vida/bolsa.gd")
const Catalogo = preload("res://scripts/vida/catalogo.gd")
const XP_POR_NIVEL := 24
const OFICIOS := {
	"pesca": ["Pesca", "Capturas de agua dulce."],
	"panaderia": ["Panadería", "Hogazas del horno de Marta."],
	"herreria": ["Herrería", "Refinado y fabricación en la fragua."],
	"cerveza": ["Elaboración de cerveza", "Bebidas de grano y hierbas."],
	"carpinteria": ["Carpintería", "Cortes y ensamblaje de madera."],
	"molienda": ["Molienda", "Harina fresca de las muelas del molino."],
}
# Cada ficha declara estación, ingredientes, producto, cantidad, nivel, XP y aciertos mínimos.
const RECETAS := {
	"hogaza": {estacion = "panaderia", ingredientes = {"harina": 1}, producto = "pan", cantidad = 1, nivel = 1, xp = 12, puntos = 1},
	"horneada": {nombre = "Hornada de pan", estacion = "panaderia", ingredientes = {"harina": 2}, producto = "pan", cantidad = 3, nivel = 2, xp = 16, puntos = 1},
	"refinar": {estacion = "herreria", ingredientes = {"hierro": 1, "carbon": 1}, producto = "lingote", cantidad = 1, nivel = 1, xp = 12, puntos = 1},
	"forjar_hacha": {estacion = "herreria", ingredientes = {"lingote": 1, "madera": 1}, producto = "hacha", cantidad = 1, nivel = 1, xp = 12, puntos = 1, unica = true},
	"cerveza_suave": {estacion = "cerveza", ingredientes = {"trigo": 1, "hierbas": 1}, producto = "cerveza", cantidad = 2, nivel = 1, xp = 12, puntos = 1},
	"cerveza_jarras": {nombre = "Tanda de jarras", estacion = "cerveza", ingredientes = {"trigo": 2, "hierbas": 1}, producto = "cerveza", cantidad = 3, nivel = 2, xp = 16, puntos = 1},
	"aserrar": {estacion = "carpinteria", ingredientes = {"madera": 1}, producto = "tablas", cantidad = 2, nivel = 1, xp = 12, puntos = 2},
	"ensamblar": {estacion = "carpinteria", ingredientes = {"tablas": 2}, producto = "cuenco", cantidad = 1, nivel = 2, xp = 16, puntos = 2},
	"moler": {estacion = "molienda", ingredientes = {"trigo": 1}, producto = "harina", cantidad = 1, nivel = 1, xp = 12, puntos = 1},
}


static func xp(oficio: String) -> int:
	return maxi(0, int(EstadoMundo.objeto("@jugador", "profesiones").get(oficio, 0)))


static func nivel(oficio: String) -> int:
	@warning_ignore("integer_division")
	return 1 + xp(oficio) / XP_POR_NIVEL


static func _experiencia(oficio: String, puntos: int) -> String:
	var anterior := nivel(oficio)
	EstadoMundo.objeto("@jugador", "profesiones")[oficio] = xp(oficio) + puntos
	var mensaje := " · +%d EXP" % puntos
	if nivel(oficio) > anterior:
		mensaje += " · %s sube al nivel %d" % [OFICIOS[oficio][0], nivel(oficio)]
	return mensaje


static func requisitos(id: String, estacion: String, copia: Array) -> String:
	var receta: Dictionary = RECETAS.get(id, {})
	if receta.is_empty() or receta.estacion != estacion:
		return "Receta no disponible en esta estación."
	if nivel(estacion) < receta.nivel:
		return "Requiere nivel %d." % receta.nivel
	if receta.get("unica", false) and Bolsa.cantidad(copia, receta.producto) > 0:
		return "Ya llevas esta herramienta."
	for ingrediente in receta.ingredientes:
		if not _retirar(copia, ingrediente, receta.ingredientes[ingrediente]):
			return "Falta %s." % Catalogo.ficha(ingrediente).nombre
	if not Bolsa.anadir(copia, receta.producto, receta.cantidad):
		return "Mochila llena."
	return ""


static func producir(id: String, estacion: String, puntos: int) -> String:
	var receta: Dictionary = RECETAS.get(id, {})
	if receta.is_empty() or puntos < receta.puntos:
		return "Trabajo incompleto. Conservas los ingredientes."
	var bolsa := Bolsa.jugador()
	var copia := bolsa.duplicate(true)
	var error := requisitos(id, estacion, copia)
	if not error.is_empty():
		return error
	bolsa.assign(copia)
	var mensaje := "+%d %s" % [receta.cantidad, Catalogo.ficha(receta.producto).nombre]
	mensaje += _experiencia(estacion, receta.xp)
	EstadoMundo.registrar_actividad("fabricar", receta.producto, receta.cantidad)
	EstadoMundo.registrar_actividad("minijuego", estacion)
	if not EstadoMundo.guardar_actual():
		mensaje += " · Guardado pendiente"
	return mensaje


static func _retirar(copia: Array, id: String, cantidad: int) -> bool:
	if cantidad <= 0 or Bolsa.cantidad(copia, id) < cantidad:
		return false
	for i in copia.size():
		var pila: Variant = copia[i]
		if pila is Dictionary and pila.id == id:
			var retirar := mini(cantidad, pila.cantidad)
			Bolsa.quitar(copia, i, retirar)
			cantidad -= retirar
			if cantidad == 0:
				return true
	return false


static func pendientes() -> Dictionary:
	return EstadoMundo.objeto("@jugador", "pesca_pendiente")


static func recoger_pesca() -> String:
	var bolsa := Bolsa.jugador()
	var pendientes_pesca := pendientes()
	var entregados := PackedStringArray()
	for id in pendientes_pesca.keys():
		var cantidad := int(pendientes_pesca[id])
		if Bolsa.anadir(bolsa, id, cantidad):
			pendientes_pesca.erase(id)
			entregados.append("+%d %s" % [cantidad, Catalogo.ficha(id).nombre])
	if not entregados.is_empty():
		EstadoMundo.guardar_actual()
	if not pendientes_pesca.is_empty():
		entregados.append("Captura reservada en el río. Haz sitio en la mochila.")
	return " · ".join(entregados)


static func capturar(puntos: int) -> String:
	if Bolsa.cantidad(Bolsa.jugador(), "cana") == 0:
		return "Necesitas una caña de pescar."
	if puntos <= 0:
		return "No hubo capturas aprovechables."
	if not pendientes().is_empty():
		return "Recoge primero la captura reservada."
	var id := "carpa_dorada" if puntos >= 60 else "pescado"
	var cantidad := clampi(floori(puntos / 30.0), 1, 3)
	pendientes()[id] = cantidad
	var progreso := _experiencia("pesca", cantidad * 6)
	EstadoMundo.registrar_actividad("pescar", "captura", cantidad)
	EstadoMundo.registrar_actividad("minijuego", "pesca")
	var captura := recoger_pesca()
	if not pendientes().is_empty():
		EstadoMundo.guardar_actual()
	return captura + progreso


## Estos métodos usan el ID estable del encargo del NPC. Se pueden reintentar si la mochila está llena.
static func entregar_materiales(encargo: String, materiales: Dictionary, guardar: bool = true) -> bool:
	var estado := EstadoMundo.objeto("@encargos_oficio", encargo)
	if estado.get("materiales", false) or estado.get("completo", false):
		return false
	var bolsa := Bolsa.jugador()
	var copia := bolsa.duplicate(true)
	for id in materiales:
		if not Bolsa.anadir(copia, id, materiales[id]):
			return false
	bolsa.assign(copia)
	estado.materiales = true
	if guardar:
		EstadoMundo.guardar_actual()
	return true


static func entregar_producto(encargo: String, id: String, cantidad: int, monedas: int, guardar: bool = true) -> bool:
	var estado := EstadoMundo.objeto("@encargos_oficio", encargo)
	var bolsa := Bolsa.jugador()
	var copia := bolsa.duplicate(true)
	if estado.get("completo", false) or monedas < 0 or not _retirar(copia, id, cantidad):
		return false
	bolsa.assign(copia)
	estado.completo = true
	EstadoMundo.datos.monedas += monedas
	if guardar:
		EstadoMundo.guardar_actual()
	return true

