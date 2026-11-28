extends PanelContainer

const Estilo = preload("res://scripts/presentacion/estilo.gd")
const Teclado = preload("res://scripts/presentacion/teclado_virtual.gd")
signal cerrado
var seccion_inicial := "Gráficos"

var _contenido: VBoxContainer
var _pestanas: HBoxContainer
var _captura := ""
var _mensaje: Label
var _pantalla_anterior: Dictionary = {}
var _restante := 0.0
var _temporizador: Label
var _confirmacion_pantalla: HBoxContainer

func _ready() -> void:
	var pila := VBoxContainer.new()
	add_child(pila)
	pila.add_child(Estilo.titulo("Opciones"))
	_pestanas = HBoxContainer.new()
	pila.add_child(_pestanas)
	var grupo := ButtonGroup.new()
	for nombre in ["Gráficos", "Audio", "Controles", "Interfaz", "Accesibilidad", "IA"]:
		var boton := Estilo.boton(nombre, _seccion.bind(nombre))
		boton.toggle_mode = true
		boton.button_group = grupo
		_pestanas.add_child(boton)
	var scroll := ScrollContainer.new()
	scroll.follow_focus = true
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	pila.add_child(scroll)
	_contenido = VBoxContainer.new()
	_contenido.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_contenido)
	_mensaje = Estilo.texto("")
	pila.add_child(_mensaje)
	var nav := HBoxContainer.new()
	pila.add_child(nav)
	nav.add_child(Estilo.boton("Restaurar valores", func():
		Estilo.confirmar(self, "¿Restaurar los ajustes de presentación y controles?", func():
			Ajustes.restaurar()
			_seccion("Gráficos"))))
	var volver := Estilo.boton("Volver", _cerrar)
	nav.add_child(volver)
	_seccion(seccion_inicial)
	for boton in _pestanas.get_children():
		if boton.text == seccion_inicial:
			boton.grab_focus()

func _cerrar() -> void:
	_revertir_pantalla()
	cerrado.emit()
	queue_free()

