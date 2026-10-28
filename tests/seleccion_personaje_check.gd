extends SceneTree

const SELECCION := "res://ui/seleccion_personaje/seleccion_personaje.tscn"
const MAPA := "res://ui/Mapa/mapa_mundo.tscn"

func _initialize() -> void:
	call_deferred("_comprobar")

func _comprobar() -> void:
	assert(change_scene_to_file(SELECCION) == OK)
	await process_frame
	await process_frame
	var seleccion = current_scene
	assert(not seleccion.has_node("TimerInicio"))
	assert(ResourceLoader.load_threaded_get_status(MAPA) != ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, "El mapa debe empezar a cargar durante la selección.")

	seleccion.jugadores_activos.append("p1")
	seleccion._on_jugador_listo("p1", true, 2)
	assert(seleccion.inicio_pendiente and seleccion.mensaje_inicio.visible)
	assert(seleccion.mensaje_inicio.text == "Cargando mapa...")
	assert(not seleccion.is_processing_input())
	for panel in seleccion.paneles:
		assert(not panel.is_processing_input())
	var limite := Time.get_ticks_msec() + 30000
	while current_scene == seleccion and Time.get_ticks_msec() < limite:
		await process_frame
	assert(current_scene != null and current_scene.scene_file_path == MAPA, "Debe abrirse el mapa al terminar la carga.")
	assert(root.get_node("Ajustes").jugadores_seleccionados == {"p1": 2})
	print("PASS: inicio inmediato y transición con personajes seleccionados.")
	quit()
