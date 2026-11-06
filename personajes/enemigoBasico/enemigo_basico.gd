extends "res://personajes/personajeBase/personaje_base.gd"

@export_group("IA del Enemigo")
@export var distancia_ataque_melee: float = 40.0
@export var duracion_ataque: float = 0.6

var jugador_objetivo: Node2D = null
var diccionario_cooldowns: Dictionary = {}

func _ready() -> void:
	es_jugador = false
	super()

func _physics_process(delta: float) -> void:
	gestionar_cooldowns(delta)
	
	if esta_atacando or vida <= 0:
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	if jugador_objetivo and is_instance_valid(jugador_objetivo):
		var distancia = global_position.distance_to(jugador_objetivo.global_position)
		var ataque_elegido = decidir_ataque(distancia)
		
		if ataque_elegido != "":
			iniciar_ataque(ataque_elegido)
		else:
			mover_hacia_objetivo(distancia)
	else:
		velocity = Vector2.ZERO
		
	move_and_slide()

func _on_area_deteccion_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		jugador_objetivo = body

func _on_area_deteccion_body_exited(body: Node2D) -> void:
	if body == jugador_objetivo:
		jugador_objetivo = null

func decidir_ataque(distancia: float) -> String:
	if distancia <= distancia_ataque_melee and puede_atacar_normal:
		return "ataque_normal"
	return ""

func iniciar_ataque(ataque: String) -> void:
	if ataque == "ataque_normal":
		esta_atacando = true
		puede_atacar_normal = false
		
		ejecutar_ataque_normal(jugador_objetivo)
		
		await get_tree().create_timer(duracion_ataque).timeout
		esta_atacando = false
		
		var tiempo_restante = max(0.0, tiempo_recarga_normal - duracion_ataque)
		await get_tree().create_timer(tiempo_restante).timeout
		puede_atacar_normal = true

func mover_hacia_objetivo(distancia: float) -> void:
	if distancia > distancia_ataque_melee:
		var direccion = (jugador_objetivo.global_position - global_position).normalized()
		velocity = direccion * velocidad
		voltear_hacia(direccion.x)
	else:
		velocity = Vector2.ZERO

func gestionar_cooldowns(delta: float) -> void:
	for habilidad in diccionario_cooldowns.keys():
		if diccionario_cooldowns[habilidad] > 0:
			diccionario_cooldowns[habilidad] -= delta

func aplicar_cooldown(habilidad: String, tiempo: float) -> void:
	diccionario_cooldowns[habilidad] = tiempo

func habilidad_disponible(habilidad: String) -> bool:
	return not diccionario_cooldowns.has(habilidad) or diccionario_cooldowns[habilidad] <= 0

func aturdir(duracion: float) -> void:
	esta_atacando = true
	await get_tree().create_timer(duracion).timeout
	if vida > 0:
		esta_atacando = false
