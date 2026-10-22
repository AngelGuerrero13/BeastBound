extends "res://personajes/personajeBase/personaje_base.gd"

@export_group("Combate y Habilidades")
@export var carga_por_golpe: float = 20.0
@export var multiplicador_dano_definitiva: float = 5.0
var energia_actual: float = 0.0

@export_group("Progresión de Habilidades")
@export var cristales_experiencia: int = 0
@export var costo_base_mejora: int = 10
@export var multiplicador_costo: float = 1.5

var nivel_fuerza: int = 0
var nivel_agilidad: int = 0
var nivel_resistencia: int = 0

func _ready() -> void:
	vida_maxima = 10
	vida = 10
	dano = 1
	velocidad = 230.0
	tiempo_recarga_normal = 0.25
	rango_ataque = 55.0
	
	if barra_carga:
		barra_carga.visible = true
		barra_carga.max_value = tiempo_requerido * 2.0
		barra_carga.value = energia_actual

func _process(delta: float) -> void:
	if not es_jugador:
		return
		
	if Input.is_action_just_pressed(prefijo_input + "_ataque_normal"):
		if puede_atacar_normal:
			puede_atacar_normal = false
			ejecutar_ataque_normal(obtener_enemigo_objetivo())
			await get_tree().create_timer(tiempo_recarga_normal).timeout
			puede_atacar_normal = true
			
	if Input.is_action_just_pressed(prefijo_input + "_ataque_cargado"):
		if energia_actual >= tiempo_requerido:
			energia_actual -= tiempo_requerido
			actualizar_hud_carga()
			ejecutar_ataque_cargado(obtener_enemigo_objetivo())
			
	if Input.is_action_just_pressed(prefijo_input + "_habilidad_definitiva"):
		var carga_definitiva = tiempo_requerido * 2.0
		if energia_actual >= carga_definitiva:
			energia_actual -= carga_definitiva
			actualizar_hud_carga()
			ejecutar_habilidad_definitiva(obtener_enemigo_objetivo())

func ejecutar_ataque_normal(objetivo) -> void:
	if objetivo and objetivo.has_method("recibir_dano"):
		objetivo.recibir_dano(dano)
		acumular_energia(carga_por_golpe)

func ejecutar_ataque_cargado(objetivo) -> void:
	if objetivo and objetivo.has_method("recibir_dano"):
		objetivo.recibir_dano(dano * 2)

func ejecutar_habilidad_definitiva(objetivo) -> void:
	var dano_definitiva = int(dano * multiplicador_dano_definitiva)
	var enemigos = get_tree().get_nodes_in_group("enemigos")
	for enemigo in enemigos:
		if is_instance_valid(enemigo) and global_position.distance_to(enemigo.global_position) <= (rango_ataque * 2.0):
			if enemigo.has_method("recibir_dano"):
				enemigo.recibir_dano(dano_definitiva)

func acumular_energia(cantidad: float) -> void:
	var max_energia = tiempo_requerido * 2.0
	energia_actual = clamp(energia_actual + cantidad, 0.0, max_energia)
	actualizar_hud_carga()

func actualizar_hud_carga() -> void:
	if barra_carga:
		barra_carga.value = energia_actual

func obtener_enemigo_objetivo() -> Node2D:
	var enemigos = get_tree().get_nodes_in_group("enemigos")
	var enemigo_cercano: Node2D = null
	var menor_distancia: float = rango_ataque
	for enemigo in enemigos:
		if is_instance_valid(enemigo) and enemigo != self:
			var distancia = global_position.distance_to(enemigo.global_position)
			if distancia <= menor_distancia:
				menor_distancia = distancia
				enemigo_cercano = enemigo
	return enemigo_cercano

# --- PROGRESIÓN ---
func mejorar_resistencia() -> bool:
	var costo = int(costo_base_mejora * pow(multiplicador_costo, nivel_resistencia))
	if cristales_experiencia >= costo:
		cristales_experiencia -= costo
		nivel_resistencia += 1
		vida_maxima += 2
		vida += 2
		vida_cambiada.emit(vida) 
		return true
	return false

func mejorar_fuerza() -> bool:
	var costo = int(costo_base_mejora * pow(multiplicador_costo, nivel_fuerza))
	if cristales_experiencia >= costo:
		cristales_experiencia -= costo
		nivel_fuerza += 1
		dano += 1
		return true
	return false

func mejorar_agilidad() -> bool:
	var costo = int(costo_base_mejora * pow(multiplicador_costo, nivel_agilidad))
	if cristales_experiencia >= costo:
		cristales_experiencia -= costo
		nivel_agilidad += 1
		velocidad += 15.0
		return true
	return false
