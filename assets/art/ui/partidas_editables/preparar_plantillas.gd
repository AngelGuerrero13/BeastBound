extends SceneTree

# Herramienta de preparación: el juego carga los PNG, TileSet y nodos ya guardados.
const CARPETA := "res://assets/art/ui/partidas_editables/"
const PASO := 4

func _initialize() -> void:
	var solo_texturas := "--solo-texturas" in OS.get_cmdline_user_args()
	var original := Image.load_from_file(CARPETA + "piezas_fuente.png")
	var fuente := Image.load_from_file(CARPETA + "piezas_trazo_fino.png") if FileAccess.file_exists(CARPETA + "piezas_trazo_fino.png") else original
	assert(fuente.get_size() == Vector2i(1536, 1024))
	assert(fuente.get_pixel(250, 350).a == 0.0, "La paleta debe tener fondo transparente.")
	var piezas := [
		["Travesano", Rect2i(32, 32, 880, 108), Vector2i(688, 28)],
		["Placa Titulo", Rect2i(924, 28, 580, 124), Vector2i(292, 44)],
		["Palo Izquierdo", Rect2i(104, 148, 92, 620), Vector2i(32, 312)],
		["Palo Derecho", Rect2i(1340, 148, 92, 620), Vector2i(32, 312)],
		["Tabla 1", Rect2i(296, 184, 944, 164), Vector2i(460, 76)],
		["Tabla 2", Rect2i(296, 376, 944, 164), Vector2i(460, 76)],
		["Tabla 3", Rect2i(292, 572, 948, 168), Vector2i(460, 76)],
		["Cuerda Corta", Rect2i(64, 780, 64, 216), Vector2i(12, 44)],
		["Cuerda Larga", Rect2i(64, 780, 64, 216), Vector2i(12, 104)],
		["Amarre Superior", Rect2i(192, 796, 96, 192), Vector2i(24, 68)],
		["Nudo", Rect2i(340, 832, 100, 116), Vector2i(24, 24)],
		["Enredadera", Rect2i(452, 764, 288, 240), Vector2i(40, 88)],
		["Flor Blanca", Rect2i(752, 852, 88, 96), Vector2i(12, 12)],
		["Flor Rosa", Rect2i(868, 852, 88, 96), Vector2i(12, 12)],
		["Hojas", Rect2i(972, 844, 204, 116), Vector2i(64, 24)],
		["Arbusto", Rect2i(1176, 780, 348, 208), Vector2i(112, 60)],
	]
	var paleta := TileSet.new()
	paleta.tile_size = Vector2i(PASO, PASO)
	var patrones := {}
	for id in piezas.size():
		var datos: Array = piezas[id]
		var recorte := fuente.get_region(datos[1])
		var imagen := recorte.get_region(original.get_region(datos[1]).get_used_rect())
		imagen.resize(datos[2].x, datos[2].y, Image.INTERPOLATE_NEAREST)
		var archivo: String = datos[0].to_snake_case() + ".png"
		if solo_texturas:
			var anterior := Image.load_from_file(CARPETA + archivo)
			assert(anterior.get_size() == imagen.get_size())
			# Mantener la silueta pintada y las casillas de todas las capas personalizadas.
			for y in imagen.get_height():
				for x in imagen.get_width():
					var color := imagen.get_pixel(x, y)
					color.a = anterior.get_pixel(x, y).a
					imagen.set_pixel(x, y, color)
		assert(imagen.save_png(CARPETA + archivo) == OK)
		if solo_texturas:
			continue
		var atlas := TileSetAtlasSource.new()
		# Texture2D con ruta externa; Godot lo importa antes de cargar la escena.
		var textura := ImageTexture.create_from_image(imagen)
		textura.take_over_path(CARPETA + archivo)
		atlas.texture = textura
		atlas.texture_region_size = Vector2i(PASO, PASO)
		atlas.resource_name = datos[0]
		paleta.add_source(atlas, id)
		var patron := TileMapPattern.new()
		patron.resource_name = datos[0]
		for y in imagen.get_height() / PASO:
			for x in imagen.get_width() / PASO:
				var celda := Vector2i(x, y)
				if imagen.get_region(Rect2i(celda * PASO, Vector2i(PASO, PASO))).is_invisible():
					continue
				atlas.create_tile(celda)
				patron.set_cell(celda, id, celda, 0)
		assert(patron.get_used_cells().size() > 0)
		paleta.add_pattern(patron)
		patrones[datos[0]] = patron
	if solo_texturas:
		print("Actualizadas 16 texturas con trazo fino; escenas, siluetas y plantillas conservadas.")
		quit()
		return
	assert(ResourceSaver.save(paleta, CARPETA + "plantillas.tres") == OK)
	var ruta := "res://ui/seleccion_partidas.tscn"
	var texto := FileAccess.get_file_as_string(ruta)
	var quitar := RegEx.new()
	quitar.compile('(?m)^\\[ext_resource[^\\n]*id="(?:carteles|fondo|paisaje|tabla_borrado|plantillas)"\\]\\n')
	texto = quitar.sub(texto, "", true)
	quitar.compile('\\n{3,}')
	texto = quitar.sub(texto, "\n\n", true)
	quitar.compile('(?s)\\[node name="Arco".*?(?=\\[node name="Titulo Partidas")')
	texto = quitar.sub(texto, "")
	quitar.compile('(?s)\\[sub_resource type="AtlasTexture".*?(?=\\[node name="Seleccion Partidas")')
	texto = quitar.sub(texto, "")
	var recursos := '[ext_resource type="Texture2D" path="' + CARPETA + 'paisaje.png" id="paisaje"]\n'
	recursos += '[ext_resource type="Texture2D" path="' + CARPETA + 'tabla_1.png" id="tabla_borrado"]\n'
	recursos += '[ext_resource type="TileSet" path="' + CARPETA + 'plantillas.tres" id="plantillas"]\n\n'
	texto = texto.replace('[node name="Seleccion Partidas"', recursos + '[node name="Seleccion Partidas"')
	texto = texto.replace('texture = SubResource("Pradera_Ancha")', 'texture = ExtResource("paisaje")')
	texto = texto.replace('texture = SubResource("Madera_1")', 'texture = ExtResource("tabla_borrado")')
	var arco := '[node name="Arco" type="Node2D" parent="."]\neditor_description = "Cada pieza es una capa independiente. Selecciona una capa y abre TileMap > Patrones para pintar las plantillas."\n\n'
	arco += _capa("Capa 1 Palo Izquierdo", "Arco", "Palo Izquierdo", Vector2(18, 0), paleta, patrones)
	arco += _capa("Capa 2 Palo Derecho", "Arco", "Palo Derecho", Vector2(590, 0), paleta, patrones)
	arco += _capa("Capa 3 Travesano", "Arco", "Travesano", Vector2(-24, 16), paleta, patrones)
	arco += _capa("Capa 4 Placa Titulo", "Arco", "Placa Titulo", Vector2(174, 4), paleta, patrones)
	arco += _capa("Capa 5 Amarre Izquierdo", "Arco", "Amarre Superior", Vector2(126, 10), paleta, patrones)
	arco += _capa("Capa 6 Amarre Derecho", "Arco", "Amarre Superior", Vector2(494, 10), paleta, patrones)
	texto = texto.replace('[node name="Titulo Partidas"', arco + '[node name="Titulo Partidas"')
	for numero in range(1, 4):
		var padre := "Carteles/Cartel %d" % numero
		quitar.compile('(?s)\\[node name="(?:Madera y Cuerdas|Capa 1 Tabla)"[^\\n]*parent="' + padre + '"[^\\n]*\\]\\n.*?(?=\\[node name="Nombre Equipo")')
		var capas := _capa("Capa 1 Tabla", padre, "Tabla %d" % numero, Vector2(10, 24), paleta, patrones)
		capas += _capa("Capa 2 Cuerda Izquierda", padre, "Cuerda Corta", Vector2(52, 0), paleta, patrones)
		capas += _capa("Capa 3 Cuerda Derecha", padre, "Cuerda Corta", Vector2(420, 0), paleta, patrones)
		capas += _capa("Capa 4 Nudo Izquierdo", padre, "Nudo", Vector2(46, 82), paleta, patrones)
		capas += _capa("Capa 5 Nudo Derecho", padre, "Nudo", Vector2(414, 82), paleta, patrones)
		if numero < 3:
			capas += _capa("Capa 6 Enredadera", padre, "Enredadera", Vector2(12 if numero == 1 else 440, 22), paleta, patrones)
			capas += _capa("Capa 7 Flor", padre, "Flor Blanca" if numero == 1 else "Flor Rosa", Vector2(24 if numero == 1 else 452, 46), paleta, patrones)
		else:
			capas += _capa("Capa 6 Hojas Izquierdas", padre, "Hojas", Vector2(70, 2), paleta, patrones)
			capas += _capa("Capa 7 Hojas Derechas", padre, "Hojas", Vector2(340, 2), paleta, patrones)
			capas += _capa("Capa 8 Flor", padre, "Flor Blanca", Vector2(388, 2), paleta, patrones)
		texto = quitar.sub(texto, capas)
		texto = texto.replace('Madera, enredadera, agujeros y nudos del cartel %d. Sus textos, progreso y boton son nodos independientes.' % numero, 'Tabla, cuerdas, nudos, hojas y flores editables en capas separadas. Cada capa tiene sus plantillas en TileMap > Patrones.')
	var archivo := FileAccess.open(ruta, FileAccess.WRITE)
	archivo.store_string(texto)
	print("Preparadas 16 plantillas, 6 piezas del arco sin plantas y 22 capas de los carteles.")
	quit()

func _capa(nombre: String, padre: String, pieza: String, posicion: Vector2, paleta: TileSet, patrones: Dictionary) -> String:
	var capa := TileMapLayer.new()
	capa.tile_set = paleta
	capa.set_pattern(Vector2i.ZERO, patrones[pieza])
	assert(not capa.get_used_cells().is_empty())
	var datos: PackedByteArray = capa.get_tile_map_data_as_array()
	capa.free()
	return '[node name="%s" type="TileMapLayer" parent="%s"]\neditor_description = "Pieza independiente: %s. Usa TileMap > Patrones para copiar, pintar o borrar. Cuadricula de 4 px."\ntexture_filter = 1\nposition = Vector2(%s, %s)\ntile_map_data = PackedByteArray("%s")\ntile_set = ExtResource("plantillas")\n\n' % [nombre, padre, pieza, posicion.x, posicion.y, Marshalls.raw_to_base64(datos)]
