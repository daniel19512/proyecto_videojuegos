extends RefCounted

const Calendario = preload("res://scripts/ia/calendario.gd")

const DATOS := {
	"Aldea": ["Aldea", "aldea", "Un hogar entre caminos, oficios y nuevas historias.", "Plaza, mercado, cultivos y talleres", Vector3(-3, 1, -4)],
	"Bosque": ["Bosque", "bosque", "Entre antiguos árboles, la naturaleza guarda sus propias historias.", "Senderos y recolección", Vector3(0, 1, 8)],
	"CamposYGranjas": ["Campos y Granjas", "campos", "La paciencia y el trabajo dan fruto bajo el sol.", "Bancales y caminos rurales", Vector3(0, 1, 0)],
	"Montanas": ["Montañas", "montanas", "Más allá de los senderos, esperan nuevos horizontes.", "Campamento y paso minero", Vector3(28, 13, 10)],
	"Minas": ["Minas", "minas", "Bajo la tierra descansan los recursos de generaciones.", "Vetas y galerías", Vector3(8, -3, -40)],
	"Ruinas": ["Ruinas", "ruinas", "Las piedras conservan recuerdos de tiempos olvidados.", "Vestigios antiguos", Vector3(0, 1, 0)],
}
const ESCENAS := {
	"Aldea": "mundo", "Bosque": "mundo_bosque", "CamposYGranjas": "mundo_campos_granjas",
	"Montanas": "mundo_montanas", "Minas": "mundo_minas", "Ruinas": "mundo_ruinas",
}
const INTERIORES := {
	"TabernaE01": "Taberna", "InteriorE02": "Panadería", "InteriorE03": "Herrería",
	"InteriorE04": "Carpintería", "InteriorE05": "Herbolario", "InteriorE06": "Vivienda E06",
	"InteriorE07": "Vivienda E07", "InteriorE08": "Vivienda E08", "InteriorE09": "Vivienda E09",
	"InteriorE10": "Vivienda E10", "InteriorE11": "Vivienda E11", "InteriorE12": "Molino",
}
const RUTAS := [
	["Bosque", "Ruinas"], ["Bosque", "Aldea"], ["Aldea", "CamposYGranjas"],
	["Aldea", "Montanas"], ["Montanas", "Minas"],
]

static func ruta(id: String) -> String:
	return "res://scenes/%s.tscn" % ESCENAS[id]

static func id_por_ruta(origen: String) -> String:
	for id in ESCENAS:
		if ruta(id) == origen:
			return id
	return ""

static func nombre(id: String) -> String:
	return DATOS[id][0] if DATOS.has(id) else INTERIORES.get(id, id.replace("_", " "))

static func imagen(id: String) -> Texture2D:
	return load("res://assets/transiciones/%s.png" % DATOS[id][1]) as Texture2D

static func hora(segundos: float) -> String:
	var minutos := Calendario.minutos_del_dia(segundos)
	return "%02d:%02d" % [minutos / 60, minutos % 60]
