extends CanvasLayer

@onready var h_box_container: HBoxContainer = $Interfaces

func _ready() -> void:
	await get_tree().process_frame
	
	var paneles_hud = h_box_container.get_children()
	
	for panel in paneles_hud:
		panel.visible = false
		
	var lista_jugadores = get_tree().get_nodes_in_group("Jugador")
	
	for jugador in lista_jugadores:
		if "prefijo_input" in jugador:
			var numero_jugador = int(jugador.prefijo_input.get_slice("p", 1))
			var indice = numero_jugador - 1
			
			if indice >= 0 and indice < paneles_hud.size():
				var panel_asignado = paneles_hud[indice]
				panel_asignado.visible = true
				
				if jugador.has_signal("vida_cambiada"):
					jugador.vida_cambiada.connect(func(nueva_vida):
						if panel_asignado.has_method("actualizar_corazones"):
							panel_asignado.actualizar_corazones(nueva_vida, jugador.vida_maxima)
					)
