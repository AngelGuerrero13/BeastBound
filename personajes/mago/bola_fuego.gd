extends Area2D

var objetivo: Node2D = null
var velocidad: float = 400.0
var dano: int = 10
var es_ataque_cargado: bool = false

# Nuevas variables para el vuelo libre
var direccion_vuelo: Vector2 = Vector2.ZERO
var tiempo_vida: float = 3.0 

# Ahora la función recibe un tercer parámetro: la dirección base
func configurar(nuevo_objetivo: Node2D, cargado: bool, direccion_base: Vector2):
	objetivo = nuevo_objetivo
	es_ataque_cargado = cargado
	direccion_vuelo = direccion_base.normalized()
	
	if es_ataque_cargado:
		dano = 40
		velocidad = 250.0
		scale = Vector2(3, 3)
	else:
		dano = 10
		velocidad = 500.0
		scale = Vector2(1, 1)

func _physics_process(delta):
	# Restamos tiempo de vida. Si llega a 0, se destruye para no saturar la memoria
	tiempo_vida -= delta
	if tiempo_vida <= 0:
		queue_free()

	# Si hay un objetivo válido, actualizamos la dirección para perseguirlo
	if objetivo and is_instance_valid(objetivo):
		direccion_vuelo = (objetivo.global_position - global_position).normalized()
	
	# Nos movemos en la dirección actual (ya sea persiguiendo o en línea recta)
	global_position += direccion_vuelo * velocidad * delta

func _on_body_entered(body):
	# Si tenemos un objetivo específico y chocamos con él
	if objetivo and body == objetivo:
		if body.has_method("recibir_dano"):
			body.recibir_dano(dano)
		queue_free()
		
	# Si NO teníamos objetivo (disparo a ciegas) pero le dimos a un enemigo por accidente
	elif not objetivo and body.has_method("recibir_dano"):
		body.recibir_dano(dano)
		queue_free()
