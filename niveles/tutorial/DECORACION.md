# Decoración editable del granero

Abre `res://niveles/tutorial/tutorial.tscn`. La pared activa es **Fondo → Pared Granero**, opción 2, con ventanas al bosque. Se quitaron los dos textos de la esquina superior derecha y se conservó el suelo de paja.

En **Decoracion Granero** están las cinco TileMapLayer:

| Capa | Muestras colocadas |
| --- | --- |
| Capa 1 Pared | Farol, escalera, horquilla y escoba. |
| Capa 2 Paja | Fardo y saco de grano. |
| Capa 3 Madera | Barril y caja. |
| Capa 4 Equipo | Carro y comedero. |
| Capa 5 Detalles | Cubo y cuerda. |

Selecciona cualquiera de estas capas y abre **TileMap → Patrones**. Las cinco comparten las doce plantillas completas; puedes colocar cualquier objeto en cualquiera de ellas. Pinta con el botón izquierdo, borra con el derecho y ajusta **Ordering → Z Index** para cambiar qué capa queda delante. Los valores iniciales van de -5 a -1, por encima del fondo y detrás de los héroes. Las muestras son decoración sin colisiones y puedes borrarlas o moverlas.

Cada objeto tiene una imagen PNG transparente de **48 × 48 píxeles**, igual que cada fotograma de `mago_idle.png`, y se coloca con escala **1 × 1**. Los contornos son finos y de color. La cuadrícula es de **8 × 8**, y cada plantilla completa ocupa **6 × 6 celdas**; el objeto visible puede ser menor por el margen transparente.

Las doce piezas son: **Fardo Paja**, **Saco Grano**, **Barril**, **Caja Madera**, **Carro**, **Comedero**, **Cubo**, **Horquilla**, **Escoba**, **Cuerda**, **Farol** y **Escalera**.

Todos los PNG y el recurso `plantillas_decoracion.tres` están en `assets/art/fondos/granero_tutorial/decoracion/`. `decoracion_48.png` reúne las doce piezas en una lámina de 192 × 144; `decoracion_original.png` es la salida original de ImageGen integrado. El prompt está en `prompt.txt`. Se usó `mago_idle.png` como referencia de escala y paleta; las piezas se prepararon con vecino más cercano y se separaron sin añadir contornos.

No se generan elementos visuales por código durante el juego. Las cinco capas, sus posiciones, texturas y patrones están guardados en la escena y el recurso, y se pueden editar sin ejecutar.
