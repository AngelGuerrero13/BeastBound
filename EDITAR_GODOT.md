# Dónde editar en Godot

Los nombres del árbol indican qué cambia cada nodo. Las capas decorativas están numeradas; su profundidad real se ajusta en **Ordering → Z Index**.

## Nivel 1

Abre `niveles/nivel 1/nivel 1.tscn`.

| Ruta en el árbol | Qué editar |
| --- | --- |
| Fondo → Suelo Pasto | Baldosas del camino y suelo. |
| Fondo → Color Fondo | Color base detrás de la vegetación. |
| Fondo → Capa 1 Siluetas | Siluetas lejanas. |
| Fondo → Capa 2 Rocas | Rocas de fondo. |
| Fondo → Capa 3 Vegetacion Lejana | Árboles y arbustos del fondo. |
| Fondo → Capa 4 Arboles Grandes | Árboles cercanos. |
| Fondo → Capa 5 Arbustos Grandes | Arbustos cercanos. |
| Fondo → Capa 6 Brotes | Brotes pequeños. |
| Fondo → Capa 7 Pared Superior | Dibujo del muro superior y sus arbustos. |
| Fondo → Capa 8 Flores | Arbustos con flores. |
| Fondo → Capa 9 Piedras | Piedras decorativas. |
| Fondo → Capa 10 Maleza Frontal | Maleza que aparece delante del muro. |
| Limites Nivel → Pared Superior → Colision Superior | Límite físico de arriba. |
| Limites Nivel → Pared Inferior → Colision Inferior | Límite físico de abajo. |
| Limites Nivel → Paredes Laterales | Colision Izquierda y Colision Derecha. |
| Puntos Oleadas | Marcadores de las cinco oleadas. |
| Camara Nivel | Zoom y encuadre del nivel. Anticipación y suavizado están en la raíz Nivel 1. |
| Ambiente → Polen Suave | Partículas doradas detrás de los personajes. Amount controla la cantidad en todo el nivel; Initial Velocity, la velocidad; Color, la opacidad. |

Las capas 1 a 10 usan los TileSet `assets/art/fondos/vegetacion_editable/01_Siluetas.tres` a `10_MalezaInferior.tres`; los nombres de esos archivos se conservan. **Color Fondo** usa `color_fondo.png` de esa carpeta. No se han añadido fondos. Para pintar piezas completas, usa **TileMap → Patrones**. Más detalles en `assets/art/fondos/vegetacion_editable/COMO_EDITAR.md`.

La escena `niveles/mundo.tscn` contiene **Nivel 1** y **Nivel 2** como instancias guardadas, con sus hijos editables. Expande cada nivel en el árbol para editar suelo, personajes, límites, cámara y marcadores. Nivel 2 está oculto en Mundo para que los dibujos de ambos niveles no se superpongan; abre su escena propia para ver y editar su suelo. Al jugar, solo el nivel activo procesa movimiento, colisiones, cámara e interfaz.

## Paso al Nivel 2

En `niveles/nivel 1/nivel 1.tscn`, **Salida Derecha → Colision Salida** es la zona que abre Nivel 2 al atravesar el extremo derecho. **Limites Nivel → Paredes Laterales → Colision Derecha** está desactivada para permitir el paso. El destino está en **Nivel 1 → Siguiente Nivel** en el Inspector.

Abre `niveles/nivel 2/nivel 2.tscn`. **Fondo → Suelo Pasto** contiene las mismas baldosas y dimensiones del Nivel 1, sin color de fondo, vegetación ni polen. Su TileSet usa `assets/art/fondos/MagicMarketFondo/Tilesets/TilesetFloor.png`; no se añadió ninguna textura de fondo. Los límites, cámara, personajes y marcadores siguen siendo nodos editables. El Nivel 2 conserva su pared derecha porque todavía no hay un Nivel 3.

Al jugar desde el menú, el mundo desactiva Nivel 1 y activa el nodo Nivel 2 ya guardado en la escena, conservando la vida del jugador. Guardar y cargar recuerda el nivel, la posición y la vida; el porcentaje de avance empieza de cero al cambiar de nivel. Las partidas antiguas del Nivel 1 siguen cargando.

**Polen Suave** guarda en la escena una textura `GradientTexture2D` de 2 × 2 píxeles y un gradiente de aparición y desaparición. Son 360 partículas repartidas a lo largo del nivel, de 1 a 2,5 px/s, escala de 0,65 a 1,05 y opacidad máxima del 62%; se dibujan detrás de los personajes y de su interfaz. No añade fondos ni rayos de luz.

## Personajes

