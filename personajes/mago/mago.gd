extends "res://personajes/personajeBase/personaje_base.gd"

@export var escena_bola_magica: PackedScene

# Busca el marcador invisible en la punta del bastón
@onready var punto_disparo: Marker2D = $PuntoDisparo

func ejecutar_ataque_normal(objetivo: Node2D) -> void:
	disparar_bola(objetivo, false)

func ejecutar_ataque_cargado(objetivo: Node2D) -> void:
	disparar_bola(objetivo, true)

func disparar_bola(objetivo: Node2D, es_cargada: bool) -> void:
	if escena_bola_magica:
		var nueva_bola = escena_bola_magica.instantiate()
		
		get_tree().current_scene.add_child(nueva_bola)
		
		nueva_bola.global_position = punto_disparo.global_position
		
		# Calculamos el ángulo hacia el ratón
		var direccion_hacia_raton = get_global_mouse_position() - punto_disparo.global_position
		
		# Le enviamos toda la información al script de la bola
		nueva_bola.configurar(objetivo, es_cargada, direccion_hacia_raton)
	else:
		print("Error: La escena de la bola mágica no ha sido asignada en el Inspector del Mago.")
