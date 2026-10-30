extends "res://personajes/enemigoBasico/enemigo_basico.gd"

@export_group("Combate a Distancia")
@export var escena_espora: PackedScene
@export var distancia_huida: float = 150.0
@export var distancia_disparo_max: float = 350.0
@export var tiempo_recarga_espora: float = 2.5

func _ready() -> void:
	super()
	diccionario_cooldowns["disparo_espora"] = 0.0

func mover_hacia_objetivo(distancia: float) -> void:
	var dir_hacia_jugador = (jugador_objetivo.global_position - global_position).normalized()
	
	if distancia < distancia_huida:
		velocity.x = -dir_hacia_jugador.x * velocidad
	elif distancia > distancia_disparo_max:
		velocity.x = dir_hacia_jugador.x * velocidad
	else:
		velocity.x = 0
	if sprite and velocity.x != 0:
		sprite.flip_h = velocity.x < 0
		actualizar_offset_horizontal()

func decidir_ataque(distancia: float) -> String:
	if distancia >= distancia_huida and distancia <= distancia_disparo_max:
		if habilidad_disponible("disparo_espora"):
			return "disparo_espora"
	return ""

func iniciar_ataque(ataque: String) -> void:
	if ataque == "disparo_espora":
		esta_atacando = true
		aplicar_cooldown("disparo_espora", tiempo_recarga_espora)
		
		var dir_jugador = (jugador_objetivo.global_position - global_position).normalized()
		if sprite:
			sprite.flip_h = dir_jugador.x < 0
			actualizar_offset_horizontal()
			
		if escena_espora:
			var espora = escena_espora.instantiate()
			get_tree().current_scene.add_child(espora)
			espora.global_position = global_position + Vector2(0, -10)
			
			espora.configurar(dir_jugador, false, dano)

		await get_tree().create_timer(0.5).timeout
		esta_atacando = false
	else:
		super.iniciar_ataque(ataque)
