# Ideas de pared para el granero

Abre `res://niveles/tutorial/tutorial.tscn`. Todas las muestras estan reunidas en **Fondo → Plantillas**. Activa el ojo del grupo para compararlas debajo del area jugable; se guarda oculto para que las muestras no aparezcan al jugar. Las tres paredes son:

1. **Madera Sencilla**: tablones y vigas, con pocos detalles.
2. **Ventanas al Bosque**: tres ventanas con siluetas verdes que enlazan con el ambiente del Nivel 1.
3. **Porton Central**: puerta doble cerrada con refuerzos en X y algunos tonos verdes en los postes.

Las tres imágenes se crearon con ImageGen integrado usando el árbol frondoso del Nivel 1 como referencia de estilo. Los originales y las versiones de 480 × 72 píxeles están en `assets/art/fondos/granero_tutorial/ideas/`. Los prompts completos están en `prompts.json`. Las versiones pequeñas usan interpolación al vecino más cercano para conservar bordes de píxel.

## Pared activa en el tutorial

En `tutorial.tscn`, **Fondo → Pared Granero** usa **Ventanas al Bosque**, la opción 2. En **Fondo → Plantillas** se conservan **Pared Madera**, **Pared Ventanas** y **Pared Porton**, cada una con sus tiles editables. **Atlas Suelo** muestra la superficie continua de 480 × 144 píxeles, formada por 270 piezas de 16 × 16. Las cinco capas de decoracion y sus doce patrones estan en **Fondo → Decoracion Granero**.

Para cambiar de diseño, selecciona **Pared Granero**, abre **TileMap → Patrones**, borra el fondo actual y pinta uno de los tres patrones completos en la celda (0, 0).

**Fondo → Suelo** es una TileMapLayer de 16 × 16 píxeles, igual que en el Nivel 1. Usa `suelo/plantilla_tierra_paja_v2.tres`: selecciona el nodo y abre **TileMap → Patrones → Suelo Continuo** y pinta el suelo completo en la celda (0, 4). Las piezas conservan el orden de la textura para que no aparezcan cortes; sigue siendo posible editarlas individualmente. La escala vertical de Pared Granero ajusta los 72 píxeles al alto de la pared anterior.

## Pintar y modificar las plantillas

Para el suelo, selecciona **Fondo → Suelo** y abre **TileMap → Patrones**. Estan **Suelo Continuo**, **Paja Rala**, **Paja Media** y **Paja Abundante**. Cada patron coloca una superficie completa de 480 × 144 en la celda (0, 4), conservando la continuidad interna de la textura. Son variantes planas de tierra con paja. Las tres muestras nuevas estan en **Fondo → Plantillas**, debajo de **Atlas Suelo**. Para pintar partes puedes seleccionar zonas del atlas; las uniones entre recortes de distintas variantes requieren revision visual.

Selecciona **Pared Granero**, una **TileMapLayer**, y abre **TileMap → Patrones**. El recurso `plantillas_granero.tres` contiene los tres patrones completos, cada uno de 60 × 9 celdas, con cuadrícula de 8 × 8 píxeles. Puedes pintar el fondo entero, borrar tiles, seleccionar una parte con la herramienta de selección y copiarla para reutilizar vigas, tablones, ventanas o el portón.

Las escenas auxiliares `ideas_granero.tscn`, `plantillas_granero.tscn` y `plantilla_suelo.tscn` se reunieron en el tutorial y se retiraron para evitar duplicados. No hay scripts que regeneren las paredes al ejecutar: los tiles, las texturas y los patrones están guardados en `tutorial.tscn` y sus recursos.
