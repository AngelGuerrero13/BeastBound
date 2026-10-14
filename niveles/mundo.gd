extends Node2D

const NIVEL_2 := "res://niveles/nivel 2/nivel 2.tscn"
var nivel_actual: Node2D

func _ready() -> void:
	nivel_actual = $"Nivel 1"
	_activar_nivel($"Nivel 2", false)
	_activar_nivel(nivel_actual, true)
	if Partidas.estado_pendiente.get("nivel", 1) == 2:
		ir_al_nivel(NIVEL_2)
	Partidas.aplicar_estado(self)


func ir_al_nivel(ruta: String) -> Error:
	if ruta != NIVEL_2:
		return ERR_INVALID_PARAMETER
	var nuevo: Node2D = $"Nivel 2"
	if nuevo == nivel_actual:
		return OK
	for jugador in get_tree().get_nodes_in_group("Jugador"):
		if not nivel_actual.is_ancestor_of(jugador) or not jugador.es_jugador:
			continue
		var entrada := nuevo.get_node_or_null(nivel_actual.get_path_to(jugador))
		if entrada != null:
			entrada.vida = jugador.vida
			entrada.actualizar_corazones()
	_activar_nivel(nivel_actual, false)
	nivel_actual = nuevo
	_activar_nivel(nivel_actual, true)
	return OK


func _activar_nivel(nivel: Node2D, activo: bool) -> void:
	nivel.process_mode = Node.PROCESS_MODE_INHERIT if activo else Node.PROCESS_MODE_DISABLED
	nivel.visible = activo
	nivel.camara.enabled = activo
	for jugador in get_tree().get_nodes_in_group("Jugador"):
		if nivel.is_ancestor_of(jugador) and jugador.es_jugador:
			jugador.hud.visible = activo
	if activo:
		nivel._actualizar_objetivo()
		nivel.camara.make_current()
		nivel.camara.reset_smoothing()
