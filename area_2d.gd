extends "res://personajes/proyectil_base.gd"

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
		
	if has_node("Imagen") and get_node("Imagen") is AnimatedSprite2D:
		$"Imagen".play("default")
