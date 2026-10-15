extends "res://personajes/enemigoBasico/enemigo_basico.gd"
@export var tiempo_anticipacion_cabezazo: float = 0.35 # Pausa de tensión antes del impacto

# Hereda toda la persecución y el movimiento del enemigo básico,
# pero le damos su propia identidad en el momento de golpear.
func manejar_movimiento() -> void:
	if jugador_objetivo and is_instance_valid(jugador_objetivo):
		var distancia = global_position.distance_to(jugador_objetivo.global_position)
		
		# Si está lejos, camina hacia el jugador usando la lógica normal del enemigo básico
		if distancia > distancia_ataque:
			super.manejar_movimiento()
		else:
			# Si llega al rango de contacto, se planta en seco para dar el cabezazo
			velocity = Vector2.ZERO
			
			if puede_atacar_normal:
				ejecutar_cabezazo_pesado()
	else:
		velocity.x = 0

func ejecutar_cabezazo_pesado() -> void:
	puede_atacar_normal = false
	
	# 1. El hongo frena en seco y concentra la fuerza (Wind-up / Anticipación)
	velocity = Vector2.ZERO
	await get_tree().create_timer(tiempo_anticipacion_cabezazo).timeout
	
	# 2. El impacto seco sobre el jugador
	if jugador_objetivo and is_instance_valid(jugador_objetivo):
		# Damos un pequeño margen de tolerancia por si el jugador se movió un pelo
		if global_position.distance_to(jugador_objetivo.global_position) <= distancia_ataque + 15.0:
			# Usa directamente la función heredada de la base para restarle vida al jugador
			ejecutar_ataque_normal(jugador_objetivo)
			
	# 3. Recuperación tras el golpe antes de poder volver a atacar
	await get_tree().create_timer(tiempo_recarga_normal).timeout
	puede_atacar_normal = true
