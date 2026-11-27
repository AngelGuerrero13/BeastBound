extends "res://personajes/enemigoBasico/enemigo_basico.gd"

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
var puede_atacar: bool = true
@export var escena_espina: PackedScene
@onready var detector: Area2D = $Area2D
@onready var animacion_arbusto: AnimatedSprite2D = $AnimacionArbusto
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
	animacion_arbusto.flip_h = true
	animacion_arbusto.play("reposo")
	
func _physics_process(delta:float)-> void:
	if vida <= 0 or estado == "muriendo":
		velocity = Vector2.ZERO
		return
	
	gestionar_cooldowns(delta)
	revisar_fase()
	
	if estado == "patrullando":
		patrullar()
		
	elif estado == "detectando":
		velocity = Vector2.ZERO
		animacion_arbusto.play("reposo")
		
		if not is_instance_valid(jugador_objetivo):
			estado = "patrullando"
		elif puede_atacar and not esta_atacando:
			elegir_ataque()
			
	elif estado == "atacando":
		velocity = Vector2.ZERO
	
	elif estado == "recuperando":
		velocity = Vector2.ZERO

	move_and_slide()


func patrullar() -> void:
	animacion_arbusto.play("patruya")
	
	if global_position.distance_to(destino_patruya) < 2.0:
		elegir_destino_patruya()
	
	var direccion_movimiento = (destino_patruya - global_position).normalized()
	velocity = direccion_movimiento * velocidad_patruya
		
func _cuando_entra_jugador(cuerpo: Node2D)-> void:
	if cuerpo.is_in_group("Jugador"):
		jugador_objetivo = cuerpo
		
		if not esta_atacando and estado != "muriendo":
			estado = "detectando"
		print("El Jefe Arbusto detecto a un personaje.")
		
		
func _cuando_sale_jugador(cuerpo: Node2D) -> void:
	if cuerpo == jugador_objetivo:
		jugador_objetivo = null
		
		if not esta_atacando and estado != "muriendo":
			estado = "patrullando"
		
		

func elegir_ataque() -> void:
	if esta_atacando or not puede_atacar or not jefe_activo():
		return
		
	esta_atacando = true
	puede_atacar = false
	estado= "atacando"

	var ataque = randi_range(1, 3)
	
	if ataque == 1:
		await ataque_espinas()
	
	elif ataque == 2:
		await ataque_raices()
	
	else:
		await  ataque_esporas()

	if not jefe_activo():
		return
		
	estado = "recuperando"
	animacion_arbusto.play("reposo")
	
	var recuperacion = 1.5
	
	if fase == 2:
		recuperacion = 1.1
	elif  fase == 3:
		recuperacion = 0.8
		
	await get_tree().create_timer(recuperacion).timeout
	
	if not jefe_activo():
		return
	
	esta_atacando = false
	puede_atacar = true
	
	if is_instance_valid(jugador_objetivo):
		estado = "detectando"
	else:
		estado = "patrullando"
		
		
func ataque_espinas() -> void:
	animacion_arbusto.play("ataque_espinas")

	print("¡El arbusto prepara sus espinas!")

	await get_tree().create_timer(0.3).timeout

	if not jefe_activo():
		return

	lanzar_espinas()

	await get_tree().create_timer(0.3).timeout


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
	animacion_arbusto.play("ataque_raices")
	print("¡Saldran raices del suelo!")
	
	await  get_tree().create_timer(0.375).timeout
	
	if not jefe_activo():
		return
		
	print("¡Las raices emergen del suelo!")
	
	if is_instance_valid(jugador_objetivo):
		var distancia = global_position.distance_to(jugador_objetivo.global_position)
		
		if distancia <= 55.0:
			jugador_objetivo.recibir_dano(dano_raices)
		
	await get_tree().create_timer(0.375).timeout


func ataque_esporas() -> void:
	animacion_arbusto.play("ataque_esporas")
	print("¡La flor del arbusto comienza a abrirse!")

	await get_tree().create_timer(0.375).timeout
	
	if not jefe_activo():
		return

	print("¡La flor libera esporas venenosas!")

	var radio = 90.0

	if fase == 2:
		radio = 110.0
	elif fase == 3:
		radio = 130.0

	if is_instance_valid(jugador_objetivo):
		var distancia = global_position.distance_to(jugador_objetivo.global_position)

		if distancia <= radio:
			jugador_objetivo.recibir_dano(dano_esporas)

	await get_tree().create_timer(0.375).timeout


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
	esta_atacando = false
	puede_atacar = false
	velocity = Vector2.ZERO
	animacion_arbusto.stop()
	
	print("El jefe Arbusto ha sido derrotado!")

	await get_tree().create_timer(1.5).timeout
	
	if not is_inside_tree():
		return
	
	boss_health_bar.visible = false
	ha_muerto.emit()
	queue_free()
	
func jefe_activo() -> bool:
	return is_inside_tree() and vida > 0 and estado != "muriendo"
	
func lanzar_espinas() -> void:
	if escena_espina == null:
		print("Falta asignar la escena de espinas")
		return

	var cantidad: int = 3
	var separacion: float = 12.0

	if fase == 2:
		cantidad = 5
	elif fase == 3:
		cantidad = 7

	for i in range(cantidad):
		var espina = escena_espina.instantiate()

		espina.dano = dano_espinas

		get_parent().add_child(espina)

		var desplazamiento = (
			i - (cantidad - 1) / 2.0
		) * separacion

		espina.global_position = global_position + Vector2(
			-25, desplazamiento
		)
