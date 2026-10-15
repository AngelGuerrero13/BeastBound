extends "res://personajes/enemigoBasico/enemigo_basico.gd"
@export var velocidad_ataque_rapido: float = 0.2  # Tiempo de recarga muy corto entre golpes
var ejecutando_rafaga: bool = false

func manejar_movimiento() -> void:
	if jugador_objetivo and is_instance_valid(jugador_objetivo):
		var distancia = global_position.distance_to(jugador_objetivo.global_position)
		
		# Si está lejos, corre hacia el jugador más veloz si gustas (puedes subirle la velocidad en el Inspector)
		if distancia > rango_ataque:
			super.manejar_movimiento()
		else:
			# Si está a distancia de contacto, se detiene momentáneamente para lanzar su ráfaga
			velocity = Vector2.ZERO
			
			if puede_atacar_normal and not ejecutando_rafaga:
				ejecutar_rafaga_rapida()
	else:
		velocity.x = 0

func ejecutar_rafaga_rapida() -> void:
	ejecutando_rafaga = true
	puede_atacar_normal = false
	
	# Da una serie de 2 o 3 ataques rápidos seguidos (estilo combo corto)
	for i in range(3):
		if jugador_objetivo and is_instance_valid(jugador_objetivo):
			# Comprueba que siga cerca antes de cada golpe de la ráfaga
			if global_position.distance_to(jugador_objetivo.global_position) <= rango_ataque + 15.0:
				ejecutar_ataque_normal(jugador_objetivo)
		
		# Espera un lapso muy corto entre golpe y golpe de la ráfaga
		await get_tree().create_timer(velocidad_ataque_rapido).timeout
		
		# Si el jugador se aleja demasiado a mitad de la ráfaga, corta los golpes restantes
		if not jugador_objetivo or global_position.distance_to(jugador_objetivo.global_position) > rango_ataque + 25.0:
			break
			
	# Cooldown o recarga un poco más larga tras terminar toda la ráfaga
	await get_tree().create_timer(tiempo_recarga_normal * 1.5).timeout
	puede_atacar_normal = true
	ejecutando_rafaga = false
