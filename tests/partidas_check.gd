extends SceneTree

# Ejecutar con APPDATA apuntando a una carpeta de pruebas y BEASTBOUND_SAVE_TESTS=1.
func _initialize() -> void:
	var carpeta_pruebas := OS.get_environment("APPDATA").replace("\\", "/")
	var datos_usuario := OS.get_user_data_dir().replace("\\", "/")
	if OS.get_environment("BEASTBOUND_SAVE_TESTS") != "1" or not carpeta_pruebas.ends_with("/test-appdata") or not datos_usuario.begins_with(carpeta_pruebas + "/"):
		push_error("Usa una carpeta APPDATA aislada terminada en test-appdata para proteger las partidas reales.")
		quit(1)
		return
	call_deferred("_comprobar")


func _esperar_escena() -> void:
	await process_frame
	await process_frame


func _comprobar() -> void:
	var partidas = root.get_node("Partidas")
	# Solo borrar los archivos de esta prueba en la carpeta aislada verificada arriba.
	for espacio in range(1, 4):
		var ruta := "user://partidas/partida_%d.cfg" % espacio
		if FileAccess.file_exists(ruta):
			DirAccess.remove_absolute(ruta)
	assert(partidas.crear(0) == ERR_INVALID_PARAMETER)
	assert(partidas.crear(4) == ERR_INVALID_PARAMETER)
	assert(partidas.crear(1, "   ") == ERR_INVALID_PARAMETER)
	assert(partidas.crear(1, "x".repeat(25)) == ERR_INVALID_PARAMETER)
	assert(partidas.guardar_actual() == ERR_UNCONFIGURED)
	assert(partidas.eliminar(0) == ERR_INVALID_PARAMETER)
	assert(partidas.eliminar(4) == ERR_INVALID_PARAMETER)
	assert(partidas.eliminar(1) == ERR_DOES_NOT_EXIST)
	# Los botones deben existir al instanciar, antes de ejecutar _ready.
	var seleccion = load("res://ui/seleccion_partidas.tscn").instantiate()
	for indice in range(1, 4):
		var cartel: Control = seleccion.get_node("Carteles/Cartel %d" % indice)
		assert(cartel.get_node("Boton Partida") is Button)
		assert(cartel.get_node("Boton Eliminar") is Button)
		assert(cartel.get_node("Nombre Nuevo") is LineEdit)
		assert(cartel.get_node("Barra Avance") is ProgressBar)
		assert(cartel.get_node("Madera y Cuerdas").texture != null)
	assert(seleccion.get_node("Fondo Pradera").texture != null)
	assert(seleccion.get_node("Confirmar Borrado/Panel Borrado/Boton Cancelar") is Button)
	assert(seleccion.get_node("Confirmar Borrado/Panel Borrado/Boton Eliminar") is Button)
	seleccion.free()
	var menu_editable = load("res://ui/menu_principal.tscn").instantiate()
	assert(menu_editable.get_node("Centro Menu/Margen Interior/Botones Menu/Boton Guardar Partida") is Button)
	var boton_guardar: Button = menu_editable.get_node("Centro Menu/Margen Interior/Botones Menu/Boton Guardar Partida")
	assert(boton_guardar.text == "GUARDAR PARTIDA")
	assert(boton_guardar.get_theme_stylebox("normal") is StyleBoxTexture)
	assert(boton_guardar.get_theme_stylebox("normal").texture.atlas.resource_path.ends_with("cartel_sin_cuerdas.png"))
	assert(menu_editable.get_node("Fondo/Imagen Granja").texture.resource_path == "res://ui/introduccion_granja.svg")
	for boton in menu_editable.get_node("Centro Menu/Margen Interior/Botones Menu").find_children("*", "TextureButton", true, false):
		assert(boton.texture_normal != null and boton.texture_pressed != null, "Los sprites del menú deben verse en el editor.")
	menu_editable.free()
	assert(change_scene_to_file("res://ui/menu_principal.tscn") == OK)
	await _esperar_escena()
	current_scene._jugar()
	await _esperar_escena()
	assert(current_scene.scene_file_path == "res://ui/seleccion_partidas.tscn")
	assert(current_scene.espacios.get_child_count() == 3)
	for cartel in current_scene.espacios.get_children():
		assert(cartel.get_node("Boton Partida").text == "CREAR")
		assert(not cartel.get_node("Boton Eliminar").visible)
		assert(not cartel.get_node("Detalle Partida").visible)
		assert(is_equal_approx(cartel.get_node("Barra Avance").size.x, 242.0 * 2.0 / 3.0))
		assert(cartel.get_node("Nombre Nuevo").size.x == 162.0, "El campo de nombre debe medir 162 px de ancho como el cartel 3.")
		assert(cartel.get_node("Boton Eliminar").position.x > cartel.get_node("Barra Avance").get_rect().end.x)
		assert(cartel.get_node("Boton Eliminar").get_rect().end.x < cartel.get_node("Boton Partida").position.x)
		assert(cartel.get_node("Nombre Equipo").position.x >= 80, "El título debe quedar lejos de la cuerda izquierda.")
		assert(cartel.get_node("Nombre Nuevo").get_global_rect().end.y <= cartel.get_global_rect().end.y - 8, "El campo debe conservar margen inferior dentro de la madera.")
		assert(cartel.get_node("Boton Partida").get_global_rect().position.x >= cartel.get_node("Barra Avance").get_global_rect().end.x + 10, "La barra y el botón necesitan separación.")
		assert(current_scene.get_global_rect().encloses(cartel.get_global_rect()), "Los carteles deben caber en la pantalla.")
		for nombre_control in ["Boton Partida", "Boton Eliminar", "Nombre Nuevo", "Barra Avance"]:
			assert(current_scene.get_global_rect().encloses(cartel.get_node(nombre_control).get_global_rect()))
			assert(cartel.get_global_rect().encloses(cartel.get_node(nombre_control).get_global_rect()), "Los controles deben caber dentro de su cartel.")
	current_scene._seleccionar(1)
	assert(not partidas.existe(1), "El nombre vacío no debe crear un guardado.")
	var posicion_guardada := Vector2.ZERO
	for espacio in range(1, 4):
		var cartel: Control = current_scene.espacios.get_child(espacio - 1)
		cartel.get_node("Nombre Nuevo").text = " Equipo %d " % espacio
		if espacio == 2:
			cartel.get_node("Nombre Nuevo").text_submitted.emit(cartel.get_node("Nombre Nuevo").text)
		else:
			cartel.get_node("Boton Partida").pressed.emit()
		await _esperar_escena()
		assert(current_scene.scene_file_path == partidas.MUNDO)
		assert(partidas.espacio_activo == espacio)
		current_scene.process_mode = Node.PROCESS_MODE_DISABLED
		var jugador = current_scene.get_node("Nivel 1/Mago")
		jugador.global_position += Vector2(espacio * 32, 0)
		jugador.vida = espacio + 1
		if espacio == 1:
			posicion_guardada = jugador.global_position
		var ajustes = root.get_node("Ajustes")
		ajustes._pausar()
		assert(paused)
		var menu = ajustes.capa_pausa.get_child(0)
		for boton in menu._opciones_menu():
			assert(menu.get_global_rect().encloses(boton.get_global_rect()), "Un botón de pausa queda fuera de la pantalla.")
		menu._guardar_partida()
		assert(menu.mensaje.text == "PARTIDA %d GUARDADA." % espacio)
		assert(partidas.leer(espacio).jugadores[0].vida == espacio + 1)
		assert(partidas.leer(espacio).nombre == "Equipo %d" % espacio)
		assert(partidas.leer(espacio).nivel == 1)
		var guardado: Dictionary = partidas.leer(espacio)
		assert(partidas.crear(espacio) == ERR_ALREADY_EXISTS)
		assert(partidas.leer(espacio) == guardado)
		menu._salir()
		await _esperar_escena()
		assert(not paused)
		current_scene._jugar()
		await _esperar_escena()
	assert(not FileAccess.file_exists("user://partidas/partida_4.cfg"))
	for cartel in current_scene.espacios.get_children():
		assert(cartel.get_node("Boton Partida").text == "JUGAR")
		assert(cartel.get_node("Boton Eliminar").visible)
		assert(cartel.get_node("Barra Avance").visible)
		assert(not cartel.get_node("Nombre Nuevo").visible)
	current_scene.espacios.get_child(0).get_node("Boton Partida").pressed.emit()
	await _esperar_escena()
	current_scene.process_mode = Node.PROCESS_MODE_DISABLED
	var jugador = current_scene.get_node("Nivel 1/Mago")
	assert(jugador.global_position == posicion_guardada)
	assert(jugador.vida == 2)
	jugador.global_position.x = current_scene.get_node("Nivel 1/Camara Nivel").limit_right - 10
	assert(partidas.guardar_actual() == OK)
	var avance_maximo: int = partidas.leer(1).avance
	assert(avance_maximo >= 99)
	jugador.global_position = posicion_guardada
	assert(partidas.guardar_actual() == OK)
	assert(partidas.leer(1).avance == avance_maximo, "Retroceder no pierde el avance alcanzado.")
	# Un guardado anterior sin los tres campos nuevos sigue siendo válido.
	var antiguo := ConfigFile.new()
	assert(antiguo.load("user://partidas/partida_2.cfg") == OK)
	for campo in ["nombre", "nivel", "avance"]:
		antiguo.erase_section_key("partida", campo)
	assert(antiguo.save("user://partidas/partida_2.cfg") == OK)
	assert(partidas.leer(2).nombre == "Equipo 2")
	assert(partidas.leer(2).nivel == 1 and partidas.leer(2).avance == 0)
	# La muerte no puede reemplazar el último guardado válido.
	jugador.vida = 0
	assert(partidas.guardar_actual() == ERR_UNAVAILABLE)
	assert(partidas.leer(1).jugadores[0].vida == 2)
	assert(partidas.leer(2).jugadores[0].vida == 3)
	assert(partidas.leer(3).jugadores[0].vida == 4)
	var corrupto := ConfigFile.new()
	corrupto.set_value("partida", "version", 999)
	assert(corrupto.save("user://partidas/partida_3.cfg") == OK)
	assert(partidas.leer(3).is_empty())
	assert(partidas.crear(3) == ERR_ALREADY_EXISTS)
	assert(partidas.abrir(3) == ERR_FILE_CORRUPT)
	assert(change_scene_to_file("res://ui/seleccion_partidas.tscn") == OK)
	await _esperar_escena()
	assert(current_scene.espacios.get_child(2).get_node("Boton Partida").disabled)
	assert(current_scene.espacios.get_child(2).get_node("Detalle Partida").text == "ARCHIVO DAÑADO")
	var cancelar := InputEventAction.new()
	cancelar.action = "ui_cancel"
	cancelar.pressed = true
	var primera: Dictionary = partidas.leer(1)
	var segunda: Dictionary = partidas.leer(2)
	current_scene.espacios.get_child(0).get_node("Boton Eliminar").pressed.emit()
	assert(current_scene.confirmacion.visible)
	assert(current_scene.get_viewport().gui_get_focus_owner().name == "Boton Cancelar")
	assert(partidas.leer(1) == primera, "La X debe pedir confirmación antes de borrar.")
	current_scene._seleccionar(2)
	assert(current_scene.scene_file_path == "res://ui/seleccion_partidas.tscn")
	current_scene._unhandled_input(cancelar)
	assert(not current_scene.confirmacion.visible and partidas.leer(1) == primera)
	# También se puede liberar un espacio cuyo archivo esté dañado.
	current_scene.espacios.get_child(2).get_node("Boton Eliminar").pressed.emit()
	current_scene.get_node("Confirmar Borrado/Panel Borrado/Boton Eliminar").pressed.emit()
	assert(not partidas.existe(3))
	assert(current_scene.espacios.get_child(2).get_node("Boton Partida").text == "CREAR")
	assert(not current_scene.espacios.get_child(2).get_node("Boton Eliminar").visible)
	assert(current_scene.espacios.get_child(2).get_node("Nombre Nuevo").visible)
	assert(partidas.leer(1) == primera and partidas.leer(2) == segunda)
	partidas.espacio_activo = 1
	partidas.estado_pendiente = primera
	current_scene.espacios.get_child(0).get_node("Boton Eliminar").pressed.emit()
	current_scene.get_node("Confirmar Borrado/Panel Borrado/Boton Eliminar").pressed.emit()
	assert(not partidas.existe(1))
	assert(partidas.espacio_activo == 0 and partidas.estado_pendiente.is_empty())
	assert(partidas.leer(2) == segunda, "Eliminar una partida no debe alterar las demás.")
	assert(partidas.crear(1, "Equipo nuevo") == OK)
	assert(partidas.leer(1).nombre == "Equipo nuevo")
	current_scene._unhandled_input(cancelar)
	await _esperar_escena()
	assert(current_scene.scene_file_path == "res://ui/menu_principal.tscn")
	assert(not paused)
	for espacio in range(1, 4):
		DirAccess.remove_absolute("user://partidas/partida_%d.cfg" % espacio)
	print("PASS: carteles editables, creación, carga, progreso, borrado confirmado, cancelación y conservación de otras partidas.")
	quit()
