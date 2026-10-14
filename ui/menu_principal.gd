extends Control

const SELECCION_PARTIDAS := "res://ui/seleccion_partidas.tscn"

@export var modo_pausa := false
@export_range(1.0, 30.0, 0.5) var duracion_introduccion := 7.0

@onready var botones: VBoxContainer = $"Centro Menu/Margen Interior/Botones Menu"
@onready var modal: ColorRect = $"Ventanas Menu"
@onready var contenido: VBoxContainer = $"Ventanas Menu/Centro Ventana/Panel Ventana/Margen Interior/Contenido Ventana"
@onready var mensaje: Label = $"Estado Partida"

var boton_anterior: Control
var ventana_actual := ""
@onready var estado_guardado: Label = contenido.get_node("Configuracion/Estado Ajustes")
var introduccion_activa := false
var mostrando_menu := false
var progreso_introduccion := 0.0
var animacion_introduccion: Tween
var animacion_menu: Tween


func _ready() -> void:
	for ventana in contenido.get_children():
		ventana.get_node("Boton Volver").pressed.connect(_cerrar_modal)
	var configuracion := contenido.get_node("Configuracion")
	var filas := {"general": "Volumen General", "musica": "Volumen Musica", "efectos": "Volumen Efectos"}
	for clave in filas:
		var fila: HBoxContainer = configuracion.get_node(filas[clave])
		var deslizador: HSlider = fila.get_node("Deslizador Volumen")
		var porcentaje: Label = fila.get_node("Porcentaje Volumen")
		deslizador.value_changed.connect(func(valor: float) -> void:
			Ajustes.establecer_volumen(clave, valor)
			porcentaje.text = "%d%%" % valor
		)
	configuracion.get_node("Opciones Generales/Silenciar Audio").toggled.connect(Ajustes.establecer_silencio)
	configuracion.get_node("Opciones Generales/Pantalla Completa").toggled.connect(Ajustes.establecer_pantalla_completa)
	_boton_menu("Jugar").pressed.connect(_jugar)
	_boton_menu("Configuracion").pressed.connect(_configuracion)
	_boton_menu("Controles").pressed.connect(_controles)
	_boton_menu("Creditos").pressed.connect(_creditos)
	_boton_menu("Salir").pressed.connect(_salir)
	_boton_menu("GuardarPartida").pressed.connect(_guardar_partida)
	_boton_menu("GuardarPartida").visible = modo_pausa
	if modo_pausa:
		$Fondo.hide()
		$"Sombra Pantalla".show()
		_boton_menu("Jugar").get_node("Texto Boton").text = "Continuar"
		_boton_menu("Jugar").get_node("Texto Boton").offset_left = 0.0
		_boton_menu("Jugar").get_node("Icono Jugar").hide()
		_boton_menu("Salir").call("usar_frames", "inicio")
		_boton_menu("Salir").get_parent().get_node("Etiqueta Boton").text = "MENU"
		$"Ayuda Introduccion".hide()
		_boton_menu("Jugar").grab_focus()
		return
	resized.connect(_ajustar_imagen_introduccion)
	if Ajustes.introduccion_vista:
		progreso_introduccion = 1.0
		_ajustar_imagen_introduccion()
		$"Ayuda Introduccion".hide()
		_boton_menu("Jugar").grab_focus()
	else:
		_iniciar_introduccion()


func _boton_menu(nombre: String) -> BaseButton:
	return botones.find_child("Boton " + nombre.replace("GuardarPartida", "Guardar Partida"), true, false) as BaseButton


func _opciones_menu() -> Array[BaseButton]:
	var opciones: Array[BaseButton] = []
	for nodo in botones.find_children("*", "BaseButton", true, false):
		opciones.append(nodo as BaseButton)
	return opciones


func _iniciar_introduccion() -> void:
	introduccion_activa = true
	$"Centro Menu".hide()
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
	var imagen: TextureRect = $"Fondo/Imagen Granja"
	var alto := maxf(size.y, size.x * imagen.texture.get_height() / float(imagen.texture.get_width()))
	imagen.size = Vector2(size.x, alto)
	imagen.position = Vector2(0, -(alto - size.y) * progreso_introduccion)


func _mostrar_menu() -> void:
	if mostrando_menu:
		return
	mostrando_menu = true
	_actualizar_introduccion(1.0)
	$"Ayuda Introduccion".hide()
	animacion_menu = create_tween().set_parallel(true)
	for nodo in [$"Centro Menu"]:
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
		_cambiar_escena(SELECCION_PARTIDAS)


func _guardar_partida() -> void:
	var resultado := Partidas.guardar_actual()
	if resultado == OK:
		mensaje.text = "PARTIDA %d GUARDADA." % Partidas.espacio_activo
	elif resultado == ERR_UNCONFIGURED:
		mensaje.text = "ABRE UNA PARTIDA DESDE JUGAR PARA PODER GUARDARLA."
	elif resultado == ERR_UNAVAILABLE:
		mensaje.text = "NO PUEDES GUARDAR SIN UN PERSONAJE CON VIDA."
	else:
		mensaje.text = "NO SE PUDO GUARDAR LA PARTIDA. INTENTA DE NUEVO."


func _cambiar_escena(ruta: String) -> void:
	var resultado := Ajustes.cambiar_escena(ruta)
	if resultado != OK:
		mensaje.text = "NO SE PUDO ABRIR LA ESCENA. ERROR: %s" % resultado
		_boton_menu("Jugar").grab_focus()


func _abrir_modal(ventana: String) -> void:
	boton_anterior = get_viewport().gui_get_focus_owner()
	ventana_actual = ventana
	for panel in contenido.get_children():
		panel.visible = panel.name == ventana
	# El teclado queda dentro de la ventana, sin activar botones del fondo.
	for boton in _opciones_menu():
		boton.focus_mode = Control.FOCUS_NONE
	modal.show()


func _cerrar_modal() -> void:
	if ventana_actual == "Configuracion":
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
	var configuracion := contenido.get_node("Configuracion")
	var filas := {"general": "Volumen General", "musica": "Volumen Musica", "efectos": "Volumen Efectos"}
	for clave in filas:
		var fila := configuracion.get_node(filas[clave])
		fila.get_node("Deslizador Volumen").set_value_no_signal(Ajustes.volumenes[clave])
		fila.get_node("Porcentaje Volumen").text = "%d%%" % Ajustes.volumenes[clave]
	configuracion.get_node("Opciones Generales/Silenciar Audio").set_pressed_no_signal(Ajustes.silenciado)
	configuracion.get_node("Opciones Generales/Pantalla Completa").set_pressed_no_signal(Ajustes.pantalla_completa)
	estado_guardado.text = "Los cambios se aplican al instante."
	_abrir_modal("Configuracion")
	configuracion.get_node("Volumen General/Deslizador Volumen").grab_focus()


func _controles() -> void:
	_abrir_modal("Controles")
	contenido.get_node("Controles/Boton Volver").grab_focus()


func _creditos() -> void:
	_abrir_modal("Creditos")
	contenido.get_node("Creditos/Boton Volver").grab_focus()


func _salir() -> void:
	if modo_pausa:
		# Volver directamente al menú también al probar el nivel con F6.
		Ajustes.introduccion_vista = true
		_cambiar_escena(Ajustes.MENU)
	else:
		get_tree().quit()
