extends CanvasLayer

const Bolsa = preload("res://scripts/vida/bolsa.gd")
const Catalogo = preload("res://scripts/vida/catalogo.gd")
const Comercio = preload("res://scripts/vida/comercio.gd")
const Oficios = preload("res://scripts/vida/oficios.gd")
const BORDE := "res://assets/inventario/interfaz/kenney_ui-pack-pixel-adventure/Tiles/Large tiles/Thin outline/tile_0000.png"

var contexto := ""
var modo := ""
var almacen: Array
var _mensaje := ""
var _fondo: ColorRect
var _contenido: VBoxContainer
var _aviso: Label
var _fin_aviso := 0
var _foco := ""
var _iniciar_oficio: Callable
var _oficio_consultado := "pesca"
var _eje_menu := Vector2i.ZERO
var _fotograma_interaccion := -2


func _ready() -> void:
	layer = 35
	process_mode = PROCESS_MODE_ALWAYS
	_fondo = ColorRect.new()
	_fondo.color = Color(0.09, 0.06, 0.04, 0.78)
	add_child(_fondo)
	_fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var margen := MarginContainer.new()
	_fondo.add_child(margen)
	margen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for lado in ["left", "right", "top", "bottom"]:
		margen.add_theme_constant_override("margin_" + lado, 26)
	var panel := PanelContainer.new()
	margen.add_child(panel)
	panel.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var interior := MarginContainer.new()
	panel.add_child(interior)
	for lado in ["left", "right", "top", "bottom"]:
		interior.add_theme_constant_override("margin_" + lado, 18)
	_contenido = VBoxContainer.new()
	_contenido.add_theme_constant_override("separation", 10)
	interior.add_child(_contenido)
	_fondo.hide()
	_aviso = Label.new()
	add_child(_aviso)
	_aviso.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_aviso.offset_top = -148.0
	_aviso.offset_left = -300.0
	_aviso.offset_right = 300.0
	_aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_aviso.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_aviso.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_aviso.add_theme_font_size_override("font_size", 18)
	_aviso.add_theme_color_override("font_outline_color", Color("#24180f"))
	_aviso.add_theme_constant_override("outline_size", 8)
	_aviso.hide()


func avisar(mensaje: String) -> void:
	AudioJuego.sonido_interfaz("aviso")
	_aviso.text = mensaje
	_aviso.show()
	_fin_aviso = Time.get_ticks_msec() + 3500


func _process(_delta: float) -> void:
	if _aviso.visible and Time.get_ticks_msec() >= _fin_aviso:
		_aviso.hide()


func registrar_interaccion_mundo() -> void:
	_fotograma_interaccion = Engine.get_process_frames()


func interaccion_mundo_consumida() -> bool:
	# Input llega antes del procesamiento de los puntos que consultan just_pressed.
	return Engine.get_process_frames() - _fotograma_interaccion <= 1


func _input(evento: InputEvent) -> void:
	if not _fondo.visible:
		return
	if evento is InputEventJoypadMotion and evento.axis in [JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y]:
		var direccion := 0 if absf(evento.axis_value) < 0.55 else int(signf(evento.axis_value))
		if _eje_menu[evento.axis] != direccion and direccion != 0:
			var lados := [SIDE_LEFT, SIDE_RIGHT] if evento.axis == JOY_AXIS_LEFT_X else [SIDE_TOP, SIDE_BOTTOM]
			_mover_foco(lados[0 if direccion < 0 else 1])
		_eje_menu[evento.axis] = direccion
		get_viewport().set_input_as_handled()
		return
	if not evento is InputEventJoypadButton or not evento.pressed:
		return
	var foco := get_viewport().gui_get_focus_owner()
	match evento.button_index:
		JOY_BUTTON_B:
			cerrar()
		JOY_BUTTON_A:
			if foco is Button and not foco.disabled:
				foco.pressed.emit()
		JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_DOWN, JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_RIGHT:
			var lado: Side = {
				JOY_BUTTON_DPAD_UP: SIDE_TOP, JOY_BUTTON_DPAD_DOWN: SIDE_BOTTOM,
				JOY_BUTTON_DPAD_LEFT: SIDE_LEFT, JOY_BUTTON_DPAD_RIGHT: SIDE_RIGHT,
			}[evento.button_index]
			_mover_foco(lado)
		_:
			return
	get_viewport().set_input_as_handled()


