extends "res://personajes/personajeBase/personaje_base.gd"

@export_group("IA del Enemigo")
@export var distancia_ataque_melee: float = 40.0
@export var distancia_vision: float = 400.0

var jugador_objetivo: Node2D = null
var diccionario_cooldowns: Dictionary = {}

func _ready() -> void:
	super()
	es_jugador = false

func _physics_process(delta: float) -> void:
	manejar_gravedad_y_salto(delta)
	gestionar_cooldowns(delta)
	
	if esta_atacando or vida <= 0:
		velocity.x = 0
		move_and_slide()
		return
		
	buscar_jugador_cercano()
	
	if jugador_objetivo and is_instance_valid(jugador_objetivo):
		var distancia = global_position.distance_to(jugador_objetivo.global_position)
		
		if distancia <= distancia_vision:
			var ataque_elegido = decidir_ataque(distancia)
			
			if ataque_elegido != "":
				iniciar_ataque(ataque_elegido)
			else:
				mover_hacia_objetivo(distancia)
		else:
			velocity.x = 0 
	else:
		velocity.x = 0
		
	move_and_slide()

func decidir_ataque(distancia: float) -> String:
	if distancia <= distancia_ataque_melee and puede_atacar_normal:
		return "ataque_normal"
	return ""

func iniciar_ataque(ataque: String) -> void:
	if ataque == "ataque_normal":
		esta_atacando = true
		puede_atacar_normal = false
		
		ejecutar_ataque_normal(jugador_objetivo)
		
		await get_tree().create_timer(0.3).timeout
		esta_atacando = false
		
		var tiempo_restante = max(0.0, tiempo_recarga_normal - 0.3)
		await get_tree().create_timer(tiempo_restante).timeout
		puede_atacar_normal = true

func buscar_jugador_cercano() -> void:
	var jugadores = get_tree().get_nodes_in_group("Jugador")
	var distancia_minima = INF
	jugador_objetivo = null
	
	for j in jugadores:
		if is_instance_valid(j) and j.vida > 0:
			var dist = global_position.distance_to(j.global_position)
			if dist < distancia_minima:
				distancia_minima = dist
				jugador_objetivo = j

func mover_hacia_objetivo(distancia: float) -> void:
	if distancia > distancia_ataque_melee:
		var direccion = (jugador_objetivo.global_position - global_position).normalized()
		velocity.x = direccion.x * velocidad
		if sprite:
			sprite.flip_h = direccion.x < 0
			actualizar_offset_horizontal()
	else:
		velocity.x = 0

func gestionar_cooldowns(delta: float) -> void:
	for habilidad in diccionario_cooldowns.keys():
		if diccionario_cooldowns[habilidad] > 0:
			diccionario_cooldowns[habilidad] -= delta

func aplicar_cooldown(habilidad: String, tiempo: float) -> void:
	diccionario_cooldowns[habilidad] = tiempo

func habilidad_disponible(habilidad: String) -> bool:
	return not diccionario_cooldowns.has(habilidad) or diccionario_cooldowns[habilidad] <= 0
