extends SceneTree

# Añade recursos a la paleta compartida; no coloca ni mueve adornos en la escena.
const CARPETA := "res://assets/art/ui/partidas_editables/naturaleza/"
const PALETA := "res://assets/art/ui/partidas_editables/plantillas.tres"
const PASO := 4

func _initialize() -> void:
	var ruta_escena := "res://ui/seleccion_partidas.tscn"
	var escena_antes := FileAccess.get_file_as_bytes(ruta_escena)
	var paleta: TileSet = load(PALETA)
	var fuente := Image.new()
	assert(fuente.load(CARPETA + "lamina.png") == OK)
	assert(fuente.get_size() == Vector2i(1536, 1024))
	assert(fuente.get_pixel(0, 0).a == 0.0, "Los adornos necesitan un fondo transparente.")
	var piezas := [
		["Natural Arbusto Redondo", Rect2i(0, 0, 384, 352), Vector2i(64, 48)],
		["Natural Arbusto Blanco", Rect2i(384, 0, 384, 352), Vector2i(64, 44)],
		["Natural Arbusto Rosado", Rect2i(768, 0, 384, 352), Vector2i(64, 44)],
		["Natural Helecho", Rect2i(1152, 0, 384, 352), Vector2i(56, 52)],
		["Natural Hiedra", Rect2i(0, 352, 384, 424), Vector2i(36, 88)],
		["Natural Guirnalda", Rect2i(384, 352, 384, 424), Vector2i(104, 40)],
		["Natural Esquina Hojas", Rect2i(768, 352, 384, 424), Vector2i(56, 64)],
		["Natural Rosal", Rect2i(1152, 352, 384, 392), Vector2i(32, 88)],
		["Natural Flores Blancas", Rect2i(0, 776, 384, 248), Vector2i(56, 32)],
		["Natural Flores Violetas", Rect2i(384, 776, 384, 248), Vector2i(56, 36)],
		["Natural Musgo", Rect2i(768, 776, 384, 248), Vector2i(72, 32)],
		["Natural Rama", Rect2i(1152, 744, 384, 280), Vector2i(64, 56)],
	]
	for indice in piezas.size():
		var pieza: Array = piezas[indice]
		var recorte := fuente.get_region(pieza[1])
		var imagen := recorte.get_region(recorte.get_used_rect())
		var limite: Vector2i = pieza[2]
		var factor := minf(float(limite.x) / imagen.get_width(), float(limite.y) / imagen.get_height())
		imagen.resize(maxi(1, roundi(imagen.get_width() * factor)), maxi(1, roundi(imagen.get_height() * factor)), Image.INTERPOLATE_NEAREST)
		_agregar(paleta, 16 + indice, pieza[0], imagen)
	var originales := [
		["Nivel 1 Arbusto Blanco", "arbusto_flor_clara.png"],
		["Nivel 1 Arbusto Rosado", "arbusto_flor_rosada.png"],
		["Nivel 1 Arbusto Ancho", "arbusto_ancho.png"],
	]
	for indice in originales.size():
		var imagen := Image.new()
		assert(imagen.load("res://assets/art/fondos/vegetacion_editable/png/" + originales[indice][1]) == OK)
		_agregar(paleta, 28 + indice, originales[indice][0], imagen)
	assert(paleta.get_patterns_count() == 31)
	assert(ResourceSaver.save(paleta, PALETA) == OK)
	assert(FileAccess.get_file_as_bytes(ruta_escena) == escena_antes, "La decoración colocada debe conservarse.")
	print("PASS: 12 adornos nuevos y 3 arbustos originales de Nivel 1; 31 patrones; escena conservada.")
	quit()

func _agregar(paleta: TileSet, id: int, nombre: String, imagen: Image) -> void:
	var tamano := Vector2i(ceili(float(imagen.get_width()) / PASO) * PASO, ceili(float(imagen.get_height()) / PASO) * PASO)
	var textura := Image.create(tamano.x, tamano.y, false, Image.FORMAT_RGBA8)
	textura.blit_rect(imagen, Rect2i(Vector2i.ZERO, imagen.get_size()), Vector2i.ZERO)
	var ruta := CARPETA + nombre.to_snake_case() + ".png"
	assert(textura.save_png(ruta) == OK)
	var atlas := TileSetAtlasSource.new()
	atlas.resource_name = nombre
	var recurso := ImageTexture.create_from_image(textura)
	recurso.take_over_path(ruta)
	atlas.texture = recurso
	atlas.texture_region_size = Vector2i(PASO, PASO)
	if paleta.has_source(id):
		assert(paleta.get_source(id).resource_name == nombre, "No reemplazar piezas ajenas.")
		paleta.remove_source(id)
	paleta.add_source(atlas, id)
	for indice in range(paleta.get_patterns_count() - 1, -1, -1):
		if paleta.get_pattern(indice).resource_name == nombre:
			paleta.remove_pattern(indice)
	var patron := TileMapPattern.new()
	patron.resource_name = nombre
	for y in tamano.y / PASO:
		for x in tamano.x / PASO:
			var celda := Vector2i(x, y)
			if textura.get_region(Rect2i(celda * PASO, Vector2i(PASO, PASO))).is_invisible():
				continue
			atlas.create_tile(celda)
			patron.set_cell(celda, id, celda, 0)
	assert(not patron.get_used_cells().is_empty())
	paleta.add_pattern(patron)