func _mover_foco(lado: Side) -> void:
	var foco := get_viewport().gui_get_focus_owner()
	if foco:
		var destino := foco.find_valid_focus_neighbor(lado)
		if destino:
			destino.grab_focus()


func abrir_estacion(id: String, iniciar: Callable) -> void:
	if get_tree().paused or GestorRegiones.en_transicion:
		return
	_iniciar_oficio = iniciar
	abrir("estacion", id)


func _unhandled_input(evento: InputEvent) -> void:
	if _fondo.visible and (evento.is_action_pressed("abrir_inventario") or evento.is_action_pressed("ui_cancel")):
		cerrar()
		get_viewport().set_input_as_handled()
	elif not get_tree().paused and not GestorRegiones.en_transicion and evento.is_action_pressed("abrir_inventario"):
		if GestorRegiones.region_actual != &"":
			abrir("inventario")
			get_viewport().set_input_as_handled()


func abrir(tipo: String, id: String = "", cofre: Array = []) -> void:
	if get_tree().paused or GestorRegiones.en_transicion:
		return
	AudioJuego.sonido_interfaz("abrir")
	contexto = tipo
	almacen = cofre
	modo = id
	_mensaje = ""
	_foco = "inv0" if tipo not in ["oficios", "estacion"] else "cerrar"
	_eje_menu = Vector2i.ZERO
	_aviso.hide()
	get_tree().paused = true
	_fondo.show()
	_dibujar()


func cerrar() -> void:
	EstadoMundo.actividad_registrada.emit("mochila", "")
	_fondo.hide()
	get_tree().paused = false
	contexto = ""
	almacen = []
	_iniciar_oficio = Callable()


func _dibujar() -> void:
	for hijo in _contenido.get_children():
		_contenido.remove_child(hijo)
		hijo.queue_free()
	var cabecera := HBoxContainer.new()
	cabecera.add_theme_constant_override("separation", 12)
	_contenido.add_child(cabecera)
	var titulo_tienda: String = Comercio.NOMBRES.get(modo, "Tienda")
	var titulo := _texto(cabecera, {"inventario": "Mochila", "cofre": "Cofre", "tienda": titulo_tienda, "estacion": Oficios.OFICIOS.get(modo, ["Oficio"])[0], "oficios": "Oficios"}.get(contexto, "Mochila"), 25)
	titulo.autowrap_mode = TextServer.AUTOWRAP_OFF
	titulo.theme_type_variation = &"Titulo"
	titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var moneda := TextureRect.new()
	moneda.texture = Catalogo.textura(Catalogo.MONEDA)
	moneda.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	moneda.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	moneda.custom_minimum_size = Vector2(26, 26)
	moneda.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	cabecera.add_child(moneda)
	var saldo := _texto(cabecera, str(EstadoMundo.datos.monedas), 21)
	saldo.autowrap_mode = TextServer.AUTOWRAP_OFF
	saldo.add_theme_color_override("font_color", Color("#f9d68d"))
	_boton(cabecera, "Cerrar", "cerrar", cerrar)
	var fila := HBoxContainer.new()
	fila.size_flags_vertical = Control.SIZE_EXPAND_FILL
	fila.add_theme_constant_override("separation", 16)
	_contenido.add_child(fila)
	if contexto in ["estacion", "oficios"]:
		_dibujar_oficios(fila)
		_enfocar()
		return
	var lista := _columna(fila, "Vender desde la mochila" if contexto == "tienda" else "Mochila")
	_dibujar_casillas(lista, Bolsa.jugador(), false)
	if contexto == "cofre":
		_dibujar_casillas(_columna(fila, "Almacén"), almacen, true)
	elif contexto == "tienda":
		var productos := _columna(fila, "Comprar")
		for id in Comercio.TIENDAS[modo]:
			var ficha := Catalogo.ficha(id)
			_boton(productos, "%s · %d monedas · %d disp." % [ficha.nombre, ficha.compra, Comercio.stock(modo, id)],
				id, func(): _actualizar(Comercio.comprar(modo, id)), Catalogo.icono(id))
	else:
		var detalle := _columna(fila, "Objeto equipado")
		_boton(detalle, "Oficios y recetas", "oficios", _mostrar_oficios)
		var pila := Bolsa.seleccion()
		var ficha := Catalogo.ficha(pila.get("id", ""))
		if ficha.is_empty():
			_texto(detalle, "Elige una casilla para equipar un objeto.")
		else:
			_texto(detalle, "%s · %s" % [ficha.nombre, ficha.categoria], 20)
			_texto(detalle, ficha.descripcion)
			_boton(detalle, "Mover o combinar" if modo != "mover" else "Cancelar movimiento", "mover", _alternar.bind("mover"))
			_boton(detalle, "Dividir pila" if modo != "dividir" else "Cancelar división", "dividir", _alternar.bind("dividir"))
			_boton(detalle, "Dejar uno en el suelo", "soltar", _soltar)
	var ayuda := "Selecciona una casilla para equipar. Usa F/A junto a una parcela."
	if contexto == "cofre":
		ayuda = "Selecciona una pila para transferirla completa."
	elif contexto == "tienda":
		ayuda = "Selecciona un objeto de la mochila para vender una unidad."
	_texto(_contenido, _mensaje if not _mensaje.is_empty() else ayuda)
	_enfocar()


