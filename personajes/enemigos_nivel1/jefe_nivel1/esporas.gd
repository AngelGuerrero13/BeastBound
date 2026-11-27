extends Area2D

@export var velocidad: float = 70.0
@export var dano: int = 1
@export var tiempo_vida: float = 4.0

var direccion: Vector2 = Vector2.LEFT

@onready var animacion: AnimatedSprite2D = $AnimacionEsporas

func _ready() -> void:
	animacion.sprite_frames.set_animation_loop("nube", true)
	animacion.play("nube")

	body_entered.connect(_cuando_colisiona)

	await get_tree().create_timer(tiempo_vida).timeout
	queue_free()


func _physics_process(delta: float) -> void:
	global_position += direccion * velocidad * delta

	velocidad = move_toward(velocidad, 15.0, 25.0 * delta)


func _cuando_colisiona(cuerpo: Node2D) -> void:
	if is_queued_for_deletion():
		return

	if cuerpo.is_in_group("Jugador"):
		cuerpo.recibir_dano(dano)
		queue_free()
