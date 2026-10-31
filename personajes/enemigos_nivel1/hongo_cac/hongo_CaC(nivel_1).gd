extends "res://personajes/enemigoBasico/enemigo_basico.gd"
@export var tiempo_anticipacion_cabezazo: float = 0.35 # Pausa de tensión antes del impacto

@onready var zona_impacto: Area2D = $ZonaImpacto
@onready var hitbox_cabezazo: CollisionShape2D = $ZonaImpacto/HitboxCabezazo

func _ready() -> void:
	super()
	if hitbox_cabezazo:
		hitbox_cabezazo.disabled = true

func _on_area_deteccion_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		jugador_objetivo = body 

func _on_area_deteccion_body_exited(body: Node2D) -> void:
	if body == jugador_objetivo:
		jugador_objetivo = null 

# --- SISTEMA DE COMBATE CORREGIDO ---
func ejecutar_ataque_normal(_objetivo) -> void:
	# 1. BLOQUEO: Evita el spam de 60 frames por segundo del padre
	puede_atacar_normal = false 
	
	# 2. Anticipación visual usando tu nueva variable
	await get_tree().create_timer(tiempo_anticipacion_cabezazo).timeout
	
	if hitbox_cabezazo:
		hitbox_cabezazo.disabled = false
		
		# TRUCO DE FÍSICAS: Esperar 1 frame asegura que Godot registre la hitbox antes de leerla
		await get_tree().physics_frame
		
		var cuerpos = zona_impacto.get_overlapping_bodies()
		for cuerpo in cuerpos:
			if cuerpo.is_in_group("Jugador") and cuerpo.has_method("recibir_dano"):
				cuerpo.recibir_dano(dano)
				
	# 3. Desactiva la hitbox rápidamente
	await get_tree().create_timer(0.1).timeout
	if hitbox_cabezazo:
		hitbox_cabezazo.disabled = true
		
	# 4. RECARGA: Aplicamos el cooldown heredado para que se destrabe y vuelva a moverse
	await get_tree().create_timer(tiempo_recarga_normal).timeout
	puede_atacar_normal = true

# Tu deducción aquí fue excelente. Esto anula perfectamente el radar global del padre.
func buscar_jugador_cercano() -> void:
	pass
