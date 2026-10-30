extends "res://personajes/personajeBase/personaje_base.gd"


@export var distancia_patruya: float = 100.0
@export var rango_deteccion: float = 70.0

@export var dano_raices: int = 2
@export var dano_espinas: int = 1
@export var dano_ramas: int = 3

var direccion: int = -1
var posicion_inicial: float
var jugador: Node2D = null
var atacando: bool = false
var puede_atacar: bool = true

@onready var detector: Area2D = $Detector

func _ready() -> void:
	es_jugador = false
	
	super._ready()
	
	posicion_inicial = global_position.x
	
	var forma = detector.get_node("CollisionShape2D").shape
	if forma is RectangleShape2D:
		forma.radius = rango_deteccion

	detector.body_entered.connect(_cuando_entra_jugador)
	detector.body_exited.connect(_cuando_sale_jugador)
	
	
func _physics_process(_delta):
	if vida <= 0:
		return

	if jugador != null:
		vigilar_jugador()
	else:
		patrullar()

	move_and_slide()


func patrullar():
	velocity.x = velocidad * direccion

	if global_position.x >= posicion_inicial + distancia_patruya:
		direccion = -1

	elif global_position.x <= posicion_inicial - distancia_patruya:
		direccion = 1


func vigilar_jugador():
	velocity.x = 0

	if not atacando:
		elegir_ataque()


func _cuando_entra_jugador(cuerpo):
	if cuerpo.is_in_group("jugador"):
		jugador = cuerpo


func _cuando_sale_jugador(cuerpo):
	if cuerpo == jugador:
		jugador = null
		atacando = false


func elegir_ataque():
	atacando = true
	puede_atacar = false

	var ataque = randi_range(1, 3)

	match ataque:
		1:
			await ataque_raices()

		2:
			await ataque_espinas()

		3:
			await ataque_ramas()

	await get_tree().create_timer(1.0).timeout
	
	atacando = false

func atacar_jugador(cantidad_dano: int) -> void:
	if not is_instance_valid(jugador):
		return
		
	if jugador.has_method("recibir_dano"):
		jugador.recibir_dano(cantidad_dano)

func ataque_raices():
	print("¡El jefe usa raíces aprisionadoras!")
	await get_tree().create_timer(1.0).timeout


func ataque_espinas():
	print("¡El jefe lanza un racimo de espinas!")
	await get_tree().create_timer(1.5).timeout


func ataque_ramas():
	print("¡El jefe usa el azote de ramas!")
	await get_tree().create_timer(2.0).timeout


func recibir_dano(cantidad: int):
	vida -= cantidad
	print("Vida del jefe: ", vida)

	if vida <= 0:
		morir()


func morir() -> void:
	velocity = Vector2.ZERO
	ha_muerto.emit()
	print("¡El jefe arbusto ha sido derrotado!")
	queue_free()