func _mostrar_oficios() -> void:
	contexto = "oficios"
	_foco = "volver"
	_dibujar()


func _dibujar_oficios(fila: HBoxContainer) -> void:
	if contexto == "oficios":
		var categorias := _columna(fila, "Profesiones")
		_boton(categorias, "Volver a la mochila", "volver", func():
			contexto = "inventario"
			_foco = "oficios"
			_dibujar())
		for oficio in Oficios.OFICIOS:
			_boton(categorias, "%s · Nivel %d" % [Oficios.OFICIOS[oficio][0], Oficios.nivel(oficio)],
				oficio, _consultar_oficio.bind(oficio))
	var lista := _columna(fila, "Experiencia y recetas")
	_texto(lista, "Flechas, stick o cruceta · Intro/A para confirmar · Esc/B para salir")
	var bolsa := Bolsa.jugador()
	for oficio in Oficios.OFICIOS:
		if oficio != (modo if contexto == "estacion" else _oficio_consultado):
			continue
		var ficha: Array = Oficios.OFICIOS[oficio]
		var exp_actual := Oficios.xp(oficio)
		_texto(lista, "%s · Nivel %d · %d EXP total" % [ficha[0], Oficios.nivel(oficio), exp_actual], 20)
		_texto(lista, ficha[1])
		var progreso := ProgressBar.new()
		progreso.max_value = Oficios.XP_POR_NIVEL
		progreso.value = exp_actual % Oficios.XP_POR_NIVEL
		progreso.show_percentage = false
		lista.add_child(progreso)
		_texto(lista, "%d/%d EXP para el siguiente nivel" % [int(progreso.value), Oficios.XP_POR_NIVEL])
		if oficio == "pesca":
			_texto(lista, "Río · Caña %d/1 · Pescado o carpa dorada, según la puntuación" % Bolsa.cantidad(bolsa, "cana"))
		for id in Oficios.RECETAS:
			var receta: Dictionary = Oficios.RECETAS[id]
			if receta.estacion != oficio:
				continue
			var materiales := PackedStringArray()
			for ingrediente in receta.ingredientes:
				materiales.append("%s %d/%d" % [Catalogo.ficha(ingrediente).nombre,
					Bolsa.cantidad(bolsa, ingrediente), receta.ingredientes[ingrediente]])
			var producto := "%d × %s · Nivel %d · +%d EXP" % [
				receta.cantidad, Catalogo.ficha(receta.producto).nombre, receta.nivel, receta.xp]
			var nombre: String = receta.get("nombre", Catalogo.ficha(receta.producto).nombre)
			_texto(lista, producto if not receta.has("nombre") else nombre + " · " + producto)
			_texto(lista, "Materiales en mochila · " + ", ".join(materiales))
			if contexto == "estacion":
				var error := Oficios.requisitos(id, oficio, bolsa.duplicate(true))
				var boton := _boton(lista, "Preparar " + nombre,
					id, _elegir_receta.bind(id), Catalogo.icono(receta.producto))
				boton.disabled = not error.is_empty()
				if not boton.disabled and _foco == "cerrar":
					_foco = id
				if boton.disabled:
					_texto(lista, error)


func _consultar_oficio(id: String) -> void:
	_oficio_consultado = id
	_dibujar()


func _elegir_receta(id: String) -> void:
	var iniciar := _iniciar_oficio
	cerrar()
	iniciar.call(id)


