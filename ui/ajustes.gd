extends Node

const MENU := "res://ui/menu_principal.tscn"
const ARCHIVO := "user://ajustes.cfg"
const BUSES := {"general": "Master", "musica": "Musica", "efectos": "Efectos"}

var volumenes: Dictionary = {"general": 80.0, "musica": 80.0, "efectos": 80.0}
var silenciado := false
var pantalla_completa := true
var introduccion_vista := false
var capa_pausa: CanvasLayer


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
	_aplicar_audio()
	_aplicar_pantalla()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		var escena := get_tree().current_scene
		if escena != null and escena.scene_file_path != MENU and escena.scene_file_path != "res://ui/seleccion_partidas.tscn" and capa_pausa == null:
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
	pantalla_completa = valor
	_aplicar_pantalla()


func _aplicar_audio() -> void:
	for clave in BUSES:
		var indice := AudioServer.get_bus_index(BUSES[clave])
		AudioServer.set_bus_volume_db(indice, linear_to_db(maxf(float(volumenes[clave]) / 100.0, 0.0001)))
		AudioServer.set_bus_mute(indice, float(volumenes[clave]) == 0.0 or (clave == "general" and silenciado))


func _aplicar_pantalla() -> void:
	if DisplayServer.get_name() == "headless":
		return
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if pantalla_completa else DisplayServer.WINDOW_MODE_WINDOWED)


func guardar() -> Error:
	var config := ConfigFile.new()
	for clave in volumenes:
		config.set_value("audio", clave, volumenes[clave])
	config.set_value("audio", "silenciado", silenciado)
	config.set_value("pantalla", "completa", pantalla_completa)
	return config.save(ARCHIVO)
