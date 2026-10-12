extends Node

enum Fase { NORMAL, CERRANDO, PRESIONADA, ABRIENDO }

const FRAMES: Array[Texture2D] = [
	preload("res://assets/art/ui/cursor_patita/normal.png"),
	preload("res://assets/art/ui/cursor_patita/cierre.png"),
	preload("res://assets/art/ui/cursor_patita/presionada.png"),
]
const HOTSPOT := Vector2(18, 3)
const TIEMPO_TRANSICION := 0.065
const TIEMPO_PRESION_MINIMA := 0.055

var fase := Fase.NORMAL
var tiempo_fase := 0.0
var presionado := false
var frame_actual := -1
var ventana_activa := true


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_mostrar_frame(0)
	get_window().focus_exited.connect(_perder_foco)
	get_window().focus_entered.connect(_recuperar_foco)


func _input(event: InputEvent) -> void:
	if not ventana_activa:
		return
	if event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]:
		_actualizar_presionado(_boton_pulsado())
	# El evento continúa hacia los botones del menú y el combate.


func _process(delta: float) -> void:
	if not ventana_activa:
		return
	# También detectar los clics que la interfaz haya marcado como manejados.
	_actualizar_presionado(_boton_pulsado())
	tiempo_fase += delta
	match fase:
		Fase.CERRANDO:
			if tiempo_fase >= TIEMPO_TRANSICION:
				fase = Fase.PRESIONADA
				tiempo_fase = 0.0
				_mostrar_frame(2)
		Fase.PRESIONADA:
			if not presionado and tiempo_fase >= TIEMPO_PRESION_MINIMA:
				fase = Fase.ABRIENDO
				tiempo_fase = 0.0
				_mostrar_frame(1)
		Fase.ABRIENDO:
			if tiempo_fase >= TIEMPO_TRANSICION:
				fase = Fase.NORMAL
				tiempo_fase = 0.0
				_mostrar_frame(0)


func _boton_pulsado() -> bool:
	return Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)


func _actualizar_presionado(valor: bool) -> void:
	if valor and not presionado:
		fase = Fase.CERRANDO
		tiempo_fase = 0.0
		_mostrar_frame(1)
	presionado = valor


func _mostrar_frame(indice: int) -> void:
	if frame_actual == indice:
		return
	frame_actual = indice
	if DisplayServer.get_name() == "headless":
		return
	# Registrar la patita para flecha, mano de botones, deslizadores y demás formas.
	for forma in range(Input.CURSOR_HELP + 1):
		Input.set_custom_mouse_cursor(FRAMES[indice], forma, HOTSPOT)


func _reiniciar() -> void:
	presionado = false
	fase = Fase.NORMAL
	tiempo_fase = 0.0
	_mostrar_frame(0)


func _perder_foco() -> void:
	ventana_activa = false
	_reiniciar()


func _recuperar_foco() -> void:
	ventana_activa = true
	_reiniciar()
