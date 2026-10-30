extends Node

const MENU := "res://ui/menu_principal.tscn"
const ARCHIVO := "user://ajustes.cfg"
const BUSES := {"general": "Master", "musica": "Musica", "efectos": "Efectos"}

var volumenes: Dictionary = {"general": 80.0, "musica": 80.0, "efectos": 80.0}
var silenciado := false
var pantalla_completa := true
var modo_pantalla := "completa"
var teclas: Dictionary = {}
const ACCIONES_EDITABLES := ["p1_arriba", "p1_abajo", "p1_izquierda", "p1_derecha", "p1_salto", "p1_ataque_normal", "p1_ataque_cargado"]
var introduccion_vista := false
var capa_pausa: CanvasLayer

var jugadores_seleccionados: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for nombre in ["Musica", "Efectos"]:
		if AudioServer.get_bus_index(nombre) == -1:
			AudioServer.add_bus()
			var indice := AudioServer.bus_count - 1
			AudioServer.set_bus_name(indice, nombre)
			AudioServer.set_bus_send(indice, "Master")
	var config := ConfigFile.new()
	if config.load(ARCHIVO) == OK:
		for clave in volumenes:
			volumenes[clave] = clampf(float(config.get_value("audio", clave, 80.0)), 0.0, 100.0)
		silenciado = bool(config.get_value("audio", "silenciado", false))
		pantalla_completa = bool(config.get_value("pantalla", "completa", true))
		modo_pantalla = str(config.get_value("pantalla", "modo", "completa" if pantalla_completa else "ventana"))
		if modo_pantalla not in ["completa", "ventana", "sin_bordes"]:
			modo_pantalla = "completa"
		pantalla_completa = modo_pantalla == "completa"
		for accion in ACCIONES_EDITABLES:
			if config.has_section_key("controles", accion):
				var entrada = config.get_value("controles", accion)
				if entrada is InputEventKey or entrada is InputEventMouseButton:
					asignar_control(accion, entrada)
	_aplicar_audio()
	_aplicar_pantalla()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		var escena := get_tree().current_scene
		if escena != null and escena.scene_file_path not in [MENU, "res://ui/seleccion_partidas.tscn", "res://ui/carga.tscn"] and capa_pausa == null:
			get_viewport().set_input_as_handled()
			_pausar()

func _pausar() -> void:
	capa_pausa = CanvasLayer.new()
	capa_pausa.name = "Interfaz Pausa"
	capa_pausa.layer = 100
	capa_pausa.process_mode = Node.PROCESS_MODE_ALWAYS
	var menu: Control = load(MENU).instantiate()
	menu.modo_pausa = true
	get_tree().paused = true
	add_child(capa_pausa)
	capa_pausa.add_child(menu)

func reanudar() -> void:
	if is_instance_valid(capa_pausa):
		capa_pausa.queue_free()
	capa_pausa = null
	get_tree().paused = false

func cambiar_escena(ruta: String) -> Error:
	var resultado := get_tree().change_scene_to_file(ruta)
	if resultado == OK:
		reanudar()
	return resultado

func establecer_volumen(clave: String, valor: float) -> void:
	volumenes[clave] = clampf(valor, 0.0, 100.0)
	_aplicar_audio()

func establecer_silencio(valor: bool) -> void:
	silenciado = valor
	_aplicar_audio()

func establecer_pantalla_completa(valor: bool) -> void:
	establecer_modo_pantalla("completa" if valor else "ventana")

func establecer_modo_pantalla(modo: String) -> void:
	if modo not in ["completa", "ventana", "sin_bordes"]:
		return
	modo_pantalla = modo
	pantalla_completa = modo == "completa"
	_aplicar_pantalla()

func asignar_control(accion: String, entrada: InputEvent) -> void:
	if accion not in ACCIONES_EDITABLES or not (entrada is InputEventKey or entrada is InputEventMouseButton):
		return
	for anterior in InputMap.action_get_events(accion):
		if anterior is InputEventKey or anterior is InputEventMouseButton:
			InputMap.action_erase_event(accion, anterior)
	InputMap.action_add_event(accion, entrada)
	teclas[accion] = entrada

func _aplicar_audio() -> void:
	for clave in BUSES:
		var indice := AudioServer.get_bus_index(BUSES[clave])
		AudioServer.set_bus_volume_db(indice, linear_to_db(maxf(float(volumenes[clave]) / 100.0, 0.0001)))
		AudioServer.set_bus_mute(indice, float(volumenes[clave]) == 0.0 or (clave == "general" and silenciado))

func _aplicar_pantalla() -> void:
	if DisplayServer.get_name() == "headless":
		return
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if modo_pantalla == "completa" else DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, modo_pantalla == "sin_bordes")

func guardar() -> Error:
	var config := ConfigFile.new()
	for clave in volumenes:
		config.set_value("audio", clave, volumenes[clave])
	config.set_value("audio", "silenciado", silenciado)
	config.set_value("pantalla", "completa", pantalla_completa)
	config.set_value("pantalla", "modo", modo_pantalla)
	for accion in teclas:
		config.set_value("controles", accion, teclas[accion])
	return config.save(ARCHIVO)
