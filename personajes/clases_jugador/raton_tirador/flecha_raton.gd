extends "res://personajes/proyectil_base.gd"

var tirador: CollisionObject2D
var impacto: bool = false

func _ready() -> void:
	if has_node("Imagen Flecha"):
		$"Imagen Flecha".play("volar")

func configurar_flecha(nuevo_tirador: CollisionObject2D, dir: Vector2, dano_modificado: int) -> void:
	tirador = nuevo_tirador
	super.configurar(dir, true, dano_modificado)
	velocidad = 320.0

func _physics_process(delta: float) -> void:
	if impacto:
		return
		
	tiempo_vida -= delta
	if tiempo_vida <= 0.0:
		queue_free()
		return
		
	var destino := global_position + direccion_vuelo * velocidad * delta
	var consulta := PhysicsRayQueryParameters2D.create(global_position, destino, collision_mask)
	
	if is_instance_valid(tirador):
		consulta.exclude = [tirador.get_rid()]
		
	var choque := get_world_2d().direct_space_state.intersect_ray(consulta)
	
	if not choque.is_empty():
		global_position = choque.position
		impacto = true
		
		super._on_body_entered(choque.collider)
	else:
		global_position = destino
