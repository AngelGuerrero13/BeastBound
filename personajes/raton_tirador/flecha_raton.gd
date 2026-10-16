extends Area2D

@export var velocidad: float = 320.0
@export var dano: int = 1
@export var tiempo_vida: float = 2.0
var direccion := Vector2.RIGHT
var tirador: CollisionObject2D
var impacto := false

func _ready() -> void:
	direccion = direccion.normalized()
	$"Imagen Flecha".rotation = direccion.angle()
	$"Imagen Flecha".play("volar")

func _physics_process(delta: float) -> void:
	if impacto:
		return
	tiempo_vida -= delta
	if tiempo_vida <= 0.0:
		queue_free()
		return
	var destino := global_position + direccion * velocidad * delta
	# Barrido completo del recorrido: no atraviesa objetivos entre fotogramas.
	var consulta := PhysicsRayQueryParameters2D.create(global_position, destino, collision_mask)
	if is_instance_valid(tirador):
		consulta.exclude = [tirador.get_rid()]
	var choque := get_world_2d().direct_space_state.intersect_ray(consulta)
	if not choque.is_empty():
		global_position = choque.position
		_al_tocar_cuerpo(choque.collider)
	else:
		global_position = destino

func _al_tocar_cuerpo(cuerpo: Node) -> void:
	if impacto or cuerpo == tirador or cuerpo.is_in_group("Jugador"):
		return
	impacto = true
	if cuerpo.has_method("recibir_dano") and cuerpo.get("es_jugador") == false:
		cuerpo.recibir_dano(dano)
	queue_free()
