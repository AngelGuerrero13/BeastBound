extends SceneTree


func _initialize() -> void:
	var carpeta := OS.get_environment("APPDATA").replace("\\", "/")
	if not carpeta.ends_with("/tutorial-tests/test-appdata") or not OS.get_user_data_dir().replace("\\", "/").begins_with(carpeta + "/"):
		push_error("Usa APPDATA aislado en .godot/tutorial-tests/test-appdata.")
		quit(1)
		return
	call_deferred("_comprobar")


func _esperar_escena() -> void:
	await process_frame
	await process_frame


func _comprobar() -> void:
	var partidas = root.get_node("Partidas")
	for espacio in [1, 2]:
		if partidas.existe(espacio):
			assert(partidas.eliminar(espacio) == OK)
	assert(partidas.crear(1, "Equipo tutorial") == OK)
	assert(partidas.leer(1).tutorial_pendiente)
	assert(partidas.abrir(1) == OK)
	await _esperar_escena()
	assert(current_scene.scene_file_path == partidas.TUTORIAL)
	assert(not partidas.leer(1).tutorial_pendiente)
	var tutorial := current_scene
	var boton: Button = tutorial.get_node("Interfaz Tutorial/Boton Avanzar")
	var reloj: Timer = tutorial.get_node("Tiempo Practica")
	assert(reloj.wait_time == 60.0 and reloj.time_left > 59.0)
	assert(not boton.visible and boton.disabled)
	assert(tutorial.get_node("Fondo/Suelo Paja").texture != null)
	var pared: TileMapLayer = tutorial.get_node("Fondo/Pared Granero")
	assert(pared.get_used_rect() == Rect2i(0, 0, 60, 9))
	for celda in pared.get_used_cells():
		assert(pared.get_cell_source_id(celda) == 1, "El fondo activo debe ser la opcion 2.")
	assert(not tutorial.has_node("Interfaz Tutorial/Titulo Tutorial"))
	assert(not tutorial.has_node("Interfaz Tutorial/Ayuda Controles"))
	var decoracion: Node2D = tutorial.get_node("Decoracion Granero")
	assert(decoracion.get_child_count() == 5)
	for capa: TileMapLayer in decoracion.get_children():
		assert(capa.scale == Vector2.ONE)
		assert(capa.tile_set.get_patterns_count() == 12)
		for indice in 12:
			var atlas := capa.tile_set.get_source(indice) as TileSetAtlasSource
			assert(atlas.texture.get_size() == Vector2(48, 48))
			assert(capa.tile_set.get_pattern(indice).get_size() == Vector2i(6, 6))
	assert(tutorial.get_node("Fondo/Suelo Paja").texture.region == Rect2(0, 280, 1942, 529))
	assert(tutorial.get_node("Camara Tutorial").is_current())
	assert(not tutorial.get_node("Mago/Camara Personaje").enabled)
	tutorial._avanzar()
	assert(current_scene == tutorial)
	paused = true
	var restante := reloj.time_left
	await create_timer(0.1).timeout
	assert(is_equal_approx(reloj.time_left, restante))
	paused = false
	assert(partidas.guardar_actual() == OK)
	assert(partidas.leer(1).jugadores.is_empty())
	# Acelerar el tiempo del motor permite probar los 60 segundos completos.
	Engine.time_scale = 20.0
	await reloj.timeout
	await process_frame
	Engine.time_scale = 1.0
	assert(boton.visible and not boton.disabled)
	assert(boton.get_theme_stylebox("normal") is StyleBoxTexture)
	assert(Rect2(Vector2.ZERO, Vector2(640, 360)).encloses(boton.get_global_rect()))
	boton.pressed.emit()
	await _esperar_escena()
	assert(current_scene.scene_file_path == partidas.MUNDO)
	assert(current_scene.get_node("Nivel 1/Mago").vida > 0)
	assert(partidas.guardar_actual() == OK)
	assert(partidas.abrir(1) == OK)
	await _esperar_escena()
	assert(current_scene.scene_file_path == partidas.MUNDO)
	# Una segunda partida entra una sola vez, aunque abandone el tutorial.
	assert(change_scene_to_file("res://ui/seleccion_partidas.tscn") == OK)
	await _esperar_escena()
	var cartel: Control = current_scene.espacios.get_child(1)
	cartel.get_node("Nombre Nuevo").text = "Otro equipo"
	cartel.get_node("Boton Partida").pressed.emit()
	await _esperar_escena()
	assert(current_scene.scene_file_path == partidas.TUTORIAL)
	assert(change_scene_to_file("res://ui/seleccion_partidas.tscn") == OK)
	await _esperar_escena()
	cartel = current_scene.espacios.get_child(1)
	assert(cartel.get_node("Boton Partida").text == "JUGAR")
	cartel.get_node("Boton Partida").pressed.emit()
	await _esperar_escena()
	assert(current_scene.scene_file_path == partidas.MUNDO)
	var antiguo := ConfigFile.new()
	assert(antiguo.load("user://partidas/partida_2.cfg") == OK)
	antiguo.erase_section_key("partida", "tutorial_pendiente")
	assert(antiguo.save("user://partidas/partida_2.cfg") == OK)
	assert(not partidas.leer(2).tutorial_pendiente)
	assert(partidas.abrir(2) == OK)
	await _esperar_escena()
	assert(current_scene.scene_file_path == partidas.MUNDO)
	for espacio in [1, 2]:
		assert(partidas.eliminar(espacio) == OK)
	print("PASS: tutorial por partida nueva, 60 segundos, pausa, boton, Nivel 1, guardado y compatibilidad anterior.")
	quit()
