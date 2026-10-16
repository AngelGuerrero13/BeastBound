extends CharacterBody2D

signal vida_cambiada(nueva_vida: int)
signal ha_muerto()

@export var velocidad: float = 100.0
@export var vida_maxima: int = 6
@export var vida: int = 6
@export var dano: int = 1
@export var es_jugador: bool = true
@export var tiempo_invulnerable: float = 0.6
@export var escena_flecha: PackedScene
@export var corazon_lleno: Texture2D
@export var corazon_mitad: Texture2D
@export var corazon_vacio: Texture2D

var mira_izquierda := false
var muerto := false
var atacando := false
var invulnerabilidad := 0.0
var direccion_disparo := Vector2.RIGHT
var flecha_lanzada := false
@onready var imagen: AnimatedSprite2D = $"Imagen Raton"
@onready var corazones: HBoxContainer = $"Interfaz Jugador/Corazones Vida"
@onready var hud: CanvasLayer = $"Interfaz Jugador"

func _ready() -> void:
	imagen.animation_changed.connect(_actualizar_color)
	_actualizar_color()
	vida = clampi(vida, 0, vida_maxima)
	actualizar_corazones()
	if vida == 0:
		morir()

func _actualizar_color() -> void:
	var material_color := imagen.material as ShaderMaterial
	if material_color:
		material_color.set_shader_parameter("ajustar_derecha", false)

func _physics_process(delta: float) -> void:
	invulnerabilidad = maxf(0.0, invulnerabilidad - delta)
	imagen.modulate.a = 0.5 if invulnerabilidad > 0.0 and fmod(invulnerabilidad, 0.12) < 0.06 and not muerto else 1.0
	if muerto:
		return
	if atacando:
		velocity = Vector2.ZERO
		return
	if es_jugador and Input.is_action_just_pressed("ataque_normal"):
		atacar(get_global_mouse_position() - (global_position + Vector2(0, -20)))
		return
	var direccion := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") if es_jugador else Vector2.ZERO
	velocity = direccion * velocidad
	move_and_slide()
	if get_real_velocity().length_squared() <= 0.01:
		reproducir_reposo()
	elif absf(direccion.x) >= absf(direccion.y):
		mira_izquierda = direccion.x < 0.0
		imagen.flip_h = not mira_izquierda
		imagen.play("caminar_izquierda" if mira_izquierda else "caminar")
	else:
		imagen.flip_h = false
		imagen.play("caminar_arriba" if direccion.y < 0.0 else "caminar_abajo")

func reproducir_reposo() -> void:
	imagen.flip_h = mira_izquierda
	imagen.play("reposo")

func atacar(direccion: Vector2) -> void:
	if muerto or atacando or direccion.is_zero_approx():
		return
	atacando = true
	flecha_lanzada = false
	velocity = Vector2.ZERO
	direccion_disparo = direccion.normalized()
	mira_izquierda = direccion_disparo.x < 0.0
	imagen.flip_h = mira_izquierda
	imagen.play("atacar")

func _al_cambiar_cuadro() -> void:
	# Cuarto cuadro: cuerda suelta, una sola flecha por ataque.
	if imagen.animation == &"atacar" and imagen.frame == 3 and not flecha_lanzada and not muerto:
		flecha_lanzada = true
		var flecha := escena_flecha.instantiate() as Area2D
		flecha.direccion = direccion_disparo
		flecha.dano = dano
		flecha.tirador = self
		get_parent().add_child(flecha)
		flecha.global_position = global_position + direccion_disparo * 18.0

func _al_terminar_animacion() -> void:
	if imagen.animation == &"atacar" and not muerto:
		atacando = false
		reproducir_reposo()

func recibir_dano(cantidad: int) -> void:
	if muerto or cantidad <= 0 or invulnerabilidad > 0.0:
		return
	vida = maxi(0, vida - cantidad)
	invulnerabilidad = tiempo_invulnerable
	actualizar_corazones()
	vida_cambiada.emit(vida)
	if vida == 0:
		morir()

func actualizar_corazones() -> void:
	for i in corazones.get_child_count():
		var restantes := vida - i * 2
		corazones.get_child(i).texture = corazon_lleno if restantes >= 2 else (corazon_mitad if restantes == 1 else corazon_vacio)

func morir() -> void:
	if muerto:
		return
	muerto = true
	vida = 0
	atacando = false
	velocity = Vector2.ZERO
	actualizar_corazones()
	remove_from_group("Jugador")
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	imagen.modulate = Color.WHITE
	imagen.flip_h = mira_izquierda
	# Reproducir una sola vez y conservar la pose final.
	imagen.play("morir")
	ha_muerto.emit()
