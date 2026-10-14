extends Node2D


func _ready() -> void:
	$"Nivel 1".set_meta("inicio_avance", $"Nivel 1/Mago".global_position.x)
	Partidas.aplicar_estado(self)
