extends Area2D

@export var velocidad: float = 300.0
@export var dano: int = 1
@export var tiempo_vida: float = 3.0
@export var distancia_maxima: float = 400.0

var direccion_vuelo: Vector2 = Vector2.ZERO
var disparado_por_jugador: bool = false
var distancia_recorrida: float = 0.0

func configurar(dir: Vector2, es_de_jugador: bool, dano_modificado: int = -1) -> void:
	direccion_vuelo = dir.normalized()
	disparado_por_jugador = es_de_jugador
	if dano_modificado >= 0:
		dano = dano_modificado
	rotation = direccion_vuelo.angle()

func _physics_process(delta: float) -> void:
	tiempo_vida -= delta
	if tiempo_vida <= 0:
		queue_free()
		return
	
	var paso = velocidad * delta
	global_position += direccion_vuelo * paso
	distancia_recorrida += paso
	
	if distancia_recorrida >= distancia_maxima:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	var victima = area.get_parent()
	
	print("Proyectil tocó el área de: ", victima.name)
	
	if victima.has_method("recibir_dano") and "es_jugador" in victima:
		if victima.es_jugador != disparado_por_jugador:
			victima.recibir_dano(dano)
			
	queue_free()
