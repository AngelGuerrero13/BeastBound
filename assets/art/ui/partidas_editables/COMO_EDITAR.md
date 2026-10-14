# Decoración editable de las partidas

Abre `ui/seleccion_partidas.tscn` en Godot, en la vista **2D**.

- **Fondo Pradera** usa `paisaje.png`: solo cielo, árboles lejanos y pradera. El arco ya no está pegado al paisaje.
- **Arco** contiene 6 capas: dos palos, travesaño, placa del título y dos amarres. El marco no tiene plantas colocadas; sus plantillas siguen disponibles para decorar a tu gusto.
- **Carteles → Cartel 1 / 2 / 3** contiene la tabla, cada cuerda, cada nudo y sus plantas en capas separadas. Los controles conservan sus posiciones editables.

Haz clic en una **Capa** del árbol: se abre el panel nativo **TileMap** con la paleta. En **Patrones** hay 31 plantillas completas: las 16 piezas anteriores y 15 adornos naturales. Todas las capas comparten `plantillas.tres`, así que todas muestran las mismas piezas.

Los 12 patrones **Natural** son arbustos, helecho, hiedra, guirnalda, esquina de hojas, rosal, flores, musgo y rama. Los tres patrones **Nivel 1** son sus arbustos originales blanco, rosado y ancho. Los dibujos están en `naturaleza/`; los nuevos se crearon con ImageGen integrado, tomando como referencia la vegetación del nivel, y el prompt está en `naturaleza/prompt.json`. Ninguno está colocado en los letreros: elige uno en **TileMap → Patrones** y píntalo donde quieras en la capa seleccionada.

Para mover una pieza ya colocada, selecciona su capa y usa **Position**, **Rotation** o **Scale** del Inspector. Para copiarla o pintarla de nuevo, elige su plantilla en **TileMap → Patrones**. Para modificar un fragmento, pinta o borra sus casillas de 4 × 4 píxeles. El borrado solo afecta a la capa seleccionada. Las casillas completamente transparentes no forman parte de las plantillas.

Cada PNG pequeño de esta carpeta corresponde a una pieza. Cambia ese PNG o la fuente del TileSet para reemplazar su dibujo. El título y los textos siguen siendo controles editables, y los botones usan `ui/tema_partidas.tres`.

`paisaje.png` y `piezas_fuente.png` se prepararon con ImageGen integrado; los prompts están en `prompts.json`. Los PNG de las piezas usan ahora `piezas_trazo_fino.png`, con contornos delgados de color; su prompt está en `prompt_trazo_fino.json`. Se conservan los tamaños, las siluetas, las casillas y las posiciones de las capas.

`preparar_plantillas.gd` es una herramienta de preparación, no se ejecuta en el juego: reconstruye los recursos y la composición inicial, así que no la ejecutes sobre una decoración que ya hayas personalizado. Su opción `--solo-texturas` actualiza únicamente los PNG y conserva las escenas y plantillas. No hace falta ejecutarla para editar o jugar.

`naturaleza/agregar_plantillas.gd` añade los 15 patrones naturales a la paleta sin modificar la escena. Úsalo para recuperar esa colección después de reconstruir la paleta inicial.
