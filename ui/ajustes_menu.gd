extends Control

signal cerrar_solicitado

const ACCIONES := {
	"Arriba": "p1_arriba",
	"Abajo": "p1_abajo",
	"Izquierda": "p1_izquierda",
	"Derecha": "p1_derecha",
	"Salto": "p1_salto",
	"Ataque": "p1_ataque_normal",
	"Cargado": "p1_ataque_cargado",
}
const MODOS := {"Completa": "completa", "Ventana": "ventana", "Sin Bordes": "sin_bordes"}
const VOLUMENES := {"General": "general", "Musica": "musica", "Efectos": "efectos"}

@onready var dibujos := [$"Dibujo Audio", $"Dibujo Pantalla", $"Dibujo Controles"]
@onready var paginas := [$"Pagina Audio", $"Pagina Pantalla", $"Pagina Controles"]
@onready var marcadores := [$"Marcadores/Audio", $"Marcadores/Pantalla", $"Marcadores/Controles"]
@onready var tintes_marcadores := marcadores.map(func(marcador: TextureButton) -> Color: return marcador.self_modulate)
@onready var estado: Label = $Estado
var pagina := 0
var accion_pendiente := ""
var animacion: Tween


func _ready() -> void:
	for nombre in VOLUMENES:
		var deslizador: HSlider = paginas[0].get_node("Volumen " + nombre)
		deslizador.value_changed.connect(_cambiar_volumen.bind(nombre))
	for nombre in MODOS:
		var casilla: CheckBox = paginas[1].get_node(nombre)
		casilla.toggled.connect(_cambiar_pantalla.bind(nombre))
	for nombre in ACCIONES:
		paginas[2].get_node("Tecla " + nombre).pressed.connect(_esperar_control.bind(nombre))
	for i in range(marcadores.size()):
		marcadores[i].pressed.connect(_cambiar_pagina.bind(i))
	$"Boton Volver".pressed.connect(guardar_y_cerrar)


func abrir() -> void:
	accion_pendiente = ""
	estado.text = ""
	for nombre in VOLUMENES:
		var valor: float = Ajustes.volumenes[VOLUMENES[nombre]]
		paginas[0].get_node("Volumen " + nombre).set_value_no_signal(valor)
		paginas[0].get_node("Porcentaje " + nombre).text = "%d%%" % valor
	for nombre in MODOS:
		paginas[1].get_node(nombre).set_pressed_no_signal(Ajustes.modo_pantalla == MODOS[nombre])
	_actualizar_controles()
	_mostrar_pagina(0)
	pivot_offset = size / 2.0
	scale = Vector2(0.16, 0.98)
	modulate.a = 0.0
	if animacion and animacion.is_valid():
		animacion.kill()
	animacion = create_tween().set_parallel(true)
	animacion.tween_property(self, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_SINE)
	animacion.tween_property(self, "modulate:a", 1.0, 0.2)
	paginas[0].get_node("Volumen General").grab_focus()


func _cambiar_volumen(valor: float, nombre: String) -> void:
	Ajustes.establecer_volumen(VOLUMENES[nombre], valor)
	paginas[0].get_node("Porcentaje " + nombre).text = "%d%%" % valor


func _cambiar_pantalla(activo: bool, nombre: String) -> void:
	if activo:
		Ajustes.establecer_modo_pantalla(MODOS[nombre])


func _cambiar_pagina(indice: int) -> void:
	accion_pendiente = ""
	estado.text = ""
	_mostrar_pagina(indice)
	dibujos[pagina].modulate.a = 0.65
	paginas[pagina].modulate.a = 0.65
	var transicion := create_tween().set_parallel(true)
	transicion.tween_property(dibujos[pagina], "modulate:a", 1.0, 0.16)
	transicion.tween_property(paginas[pagina], "modulate:a", 1.0, 0.16)


func _mostrar_pagina(indice: int) -> void:
	pagina = indice
	for i in range(3):
		dibujos[i].visible = i == pagina
		paginas[i].visible = i == pagina
		marcadores[i].set_pressed_no_signal(i == pagina)
		marcadores[i].self_modulate = tintes_marcadores[i] * (Color.WHITE if i == pagina else Color(0.75, 0.75, 0.75, 1.0))


func _esperar_control(nombre: String) -> void:
	accion_pendiente = ACCIONES[nombre]
	estado.text = "Presiona una tecla o botón del ratón · Esc cancela"


func _input(evento: InputEvent) -> void:
	if not visible or accion_pendiente.is_empty():
		return
	if evento is InputEventKey and evento.pressed and not evento.echo:
		get_viewport().set_input_as_handled()
		if evento.keycode == KEY_ESCAPE:
			accion_pendiente = ""
			estado.text = "Cambio cancelado."
			return
		_asignar(evento)
	elif evento is InputEventMouseButton and evento.pressed:
		for marcador in marcadores:
			if marcador.get_global_rect().has_point(evento.position):
				accion_pendiente = ""
				estado.text = ""
				return
		get_viewport().set_input_as_handled()
		_asignar(evento)


func _asignar(evento: InputEvent) -> void:
	for otra in ACCIONES.values():
		if otra == accion_pendiente:
			continue
		for anterior in InputMap.action_get_events(otra):
			if (anterior is InputEventKey or anterior is InputEventMouseButton) and anterior.is_match(evento):
				estado.text = "Esa tecla ya está asignada. Elige otra."
				return
	var entrada: InputEvent = evento.duplicate()
	entrada.pressed = false
	Ajustes.asignar_control(accion_pendiente, entrada)
	accion_pendiente = ""
	estado.text = "Control actualizado."
	_actualizar_controles()


func _actualizar_controles() -> void:
	for nombre in ACCIONES:
		var texto := "Sin asignar"
		for evento in InputMap.action_get_events(ACCIONES[nombre]):
			if evento is InputEventKey or evento is InputEventMouseButton:
				texto = evento.as_text().replace(" (Physical)", "").replace(" - Physical", "")
				if evento is InputEventKey:
					var traducciones := {"Space": "Espacio", "Escape": "Escape", "Enter": "Intro", "Backspace": "Retroceso", "Delete": "Suprimir", "Insert": "Insertar", "Home": "Inicio", "End": "Fin", "Page Up": "Re Pág", "Page Down": "Av Pág", "Up": "Arriba", "Down": "Abajo", "Left": "Izquierda", "Right": "Derecha", "Shift": "Mayús"}
					for ingles in traducciones:
						texto = texto.replace(ingles, traducciones[ingles])
				if evento is InputEventMouseButton:
					if evento.button_index == MOUSE_BUTTON_LEFT:
						texto = "Click izq"
					elif evento.button_index == MOUSE_BUTTON_RIGHT:
						texto = "Click der"
					elif evento.button_index == MOUSE_BUTTON_MIDDLE:
						texto = "Ratón central"
					else:
						texto = "Ratón %d" % evento.button_index
				break
		paginas[2].get_node("Tecla " + nombre).text = texto


func guardar_y_cerrar() -> bool:
	accion_pendiente = ""
	if Ajustes.guardar() != OK:
		estado.text = "No se pudieron guardar los ajustes."
		return false
	cerrar_solicitado.emit()
	return true
