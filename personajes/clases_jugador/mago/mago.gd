extends "res://personajes/personajeBase/personaje_base.gd"

@export var escena_bola_magica: PackedScene

@onready var punto_disparo: Marker2D = $"Origen Disparo"

func ejecutar_ataque_normal(objetivo: Node2D) -> void:
	disparar_bola(objetivo, false)

func ejecutar_ataque_cargado(objetivo: Node2D) -> void:
	disparar_bola(objetivo, true)

func disparar_bola(objetivo: Node2D, es_cargada: bool) -> void:
	if not escena_bola_magica:
		print("Error: La escena de la bola mágica no ha sido asignada en el Inspector del Mago.")
		return
	
	var dir = obtener_direccion_frente()
	
	var nueva_bola = escena_bola_magica.instantiate()
	get_tree().current_scene.add_child(nueva_bola)
	
	nueva_bola.global_position = global_position + Vector2(abs(punto_disparo.position.x) * dir.x, punto_disparo.position.y)
	
	nueva_bola.configurar_bola(objetivo, es_cargada, dir)
