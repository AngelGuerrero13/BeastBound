
extends "res://personajes/enemigoBasico/enemigo_basico.gd"

signal talus_derrotado

enum Fase {
	PIEDRA,
	TRANSFORMACION,
	LAVA,
	DERROTADO
}

var fase_actual = Fase.PIEDRA

@export var reduccion_dano_cuerpo: float = 0.9
@export var velocidad_fase_2: float = 30.0
@export_group("Rastro de lava")
@export var distancia_entre_charcos: float  = 20.0

var escena_zona_lava = preload("res://personajes/enemigos_nivel2/jefe_nivel2/ZonaLava.tscn")
var ultima_posicion_lava: Vector2

func _ready() -> void:
	vida_maxima = 100
	vida = vida_maxima
	dano = 3
	velocidad = 30.0
	
	super._ready()
	ultima_posicion_lava = global_position

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
	
	if vida <= 0:
		if fase_actual == Fase.PIEDRA:
			transformar_en_lava()
		else:
			derrotar_talus()

func recibir_dano(cantidad: int) -> void:
	recibir_dano_talus(float(cantidad), false)
	
	
func _on_area_deteccion_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		jugador_objetivo = body
		print("Talus detectó al jugador")


func _on_area_deteccion_body_exited(body: Node2D) -> void:
	if body == jugador_objetivo:
		jugador_objetivo = null
		print("El jugador salió del área")

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
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
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
