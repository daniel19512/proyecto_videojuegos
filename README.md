# RPG Medieval — Simulador de Vida

**Un mundo de fantasía medieval donde la vida cotidiana es la aventura.**

> **Estado:** En desarrollo · Proyecto académico · Godot 4.7.2

Este proyecto es un **RPG de simulación de vida** ambientado en una aldea medieval de fantasía. En lugar de centrarse en el combate, da protagonismo a la exploración, los oficios, las relaciones entre habitantes y las pequeñas historias que surgen de la vida en comunidad.

El juego combina **escenarios completamente 3D** con **personajes 2D de pixel art**, vistos mediante una cámara ortográfica inclinada. Sus aldeanos pueden estar controlados por un **modelo de lenguaje**: conversan contigo, recuerdan lo que haces, deciden qué hacer durante el día, hablan entre ellos y, entre todos, dan forma a la historia.

## La experiencia que queremos crear

Imagina llegar a una aldea donde cada habitante tiene su propia rutina, sus intereses y sus relaciones. Podrás conocer a tus vecinos, aprender oficios, participar en actividades cotidianas y descubrir cómo evoluciona la comunidad con el paso del tiempo.

La propuesta se apoya en cuatro pilares:

- **Exploración tranquila:** recorrer la aldea, sus interiores y las regiones que la rodean.
- **Vida social:** NPCs con personalidad, memoria, rutinas y conversaciones propias.
- **Oficios y actividades:** minijuegos de pesca, cerveza, pan y forja.
- **Un mundo con identidad:** plaza, taberna, panadería, herrería, molino, mercado, huertos y naturaleza que tienen sentido para sus habitantes.

## Qué hay ya en el juego

| Implementado | Planeado |
| --- | --- |
| Aldea de 12 edificios con interiores visitables (E01–E11) | Cambio de luz según la hora del día |
| Cinco regiones conectadas: bosque, campos y granjas, montañas, minas y ruinas | Profesiones con progreso, inventario y recompensas |
| Río con agua animada, puente y molino con rueda | Misiones y eventos más elaborados |
| Protagonista 2D con movimiento relativo a la cámara y cámara orbital 360° | Más aldeanos y oficios |
| Cinco aldeanos con sprites propios: Tomás, Marta, Gonzalo, Anselmo y Bruno | Persistencia del estado de las regiones |
| Cuatro minijuegos con sonido: pesca, cerveza, pan y forja | |
| **NPCs con IA:** conversación libre, memoria, narrador, diario, acciones autónomas y conversaciones entre aldeanos | |

El avance detallado está en [Estado del proyecto](RPG/docs/estado_proyecto.md).

## Controles

| Acción | Teclado | Mando |
| --- | --- | --- |
| Moverse | WASD o flechas | Stick izquierdo |
| Girar la cámara | Q / E | Stick derecho |
| Hablar, entrar, jugar | F | A |
| Diario de la historia | J | — |
| Menú de pausa y opciones | Esc | — |

## Aldeanos con IA

