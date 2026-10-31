extends "res://personajes/personajeBase/personaje_base.gd"

@export var escena_flecha: PackedScene
@onready var animacion_raton: AnimatedSprite2D = $"Imagen Personaje/Animacion Raton"
@onready var origen_flecha: Marker2D = $"Origen Flecha"

func _ready() -> void:
	super()
	animacion_raton.play("reposo")

func _physics_process(delta: float) -> void:
	# El movimiento, el salto y la orientación siguen perteneciendo a la base.
	super(delta)
	animacion_raton.flip_h = sprite.flip_h
	if esta_atacando:
		return
	if velocity.is_zero_approx():
		animacion_raton.play("reposo")
	elif absf(velocity.y) > absf(velocity.x):
		animacion_raton.play("caminar_arriba" if velocity.y < 0 else "caminar_abajo")
	else:
		animacion_raton.play("caminar")

func ejecutar_ataque_normal(_objetivo: Node2D) -> void:
	disparar_flecha(dano)

func ejecutar_ataque_cargado(_objetivo: Node2D) -> void:
	disparar_flecha(dano * 2)

func disparar_flecha(dano_disparo: int) -> void:
	animacion_raton.play("atacar")
	if escena_flecha == null:
		return
	var flecha := escena_flecha.instantiate() as Area2D
	var direccion := get_global_mouse_position() - origen_flecha.global_position
	if direccion.is_zero_approx():
		direccion = Vector2.LEFT if sprite.flip_h else Vector2.RIGHT
	flecha.configurar_flecha(self, direccion.normalized(), dano_disparo)
	get_parent().add_child(flecha)
	flecha.global_position = origen_flecha.global_position
