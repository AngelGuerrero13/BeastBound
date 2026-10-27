# Decoración editable de las partidas

Abre `ui/seleccion_partidas.tscn` en Godot, en la vista **2D**, para ver la pantalla completa.

- **Fondo** usa `fondo_pradera/pradera_base.png`: pradera, tierra y orilla del río.
- **Animacion del Fondo** contiene **Hojas Animadas** y **Animacion Viento**. Selecciona **Animacion Viento**, abre el panel **Animación** y reproduce **Viento** para previsualizarlo. La animación no se reproduce automáticamente mientras espera aprobación.
- Para editar un cartel abre `ui/seleccion_partidas/cartel_1.tscn`, `cartel_2.tscn` o `cartel_3.tscn`. También puedes pulsar el icono de escena junto al nodo correspondiente dentro de **Carteles**. Cada escena contiene el nodo **Tabla** y los controles editables; se retiraron cuerdas, nudos y adornos. **Tabla** usa una textura de `maderas_musgo/madera_1.png`, `madera_2.png` o `madera_3.png` y mide 480 × 92 píxeles. Si cambias algo que deba ser igual en los tres, repite el cambio en cada uno.
- Los archivos PNG de las piezas están en `assets/art/ui/partidas_editables/`; los adornos naturales están en su carpeta `naturaleza/`. El script de comportamiento sigue en `ui/seleccion_partidas.gd` y el estilo de botones en `ui/tema_partidas.tres`.

Para cambiar una madera, abre la escena de su cartel y selecciona **Tabla**. En el Inspector, **Texture** contiene un AtlasTexture con la imagen y el recorte; el nodo se muestra en el editor sin ejecutar el juego. Las plantillas anteriores permanecen guardadas en `plantillas.tres` y `naturaleza/`, pero los carteles actuales no las cargan.

`paisaje.png` y `piezas_fuente.png` se prepararon con ImageGen integrado; los prompts están en `prompts.json`. Los PNG de las piezas usan ahora `piezas_trazo_fino.png`, con contornos delgados de color; su prompt está en `prompt_trazo_fino.json`. Se conservan los tamaños, las siluetas, las casillas y las posiciones de las capas.

**No ejecutes `preparar_plantillas.gd` para editar esta pantalla.** Es una herramienta antigua de preparación que reconstruye recursos y composición y puede sobrescribir cambios o no respetar la nueva organización de escenas. Su opción `--solo-texturas` actualiza únicamente los PNG y conserva las escenas y plantillas. No hace falta ejecutarla para editar o jugar.

`naturaleza/agregar_plantillas.gd` es otra herramienta de preparación de la paleta. No hace falta ejecutarla para editar o jugar; revisa sus efectos y guarda una copia antes de usarla.
