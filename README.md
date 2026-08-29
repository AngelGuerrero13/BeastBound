<div align="center">

# BeastBound
> **Un proyecto desarrollado por Sixglitch**

*Un juego Beat 'em up cooperativo donde un grupo de héroes avanza por niveles lineales enfrentando oleadas de enemigos. El enfoque principal está en la recolección de recompensas aleatorias para fortalecer a los personajes antes de enfrentarse a los jefes de cada escenario.*

</div>

---

## 📖 Historia
En un mundo pacífico, una aldea de animales antropomórficos es atacada por humanos, quienes secuestran a sus habitantes para llevarlos a la gran ciudad, domesticarlos y comercializarlos como mascotas. Un grupo de héroes decide infiltrarse en el territorio humano para rescatar a su pueblo y su rey. 

A lo largo de los escenarios, deben asaltar diversas tiendas de mascotas urbanas enfrentándose a cuidadores, guardias y animales no antropomórficos entrenados. La misión culmina en el rescate de su rey, un espécimen exótico y altamente cotizado. La narrativa cuenta con variaciones en el desenlace final según la cantidad total de aldeanos que el equipo logre salvar en los tramos de escape de los minijuegos.

## ⚙️ Mecanismo
El juego se estructura mediante niveles lineales con desplazamiento lateral y profundidad en 2.5D, simulando pasillos, calles y tiendas de mascotas urbanas. El avance se gestiona por tramos cerrados donde la pantalla se bloquea temporalmente hasta derrotar a las oleadas de enemigos comunes y sub-jefes más resistentes. 

El sistema ajusta dinámicamente la dificultad (densidad de enemigos y presencia de armas) según la cantidad de jugadores activos. Al final de cada nivel, tras derrotar a los captores y alcanzar al grupo de aldeanos enjaulados, se activa un evento especial de rescate: una ruleta selecciona aleatoriamente a un único integrante para ejecutar un minijuego de escape o escolta. Si el jugador completa la prueba, los aldeanos se salvan; si falla, ese grupo se pierde, impactando directamente el final de la historia.

## 🎮 Jugabilidad
Combate cooperativo en tiempo real enfocado en la coordinación y la distribución del espacio en pantalla. Los jugadores deben gestionar a los rivales combinando ataques directos, control del eje vertical y uso de armas recogidas del entorno para enfrentar a enemigos básicos y oponentes acorazados. La experiencia premia la sinergia del equipo, obligando a los integrantes a cubrirse mutuamente las espaldas, priorizar objetivos peligrosos y comunicarse constantemente, tanto en peleas intensas como en las pruebas individuales.

## 📈 Sistemas de Progresión
El sistema combina personalización por capas al inicio con una progresión táctica durante la partida:

* **Personalización y arquetipo inicial:** Al comenzar, el jugador selecciona el tipo de personaje (animal antropomórfico) que cuenta con una clase unica (Tanque,Guerrero,Luchador,Asesino,Tirador,Mago).
* **Orbes de poder exclusivos:** Al derrotar sub-jefes, estos sueltan orbes elementales o de soporte (ej. curación). Solo un jugador puede recogerlo, distribuyendo responsabilidades clave. Los efectos se adaptan y canalizan según el tipo de arma que porte el personaje.
* **Economía y encantamiento de armas:** Objetos y habilidades secundarias pueden venderse por piedras especiales de mejora. Mediante encantamiento progresivo, estas piedras permiten subir de nivel y otorgar efectos adicionales al arma principal a lo largo de la aventura.

## ⌨️ Controles
El esquema de control está diseñado para ser directo pero con capas de habilidad técnica, adaptable tanto a teclado como a mando:

| Acción | Input / Botón | Descripción |
| :--- | :--- | :--- |
| **Movimiento** | Direccional | Control en 8 direcciones (arriba, abajo, izquierda, derecha y diagonales combinando dos). |
| **Acción 1** | Ataque Principal / Arma | Ejecuta el combo básico. Al mejorar el arma, permite combos rápidos (pulsaciones) o ataques cargados (mantener presionado). |
| **Acción 2** | Ataque Especial Cargado | Desata una habilidad potente del arma que se carga al conectar golpes básicos. |
| **Acción 3 y 4**| Habilidades / Orbes | Ranuras secundarias asignadas para activar los poderes y efectos de los orbes recolectados. |

## 👥 Multijugador Cooperativo
Modalidad local en pantalla compartida, diseñado para jugarse en solitario o en grupos de hasta 2 integrantes (con base técnica escalable para 4 jugadores en futuras actualizaciones). 

**Mecánica de Reanimación:** Si un jugador cae en combate, la batalla continúa y se inicia un temporizador de cuenta regresiva (ej. 15 segundos). Los compañeros restantes deben acercarse al cuerpo y utilizar un ítem de reanimación obligatorio, lo cual congela brevemente el entorno para completar el rescate. Si el tiempo expira sin reanimarlo, el jugador muere definitivamente, provocando la derrota del equipo entero.

## 🏆 Condiciones de Victoria y Derrota
* **Victoria:** Superar todos los escenarios, vencer a los jefes de cada tienda y derrotar al jefe final para liberar al rey. El resultado variará entre un *final perfecto* (todos los aldeanos rescatados) o un *final agridulce* (si algunos grupos se perdieron).
* **Derrota:** Quedarse sin vida todo el grupo o no lograr reanimar a un compañero caído antes de que finalice la cuenta regresiva. Obliga a reiniciar desde el último punto de control (checkpoint) o repetir el nivel completo.

---

<div align="center">

*Equipo Sixglitch: Javiera Maluenda | Jorge Muñoz | Priscilla Álvarez | Constanza Araya | Ángel Guerrero | Renato Martínez*

</div>

