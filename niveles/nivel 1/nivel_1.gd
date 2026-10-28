extends Node2D

@export var numero_nivel: int = 1
@export_file("*.tscn") var siguiente_nivel: String = ""
@export_range(0.0, 64.0, 1.0) var anticipacion_horizontal: float = 24.0
@export_range(1.0, 30.0, 0.5) var suavizado_camara: float = 12.0

@onready var camara: Camera2D = $"Camara Nivel"
@onready var spawner_jugadores = $PuntosSpawn

var jugador_seguido: Node2D
var cambiando_nivel := false

func _ready() -> void:
	spawner_jugadores.generar_jugadores()
	
	var posicion_inicial_x = 0.0
	var lista_jugadores = spawner_jugadores.jugadores_generados
	
	if lista_jugadores.size() > 0:
		posicion_inicial_x = lista_jugadores[0].global_position.x
		
	set_meta("inicio_avance", posicion_inicial_x)
	
	var suelo: TileMapLayer = $"Fondo/Suelo Pasto"
	var area: Rect2i = suelo.get_used_rect()
	var tamano_tile: Vector2i = suelo.tile_set.tile_size
	
	camara.position_smoothing_speed = suavizado_camara

	process_priority = 10
	camara.process_priority = 20
	camara.limit_left = roundi(suelo.to_global(Vector2(area.position * tamano_tile)).x)
	camara.limit_right = roundi(suelo.to_global(Vector2(area.end * tamano_tile)).x)
	for heredada in find_children("*", "Camera2D", true, false):
		if heredada != camara:
			heredada.enabled = false
	_actualizar_objetivo()
	camara.enabled = process_mode != Node.PROCESS_MODE_DISABLED
	if camara.enabled:
		camara.make_current()
		camara.reset_smoothing()

func _salir_del_nivel(cuerpo: Node2D) -> void:
	if cambiando_nivel or siguiente_nivel.is_empty():
		return
	if not cuerpo.is_in_group("Jugador") or not cuerpo.es_jugador or cuerpo.vida <= 0:
		return
	cambiando_nivel = true
	# Cambiar fuera del paso de fisica del Area2D.
	call_deferred("_cambiar_nivel")

func _cambiar_nivel() -> void:
	var mundo := get_parent()
	var resultado: Error
	if mundo.has_method("ir_al_siguiente_nivel"):
		resultado = mundo.ir_al_siguiente_nivel()
	else:
		resultado = Ajustes.cambiar_escena(siguiente_nivel)
	if resultado != OK:
		cambiando_nivel = false
		push_error("No se pudo abrir el siguiente nivel: %s" % error_string(resultado))

func _process(_delta: float) -> void:
	_actualizar_objetivo()
	if not camara.is_current():
		camara.make_current()

func _actualizar_objetivo() -> void:
	var primero: Node2D = null
	for candidato in get_tree().get_nodes_in_group("Jugador"):
		if not candidato is Node2D or not is_ancestor_of(candidato) or candidato.is_queued_for_deletion():
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
