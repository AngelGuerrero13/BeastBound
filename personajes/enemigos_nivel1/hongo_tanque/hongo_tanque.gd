extends "res://personajes/enemigoBasico/enemigo_basico.gd"
# --- CONFIGURACIÓN DE EMBESTIDA ---
@export var velocidad_embestida: float = 600.0 
@export var distancia_activacion_embestida: float = 170.0
@export var tiempo_recarga_embestida: float = 4.0

var esta_embistiendo: bool = false
var puede_embestir: bool = true
var direccion_embestida: float = 0.0 # Solo necesitamos X para un hongo terrestre

@onready var hitbox_frontal: CollisionShape2D = $AreaEmbestida/HitboxFrontal

func _ready() -> void:
	super() # El padre configura su vida y UI
	if hitbox_frontal: hitbox_frontal.disabled = true

# --- INTERCEPTAMOS EL MOVIMIENTO ---
func manejar_movimiento() -> void:
	# 1. Chequeamos si debemos activar el Dash (Embestida) ANTES de movernos
	if puede_embestir and jugador_objetivo and not esta_embistiendo:
		var distancia = global_position.distance_to(jugador_objetivo.global_position)
		if distancia <= distancia_activacion_embestida and distancia > rango_ataque:
			iniciar_embestida()
			return # Cortamos aquí para que no se mueva normal este frame
			
	# 2. El padre calcula la persecución, aplica gravedad y voltea el sprite. ¡Nos ahorra todo eso!
	super()
	
	# 3. Si estamos embistiendo, pisamos la velocidad X que el padre acaba de calcular
	if esta_embistiendo:
		velocity.x = direccion_embestida * velocidad_embestida

# --- SOBRESCRIBIMOS EL ATAQUE BÁSICO (Para hacerlo intencionalmente lento) ---
func ejecutar_ataque_normal(objetivo) -> void:
	puede_atacar_normal = false # Lo bloqueamos para que el _physics_process del padre no repita esto
	
	# Wind-up: Pausa de preparación pesada
	await get_tree().create_timer(0.6).timeout
	
	if is_instance_valid(objetivo) and global_position.distance_to(objetivo.global_position) <= rango_ataque + 15.0:
		# Si el jugador no logró esquivarlo, el padre aplica el daño y maneja su propio timer de recarga
		super(objetivo) 
	else:
		# Si falló, aplicamos el cooldown nosotros para no quedar trabados
		await get_tree().create_timer(tiempo_recarga_normal).timeout
		puede_atacar_normal = true

# --- LÓGICA PURA DE LA EMBESTIDA ---
func iniciar_embestida() -> void:
	esta_embistiendo = true
	puede_embestir = false
	
	# 1. Pausa dramática: se queda quieto (pisando velocity.x a 0) antes de salir disparado
	direccion_embestida = 0.0 
	await get_tree().create_timer(0.4).timeout
	
	# 2. Fija la dirección en el eje X hacia el jugador
	if is_instance_valid(jugador_objetivo):
		var dir = (jugador_objetivo.global_position - global_position).normalized()
		direccion_embestida = sign(dir.x)
	else:
		direccion_embestida = -1.0 if sprite_mira_izquierda else 1.0

	# 3. Acelera drásticamente en línea recta activando la caja de colisión[cite: 3]
	if hitbox_frontal: hitbox_frontal.disabled = false
	await get_tree().create_timer(0.5).timeout # Duración del trayecto
	if hitbox_frontal: hitbox_frontal.disabled = true
	
	esta_embistiendo = false
	
	# Cooldown para volver a embestir
	await get_tree().create_timer(tiempo_recarga_embestida).timeout
	puede_embestir = true

# --- DAÑO DE EMBESTIDA ---
func _on_area_embestida_body_entered(body: Node2D) -> void:
	if esta_embistiendo and body.is_in_group("Jugador") and body.has_method("recibir_dano"):
		body.recibir_dano(dano * 2)
