extends Control

const MUNDO := "res://niveles/mundo.tscn"
const RECURSOS_UI := preload("res://ui/recursos_ui.gd")

@export var modo_pausa := false
@export_range(1.0, 30.0, 0.5) var duracion_introduccion := 7.0

@onready var botones: VBoxContainer = $Panel/Margen/Opciones
@onready var modal: ColorRect = $Modal
@onready var contenido: VBoxContainer = $Modal/Centro/Ventana/Margen/Contenido
@onready var mensaje: Label = $Mensaje

var boton_anterior: Control
var ventana_actual := ""
var estado_guardado: Label
var introduccion_activa := false
var mostrando_menu := false
var progreso_introduccion := 0.0
var animacion_introduccion: Tween
var animacion_menu: Tween


func _ready() -> void:
	_boton_menu("Jugar").pressed.connect(_jugar)
	_boton_menu("Configuracion").pressed.connect(_configuracion)
	_boton_menu("Controles").pressed.connect(_controles)
	_boton_menu("Creditos").pressed.connect(_creditos)
	_boton_menu("Salir").pressed.connect(_salir)
	if modo_pausa:
		$Fondo.hide()
		$Oscurecer.show()
		_boton_menu("Jugar").get_node("Texto").text = "Continuar"
		_boton_menu("Jugar").get_node("Texto").offset_left = 0.0
		_boton_menu("Jugar").get_node("IconoJugar").hide()
		_boton_menu("Salir").call("usar_frames", "inicio")
		_boton_menu("Salir").get_parent().get_node("Nombre").text = "MENU"
		$AyudaIntroduccion.hide()
		_boton_menu("Jugar").grab_focus()
		return
	resized.connect(_ajustar_imagen_introduccion)
	if Ajustes.introduccion_vista:
		progreso_introduccion = 1.0
		_ajustar_imagen_introduccion()
		$AyudaIntroduccion.hide()
		_boton_menu("Jugar").grab_focus()
	else:
		_iniciar_introduccion()


func _boton_menu(nombre: String) -> BaseButton:
	return botones.find_child(nombre, true, false) as BaseButton


func _opciones_menu() -> Array[BaseButton]:
	var opciones: Array[BaseButton] = []
	for nodo in botones.find_children("*", "BaseButton", true, false):
		opciones.append(nodo as BaseButton)
	return opciones


func _iniciar_introduccion() -> void:
	introduccion_activa = true
	$Panel.hide()
	for boton in _opciones_menu():
		boton.disabled = true
	_ajustar_imagen_introduccion()
	animacion_introduccion = create_tween()
	animacion_introduccion.tween_interval(0.5)
	animacion_introduccion.tween_method(_actualizar_introduccion, 0.0, 1.0, duracion_introduccion).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	animacion_introduccion.tween_callback(_mostrar_menu)


func _actualizar_introduccion(progreso: float) -> void:
	progreso_introduccion = progreso
	_ajustar_imagen_introduccion()


func _ajustar_imagen_introduccion() -> void:
	var imagen: TextureRect = $Fondo/Imagen
	var alto := maxf(size.y, size.x * imagen.texture.get_height() / float(imagen.texture.get_width()))
	imagen.size = Vector2(size.x, alto)
	imagen.position = Vector2(0, -(alto - size.y) * progreso_introduccion)


func _mostrar_menu() -> void:
	if mostrando_menu:
		return
	mostrando_menu = true
	_actualizar_introduccion(1.0)
	$AyudaIntroduccion.hide()
	animacion_menu = create_tween().set_parallel(true)
	for nodo in [$Panel]:
		nodo.modulate.a = 0.0
		nodo.show()
		animacion_menu.tween_property(nodo, "modulate:a", 1.0, 0.65)
	animacion_menu.chain().tween_callback(_habilitar_menu)


func _habilitar_menu() -> void:
	introduccion_activa = false
	Ajustes.introduccion_vista = true
	for boton in _opciones_menu():
		boton.disabled = false
	_boton_menu("Jugar").grab_focus()


func _input(event: InputEvent) -> void:
	if not introduccion_activa:
		return
	var clic: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	if clic or event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if not mostrando_menu:
			animacion_introduccion.kill()
			_mostrar_menu()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		get_viewport().set_input_as_handled()
		if modal.visible:
			_cerrar_modal()
		elif modo_pausa:
			Ajustes.reanudar()


func _jugar() -> void:
	if modo_pausa:
		Ajustes.reanudar()
	else:
		_cambiar_escena(MUNDO)


func _cambiar_escena(ruta: String) -> void:
	var resultado := Ajustes.cambiar_escena(ruta)
	if resultado != OK:
		mensaje.text = "No se pudo abrir la escena. Error: %s" % resultado
		_boton_menu("Jugar").grab_focus()


