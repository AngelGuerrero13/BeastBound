extends Area2D

@export var velocidad: float = 180.0
@export var dano: int = 1
@export var tiempo_vida: float = 3.0

@onready var animacion: AnimatedSprite2D = $"animaciones espinas"

func _ready() -> void:
	animacion.sprite_frames.set_animation_loop("vuelo", true)
	animacion.play("vuelo")

	body_entered.connect(_cuando_colisiona)

	await get_tree().create_timer(tiempo_vida).timeout
	queue_free()


func _physics_process(delta: float) -> void:
	global_position.x -= velocidad * delta


func _cuando_colisiona(cuerpo: Node2D) -> void:
	if is_queued_for_deletion():
		return

	if cuerpo.is_in_group("Jugador"):
		cuerpo.recibir_dano(dano)
		queue_free()
