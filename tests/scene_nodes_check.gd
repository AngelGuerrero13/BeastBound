extends SceneTree

# Ejecutar con APPDATA en tests/test-appdata para aislar los ajustes.
func _initialize() -> void:
	var carpeta_pruebas := OS.get_environment("APPDATA").replace("\\", "/")
	if not carpeta_pruebas.ends_with("/test-appdata") or not OS.get_user_data_dir().replace("\\", "/").begins_with(carpeta_pruebas + "/"):
		push_error("Usa APPDATA en tests/test-appdata para proteger los ajustes reales.")
		quit(1)
		return
	call_deferred("_comprobar")


func _comprobar() -> void:
	var escenas := [
		"res://PersonajeBase.tscn",
		"res://assets/art/fondos/beastbound_fondos_arboles_nivel_v2/fondos_nivel1.tscn",
		"res://niveles/mundo.tscn",
		"res://niveles/nivel 1/nivel 1.tscn",
		"res://personajes/personajeBase/personaje_base.tscn",
		"res://personajes/mago/mago.tscn",
		"res://personajes/mago/bola_fuego.tscn",
		"res://personajes/tanque/tanque.tscn",
		"res://personajes/enemigoBasico/enemigo_basico.tscn",
		"res://personajes/muñecoPrueba/muñeco_prueba.tscn",
		"res://ui/menu_principal.tscn",
		"res://ui/seleccion_partidas.tscn",
		"res://niveles/tutorial/tutorial.tscn",
	]
	for ruta in escenas:
		var escena: Node = load(ruta).instantiate()
		assert(escena != null, ruta)
		escena.free()
	var tutorial: Node = load("res://niveles/tutorial/tutorial.tscn").instantiate()
	var suelo: TileMapLayer = tutorial.get_node("Fondo/Suelo")
	assert(suelo.tile_set != null and not suelo.get_used_cells().is_empty())
	assert(tutorial.get_node("Fondo/Pared Granero") is TileMapLayer)
	assert(tutorial.get_node("Fondo/Decoracion Granero").get_child_count() == 5)
	assert(tutorial.get_node("Fondo/Plantillas").get_child_count() == 7)
	assert(tutorial.get_node("Zona Practica").get_child_count() == 3)
	assert(tutorial.get_node("Interfaz Tutorial/Boton Avanzar") is Button)
	assert(tutorial.get_node("Interfaz Tutorial/Boton Avanzar").theme.get_stylebox("normal", "Button") is StyleBoxTexture)
	assert(tutorial.get_node("Camara Tutorial").limit_right == 480)
	tutorial.free()
	var nivel: Node = load(escenas[3]).instantiate()
	var superior: CollisionShape2D = nivel.get_node("Limites Nivel/Pared Superior/Colision Superior")
	var inferior: CollisionShape2D = nivel.get_node("Limites Nivel/Pared Inferior/Colision Inferior")
	assert(superior.position.y < inferior.position.y)
	assert(nivel.get_node("Fondo/Capa 7 Pared Superior") is TileMapLayer)
	assert(nivel.get_node("Camara Nivel") is Camera2D)
	var mago := nivel.get_node("Mago")
	var animaciones: AnimationPlayer = mago.get_node("Animaciones Personaje")
	for nombre in animaciones.get_animation_list():
		var animacion := animaciones.get_animation(nombre)
		for indice in animacion.get_track_count():
			var ruta := String(animacion.track_get_path(indice)).get_slice(":", 0)
			assert(mago.has_node(ruta), "La animacion debe apuntar al nodo renombrado.")
	var corazones: HBoxContainer = mago.get_node("Interfaz Jugador/Corazones Vida")
	var corazon_original := corazones.get_child(0)
	root.add_child(nivel)
	mago.vida = 3
	mago.actualizar_corazones()
	assert(corazones.get_child(0) == corazon_original, "Conservar los corazones editados en la escena.")
	assert(corazones.get_child_count() == 3)
	nivel.queue_free()
	assert(change_scene_to_file("res://ui/menu_principal.tscn") == OK)
	await process_frame
	await process_frame
	var menu := current_scene
	assert(menu.get_node("Centro Menu/Margen Interior/Botones Menu/Boton Jugar/Icono Jugar").texture != null)
	menu.animacion_introduccion.kill()
	menu._mostrar_menu()
	menu._ajustes()
	await process_frame
	assert(menu.libro_ajustes.visible)
	menu.libro_ajustes.get_node("Pagina Audio/Volumen General").value = 37
	assert(root.get_node("Ajustes").volumenes.general == 37)
	assert(menu.libro_ajustes.get_node("Pagina Audio/Porcentaje General").text == "37%")
	menu._cerrar_modal()
	assert(not menu.libro_ajustes.visible)
	menu._creditos()
	await process_frame
	assert(menu.modal.visible and menu.contenido.get_node("Creditos").visible)
	var ventana: Control = menu.get_node("Ventanas Menu/Centro Ventana/Panel Ventana")
	assert(menu.get_global_rect().encloses(ventana.get_global_rect()))
	menu._cerrar_modal()
	assert(not menu.modal.visible)
	print("PASS: 13 escenas, tutorial editable, paredes, camara, animaciones, corazones y ventanas del menu.")
	quit()
