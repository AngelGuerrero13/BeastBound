extends Node

const MAX_PARTIDAS := 3
const MUNDO := "res://niveles/mundo.tscn"
const TUTORIAL := "res://niveles/tutorial/tutorial.tscn"
const CARPETA := "user://partidas"

var espacio_activo := 0
var estado_pendiente: Dictionary = {}


func existe(espacio: int) -> bool:
	return espacio >= 1 and espacio <= MAX_PARTIDAS and FileAccess.file_exists(_ruta(espacio))


func leer(espacio: int) -> Dictionary:
	if not existe(espacio):
		return {}
	var archivo := ConfigFile.new()
	if archivo.load(_ruta(espacio)) != OK:
		return {}
	if archivo.get_value("partida", "version", 0) != 1 or archivo.get_value("partida", "escena", "") != MUNDO:
		return {}
	var jugadores: Variant = archivo.get_value("partida", "jugadores", null)
	var fecha: Variant = archivo.get_value("partida", "fecha", null)
	if not jugadores is Array or not fecha is String:
		return {}
	for jugador in jugadores:
		if not jugador is Dictionary:
			return {}
		if not jugador.get("ruta") is String or not jugador.get("posicion") is Vector2 or not jugador.get("vida") is int:
			return {}
		if not jugador.posicion.is_finite() or jugador.vida <= 0:
			return {}
	var nombre: Variant = archivo.get_value("partida", "nombre", "Equipo %d" % espacio)
	var nivel: Variant = archivo.get_value("partida", "nivel", 1)
	var avance: Variant = archivo.get_value("partida", "avance", 0)
	var tutorial_pendiente: Variant = archivo.get_value("partida", "tutorial_pendiente", false)
	if not nombre is String or nombre.strip_edges().is_empty() or nombre.length() > 24:
		return {}
	if not nivel is int or nivel < 1 or not avance is int or avance < 0 or avance > 100:
		return {}
	if not tutorial_pendiente is bool:
		return {}
	return {"jugadores": jugadores, "fecha": fecha, "nombre": nombre, "nivel": nivel, "avance": avance, "tutorial_pendiente": tutorial_pendiente}


func crear(espacio: int, nombre: String = "") -> Error:
	if espacio < 1 or espacio > MAX_PARTIDAS:
		return ERR_INVALID_PARAMETER
	if existe(espacio):
		return ERR_ALREADY_EXISTS
	nombre = nombre.strip_edges()
	if nombre.is_empty() or nombre.length() > 24:
		return ERR_INVALID_PARAMETER
	return _escribir(espacio, [], nombre, 1, 0, true)


func abrir(espacio: int) -> Error:
	var datos := leer(espacio)
	if datos.is_empty():
		return ERR_FILE_CORRUPT
	var destino: String = TUTORIAL if datos.tutorial_pendiente else MUNDO
	# Consumir la primera entrada: cargar después siempre abre el Nivel 1.
	if datos.tutorial_pendiente:
		var guardado := _escribir(espacio, datos.jugadores, datos.nombre, datos.nivel, datos.avance)
		if guardado != OK:
			return guardado
	var anterior := espacio_activo
	espacio_activo = espacio
	estado_pendiente = datos
	var resultado := Ajustes.cambiar_escena(destino)
	if resultado != OK:
		espacio_activo = anterior
		estado_pendiente = {}
		if datos.tutorial_pendiente:
			var restaurado := _escribir(espacio, datos.jugadores, datos.nombre, datos.nivel, datos.avance, true)
			if restaurado != OK:
				push_error("No se pudo restaurar la entrada al tutorial: %s" % error_string(restaurado))
	return resultado


func eliminar(espacio: int) -> Error:
	if espacio < 1 or espacio > MAX_PARTIDAS:
		return ERR_INVALID_PARAMETER
	if not existe(espacio):
		return ERR_DOES_NOT_EXIST
	var resultado := DirAccess.remove_absolute(_ruta(espacio))
	if resultado == OK and espacio_activo == espacio:
		espacio_activo = 0
		estado_pendiente = {}
	return resultado


func guardar_actual() -> Error:
	var mundo := get_tree().current_scene
	if espacio_activo < 1 or espacio_activo > MAX_PARTIDAS or mundo == null or mundo.scene_file_path not in [MUNDO, TUTORIAL]:
		return ERR_UNCONFIGURED
	if mundo.scene_file_path == TUTORIAL:
		var datos := leer(espacio_activo)
		if datos.is_empty():
			return ERR_FILE_CORRUPT
		# Las posiciones del granero no pertenecen al Nivel 1.
		return _escribir(espacio_activo, [], datos.nombre, 1, 0)
	var jugadores: Array = []
	for jugador in get_tree().get_nodes_in_group("Jugador"):
		if not mundo.nivel_actual.is_ancestor_of(jugador) or not jugador.es_jugador or jugador.is_queued_for_deletion():
			continue
		if jugador.vida <= 0:
			return ERR_UNAVAILABLE
		jugadores.append({"ruta": String(mundo.get_path_to(jugador)), "posicion": jugador.global_position, "vida": jugador.vida})
	if jugadores.is_empty():
		return ERR_UNAVAILABLE
	var anterior := leer(espacio_activo)
	if anterior.is_empty():
		return ERR_FILE_CORRUPT
	var nivel: Node2D = mundo.nivel_actual
	var camara: Camera2D = nivel.get_node("Camara Nivel")
	var inicio: float = nivel.get_meta("inicio_avance")
	var avance: int = anterior.avance if anterior.nivel == nivel.numero_nivel else 0
	# shortcut: avance por distancia recorrida; sustituir cuando haya objetivos de nivel.
	for jugador in jugadores:
		var recorrido: float = inverse_lerp(inicio, float(camara.limit_right), jugador.posicion.x)
		avance = maxi(avance, clampi(floori(recorrido * 100.0), 0, 100))
	return _escribir(espacio_activo, jugadores, anterior.nombre, nivel.numero_nivel, avance)


func aplicar_estado(mundo: Node2D) -> void:
	for datos in estado_pendiente.get("jugadores", []):
		var jugador := mundo.get_node_or_null(NodePath(datos.ruta))
		if jugador == null or not jugador.is_in_group("Jugador") or not jugador.es_jugador:
			continue
		jugador.global_position = datos.posicion
		jugador.vida = clampi(datos.vida, 1, jugador.vida_maxima)
		jugador.actualizar_corazones()
	estado_pendiente = {}


func _ruta(espacio: int) -> String:
	return "%s/partida_%d.cfg" % [CARPETA, espacio]


func _escribir(espacio: int, jugadores: Array, nombre: String, nivel: int, avance: int, tutorial_pendiente: bool = false) -> Error:
	var resultado := DirAccess.make_dir_recursive_absolute(CARPETA)
	if resultado != OK:
		return resultado
	var archivo := ConfigFile.new()
	archivo.set_value("partida", "version", 1)
	archivo.set_value("partida", "escena", MUNDO)
	archivo.set_value("partida", "fecha", Time.get_datetime_string_from_system(false, true))
	archivo.set_value("partida", "jugadores", jugadores)
	archivo.set_value("partida", "nombre", nombre)
	archivo.set_value("partida", "nivel", nivel)
	archivo.set_value("partida", "avance", avance)
	archivo.set_value("partida", "tutorial_pendiente", tutorial_pendiente)
	# Escribir primero el temporal evita truncar el guardado anterior si falla la escritura.
	var temporal := _ruta(espacio) + ".tmp"
	resultado = archivo.save(temporal)
	if resultado != OK:
		return resultado
	return DirAccess.rename_absolute(temporal, _ruta(espacio))
