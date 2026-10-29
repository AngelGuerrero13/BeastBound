extends Node2D

@export var escenas_personajes: Array[PackedScene]
var jugadores_generados: Array[Node2D] = []
var generado := false

func generar_jugadores() -> void:
	if generado:
		return
	var seleccion: Dictionary = Ajustes.jugadores_seleccionados.duplicate()
	if seleccion.is_empty():
		seleccion = {"p1": 0}
	var puntos: Array[Marker2D] = []
	for hijo in get_children():
		if hijo is Marker2D:
			puntos.append(hijo)
	var prefijos := seleccion.keys()
	prefijos.sort()
	if puntos.size() < prefijos.size():
		push_error("Faltan puntos de aparición para los jugadores en " + str(get_path()))
		return
	for prefijo in prefijos:
		var indice: int = seleccion[prefijo]
		if indice < 0 or indice >= escenas_personajes.size() or escenas_personajes[indice] == null:
			push_error("Personaje seleccionado inválido: " + str(indice))
			return
	generado = true
	var nivel := get_parent() as Node2D
	for i in prefijos.size():
		var prefijo: String = prefijos[i]
		var personaje := escenas_personajes[seleccion[prefijo]].instantiate() as Node2D
		personaje.name = "Jugador " + prefijo
		personaje.prefijo_input = prefijo
		# Posición local correcta antes de _ready, incluso si el nivel está desplazado.
		personaje.position = nivel.to_local(puntos[i].global_position)
		for camara in personaje.find_children("*", "Camera2D", true, false):
			camara.enabled = false
		nivel.add_child(personaje)
		jugadores_generados.append(personaje)
