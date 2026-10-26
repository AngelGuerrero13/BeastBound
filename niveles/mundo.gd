extends Node2D

var nivel_actual: Node2D

func _ready() -> void:
	var niveles := _obtener_niveles()
	for n in niveles:
		_activar_nivel(n, false)

	nivel_actual = $Tutorial
	
	var ruta_guardada: String = Partidas.estado_pendiente.get("nivel_ruta", "")
	var guardado: int = Partidas.estado_pendiente.get("nivel", 0)
	
	for n in niveles:
		if ruta_guardada != "" and n.scene_file_path == ruta_guardada:
			nivel_actual = n
			break
		elif guardado > 0 and n.get("numero_nivel") == guardado:
			nivel_actual = n
			break
			
	_activar_nivel(nivel_actual, true)
	Partidas.aplicar_estado(self)

func _obtener_niveles() -> Array[Node2D]:
	var lista: Array[Node2D] = []
	for hijo in get_children():
		if hijo is Node2D and "camara" in hijo:
			lista.append(hijo)
	return lista

func ir_al_nivel(ruta: String) -> Error:
	var nuevo: Node2D = null
	for n in _obtener_niveles():
		if n.scene_file_path == ruta:
			nuevo = n
			break
	if nuevo == null:
		return ERR_INVALID_PARAMETER
	if nuevo == nivel_actual:
		return OK

	for jugador in get_tree().get_nodes_in_group("Jugador"):
		if not nivel_actual.is_ancestor_of(jugador) or not jugador.es_jugador:
			continue
		var entrada := nuevo.get_node_or_null(nivel_actual.get_path_to(jugador))
		if entrada != null:
			entrada.vida = jugador.vida

	_activar_nivel(nivel_actual, false)
	nivel_actual = nuevo
	_activar_nivel(nivel_actual, true)
	return OK

func ir_al_siguiente_nivel() -> Error:
	var niveles := _obtener_niveles()
	var i := niveles.find(nivel_actual)
	if i == -1 or i + 1 >= niveles.size():
		return ERR_DOES_NOT_EXIST
	return ir_al_nivel(niveles[i + 1].scene_file_path)

func _activar_nivel(nivel: Node2D, activo: bool) -> void:
	nivel.process_mode = Node.PROCESS_MODE_INHERIT if activo else Node.PROCESS_MODE_DISABLED
	nivel.visible = activo
	nivel.camara.enabled = activo
	
	for hijo in nivel.get_children():
		if hijo is CanvasLayer:
			hijo.visible = activo
	
	if activo:
		nivel._actualizar_objetivo()
		nivel.camara.make_current()
		nivel.camara.reset_smoothing()
