extends Node2D

@export_range(0.0, 64.0, 1.0) var anticipacion_horizontal: float = 24.0
@export_range(1.0, 30.0, 0.5) var suavizado_camara: float = 12.0

var camara: Camera2D
var jugador_seguido: Node2D

func _ready() -> void:
	var suelo: TileMapLayer = $Fondo/Pasto
	var area: Rect2i = suelo.get_used_rect()
	var tamano_tile: Vector2i = suelo.tile_set.tile_size
	var camara_anterior: Camera2D = $Mago/Camera2D
	camara = Camera2D.new()
	camara.name = "CamaraNivel"
	camara.zoom = camara_anterior.zoom
	camara.drag_horizontal_enabled = false
	camara.drag_vertical_enabled = camara_anterior.drag_vertical_enabled
	camara.drag_top_margin = camara_anterior.drag_top_margin
	camara.drag_bottom_margin = camara_anterior.drag_bottom_margin
	camara.position_smoothing_enabled = true
	camara.position_smoothing_speed = suavizado_camara
	# Actualizar el objetivo antes de que la cámara calcule la vista.
	process_priority = 10
	camara.process_priority = 20
	camara.limit_left = roundi(suelo.to_global(Vector2(area.position * tamano_tile)).x)
	camara.limit_right = roundi(suelo.to_global(Vector2(area.end * tamano_tile)).x)
	for heredada in find_children("*", "Camera2D", true, false):
		heredada.enabled = false
	add_child(camara)
	_actualizar_objetivo()
	camara.make_current()
	camara.reset_smoothing()

func _process(_delta: float) -> void:
	_actualizar_objetivo()
	if not camara.is_current():
		camara.make_current()

func _actualizar_objetivo() -> void:
	var primero: Node2D = null
	for candidato in get_tree().get_nodes_in_group("Jugador"):
		if not candidato is Node2D or candidato.is_queued_for_deletion():
			continue
		# También desactivar las cámaras de jugadores incorporados después.
		for heredada in candidato.find_children("*", "Camera2D", true, false):
			heredada.enabled = false
		if "es_jugador" in candidato and not candidato.es_jugador:
			continue
		if "vida" in candidato and candidato.vida <= 0:
			continue
		if primero == null or candidato.global_position.x > primero.global_position.x:
			primero = candidato
	jugador_seguido = primero
	# La cámara pertenece al nivel: sobrevive al jugador que estaba siguiendo.
	if jugador_seguido != null:
		camara.global_position = jugador_seguido.global_position + Vector2(anticipacion_horizontal, 0)
