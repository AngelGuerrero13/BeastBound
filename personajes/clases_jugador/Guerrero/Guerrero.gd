extends "res://personajes/personajeBase/personaje_base.gd"

@export_group("Energía")
@export var energia_maxima: float = 100.0
@export var carga_por_golpe: float = 20.0
@export var costo_cargado: float = 50.0
@export var costo_definitiva: float = 100.0

@export_group("Habilidades")
@export var tiempo_anticipacion_golpe: float = 0.1
@export var multiplicador_dano_cargado: float = 2.0
@export var multiplicador_dano_definitiva: float = 5.0

var energia_actual: float = 0.0

@onready var zona_golpe: Area2D = $ZonaGolpe
@onready var zona_definitiva: Area2D = $ZonaDefinitiva

func _ready() -> void:
	super()
	if barra_carga:
		barra_carga.max_value = energia_maxima
		actualizar_hud_carga()

func _physics_process(delta: float) -> void:
	super(delta)
	zona_golpe.position.x = abs(zona_golpe.position.x) * obtener_direccion_frente().x

func _process(delta: float) -> void:
	super(delta)
	if not es_jugador:
		return
	
	var accion = prefijo_input + "_ataque_definitivo"
	if InputMap.has_action(accion) and Input.is_action_just_pressed(accion) \
			and energia_actual >= costo_definitiva and not esta_atacando:
		gastar_energia(costo_definitiva)
		ejecutar_habilidad_definitiva()

# Ataque normal: da energía al acertar
func ejecutar_ataque_normal(_objetivo) -> void:
	await get_tree().create_timer(tiempo_anticipacion_golpe).timeout
	if vida <= 0:
		return
	if golpear_zona(zona_golpe, dano) > 0:
		acumular_energia(carga_por_golpe)

# Ataque cargado: se gasta energía, no se mantiene el botón
func manejar_ataque_cargado(_delta: float) -> void:
	var accion = prefijo_input + "_ataque_cargado"
	if Input.is_action_just_pressed(accion) and energia_actual >= costo_cargado and not esta_atacando:
		gastar_energia(costo_cargado)
		ejecutar_ataque_cargado(null)

func ejecutar_ataque_cargado(_objetivo) -> void:
	golpear_zona(zona_golpe, int(dano * multiplicador_dano_cargado))

# Definitiva: daño en área alrededor del guerrero
func ejecutar_habilidad_definitiva() -> void:
	golpear_zona(zona_definitiva, int(dano * multiplicador_dano_definitiva))

func golpear_zona(zona: Area2D, danio: int) -> int:
	var golpeados := 0
	for c in zona.get_overlapping_bodies():
		if c != self and c.has_method("recibir_dano") \
				and "es_jugador" in c and c.es_jugador != es_jugador:
			c.recibir_dano(danio)
			golpeados += 1
	return golpeados

func acumular_energia(cantidad: float) -> void:
	energia_actual = clamp(energia_actual + cantidad, 0.0, energia_maxima)
	actualizar_hud_carga()

func gastar_energia(cantidad: float) -> void:
	energia_actual = max(0.0, energia_actual - cantidad)
	actualizar_hud_carga()

func actualizar_hud_carga() -> void:
	if barra_carga:
		barra_carga.value = energia_actual
		barra_carga.visible = energia_actual > 0.0
