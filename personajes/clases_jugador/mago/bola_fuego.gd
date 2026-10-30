extends "res://personajes/proyectil_base.gd"

var objetivo: Node2D = null
var es_ataque_cargado: bool = false

func _ready() -> void:
	if has_node("Animacion Fuego"):
		$"Animacion Fuego".play("default")

func configurar_bola(nuevo_objetivo: Node2D, cargado: bool, direccion_base: Vector2) -> void:
	objetivo = nuevo_objetivo
	es_ataque_cargado = cargado
	
	var dano_final = 2 if es_ataque_cargado else 1
	velocidad = 200.0 if es_ataque_cargado else 300.0
	scale = Vector2(3, 3) if es_ataque_cargado else Vector2(1, 1)

	super.configurar(direccion_base, true, dano_final)

func _physics_process(delta: float) -> void:
	if objetivo and is_instance_valid(objetivo):
		direccion_vuelo = (objetivo.global_position - global_position).normalized()
		rotation = direccion_vuelo.angle()
		
	super._physics_process(delta)
