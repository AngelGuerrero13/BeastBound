extends "res://personajes/personajeBase/personaje_base.gd"

@export var escena_bola_magica: PackedScene

# Esta línea busca automáticamente el nodo que acabas de crear cuando el juego arranca
@onready var punto_disparo: Marker2D = $PuntoDisparo

var esta_cargando: bool = false

func _process(delta):
	if Input.is_action_just_pressed("ataque_normal"):
		ataque(obtener_enemigo_objetivo())
			
	elif Input.is_action_just_pressed("ataque_cargado"):
		ataque_cargado(obtener_enemigo_objetivo())

func ataque(objetivo: Node2D):
	disparar_bola(objetivo, false)

func ataque_cargado(objetivo: Node2D):
	if not esta_cargando:
		esta_cargando = true
		
		await get_tree().create_timer(3.0).timeout
		
		disparar_bola(objetivo, true)
			
		esta_cargando = false

func disparar_bola(objetivo: Node2D, es_cargada: bool):
	if escena_bola_magica:
		var nueva_bola = escena_bola_magica.instantiate()
		
		get_tree().current_scene.add_child(nueva_bola)
		
		# ¡EL CAMBIO CLAVE!: Posicionamos la bola exactamente en el Marker2D
		nueva_bola.global_position = punto_disparo.global_position
		
		# Calculamos la dirección usando también el punto de disparo
		var direccion_hacia_raton = get_global_mouse_position() - punto_disparo.global_position
		
		nueva_bola.configurar(objetivo, es_cargada, direccion_hacia_raton)
	else:
		print("Error: La escena de la bola mágica no ha sido asignada en el Inspector.")

func obtener_enemigo_objetivo() -> Node2D:
	return null
