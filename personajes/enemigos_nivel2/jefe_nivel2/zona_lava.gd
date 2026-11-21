extends Area2D
@export var dano_lava: int  = 1
@export var intervalo_dano: float  = 1.0
@export var duracion: float  = 20.0

var tiempo_dano: float = 0.0
var tiempo_vida: float = 0.0

func _ready() -> void:
	pass 

func _physics_process(delta: float) -> void:
	tiempo_vida += delta
	tiempo_dano += delta
	
	if tiempo_vida >= duracion:
		queue_free()
		return
	
	if tiempo_dano >= intervalo_dano:
		tiempo_dano = 0.0
		
		for cuerpo in get_overlapping_bodies():
			if cuerpo.is_in_group("Jugador"):
				if(cuerpo.has_method("recibir_dano")):
					cuerpo.recibir_dano(dano_lava)

func _process(delta: float) -> void:
	pass