Con una clave de [OpenRouter](https://openrouter.ai/), los aldeanos dejan de usar diálogos fijos:

- **Conversan contigo:** responden en personaje, te proponen 2-3 respuestas y también puedes escribir la tuya. Recuerdan lo que has hecho, incluidas tus partidas de pesca.
- **Un narrador invisible da forma a la historia:** a partir de lo que pasa, actualiza los asuntos abiertos, orienta a cada aldeano y escribe en tu **diario** (tecla J).
- **Viven su día:** un día de juego dura 12 minutos en cuatro franjas. En cada una deciden qué hacer (trabajar, ir a la plaza o al molino, visitar a un vecino, buscarte para contarte algo…) y caminan por la aldea.
- **Hablan entre ellos:** si estás cerca lo verás en bocadillos sobre sus cabezas. Lo que se cuentan circula como rumores que luego te mencionan.

**Cómo activarlo:** pulsa **Esc → Opciones de IA**, pega tu clave, pulsa «Probar conexión» y «Guardar y volver».

- La clave se guarda **solo en tu equipo** (`user://ia.cfg`, en la carpeta de datos de Godot), nunca en el repositorio.
- Modelo por defecto: `z-ai/glm-5.3-flash`, cambiable en el mismo menú. Cuesta del orden de 0,0002 USD por conversación o plan.
- Hay un **tope de tokens por sesión** (200.000 por defecto) y el menú muestra el gasto. Al alcanzarlo, o sin clave ni conexión, los aldeanos vuelven a sus diálogos y rutinas fijos.
- La historia se guarda entre sesiones (`user://historia.json`). «Nueva historia» la reinicia.
- La premisa, las fichas de los aldeanos y los lugares a los que pueden ir se editan sin tocar código en `RPG/data/historia/`.

## Dirección artística

El proyecto utiliza una estética **medieval fantástica, cálida y estilizada**, con arquitectura de madera y piedra, vegetación colorida y espacios diseñados para sentirse habitados.

La combinación de **personajes pixel art en escenarios 3D** conserva el encanto de los RPG clásicos mientras aprovecha la profundidad, iluminación y composición espacial de un entorno tridimensional.

## Tecnologías

| Tecnología | Uso |
| --- | --- |
| **Godot 4.7.2** | Motor del videojuego |
| **GDScript** | Lógica de juego |
| **Forward Plus / Jolt Physics** | Renderizado 3D y colisiones |
| **AnimatedSprite3D** | Personajes 2D dentro del mundo 3D |
| **glTF / GLB / FBX** | Modelos 3D modulares |
| **OpenRouter** | Modelo de lenguaje de los aldeanos (salida JSON estructurada, llamada directa desde Godot) |
| **AStarGrid2D** | Rutas de los aldeanos por la aldea |

## Estructura del repositorio

```text
.
├── AGENTS.md                 # Instrucciones y decisiones técnicas para agentes
├── README.md
└── RPG/                      # Proyecto Godot
    ├── assets/               # Modelos, texturas, sprites y sonidos
    ├── data/historia/        # Premisa, aldeanos y lugares de la historia (editables)
    ├── docs/                 # Estado, inventario de assets, planos e interiores
    ├── scenes/               # Mundo, regiones, interiores, NPCs y minijuegos
    ├── scripts/
    │   ├── ia/               # Cliente OpenRouter, historia, narrador, reloj, aldeanos, diario y menú
    │   ├── minijuegos/       # Cerveza, pan, forja y base común
    │   ├── npc/              # Aldeanos, patrulla y pescador
    │   └── pesca/            # Minijuego de pesca
    ├── tests/                # Validaciones automáticas
    └── project.godot
```

La escena principal es `RPG/scenes/mundo.tscn`.

## Cómo abrir el proyecto

1. Instala **Godot 4.7.2**.
2. Clona o descarga este repositorio.
3. En Godot, selecciona **Import** y elige `RPG/project.godot`.
4. Espera a que termine la importación inicial de recursos y ejecuta el proyecto (F5).

Los recursos gráficos y de sonido están incluidos en `RPG/assets/`. El juego funciona sin clave de OpenRouter, con diálogos fijos.

## Pruebas

Las validaciones están en `RPG/tests/` y se ejecutan sin ventana desde la raíz del repositorio, por ejemplo:

```text
godot --headless --path RPG --log-file logs/validar_ia_capa1.log --script res://tests/validar_ia_capa1.gd
```

Las pruebas de IA usan un simulador y **nunca llaman a la red** ni tocan tu partida guardada. Los registros se guardan en `RPG/logs/` (excluida de Git).

## Recursos de terceros

- [Quaternius](https://quaternius.com/): Medieval Village MegaKit, Stylized Nature MegaKit, Fantasy Props MegaKit y Farm Animals Pack.
- [KayKit](https://kaylousberg.com/) Forest Nature Pack (CC0) y Forest Nature Updated: vegetación del bosque.
- Avramania: Interiors Furniture, Food & Market, Props Tools & Fencing y Farm & Harvest; LowPolyBlacksmithPack; medv-cafe (taberna).
- [Kenney](https://kenney.nl/): Interface Sounds, Impact Sounds y RPG Audio (CC0), sonidos de los minijuegos.
- **Ventilatore — The Fantasy Tileset / Animated Character:** sprites del protagonista. Los sprites de los aldeanos se generaron para el proyecto.

Los recursos pertenecen a sus respectivos autores y están sujetos a sus propias condiciones de uso. **Algunas licencias tienen restricciones o están pendientes de verificar** (por ejemplo, Forest Nature Updated no permite redistribuir sus archivos originales y la licencia de medv-cafe no se ha localizado). El detalle está en el [Inventario de assets](RPG/docs/inventario_assets.md) y en la [integración de interiores](RPG/docs/integracion_assets_interiores.md).

## Documentación del desarrollo

- [Estado del proyecto](RPG/docs/estado_proyecto.md): funcionalidades, pruebas, limitaciones y próximos pasos.
- [Inventario de assets](RPG/docs/inventario_assets.md): recursos disponibles, licencias y comprobaciones.
- [Interiores de la aldea](RPG/docs/interiores_aldea.md) y [transiciones regionales](RPG/docs/transiciones_regionales.md).
- [AGENTS.md](AGENTS.md): arquitectura, convenciones y reglas de trabajo.

## Sobre el proyecto

Este videojuego nace como un **proyecto académico** y se desarrolla por capas: primero una base jugable estable, después una aldea y unas regiones más completas y, ahora, unos habitantes que viven, conversan y cuentan su propia historia.

**La meta es crear un pequeño mundo medieval que se sienta vivo, incluso cuando el jugador simplemente decide pasear por sus calles.**