func _abrir_modal(titulo: String, ventana: String) -> void:
	boton_anterior = get_viewport().gui_get_focus_owner()
	ventana_actual = ventana
	for hijo in contenido.get_children():
		contenido.remove_child(hijo)
		hijo.queue_free()
	# El teclado queda dentro de la ventana, sin activar botones del fondo.
	for boton in _opciones_menu():
		boton.focus_mode = Control.FOCUS_NONE
	modal.show()
	var encabezado := _etiqueta(titulo, 22)
	encabezado.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	contenido.add_child(encabezado)
	contenido.add_child(HSeparator.new())


func _etiqueta(texto: String, tamano: int = 14) -> Label:
	var etiqueta := Label.new()
	etiqueta.text = texto
	etiqueta.add_theme_font_size_override("font_size", tamano)
	return etiqueta


func _boton(texto: String, accion: Callable, icono: String = "") -> Button:
	var boton := Button.new()
	boton.text = texto
	boton.custom_minimum_size.y = 32
	if not icono.is_empty():
		boton.icon = RECURSOS_UI.icono(icono)
		boton.expand_icon = true
	boton.pressed.connect(accion)
	contenido.add_child(boton)
	return boton


func _cerrar_modal() -> void:
	if ventana_actual == "configuracion":
		if Ajustes.guardar() != OK:
			estado_guardado.text = "No se pudieron guardar los ajustes. Intenta de nuevo."
			return
	modal.hide()
	ventana_actual = ""
	for boton in _opciones_menu():
		boton.focus_mode = Control.FOCUS_ALL
	if is_instance_valid(boton_anterior):
		boton_anterior.grab_focus()


func _configuracion() -> void:
	_abrir_modal("Configuración", "configuracion")
	var primer_control: HSlider
	for clave in ["general", "musica", "efectos"]:
		var fila := HBoxContainer.new()
		var nombres := {"general": "Volumen general", "musica": "Música", "efectos": "Efectos"}
		var etiqueta := _etiqueta(nombres[clave])
		etiqueta.custom_minimum_size.x = 130
		fila.add_child(etiqueta)
		var deslizador := HSlider.new()
		deslizador.custom_minimum_size = Vector2(150, 24)
		deslizador.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		deslizador.max_value = 100
		deslizador.step = 1
		deslizador.value = Ajustes.volumenes[clave]
		fila.add_child(deslizador)
		var porcentaje := _etiqueta("%d%%" % deslizador.value)
		porcentaje.custom_minimum_size.x = 42
		porcentaje.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		fila.add_child(porcentaje)
		deslizador.value_changed.connect(func(valor: float) -> void:
			Ajustes.establecer_volumen(clave, valor)
			porcentaje.text = "%d%%" % valor
		)
		contenido.add_child(fila)
		if primer_control == null:
			primer_control = deslizador
	var silencio := CheckButton.new()
	silencio.text = "Silenciar todo el audio"
	silencio.button_pressed = Ajustes.silenciado
	silencio.toggled.connect(Ajustes.establecer_silencio)
	contenido.add_child(silencio)
	var pantalla := CheckButton.new()
	pantalla.text = "Pantalla completa"
	pantalla.button_pressed = Ajustes.pantalla_completa
	pantalla.toggled.connect(Ajustes.establecer_pantalla_completa)
	contenido.add_child(pantalla)
	estado_guardado = _etiqueta("Los cambios se aplican al instante.", 12)
	contenido.add_child(estado_guardado)
	_boton("Guardar y volver", _cerrar_modal, "volver")
	primer_control.grab_focus()


func _controles() -> void:
	_abrir_modal("Controles", "controles")
	var filas := [
		["Moverse", "W A S D / Flechas"],
		["Saltar", "Espacio / Enter"],
		["Apuntar", "Mover el ratón"],
		["Ataque normal", "Clic izquierdo"],
		["Ataque cargado", "Mantener clic derecho"],
		["Pausar / Volver", "Escape"],
	]
	var tabla := GridContainer.new()
	tabla.columns = 2
	tabla.add_theme_constant_override("h_separation", 28)
	tabla.add_theme_constant_override("v_separation", 9)
	for fila in filas:
		for texto in fila:
			tabla.add_child(_etiqueta(texto))
	contenido.add_child(tabla)
	contenido.add_child(_etiqueta("Menús: ratón o flechas y Enter.", 12))
	_boton("Volver", _cerrar_modal, "volver").grab_focus()


func _creditos() -> void:
	_abrir_modal("Equipo Sixglitch", "creditos")
	var texto := _etiqueta("Javiera Maluenda · Jorge Muñoz\nPriscilla Álvarez · Constanza Araya\nÁngel Guerrero · Renato Martínez\n\nBeastBound", 15)
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	contenido.add_child(texto)
	_boton("Volver", _cerrar_modal, "volver").grab_focus()


func _salir() -> void:
	if modo_pausa:
		# Volver directamente al menú también al probar el nivel con F6.
		Ajustes.introduccion_vista = true
		_cambiar_escena(Ajustes.MENU)
	else:
		get_tree().quit()
