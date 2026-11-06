extends "res://personajes/personajeBase/personaje_base.gd"

@export_group("Combate Tirador")
@export var escena_flecha: PackedScene
@export var angulo_flechas_cargado: float = 15.0
@export var multiplicador_dano_cargado: float = 1.0

@onready var punto_disparo: Marker2D = $"Origen Disparo"

func ejecutar_ataque_normal(_objetivo) -> void:
	disparar_flecha(obtener_direccion_frente(), dano)

func ejecutar_ataque_cargado(_objetivo) -> void:
	if not es_jugador:
		return
	
	var dir = obtener_direccion_frente()
	var dano_flecha = int(dano * multiplicador_dano_cargado)
	var angulo = deg_to_rad(angulo_flechas_cargado)
	
	disparar_flecha(dir, dano_flecha)
	disparar_flecha(dir.rotated(angulo), dano_flecha)
	disparar_flecha(dir.rotated(-angulo), dano_flecha)

func disparar_flecha(dir: Vector2, dano_flecha: int) -> void:
	if not escena_flecha:
		print("Error: falta asignar la escena de la flecha en el Inspector del Tirador.")
		return
	
	var flecha = escena_flecha.instantiate()
	get_tree().current_scene.add_child(flecha)
	
	var frente = obtener_direccion_frente()
	flecha.global_position = global_position + Vector2(abs(punto_disparo.position.x) * frente.x, punto_disparo.position.y)
	flecha.configurar_flecha(self, dir, dano_flecha, es_jugador)
