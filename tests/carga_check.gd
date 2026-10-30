extends SceneTree

const CARGA := "res://ui/carga.tscn"
const SELECCION := "res://ui/seleccion_personaje/seleccion_personaje.tscn"


func _initialize() -> void:
	call_deferred("_comprobar")


func _comprobar() -> void:
	var pantalla = load(CARGA).instantiate()
	var fondo: TextureRect = pantalla.get_node("Fondo")
	assert(fondo.texture != null, "El fondo debe existir en la escena antes de ejecutar el juego.")
	var tamano := fondo.texture.get_size()
	assert(absf(tamano.x / tamano.y - 16.0 / 9.0) < 0.005, "El encuadre debe tener proporción 16:9 para evitar deformar el fondo.")
	var atlas := fondo.texture as AtlasTexture
	assert(atlas != null)
	assert(atlas.atlas.resource_path == "res://assets/art/fondos/carga/fondo_carga_aprobado.png")
	var panel: PanelContainer = pantalla.get_node("Panel Carga")
	assert(panel.anchor_left == 1.0 and panel.anchor_top == 1.0 and panel.anchor_right == 1.0 and panel.anchor_bottom == 1.0, "El porcentaje debe estar anclado abajo a la derecha.")
	assert(panel.offset_right < 0 and panel.offset_bottom < 0)
	var porcentaje: Label = pantalla.get_node("Panel Carga/Estado/Porcentaje")
	assert(porcentaje.text == "0 %" and porcentaje.horizontal_alignment == HORIZONTAL_ALIGNMENT_RIGHT)
	assert(not pantalla.get_node("Boton Volver").visible)
	# Aunque el cargador repita el mismo avance, la estimación visual debe seguir moviéndose.
	pantalla.tiempo_carga = 2.0
	var primero: float = pantalla._objetivo_carga(0.2)
	pantalla.tiempo_carga = 6.0
	var segundo: float = pantalla._objetivo_carga(0.2)
	assert(segundo > primero and segundo < 85.0)
	pantalla.tiempo_carga = 0.0

	pantalla.escena_destino = "res://tests/escena_inexistente_carga.tscn"
	assert(not FileAccess.file_exists(pantalla.escena_destino))
	root.get_node("Ajustes").jugadores_seleccionados = {"p1": 1, "p2": 3}
	root.add_child(pantalla)
	current_scene = pantalla
	var limite := Time.get_ticks_msec() + 5000
	while not pantalla.boton_volver.visible and Time.get_ticks_msec() < limite:
		await process_frame
	assert(pantalla.boton_volver.is_visible_in_tree(), "Una carga fallida debe permitir volver.")
	assert(pantalla.texto_estado.text == "No se pudo cargar el mapa.")
	assert(not porcentaje.visible and pantalla.progreso < 100, "Una carga fallida no debe mostrar 100 %.")
	assert(not pantalla.is_processing())
	assert(pantalla.get_global_rect().encloses(panel.get_global_rect()), "El panel debe quedar dentro del viewport.")
	assert(panel.get_global_rect().end.x <= pantalla.size.x and panel.get_global_rect().end.y <= pantalla.size.y)

	pantalla.boton_volver.pressed.emit()
	limite = Time.get_ticks_msec() + 5000
	while (current_scene == null or current_scene.scene_file_path != SELECCION) and Time.get_ticks_msec() < limite:
		await process_frame
	assert(current_scene != null and current_scene.scene_file_path == SELECCION, "Volver debe recuperar la selección de personaje.")
	assert(root.get_node("Ajustes").jugadores_seleccionados == {"p1": 1, "p2": 3})
	assert(not paused)
	current_scene.queue_free()
	current_scene = null
	await process_frame
	await process_frame
	print("PASS: fondo editable 16:9, porcentaje abajo a la derecha, error de carga y botón Volver.")
	quit()
