# Tutorial del granero

Abre `res://niveles/tutorial/tutorial.tscn` en Godot. La sala mide 480 × 200 unidades; con zoom 2 ocupa una pantalla y media de ancho. Usa el mismo Mago y movimiento en X e Y del Nivel 1.

- **Fondo → Pared Granero**: opción 2, Ventanas al Bosque, como TileMapLayer editable. Usa `ideas/ventanas.png` a través de `ideas/plantillas_granero.tres`.
- **Fondo → Suelo Paja**: recorte inferior original de `assets/art/fondos/granero_tutorial/granero_paja.png`. Se conserva como AtlasTexture y se ve sin ejecutar.
- **Decoracion Granero**: cinco capas editables y doce patrones de decoración de 48 × 48 píxeles. Consulta `DECORACION.md`.
- **Mago → Interfaz Jugador**: en este tutorial solo se muestra Retrato Personaje. Corazones Vida, Marco Vida y Marco Retrato están ocultos mediante propiedades guardadas en la escena; los otros niveles conservan su interfaz de vida.
- **Zona Practica**: coloca aquí tus muñecos. **Punto 1**, **Punto 2** y **Punto 3** son marcadores de posiciones sugeridas; no aparecen al jugar.
- **Limites Granero**: cuatro paredes físicas con sus colisiones editables.
- **Camara Tutorial**: zoom 2 y límites de la sala.
- **Tiempo Practica**: Timer de 60 segundos de juego activo; se detiene al pausar.
- **Interfaz Tutorial → Boton Avanzar**: botón anclado abajo a la derecha, con el tema de madera de las partidas. Se ve en el editor; al jugar se oculta hasta que termine el minuto. Puedes continuar practicando después del minuto sin que cambie la escena automáticamente.

Una partida recién creada tiene `tutorial_pendiente = true`. La primera vez que se abre entra al granero y consume esa entrada. Al cargarla posteriormente se abre el nivel guardado; una partida antigua sin ese campo conserva su comportamiento. Si sales del granero antes del minuto, la próxima carga también entra al Nivel 1. Guardar desde el tutorial conserva el inicio del Nivel 1 y no guarda posiciones del granero.

El fondo se creó con ImageGen integrado. El prompt completo está en `assets/art/fondos/granero_tutorial/prompt.txt`.

Hay tres ideas de pared, con menos detalle, en `ideas_granero.tscn`. Sus patrones siguen disponibles en `plantillas_granero.tscn`; la opción 2 ya está activa en `Fondo → Pared Granero` del tutorial. Consulta `PLANTILLAS.md` para cambiarlas. El suelo de paja sigue usando el recorte original. Se retiraron Titulo Tutorial y Ayuda Controles de la esquina superior derecha para añadirlos después.

Prueba automatizada (con datos aislados): configura APPDATA en `.godot/tutorial-tests/test-appdata` y ejecuta Godot con `--headless --path . --script res://tests/tutorial_check.gd`. La prueba acelera el tiempo del motor para comprobar el minuto completo, la pausa, la salida, las recargas y las partidas antiguas.
