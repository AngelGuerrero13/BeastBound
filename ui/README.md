# Menús de BeastBound

El menú es una escena de interfaz (`Control`), no un nivel. `menu_principal.tscn` es la escena principal del proyecto. Ejecuta con **F6** esa escena para ver el menú, o con **F5** para iniciar el juego completo.

Al abrir el juego se recorre automáticamente `introduccion_granja.svg`, una imagen vertical provisional de 640 × 1440 con degradados del cielo a la tierra y cultivos al pie. Al llegar abajo aparece el PLAY original de la lámina Sprout Lands y, debajo, los botones de engranaje, mando, estrella y salida, con sus nombres. Enter, Espacio, Escape o clic izquierdo saltan el recorrido sin activar PLAY. La introducción se muestra una vez por ejecución; la pausa y el regreso desde la partida abren el menú directamente.

Para cambiar la velocidad, edita **Duracion Introduccion** en el nodo raíz de `menu_principal.tscn` (7 segundos de recorrido por defecto). Para sustituir el arte provisional, cambia **Texture** en `Fondo/Imagen` por la imagen vertical definitiva. La imagen se adapta al ancho y conserva su proporción; el recorrido se recalcula al cambiar el tamaño de la ventana.

- **PLAY** abre `res://niveles/mundo.tscn`.
- **Configuración** permite ajustar volumen general, música y efectos, silenciar el audio y activar/desactivar pantalla completa. Los cambios se aplican inmediatamente y se guardan al volver, también con Escape, en `user://ajustes.cfg`.
- **Controles** explica las acciones implementadas actualmente. Es una guía; no reasigna teclas.
- **Créditos** muestra al equipo del README del proyecto.
- **Salir del juego**, en el menú principal, cierra BeastBound directamente.
- **Escape durante la partida** pausa el nivel. PLAY, con la etiqueta Continuar, reanuda la partida; el botón de casa con la etiqueta MENU vuelve directamente al menú principal, sin confirmación ni introducción, incluso si el nivel se inició con F6. El juego solo se cierra desde el menú principal. Al pulsar PLAY de nuevo se reinicia la partida.

Los botones y textos principales se editan en `menu_principal.tscn`. El estilo compartido está en `tema_menu.tres`; el comportamiento y las ventanas secundarias están en `menu_principal.gd`. `ajustes.gd` es un Autoload que mantiene las preferencias y la pausa entre escenas, incluso al probar un nivel con F6.

Todos los sprites consumidos por el menú y la configuración proceden de `assets/art/ui/Sprout Lands - UI Pack - Basic pack/Sprite sheets/Sprite sheet for Basic Pack.png`, idéntica a la lámina adjunta por el usuario. `AtlasTexture` selecciona las regiones directamente, sin modificar la imagen original.

`recursos_ui.gd` define los pares de frames. `boton_ui.gd`, basado en TextureButton, anima todos los botones, incluido PLAY: al pasar el cursor aumentan ligeramente de tamaño y brillo; al hacer clic muestran el sprite presionado y se hunden; al soltar recuperan el estado del cursor. El foco de teclado se resalta por separado para que PLAY también reaccione al cursor aunque tenga el foco inicial. PLAY incluye su texto dibujado en la imagen. Los botones secundarios usan sus cuadros con iconos ya dibujados. Las ventanas de configuración, controles y créditos usan texto legible y botones Volver con los estados de la misma lámina. No hay ventanas de confirmación.

La licencia del pack se conserva en `assets/art/ui/Sprout Lands - UI Pack - Basic pack/read_me.txt`.

El Autoload crea los buses **Musica** y **Efectos**, enviados a **Master**, si faltan. Al agregar `AudioStreamPlayer`, asigna su propiedad **Bus** a Musica o Efectos para que responda al deslizador correspondiente. El volumen general afecta todo el audio. No se han añadido pistas de música ni sonidos nuevos.

La navegación funciona con ratón o flechas y Enter. En las ventanas, Escape vuelve atrás; en pausa, un segundo Escape continúa la partida.

## Cursor de patita

`CursorPatita` es un Autoload que instala el diseño pastel aprobado en todo el juego, incluido el menú, los niveles probados con F6 y la pausa. Usa tres PNG transparentes de 48 × 48 en `assets/art/ui/cursor_patita`: normal, cierre y presionada. El punto de clic está en `(18, 3)`, junto al extremo del primer dedo, y se conserva entre frames.

El clic izquierdo y derecho recorren normal → cierre → puño; el puño permanece mientras se mantenga un botón pulsado. Al soltar ambos vuelve por cierre → normal. Un clic breve también muestra los tres estados. El cursor continúa animándose durante la pausa y vuelve a su estado normal al perder el foco de la ventana. Los clics siguen llegando a la interfaz y al combate.

La imagen fuente y el prompt de la edición con ImageGen se conservan en `assets/art/ui/cursor_patita`. Para cambiar la velocidad, edita `TIEMPO_TRANSICION` y `TIEMPO_PRESION_MINIMA` en `cursor_patita.gd`.
