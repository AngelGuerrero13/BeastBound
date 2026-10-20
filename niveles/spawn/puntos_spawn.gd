extends Node2D

@export var escenas_personajes: Array[PackedScene]

func generar_jugadores():
	if Ajustes.jugadores_seleccionados.is_empty():
		print("Prueba rápida: Generando al Mapache por defecto para P1")
		Ajustes.jugadores_seleccionados["p1"] = 0
	
	var i = 0
	var puntos = get_children()
	
	for prefijo in Ajustes.jugadores_seleccionados.keys():
		var indice_personaje = Ajustes.jugadores_seleccionados[prefijo]
		var nuevo_personaje = escenas_personajes[indice_personaje].instantiate()
		
		var indice_punto = min(i, puntos.size() - 1)
		nuevo_personaje.global_position = puntos[indice_punto].global_position
		
		if nuevo_personaje.get("prefijo_input") != null:
			nuevo_personaje.prefijo_input = prefijo
		
		get_parent().call_deferred("add_child", nuevo_personaje)
		
		i += 1
