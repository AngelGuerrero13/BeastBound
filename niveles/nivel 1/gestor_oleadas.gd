extends Node2D

@export var hongo_cac: PackedScene
@export var hongo_explosivo: PackedScene
@export var hongo_tanque: PackedScene
@export var hongo_tirador: PackedScene

@export var oleada_1_enemigos: Array[PackedScene] = []
@export var oleada_2_enemigos: Array[PackedScene] = []
@export var oleada_3_enemigos: Array[PackedScene] = []
@export var oleada_4_enemigos: Array[PackedScene] = []
@export var oleada_5_enemigos: Array[PackedScene] = []

@onready var timer = $TimerOleada


@onready var punto_spawn_1 = $"PuntosSpawn/Oleada 1 Salida"
@onready var punto_spawn_2 = $"PuntosSpawn/Oleada 2 Entrada Bosque"
@onready var punto_spawn_3 = $"PuntosSpawn/Oleada 3 Bosque Frondoso"
@onready var punto_spawn_4 = $"PuntosSpawn/Oleada 4 Salida Bosque"
@onready var punto_spawn_5 = $"PuntosSpawn/Oleada 5 Bosque Abierto"

var oleada_actual: int = 1
var enemigos_vivos: int = 0
var total_oleadas: int = 5

func _ready() -> void:
	timer.timeout.connect(iniciar_oleada)
	timer.start()
	print("Prepárate... la oleada ", oleada_actual, " está por comenzar.")

func obtener_lista_oleada_actual() -> Array[PackedScene]:
	match oleada_actual:
		1: return oleada_1_enemigos
		2: return oleada_2_enemigos
		3: return oleada_3_enemigos
		4: return oleada_4_enemigos
		5: return oleada_5_enemigos
		_: return []

func obtener_punto_spawn_actual() -> Marker2D:
	match oleada_actual:
		1: return punto_spawn_1
		2: return punto_spawn_2
		3: return punto_spawn_3
		4: return punto_spawn_4
		5: return punto_spawn_5
		_: return punto_spawn_1

func iniciar_oleada() -> void:
	timer.stop()
	print("¡Inicia la oleada ", oleada_actual, "!")
	
	var lista_enemigos = obtener_lista_oleada_actual()
	var punto_spawn = obtener_punto_spawn_actual()
	
	if lista_enemigos.is_empty():
		print("Error: No hay enemigos configurados para la oleada ", oleada_actual)
		_avanzar_oleada()
		return

	for escena_enemigo in lista_enemigos:
		if escena_enemigo != null:
			spawnear_enemigo(escena_enemigo, punto_spawn)
			await get_tree().create_timer(0.4).timeout

func spawnear_enemigo(escena: PackedScene, punto: Marker2D) -> void:
	var enemigo_instancia = escena.instantiate()
	
	enemigo_instancia.global_position = punto.global_position
	add_child(enemigo_instancia)
	
	enemigo_instancia.ha_muerto.connect(_on_enemigo_muerto)
	enemigos_vivos += 1

func _on_enemigo_muerto() -> void:
	enemigos_vivos -= 1
	
	if enemigos_vivos <= 0:
		_avanzar_oleada()

func _avanzar_oleada() -> void:
	oleada_actual += 1
	
	if oleada_actual > total_oleadas:
		print("¡Has sobrevivido a todas las oleadas! ¡Nivel completado!")
	else:
		print("Oleada despejada. Siguiente oleada en 5 segundos...")
		timer.start()
