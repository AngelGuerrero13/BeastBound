extends Node2D

@export_range(0.0, 64.0, 1.0) var anticipacion_horizontal: float = 24.0
@export_range(1.0, 30.0, 0.5) var suavizado_camara: float = 12.0

@onready var camara: Camera2D = $"Camara Nivel"
var jugador_seguido: Node2D

func _ready() -> void:
	var suelo: TileMapLayer = $"Fondo/Suelo Pasto"
	var area: Rect2i = suelo.get_used_rect()
	var tamano_tile: Vector2i = suelo.tile_set.tile_size
	camara.position_smoothing_speed = suavizado_camara
	# Actualizar el objetivo antes de que la cámara calcule la vista.
	process_priority = 10
	camara.process_priority = 20
	camara.limit_left = roundi(suelo.to_global(Vector2(area.position * tamano_tile)).x)
	camara.limit_right = roundi(suelo.to_global(Vector2(area.end * tamano_tile)).x)
	for heredada in find_children("*", "Camera2D", true, false):
		if heredada != camara:
			heredada.enabled = false
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
