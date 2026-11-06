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
	var espacio = get_world_2d().direct_space_state
	
	var excluidos: Array[RID] = []
	if is_instance_valid(tirador):
		excluidos.append(tirador.get_rid())
	
	var choque: Dictionary = {}
	while true:
		var consulta = PhysicsRayQueryParameters2D.create(global_position, destino, collision_mask)
		consulta.exclude = excluidos
		choque = espacio.intersect_ray(consulta)
		
		if choque.is_empty():
			break
		
		var cuerpo = choque.collider
		if es_aliado(cuerpo):
			excluidos.append(cuerpo.get_rid())
			continue
		
		break
	
	if not choque.is_empty():
		global_position = choque.position
		impacto = true
		super._on_body_entered(choque.collider)
		queue_free()
	else:
		distancia_recorrida += global_position.distance_to(destino)
		global_position = destino
		
		if distancia_recorrida >= distancia_maxima:
			queue_free()

func es_aliado(cuerpo: Object) -> bool:
	return "es_jugador" in cuerpo and cuerpo.es_jugador == disparado_por_jugador

func _on_body_entered(body: Node) -> void:
	if impacto:
		return
	super(body)
