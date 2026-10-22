extends CanvasLayer

@onready var huds: Array[Node] = $Interfaces.get_children()

var vinculados: Array[Node] = []

func _ready() -> void:
	for h in huds:
		h.hide() 

func _process(_delta: float) -> void:
	var actuales: Array = []
	for j in get_tree().get_nodes_in_group("Jugador"):
		if j.es_jugador and not j.is_queued_for_deletion() and j.can_process():
			actuales.append(j)

	var hay_nuevo := false
	for j in actuales:
		if not vinculados.has(j):
			hay_nuevo = true
			break
	if hay_nuevo:
		vincular_jugadores(actuales)

func vincular_jugadores(jugadores: Array) -> void:
	jugadores.sort_custom(func(a, b): return a.prefijo_input < b.prefijo_input)
	for i in huds.size():
		if i < jugadores.size():
			huds[i].vincular(jugadores[i])
		else:
			huds[i].hide()
			
	vinculados.clear()
	for j in jugadores:
		vinculados.append(j)
