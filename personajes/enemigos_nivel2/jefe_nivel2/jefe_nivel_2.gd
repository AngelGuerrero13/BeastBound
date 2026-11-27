
extends "res://personajes/enemigoBasico/enemigo_basico.gd"

signal talus_derrotado

enum Fase {
	PIEDRA,
	TRANSFORMACION,
	LAVA,
	DERROTADO
}
var estado: String = "patrullando"
var fase_actual = Fase.PIEDRA
@onready var imagen_personaje: AnimatedSprite2D = $AnimacionTalus

@export var textura_piedra: Texture2D
@export var textura_lava: Texture2D

@export_group("Patrullaje Talus")
@export var ancho_patruya: float = 200.0
@export var alto_patruya: float = 140.0
@export var velocidad_patruya: float = 35.0
@export var probabilidad_vertical: float = 0.30
@export var pausa_patruya: float = 0.5

@export var reduccion_dano_cuerpo: float = 0.9
@export var velocidad_fase_2: float = 30.0
@export_group("Rastro de lava")
@export var distancia_entre_charcos: float  = 20.0

var direccion: int = 1
var posicion_inicial: Vector2
var destino_patruya: Vector2
var esperando_patruya: bool = false

var escena_zona_lava = preload("res://personajes/enemigos_nivel2/jefe_nivel2/ZonaLava.tscn")
var ultima_posicion_lava: Vector2

func _ready() -> void:
	vida_maxima = 100
	vida = vida_maxima
	dano = 3
	velocidad = 30.0
	
	super._ready()
	if imagen_personaje.sprite_frames.has_animation("caminar"):
		imagen_personaje.play("caminar")

	ultima_posicion_lava = global_position
	posicion_inicial = global_position
	destino_patruya = posicion_inicial
	elegir_destino_patruya()

func recibir_dano_talus(cantidad: float, es_nucleo: bool) -> void:
	if fase_actual == Fase.TRANSFORMACION:
		return

	if fase_actual == Fase.DERROTADO:
		return

	var dano_final = cantidad

	if not es_nucleo:
		dano_final *= (1.0 - reduccion_dano_cuerpo)
	if cantidad <= 0:
		return
		
	var dano_entero : int  = maxi(1, roundi(dano_final))
	vida = maxi(vida - dano_entero, 0)
	
	vida_cambiada.emit(vida)
	
	if barra_vida_enemigo:
		barra_vida_enemigo.value = vida


	if fase_actual == Fase.PIEDRA and vida <= vida_maxima * 0.30:
		transformar_en_lava()
	elif fase_actual == Fase.LAVA and vida <= 0:
		derrotar_talus()
		
func cambiar_apariencia_lava() -> void:
	if imagen_personaje.sprite_frames.has_animation("caminar_lava"):
		imagen_personaje.play("caminar_lava")
		
		
func recibir_dano(cantidad: int) -> void:
	recibir_dano_talus(float(cantidad), false)
	
	
func _on_area_deteccion_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		jugador_objetivo = body
		print("Talus detectó al jugador")


func _on_area_deteccion_body_exited(body: Node2D) -> void:
	if body == jugador_objetivo:
		jugador_objetivo = null
		estado = "patrullando"

		esperando_patruya = false

		# Elegir un destino nuevo
		elegir_destino_patruya()

		print("Talus perdió al jugador y vuelve a patrullar")

func transformar_en_lava() -> void:
	fase_actual = Fase.TRANSFORMACION
	esta_atacando = true
	velocity = Vector2.ZERO

	print("Talus cae a la lava")

	await get_tree().create_timer(3.0).timeout
	
	if not is_inside_tree():
		return
	
	fase_actual = Fase.LAVA
	esta_atacando = false
	cambiar_apariencia_lava()
	ultima_posicion_lava = global_position
	vida = vida_maxima
	velocidad = velocidad_fase_2
	dano = 5
	
	if barra_vida_enemigo: 
		barra_vida_enemigo.max_value = vida_maxima
		barra_vida_enemigo.value = vida
	
	vida_cambiada.emit(vida)
	
	print("Talus entra en fase 2")

func derrotar_talus() -> void:
	fase_actual = Fase.DERROTADO
	
	esta_atacando = true
	velocity = Vector2.ZERO
	
	print("Talus derrotado")
	talus_derrotado.emit()
	queue_free()
	

func _physics_process(_delta: float) -> void:
	if fase_actual == Fase.TRANSFORMACION or fase_actual == Fase.DERROTADO:
		velocity = Vector2.ZERO
		return

	if esta_atacando or vida <= 0:
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	if jugador_objetivo != null and is_instance_valid(jugador_objetivo):
		estado = "persiguiendo"
		var distancia = global_position.distance_to(jugador_objetivo.global_position)
		var ataque = decidir_ataque(distancia)
		if ataque != "":
			estado = "atacando"
			iniciar_ataque(ataque)
			velocity = Vector2.ZERO
		else:
			mover_hacia_objetivo(distancia)
		
	else:
		estado = "patrullando"
		patrullar_talus()
		
	move_and_slide()
	if Engine.get_physics_frames() % 60 == 0:
		print("Talus: ", global_position,
		 " | Destino: ", destino_patruya,
		 " | Velocidad: ", velocity,
		" | Colisión: ", get_slide_collision_count())
		
	if fase_actual == Fase.LAVA:
		dejar_rastro_lava()
		
		
func dejar_rastro_lava()-> void:
	if fase_actual != Fase.LAVA:
		return
		
	if global_position.distance_to(ultima_posicion_lava)< distancia_entre_charcos:
		return
	
	var charco = escena_zona_lava.instantiate()
	get_parent().add_child(charco)
	charco.global_position = global_position
	
	ultima_posicion_lava = global_position
	
func morir() -> void:
	if fase_actual == Fase.PIEDRA:
		transformar_en_lava()
	elif fase_actual == Fase.LAVA:
		derrotar_talus()
func elegir_destino_patruya() -> void:
	var mitad_ancho = ancho_patruya / 2.0
	var mitad_alto = alto_patruya / 2.0

	if randf() < probabilidad_vertical:
		# Talus elige moverse verticalmente
		destino_patruya = Vector2(
			global_position.x,
			posicion_inicial.y + randf_range(-mitad_alto, mitad_alto)
		)
	else:
		# Talus elige moverse horizontalmente
		destino_patruya = Vector2(
			posicion_inicial.x + randf_range(-mitad_ancho, mitad_ancho),
			global_position.y
		)

func patrullar_talus() -> void:
	if esperando_patruya:
		velocity = Vector2.ZERO
		return

	var distancia = global_position.distance_to(destino_patruya)

	if distancia <= 3.0:
		velocity = Vector2.ZERO
		esperar_y_cambiar_destino()
		return

	var direccion_movimiento = (
	destino_patruya - global_position
	).normalized()

	velocity = direccion_movimiento * velocidad_patruya

	if absf(direccion_movimiento.x) > 0.01:
		voltear_hacia(direccion_movimiento.x)

func esperar_y_cambiar_destino() -> void:
	if esperando_patruya:
		return

	esperando_patruya = true

	await get_tree().create_timer(pausa_patruya).timeout

	if not is_inside_tree():
		return
	esperando_patruya = false
	if jugador_objetivo != null and is_instance_valid(jugador_objetivo):
		return
		
	elegir_destino_patruya()
