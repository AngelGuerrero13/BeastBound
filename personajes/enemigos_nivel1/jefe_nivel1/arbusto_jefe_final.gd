extends "res://personajes/personajeBase/personaje_base.gd"

#Estados de la IA
var estado: String = "patrullando"
var fase: int = 1

#Movimiento
@export var distancia_patruya: float = 40.0
@export var velocidad_patruya: float = 35.0
@export var rango_deteccion: float = 40.0
var direccion: int = 1
var posicion_inicial: Vector2
var destino_patruya: Vector2

# Ataques
@export var dano_raices: int = 2
@export var dano_espinas: int = 1
@export var dano_esporas: int = 1

var jugador: Node2D = null
var atacando: bool = false
var puede_atacar: bool = true

@onready var detector: Area2D = $Area2D
@onready var boss_health_bar = $CanvasLayer/BossHealthBar

func _ready() -> void:
	es_jugador = false
	
	vida_maxima = 30
	vida = vida_maxima
	
	super._ready()
	
	posicion_inicial = global_position
	destino_patruya = posicion_inicial
	elegir_destino_patruya()
	
	detector.body_entered.connect(_cuando_entra_jugador)
	detector.body_exited.connect(_cuando_sale_jugador)
	vida_cambiada.connect(_actualizar_barra_jefe)
	
	if barra_vida_enemigo:
		barra_vida_enemigo.max_value = vida_maxima
		barra_vida_enemigo.value = vida
	
func _physics_process(_delta:float)-> void:
	print("El jefe está ejecutando su IA")
	if vida <= 0:
		velocity = Vector2.ZERO
		return
	
	revisar_fase()
	
	if estado == "patrullando":
		print("Estado actual: ", estado)
		patrullar()
	elif estado == "detectando":
		velocity = Vector2.ZERO
		
		if puede_atacar and jugador != null:
			elegir_ataque()
	elif estado == "atacando":
		velocity = Vector2.ZERO
	
	elif estado == "recuperando":
		velocity = Vector2.ZERO

	move_and_slide()


func patrullar() -> void:
	global_position = global_position.move_toward(
		destino_patruya,
		velocidad_patruya * get_physics_process_delta_time()
	)
	if global_position.distance_to(destino_patruya) < 2.0:
		elegir_destino_patruya()
		
		
func _cuando_entra_jugador(cuerpo: Node2D)-> void:
	if cuerpo.is_in_group("Jugador"):
		jugador = cuerpo
		estado = "detectando"
		print("El Jefe Arbusto detecto a un personaje.")
		
		
func _cuando_sale_jugador(cuerpo: Node2D) -> void:
	if cuerpo == jugador:
		jugador = null
		
		if not atacando:
			estado = "patrullando"
		
		

func elegir_ataque() -> void:
	if atacando or not puede_atacar:
		return
		
	atacando = true
	puede_atacar = false
	estado= "atacando"

	var ataque = randi_range(1, 3)
	
	if ataque == 1:
		await ataque_espinas()
	
	elif ataque == 2:
		await ataque_raices()
	
	else:
		await  ataque_esporas()

	if not is_inside_tree():
		return
		
	estado = "recuperando"
	
	var recuperacion = 1.5
	
	if fase == 2:
		recuperacion = 1.1
	elif  fase == 3:
		recuperacion = 0.8
		
	await get_tree().create_timer(recuperacion).timeout
	
	if not is_inside_tree():
		return
	
	atacando = false
	puede_atacar = true
	
	if jugador != null and is_instance_valid(jugador):
		estado = "detectando"
	else:
		estado = "patrullando"
		
		
func ataque_espinas() -> void:
	print("¡El arbusto prepara sus espinas verticales!")
	await get_tree().create_timer(0.6).timeout
	
	if not is_inside_tree():
		return
	print("¡Las espinas salen disparadas")
	
	if jugador != null and is_instance_valid(jugador):
		var distancia_x = absf(jugador.global_position.x - global_position.x)
		var distancia_y = absf(jugador.global_position.y - global_position.y)
		
		if distancia_x <= 50.0 and distancia_y <= 100.0:
			jugador.recibir_dano(dano_espinas)
			
		await get_tree().create_timer(0.4).timeout
		
		
func elegir_destino_patruya() -> void:
	if destino_patruya == Vector2.ZERO:
		destino_patruya = posicion_inicial + Vector2(distancia_patruya, -distancia_patruya)
	elif destino_patruya == posicion_inicial + Vector2(distancia_patruya, -distancia_patruya):
		destino_patruya = posicion_inicial + Vector2(distancia_patruya, distancia_patruya)
	elif destino_patruya == posicion_inicial + Vector2(distancia_patruya, distancia_patruya):
		destino_patruya = posicion_inicial + Vector2(-distancia_patruya, distancia_patruya)
	elif destino_patruya == posicion_inicial + Vector2(-distancia_patruya, distancia_patruya):
		destino_patruya = posicion_inicial + Vector2(-distancia_patruya, -distancia_patruya)
	else:
		destino_patruya = posicion_inicial + Vector2(distancia_patruya, -distancia_patruya)
		
		
func ataque_raices()-> void:
	print("¡Saldran raices del suelo!")
	
	await  get_tree().create_timer(1.0).timeout
	
	if not is_inside_tree():
		return
		
	print("¡Las raices emergen del suelo!")
	
	if jugador != null and is_instance_valid(jugador):
		var distancia = global_position.distance_to(jugador.global_position)
		
		if distancia <= 55.0:
			jugador.recibir_dano(dano_raices)
		
	await get_tree().create_timer(0.6).timeout


func ataque_esporas() -> void:
	print("¡La flor del arbusto comienza a abrirse!")

	await get_tree().create_timer(0.8).timeout
	if not is_inside_tree():
		return

	print("¡La flor libera esporas venenosas!")

	var radio = 90.0

	if fase == 2:
		radio = 110.0
	elif fase == 3:
		radio = 130.0

	if jugador != null and is_instance_valid(jugador):
		var distancia = global_position.distance_to(jugador.global_position)

		if distancia <= radio:
			jugador.recibir_dano(dano_esporas)

	await get_tree().create_timer(1.0).timeout


func revisar_fase() -> void:
	var porcentaje_vida = float(vida) / float(vida_maxima)

	if porcentaje_vida <= 0.25 and fase < 3:
		fase = 3
		print("¡Fase 3! El arbusto está enfurecido.")

	elif porcentaje_vida <= 0.60 and fase < 2:
		fase = 2
		print("¡Fase 2! El arbusto se vuelve más agresivo.")

func _actualizar_barra_jefe(nueva_vida:int) -> void:
	boss_health_bar.value = nueva_vida
	
func morir() -> void:
	if estado == "muriendo":
		return
	
	estado = "muriendo"
	atacando = false
	puede_atacar = false
	velocity = Vector2.ZERO
	
	print("El jefe Arbusto ha sido derrotado!")

	await get_tree().create_timer(1.5).timeout
	
	if not is_inside_tree():
		return
	
	ha_muerto.emit()
	boss_health_bar.visible = false
	
	queue_free()
