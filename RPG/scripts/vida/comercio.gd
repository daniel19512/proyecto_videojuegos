extends RefCounted

const Bolsa = preload("res://scripts/vida/bolsa.gd")
const Catalogo = preload("res://scripts/vida/catalogo.gd")
const EXISTENCIAS := 12
const NOMBRES := {
	"panaderia": "Panadería de Marta",
	"herreria": "Herrería de Gonzalo",
	"herbolario": "Herbolario",
	"mercado": "Mercado",
	"semillas": "Puesto de semillas",
}
const TIENDAS := {
	"panaderia": ["pan", "harina", "trigo"],
	"herreria": ["azada", "regadera", "hacha", "pico", "hierro", "cobre", "carbon", "lingote"],
	"herbolario": ["hierbas", "flores", "semilla_zanahoria", "semilla_patata"],
	"mercado": ["semilla_trigo", "semilla_zanahoria", "semilla_patata", "madera", "piedra", "pan", "tablas", "cana"],
	"semillas": ["semilla_trigo", "semilla_zanahoria", "semilla_patata", "trigo", "zanahoria", "patata"],
}


static func stock(tienda: String, id: String) -> int:
	var estado := EstadoMundo.objeto("@economia", tienda)
	var entrada: Dictionary = estado.get(id, {})
	return int(entrada.get("cantidad", EXISTENCIAS)) if entrada.get("dia") == Reloj.dia else EXISTENCIAS


static func comprar(tienda: String, id: String) -> String:
	if not id in TIENDAS.get(tienda, []) or stock(tienda, id) < 1:
		return "Producto agotado."
	var ficha := Catalogo.ficha(id)
	var precio := int(ficha.compra)
	if EstadoMundo.datos.monedas < precio:
		return "Te faltan monedas."
	if not Bolsa.anadir(Bolsa.jugador(), id, 1):
		return "Inventario lleno."
	EstadoMundo.datos.monedas -= precio
	EstadoMundo.objeto("@economia", tienda)[id] = {"dia": Reloj.dia, "cantidad": stock(tienda, id) - 1}
	EstadoMundo.registrar_actividad("comercio", "operacion")
	return "Compraste: " + ficha.nombre


static func vender(indice: int) -> String:
	var casillas := Bolsa.jugador()
	if indice < 0 or indice >= casillas.size() or not casillas[indice] is Dictionary:
		return "Elige un objeto para vender."
	var ficha := Catalogo.ficha(casillas[indice].id)
	var precio := int(ficha.venta)
	if precio <= 0:
		return "Este objeto no se vende."
	if not Bolsa.quitar(casillas, indice, 1):
		return "El objeto ya no está disponible."
	EstadoMundo.datos.monedas += precio
	EstadoMundo.registrar_actividad("comercio", "operacion")
	return "Vendiste %s por %d monedas." % [ficha.nombre, precio]
