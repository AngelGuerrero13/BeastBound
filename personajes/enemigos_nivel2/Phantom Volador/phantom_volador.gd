extends "res://personajes/enemigoBasico/enemigo_basico.gd"
@export var escena_proyectil: PackedScene
@export var altura_flote: float = 50.0 # Altura extra para mantenerse en el aire sobre el jugador

@onready var punto_disparo: Marker2D = get_node_or_null("PuntoDisparo")

# 1. IGNORAR GRAVEDAD: Anulamos la función del padre sin tocar _physics_process
func manejar_gravedad_y_salto(_delta: float) -> void:
	pass

# 2. IA DE VUELO: Dejamos que super() voltee el sprite y aplicamos movimiento libre en 2D
func manejar_movimiento() -> void:
	super()
	
	if jugador_objetivo and is_instance_valid(jugador_objetivo):
		var distancia = global_position.distance_to(jugador_objetivo.global_position)
		# Se acerca hasta entrar bien dentro del rango de disparo (85%) y luego flota en el sitio
		if distancia > rango_ataque * 0.85:
			var destino = jugador_objetivo.global_position + Vector2(0, -altura_flote)
			velocity = global_position.direction_to(destino) * velocidad
		else:
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO

# 3. ATAQUE A DISTANCIA: Instancia el proyectil usando el 'dano' y cooldown heredados
func ejecutar_ataque_normal(objetivo) -> void:
	puede_atacar_normal = false
	
	if escena_proyectil and is_instance_valid(objetivo):
		var proyectil = escena_proyectil.instantiate()
		var origen = punto_disparo.global_position if punto_disparo else global_position
		
		proyectil.global_position = origen
		proyectil.direccion = origen.direction_to(objetivo.global_position)
		proyectil.dano = dano
		
		# Se agrega a la escena principal para que el proyectil sea independiente del enemigo
		get_tree().current_scene.add_child(proyectil)
		
	await get_tree().create_timer(tiempo_recarga_normal).timeout
	puede_atacar_normal = true
