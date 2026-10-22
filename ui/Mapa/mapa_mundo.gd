extends Node2D

@onready var camino: Path2D = $Camino
@onready var recorrido: PathFollow2D = $Camino/Recorrido
@onready var cursor: AnimatedSprite2D = $Camino/Recorrido/Cursor
@onready var puntos_niveles: Array = $PuntosNiveles.get_children()
	
@export var escenas_niveles: Array[PackedScene]

# --- VARIABLES DE CONTROL ---
var indice_actual: int = 0
var en_movimiento: bool = false
var offsets_niveles: Array[float] = []

func _ready() -> void:
	
	for nivel in puntos_niveles:
		var posicion_local = camino.to_local(nivel.global_position)
		var offset = camino.curve.get_closest_offset(posicion_local)
		offsets_niveles.append(offset)
		
		var ani_level: AnimatedSprite2D = nivel.get_node("AniLevel")
		ani_level.play("normal")
	
	recorrido.progress = offsets_niveles[indice_actual]
	cursor.play("seleccion")

func _process(_delta: float) -> void:
	if en_movimiento:
		return

	if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_up"):
		if indice_actual < puntos_niveles.size() - 1:
			viajar_a_nivel(indice_actual + 1)
			
	if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_down"):
		if indice_actual > 0:
			viajar_a_nivel(indice_actual - 1)
			
	if Input.is_action_just_pressed("ui_accept"):
		entrar_al_nivel()

func entrar_al_nivel() -> void:
	if indice_actual < escenas_niveles.size() and escenas_niveles[indice_actual] != null:
		var escena_seleccionada = escenas_niveles[indice_actual]
		
		Partidas.estado_pendiente["nivel_ruta"] = escena_seleccionada.resource_path
		
		get_tree().change_scene_to_file("res://niveles/mundo.tscn")
	else:
		print("Error: No se asigno una escena para el nivel ", indice_actual, " en el Inspector.")

func viajar_a_nivel(nuevo_indice: int) -> void:
	en_movimiento = true
	cursor.play("normal")
	
	if nuevo_indice > indice_actual:
		cursor.flip_h = false 
	else:
		cursor.flip_h = true
		
	indice_actual = nuevo_indice
	
	var progreso_destino = offsets_niveles[indice_actual]
	
	var distancia = abs(progreso_destino - recorrido.progress)

	var velocidad = 200.0
	
	var tiempo_de_viaje = distancia / velocidad
	
	var tween = create_tween()
	tween.tween_property(recorrido, "progress", progreso_destino, tiempo_de_viaje)
	
	tween.finished.connect(al_llegar)

func al_llegar() -> void:
	en_movimiento = false
	cursor.play("seleccion")
