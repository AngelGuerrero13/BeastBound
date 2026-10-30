extends "res://personajes/enemigoBasico/enemigo_basico.gd"
var detonando: bool = false
@export var tiempo_detonacion: float = 1.5
@export var dano_explosion: int = 5 

@onready var area_explosion: Area2D = $AreaExplosion

# El padre dispara esto automáticamente al entrar en el rango de ataque
func ejecutar_ataque_normal(_objetivo) -> void:
	if not detonando:
		iniciar_detonacion()

func iniciar_detonacion() -> void:
	detonando = true
	
	# TRUCO DE HERENCIA: Al vaciar esta variable, el _physics_process del padre 
	# frena al enemigo en seco y le sigue aplicando gravedad por nosotros.
	jugador_objetivo = null 
	
	var parpadeos = 5
	var tiempo_por_parpadeo = tiempo_detonacion / (parpadeos * 2.0)
	
	for i in range(parpadeos):
		if not is_instance_valid(sprite): return 
		
		sprite.modulate = Color.RED
		await get_tree().create_timer(tiempo_por_parpadeo).timeout
		
		if not is_instance_valid(sprite): return
		
		sprite.modulate = Color.WHITE
		await get_tree().create_timer(tiempo_por_parpadeo).timeout
		
	explotar()

func explotar() -> void:
	if area_explosion:
		var cuerpos = area_explosion.get_overlapping_bodies()
		for cuerpo in cuerpos:
			if cuerpo.is_in_group("Jugador") and cuerpo.has_method("recibir_dano"):
				cuerpo.recibir_dano(dano_explosion)
				
	morir() # Función de personaje_base.gd
