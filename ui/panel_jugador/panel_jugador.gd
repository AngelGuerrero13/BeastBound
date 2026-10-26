extends Control

signal jugador_salio(prefijo)
signal jugador_listo(prefijo, esta_listo, indice_personaje)

# --- ESTADOS Y DATOS ---
enum Estado { ESPERANDO, SELECCIONANDO, LISTO }
var estado_actual = Estado.ESPERANDO
var indice_personaje_actual = 0

var prefijo_input = ""
var device_id = -1

var lista_personajes = [
	["Mapache","Tanque",preload("res://assets/art/personajes/mago/RanaPrueba.png")],
	["Sapo","Mago",preload("res://assets/art/personajes/mago/ranafoto.png")],
	["Nutria","Guerrero",preload("res://assets/art/personajes/hongo simple.png")],
	["Ratón","Tirador",preload("res://icon.svg")]
]

# Contenedor del botón
@onready var contenedor_unirse = $ContenedorUnirse
@onready var animacion_boton = $ContenedorUnirse/IconoBoton/AnimacionBotones

@onready var contenedor_listo = $ContenedorListo
@onready var animacion_listo = $ContenedorListo/IconoBoton/AnimacionBotones

# Elementos del personaje
@onready var vista_personaje = $VistaPersonaje
@onready var imagen_pj = $VistaPersonaje/Imagen
@onready var nombre_pj = $VistaPersonaje/MarcoNombre/Nombre
@onready var mensaje_listo = $VistaPersonaje/MensajeListo
@onready var flecha_arriba = $VistaPersonaje/FlechaArriba
@onready var flecha_abajo = $VistaPersonaje/FlechaAbajo

func _ready():
	animacion_boton.play("teclado")
	animacion_listo.play("teclado")
	Input.joy_connection_changed.connect(_al_cambiar_conexion_mando)
	actualizar_ui()

func iniciar_jugador(prefijo: String, device: int):
	prefijo_input = prefijo
	device_id = device
	estado_actual = Estado.SELECCIONANDO
	
	if device != -1:
		_actualizar_icono(device)
		
	else:
		animacion_boton.play("teclado")
		animacion_listo.play("teclado")
		
	actualizar_ui()

func _input(event):
	if estado_actual == Estado.ESPERANDO or prefijo_input == "":
		return
		
	if event is InputEventKey and device_id == -1:
		animacion_boton.play("teclado")
		animacion_listo.play("teclado")
	elif (event is InputEventJoypadButton or event is InputEventJoypadMotion) and event.device == device_id:
		_actualizar_icono(event.device)

	match estado_actual:
		Estado.SELECCIONANDO:
			if event.is_action_pressed(prefijo_input + "_arriba"):
				indice_personaje_actual -= 1
				if indice_personaje_actual < 0:
					indice_personaje_actual = lista_personajes.size() - 1
				actualizar_ui()
				
			elif event.is_action_pressed(prefijo_input + "_abajo"):
				indice_personaje_actual += 1
				if indice_personaje_actual >= lista_personajes.size():
					indice_personaje_actual = 0
				actualizar_ui()
				
			elif event.is_action_pressed(prefijo_input + "_unirse"):
				estado_actual = Estado.LISTO
				jugador_listo.emit(prefijo_input, true, indice_personaje_actual)
				actualizar_ui()
				
			elif event.is_action_pressed(prefijo_input + "_volver"):
				estado_actual = Estado.ESPERANDO
				jugador_salio.emit(prefijo_input)
				prefijo_input = ""
				actualizar_ui()
				
		Estado.LISTO:
			if event.is_action_pressed(prefijo_input + "_volver"):
				estado_actual = Estado.SELECCIONANDO
				jugador_listo.emit(prefijo_input, false, 0)
				actualizar_ui()

# --- FUNCIONES DE INTERFAZ Y MANDOS ---
func actualizar_ui():
	contenedor_unirse.hide()
	vista_personaje.hide()
	contenedor_listo.hide()
	
	if estado_actual == Estado.ESPERANDO:
		contenedor_unirse.show()
		
	elif estado_actual == Estado.SELECCIONANDO or estado_actual == Estado.LISTO:
		vista_personaje.show()
		var datos_pj = lista_personajes[indice_personaje_actual]
		
		nombre_pj.text = datos_pj[0] + "\n" + datos_pj[1]
		if datos_pj[2] != null:
			imagen_pj.texture = datos_pj[2]
			
		if estado_actual == Estado.SELECCIONANDO:
			contenedor_listo.show()
			flecha_arriba.show()
			flecha_abajo.show()
			
		elif estado_actual == Estado.LISTO:
			flecha_arriba.hide()
			flecha_abajo.hide()

func _actualizar_icono(device_id: int):
	var nombre_mando = Input.get_joy_name(device_id).to_lower()
	if "ps4" in nombre_mando or "ps5" in nombre_mando or "sony" in nombre_mando or "dualshock" in nombre_mando or "dualsense" in nombre_mando:
		animacion_boton.play("ps")
		animacion_listo.play("ps")
	elif "nintendo" in nombre_mando or "switch" in nombre_mando or "joy-con" in nombre_mando or "pro controller" in nombre_mando:
		animacion_boton.play("switch")
		animacion_listo.play("switch")
	else:
		animacion_boton.play("xbox")
		animacion_listo.play("xbox")

func _al_cambiar_conexion_mando(device: int, connected: bool):
	if connected:
		_actualizar_icono(device)
	else:
		if Input.get_connected_joypads().size() == 0:
			animacion_boton.play("teclado")
