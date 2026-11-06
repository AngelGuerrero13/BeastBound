extends "res://personajes/personajeBase/personaje_base.gd"

@export var tiempo_anticipacion_golpe := 0.15
@export var velocidad_embestida := 400.0
@export var duracion_embestida_maxima := 0.25
@export var tiempo_maximo_carga := 1.0
@export var duracion_escudo := 4.0
@export var recarga_escudo := 10.0
@export var velocidad_escudo := 80.0
@export var duracion_aturdimiento := 1.5

var esta_embistiendo := false
var escudo_activo := false
var escudo_disponible := true
var direccion_embestida := Vector2.ZERO
var dano_embestida := 1
var golpeados: Array = []

@onready var frente: Node2D = $Frente
@onready var zona_golpe: Area2D = $Frente/ZonaGolpe
@onready var escudo: Area2D = $Frente/EscudoReinhardt

func _ready() -> void:
	super()
	barra_carga.max_value = tiempo_maximo_carga
	poner_escudo(false)
	escudo.area_entered.connect(_on_escudo_area_entered)

func _process(delta: float) -> void:
	super(delta)
	if es_jugador and escudo_disponible and not (esta_cargando or esta_embistiendo or esta_atacando) \
			and Input.is_action_just_pressed(prefijo_input + "_ataque_definitivo"):
		activar_escudo()

func _physics_process(delta: float) -> void:
	super(delta)
	frente.scale.x = obtener_direccion_frente().x
	if esta_embistiendo:
		for c in zona_golpe.get_overlapping_bodies():
			if es_enemigo(c) and not golpeados.has(c):
				golpeados.append(c)
				c.recibir_dano(dano_embestida)
				if c.has_method("aturdir"):
					c.aturdir(duracion_aturdimiento)

func manejar_movimiento() -> void:
	if esta_embistiendo:
		velocity = direccion_embestida * velocidad_embestida
		return
	var normal = velocidad
	if escudo_activo: velocidad = velocidad_escudo
	super()
	velocidad = normal

# Golpe de escudo
func manejar_ataque_normal() -> void:
	if not (esta_cargando or esta_embistiendo or escudo_activo):
		super()

func ejecutar_ataque_normal(_o) -> void:
	await get_tree().create_timer(tiempo_anticipacion_golpe).timeout
	for c in zona_golpe.get_overlapping_bodies():
		if es_enemigo(c): c.recibir_dano(dano)

# Embestida (se carga y se lanza al soltar)
func manejar_ataque_cargado(delta: float) -> void:
	if esta_embistiendo: return
	var presionado = Input.is_action_pressed(prefijo_input + "_ataque_cargado")
	if presionado and not escudo_activo and not esta_atacando:
		esta_cargando = true
		tiempo_cargado = min(tiempo_cargado + delta, tiempo_maximo_carga)
		barra_carga.visible = true
		barra_carga.value = tiempo_cargado
		var dir = Input.get_vector(prefijo_input + "_izquierda", prefijo_input + "_derecha",
			prefijo_input + "_arriba", prefijo_input + "_abajo")
		if dir != Vector2.ZERO:
			direccion_embestida = dir
			voltear_hacia(dir.x)
	elif esta_cargando:
		esta_cargando = false
		barra_carga.visible = false
		ejecutar_ataque_cargado(null)

func ejecutar_ataque_cargado(_o) -> void:
	var porcentaje = clamp(tiempo_cargado / tiempo_maximo_carga, 0.2, 1.0)
	tiempo_cargado = 0.0
	if direccion_embestida == Vector2.ZERO:
		direccion_embestida = obtener_direccion_frente()
	direccion_embestida = direccion_embestida.normalized()
	dano_embestida = max(1, int(ceil(dano * 2 * porcentaje)))
	golpeados.clear()
	esta_embistiendo = true
	await get_tree().create_timer(duracion_embestida_maxima * porcentaje).timeout
	esta_embistiendo = false
	direccion_embestida = Vector2.ZERO

# Escudo
func activar_escudo() -> void:
	escudo_activo = true
	escudo_disponible = false
	poner_escudo(true)
	await get_tree().create_timer(duracion_escudo).timeout
	escudo_activo = false
	poner_escudo(false)
	await get_tree().create_timer(recarga_escudo).timeout
	escudo_disponible = true

func poner_escudo(activo: bool) -> void:
	escudo.visible = activo
	escudo.get_node("CollisionShape2D").set_deferred("disabled", not activo)

func recibir_dano(cantidad: int) -> void:
	if not escudo_activo:
		super(cantidad)

func _on_escudo_area_entered(area: Area2D) -> void:
	if escudo_activo and "disparado_por_jugador" in area and area.disparado_por_jugador != es_jugador:
		area.queue_free()

func es_enemigo(c: Node) -> bool:
	return c != self and c.has_method("recibir_dano") and "es_jugador" in c and c.es_jugador != es_jugador
