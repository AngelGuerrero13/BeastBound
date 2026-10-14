extends SceneTree


func _initialize() -> void:
	var carpeta := OS.get_environment("APPDATA").replace("\\", "/")
	if not carpeta.ends_with("/test-appdata") or not OS.get_user_data_dir().replace("\\", "/").begins_with(carpeta + "/"):
		push_error("Usa APPDATA en tests/test-appdata para proteger las partidas reales.")
		quit(1)
		return
	call_deferred("_comprobar")


func _comprobar() -> void:
	var primero = load("res://niveles/nivel 1/nivel 1.tscn").instantiate()
	var segundo = load("res://niveles/nivel 2/nivel 2.tscn").instantiate()
	var suelo_1: TileMapLayer = primero.get_node("Fondo/Suelo Pasto")
	var suelo_2: TileMapLayer = segundo.get_node("Fondo/Suelo Pasto")
	assert(suelo_1.get_tile_map_data_as_array() == suelo_2.get_tile_map_data_as_array())
	assert(suelo_1.tile_set.tile_size == suelo_2.tile_set.tile_size)
	assert(segundo.get_node("Fondo").get_child_count() == 1)
	assert(not segundo.has_node("Ambiente"))
	var mundo_editable = load("res://niveles/mundo.tscn").instantiate()
	assert(mundo_editable.has_node("Nivel 1/Fondo/Suelo Pasto"))
	assert(mundo_editable.has_node("Nivel 2/Fondo/Suelo Pasto"))
	assert(mundo_editable.is_editable_instance(mundo_editable.get_node("Nivel 2")))
	mundo_editable.free()
	assert(primero.get_node("Limites Nivel/Paredes Laterales/Colision Derecha").disabled)
	assert(not segundo.get_node("Limites Nivel/Paredes Laterales/Colision Derecha").disabled)
	primero.free()
	segundo.free()

	var partidas = root.get_node("Partidas")
	# Este espacio solo existe en APPDATA de pruebas, verificado al iniciar.
	if partidas.existe(1):
		assert(partidas.eliminar(1) == OK)
	assert(partidas.crear(1, "Paso Nivel 2") == OK)
	# Comprobar los niveles desde una partida que ya paso el tutorial.
	var guardado := ConfigFile.new()
	assert(guardado.load("user://partidas/partida_1.cfg") == OK)
	guardado.set_value("partida", "tutorial_pendiente", false)
	assert(guardado.save("user://partidas/partida_1.cfg") == OK)
	assert(partidas.abrir(1) == OK)
	await process_frame
	await process_frame
	var mundo = current_scene
	var nivel = mundo.nivel_actual
	var nivel_2 = mundo.get_node("Nivel 2")
	assert(not nivel_2.can_process() and not nivel_2.visible and not nivel_2.get_node("Mago").hud.visible)
	assert(nivel.jugador_seguido == nivel.get_node("Mago"))
	var mago = nivel.get_node("Mago")
	var salida: Area2D = nivel.get_node("Salida Derecha")
	# Ni un enemigo ni un jugador muerto deben activar el cambio.
	salida.body_entered.emit(nivel.get_node("Muñeco Prueba"))
	assert(not nivel.cambiando_nivel)
	mago.vida = 0
	salida.body_entered.emit(mago)
	assert(not nivel.cambiando_nivel)
	mago.vida = 3
	mago.position = Vector2(4780, 100)
	assert(partidas.guardar_actual() == OK)
	assert(partidas.leer(1).nivel == 1 and partidas.leer(1).avance >= 99)
	assert(partidas.abrir(1) == OK)
	await process_frame
	await process_frame
	mundo = current_scene
	mago = mundo.get_node("Nivel 1/Mago")
	assert(mago.vida == 3 and is_equal_approx(mago.position.x, 4780))
	# Cruzar fisicamente el borde, con las colisiones activas.
	Input.action_press("ui_right")
	for paso in 180:
		await physics_frame
		if mundo.nivel_actual.numero_nivel == 2:
			break
	Input.action_release("ui_right")
	await process_frame
	assert(mundo.nivel_actual.numero_nivel == 2, "Atravesar la derecha debe abrir el Nivel 2.")
	assert(mundo.has_node("Nivel 1"))
	assert(not mundo.get_node("Nivel 1").can_process() and not mundo.get_node("Nivel 1").visible)
	assert(not mundo.get_node("Nivel 1/Mago").hud.visible)
	var nuevo = mundo.get_node("Nivel 2/Mago")
	assert(nuevo.vida == 3, "Cambiar de nivel debe conservar la vida.")
	assert(nuevo.position.x < 110, "Entrar por la izquierda del nuevo nivel.")
	assert(mundo.nivel_actual.camara.is_current())
	assert(partidas.guardar_actual() == OK)
	assert(partidas.leer(1).jugadores.size() == 1, "Guardar solo el personaje del nivel activo.")
	assert(partidas.leer(1).nivel == 2 and partidas.leer(1).avance == 0)
	var posicion: Vector2 = nuevo.global_position
	assert(partidas.abrir(1) == OK)
	await process_frame
	await process_frame
	assert(current_scene.nivel_actual.numero_nivel == 2)
	assert(current_scene.get_node("Nivel 2/Mago").vida == 3)
	assert(current_scene.get_node("Nivel 2/Mago").global_position.is_equal_approx(posicion))
	assert(partidas.eliminar(1) == OK)
	# La salida tambien debe funcionar al ejecutar Nivel 1 directamente con F6.
	assert(change_scene_to_file("res://niveles/nivel 1/nivel 1.tscn") == OK)
	await process_frame
	await process_frame
	current_scene.get_node("Salida Derecha").body_entered.emit(current_scene.get_node("Mago"))
	await process_frame
	await process_frame
	assert(current_scene.scene_file_path == "res://niveles/nivel 2/nivel 2.tscn")
	print("PASS: suelo identico sin decoracion, salida fisica, vida, camara, guardado/carga del Nivel 2 y F6.")
	quit()
