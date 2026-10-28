extends VBoxContainer

signal cerrar_solicitado

@onready var secciones: TabContainer = $Secciones
@onready var audio: VBoxContainer = $"Secciones/Audio y Pantalla"
@onready var estado: Label = $"Secciones/Audio y Pantalla/Estado Ajustes"


func _ready() -> void:
	var filas := {"general": "Volumen General", "musica": "Volumen Musica", "efectos": "Volumen Efectos"}
	for clave in filas:
		var fila: HBoxContainer = audio.get_node(filas[clave])
		var deslizador: HSlider = fila.get_node("Deslizador Volumen")
		var porcentaje: Label = fila.get_node("Porcentaje Volumen")
		deslizador.value_changed.connect(func(valor: float) -> void:
			Ajustes.establecer_volumen(clave, valor)
			porcentaje.text = "%d%%" % valor
		)
	audio.get_node("Opciones Generales/Silenciar Audio").toggled.connect(Ajustes.establecer_silencio)
	audio.get_node("Opciones Generales/Pantalla Completa").toggled.connect(Ajustes.establecer_pantalla_completa)
	$"Boton Volver".pressed.connect(guardar_y_cerrar)


func abrir() -> void:
	secciones.current_tab = 0
	var filas := {"general": "Volumen General", "musica": "Volumen Musica", "efectos": "Volumen Efectos"}
	for clave in filas:
		var fila: HBoxContainer = audio.get_node(filas[clave])
		fila.get_node("Deslizador Volumen").set_value_no_signal(Ajustes.volumenes[clave])
		fila.get_node("Porcentaje Volumen").text = "%d%%" % Ajustes.volumenes[clave]
	audio.get_node("Opciones Generales/Silenciar Audio").set_pressed_no_signal(Ajustes.silenciado)
	audio.get_node("Opciones Generales/Pantalla Completa").set_pressed_no_signal(Ajustes.pantalla_completa)
	estado.text = "Los cambios se aplican al instante."
	call_deferred("_enfocar")


func _enfocar() -> void:
	if is_visible_in_tree():
		audio.get_node("Volumen General/Deslizador Volumen").grab_focus()


func guardar_y_cerrar() -> bool:
	if Ajustes.guardar() != OK:
		secciones.current_tab = 0
		estado.text = "No se pudieron guardar los ajustes. Intenta de nuevo."
		return false
	cerrar_solicitado.emit()
	return true
