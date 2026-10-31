extends CanvasLayer

@onready var barra = $BossHealthBar

func configurar(vida_maxima:int, vida_actual:int):
	barra.max_value = vida_maxima
	barra.value = vida_actual
	
func actualizar_vida(nueva_vida: int): 
	barra.value = nueva_vida
