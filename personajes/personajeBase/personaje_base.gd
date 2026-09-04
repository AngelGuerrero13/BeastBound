extends CharacterBody2D

# --- SEÑALES ---
signal vida_cambiada(nueva_vida: int)
signal ha_muerto()

@export var es_jugador: bool = true

# --- ESTADÍSTICAS BASE ---
@export var vida_maxima: int = 6
@export var vida: int = 6
@export var velocidad: float = 200.0 
@export var dano: int = 1
@export var velocidad_ataque: float = 5.0
@export var rango_ataque: float = 2.0 

# --- SPRITES DE CORAZONES ---
@export var textura_corazon_lleno: Texture2D
@export var textura_corazon_mitad: Texture2D
@export var textura_corazon_vacio: Texture2D

# --- FÍSICAS Y SALTO (Beat 'em up) ---
@export var fuerza_salto: float = 400.0
@export var gravedad: float = 980.0

var altura: float = 0.0 
var velocidad_vertical: float = 0.0
var en_suelo: bool = true

# --- NODOS HIJOS ---
@onready var sprite: Sprite2D = $personajeSprite
@onready var barra_carga: TextureProgressBar = $BarraCarga

# UI Jugador
@onready var hud: CanvasLayer = $HUD
@onready var corazones_ui: HBoxContainer = $HUD/ContenedorCorazones

# UI Enemigo
@onready var barra_vida_enemigo: TextureProgressBar = $BarraVidaEnemigo

# --- VARIABLES DE CONTROL DE ATAQUE ---
@export var tiempo_recarga_normal: float = 0.5 
@export var tiempo_requerido: float = 3.0   

var puede_atacar_normal: bool = true
var esta_cargando: bool = false
var tiempo_cargado: float = 0.0          
var ya_disparo_cargado: bool = false     

func _ready() -> void:
	
	if barra_carga:
		barra_carga.visible = false          # Empieza invisible
		barra_carga.value = 0.0              # Empieza vacía
		barra_carga.max_value = tiempo_requerido # Se ajusta exactamente a los 3 segundos
		barra_carga.step = 0.01
		
	# Configurar barras de vida según quién sea
	if es_jugador:
		if barra_vida_enemigo: barra_vida_enemigo.visible = false
		actualizar_corazones()
	else:
		if hud: hud.visible = false
		
		if has_node("BarraCarga"):
			$BarraCarga.visible = false
		
		if barra_vida_enemigo:
			barra_vida_enemigo.visible = true
			barra_vida_enemigo.max_value = vida_maxima
			barra_vida_enemigo.value = vida

func actualizar_corazones() -> void:
	if not es_jugador or not corazones_ui: 
		return

	for corazon in corazones_ui.get_children():
		corazon.queue_free()

	# Si vida_maxima es 6, esto da 3 contenedores a dibujar
	var total_contenedores = vida_maxima / 2 

	for i in range(total_contenedores):
		var nuevo_icono = TextureRect.new()
		
		if vida >= (i * 2) + 2:
			nuevo_icono.texture = textura_corazon_lleno
		elif vida == (i * 2) + 1:
			nuevo_icono.texture = textura_corazon_mitad
		else:
			nuevo_icono.texture = textura_corazon_vacio
			
		nuevo_icono.stretch_mode = TextureRect.STRETCH_KEEP
		corazones_ui.add_child(nuevo_icono)

# BUCLE DE INPUTS (Ataques y UI)
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
			
	# 2. ATAQUE CARGADO
	if Input.is_action_pressed("ataque_cargado"):
		esta_cargando = true
		if barra_carga: barra_carga.visible = true 
		
		if not ya_disparo_cargado:
			tiempo_cargado += delta
			if barra_carga: barra_carga.value = tiempo_cargado 
			
			if tiempo_cargado >= tiempo_requerido:
				ejecutar_ataque_cargado(obtener_enemigo_objetivo())
				ya_disparo_cargado = true 
	else:
		esta_cargando = false
		tiempo_cargado = 0.0
		ya_disparo_cargado = false
		if barra_carga:
			barra_carga.visible = false 
			barra_carga.value = 0.0

# BUCLE DE FÍSICAS (Movimiento y Gravedad)
func _physics_process(delta: float) -> void:
	manejar_movimiento()
	manejar_gravedad_y_salto(delta)
	
	# Mueve la caja de colisión en las 8 direcciones (X, Y)
	move_and_slide()

func manejar_movimiento() -> void:
	
	if not es_jugador:
		return
	
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_dir * velocidad
	
	if sprite != null:
		if input_dir.x != 0:
			sprite.flip_h = input_dir.x < 0

func manejar_gravedad_y_salto(delta: float) -> void:
	if not en_suelo:
		velocidad_vertical -= gravedad * delta
		altura += velocidad_vertical * delta
		
		if altura <= 0.0:
			altura = 0.0
			velocidad_vertical = 0.0
			en_suelo = true
	else:
		if es_jugador and Input.is_action_just_pressed("ui_accept"):
			saltar()
			
	# Desplaza el sprite visualmente hacia arriba/abajo basándose en la altura
	if sprite:
		sprite.position.y = -altura

func saltar() -> void:
	if en_suelo:
		velocidad_vertical = fuerza_salto
		en_suelo = false
		print(name, " ha saltado.")

# SISTEMA DE COMBATE Y SALUD

func ejecutar_ataque_normal(objetivo) -> void:
	if objetivo:
		print(name, " realiza un ataque básico a ", objetivo.name, " por ", dano, " de daño.")
		if objetivo.has_method("recibir_dano"):
			objetivo.recibir_dano(dano)
	else:
		print(name, " ataca al aire.")

func ejecutar_ataque_cargado(objetivo) -> void:
	if not es_jugador:
		return
	
	if objetivo:
		var dano_cargado = dano * 2 
		print(name, " realiza un ataque CARGADO a ", objetivo.name, " por ", dano_cargado, " de daño.")
		if objetivo.has_method("recibir_dano"):
			objetivo.recibir_dano(dano_cargado)
	else:
		print(name, " realiza ataque cargado al aire.")

func obtener_enemigo_objetivo() -> Node2D:
	return null

func recibir_dano(cantidad: int) -> void:
	vida -= cantidad
	vida_cambiada.emit(vida)
	print(name, " recibió ", cantidad, " de daño. Vida restante: ", vida)
	
	if not es_jugador and barra_vida_enemigo:
		barra_vida_enemigo.value = vida
	
	actualizar_corazones()
	
	if vida <= 0:
		morir()

func morir() -> void:
	print(name, " ha muerto.")
	ha_muerto.emit()
	queue_free()
