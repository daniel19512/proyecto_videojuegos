extends RefCounted

const Bolsa = preload("res://scripts/vida/bolsa.gd")
const Catalogo = preload("res://scripts/vida/catalogo.gd")


static func trabajo(puntuacion: int, producto: String) -> void:
	if puntuacion <= 0:
		return
	var monedas := clampi(floori(puntuacion / 10.0), 1, 15)
	EstadoMundo.datos.monedas += monedas
	var mensaje := "Trabajo: +%d monedas." % monedas
	if Bolsa.anadir(Bolsa.jugador(), producto, 1):
		mensaje += " +1 " + Catalogo.ficha(producto).nombre
	else:
		mensaje += " Mochila llena."
	InterfazVida.avisar(mensaje)
