extends Control

@export var textura_corazon_lleno: Texture2D
@export var textura_corazon_mitad: Texture2D
@export var textura_corazon_vacio: Texture2D

@onready var retrato: TextureRect = $"Interfaz/Retrato Personaje"
@onready var corazones_ui: HBoxContainer = $"Interfaz/Marco Vida/Corazones Vida"

var jugador_vinculado: Node = null

func vincular(jugador: Node) -> void:
	jugador_vinculado = jugador
	show()
	modulate = Color.WHITE
	
	if jugador.retrato:
		retrato.texture = jugador.retrato
		
	if not jugador.vida_cambiada.is_connected(actualizar_corazones):
		jugador.vida_cambiada.connect(actualizar_corazones)
	if not jugador.ha_muerto.is_connected(_al_morir):
		jugador.ha_muerto.connect(_al_morir)
		
	actualizar_corazones(jugador.vida)

func actualizar_corazones(vida: int) -> void:
	if not jugador_vinculado:
		return
		
	var vida_max_actual = jugador_vinculado.vida_maxima
	var total_corazones := ceili(vida_max_actual / 2.0)
	
	while corazones_ui.get_child_count() < total_corazones:
		var nuevo := corazones_ui.get_child(0).duplicate() as TextureRect
		nuevo.name = "Corazon %d" % (corazones_ui.get_child_count() + 1)
		corazones_ui.add_child(nuevo)
		
	for i in corazones_ui.get_child_count():
		var icono := corazones_ui.get_child(i) as TextureRect
		icono.visible = i < total_corazones
		
		if vida >= (i * 2) + 2:
			icono.texture = textura_corazon_lleno
		elif vida == (i * 2) + 1:
			icono.texture = textura_corazon_mitad
		else:
			icono.texture = textura_corazon_vacio

func _al_morir() -> void:
	modulate = Color(0.4, 0.4, 0.4, 0.7)
