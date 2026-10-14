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

La escena `niveles/mundo.tscn` contiene Nivel 1. Abre la escena del nivel para editar sus nodos internos.

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

La selección de partidas se edita en `ui/seleccion_partidas.tscn`: **Fondo Pradera** tiene la pradera y el soporte con las cuerdas sujetas al travesaño; **Titulo Partidas** es texto editable. En **Carteles → Cartel 1 / Cartel 2 / Cartel 3**, cada nodo **Madera y Cuerdas** usa una región de `assets/art/ui/partidas_rusticas/carteles.png`; los nombres, datos, barras, campos de nombre y botones son nodos separados. **Boton Volver** y **Estado Partida** están en la raíz. `ui/tema_partidas.tres` usa `boton_madera.png` para las placas ámbar. Los tres PNG están guardados en el proyecto y se ven en el editor sin ejecutar. El script cambia los ejemplos del editor por las partidas reales al iniciar la escena.

Abre `ui/menu_principal.tscn`:

- **Fondo → Imagen Granja**: textura `ui/introduccion_granja.svg`.
- **Centro Menu → Margen Interior → Botones Menu**: Boton Jugar, Accesos Menu y Boton Guardar Partida.
- **Boton Jugar → Icono Jugar**: textura guardada en `ui/icono_jugar.tres`, extraída de la lámina original para verse también en el editor.
- **Accesos Menu**: grupos de configuración, controles, créditos y salida. Cada uno tiene su botón y Etiqueta Boton.
- **Ventanas Menu → Centro Ventana → Panel Ventana → Margen Interior → Contenido Ventana**: Configuracion, Controles y Creditos, con todos sus controles guardados en la escena.

Para previsualizar una ventana, activa **Visible** en Ventanas Menu y en el panel deseado; desactiva los otros dos paneles. Al ejecutar, el script muestra el panel elegido. Los ajustes se sincronizan con los datos guardados.

Abre `ui/seleccion_partidas.tscn`: **Carteles → Cartel 1 / Cartel 2 / Cartel 3** contiene los controles editables de cada partida. **Boton Volver** está en la raíz.

Usa **F6** para probar la escena abierta o **F5** para iniciar desde el menú principal. Los scripts mantienen las transiciones, el comportamiento, los ajustes y las partidas. Se conserva la ruta guardada `Nivel 1/Mago` para que las partidas anteriores sigan cargando.

La selección usa carteles de 480 píxeles de ancho. En cada **Cartel**, **Boton Eliminar** es la X rojiza: visible en los dos ejemplos guardados y oculta en el espacio vacío. La confirmación también es editable en la raíz: **Confirmar Borrado → Panel Borrado**, con **Titulo Borrado**, **Detalle Borrado**, **Boton Cancelar** y **Boton Eliminar**. Activa Visible de Confirmar Borrado para previsualizarla y vuelve a ocultarla antes de guardar. El estilo Eliminar está en **ui/tema_partidas.tres**. **Pradera_Ancha** es una región de pradera_soporte.png que adapta el soporte al nuevo ancho; no se añadió otro fondo.

Ajuste visual de partidas: **Fondo Pradera → Texture → Pradera_Ancha** usa **pradera_soporte_v2.png**, con las cuerdas del travesaño retocadas y alineadas. La barra de progreso mide dos tercios del ancho anterior. En cada **Cartel**, **Boton Eliminar** queda entre las cuerdas, a la izquierda de **Boton Partida**. **Detalle Partida** se oculta en los espacios vacíos. El cartel de guardar se edita en **menu_principal.tscn → Centro Menu → Margen Interior → Botones Menu → Boton Guardar Partida**; sus estilos usan **cartel_sin_cuerdas.png** y su texto es GUARDAR PARTIDA. Ambos PNG y los prompts están en **assets/art/ui/partidas_rusticas**.
