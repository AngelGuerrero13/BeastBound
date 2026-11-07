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

@export_group("Separación de Spawn")
@export var separacion_spawn: float = 80.0
@export var columnas_spawn: int = 3
@export var variacion_spawn: float = 15.0
@export var tiempo_entre_spawns: float = 0.4

@export_group("Final de Zona")
@export_file("*.tscn") var escena_jefe: String = ""
@export var duracion_vamos: float = 5.0

@onready var timer = $TimerOleada

@onready var punto_spawn_1 = $"PuntosSpawn/Oleada 1 Salida"
@onready var punto_spawn_2 = $"PuntosSpawn/Oleada 2 Entrada Bosque"
@onready var punto_spawn_3 = $"PuntosSpawn/Oleada 3 Bosque Frondoso"
@onready var punto_spawn_4 = $"PuntosSpawn/Oleada 4 Salida Bosque"
@onready var punto_spawn_5 = $"PuntosSpawn/Oleada 5 Bosque Abierto"

# Nodos opcionales
@onready var emboscadas: Node = get_node_or_null("Emboscadas")
@onready var zona_salida: Area2D = get_node_or_null("ZonaSalida")
@onready var label_vamos: Label = get_node_or_null("CanvasLayer/LabelVamos")
@onready var fundido: ColorRect = get_node_or_null("CanvasLayer/Fundido")

var oleada_actual: int = 1
var enemigos_vivos: int = 0
var total_oleadas: int = 5
var cambiando_escena: bool = false

func _ready() -> void:
	timer.timeout.connect(iniciar_oleada)
	timer.start()
	print("Prepárate... la oleada ", oleada_actual, " está por comenzar.")
	
	# Emboscadas: cada hijo de "Emboscadas" avisa cuando un jugador lo cruza
	if emboscadas:
		for e in emboscadas.get_children():
			if e.has_signal("activada"):
				e.activada.connect(_on_emboscada_activada)
	
	# La salida empieza apagada y oculta el mensaje
	if zona_salida:
		zona_salida.set_deferred("monitoring", false)
		zona_salida.body_entered.connect(_on_salida_body_entered)
	if label_vamos:
		label_vamos.visible = false
	if fundido:
		fundido.modulate.a = 0.0

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

func calcular_posicion_spawn(centro: Vector2, indice: int, total: int) -> Vector2:
	var columnas = max(1, min(columnas_spawn, total))
	var filas = int(ceil(float(total) / columnas))
	
	var col = indice % columnas
	var fila = indice / columnas
	
	var offset = Vector2(
		(col - (columnas - 1) / 2.0) * separacion_spawn,
		(fila - (filas - 1) / 2.0) * separacion_spawn
	)
	offset += Vector2(
		randf_range(-variacion_spawn, variacion_spawn),
		randf_range(-variacion_spawn, variacion_spawn)
	)
	return centro + offset

# Spawnea un grupo de escenas en cuadrícula. "al_morir" se llama por cada enemigo muerto.
func spawnear_grupo(escenas: Array, centro: Vector2, al_morir: Callable) -> void:
	var total = escenas.size()
	for i in range(total):
		var posicion = calcular_posicion_spawn(centro, i, total)
		spawnear_enemigo(escenas[i], posicion, al_morir)
		await get_tree().create_timer(tiempo_entre_spawns).timeout

func spawnear_enemigo(escena: PackedScene, posicion: Vector2, al_morir: Callable) -> void:
	var enemigo_instancia = escena.instantiate()
	add_child(enemigo_instancia)
	enemigo_instancia.global_position = posicion
	enemigo_instancia.ha_muerto.connect(al_morir)

# ---------------- OLEADAS ----------------

func iniciar_oleada() -> void:
	timer.stop()
	print("¡Inicia la oleada ", oleada_actual, "!")
	
	var escenas_validas: Array[PackedScene] = []
	for escena in obtener_lista_oleada_actual():
		if escena != null:
			escenas_validas.append(escena)
	
	if escenas_validas.is_empty():
		print("Error: No hay enemigos configurados para la oleada ", oleada_actual)
		_avanzar_oleada()
		return
	
	enemigos_vivos = escenas_validas.size()
	spawnear_grupo(escenas_validas, obtener_punto_spawn_actual().global_position, _on_enemigo_muerto)

func _on_enemigo_muerto() -> void:
	enemigos_vivos -= 1
	if enemigos_vivos <= 0:
		_avanzar_oleada()

func _avanzar_oleada() -> void:
	oleada_actual += 1
	
	if oleada_actual > total_oleadas:
		print("¡Has sobrevivido a todas las oleadas! ¡Nivel completado!")
		zona_despejada()
	else:
		print("Oleada despejada. Siguiente oleada en 5 segundos...")
		timer.start()

# ---------------- EMBOSCADAS ----------------

func _on_emboscada_activada(escenas: Array, posicion: Vector2) -> void:
	var validas: Array = escenas.filter(func(e): return e != null)
	if validas.is_empty():
		return
	print("¡Emboscada!")
	# Estos enemigos no cuentan para avanzar de oleada
	spawnear_grupo(validas, posicion, func(): pass)

# ---------------- FINAL DE ZONA ----------------

func zona_despejada() -> void:
	if zona_salida:
		zona_salida.set_deferred("monitoring", true)
	mostrar_vamos()

func mostrar_vamos() -> void:
	if label_vamos == null:
		return
	label_vamos.text = "¡VAMOS!"
	label_vamos.visible = true
	label_vamos.modulate.a = 1.0
	
	# Parpadea durante unos segundos y luego se oculta
	var tween = create_tween()
	var parpadeos = int(duracion_vamos / 0.8)
	for i in range(parpadeos):
		tween.tween_property(label_vamos, "modulate:a", 0.2, 0.4)
		tween.tween_property(label_vamos, "modulate:a", 1.0, 0.4)
	tween.tween_callback(func(): label_vamos.visible = false)

func _on_salida_body_entered(body: Node2D) -> void:
	if cambiando_escena or not body.is_in_group("Jugador"):
		return
	
	# Todos los jugadores vivos deben estar dentro de la zona
	for j in get_tree().get_nodes_in_group("Jugador"):
		if not zona_salida.overlaps_body(j):
			return
	
	ir_al_jefe()

func ir_al_jefe() -> void:
	if escena_jefe == "":
		print("Falta asignar la escena del jefe en el inspector.")
		return
	cambiando_escena = true
	
	if fundido:
		var tween = create_tween()
		tween.tween_property(fundido, "modulate:a", 1.0, 0.8)
		await tween.finished
	
	get_tree().change_scene_to_file(escena_jefe)
