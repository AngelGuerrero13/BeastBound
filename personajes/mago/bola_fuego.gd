extends Area2D

var objetivo: Node2D = null
var velocidad: float = 400.0
var dano: int = 10
var es_ataque_cargado: bool = false

var direccion_vuelo: Vector2 = Vector2.ZERO
var tiempo_vida: float = 3.0
	
func _ready() -> void:
	# La animación arranca una sola vez al crearse la bola
	$AnimatedSprite2D.play("default")

func configurar(nuevo_objetivo: Node2D, cargado: bool, direccion_base: Vector2):
	objetivo = nuevo_objetivo
	es_ataque_cargado = cargado

	# Normalizamos la dirección base
	direccion_vuelo = direccion_base.normalized()

	# Rotación inicial en 360 grados hacia el objetivo o el cursor
	rotation = direccion_vuelo.angle()

	if es_ataque_cargado:
		dano = 2
		velocidad = 200.0
		scale = Vector2(3, 3)
	else:
		dano = 1
		velocidad = 300.0
		scale = Vector2(1, 1)


func _physics_process(delta):
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
	# Código blindado: Si puede recibir daño y NO es el jugador, lo quemamos.
	if body.has_method("recibir_dano"):
		if "es_jugador" in body and not body.es_jugador:
			body.recibir_dano(dano)
			queue_free()
