extends Node2D

@onready var camara: Camera2D = $"Camara Tutorial"
@onready var boton: Button = $"Interfaz Tutorial/Boton Avanzar"
@onready var mensaje: Label = $"Interfaz Tutorial/Estado Tutorial"


func _ready() -> void:
	boton.hide()
	boton.disabled = true
	Partidas.estado_pendiente = {}
	for heredada in find_children("*", "Camera2D", true, false):
		if heredada != camara:
			heredada.enabled = false
	process_priority = 10
	camara.process_priority = 20
	_actualizar_camara()
	camara.make_current()
	camara.reset_smoothing()


func _process(_delta: float) -> void:
	_actualizar_camara()
	if not boton.disabled:
		return
	var segundos := ceili($"Tiempo Practica".time_left)
	mensaje.text = "PRACTICA TUS HABILIDADES · %02d:%02d" % [floori(segundos / 60.0), segundos % 60]


func _actualizar_camara() -> void:
	camara.position.x = $Mago.position.x + 24.0


func _habilitar_salida() -> void:
	$"Tiempo Practica".stop()
	boton.disabled = false
	boton.show()
	mensaje.text = "PUEDES SEGUIR PRACTICANDO O AVANZAR AL NIVEL 1."


func _avanzar() -> void:
	if boton.disabled:
		return
	var resultado := Ajustes.cambiar_escena(Partidas.MUNDO)
	if resultado != OK:
		mensaje.text = "NO SE PUDO ABRIR EL NIVEL 1. INTENTA DE NUEVO."
