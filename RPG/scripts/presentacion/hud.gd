extends CanvasLayer

const Regiones = preload("res://scripts/presentacion/regiones.gd")
const Estilo = preload("res://scripts/presentacion/estilo.gd")
const Bolsa = preload("res://scripts/vida/bolsa.gd")
const Catalogo = preload("res://scripts/vida/catalogo.gd")

var _panel: PanelContainer
var _estado: Label
var _barra: PanelContainer
var _objetos := []
var _pista: Label
var _instante := 0.0

func _ready() -> void:
	layer = 8
	process_mode = PROCESS_MODE_ALWAYS
	_panel = PanelContainer.new()
	_panel.position = Vector2(16, 16)
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_panel)
	_estado = Label.new()
	_panel.add_child(_estado)
	var centro := CenterContainer.new()
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(centro)
	centro.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	centro.offset_top = -102
	centro.offset_bottom = -12
	_barra = PanelContainer.new()
	_barra.mouse_filter = Control.MOUSE_FILTER_IGNORE
	centro.add_child(_barra)
	var pila := VBoxContainer.new()
	_barra.add_child(pila)
	var fila := HBoxContainer.new()
	fila.alignment = BoxContainer.ALIGNMENT_CENTER
	pila.add_child(fila)
	for i in 6:
		var icono := Estilo.textura(null, Vector2(24, 24))
		icono.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var cantidad := Label.new()
		var borde := PanelContainer.new()
		borde.add_theme_stylebox_override("panel", _panel.get_theme_stylebox("focus", "Button"))
		fila.add_child(borde)
		var celda := HBoxContainer.new()
		borde.add_child(celda)
		celda.custom_minimum_size.x = 57
		celda.add_child(icono)
		celda.add_child(cantidad)
		_objetos.append([icono, cantidad, borde])
	_pista = Label.new()
	_pista.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pila.add_child(_pista)
	hide()

func _process(delta: float) -> void:
	visible = Partidas.espacio > 0 and not get_tree().paused and not GestorRegiones.en_transicion
	if not visible:
		return
	_instante -= delta
	if _instante <= 0:
		_instante = 0.12
		_refrescar()

func _unhandled_input(evento: InputEvent) -> void:
	if not visible or not _barra.visible or evento.is_echo():
		return
	var avance := int(evento.is_action_pressed("ranura_siguiente")) - int(evento.is_action_pressed("ranura_anterior"))
	if avance == 0 and not evento.is_action_pressed("ranura_usar"):
		return
	if avance:
		var indice := int(EstadoMundo.objeto("@jugador", "bolsa").get("seleccion", -1))
		Bolsa.elegir(posmod(indice + avance, Bolsa.CAPACIDAD))
	else:
		var actividad := get_tree().current_scene.get_node_or_null("Region/ActividadesVida")
		if actividad:
			actividad.usar_seleccion_rapida()
	_refrescar()
	get_viewport().set_input_as_handled()

func _refrescar() -> void:
	_estado.text = "%s  ·  Día %d  %s (%s)  ·  %d monedas" % [
		Regiones.nombre(String(GestorRegiones.region_actual)), Reloj.dia,
		Regiones.hora(Reloj.segundos), Reloj.nombre_franja(), EstadoMundo.datos.monedas]
	_barra.visible = Ajustes.valores.barra
	if not _barra.visible:
		return
	var inventario := Bolsa.jugador()
	var elegida := int(EstadoMundo.objeto("@jugador", "bolsa").get("seleccion", -1))
	var inicio := clampi(elegida - 2, 0, Bolsa.CAPACIDAD - _objetos.size())
	for i in _objetos.size():
		var casilla: Variant = inventario[inicio + i]
		var ocupada: bool = casilla is Dictionary
		var icono: TextureRect = _objetos[i][0]
		var etiqueta: Label = _objetos[i][1]
		icono.texture = Catalogo.icono(casilla.id) if ocupada else null
		etiqueta.text = str(casilla.cantidad) if ocupada else "·"
		var activa := inicio + i == elegida
		etiqueta.modulate = Color.WHITE if activa else Color(1, 1, 1, 0.58)
		var borde: PanelContainer = _objetos[i][2]
		borde.self_modulate = Color.WHITE if activa else Color(1, 1, 1, 0)
	var seleccion := Bolsa.seleccion()
	var nombre := String(Catalogo.ficha(seleccion.id).nombre) if not seleccion.is_empty() else "Sin objeto"
	_pista.text = "%s · %s / %s Elegir · %s Usar" % [nombre, Ajustes.indicacion("ranura_anterior"), Ajustes.indicacion("ranura_siguiente"), Ajustes.indicacion("ranura_usar")]
