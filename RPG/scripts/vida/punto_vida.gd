extends Node3D
## Proyección visual de un objeto con identidad estable dentro de la región.

const Bolsa = preload("res://scripts/vida/bolsa.gd")
const Catalogo = preload("res://scripts/vida/catalogo.gd")
const Parcela = preload("res://scripts/vida/parcela.gd")
const Descubrimientos = preload("res://scripts/vida/descubrimientos.gd")
const Estilo = preload("res://scripts/presentacion/estilo.gd")

var tipo: String
var producto: String
var estado: Dictionary
var cantidad := 1
var regeneracion := 0.0
var herramienta := ""
var aviso: Label3D
var _sprite: Sprite3D
var _tierra: MeshInstance3D
var _material_surcos: StandardMaterial3D
var _etapa := -1


func _ready() -> void:
	aviso = Label3D.new()
	aviso.position.y = 1.85
	aviso.font_size = 38
	aviso.pixel_size = 0.008
	aviso.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	aviso.outline_size = 12
	aviso.hide()
	add_child(aviso)
	_sprite = Sprite3D.new()
	_sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	_sprite.pixel_size = 0.035
	_sprite.position.y = 0.32
	_sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	add_child(_sprite)
	match tipo:
		"parcela":
			_tierra = MeshInstance3D.new()
			var caja := BoxMesh.new()
			caja.size = Vector3(1.45, 0.08, 1.45)
			_tierra.mesh = caja
			_tierra.material_override = StandardMaterial3D.new()
			add_child(_tierra)
			var surco := BoxMesh.new()
			surco.size = Vector3(0.17, 0.014, 1.22)
			_material_surcos = StandardMaterial3D.new()
			for x in [-0.43, 0.0, 0.43]:
				var marca := MeshInstance3D.new()
				marca.mesh = surco
				marca.material_override = _material_surcos
				marca.position = Vector3(x, 0.044, 0)
				add_child(marca)
		"cofre":
			var cofre := load("res://assets/objetos_medievales/glTF/Chest_Wood.gltf") as PackedScene
			if cofre:
				add_child(cofre.instantiate())
			else:
				_sprite.texture = Catalogo.textura("res://assets/inventario/iconos/larchrow-rpg-item-icons/PNG/misc/chest_wood.png")
		"tienda":
			_sprite.position.y = 0.8
			_sprite.texture = Catalogo.textura(Catalogo.MONEDA)
		"descubrimiento":
			_sprite.texture = Catalogo.textura(Descubrimientos.ICONO)
		"feria":
			_sprite.texture = Catalogo.icono(producto)
			_sprite.position.y = 1.05
			_sprite.scale *= 1.8
			var cartel := Label3D.new()
			cartel.text = "Feria · " + Catalogo.ficha(producto).nombre
			cartel.position.y = 2.2
			cartel.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			cartel.modulate = Color("#fff0b2")
			cartel.pixel_size = 0.007
			add_child(cartel)
		"cofre_personal", "descanso":
			_sprite.hide()
		_:
			_sprite.texture = Catalogo.icono(producto)
	refrescar()


func refrescar() -> void:
	match tipo:
		"parcela":
			var etapa := Parcela.etapa(estado)
			if etapa == _etapa:
				return
			_etapa = etapa
			var color_tierra := Color("#655039") if etapa == 0 else (Color("#6c402a") if etapa < 3 else Color("#382a2c"))
			_tierra.material_override.albedo_color = color_tierra
			_material_surcos.albedo_color = color_tierra.darkened(0.28)
			_sprite.visible = etapa >= 2
			if etapa >= 2:
				var ficha := Catalogo.ficha(estado.semilla)
				_sprite.texture = Catalogo.icono(estado.semilla if etapa < 4 else ficha.cultivo)
				var tamano: float = [0.0, 0.0, 0.52, 0.64, 0.87, 1.30][etapa]
				_sprite.scale = Vector3.ONE * tamano
		"recurso":
			visible = not estado.get("recogido", false) or (regeneracion > 0 and Reloj.tiempo_juego >= float(estado.get("disponible", INF)))


func texto() -> String:
	match tipo:
		"parcela":
			return ["Preparar · azada", "Sembrar · semillas", "Regar · regadera", "Regada", "Creciendo", "Cosechar"][Parcela.etapa(estado)]
		"cofre":
			return "Abrir cofre"
		"cofre_personal":
			return "Abrir cofre personal"
		"descanso":
			return "Descansar"
		"tienda":
			return "Comerciar · " + {"panaderia": "Marta", "herreria": "Gonzalo", "herbolario": "Herbolario", "mercado": "Mercado"}.get(producto, producto)
		"descubrimiento":
			return "Examinar · " + Descubrimientos.PUNTOS[producto].titulo
		"feria":
			return "Visitar puesto · " + Catalogo.ficha(producto).nombre
	var accion: String = {"hacha": "Talar · ", "pico": "Extraer · "}.get(herramienta, "Recoger ")
	return accion + Catalogo.ficha(producto).get("nombre", producto)


func actuar() -> void:
	refrescar()
	if not visible:
		return
	match tipo:
		"parcela":
			InterfazVida.avisar(Parcela.actuar(estado))
			refrescar()
		"cofre", "cofre_personal":
			if not estado.get("casillas") is Array:
				estado.casillas = Bolsa.crear(12)
			AudioJuego.efecto("cofre")
			InterfazVida.abrir("cofre", "", estado.casillas)
		"descanso":
			get_tree().paused = true
			Estilo.confirmar(self, "¿Quieres dormir hasta la mañana siguiente?\nDespertarás a las 06:00.",
				GestorRegiones.descansar.bind(global_position), "Dormir", Callable(), "Descansar",
				"Cancelar", func(): get_tree().paused = false)
		"tienda":
			InterfazVida.abrir("tienda", producto)
		"descubrimiento":
			Diario.mostrar_descubrimiento(producto, Descubrimientos.examinar(producto, global_position))
		"feria":
			Misiones.visitar_puesto(String(name))
			var lineas := {"trigo": "Los agricultores intercambian muestras de las semillas del valle.",
				"tablas": "Los talleres muestran cómo encajan las piezas del mercado.",
				"cobre": "Una muestra de la mina ilustra las pesas recuperadas en las Ruinas."}
			InterfazVida.avisar(lineas[producto])
		_:
			if not herramienta.is_empty() and Bolsa.cantidad(Bolsa.jugador(), herramienta) == 0:
				InterfazVida.avisar("Necesitas: " + Catalogo.ficha(herramienta).nombre)
				return
			if not Bolsa.anadir(Bolsa.jugador(), producto, cantidad):
				InterfazVida.avisar("Inventario lleno. El objeto sigue aquí.")
				return
			estado.recogido = true
			if regeneracion > 0:
				estado.disponible = Reloj.tiempo_juego + regeneracion
			if not String(name).begins_with("suelto_"):
				EstadoMundo.registrar_actividad("extraer" if herramienta == "pico" else "recoger", producto, cantidad)
			InterfazVida.avisar("Recogiste %d × %s." % [cantidad, Catalogo.ficha(producto).nombre])
			refrescar()