func _input(evento: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if not _captura.is_empty():
		if evento.is_action_pressed("ui_cancel"):
			_mensaje.text = "Reasignación cancelada."
		elif _evento_reasignable(evento):
			if evento is InputEventJoypadMotion:
				var eje := evento.duplicate() as InputEventJoypadMotion
				eje.axis_value = signf(eje.axis_value)
				evento = eje
			var error := Ajustes.reasignar(_captura, evento)
			_seccion("Controles")
			_mensaje.text = "Control guardado." if error.is_empty() else error
		else:
			return
		_captura = ""
		get_viewport().set_input_as_handled()
	elif evento.is_action_pressed("ui_cancel") and get_viewport().gui_get_focus_owner() != null:
		if not is_ancestor_of(get_viewport().gui_get_focus_owner()):
			return
		get_viewport().set_input_as_handled()
		_cerrar()

func _evento_reasignable(evento: InputEvent) -> bool:
	return (evento is InputEventKey and evento.pressed and not evento.echo
		or evento is InputEventJoypadButton and evento.pressed
		or evento is InputEventJoypadMotion and absf(evento.axis_value) >= 0.8)

func _seccion(nombre: String) -> void:
	_revertir_pantalla()
	_mensaje.text = ""
	for hijo in _contenido.get_children():
		_contenido.remove_child(hijo)
		hijo.queue_free()
	for boton in _pestanas.get_children():
		boton.set_pressed_no_signal(boton.text == nombre)
	_contenido.add_child(Estilo.titulo(nombre, 23))
	match nombre:
		"Gráficos":
			_lista("Modo de pantalla", "modo", ["Ventana", "Pantalla completa", "Sin bordes"], [0, 1, 2], true)
			var resoluciones: Array = []
			var textos: Array = []
			var limite := DisplayServer.screen_get_usable_rect().size
			for tamano in Ajustes.RESOLUCIONES:
				if DisplayServer.get_name() == "headless" or (tamano.x <= limite.x and tamano.y <= limite.y):
					resoluciones.append(tamano)
					textos.append("%d × %d" % [tamano.x, tamano.y])
			if not resoluciones.is_empty():
				_lista("Resolución", "resolucion", textos, resoluciones, true)
			_lista("Antialiasing 3D", "calidad", ["Bajo", "Medio", "Alto"], [0, 1, 2])
			_lista("Sombras", "sombras", ["Bajas", "Medias", "Altas"], [0, 1, 2])
			_check("Sincronización vertical", "vsync")
			_lista("Límite de FPS", "fps", ["30", "60", "120", "Sin límite"], [30, 60, 120, 0])
			_slider("Escala de interfaz", "escala", 0.8, 1.3, 0.1)
		"Audio":
			_check("Silenciar audio", "silencio")
			for i in Ajustes.BUS.size():
				_slider("General" if i == 0 else Ajustes.BUS[i], "volumen", 0, 1, 0.05, i)
		"Controles":
			_lista("Velocidad del protagonista", "velocidad", ["Lenta", "Normal", "Rápida"], ["tranquila", "normal", "rapida"])
			_contenido.add_child(Estilo.texto("Ratón: selecciona en los menús. Mando: cruceta o stick para navegar, A para aceptar, B para volver."))
			_slider("Sensibilidad de cámara", "camara", 0.4, 2.0, 0.1)
			_check("Invertir giro de cámara", "invertir")
			for id in Ajustes.predeterminados:
				var entradas := PackedStringArray()
				for evento in InputMap.action_get_events(id):
					entradas.append(Ajustes.nombre_entrada(evento))
				var etiqueta: String = Ajustes.ACCIONES[id] + " · " + " / ".join(entradas)
				_contenido.add_child(Estilo.boton(etiqueta, func():
					_captura = id
					_mensaje.text = "Pulsa una tecla, un botón o mueve un stick. Esc o B cancela."))
		"Interfaz":
			_check("Mostrar barra rápida", "barra")
			_slider("Escala de interfaz", "escala", 0.8, 1.3, 0.1)
			_check("Texto instantáneo", "instantaneo")
		"Accesibilidad":
			_slider("Tamaño de texto", "texto", 16, 28, 1)
			_check("Contraste mejorado", "contraste")
			_slider("Velocidad de diálogo", "dialogo", 0.5, 2.0, 0.25)
			_check("Texto instantáneo", "instantaneo")
			_check("Reducir movimiento cinematográfico", "movimiento")
		"IA":
			_construir_ia()

func _fila(etiqueta: String) -> HBoxContainer:
	var fila := HBoxContainer.new()
	var rotulo := Estilo.texto(etiqueta)
	rotulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila.add_child(rotulo)
	_contenido.add_child(fila)
	return fila

func _lista(etiqueta: String, id: String, items: Array, valores: Array, pantalla: bool = false) -> void:
	var lista := OptionButton.new()
	for item in items:
		lista.add_item(item)
	lista.select(maxi(valores.find(Ajustes.valores[id]), 0))
	_fila(etiqueta).add_child(lista)
	lista.item_selected.connect(func(indice):
		if pantalla:
			_probar_pantalla(id, valores[indice])
		else:
			_cambiar(id, valores[indice]))

func _check(etiqueta: String, id: String) -> void:
	var control := CheckButton.new()
	control.button_pressed = Ajustes.valores[id]
	_fila(etiqueta).add_child(control)
	control.toggled.connect(func(valor): _cambiar(id, valor))

func _slider(etiqueta: String, id: String, minimo: float, maximo: float, paso: float, indice: int = -1) -> void:
	var fila := _fila(etiqueta)
	var valor := Label.new()
	var control := HSlider.new()
	control.focus_mode = Control.FOCUS_ALL
	control.custom_minimum_size.x = 150
	control.min_value = minimo
	control.max_value = maximo
	control.step = paso
	control.value = Ajustes.valores[id] if indice < 0 else Ajustes.valores[id][indice]
	valor.text = str(control.value)
	fila.add_child(control)
	fila.add_child(valor)
	control.value_changed.connect(func(nuevo):
		valor.text = str(nuevo)
		if indice < 0:
			_cambiar(id, int(nuevo) if Ajustes.BASE[id] is int else nuevo)
		else:
			Ajustes.valores[id][indice] = nuevo
			Ajustes.aplicar()
			if _pantalla_anterior.is_empty():
				Ajustes.guardar())

func _cambiar(id: String, valor: Variant) -> void:
	Ajustes.valores[id] = valor
	Ajustes.aplicar()
	if _pantalla_anterior.is_empty():
		Ajustes.guardar()

func _probar_pantalla(id: String, valor: Variant) -> void:
	_revertir_pantalla()
	_pantalla_anterior = {"modo": Ajustes.valores.modo, "resolucion": Ajustes.valores.resolucion}
	Ajustes.valores[id] = valor
	Ajustes.aplicar_pantalla()
	_restante = 12.0
	if is_instance_valid(_confirmacion_pantalla):
		_confirmacion_pantalla.queue_free()
	_confirmacion_pantalla = HBoxContainer.new()
	_contenido.add_child(_confirmacion_pantalla)
	_temporizador = Estilo.texto("")
	_temporizador.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_confirmacion_pantalla.add_child(_temporizador)
	var boton := Estilo.boton("Conservar cambios", _confirmar_pantalla)
	_confirmacion_pantalla.add_child(boton)
	boton.grab_focus()

func _process(delta: float) -> void:
	if not _pantalla_anterior.is_empty():
		_restante -= delta
		_temporizador.text = "Se restaura en %d s." % ceili(_restante)
		if _restante <= 0:
			_seccion("Gráficos")
			(_pestanas.get_child(0) as Button).grab_focus()

func _confirmar_pantalla() -> void:
	_pantalla_anterior.clear()
	Ajustes.guardar()
	_seccion("Gráficos")
	(_pestanas.get_child(0) as Button).grab_focus()

func _revertir_pantalla() -> void:
	if _pantalla_anterior.is_empty():
		return
	Ajustes.valores.merge(_pantalla_anterior, true)
	_pantalla_anterior.clear()
	Ajustes.aplicar_pantalla()

func _construir_ia() -> void:
	var activa := CheckButton.new()
	activa.button_pressed = IA.activa
	_fila("Modo online").add_child(activa)
	_contenido.add_child(Estilo.texto("El modo local usa conversaciones disponibles sin conexión. Las consultas online pueden consumir créditos."))
	var clave := _campo("Clave de OpenRouter", IA.clave, true)
	var modelo := _campo("Modelo", IA.modelo, false)
	var limite := HSlider.new()
	limite.focus_mode = Control.FOCUS_ALL
	limite.custom_minimum_size.x = 160
	limite.min_value = 10
	limite.max_value = 5000
	limite.step = 10
	limite.value = IA.tope_tokens / 1000
	var fila := _fila("Límite por sesión (miles de tokens)")
	fila.add_child(limite)
	var cantidad := Estilo.texto(str(int(limite.value)))
	fila.add_child(cantidad)
	limite.value_changed.connect(func(valor): cantidad.text = str(int(valor)))
	_contenido.add_child(Estilo.boton("Guardar configuración de IA", func():
		IA.activa = activa.button_pressed
		IA.clave = clave.text.strip_edges()
		IA.modelo = modelo.text.strip_edges() if not modelo.text.strip_edges().is_empty() else IA.MODELO_POR_DEFECTO
		IA.tope_tokens = int(limite.value) * 1000
		IA.guardar_config()
		_mensaje.text = "Configuración guardada."))

func _campo(etiqueta: String, valor: String, secreto: bool) -> LineEdit:
	var fila := _fila(etiqueta)
	var campo := LineEdit.new()
	campo.text = valor
	campo.secret = secreto
	campo.custom_minimum_size.x = 190
	fila.add_child(campo)
	fila.add_child(Estilo.boton("Teclado", Teclado.mostrar.bind(campo)))
	return campo
