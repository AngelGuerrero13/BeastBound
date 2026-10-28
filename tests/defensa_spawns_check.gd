extends SceneTree

func _initialize() -> void:
	call_deferred("comprobar")

func comprobar() -> void:
	var tanque: Node = load("res://personajes/tanque/tanque.tscn").instantiate()
	tanque.vida = 100
	assert(is_equal_approx(tanque.reduccion_dano, 0.3))
	for i in 10:
		tanque.recibir_dano(1)
	assert(tanque.vida == 93, "Diez golpes de 1 deben quitar 7 con defensa del 30 %")
	tanque.recibir_dano(-5)
	assert(tanque.vida == 93)
	tanque.reduccion_dano = 1.0
	tanque.recibir_dano(100)
	assert(tanque.vida == 93)
	tanque.free()
	var mago: Node = load("res://personajes/mago/mago.tscn").instantiate()
	mago.recibir_dano(2)
	assert(mago.vida == 4, "El mago sin defensa sigue recibiendo el daño completo")
	mago.free()
	var ajustes := root.get_node("Ajustes")
	ajustes.jugadores_seleccionados = {"p4": 1, "p2": 0, "p1": 1, "p3": 0}
	for ruta in ["res://niveles/tutorial/tutorial.tscn", "res://niveles/nivel 1/nivel 1.tscn", "res://niveles/nivel 2/nivel 2.tscn"]:
		var nivel: Node2D = load(ruta).instantiate()
		nivel.position = Vector2(500, 200)
		root.add_child(nivel)
		nivel.process_mode = Node.PROCESS_MODE_DISABLED
		var spawner: Node = nivel.get_node("PuntosSpawn")
		assert(spawner.jugadores_generados.size() == 4)
		for i in 4:
			var jugador: Node2D = spawner.jugadores_generados[i]
			var marcador: Marker2D = spawner.get_child(i)
			assert(jugador.global_position.is_equal_approx(marcador.global_position))
			assert(jugador.name == "Jugador p%d" % (i + 1))
			assert(jugador.position.x >= 40 and jugador.position.y >= 100 and jugador.position.y <= 170)
			for j in range(i):
				assert(jugador.position.distance_to(spawner.jugadores_generados[j].position) >= 40)
			for camara in jugador.find_children("*", "Camera2D", true, false):
				assert(not camara.enabled)
		spawner.generar_jugadores()
		assert(spawner.jugadores_generados.size() == 4, "No duplicar jugadores")
		if nivel.has_meta("inicio_avance"):
			assert(nivel.get_meta("inicio_avance") == 564.0)
		nivel.free()
	# Cargar una partida encuentra al jugador desde el _ready de Mundo.
	var partidas := root.get_node("Partidas")
	partidas.estado_pendiente = {"nivel": 1, "jugadores": [{"ruta": "Nivel 1/Jugador p1", "posicion": Vector2(250, 130), "vida": 3}]}
	var mundo: Node = load("res://niveles/mundo.tscn").instantiate()
	root.add_child(mundo)
	assert(mundo.get_node("Nivel 1/Jugador p1").global_position == Vector2(250, 130))
	assert(mundo.get_node("Nivel 1/Jugador p1").vida == 3)
	mundo.free()
	print("OK: defensa, golpes pequeños, cuatro spawns, niveles desplazados y carga de partida")
	quit()
