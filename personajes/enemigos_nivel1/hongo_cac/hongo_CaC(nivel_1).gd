extends "res://personajes/enemigoBasico/enemigo_basico.gd"
@export var tiempo_anticipacion_cabezazo: float = 0.35 # Pausa de tensión antes del impacto

# Nodos exclusivos de este hongo
@onready var zona_impacto: Area2D = $ZonaImpacto
@onready var hitbox_cabezazo: CollisionShape2D = $ZonaImpacto/HitboxCabezazo

func _ready() -> void:
	super() # Configura UI y hace la búsqueda global del padre
	
	# TRUCO DE HERENCIA: Le borramos el objetivo que el padre acaba de encontrar.
	# Esto hace que el hongo nazca quieto y no se mueva hasta que pises su Area2D.
	jugador_objetivo = null 
	
	if hitbox_cabezazo:
		hitbox_cabezazo.disabled = true

# --- SISTEMA DE DETECCIÓN (Conecta los nodos de tu AreaDeteccion aquí) ---
func _on_area_deteccion_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		# Le pasamos el objetivo al padre. Él retoma su _physics_process y lo persigue.
		jugador_objetivo = body 

func _on_area_deteccion_body_exited(body: Node2D) -> void:
	if body == jugador_objetivo:
		# Se lo quitamos. El padre frena al hongo en seco automáticamente.
		jugador_objetivo = null 

# --- SISTEMA DE COMBATE ---
# El padre nos llama aquí, y él mismo maneja el "puede_atacar" y los cooldowns.
func ejecutar_ataque_normal(_objetivo) -> void:
	# 1. Anticipación visual (wind-up)
	await get_tree().create_timer(0.2).timeout
	
	# 2. Activa la hitbox para generar daño en área a corta distancia
	if hitbox_cabezazo:
		hitbox_cabezazo.disabled = false
		
		# Daño a todos los que estén dentro del impacto
		var cuerpos = zona_impacto.get_overlapping_bodies()
		for cuerpo in cuerpos:
			if cuerpo.is_in_group("Jugador") and cuerpo.has_method("recibir_dano"):
				cuerpo.recibir_dano(dano)
				
	# 3. Desactiva la hitbox rápidamente (golpe seco)
	await get_tree().create_timer(0.1).timeout
	if hitbox_cabezazo:
		hitbox_cabezazo.disabled = true
