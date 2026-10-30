extends Control

@onready var espacios: Control = $Carteles
@onready var mensaje: Label = $"Estado Partida"
@onready var confirmacion: Control = $"Confirmar Borrado"
@onready var mensaje_carga: Label = $"Mensaje Carga"
var espacio_por_borrar := 0
var cargando_partida := false


func _ready() -> void:
	Partidas.espacio_activo = 0
	$"Boton Volver".pressed.connect(_volver)
	$"Confirmar Borrado/Panel Borrado/Boton Cancelar".pressed.connect(_cancelar_borrado)
	$"Confirmar Borrado/Panel Borrado/Boton Eliminar".pressed.connect(_confirmar_borrado)
	for indice in espacios.get_child_count():
		var espacio := indice + 1
		var cartel: Control = espacios.get_child(indice)
		_actualizar_cartel(espacio)
		cartel.get_node("Boton Partida").pressed.connect(_seleccionar.bind(espacio))
		cartel.get_node("Nombre Nuevo").text_submitted.connect(_nombre_enviado.bind(espacio))
		cartel.get_node("Boton Eliminar").pressed.connect(_pedir_borrado.bind(espacio))
	$"Boton Volver".grab_focus()
	for cartel in espacios.get_children():
		if not cartel.get_node("Boton Partida").disabled:
			if cartel.get_node("Nombre Nuevo").visible:
				cartel.get_node("Nombre Nuevo").grab_focus()
			else:
				cartel.get_node("Boton Partida").grab_focus()
			break


func _actualizar_cartel(espacio: int) -> void:
	var cartel: Control = espacios.get_child(espacio - 1)
	var boton: Button = cartel.get_node("Boton Partida")
	var nombre: Label = cartel.get_node("Nombre Equipo")
	var detalle: Label = cartel.get_node("Detalle Partida")
	var barra: ProgressBar = cartel.get_node("Barra Avance")
	var campo: LineEdit = cartel.get_node("Nombre Nuevo")
	var ocupado := Partidas.existe(espacio)
	var datos := Partidas.leer(espacio)
	campo.visible = not ocupado
	detalle.visible = ocupado
	barra.visible = ocupado and not datos.is_empty()
	cartel.get_node("Boton Eliminar").visible = ocupado
	boton.disabled = ocupado and datos.is_empty()
	boton.text = "JUGAR" if ocupado else "CREAR"
	boton.tooltip_text = ""
	if not ocupado:
		nombre.text = "NUEVA PARTIDA"
		detalle.text = ""
		campo.clear()
	elif datos.is_empty():
		nombre.text = "PARTIDA %d" % espacio
		detalle.text = "ARCHIVO DAÑADO"
	else:
		nombre.text = datos.nombre.to_upper()
		detalle.text = "NIVEL %d · AVANCE: %d%%" % [datos.nivel, datos.avance]
		barra.value = datos.avance
		boton.tooltip_text = "Último guardado: " + datos.fecha


func _nombre_enviado(_texto: String, espacio: int) -> void:
	_seleccionar(espacio)


func _seleccionar(espacio: int) -> void:
	if confirmacion.visible or cargando_partida:
		return
	var resultado: Error = OK
	if not Partidas.existe(espacio):
		var campo: LineEdit = espacios.get_child(espacio - 1).get_node("Nombre Nuevo")
		if campo.text.strip_edges().is_empty():
			mensaje.text = "ESCRIBE EL NOMBRE DE TU EQUIPO PARA CREAR LA PARTIDA."
			campo.grab_focus()
			return
		resultado = Partidas.crear(espacio, campo.text)
	if resultado == OK:
		cargando_partida = true
		mensaje_carga.show()
		# Dibujar el aviso antes de abrir los recursos de la partida.
		if DisplayServer.get_name() == "headless":
			await get_tree().process_frame
		else:
			await RenderingServer.frame_post_draw
		resultado = Partidas.abrir(espacio)
		if resultado == OK:
			resultado = Ajustes.cambiar_escena("res://ui/seleccion_personaje/seleccion_personaje.tscn")
	if resultado != OK:
		cargando_partida = false
		mensaje_carga.hide()
		mensaje.text = "NO SE PUDO ABRIR LA PARTIDA. INTENTA DE NUEVO."


func _pedir_borrado(espacio: int) -> void:
	if cargando_partida or not Partidas.existe(espacio):
		return
	espacio_por_borrar = espacio
	var nombre: String = espacios.get_child(espacio - 1).get_node("Nombre Equipo").text
	$"Confirmar Borrado/Panel Borrado/Detalle Borrado".text = "«%s»\nPERDERÁS SU AVANCE GUARDADO." % nombre
	confirmacion.show()
	$"Confirmar Borrado/Panel Borrado/Boton Cancelar".grab_focus()


func _cancelar_borrado() -> void:
	confirmacion.hide()
	if espacio_por_borrar != 0:
		espacios.get_child(espacio_por_borrar - 1).get_node("Boton Eliminar").grab_focus()
	espacio_por_borrar = 0


func _confirmar_borrado() -> void:
	if espacio_por_borrar == 0:
		return
	var espacio := espacio_por_borrar
	var resultado := Partidas.eliminar(espacio)
	_cancelar_borrado()
	if resultado != OK:
		mensaje.text = "NO SE PUDO ELIMINAR LA PARTIDA. INTENTA DE NUEVO."
		return
	_actualizar_cartel(espacio)
	mensaje.text = "PARTIDA ELIMINADA."
	espacios.get_child(espacio - 1).get_node("Nombre Nuevo").grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if cargando_partida:
		return
	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		get_viewport().set_input_as_handled()
		if confirmacion.visible:
			_cancelar_borrado()
		else:
			_volver()


func _volver() -> void:
	if cargando_partida:
		return
	var resultado := Ajustes.cambiar_escena(Ajustes.MENU)
	if resultado != OK:
		mensaje.text = "NO SE PUDO VOLVER AL MENÚ. INTENTA DE NUEVO."
