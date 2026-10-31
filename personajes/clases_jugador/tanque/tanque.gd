extends "res://personajes/personajeBase/personaje_base.gd"


# --- VARIABLES DE LA EMBESTIDA ---
@export var velocidad_embestida: float = 800.0
@export var duracion_embestida_maxima: float = 0.35
@export var tiempo_maximo_carga_embestida: float = 1.0

var esta_cargando_embestida: bool = false
var esta_embistiendo: bool = false
var nivel_de_carga: float = 0.0
var direccion_embestida: Vector2 = Vector2.ZERO

# --- VARIABLES DEL ESCUDO (REINHARDT) ---
@export var velocidad_escudo: float = 80.0
var escudo_activo: bool = false
@onready var escudo_nodo: Area2D = get_node_or_null("EscudoReinhardt")
@onready var colision_escudo: CollisionShape2D = get_node_or_null("EscudoReinhardt/CollisionShape2D")

func _ready() -> void:
	# Ejecuta el _ready() de personaje_base.gd para configurar la UI y las barras de vida
	super()

	# Aseguramos que el escudo nazca apagado
	if escudo_nodo:
		escudo_nodo.visible = false
		if colision_escudo:
			colision_escudo.disabled = true

# Sobrescribimos SOLO el movimiento; la gravedad y las físicas las sigue manejando la base
func manejar_movimiento() -> void:
	if not es_jugador:
		return

	# La dirección solo se lee aquí para apuntar la embestida.
	var input_dir := Vector2.ZERO
	var delta = get_physics_process_delta_time()

	# Leemos la acción heredada y la tecla del escudo
	var accion_embestida = Input.is_action_pressed(prefijo_input + "_ataque_cargado")
	var c_presionada = Input.is_physical_key_pressed(KEY_C)

	# 0. FASE DE ESCUDO
	if c_presionada and not esta_embistiendo and not esta_cargando_embestida:
		escudo_activo = true
		if escudo_nodo:
			escudo_nodo.visible = true
			if colision_escudo: colision_escudo.disabled = false
	else:
		escudo_activo = false
		if escudo_nodo:
			escudo_nodo.visible = false
			if colision_escudo: colision_escudo.disabled = true

	# 1. FASE DE CARGA EMBESTIDA
	if accion_embestida and not esta_embistiendo and not escudo_activo:
		esta_cargando_embestida = true
		nivel_de_carga += delta
		input_dir = Input.get_vector(prefijo_input + "_izquierda", prefijo_input + "_derecha",
			prefijo_input + "_arriba", prefijo_input + "_abajo")
		velocity = Vector2.ZERO # El tanque se planta en el suelo

		if input_dir != Vector2.ZERO:
			direccion_embestida = input_dir
			orientar_personaje_y_escudo(input_dir)
		return

	# 2. EJECUCIÓN DE EMBESTIDA (Al soltar el botón)
	elif esta_cargando_embestida and not accion_embestida:
		esta_cargando_embestida = false
		ejecutar_embestida()

	# 3. APLICACIÓN DE VELOCIDADES
	if esta_embistiendo:
		var dir_final = direccion_embestida
		if dir_final == Vector2.ZERO:
			if sprite_mira_izquierda:
				dir_final = Vector2.RIGHT if sprite.flip_h else Vector2.LEFT
			else:
				dir_final = Vector2.LEFT if sprite.flip_h else Vector2.RIGHT

		velocity = dir_final * velocidad_embestida

	else:
		# El desplazamiento, orientación y bloqueo al atacar pertenecen a la base.
		# El escudo solo cambia la velocidad durante esta llamada.
		var velocidad_normal := velocidad
		if escudo_activo:
			velocidad = velocidad_escudo
		super.manejar_movimiento()
		velocidad = velocidad_normal
		actualizar_posicion_escudo()

func ejecutar_embestida() -> void:
	esta_embistiendo = true
	var porcentaje_carga = clamp(nivel_de_carga / tiempo_maximo_carga_embestida, 0.2, 1.0)
	var duracion_final = duracion_embestida_maxima * porcentaje_carga
	nivel_de_carga = 0.0

	await get_tree().create_timer(duracion_final).timeout

	esta_embistiendo = false
	direccion_embestida = Vector2.ZERO

# Agrupamos la lógica visual para mantener la herencia limpia
func orientar_personaje_y_escudo(dir: Vector2) -> void:
	if sprite != null:
		if sprite_mira_izquierda:
			sprite.flip_h = dir.x > 0
		else:
			sprite.flip_h = dir.x < 0

		# Llamamos al método que ya existe en el script base
		actualizar_offset_horizontal()

	actualizar_posicion_escudo()

func actualizar_posicion_escudo() -> void:
	if escudo_nodo and sprite:
		var mira_izquierda: bool = not sprite.flip_h if sprite_mira_izquierda else sprite.flip_h
		escudo_nodo.position.x = -45.0 if mira_izquierda else 45.0
