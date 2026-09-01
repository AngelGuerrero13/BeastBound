extends CharacterBody2D

# --- SEÑALES ---
signal vida_cambiada(nueva_vida: int)
signal ha_muerto()

# --- ESTADÍSTICAS BASE ---
@export var vida: int = 100
@export var velocidad: float = 200.0 # Subido de 20 para que sea jugable en píxeles
@export var dano: int = 5
@export var velocidad_ataque: float = 5.0
@export var rango_ataque: float = 4.0 

# --- FÍSICAS Y SALTO (Beat 'em up) ---
@export var fuerza_salto: float = 400.0
@export var gravedad: float = 980.0

var altura: float = 0.0 # Simula el eje Z (qué tan alto está del suelo)
var velocidad_vertical: float = 0.0
var en_suelo: bool = true

# Referencia al nodo visual. Es necesario que el personaje tenga un Sprite2D como hijo.
@onready var sprite: Sprite2D = $personajeSprite

# --- BUCLE DE FÍSICAS ---
func _physics_process(delta: float) -> void:
	manejar_movimiento()
	manejar_gravedad_y_salto(delta)
	
	# Mueve la caja de colisión en las 8 direcciones (X, Y)
	move_and_slide()

## Controla el movimiento en 8 direcciones
func manejar_movimiento() -> void:
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_dir * velocidad
	
	# Comprobamos que el nodo sprite exista antes de intentar voltearlo
	if sprite != null:
		if input_dir.x != 0:
			sprite.flip_h = input_dir.x < 0

## Controla la gravedad simulada y el desplazamiento visual del salto
func manejar_gravedad_y_salto(delta: float) -> void:
	if not en_suelo:
		velocidad_vertical -= gravedad * delta
		altura += velocidad_vertical * delta
		
		# Si toca el suelo
		if altura <= 0.0:
			altura = 0.0
			velocidad_vertical = 0.0
			en_suelo = true
	else:
		# Detectar input de salto (Asignado a la barra espaciadora por defecto en 'ui_accept')
		if Input.is_action_just_pressed("ui_accept"):
			saltar()
			
	# Desplaza el sprite visualmente hacia arriba/abajo basándose en la altura
	# Importante: El Sprite2D no debe ser el nodo raíz, debe ser hijo del CharacterBody2D
	if sprite:
		sprite.position.y = -altura

## Inicia el salto
func saltar() -> void:
	if en_suelo:
		velocidad_vertical = fuerza_salto
		en_suelo = false
		print(name, " ha saltado.")

# --- FUNCIONES DE COMBATE ---

func ataque(objetivo) -> void:
	print(name, " realiza un ataque básico a ", objetivo.name, " por ", dano, " de daño.")
	if objetivo.has_method("recibir_dano"):
		objetivo.recibir_dano(dano)

func ataque_cargado(objetivo) -> void:
	var dano_cargado = dano * 2 
	print(name, " realiza un ataque CARGADO a ", objetivo.name, " por ", dano_cargado, " de daño.")
	if objetivo.has_method("recibir_dano"):
		objetivo.recibir_dano(dano_cargado)

func recibir_dano(cantidad: int) -> void:
	vida -= cantidad
	vida_cambiada.emit(vida)
	print(name, " recibió ", cantidad, " de daño. Vida restante: ", vida)
	
	if vida <= 0:
		morir()

func morir() -> void:
	print(name, " ha muerto.")
	ha_muerto.emit()
	queue_free()
