# RPG Medieval — Simulador de Vida

**Un mundo de fantasía medieval donde la vida cotidiana es la aventura.**

> **Estado:** En desarrollo · Proyecto académico · Godot 4.7.2

Este proyecto es un **RPG de simulación de vida** ambientado en una aldea medieval de fantasía. En lugar de centrarse en el combate tradicional, busca dar protagonismo a la exploración, los oficios, las relaciones entre habitantes y las pequeñas historias que surgen de la vida en comunidad.

El juego combina **escenarios completamente 3D** con **personajes 2D de pixel art**, vistos mediante una cámara ortográfica inclinada. Actualmente estamos construyendo la base jugable y el entorno de la aldea; los sistemas sociales y de simulación forman parte de la visión futura.

## La experiencia que queremos crear

Imagina llegar a una aldea donde cada habitante tenga su propia rutina, sus intereses y sus relaciones. Podrás conocer a sus vecinos, aprender profesiones, participar en actividades cotidianas y descubrir cómo evoluciona la comunidad con el paso del tiempo.

La propuesta se apoya en cuatro pilares:

- **Exploración tranquila:** recorrer aldeas, caminos y entornos medievales.
- **Vida social:** interactuar con NPCs que, en futuras etapas, tendrán personalidad, memoria, rutinas y relaciones.
- **Oficios y actividades:** desarrollar profesiones como herrería y agricultura mediante sistemas y minijuegos propios.
- **Un mundo con identidad:** construir espacios reconocibles —plaza, taberna, herrería, viviendas, mercado y naturaleza— que tengan sentido para sus habitantes.

Estas son **metas de diseño**, no una lista de funciones ya disponibles.

## Estado actual del desarrollo

| Implementado | Planeado |
| --- | --- |
| Mundo 3D con iluminación y ambiente | NPCs con rutinas, personalidad y memoria |
| Protagonista 2D integrado mediante `AnimatedSprite3D` | Diálogos, vínculos y relaciones sociales |
| Movimiento relativo a la cámara, aceleración y frenado | Profesiones y minijuegos |
| Animaciones de reposo y caminata en cuatro direcciones | Misiones y eventos dinámicos |
| Cámara ortográfica inclinada con seguimiento suave | Ampliación de la aldea y nuevos escenarios |
| Colisiones básicas del personaje y la aldea | Río, puente, molino, huertos y zonas naturales |
| Aldea modular inicial con plaza, caminos y edificios | Sistemas de simulación de vida |

**Próximo objetivo:** probar visualmente los nuevos paquetes de modelos, validar escalas y colisiones, y ampliar progresivamente la aldea a partir de una referencia artística.

El avance detallado se encuentra en [Estado del proyecto](RPG/docs/estado_proyecto.md).

## Dirección artística

El proyecto utiliza una estética **medieval fantástica, cálida y estilizada**, con arquitectura de madera y piedra, vegetación colorida y espacios diseñados para sentirse habitados.

La combinación de **personajes pixel art en escenarios 3D** permite conservar el encanto de los RPG clásicos mientras aprovechamos la profundidad, iluminación y composición espacial de un entorno tridimensional.

La aldea se construye con piezas modulares para poder ajustar su distribución, añadir colisiones y preparar futuros recorridos e interacciones de los NPCs.

## Tecnologías

| Tecnología | Uso |
| --- | --- |
| **Godot 4.7.2** | Motor del videojuego |
| **GDScript** | Lógica de juego y comportamiento |
| **Forward Plus** | Renderizado 3D |
| **Jolt Physics** | Física y colisiones 3D |
| **AnimatedSprite3D** | Personajes 2D dentro del mundo 3D |
| **glTF** | Modelos 3D modulares y recursos visuales |

## Estructura del repositorio

```text
.
├── AGENTS.md                 # Instrucciones para agentes de desarrollo
├── README.md
└── RPG/                      # Proyecto Godot
    ├── assets/               # Recursos locales (excluidos de Git)
    ├── docs/
    │   ├── estado_proyecto.md
    │   └── inventario_assets.md
    ├── scenes/               # Escenas y recursos visuales
    ├── scripts/              # Lógica en GDScript
    ├── tests/                # Validaciones del escenario
    └── project.godot
```

La escena principal es `RPG/scenes/mundo.tscn`. El personaje, la cámara y la aldea se mantienen organizados en escenas y scripts separados.

## Cómo abrir el proyecto

1. Instala **Godot 4.7.2**.
2. Clona o descarga este repositorio.
3. Abre Godot y selecciona **Import**.
4. Elige `RPG/project.godot`.
5. Una vez disponibles los recursos gráficos locales, espera a que Godot termine de importarlos y ejecuta la escena principal.

### Importante: recursos gráficos no incluidos

**La carpeta `RPG/assets/` está excluida de Git intencionalmente.** Por tanto, clonar este repositorio **no basta para ejecutar correctamente el videojuego**: faltarán modelos, texturas y sprites hasta que se incorporen localmente con la estructura esperada.

La documentación de recursos está en [Inventario de assets](RPG/docs/inventario_assets.md). El proyecto no incluye un instalador ni un paquete independiente listo para jugar.

## Recursos artísticos

La base visual utiliza paquetes de terceros, entre ellos:

- [Quaternius — Medieval Village MegaKit](https://quaternius.com/packs/medievalvillagemegakit.html): arquitectura medieval modular.
- [Quaternius — Stylized Nature MegaKit](https://quaternius.com/packs/stylizednaturemegakit.html): árboles, arbustos, flores y rocas.
- [Quaternius — Fantasy Props MegaKit](https://quaternius.com/packs/fantasypropsmegakit.html): mobiliario, herramientas y objetos decorativos.
- **Ventilatore — The Fantasy Tileset / Animated Character:** sprites del protagonista.

Los recursos originales pertenecen a sus respectivos autores y están sujetos a sus propias condiciones de uso. No se redistribuyen en este repositorio.

El inventario local actual registra **338 modelos 3D** entre los tres paquetes de Quaternius. Que un modelo esté disponible no significa que ya esté integrado en el escenario.

## Documentación del desarrollo

- [Estado del proyecto](RPG/docs/estado_proyecto.md): funcionalidades, limitaciones y próximos pasos.
- [Inventario de assets](RPG/docs/inventario_assets.md): recursos 3D disponibles y comprobaciones de importación.
- [AGENTS.md](AGENTS.md): convenciones técnicas y reglas de trabajo para agentes de programación.

## Sobre el proyecto

Este videojuego nace como un **proyecto académico** y se desarrolla de forma incremental: primero una base jugable estable, después una aldea más completa y, posteriormente, los sistemas de interacción y simulación social.

**La meta es crear un pequeño mundo medieval que se sienta vivo, incluso cuando el jugador simplemente decide pasear por sus calles.**
