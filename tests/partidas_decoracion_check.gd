extends SceneTree

func _initialize() -> void:
	call_deferred("_comprobar")

func _comprobar() -> void:
	var escena: Node = load("res://ui/seleccion_partidas.tscn").instantiate()
	var capas: Array[Node] = escena.find_children("Capa *", "TileMapLayer", true, false)
	assert(capas.size() == 28, "Cada pieza del arco y los carteles debe ser una capa independiente.")
	assert(escena.get_node("Arco").get_child_count() == 6, "El marco debe tener solo madera y amarres, sin plantas.")
	for capa in escena.get_node("Arco").get_children():
		assert(not "Enredadera" in String(capa.name) and not "Arbusto" in String(capa.name))
	var paleta: TileSet = capas[0].tile_set
	assert(paleta.get_patterns_count() == 31)
	assert(paleta.tile_size == Vector2i(4, 4))
	var imagenes := {}
	for indice in paleta.get_source_count():
		var id := paleta.get_source_id(indice)
		var fuente: TileSetAtlasSource = paleta.get_source(id)
		imagenes[id] = fuente.texture.get_image()
	for capa in capas:
		assert(capa.tile_set == paleta)
		var celdas: Array[Vector2i] = capa.get_used_cells()
		assert(not celdas.is_empty(), "La pieza debe estar dibujada en el editor: " + String(capa.name))
		for celda in celdas:
			var id: int = capa.get_cell_source_id(celda)
			assert(id < 16, "Los adornos nuevos no deben colocarse automáticamente.")
			var fuente: TileSetAtlasSource = paleta.get_source(id)
			var region := fuente.get_tile_texture_region(capa.get_cell_atlas_coords(celda))
			assert(not imagenes[id].get_region(region).is_invisible())
		var otra: TileMapLayer = capas[1] if capa != capas[1] else capas[0]
		var cantidad: int = otra.get_used_cells().size()
		capa.erase_cell(celdas[0])
		assert(capa.get_used_cells().size() == celdas.size() - 1)
		assert(otra.get_used_cells().size() == cantidad, "Borrar un palo o cuerda no debe borrar otra pieza.")
	var prueba := TileMapLayer.new()
	prueba.tile_set = paleta
	root.add_child(prueba)
	await process_frame
	for indice in paleta.get_patterns_count():
		prueba.clear()
		var patron := paleta.get_pattern(indice)
		prueba.set_pattern(Vector2i(50, 50), patron)
		await process_frame
		assert(prueba.get_used_cells().size() == patron.get_used_cells().size(), "%s: %d / %d" % [patron.resource_name, prueba.get_used_cells().size(), patron.get_used_cells().size()])
		for celda in prueba.get_used_cells():
			var id: int = prueba.get_cell_source_id(celda)
			var fuente: TileSetAtlasSource = paleta.get_source(id)
			assert(not imagenes[id].get_region(fuente.get_tile_texture_region(prueba.get_cell_atlas_coords(celda))).is_invisible(), "Las plantillas no deben pintar casillas vacías.")
	prueba.free()
	assert(escena.get_node("Carteles").get_child_count() == 3)
	assert(escena.get_node("Fondo Pradera").texture.resource_path.ends_with("partidas_editables/paisaje.png"))
	root.add_child(escena)
	await process_frame
	for cartel in escena.get_node("Carteles").get_children():
		assert(cartel.get_node("Boton Partida").pressed.get_connections().size() == 1)
		assert(cartel.get_node("Nombre Nuevo").text_submitted.get_connections().size() == 1)
	escena.queue_free()
	print("PASS: marco sin plantas, 28 piezas independientes y 31 plantillas disponibles.")
	quit()
