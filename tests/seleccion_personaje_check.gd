extends SceneTree

const SELECCION := "res://ui/seleccion_personaje/seleccion_personaje.tscn"
const CARGA := "res://ui/carga.tscn"
const MAPA := "res://ui/Mapa/mapa_mundo.tscn"

func _initialize() -> void:
	call_deferred("_comprobar")

func _comprobar() -> void:
	assert(change_scene_to_file(SELECCION) == OK)
	await process_frame
	await process_frame
	var seleccion = current_scene
	assert(not seleccion.has_node("TimerInicio"))
	assert(ResourceLoader.load_threaded_get_status(MAPA) == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, "La carga debe empezar en la pantalla de carga, no durante la selección.")

	seleccion.jugadores_activos.append("p1")
	seleccion._on_jugador_listo("p1", true, 2)
	assert(seleccion.inicio_pendiente and seleccion.mensaje_inicio.visible)
	assert(seleccion.mensaje_inicio.text == "Cargando mapa...")
	assert(not seleccion.is_processing_input())
	for panel in seleccion.paneles:
		assert(not panel.is_processing_input())
	var limite := Time.get_ticks_msec() + 30000
	while (current_scene == null or current_scene.scene_file_path != CARGA) and Time.get_ticks_msec() < limite:
		await process_frame
	assert(current_scene != null and current_scene.scene_file_path == CARGA, "La selección debe abrir primero la pantalla de carga.")
	var carga = current_scene
	assert(carga.progreso == 0 and carga.porcentaje.text == "0 %", "La pantalla debe empezar mostrando 0 %.")
	var porcentaje_anterior := -1
	var vio_cien := false
	var vio_intermedio := false
	var valores_intermedios: Dictionary = {}
	var textos_carga: Dictionary = {}
	var mapa_preparado: Node2D
	var cancelar := InputEventAction.new()
	cancelar.action = "ui_cancel"
	cancelar.pressed = true
	root.get_node("Ajustes")._unhandled_input(cancelar)
	assert(not paused, "Escape no debe pausar la pantalla de carga.")
	while current_scene == carga and Time.get_ticks_msec() < limite:
		assert(carga.progreso >= porcentaje_anterior and carga.progreso <= 100, "El porcentaje debe avanzar sin retroceder ni pasar de 100.")
		porcentaje_anterior = carga.progreso
		if carga.progreso > 0 and carga.progreso < 99:
			vio_intermedio = true
			valores_intermedios[carga.progreso] = true
			textos_carga[carga.texto_estado.text] = true
		if carga.progreso == 100:
			vio_cien = true
			assert(carga.porcentaje.is_visible_in_tree() and carga.porcentaje.text == "100 %")
			mapa_preparado = carga.escena_preparada
			assert(is_instance_valid(mapa_preparado) and mapa_preparado.is_node_ready(), "El mapa debe estar listo antes de anunciar el 100 %.")
			assert(not mapa_preparado.visible, "El mapa debe seguir oculto mientras se muestra el 100 %.")
			assert(mapa_preparado.process_mode == Node.PROCESS_MODE_DISABLED)
		await process_frame
	assert(vio_intermedio, "El porcentaje debe aumentar gradualmente desde 0 antes de llegar a 100.")
	assert(valores_intermedios.size() >= 20, "El avance debe repartirse en muchos valores visibles.")
	assert(textos_carga.size() >= 2, "El texto debe seguir animándose durante la carga.")
	assert(vio_cien, "El 100 % debe aparecer en la imagen antes de mostrar el mapa.")
	assert(current_scene != null and current_scene.scene_file_path == MAPA, "Debe abrirse el mapa al terminar la carga.")
	assert(current_scene == mapa_preparado, "Debe mostrarse el mismo mapa que se preparó durante la carga.")
	assert(mapa_preparado.visible and mapa_preparado.process_mode == Node.PROCESS_MODE_INHERIT)
	assert(root.get_node("Ajustes").jugadores_seleccionados == {"p1": 2})
	# Repetir con el recurso en memoria: tampoco debe saltar directamente al 100 %.
	var mapa_en_cache := load(MAPA) as PackedScene
	assert(change_scene_to_file(CARGA) == OK)
	while (current_scene == null or current_scene.scene_file_path != CARGA) and Time.get_ticks_msec() < limite:
		await process_frame
	carga = current_scene
	assert(carga != null and carga.progreso == 0 and carga.porcentaje.text == "0 %")
	vio_intermedio = false
	vio_cien = false
	while current_scene == carga and Time.get_ticks_msec() < limite:
		if carga.progreso > 0 and carga.progreso < 99:
			vio_intermedio = true
		if carga.progreso == 100:
			vio_cien = true
		await process_frame
	assert(mapa_en_cache != null and vio_intermedio and vio_cien, "Incluso en caché debe mostrar 0, valores intermedios y 100 antes del mapa.")
	assert(current_scene.scene_file_path == MAPA)
	print("PASS: carga desde 0, avance gradual, 100 antes del mapa, caché y personajes conservados.")
	quit()
