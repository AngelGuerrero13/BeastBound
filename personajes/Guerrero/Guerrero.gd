extends "res://personajes/personajeBase/personaje_base.gd"

# --- SOLO VARIABLES EXTRAS Y ESPECÍFICAS DEL GUERRERO ---
@export_group("Combate y Habilidades (Guerrero)")
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
	# Ajustamos las estadísticas de la nutria sobrescribiendo las variables del padre:
	vida_maxima = 10
	vida = 10
	dano = 1                         # Daño moderado por golpe
	velocidad = 230.0                # Un poco más rápido al moverse
	tiempo_recarga_normal = 0.25     # Frecuencia de ataque rápida
	rango_ataque = 55.0              # Alcance del arma
	
	# Configuración inicial de la barra
	if barra_carga:
		barra_carga.visible = true
		barra_carga.max_value = tiempo_requerido * 2.0
		barra_carga.value = energia_actual
		
	# Llamamos a actualizar corazones para reflejar los 10 de vida (5 corazones)
	actualizar_corazones()


# BUCLE DE INPUTS (Combate de la nutria)
func _process(delta: float) -> void:
	if not es_jugador:
		return
	
	# 1. ATAQUE NORMAL
	if Input.is_action_just_pressed("ataque_normal"):
		if puede_atacar_normal:
			puede_atacar_normal = false
			ejecutar_ataque_normal(obtener_enemigo_objetivo())
			
			await get_tree().create_timer(tiempo_recarga_normal).timeout
			puede_atacar_normal = true
			
	# 2. ATAQUE CARGADO (Consume 100% de la energía base)
	if Input.is_action_just_pressed("ataque_cargado"):
		if energia_actual >= tiempo_requerido:
			energia_actual -= tiempo_requerido
			actualizar_hud_carga()
			ejecutar_ataque_cargado(obtener_enemigo_objetivo())
		else:
			print("Energía insuficiente para Ataque Cargado.")

	# 3. HABILIDAD DEFINITIVA (Consume 200% de la energía base)
	if Input.is_action_just_pressed("habilidad_definitiva"):
		var carga_definitiva = tiempo_requerido * 2.0
		if energia_actual >= carga_definitiva:
			energia_actual -= carga_definitiva
			actualizar_hud_carga()
			ejecutar_habilidad_definitiva(obtener_enemigo_objetivo())
		else:
			print("Energía insuficiente para Habilidad Definitiva.")


# SISTEMA DE COMBATE

func ejecutar_ataque_normal(objetivo) -> void:
	var enemigo = objetivo if objetivo else obtener_enemigo_objetivo()
	if enemigo:
		print(name, " realiza un ataque rápido a ", enemigo.name, " por ", dano, " de daño.")
		if enemigo.has_method("recibir_dano"):
			enemigo.recibir_dano(dano)
			# Suma carga de energía únicamente cuando impacta
			acumular_energia(carga_por_golpe)
	else:
		print(name, " ataca al aire.")

func ejecutar_ataque_cargado(objetivo) -> void:
	if not es_jugador:
		return
	
	var enemigo = objetivo if objetivo else obtener_enemigo_objetivo()
	if enemigo:
		var dano_cargado = dano * 2 
		print(name, " realiza un ataque CARGADO a ", enemigo.name, " por ", dano_cargado, " de daño.")
		if enemigo.has_method("recibir_dano"):
			enemigo.recibir_dano(dano_cargado)
	else:
		print(name, " realiza ataque cargado al aire.")

func ejecutar_habilidad_definitiva(objetivo) -> void:
	var dano_definitiva = int(dano * multiplicador_dano_definitiva)
	print("¡¡", name, " desata su HABILIDAD DEFINITIVA en área por ", dano_definitiva, " de daño!!")
	
	var enemigos = get_tree().get_nodes_in_group("enemigos")
	for enemigo in enemigos:
		if is_instance_valid(enemigo) and global_position.distance_to(enemigo.global_position) <= (rango_ataque * 2.0):
			if enemigo.has_method("recibir_dano"):
				enemigo.recibir_dano(dano_definitiva)

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


# GESTIÓN DE ENERGÍA Y HUD

func acumular_energia(cantidad: float) -> void:
	var max_energia = tiempo_requerido * 2.0
	energia_actual = clamp(energia_actual + cantidad, 0.0, max_energia)
	actualizar_hud_carga()

func actualizar_hud_carga() -> void:
	if barra_carga:
		barra_carga.visible = true
		barra_carga.max_value = tiempo_requerido * 2.0
		barra_carga.value = energia_actual


# PROGRESIÓN (CRISTALES DE EXPERIENCIA)

func ganar_cristales(cantidad: int) -> void:
	cristales_experiencia += cantidad
	print("¡Has obtenido %d Cristales de Experiencia! Total: %d" % [cantidad, cristales_experiencia])

func obtener_costo_mejora(nivel_actual: int) -> int:
	return int(costo_base_mejora * pow(multiplicador_costo, nivel_actual))

func mejorar_fuerza() -> bool:
	var costo = obtener_costo_mejora(nivel_fuerza)
	if cristales_experiencia >= costo:
		cristales_experiencia -= costo
		nivel_fuerza += 1
		dano += 1
		print("¡Fuerza mejorada! Nuevo daño: ", dano)
		return true
	return false

func mejorar_agilidad() -> bool:
	var costo = obtener_costo_mejora(nivel_agilidad)
	if cristales_experiencia >= costo:
		cristales_experiencia -= costo
		nivel_agilidad += 1
		velocidad += 15.0
		print("¡Agilidad mejorada! Nueva velocidad: ", velocidad)
		return true
	return false

func mejorar_resistencia() -> bool:
	var costo = obtener_costo_mejora(nivel_resistencia)
	if cristales_experiencia >= costo:
		cristales_experiencia -= costo
		nivel_resistencia += 1
		vida_maxima += 2
		vida += 2
		actualizar_corazones()
		print("¡Resistencia mejorada! Nueva vida máxima: ", vida_maxima)
		return true
	return false
