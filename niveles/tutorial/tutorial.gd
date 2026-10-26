extends Node2D

@export_file("*.tscn") var siguiente_nivel: String = "" 

@onready var camara: Camera2D = $"Camara Tutorial"
@onready var boton: Button = $"Interfaz Tutorial/Boton Avanzar"
@onready var mensaje: Label = $"Interfaz Tutorial/Estado Tutorial"
@onready var temporizador: Timer = $"Tiempo Practica"

@onready var spawner_jugadores = $PuntosSpawn

func _ready() -> void:
	spawner_jugadores.generar_jugadores()
	if boton:
		boton.disabled = true
		boton.hide()
		
	if temporizador and not temporizador.timeout.is_connected(_habilitar_salida):
		temporizador.timeout.connect(_habilitar_salida)

	if temporizador and temporizador.is_stopped():
		temporizador.start()

func _process(_delta: float) -> void:
	if temporizador and not temporizador.is_stopped():
		var segundos := ceili(temporizador.time_left)
		mensaje.text = "PRACTICA TUS HABILIDADES · %02d:%02d" % [floori(segundos / 60.0), segundos % 60]

func _actualizar_objetivo() -> void:
	for j in get_tree().get_nodes_in_group("Jugador"):
		if is_ancestor_of(j) and not j.is_queued_for_deletion():
			camara.global_position = j.global_position
			return

func _habilitar_salida() -> void:
	if temporizador:
		temporizador.stop()
	if boton:
		boton.disabled = false
		boton.show()
	if mensaje:
		mensaje.text = "PUEDES SEGUIR PRACTICANDO O AVANZAR AL NIVEL 1."


func _avanzar() -> void:
	if boton.disabled:
		return
	boton.disabled = true
	call_deferred("_cambiar_nivel")

func _cambiar_nivel() -> void:
	var mundo := get_parent()
	if not mundo.has_method("ir_al_siguiente_nivel"):
		push_error("El tutorial no está dentro de Mundo (padre: %s). Ejecuta mundo.tscn." % mundo.name)
		boton.disabled = false
		return
	var resultado: Error = mundo.ir_al_siguiente_nivel()
	if resultado != OK:
		boton.disabled = false
		mensaje.text = "NO SE PUDO ABRIR EL NIVEL 1. INTENTA DE NUEVO."
		push_error("No se pudo abrir el siguiente nivel: %s" % error_string(resultado))
