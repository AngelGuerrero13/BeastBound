extends SceneTree

func _initialize() -> void:
	call_deferred("_comprobar")

func _comprobar() -> void:
	var escena: Node = load("res://ui/seleccion_partidas.tscn").instantiate()
	assert(not escena.has_node("Arco"))
	assert(escena.get_node("Carteles").get_child_count() == 3)
	assert(escena.find_children("*", "TileMapLayer", true, false).is_empty())
	for indice in range(1, 4):
		var cartel: Control = escena.get_node("Carteles/Cartel %d" % indice)
		var tabla: TextureRect = cartel.get_node("Tabla")
		assert(tabla.position == Vector2(0, 14) and tabla.size == Vector2(480, 92))
		assert(tabla.texture is AtlasTexture)
		assert(tabla.texture.atlas.resource_path.ends_with("maderas_musgo/madera_%d.png" % indice))
		assert(tabla.mouse_filter == Control.MOUSE_FILTER_IGNORE)
	assert(escena.get_node("Fondo").texture.resource_path.ends_with("fondo_pradera/pradera_base.png"))
	var hojas: Sprite2D = escena.get_node("Animacion del Fondo/Hojas Animadas")
	assert(hojas.texture.resource_path.ends_with("fondo_pradera/hojas_flores.png"))
	var viento: AnimationPlayer = escena.get_node("Animacion del Fondo/Animacion Viento")
	assert(viento.has_animation("Viento") and viento.autoplay.is_empty())
	root.add_child(escena)
	await process_frame
	assert(not viento.is_playing())
	var ultima_tabla: TextureRect = escena.get_node("Carteles/Cartel 3/Tabla")
	var volver: Button = escena.get_node("Boton Volver")
	assert(not ultima_tabla.get_global_rect().intersects(volver.get_global_rect()), "El cartel no debe tocar el boton Volver.")
	for cartel in escena.get_node("Carteles").get_children():
		var tabla: TextureRect = cartel.get_node("Tabla")
		for nombre in ["Nombre Equipo", "Detalle Partida", "Barra Avance", "Nombre Nuevo", "Boton Partida", "Boton Eliminar"]:
			assert(tabla.get_rect().encloses(cartel.get_node(nombre).get_rect()), "El contenido debe quedar dentro de la tabla: " + nombre)
		assert(cartel.get_node("Boton Partida").pressed.get_connections().size() == 1)
		assert(cartel.get_node("Nombre Nuevo").text_submitted.get_connections().size() == 1)
	escena.queue_free()
	print("PASS: tres maderas editables, controles y animacion sin activar.")
	quit()
