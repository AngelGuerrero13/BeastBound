extends Control

@export_file("*.tscn") var escena_destino := "res://ui/Mapa/mapa_mundo.tscn"
@export_range(0.1, 2.0, 0.05) var pausa_final := 0.35

@onready var porcentaje: Label = $"Panel Carga/Estado/Porcentaje"
@onready var texto_estado: Label = $"Panel Carga/Estado/Texto Estado"
@onready var boton_volver: Button = $"Boton Volver"

var progreso := 0
var progreso_mostrado := 0.0
var tiempo_carga := 0.0
var preparando_mapa := false
var escena_preparada: Node


func _ready() -> void:
	set_process(false)
	boton_volver.pressed.connect(_volver)
	_actualizar_progreso(0)
	# Dibujar primero el fondo, incluso si el mapa ya está en caché.
	await _esperar_dibujo()
	var estado := ResourceLoader.load_threaded_get_status(escena_destino)
	if estado == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		var resultado := ResourceLoader.load_threaded_request(escena_destino, "PackedScene")
		if resultado != OK:
			_mostrar_error()
			return
	set_process(true)


func _process(delta: float) -> void:
	tiempo_carga += delta
	texto_estado.text = "Cargando" + ".".repeat(1 + int(tiempo_carga / 0.4) % 3)
	var objetivo := 100.0
	if escena_preparada == null:
		var avance: Array = []
		var estado := ResourceLoader.load_threaded_get_status(escena_destino, avance)
		match estado:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				objetivo = _objetivo_carga(float(avance[0]) if not avance.is_empty() else 0.0)
			ResourceLoader.THREAD_LOAD_LOADED:
				objetivo = 90.0
				if not preparando_mapa:
					preparando_mapa = true
					_preparar_mapa()
			ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				_mostrar_error()
				return
	progreso_mostrado = move_toward(progreso_mostrado, maxf(progreso_mostrado, objetivo), minf(delta, 0.05) * 35.0)
	_actualizar_progreso(floori(progreso_mostrado))
	if progreso == 100:
		set_process(false)
		_mostrar_mapa()


func _objetivo_carga(avance: float) -> float:
	# Estimación visual cuando el cargador no publica nuevos valores; reserva el final para preparar el mapa.
	return maxf(clampf(avance, 0.0, 1.0) * 85.0, 85.0 * (1.0 - exp(-tiempo_carga / 5.0)))


func _preparar_mapa() -> void:
	await _esperar_dibujo()
	var recurso := ResourceLoader.load_threaded_get(escena_destino) as PackedScene
	if recurso == null:
		_mostrar_error()
		return
	# Instanciar y ejecutar _ready antes de anunciar el 100 %.
	escena_preparada = recurso.instantiate()
	if escena_preparada == null:
		_mostrar_error()
		return
	escena_preparada.process_mode = Node.PROCESS_MODE_DISABLED
	if escena_preparada is CanvasItem:
		escena_preparada.hide()
	get_tree().root.add_child(escena_preparada)


func _mostrar_mapa() -> void:
	await _esperar_dibujo()
	# Breve pausa para que el 100 % sea visible; no simula progreso de carga.
	await get_tree().create_timer(pausa_final).timeout
	var arbol := get_tree()
	arbol.current_scene = escena_preparada
	escena_preparada.process_mode = Node.PROCESS_MODE_INHERIT
	if escena_preparada is CanvasItem:
		escena_preparada.show()
	queue_free()


func _actualizar_progreso(valor: int) -> void:
	progreso = maxi(progreso, valor)
	porcentaje.text = "%d %%" % progreso


func _esperar_dibujo() -> void:
	if DisplayServer.get_name() == "headless":
		await get_tree().process_frame
	else:
		await RenderingServer.frame_post_draw


func _mostrar_error() -> void:
	set_process(false)
	texto_estado.text = "No se pudo cargar el mapa."
	porcentaje.hide()
	boton_volver.show()
	boton_volver.grab_focus()


func _volver() -> void:
	if Ajustes.cambiar_escena("res://ui/seleccion_personaje/seleccion_personaje.tscn") != OK:
		texto_estado.text = "No se pudo volver."


func _exit_tree() -> void:
	if is_instance_valid(escena_preparada) and get_tree().current_scene != escena_preparada:
		escena_preparada.queue_free()
