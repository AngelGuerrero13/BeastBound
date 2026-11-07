extends Area2D

signal activada(escenas: Array[PackedScene], posicion: Vector2)

@export var enemigos: Array[PackedScene] = []
@export var punto_spawn: Marker2D

var usada: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if usada or not body.is_in_group("Jugador"):
		return
	if punto_spawn == null:
		push_warning("Emboscada '%s': falta asignar Punto Spawn en el inspector." % name)
		return
	usada = true
	activada.emit.call_deferred(enemigos, punto_spawn.global_position)
