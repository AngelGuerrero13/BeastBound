extends SceneTree

# APPDATA aislada para no modificar los ajustes de la persona.
func _initialize() -> void:
	var carpeta := OS.get_environment("APPDATA").replace("\\", "/")
	if not carpeta.ends_with("/test-appdata") or not OS.get_user_data_dir().replace("\\", "/").begins_with(carpeta + "/"):
		push_error("Usa APPDATA aislada en test-appdata.")
		quit(1)
		return
	call_deferred("_comprobar")


func _comprobar() -> void:
	var ajustes = root.get_node("Ajustes")
	ajustes.introduccion_vista = true
	assert(change_scene_to_file("res://ui/menu_principal.tscn") == OK)
	await process_frame
	await process_frame
	var menu = current_scene
	menu._ajustes()
	await process_frame
	var libro = menu.libro_ajustes
	assert(libro.visible and not menu.modal.visible)
	var fondo_comun: TextureRect = libro.get_node("Libro")
	var textura_comun = fondo_comun.texture
	assert(fondo_comun.visible)
	assert(libro.get_node("Pagina Audio/Volumen General") is HSlider)
	libro.get_node("Pagina Audio/Volumen General").value = 37
	assert(ajustes.volumenes.general == 37)
	libro.get_node("Boton Siguiente").pressed.emit()
	assert(libro.pagina == 1)
	assert(fondo_comun.visible and fondo_comun.texture == textura_comun)
	assert(libro.get_node("Dibujo Pantalla").visible and not libro.get_node("Dibujo Audio").visible)
	libro.get_node("Pagina Pantalla/Sin Bordes").button_pressed = true
	assert(ajustes.modo_pantalla == "sin_bordes")
	libro.get_node("Boton Siguiente").pressed.emit()
	assert(libro.pagina == 2 and not libro.get_node("Boton Siguiente").visible)
	assert(fondo_comun.visible and fondo_comun.texture == textura_comun)
	assert(libro.get_node("Dibujo Controles").visible and not libro.get_node("Dibujo Pantalla").visible)
	libro.get_node("Pagina Controles/Cambiar Salto").pressed.emit()
	var duplicada := InputEventKey.new()
	duplicada.physical_keycode = KEY_W
	duplicada.pressed = true
	libro._input(duplicada)
	assert(libro.accion_pendiente == "p1_salto")
	assert(libro.estado.text.contains("ya está asignada"))
	var tecla := InputEventKey.new()
	tecla.physical_keycode = KEY_G
	tecla.pressed = true
	libro._input(tecla)
	assert(ajustes.teclas["p1_salto"].physical_keycode == KEY_G)
	assert(InputMap.action_get_events("p1_salto").any(func(e): return e is InputEventKey and e.physical_keycode == KEY_G))
	assert(libro.guardar_y_cerrar())
	assert(not libro.visible)
	var config := ConfigFile.new()
	assert(config.load("user://ajustes.cfg") == OK)
	assert(config.get_value("audio", "general") == 37)
	assert(config.get_value("pantalla", "modo") == "sin_bordes")
	assert(config.get_value("controles", "p1_salto").physical_keycode == KEY_G)
	ajustes.teclas.clear()
	ajustes._ready()
	assert(ajustes.modo_pantalla == "sin_bordes")
	assert(ajustes.teclas["p1_salto"].physical_keycode == KEY_G)
	menu._ajustes()
	assert(libro.pagina == 0)
	libro.get_node("Boton Volver").pressed.emit()
	menu._creditos()
	assert(menu.modal.visible)
	menu._cerrar_modal()
	ajustes._pausar()
	assert(paused)
	var menu_pausa = ajustes.capa_pausa.get_child(0)
	menu_pausa._ajustes()
	assert(menu_pausa.modal.visible and not menu_pausa.libro_ajustes.visible)
	menu_pausa._cerrar_modal()
	menu_pausa._jugar()
	assert(not paused)
	print("PASS: libro, audio, pantalla, controles, guardado y pausa.")
	quit()
