extends "res://personajes/proyectil_base.gd"

@export var velocidad_flecha: float = 320.0

var tirador: CollisionObject2D
var impacto: bool = false
@onready var animacion: AnimatedSprite2D = get_node_or_null("Imagen Flecha")

func _ready() -> void:
	if animacion:
		animacion.play("volar")

func configurar_flecha(nuevo_tirador: CollisionObject2D, dir: Vector2, dano_modificado: int, es_de_jugador: bool = true) -> void:
	tirador = nuevo_tirador
	super.configurar(dir, es_de_jugador, dano_modificado)
	velocidad = velocidad_flecha

func _physics_process(delta: float) -> void:
	if impacto:
		return
		
	tiempo_vida -= delta
	if tiempo_vida <= 0.0:
		queue_free()
		return
		
	var destino = global_position + direccion_vuelo * velocidad * delta
	
	var consulta = PhysicsRayQueryParameters2D.create(global_position, destino, collision_mask)
	
	consulta.collide_with_areas = true 
	consulta.collide_with_bodies = true
	
	if is_instance_valid(tirador):
		consulta.exclude = [tirador.get_rid()]
		
	var choque = get_world_2d().direct_space_state.intersect_ray(consulta)
	
	if not choque.is_empty():
		global_position = choque.position
		impacto = true
		
		if choque.collider is Area2D:
			super._on_area_entered(choque.collider)
		else:
			queue_free()
	else:
		distancia_recorrida += global_position.distance_to(destino)
		global_position = destino
		
		if distancia_recorrida >= distancia_maxima:
			queue_free()
