extends SceneTree

const SELECCION := "res://ui/seleccion_partidas.tscn"
const PERSONAJES := "res://ui/seleccion_personaje/seleccion_personaje.tscn"


func _initialize() -> void:
	var carpeta := OS.get_environment("APPDATA").replace("\\", "/")
	if OS.get_environment("BEASTBOUND_SAVE_TESTS") != "1" or not carpeta.ends_with("/test-appdata") or not OS.get_user_data_dir().replace("\\", "/").begins_with(carpeta + "/"):
		quit(1)
		return
	_comprobar.call_deferred()


func _comprobar() -> void:
	var partidas = root.get_node("Partidas")
	for espacio in [1, 2]:
		if partidas.existe(espacio):
			assert(partidas.eliminar(espacio) == OK)
	for nueva in [true, false]:
		assert(change_scene_to_file(SELECCION) == OK)
		await process_frame
		await process_frame
		var pantalla = current_scene
		assert(not pantalla.mensaje_carga.visible)
		assert(pantalla.mensaje_carga.text == "Cargando partida..")
		assert(pantalla.get_global_rect().encloses(pantalla.mensaje_carga.get_global_rect()))
		assert(pantalla.mensaje_carga.anchor_right == 1.0 and pantalla.mensaje_carga.anchor_bottom == 1.0)
		if nueva:
			pantalla._seleccionar(1)
			assert(not pantalla.mensaje_carga.visible, "No debe cargar si falta el nombre.")
			pantalla.espacios.get_child(0).get_node("Nombre Nuevo").text = "Equipo Prueba"
		pantalla._seleccionar(1)
		assert(pantalla.mensaje_carga.is_visible_in_tree() and pantalla.cargando_partida, "El aviso debe aparecer antes de cambiar de escena.")
		pantalla._seleccionar(2)
		pantalla._volver()
		pantalla._pedir_borrado(1)
		assert(not partidas.existe(2) and not pantalla.confirmacion.visible)
		assert(current_scene == pantalla)
		var limite := Time.get_ticks_msec() + 30000
		while (current_scene == null or current_scene.scene_file_path != PERSONAJES) and Time.get_ticks_msec() < limite:
			await process_frame
		assert(current_scene != null and current_scene.scene_file_path == PERSONAJES)
		assert(partidas.espacio_activo == 1 and partidas.leer(1).nombre == "Equipo Prueba")
	# Un archivo dañado debe retirar el aviso y permitir otro intento.
	assert(partidas.crear(2, "Archivo Dañado") == OK)
	var archivo := ConfigFile.new()
	assert(archivo.load("user://partidas/partida_2.cfg") == OK)
	archivo.set_value("partida", "version", 999)
	assert(archivo.save("user://partidas/partida_2.cfg") == OK)
	assert(change_scene_to_file(SELECCION) == OK)
	await process_frame
	await process_frame
	var pantalla = current_scene
	pantalla._seleccionar(2)
	await process_frame
	await process_frame
	assert(not pantalla.cargando_partida and not pantalla.mensaje_carga.visible)
	assert(pantalla.mensaje.text.contains("NO SE PUDO"))
	for espacio in [1, 2]:
		assert(partidas.eliminar(espacio) == OK)
	print("PASS: aviso al crear/abrir, posición, bloqueo de doble entrada y recuperación ante error.")
	quit()