Abre `personajes/personajeBase/personaje_base.tscn` para cambios compartidos por todos los personajes. Abre `personajes/mago/mago.tscn`, `tanque/tanque.tscn`, `enemigoBasico/enemigo_basico.tscn` o `muñecoPrueba/muñeco_prueba.tscn` para cambios propios de cada uno.

- **Imagen Personaje** y **Sombra**: dibujo y sombra.
- **Colision Cuerpo** y **Colision Sombra**: formas físicas.
- **Animaciones Personaje**: pistas de animación.
- **Camara Personaje**: cámara de la escena individual; el nivel usa Camara Nivel.
- **Barra Ataque Cargado** y **Barra Vida Enemigo**: barras sobre el personaje.
- **Interfaz Jugador**: Marco Retrato, Retrato Personaje, Marco Vida y Corazones Vida → Corazon 1, 2 y 3.
- En el mago, **Origen Disparo** marca dónde sale el proyectil. En `bola_fuego.tscn`, **Colision Proyectil** y **Animacion Fuego** controlan su forma y dibujo.

`PersonajeBase.tscn` de la raíz es una escena vacía anterior; la base compartida está en `personajes/personajeBase/personaje_base.tscn`.

## Menús

La pantalla completa se abre en `ui/seleccion_partidas.tscn`. **Fondo** usa `assets/art/ui/partidas_editables/fondo_pradera/pradera_base.png`. **Animacion del Fondo** contiene las hojas y el nodo **Animacion Viento**; selecciona ese nodo y reproduce **Viento** desde el panel Animación para previsualizarlo. La animación no se reproduce automáticamente mientras espera aprobación. Los carteles se editan por separado en `ui/seleccion_partidas/cartel_1.tscn`, `cartel_2.tscn` y `cartel_3.tscn`. Cada nodo **Tabla** muestra una imagen editable en `assets/art/ui/partidas_editables/maderas_musgo/`. Las plantillas antiguas se conservan en `assets/art/ui/partidas_editables/plantillas.tres`, pero ya no se cargan en los carteles.

Abre `ui/menu_principal.tscn`:

- **Fondo → Imagen Granja**: textura `ui/introduccion_granja.svg`.
- **Centro Menu → Margen Interior → Botones Menu**: Boton Jugar, Accesos Menu y Boton Guardar Partida.
- **Boton Jugar → Icono Jugar**: textura guardada en `ui/icono_jugar.tres`, extraída de la lámina original para verse también en el editor.
- **Accesos Menu**: grupos de configuración, controles, créditos y salida. Cada uno tiene su botón y Etiqueta Boton.
- **Ventanas Menu → Centro Ventana → Panel Ventana → Margen Interior → Contenido Ventana**: Configuracion, Controles y Creditos, con todos sus controles guardados en la escena.

Para previsualizar una ventana, activa **Visible** en Ventanas Menu y en el panel deseado; desactiva los otros dos paneles. Al ejecutar, el script muestra el panel elegido. Los ajustes se sincronizan con los datos guardados.

En `ui/seleccion_partidas.tscn`, **Carteles → Cartel 1 / Cartel 2 / Cartel 3** identifica las tres escenas independientes. Abre la escena de cada cartel para editar sus controles; **Boton Volver** está en la raíz de la pantalla principal.

Usa **F6** para probar la escena abierta o **F5** para iniciar desde el menú principal. Los scripts mantienen las transiciones, el comportamiento, los ajustes y las partidas. Se conserva la ruta guardada `Nivel 1/Mago` para que las partidas anteriores sigan cargando.

La selección usa carteles de 480 píxeles de ancho. En cada **Cartel**, **Boton Eliminar** es la X rojiza: visible en los dos ejemplos guardados y oculta en el espacio vacío. La confirmación también es editable en la raíz: **Confirmar Borrado → Panel Borrado**, con **Titulo Borrado**, **Detalle Borrado**, **Boton Cancelar** y **Boton Eliminar**. Activa Visible de Confirmar Borrado para previsualizarla y vuelve a ocultarla antes de guardar. **Madera Borrado** usa la tabla limpia `partidas_editables/tabla_1.png`. El estilo Eliminar está en **ui/tema_partidas.tres**.

La barra de progreso mide dos tercios del ancho anterior. **Detalle Partida** se oculta en los espacios vacíos. El cartel de guardar se edita en **menu_principal.tscn → Centro Menu → Margen Interior → Botones Menu → Boton Guardar Partida**; sus estilos usan **cartel_sin_cuerdas.png** y su texto es GUARDAR PARTIDA. Ese PNG y sus prompts están en **assets/art/ui/partidas_rusticas**.
