extends Area2D

@onready var talus = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func recibir_dano(cantidad: int) -> void:
	talus.recibir_dano_talus(float(cantidad), true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
