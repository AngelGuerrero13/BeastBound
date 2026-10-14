# Ideas de pared para el granero

Abre `res://niveles/tutorial/ideas_granero.tscn` para comparar tres paredes, sin suelo:

1. **Madera Sencilla**: tablones y vigas, con pocos detalles.
2. **Ventanas al Bosque**: tres ventanas con siluetas verdes que enlazan con el ambiente del Nivel 1.
3. **Porton Central**: puerta doble cerrada con refuerzos en X y algunos tonos verdes en los postes.

Las tres imágenes se crearon con ImageGen integrado usando el árbol frondoso del Nivel 1 como referencia de estilo. Los originales y las versiones de 480 × 72 píxeles están en `assets/art/fondos/granero_tutorial/ideas/`. Los prompts completos están en `prompts.json`. Las versiones pequeñas usan interpolación al vecino más cercano para conservar bordes de píxel.

## Pared activa en el tutorial

En `tutorial.tscn`, **Fondo → Pared Granero** ya usa **Ventanas al Bosque**, la opción 2. La pared anterior y el grupo de alternativas se retiraron del tutorial; los tres patrones se conservan como recursos para editar después.

Para cambiar de diseño, selecciona **Pared Granero**, abre **TileMap → Patrones**, borra el fondo actual y pinta uno de los tres patrones completos en la celda (0, 0).

**Suelo Paja** conserva la textura original, el recorte, la escala y la posición. La escala vertical de Pared Granero ajusta los 72 píxeles al alto exacto de la pared anterior.

## Pintar y modificar las plantillas

Selecciona **Pared Granero**, una **TileMapLayer**, y abre **TileMap → Patrones**. El recurso `plantillas_granero.tres` contiene los tres patrones completos, cada uno de 60 × 9 celdas, con cuadrícula de 8 × 8 píxeles. Puedes pintar el fondo entero, borrar tiles, seleccionar una parte con la herramienta de selección y copiarla para reutilizar vigas, tablones, ventanas o el portón.

Para probar modificaciones aparte, abre `plantillas_granero.tscn`. No hay scripts que regeneren las paredes al ejecutar: los tiles, las texturas y los patrones están guardados en las escenas y recursos.