func _enfocar() -> void:
	var enfocar := _contenido.find_child(_foco, true, false) as Button
	if enfocar:
		enfocar.grab_focus()


func _actualizar(mensaje: String = "") -> void:
	_mensaje = mensaje
	_dibujar()


func _alternar(accion: String) -> void:
	modo = "" if modo == accion else accion
	_actualizar("Elige una casilla de destino." if not modo.is_empty() else "")


func _dibujar_casillas(lista: VBoxContainer, casillas: Array, es_cofre: bool) -> void:
	var seleccionado := int(EstadoMundo.objeto("@jugador", "bolsa").get("seleccion", -1))
	for i in casillas.size():
		var pila: Variant = casillas[i]
		var titulo := "Casilla %d · vacía" % (i + 1)
		var icono: Texture2D
		if pila is Dictionary:
			titulo = "%s × %d" % [Catalogo.ficha(pila.id).nombre, pila.cantidad]
			icono = Catalogo.icono(pila.id)
			if not es_cofre and contexto == "inventario" and i == seleccionado:
				titulo += "  • equipada"
			if contexto == "tienda":
				titulo += "  ·  %d monedas" % int(Catalogo.ficha(pila.id).venta)
		var nombre := ("cofre" if es_cofre else "inv") + str(i)
		_boton(lista, titulo, nombre, _usar_casilla.bind(i, es_cofre), icono)


func _usar_casilla(indice: int, es_cofre: bool) -> void:
	match contexto:
		"cofre":
			var origen := almacen if es_cofre else Bolsa.jugador()
			var destino := Bolsa.jugador() if es_cofre else almacen
			var pila: Variant = origen[indice]
			if pila is Dictionary:
				_actualizar("Transferido." if Bolsa.transferir(origen, indice, destino, pila.cantidad) else "No hay espacio para la pila.")
		"tienda":
			_actualizar(Comercio.vender(indice))
		_:
			if not modo.is_empty():
				var anterior := int(EstadoMundo.objeto("@jugador", "bolsa").get("seleccion", -1))
				if modo == "dividir" and (Bolsa.jugador()[indice] != null or int(Bolsa.seleccion().get("cantidad", 0)) < 2):
					_actualizar("Elige una casilla vacía y una pila de al menos dos.")
					return
				var exito := Bolsa.mover(Bolsa.jugador(), anterior, indice, modo == "dividir")
				modo = ""
				if exito:
					Bolsa.elegir(indice)
				_actualizar("Casillas actualizadas." if exito else "No se pudo mover la pila.")
			else:
				Bolsa.elegir(indice)
				_actualizar()


func _soltar() -> void:
	var escena := get_tree().current_scene
	var puntos := escena.get_node_or_null("Region/ActividadesVida") if escena else null
	if puntos and puntos.soltar():
		_actualizar("Dejaste un objeto en el suelo.")
	else:
		_actualizar("Aquí no puedes dejar el objeto.")


func _columna(padre: Control, titulo: String) -> VBoxContainer:
	var fuera := VBoxContainer.new()
	fuera.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	padre.add_child(fuera)
	_texto(fuera, titulo, 18)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	fuera.add_child(scroll)
	var lista := VBoxContainer.new()
	lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(lista)
	return lista


func _texto(padre: Control, valor: String, tamano: int = 16) -> Label:
	var etiqueta := Label.new()
	etiqueta.text = valor
	etiqueta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tamano += int(Ajustes.valores.texto) - 20
	etiqueta.add_theme_font_size_override("font_size", tamano)
	padre.add_child(etiqueta)
	return etiqueta


func _boton(padre: Control, texto: String, id: String, accion: Callable, icono: Texture2D = null) -> Button:
	var boton := Button.new()
	boton.name = id
	boton.text = texto
	boton.icon = icono
	boton.expand_icon = true
	boton.alignment = HORIZONTAL_ALIGNMENT_LEFT
	boton.custom_minimum_size.y = 32
	boton.add_theme_constant_override("icon_max_width", 24)
	var textura := Catalogo.textura(BORDE)
	if textura:
		var foco := StyleBoxTexture.new()
		foco.texture = textura
		foco.draw_center = false
		for lado in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
			foco.set_texture_margin(lado, 4)
		boton.add_theme_stylebox_override("focus", foco)
	boton.pressed.connect(func():
		_foco = id
		accion.call())
	padre.add_child(boton)
	return boton
