extends "res://personajes/enemigoBasico/enemigo_basico.gd"

@export_group("Configuración Cabezazo")
@export var tiempo_anticipacion: float = 0.35

@onready var zona_impacto: Area2D = $ZonaImpacto
@onready var hitbox_cabezazo: CollisionShape2D = $ZonaImpacto/HitboxCabezazo

func _ready() -> void:
	super()
	hitbox_cabezazo.set_deferred("disabled", true)

func ejecutar_ataque_normal(objetivo) -> void:
	if objetivo:
		zona_impacto.scale.x = -1 if objetivo.global_position.x < global_position.x else 1
	
	await get_tree().create_timer(tiempo_anticipacion).timeout
	
	if vida <= 0:
		return
	
	hitbox_cabezazo.set_deferred("disabled", false)
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	for cuerpo in zona_impacto.get_overlapping_bodies():
		if cuerpo != self and cuerpo.is_in_group("Jugador") and cuerpo.has_method("recibir_dano"):
			cuerpo.recibir_dano(dano)
	
	await get_tree().create_timer(0.1).timeout
	hitbox_cabezazo.set_deferred("disabled", true)
	hitbox_cabezazo.set_deferred("disabled", false)
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	for cuerpo in zona_impacto.get_overlapping_bodies():
		if cuerpo != self and cuerpo.is_in_group("Jugador") and cuerpo.has_method("recibir_dano"):
			cuerpo.recibir_dano(dano)
	
	await get_tree().create_timer(0.1).timeout
	hitbox_cabezazo.set_deferred("disabled", true)

func _on_area_deteccion_body_entered(body: Node2D) -> void:
	print("Detección vio a: ", body.name, " | grupo Jugador: ", body.is_in_group("Jugador"))
	if body.is_in_group("Jugador"):
		jugador_objetivo = body
