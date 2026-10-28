extends Control

const MAPA = "res://ui/Mapa/mapa_mundo.tscn"

@onready var paneles = $Paneles.get_children()

@onready var mensaje_inicio = $MensajeInicio

@onready var icono_aceptar_global = $BotonAceptar/AnimacionBotones1
@onready var icono_volver_global = $BotonVolver/AnimacionBotones2

var jugadores_activos = []
var jugadores_listos = {}

var inicio_pendiente = false
var carga_iniciada = false

func _ready():
	carga_iniciada = ResourceLoader.load_threaded_request(MAPA, "PackedScene") == OK
	mensaje_inicio.hide()
	
	for panel in paneles:
		panel.jugador_salio.connect(_on_jugador_salio)
		panel.jugador_listo.connect(_on_jugador_listo)
		
	var mandos_conectados = Input.get_connected_joypads()
	
	if mandos_conectados.size() > 0:
		actualizar_iconos_globales(mandos_conectados[0])
	else:
		actualizar_iconos_globales(-1)

func _process(_delta):
	if inicio_pendiente:
		var estado = ResourceLoader.load_threaded_get_status(MAPA) if carga_iniciada else ResourceLoader.THREAD_LOAD_INVALID_RESOURCE
		if estado == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			return
		var resultado: Error
		if estado == ResourceLoader.THREAD_LOAD_LOADED:
			resultado = get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(MAPA))
			if resultado == OK:
				Ajustes.reanudar()
		else:
			resultado = Ajustes.cambiar_escena(MAPA)
		if resultado != OK:
			inicio_pendiente = false
			mensaje_inicio.text = "No se pudo cargar el mapa"
			set_process_input(true)
			for panel in paneles:
				panel.set_process_input(true)

func comprobar_inicio_juego():
	if jugadores_activos.size() > 0 and jugadores_listos.size() == jugadores_activos.size():
		iniciar_juego()

func iniciar_juego():
	Ajustes.jugadores_seleccionados = jugadores_listos.duplicate()
	inicio_pendiente = true
	mensaje_inicio.text = "Cargando mapa..."
	mensaje_inicio.show()
	set_process_input(false)
	for panel in paneles:
		panel.set_process_input(false)

func _input(event):
	if event is InputEventKey:
		actualizar_iconos_globales(-1)
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		actualizar_iconos_globales(event.device)
	
	for i in range(1, 5):
		var prefijo = "p" + str(i)
		var accion_unirse = prefijo + "_unirse"
		
		if event.is_action_pressed(accion_unirse):
			if not jugadores_activos.has(prefijo):
				for panel in paneles:
					if panel.estado_actual == panel.Estado.ESPERANDO:
						jugadores_activos.append(prefijo)
						
						var dispositivo_real = -1
						
						if event is InputEventJoypadButton or event is InputEventJoypadMotion:
							dispositivo_real = event.device
						
						panel.iniciar_jugador(prefijo, dispositivo_real)
						break

func _on_jugador_salio(prefijo: String):
	jugadores_activos.erase(prefijo)

func _on_jugador_listo(prefijo: String, esta_listo: bool, indice: int = 0):
	if esta_listo:
		jugadores_listos[prefijo] = indice
	else:
		jugadores_listos.erase(prefijo)
		
	comprobar_inicio_juego()

func actualizar_iconos_globales(device_id: int):
	var animacion = "teclado"
	
	if device_id != -1:
		var nombre_mando = Input.get_joy_name(device_id).to_lower()
		if "ps4" in nombre_mando or "ps5" in nombre_mando or "sony" in nombre_mando or "dual" in nombre_mando:
			animacion = "ps"
		elif "nintendo" in nombre_mando or "switch" in nombre_mando or "joy-con" in nombre_mando or "pro" in nombre_mando:
			animacion = "switch"
		else:
			animacion = "xbox"
			
	icono_aceptar_global.play(animacion)
	icono_volver_global.play(animacion)
