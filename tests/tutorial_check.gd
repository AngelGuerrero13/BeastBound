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
	var suelo: TileMapLayer = tutorial.get_node("Fondo/Suelo")
	assert(suelo.tile_set.tile_size == Vector2i(16, 16))
	assert(suelo.get_used_rect() == Rect2i(0, 4, 30, 9))
	assert(suelo.get_used_cells().size() == 270, "El suelo debe cubrir toda la sala.")
	var paja: TileMapLayer = suelo.get_node("Paja Suelta")
	assert(paja.get_used_cells().is_empty(), "La capa de decoracion queda lista para pintar.")
	assert(paja.z_index == 1 and paja.tile_set.tile_size == Vector2i(8, 8))
	assert(paja.tile_set.get_patterns_count() == 8)
	var imagen_paja := (paja.tile_set.get_source(0) as TileSetAtlasSource).texture.get_image()
	assert(imagen_paja.get_size() == Vector2i(96, 48))
	assert(imagen_paja.get_pixel(0, 0).a == 0.0)
	for indice in 8:
		var patron := paja.tile_set.get_pattern(indice)
		assert(patron.get_size() == Vector2i(3, 3))
		for celda in patron.get_used_cells():
			assert((paja.tile_set.get_source(0) as TileSetAtlasSource).has_tile(patron.get_cell_atlas_coords(celda)))
	var muestra_paja_aprobada: TileMapLayer = tutorial.get_node("Fondo/Plantillas/Atlas Suelo/Paja Suelta")
	assert(muestra_paja_aprobada.tile_set == paja.tile_set)
	assert(muestra_paja_aprobada.get_used_rect() == Rect2i(0, 0, 12, 6))
	var pared: TileMapLayer = tutorial.get_node("Fondo/Pared Granero")
	assert(pared.get_used_rect() == Rect2i(0, 0, 60, 9))
	for celda in pared.get_used_cells():
		assert(pared.get_cell_source_id(celda) == 1, "El fondo activo debe ser la opcion 2.")
	assert(not tutorial.has_node("Interfaz Tutorial/Titulo Tutorial"))
	assert(not tutorial.has_node("Interfaz Tutorial/Ayuda Controles"))
	var decoracion: Node2D = tutorial.get_node("Fondo/Decoracion Granero")
	assert(decoracion.z_index == 10, "Conservar el orden de las capas al moverlas al fondo.")
	assert(not tutorial.has_node("Decoracion Granero"))
	var plantillas: Node2D = tutorial.get_node("Fondo/Plantillas")
	assert(not plantillas.visible and plantillas.get_child_count() == 7)
	for nombre in ["Pared Madera", "Pared Ventanas", "Pared Porton"]:
		var muestra: TileMapLayer = plantillas.get_node(nombre)
		assert(muestra.tile_set == pared.tile_set)
		assert(muestra.get_used_rect() == Rect2i(0, 0, 60, 9))
	var atlas_suelo: TileMapLayer = plantillas.get_node("Atlas Suelo")
	assert(atlas_suelo.tile_set == suelo.tile_set and atlas_suelo.get_used_cells().size() == 270)
	assert(suelo.tile_set.get_pattern(0).get_size() == Vector2i(30, 9))
	assert(suelo.tile_set.get_patterns_count() == 4)
	for indice in range(1, 4):
		var nombre: String = ["Paja Rala", "Paja Media", "Paja Abundante"][indice - 1]
		var muestra_paja: TileMapLayer = plantillas.get_node(nombre)
		var patron_paja := suelo.tile_set.get_pattern(indice)
		assert(muestra_paja.tile_set == suelo.tile_set)
		assert(muestra_paja.get_used_cells().size() == 270)
		assert(patron_paja.get_size() == Vector2i(30, 9))
		assert(patron_paja.resource_name == nombre)
		for celda in muestra_paja.get_used_cells():
			assert(muestra_paja.get_cell_source_id(celda) == indice)
			assert(muestra_paja.get_cell_atlas_coords(celda) == celda)
			assert(patron_paja.get_cell_source_id(celda) == indice)
			assert(patron_paja.get_cell_atlas_coords(celda) == celda)
	assert(decoracion.get_child_count() == 5)
	for capa: TileMapLayer in decoracion.get_children():
		assert(capa.scale == Vector2.ONE)
		assert(capa.tile_set.get_patterns_count() == 12)
		for indice in 12:
			var atlas := capa.tile_set.get_source(indice) as TileSetAtlasSource
			assert(atlas.texture.get_size() == Vector2(48, 48))
			assert(capa.tile_set.get_pattern(indice).get_size() == Vector2i(6, 6))
	for celda in suelo.get_used_cells():
		assert(suelo.get_cell_atlas_coords(celda) == celda - Vector2i(0, 4), "Conservar la continuidad de la textura al colocar el suelo.")
		var atlas := suelo.tile_set.get_source(suelo.get_cell_source_id(celda)) as TileSetAtlasSource
		assert(atlas != null and atlas.texture != null)
		assert(atlas.has_tile(suelo.get_cell_atlas_coords(celda)))
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
