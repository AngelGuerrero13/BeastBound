extends "res://personajes/personajeBase/personaje_base.gd"

var jugador_objetivo: Node2D = null
var distancia_ataque: float = 40.0 # A cuántos píxeles de distancia intentará golpearte

func _ready() -> void:
	super() # Llama al _ready del padre (esto es lo que apaga el HUD gigante)
	
	# Busca en todo el juego quién tiene la etiqueta "Jugador"
	var jugadores = get_tree().get_nodes_in_group("Jugador")
	if jugadores.size() > 0:
		jugador_objetivo = jugadores[0]

func _physics_process(delta: float) -> void:
	# 1. Aplicamos la gravedad que ya estaba programada en la base
	manejar_gravedad_y_salto(delta)
	
	# 2. IA de persecución y ataque
	if jugador_objetivo and is_instance_valid(jugador_objetivo):
		# Calcula la distancia exacta entre el enemigo y el jugador
		var distancia = global_position.distance_to(jugador_objetivo.global_position)
		
		if distancia > distancia_ataque:
			# Si está lejos, camina hacia el jugador
			var direccion = (jugador_objetivo.global_position - global_position).normalized()
			velocity = direccion * velocidad
			
			# Voltea el sprite para mirar hacia dónde camina
			if sprite:
				sprite.flip_h = direccion.x < 0
				actualizar_offset_horizontal()
		else:
			# Si está lo suficientemente cerca, se detiene y golpea
			velocity = Vector2.ZERO 
			
			if puede_atacar_normal:
				puede_atacar_normal = false
				ejecutar_ataque_normal(jugador_objetivo) # Usa la función de daño de tu base
				
				# Espera su tiempo de recarga antes de volver a golpear
				await get_tree().create_timer(tiempo_recarga_normal).timeout
				puede_atacar_normal = true
	else:
		# Si el jugador muere o desaparece, el enemigo se queda quieto
		velocity.x = 0 
		
	# 3. Aplicar el movimiento final
	move_and_slide()
