extends Area2D

@export var velocidad: float = 300.0
@export var dano: int = 1
@export var tiempo_vida: float = 3.0

var direccion_vuelo: Vector2 = Vector2.ZERO
var disparado_por_jugador: bool = false

func configurar(dir: Vector2, es_de_jugador: bool, dano_modificado: int = dano) -> void:
	direccion_vuelo = dir.normalized()
	disparado_por_jugador = es_de_jugador
	dano = dano_modificado
	rotation = direccion_vuelo.angle()

func _physics_process(delta: float) -> void:
	tiempo_vida -= delta
	if tiempo_vida <= 0:
		queue_free()
		
	global_position += direccion_vuelo * velocidad * delta

func _on_body_entered(body: Node) -> void:
	if body.has_method("recibir_dano") and "es_jugador" in body:
		if body.es_jugador != disparado_por_jugador:
			body.recibir_dano(dano)
			queue_free()
