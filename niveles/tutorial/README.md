# Tutorial del granero

Abre `res://niveles/tutorial/tutorial.tscn` en Godot. La sala mide 480 × 200 unidades; con zoom 2 ocupa una pantalla y media de ancho. Usa el mismo Mago y movimiento en X e Y del Nivel 1.

- **Fondo → Pared Granero**: opción 2, Ventanas al Bosque, como TileMapLayer editable. Usa `ideas/ventanas.png` a través de `ideas/plantillas_granero.tres`.
- **Fondo → Suelo**: TileMapLayer editable en piezas de 16 × 16, como el suelo del Nivel 1. Usa `assets/art/fondos/granero_tutorial/suelo/plantilla_tierra_paja_v2.tres` y su textura `tierra_paja_continua_v2.png`. Selecciona el nodo y abre **TileMap → Patrones → Suelo Continuo** para colocar el suelo completo en la celda (0, 4), sin bordes dibujados entre tiles. La textura continua ocupa 480 × 144 píxeles; conserva el orden de sus piezas para mantener la continuidad. Las 270 celdas guardadas cubren la sala; la pared tapa la franja superior y la cámara recorta el borde inferior.
- **Fondo → Decoracion Granero**: cinco capas editables y doce patrones de decoración de 48 × 48 píxeles. Conservan sus posiciones y orden visual. Consulta `DECORACION.md`.
- **Fondo → Plantillas**: tres paredes y el atlas completo del suelo, reunidos en el tutorial. El grupo se guarda oculto y debajo de la sala; activa su ojo para comparar las muestras. Los archivos PNG y TileSet permanecen organizados como recursos en `assets/art/fondos/granero_tutorial/`.
- **Mago → Interfaz Jugador**: en este tutorial solo se muestra Retrato Personaje. Corazones Vida, Marco Vida y Marco Retrato están ocultos mediante propiedades guardadas en la escena; los otros niveles conservan su interfaz de vida.
- **Zona Practica**: coloca aquí tus muñecos. **Punto 1**, **Punto 2** y **Punto 3** son marcadores de posiciones sugeridas; no aparecen al jugar.
- **Limites Granero**: cuatro paredes físicas con sus colisiones editables.
- **Camara Tutorial**: zoom 2 y límites de la sala.
- **Tiempo Practica**: Timer de 60 segundos de juego activo; se detiene al pausar.
- **Interfaz Tutorial → Boton Avanzar**: botón anclado abajo a la derecha, con el tema de madera de las partidas. Se ve en el editor; al jugar se oculta hasta que termine el minuto. Puedes continuar practicando después del minuto sin que cambie la escena automáticamente.

Una partida recién creada tiene `tutorial_pendiente = true`. La primera vez que se abre entra al granero y consume esa entrada. Al cargarla posteriormente se abre el nivel guardado; una partida antigua sin ese campo conserva su comportamiento. Si sales del granero antes del minuto, la próxima carga también entra al Nivel 1. Guardar desde el tutorial conserva el inicio del Nivel 1 y no guarda posiciones del granero.

El fondo se creó con ImageGen integrado. El prompt completo está en `assets/art/fondos/granero_tutorial/prompt.txt`.

Todas las plantillas se consultan en **Fondo → Plantillas** de `tutorial.tscn`; se retiraron las tres escenas auxiliares. La opción 2 está activa en **Fondo → Pared Granero** y el suelo del nivel se edita en **Fondo → Suelo**. Consulta `PLANTILLAS.md` para cambiar las paredes. Se retiraron Titulo Tutorial y Ayuda Controles de la esquina superior derecha para añadirlos después.

En **Fondo → Suelo → TileMap → Patrones** tambien estan **Paja Rala**, **Paja Media** y **Paja Abundante**, ademas de **Suelo Continuo**. Son tres variantes del suelo con diferente cobertura de paja, de 480 × 144 px cada una. Coloca el patron completo en (0, 4). Las muestras se guardan ocultas en **Fondo → Plantillas**; los PNG y los prompts de ImageGen integrado estan en `assets/art/fondos/granero_tutorial/suelo/`.

Prueba automatizada (con datos aislados): configura APPDATA en `.godot/tutorial-tests/test-appdata` y ejecuta Godot con `--headless --path . --script res://tests/tutorial_check.gd`. La prueba acelera el tiempo del motor para comprobar el minuto completo, la pausa, la salida, las recargas y las partidas antiguas.
