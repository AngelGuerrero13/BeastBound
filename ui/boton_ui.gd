extends TextureButton

const RECURSOS_UI := preload("res://ui/recursos_ui.gd")

var cursor_encima := false
var clic_activo := false
var animacion_estado: Tween
var margenes_texto := Vector2.ZERO


func _ready() -> void:
	var texto := get_node_or_null("Texto Boton") as Label
	if texto != null:
		margenes_texto = Vector2(texto.offset_top, texto.offset_bottom)
	if texture_normal == null:
		usar_frames(String(name).trim_prefix("Boton "))
	_actualizar_icono(false)
	resized.connect(_centrar_pivote)
	mouse_entered.connect(_entrar_cursor)
	mouse_exited.connect(_salir_cursor)
	focus_entered.connect(_actualizar_estado)
	focus_exited.connect(_actualizar_estado)
	button_down.connect(_presionar)
	button_up.connect(_soltar)
	_centrar_pivote()


func usar_frames(opcion: String) -> void:
	texture_normal = RECURSOS_UI.frame(opcion)
	texture_hover = texture_normal
	texture_pressed = RECURSOS_UI.frame(opcion, true)
	texture_disabled = texture_normal


func _centrar_pivote() -> void:
	pivot_offset = size * 0.5


func _entrar_cursor() -> void:
	cursor_encima = true
	_actualizar_estado()


func _salir_cursor() -> void:
	cursor_encima = false
	_actualizar_estado()


func _presionar() -> void:
	clic_activo = true
	_desplazar_texto(2.0)
	_actualizar_icono(true)
	_actualizar_estado()


func _soltar() -> void:
	clic_activo = false
	_desplazar_texto(0.0)
	_actualizar_icono(false)
	_actualizar_estado()


func _desplazar_texto(desplazamiento: float) -> void:
	var texto := get_node_or_null("Texto Boton") as Label
	if texto != null:
		texto.offset_top = margenes_texto.x + desplazamiento
		texto.offset_bottom = margenes_texto.y + desplazamiento


func _actualizar_icono(presionado: bool) -> void:
	var icono := get_node_or_null("Icono Jugar") as TextureRect
	if icono != null:
		icono.texture = RECURSOS_UI.icono_jugar(presionado)
		icono.offset_top = 14.0 + (2.0 if presionado else 0.0)
		icono.offset_bottom = 44.0 + (2.0 if presionado else 0.0)


func _actualizar_estado() -> void:
	if not is_inside_tree():
		return
	var escala := Vector2.ONE
	var color := Color.WHITE
	var duracion := 0.12
	if not disabled:
		if clic_activo:
			escala = Vector2(0.97, 0.97)
			duracion = 0.06
		elif cursor_encima:
			escala = Vector2(1.04, 1.04)
			color = Color(1.13, 1.13, 1.13, 1.0)
		elif has_focus():
			color = Color(1.04, 1.04, 1.04, 1.0)
	if animacion_estado != null and animacion_estado.is_valid():
		animacion_estado.kill()
	animacion_estado = create_tween().set_parallel(true)
	animacion_estado.tween_property(self, "scale", escala, duracion).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	animacion_estado.tween_property(self, "modulate", color, duracion)
