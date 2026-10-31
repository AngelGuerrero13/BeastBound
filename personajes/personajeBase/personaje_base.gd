extends CharacterBody2D

# --- SEÑALES ---
signal vida_cambiada(nueva_vida: int)
signal ha_muerto()

@export var es_jugador: bool = true

@export var prefijo_input: String = "p1"

# --- ESTADÍSTICAS BASE ---
@export var vida_maxima: int = 6
@export var vida: int = 6
@export var velocidad: float = 200.0
@export var dano: int = 1
@export var velocidad_ataque: float = 5.0
@export var rango_ataque: float = 2.0
@export var sprite_mira_izquierda: bool = true
@export var desfase_horizontal_sprite: float = 0.0

# --- FÍSICAS Y SALTO (Beat 'em up) ---
@export var fuerza_salto: float = 400.0
@export var gravedad: float = 980.0

var altura: float = 0.0
var velocidad_vertical: float = 0.0
var en_suelo: bool = true

# --- NODOS HIJOS ---
@onready var sprite: Sprite2D = $"Imagen Personaje"
@onready var barra_carga: TextureProgressBar = $"Barra Ataque Cargado"
@onready var sombra: Sprite2D = get_node_or_null("Sombra")

# UI Jugador
@export var retrato: Texture2D

# UI Enemigo
@onready var barra_vida_enemigo: TextureProgressBar = $"Barra Vida Enemigo"

# --- VARIABLES DE CONTROL DE ATAQUE ---
@export var tiempo_recarga_normal: float = 0.5
@export var tiempo_requerido: float = 3.0

var puede_atacar_normal: bool = true
var esta_atacando: bool = false
var esta_cargando: bool = false
var tiempo_cargado: float = 0.0
var ya_disparo_cargado: bool = false

func _ready() -> void:

	if barra_carga:
		barra_carga.visible = false
		barra_carga.value = 0.0
		barra_carga.max_value = tiempo_requerido
		barra_carga.step = 0.01

	if es_jugador:
		add_to_group("Jugador")
		if barra_vida_enemigo: barra_vida_enemigo.visible = false
	else:

		if has_node("Barra Ataque Cargado"):
			$"Barra Ataque Cargado".visible = false

		if barra_vida_enemigo:
			barra_vida_enemigo.visible = true
			barra_vida_enemigo.max_value = vida_maxima
			barra_vida_enemigo.value = vida

	actualizar_offset_horizontal()

# BUCLE DE INPUTS (Ataques y UI)
func _process(delta: float) -> void:

	if not es_jugador:
		return

	# 1. ATAQUE NORMAL
	if Input.is_action_just_pressed(prefijo_input + "_ataque_normal"):
		if puede_atacar_normal:
			puede_atacar_normal = false
			esta_atacando = true
			ejecutar_ataque_normal(obtener_enemigo_objetivo())

			await get_tree().create_timer(tiempo_recarga_normal).timeout
			puede_atacar_normal = true
			esta_atacando = false

	# 2. ATAQUE CARGADO
	if Input.is_action_pressed(prefijo_input + "_ataque_cargado"):
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

	if esta_atacando or esta_cargando:
		velocity = Vector2.ZERO
		return

	var input_dir = Input.get_vector(
		prefijo_input + "_izquierda",
		prefijo_input + "_derecha",
		prefijo_input + "_arriba",
		prefijo_input + "_abajo"
	)
	velocity = input_dir * velocidad

	if sprite != null:
		if input_dir.x != 0:
			if sprite_mira_izquierda:
				sprite.flip_h = input_dir.x > 0
			else:
				sprite.flip_h = input_dir.x < 0
			actualizar_offset_horizontal()

func actualizar_offset_horizontal() -> void:
	if sprite == null or desfase_horizontal_sprite == 0.0:
		return
	if sprite.flip_h:
		sprite.position.x = -desfase_horizontal_sprite
	else:
		sprite.position.x = desfase_horizontal_sprite

func manejar_gravedad_y_salto(delta: float) -> void:
	if not en_suelo:
		velocidad_vertical -= gravedad * delta
		altura += velocidad_vertical * delta

		if altura <= 0.0:
			altura = 0.0
			velocidad_vertical = 0.0
			en_suelo = true
	else:
		if es_jugador and Input.is_action_just_pressed(prefijo_input + "_salto"):
			saltar()

	# Desplaza el sprite visualmente hacia arriba/abajo basándose en la altura
	if sprite:
		sprite.position.y = -altura

	# Efecto de sombra: la sombra se achica levemente al saltar alto
	if sombra:
		var escala_sombra = max(0.5, 1.0 - (altura / 350.0))
		sombra.scale = Vector2(escala_sombra, escala_sombra)

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

	if vida <= 0:
		morir()

func morir() -> void:
	print(name, " ha muerto.")
	ha_muerto.emit()
	queue_free()
