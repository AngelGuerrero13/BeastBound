extends SceneTree

func _initialize() -> void:
	call_deferred("comprobar")

func comprobar() -> void:
	var base: Script = load("res://personajes/personajeBase/personaje_base.gd")
	for tipo in ["mago", "tanque", "raton_tirador"]:
		var guion: Script = load("res://personajes/%s/%s.gd" % [tipo, tipo])
		assert(guion.get_base_script() == base)
		var personaje: CharacterBody2D
		if tipo == "raton_tirador":
			personaje = guion.new()
			var imagen := AnimatedSprite2D.new()
			imagen.name = "Imagen Raton"
			var cuadros := SpriteFrames.new()
			for anim in ["reposo", "caminar", "caminar_izquierda", "caminar_arriba", "caminar_abajo", "atacar", "morir"]:
				cuadros.add_animation(anim)
				cuadros.add_frame(anim, null)
			imagen.sprite_frames = cuadros
			personaje.add_child(imagen)
			var hud := CanvasLayer.new()
			hud.name = "Interfaz Jugador"
			personaje.add_child(hud)
			var corazones := HBoxContainer.new()
			corazones.name = "Corazones Vida"
			hud.add_child(corazones)
		else:
			personaje = load("res://personajes/%s/%s.tscn" % [tipo, tipo]).instantiate()
		root.add_child(personaje)
		personaje.set_process(false)
		personaje.set_physics_process(false)
		var accion: String = "ui_down" if tipo == "raton_tirador" else "p1_abajo"
		Input.action_press(accion)
		personaje.manejar_movimiento()
		assert(is_equal_approx(personaje.velocity.y, personaje.velocidad))
		Input.action_release(accion)
		personaje.manejar_movimiento()
		assert(personaje.velocity == Vector2.ZERO)
		personaje.mover_en_direccion(Vector2(1, 1))
		assert(is_equal_approx(personaje.velocity.length(), personaje.velocidad))
		if tipo == "tanque":
			assert(personaje.velocidad_embestida == 800.0)
			assert(personaje.velocidad_escudo == 80.0)
			personaje.esta_embistiendo = true
			personaje.direccion_embestida = Vector2.RIGHT
			personaje.manejar_movimiento()
			assert(personaje.velocity == Vector2(800, 0))
		elif tipo == "raton_tirador":
			assert(personaje.velocidad == 100.0)
			personaje.atacar(Vector2.RIGHT)
			assert(personaje.atacando and personaje.imagen.animation == "atacar")
			personaje.manejar_movimiento()
			assert(personaje.velocity == Vector2.ZERO)
			personaje._al_terminar_animacion()
			assert(not personaje.atacando and personaje.imagen.animation == "reposo")
			personaje.recibir_dano(1)
			personaje.recibir_dano(1)
			assert(personaje.vida == 5) # El segundo golpe se bloquea por invulnerabilidad.
			personaje.invulnerabilidad = 0
			personaje.recibir_dano(99)
			assert(personaje.muerto and personaje.imagen.animation == "morir")
		personaje.free()
	print("OK: herencia, movimiento, embestida, arco, invulnerabilidad y muerte")
	quit()
