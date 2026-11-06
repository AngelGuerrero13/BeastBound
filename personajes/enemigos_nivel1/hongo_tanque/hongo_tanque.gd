extends "res://personajes/enemigoBasico/enemigo_basico.gd"

@export var velocidad_embestida: float = 600.0 
@export var distancia_activacion_embestida: float = 170.0
@export var tiempo_recarga_embestida: float = 4.0

var esta_embistiendo: bool = false
var direccion_embestida: Vector2 = Vector2.ZERO
var ya_golpeo_embestida: bool = false

@onready var hitbox_frontal: CollisionShape2D = $AreaEmbestida/HitboxFrontal

func _ready() -> void:
	super() 
	if hitbox_frontal: hitbox_frontal.set_deferred("disabled", true)

func decidir_ataque(distancia: float) -> String:
	if esta_embistiendo:
		return ""
	
	if distancia <= distancia_ataque_melee and puede_atacar_normal:
		return "ataque_normal"
	
	if distancia <= distancia_activacion_embestida and distancia > distancia_ataque_melee and habilidad_disponible("embestida"):
		return "embestida"
		
	return ""

func iniciar_ataque(ataque: String) -> void:
	if ataque == "embestida":
		iniciar_embestida()
	elif ataque == "ataque_normal":
		iniciar_ataque_lento()

func mover_hacia_objetivo(distancia: float) -> void:
	if esta_embistiendo:
		velocity = direccion_embestida * velocidad_embestida
	else:
		super(distancia)

func iniciar_embestida() -> void:
	esta_embistiendo = true
	ya_golpeo_embestida = false
	aplicar_cooldown("embestida", tiempo_recarga_embestida)
	
	direccion_embestida = Vector2.ZERO
	await get_tree().create_timer(0.4).timeout
	
	if is_instance_valid(jugador_objetivo):
		direccion_embestida = (jugador_objetivo.global_position - global_position).normalized()
	else:
		direccion_embestida = obtener_direccion_frente()
	
	voltear_hacia(direccion_embestida.x)

	if hitbox_frontal: hitbox_frontal.set_deferred("disabled", false)
	await get_tree().create_timer(0.5).timeout 
	if hitbox_frontal: hitbox_frontal.set_deferred("disabled", true)
	
	esta_embistiendo = false

func iniciar_ataque_lento() -> void:
	esta_atacando = true
	puede_atacar_normal = false
	
	await get_tree().create_timer(0.6).timeout
	
	if is_instance_valid(jugador_objetivo) and global_position.distance_to(jugador_objetivo.global_position) <= distancia_ataque_melee + 15.0:
		ejecutar_ataque_normal(jugador_objetivo)
	
	esta_atacando = false
	var tiempo_restante = max(0.0, tiempo_recarga_normal - 0.6)
	await get_tree().create_timer(tiempo_restante).timeout
	puede_atacar_normal = true

func _on_area_embestida_body_entered(body: Node2D) -> void:
	if body == self or ya_golpeo_embestida:
		return
	if esta_embistiendo and body.is_in_group("Jugador") and body.has_method("recibir_dano"):
		ya_golpeo_embestida = true
		body.recibir_dano(dano * 2)
