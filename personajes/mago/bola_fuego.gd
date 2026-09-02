extends Area2D

var objetivo: Node2D = null
var velocidad: float = 400.0
var dano: int = 10
var es_ataque_cargado: bool = false

var direccion_vuelo: Vector2 = Vector2.ZERO
var tiempo_vida: float = 3.0

func configurar(nuevo_objetivo: Node2D, cargado: bool, direccion_base: Vector2):
	objetivo = nuevo_objetivo
	es_ataque_cargado = cargado

	# Normalizamos la dirección base
	direccion_vuelo = direccion_base.normalized()

	# Rotación inicial en 360 grados hacia el objetivo o el cursor
	rotation = direccion_vuelo.angle()

	if es_ataque_cargado:
		dano = 40
		velocidad = 250.0
		scale = Vector2(3, 3)
	else:
		dano = 10
		velocidad = 500.0
		scale = Vector2(1, 1)


func _physics_process(delta):
	# Animacion
	$AnimatedSprite2D.play("default")
	
	# Temporizador de autodestrucción si no choca con nada
	tiempo_vida -= delta
	if tiempo_vida <= 0:
		queue_free()

	# Si está persiguiendo a un objetivo, actualiza la dirección constantemente
	if objetivo and is_instance_valid(objetivo):
		direccion_vuelo = (objetivo.global_position - global_position).normalized()
		
		# Actualiza la rotación en el aire para que la bola "gire" mientras persigue al objetivo
		rotation = direccion_vuelo.angle()

	# Movimiento constante
	global_position += direccion_vuelo * velocidad * delta


func _on_body_entered(body):
	# Si choca con el objetivo marcado
	if objetivo and body == objetivo:
		if body.has_method("recibir_dano"):
			body.recibir_dano(dano)
			queue_free()

	# Si fue un disparo libre (sin objetivo) y choca con cualquier cosa que reciba daño
	elif not objetivo and body.has_method("recibir_dano"):
		body.recibir_dano(dano)
		queue_free()
