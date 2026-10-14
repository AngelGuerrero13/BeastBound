extends SceneTree

# Run with Godot --headless --path . --script tests/vegetation_editor_check.gd
func _initialize() -> void:
	var scene = load("res://niveles/nivel 1/nivel 1.tscn").instantiate()
	var checked_cells := 0
	var checked_patterns := 0
	var wall: TileMapLayer = scene.get_node("Fondo/Capa 7 Pared Superior")
	var foreground: TileMapLayer = scene.get_node("Fondo/Capa 10 Maleza Frontal")
	var rear: TileMapLayer = scene.get_node("Fondo/Capa 3 Vegetacion Lejana")
	var rear_before := rear.get_tile_map_data_as_array()
	var front: TileMapLayer = scene.get_node("Fondo/Capa 4 Arboles Grandes").duplicate()
	var palette: TileSetAtlasSource = front.tile_set.get_source(0)
	var copied := TileMapPattern.new()
	# Match the native atlas rectangle selection around arbusto_redondo.
	for y in range(32, 36):
		for x in range(0, 6):
			var coords := palette.get_tile_at_coords(Vector2i(x, y))
			if coords != Vector2i(-1, -1):
				copied.set_cell(Vector2i(x, y - 32), 0, coords, 0)
	assert(copied.get_used_cells().size() > 0 and copied.get_used_cells().size() < 24)
	front.set_pattern(Vector2i(12, 12), copied)
	assert(rear.get_tile_map_data_as_array() == rear_before, "Pasting into 04 modified layer 03")
	front.free()
	assert(foreground.z_index > wall.z_index, "The lower bushes must be in front of the wall")
	for layer in scene.get_node("Fondo").get_children():
		if not layer is TileMapLayer or not String(layer.name).begins_with("Capa "):
			continue
		assert(layer.tile_set.tile_size == Vector2i(8, 8))
		assert(not layer.tile_set.has_source(4), "Large single-cell decorations cannot be erased at their visible pixels")
		if layer != foreground and layer != wall:
			assert(layer.z_index < wall.z_index, "Vegetation layer must stay behind the wall: " + String(layer.name))
		for source_index in layer.tile_set.get_source_count():
			var source: TileSetAtlasSource = layer.tile_set.get_source(layer.tile_set.get_source_id(source_index))
			var image := source.texture.get_image()
			for tile_index in source.get_tiles_count():
				var coords := source.get_tile_id(tile_index)
				assert(not image.get_region(source.get_tile_texture_region(coords)).is_invisible(),
					"An empty palette tile can be copied as an erasing rectangle")
				for alternative_index in source.get_alternative_tiles_count(coords):
					var alternative := source.get_alternative_tile_id(coords, alternative_index)
					assert(source.get_tile_data(coords, alternative).z_index == 0,
						"A palette piece overrides its painting layer: " + String(layer.name))
		for cell in layer.get_used_cells():
			var data = layer.get_cell_tile_data(cell)
			assert(data != null and data.modulate.a > 0, "Invisible selection cell in " + String(layer.name))
			var source: TileSetAtlasSource = layer.tile_set.get_source(layer.get_cell_source_id(cell))
			assert(source.get_tile_texture_region(layer.get_cell_atlas_coords(cell)).size == Vector2i(8, 8))
			assert(data.texture_origin == Vector2i.ZERO, "Drawing extends beyond the cell erased by the native editor")
			checked_cells += 1
		var erased: TileMapLayer = layer.duplicate()
		var cells = erased.get_used_cells()
		assert(not cells.is_empty())
		erased.erase_cell(cells[cells.size() / 2])
		assert(erased.get_cell_source_id(cells[cells.size() / 2]) == -1)
		assert(erased.get_used_cells().size() == cells.size() - 1)
		erased.free()
		var probe := TileMapLayer.new()
		probe.tile_set = layer.tile_set
		var images := {}
		assert(layer.tile_set.get_patterns_count() == 18)
		for index in layer.tile_set.get_patterns_count():
			probe.clear()
			var pattern = layer.tile_set.get_pattern(index)
			probe.set_pattern(Vector2i(1000, 1000), pattern)
			assert(probe.get_used_cells().size() == pattern.get_used_cells().size())
			for cell in probe.get_used_cells():
				assert(probe.get_cell_tile_data(cell) != null)
				var source_id := probe.get_cell_source_id(cell)
				var source: TileSetAtlasSource = probe.tile_set.get_source(source_id)
				if not images.has(source_id):
					images[source_id] = source.texture.get_image()
				var region := source.get_tile_texture_region(probe.get_cell_atlas_coords(cell))
				assert(not images[source_id].get_region(region).is_invisible(), "A transparent template cell replaces the background")
			var background_cell = layer.get_used_cells()[0]
			var background_source = layer.get_cell_source_id(background_cell)
			var background_atlas = layer.get_cell_atlas_coords(background_cell)
			probe.clear()
			for y in pattern.get_size().y:
				for x in pattern.get_size().x:
					probe.set_cell(Vector2i(x, y), background_source, background_atlas)
			probe.set_pattern(Vector2i.ZERO, pattern)
			for y in pattern.get_size().y:
				for x in pattern.get_size().x:
					var cell := Vector2i(x, y)
					if not pattern.has_cell(cell):
						assert(probe.get_cell_source_id(cell) == background_source)
						assert(probe.get_cell_atlas_coords(cell) == background_atlas)
			checked_patterns += 1
		probe.free()
	scene.free()
	print("PASS: depth and erasing; ", checked_cells, " valid cells; ", checked_patterns, " patterns leave fully transparent spaces untouched.")
	quit()
