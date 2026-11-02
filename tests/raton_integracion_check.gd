extends SceneTree

func _initialize() -> void:
	if not OS.get_user_data_dir().replace("\\", "/").contains("/test-appdata/"):
		quit(1)
		return
	call_deferred("_comprobar")

func _esperar() -> void:
	await process_frame
	await process_frame
	await physics_frame

func _comprobar() -> void:
	var ajustes = root.get_node("Ajustes")
	ajustes.jugadores_seleccionados = {"p2": 3}
	root.get_node("Partidas").estado_pendiente = {}
	var escena = load("res://personajes/clases_jugador/raton_tirador/raton_tirador.tscn")
	var editable = escena.instantiate()
	assert(editable.get_script().get_base_script().resource_path == "res://personajes/personajeBase/personaje_base.gd")
	var dibujo: AnimatedSprite2D = editable.get_node("Imagen Personaje/Animacion Raton")
	for animacion in dibujo.sprite_frames.get_animation_names():
		assert(dibujo.sprite_frames.get_frame_texture(animacion, 0) != null)
	assert(editable.get_node("Colision Cuerpo").shape != null)
	assert(editable.retrato != null)
	editable.free()
	assert(change_scene_to_file("res://niveles/mundo.tscn") == OK)
	await _esperar()
	var mundo = current_scene
	for indice in range(2):
		var nivel = mundo.nivel_actual
		var raton: CharacterBody2D
		for jugador in get_nodes_in_group("Jugador"):
			if nivel.is_ancestor_of(jugador) and jugador.prefijo_input == "p2":
				raton = jugador
		assert(raton != null, "La selección 3 debe crear el ratón en cada nivel.")
		assert(raton.scene_file_path == escena.resource_path)
		assert(raton.is_visible_in_tree() and raton.get_node("Imagen Personaje/Animacion Raton").is_visible_in_tree())
		raton.global_position = Vector2(250, 140)
		await _esperar()
		var inicio := raton.position
		Input.action_press("p1_derecha")
		for paso in range(6):
			await physics_frame
		Input.action_release("p1_derecha")
		assert(raton.position.distance_to(inicio) < 0.1, "El ratón P2 no debe responder a P1.")
		for accion in ["derecha", "izquierda", "arriba", "abajo"]:
			inicio = raton.position
			Input.action_press("p2_" + accion)
			for paso in range(6):
				await physics_frame
			Input.action_release("p2_" + accion)
			assert(raton.position.distance_to(inicio) > 1.0, "Debe moverse con la base: " + accion)
			await _esperar()
		Input.action_press("p2_salto")
		await _esperar()
		Input.action_release("p2_salto")
		assert(not raton.en_suelo or raton.altura > 0.0, "El salto debe seguir perteneciendo a la base.")
		var vida_inicial: int = raton.vida
		raton.recibir_dano(1)
		assert(raton.vida == vida_inicial - 1)
		if OS.get_environment("BEASTBOUND_CAPTURA") == "1":
			await RenderingServer.frame_post_draw
			var archivo := OS.get_environment("BEASTBOUND_CAPTURA_DIR").path_join("raton_tutorial.png" if indice == 0 else "raton_nivel1.png")
			root.get_texture().get_image().save_png(archivo)
		var flechas_antes: int = nivel.get_child_count()
		raton.ejecutar_ataque_normal(null)
		assert(nivel.get_child_count() == flechas_antes + 1)
		var flecha = nivel.get_child(nivel.get_child_count() - 1)
		assert(flecha.tirador == raton and flecha.dano == raton.dano)
		assert(flecha.get_node("Imagen Flecha/Punta Flecha") is Polygon2D)
		flecha.queue_free()
		if indice == 0:
			assert(mundo.ir_al_siguiente_nivel() == OK)
			await _esperar()
	print("PASS: ratón visible desde selección 3, movimiento heredado en cuatro direcciones, P2 independiente, salto, daño, disparo y paso Tutorial → Nivel 1.")
	quit()


