extends RefCounted
## Un riego por siembra. Las etapas se calculan al consultar el estado, también fuera de escena.

const Bolsa = preload("res://scripts/vida/bolsa.gd")
const Catalogo = preload("res://scripts/vida/catalogo.gd")


static func etapa(estado: Dictionary) -> int:
	if not estado.get("preparada", false):
		return 0
	var semilla := Catalogo.ficha(estado.get("semilla", ""))
	if semilla.is_empty():
		return 1
	if not estado.has("riego"):
		return 2
	var avance := maxf(0.0, Reloj.tiempo_juego - float(estado.riego)) / float(semilla.segundos)
	return 5 if avance >= 1.0 else (4 if avance >= 0.5 else 3)


static func actuar(estado: Dictionary) -> String:
	var seleccionado: String = Bolsa.seleccion().get("id", "")
	match etapa(estado):
		0:
			if seleccionado != "azada":
				return "Equipa la azada desde el inventario."
			estado.preparada = true
			return "Tierra preparada."
		1:
			var semilla := Catalogo.ficha(seleccionado)
			if not semilla.has("cultivo"):
				return "Equipa las semillas que quieras plantar."
			var indice := int(EstadoMundo.objeto("@jugador", "bolsa").get("seleccion", -1))
			if not Bolsa.quitar(Bolsa.jugador(), indice, 1):
				return "Ya no quedan semillas."
			estado.semilla = seleccionado
			EstadoMundo.registrar_actividad("sembrar", semilla.cultivo)
			return "Sembrado. Equipa la regadera."
		2:
			if seleccionado != "regadera":
				return "Equipa la regadera desde el inventario."
			estado.riego = Reloj.tiempo_juego
			return "Cultivo regado."
		5:
			var producto: String = Catalogo.ficha(estado.semilla).cultivo
			if not Bolsa.anadir(Bolsa.jugador(), producto, 2):
				return "Inventario lleno. La cosecha sigue en la parcela."
			estado.erase("semilla")
			estado.erase("riego")
			EstadoMundo.registrar_actividad("cosechar", producto, 2)
			return "Cosechaste 2 × " + Catalogo.ficha(producto).nombre
	return "El cultivo está creciendo."
