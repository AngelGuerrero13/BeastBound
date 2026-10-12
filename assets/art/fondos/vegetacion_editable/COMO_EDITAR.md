# Decoración del nivel 1

La paleta del panel **TileMap** coloca árboles y arbustos completos con un clic. Sus partes transparentes dejan ver el fondo; la pieza ya no se divide en un pincel de muchas casillas.

## Añadir un adorno

1. Abre `niveles/nivel 1/nivel 1.tscn` y selecciona una capa dentro de **Fondo**, por ejemplo **05_ArbustosGrandes**.
2. En el panel inferior **TileMap**, selecciona **Piezas para pintar**.
3. Haz clic sobre el arbusto o árbol de la paleta. Ya se selecciona entero. También puedes elegirlo en **Patrones**.
4. Haz clic en el nivel para colocarlo. Guarda con **Ctrl + S**.

El borde superior izquierdo de la imagen se alinea con la casilla donde pintas. Cada pieza completa utiliza una sola casilla de colocación, aunque su dibujo sea grande. Para borrar una pieza nueva, borra esa casilla. En una misma capa, pintar en exactamente la misma casilla sustituye la pieza anterior; puedes usar otra capa para compartir también ese punto de colocación.

## Profundidad

Las piezas nuevas tienen la profundidad preparada en la paleta: un arbusto cercano se dibuja delante de un árbol cercano, incluso si los pintas en la misma capa. La vegetación existente mantiene su orden anterior.

| Pieza nueva | Z Index final |
|---|---:|
| Árbol silueta | -80 |
| Árbol posterior y arbustos posteriores | -60 |
| Árbol cercano y frondoso | -50 |
| Arbustos cercanos, redondo y ancho | -40 |
| Brote | -35 |
| Muro | -30 |
| Arbustos con flores | -20 |
| Roca | -10 |
| Personajes | 0 |
| Maleza del borde | 20 |

## Editar lo que ya estaba colocado

El dibujo previo se conserva dentro de **ComposicionExistente**, debajo de cada capa. Esto permite pintar adornos nuevos en la capa principal sin reemplazar las casillas del dibujo anterior.

Por ejemplo, para quitar un arbusto que ya estaba en el fondo, despliega **05_ArbustosGrandes** y selecciona **ComposicionExistente**. En ese nodo puedes borrar o copiar las casillas anteriores como antes. Para editar la franja inferior, usa **10_MalezaInferior → ComposicionExistente**.

Las fuentes **Composición existente** y **Fragmentos anteriores (solo composicion)** conservan el material del dibujo previo. Para añadir piezas enteras, usa **Piezas para pintar**.

## Imágenes

Se usan los PNG transparentes originales de `assets/art/fondos/vegetacion_editable/png/` y la paleta `paleta_vegetacion.png`, sin redimensionar ni suavizar el arte. El suelo y las colisiones del nivel conservan sus cambios anteriores.
