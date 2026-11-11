extends "res://personajes/proyectil_base.gd"

func _ready() -> void:
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
		
	if has_node("Imagen") and get_node("Imagen") is AnimatedSprite2D:
		$"Imagen".play("default")
