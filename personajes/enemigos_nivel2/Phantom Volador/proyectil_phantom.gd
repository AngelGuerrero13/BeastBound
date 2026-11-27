extends Node2D
@export var velocidad: float = 350.0
@export var tiempo_vida: float = 4.0

var direccion: Vector2 = Vector2.RIGHT
var dano: int = 1

func _ready() -> void:
	# Rota el proyectil para que apunte hacia donde viaja
	rotation = direccion.angle()
	# Seguro anti-fugas de memoria: se destruye solo tras cumplir su tiempo de vida
	get_tree().create_timer(tiempo_vida).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	position += direccion * velocidad * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		if body.has_method("recibir_dano"):
			body.recibir_dano(dano)
		queue_free()
	elif not body.is_in_group("Enemigos"):
		# Se destruye al chocar contra paredes o el suelo
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
