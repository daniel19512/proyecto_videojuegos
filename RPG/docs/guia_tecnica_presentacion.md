# Guía técnica para la presentación del RPG

Revisión de la copia local: **9 de noviembre de 2026**.

Esta guía se basa en la lectura de configuración, scripts, escenas y documentación. Es una **revisión estática**: no se ejecutó Godot ni se realizó una prueba visual o jugable durante esta tarea. Las pruebas citadas existen, pero no se presentan como aprobadas en esta sesión.

**Precaución con las fuentes:** `AGENTS.md` y `RPG/docs/estado_proyecto.md` contienen marcas de conflicto y descripciones contradictorias. El README también presenta como futuros elementos ya construidos. Para determinar qué existe se priorizaron los archivos del juego, incluidos archivos locales todavía no versionados. No se corrigieron esas inconsistencias porque la tarea solo autoriza crear esta guía.

## A. Descripción general del proyecto

Es un RPG medieval de fantasía orientado a exploración y futura simulación de vida. Actualmente tiene seis regiones conectadas, movimiento del protagonista, cámara orbital y un minijuego de pesca. Las relaciones sociales, profesiones y misiones siguen siendo objetivos futuros.

El motor objetivo documentado es **Godot 4.7.2**. `RPG/project.godot` declara características **4.7**, renderizado **Forward Plus**, controlador Windows **D3D12** y física 3D **Jolt Physics**; no fija el parche exacto. La lógica utiliza **GDScript** y los materiales especiales emplean el lenguaje de shaders de Godot.

Los escenarios son tridimensionales low-poly y el protagonista se representa con pixel art mediante `AnimatedSprite3D`. Su imagen es 2D, pero su cuerpo y movimiento son 3D. La cámara ortográfica inclinada conserva una lectura uniforme de escala y puede orbitar horizontalmente.

Las regiones identificadas son **Aldea, Bosque, Ruinas, Campos y Granjas, Montañas y Minas**. Cada entorno se guarda en una escena; una escena envolvente incorpora jugador, cámara y configuración regional. La escena inicial es `RPG/scenes/mundo.tscn`, cuyo UID coincide con `run/main_scene`.

**Cómo explicarlo durante la presentación:** «Combinamos escenarios 3D con un protagonista de sprites 2D. Godot resuelve renderizado y física, y los scripts controlan movimiento, cámara, cambios de región y pesca. La base permite explorar seis regiones conectadas. Los espacios de oficios están construidos, pero la simulación social y las profesiones todavía están pendientes».

## B. Organización de carpetas y archivos

Las rutas parten de la raíz del repositorio. En Godot, `res://` corresponde a `RPG/`: `res://scenes/jugador.tscn` equivale a `RPG/scenes/jugador.tscn`.

| Carpeta o archivo | Para qué sirve |
|---|---|
| `AGENTS.md` | Reglas de trabajo y decisiones técnicas; contiene conflictos documentales pendientes. |
| `README.md` | Presentación pública; su progreso no refleja todo el contenido local. |
| `RPG/project.godot` | Configuración, escena inicial, Autoload y controles. |
| `RPG/assets/` | Modelos, texturas y sprites originales locales. |
| `RPG/scenes/` | Escenas `.tscn`, animaciones `.tres` y recursos de terreno/colisión `.res`. |
| `RPG/scenes/recursos/` | Materiales reutilizables para parches de suelo. |
| `RPG/scenes/respaldos/` | Composición anterior de aldea y mundo, independiente del escenario actual. |
| `RPG/scripts/` | Controladores y shaders del juego. |
| `RPG/scripts/editor/` | Herramientas opcionales que construyen y guardan escenarios antes de jugar. |
| `RPG/scripts/pesca/` | Detección de interacción, reglas e interfaz de pesca. |
| `RPG/tests/` | Validadores, capturadores y herramientas de auditoría. |
| `RPG/docs/` | Estado, inventario, planos regionales y explicaciones técnicas. |
| `RPG/logs/` | Registros y evidencias temporales, excluidos de Git. |
| `RPG/docs/inventario_assets.md` | Procedencia y características de recursos; no es un inventario jugable. |
| `RPG/docs/transiciones_regionales.md` | Explicación específica de conexiones regionales. |

Un **nodo** cumple una responsabilidad: dibujar una malla, mover un cuerpo, detectar cercanía o iluminar. Una **escena** guarda un árbol de nodos reutilizable. Instanciar `jugador.tscn` permite emplear el mismo protagonista en todas las regiones.

## C. Sistema del personaje

**¿Qué hace?** Mueve al protagonista, aplica gravedad, resuelve colisiones y reproduce reposo/caminata en cuatro direcciones de pantalla.

**¿Dónde está implementado?**

| Archivo | Responsabilidad |
|---|---|
| `RPG/scenes/jugador.tscn` | Cuerpo físico, cápsula y sprite. |
| `RPG/scripts/jugador.gd` | Entrada, velocidad, gravedad y selección de animación. |
| `RPG/scenes/jugador_frames.tres` | Recurso `SpriteFrames` con ocho animaciones. |
| `RPG/project.godot` | Acciones de movimiento. |

La raíz `Jugador` es `CharacterBody3D`. Tiene `ColisionJugador` y `Visual/SpriteAnimado`. La cápsula mide 0,32 de radio y 1,6 de altura; está elevada 0,8 para apoyar los pies en el origen. `floor_snap_length = 0.2` ayuda a mantener contacto al bajar pendientes.

**¿Cómo funciona?**

1. `_physics_process(delta)` lee `Input.get_vector()` con `mover_izquierda`, `mover_derecha`, `mover_arriba` y `mover_abajo`. Las acciones admiten WASD, flechas y stick izquierdo, con zona muerta 0,20.
2. Obtiene los ejes X/Z de la cámara activa, elimina Y y los normaliza. Con ellos convierte entrada de pantalla en dirección del mundo. Sin cámara válida usa los ejes globales.
3. Normaliza la dirección final para evitar mayor rapidez diagonal. Particularidad: también hace que una entrada analógica parcial no module la rapidez objetivo una vez superada la zona muerta.
4. `velocidad` vale **10**, temporal para exploración según el comentario del script; la base original anotada es 4. `aceleracion = 18` y `desaceleracion = 24` aproximan progresivamente la velocidad horizontal al objetivo mediante `move_toward()`.
5. Aplica `get_gravity()` cuando no está apoyado; en suelo pone la velocidad vertical a cero. `move_and_slide()` desplaza el cuerpo y resuelve deslizamiento contra superficies.
6. `_actualizar_direccion_visual()` elige el eje dominante de entrada. `_actualizar_animacion()` compone nombres como `walk_arriba` o `idle_derecha`. `en_movimiento` usa un umbral de velocidad horizontal de 0,05 y al detenerse conserva la última orientación.

`delta` representa el tiempo transcurrido y adapta aceleración/gravedad al paso de simulación. No hay salto ni rotación del cuerpo para cambiar de orientación.

El sprite usa `pixel_size = 0.045`, filtrado nearest, transparencia, dos caras y `shaded = false`. Su **Y-billboard** gira la imagen alrededor del eje vertical hacia la cámara. Las hojas PNG se subdividen mediante texturas de atlas en `SpriteFrames`; no hay una malla animada del protagonista.

**Cómo explicarlo durante la presentación:** «Separamos el cuerpo físico y el sprite. Leemos acciones y calculamos el desplazamiento con la orientación de la cámara. Aplicamos aceleración, frenado y gravedad y utilizamos `move_and_slide()` para las colisiones. Elegimos la animación según el movimiento visto en pantalla».

## D. Sistema de cámara

**¿Qué hace?** Sigue suavemente al protagonista y permite observar el escenario desde cualquier orientación horizontal.

**¿Dónde está implementado?** `RPG/scripts/camara_orbital.gd` hereda de `RPG/scripts/camara_seguimiento.gd`. Se asigna a `CamaraPrincipal`, un `Camera3D` de las escenas jugables. `RPG/scenes/mundo_bosque.tscn` hereda la base de `RPG/scenes/pruebas_bosque.tscn`.

**¿Cómo funciona?** No necesita un brazo o pivote físico adicional: el script mueve directamente la cámara. La referencia exportada `objetivo` apunta al jugador. Los mundos usan proyección ortográfica y tamaño **15**; los scripts no sobrescriben ese tamaño.

El script base proporciona `desplazamiento = Vector3(0, 13.8, 20.80435)`, `altura_encuadre = 0.8` y `suavizado = 6`. La órbita lee Q/E o stick derecho X con `Input.get_axis()`, a **75°/s**. Envuelve `angulo_horizontal` entre −PI y PI y suaviza `centro_seguimiento` con interpolación exponencial. `actualizar_orbita()` rota el desplazamiento alrededor de Y y usa `look_at()` hacia el centro elevado.

La vista está inclinada aproximadamente 32° bajo la horizontal, con el ajuste de encuadre. El jugador consulta los ejes de esta cámara en física, por lo que sus controles se mantienen relativos a pantalla aunque cambie la órbita.

No hay zoom dinámico, inclinación controlable ni colisión física de cámara contra paredes. `_exit_tree()` libera estados de entrada sin borrar acciones. El laboratorio `RPG/scenes/pruebas_assets.tscn` conserva su selector 23/19/17/15 y el adaptador `RPG/scripts/camara_orbital_assets.gd`; no cambia los mundos.

**Cómo explicarlo durante la presentación:** «La cámara sigue un centro suavizado y orbita alrededor del eje vertical. Q y E cambian su ángulo manteniendo la distancia. El personaje utiliza sus ejes horizontales para que los controles sigan siendo coherentes. El tamaño ortográfico permanece fijo en 15 durante la exploración».

## E. Construcción de los mundos

### Principio común: autoría y ejecución

Las herramientas de `RPG/scripts/editor/` calculan geometría, colocan instancias y guardan escenas/recursos. Es **autoría previa**, no generación continua al jugar. Varias usan semillas fijas para repetir distribuciones.

`SurfaceTool` construye triángulos y normales. `create_trimesh_shape()` obtiene una forma física de una malla. `MultiMeshInstance3D` representa muchas copias visuales de una malla; no crea colisiones por sí mismo. Los metadatos de caminos y reservas describen el plano y ayudan a validarlo, pero no son navegación de NPCs.

### E.1. Aldea

**Archivos:** `RPG/scenes/mundo.tscn` compone el mundo y `RPG/scenes/aldea.tscn` el entorno. `RPG/scripts/mundo.gd` solo imprime mensajes. Plano: `RPG/docs/plano_aldea.md`.

- **Terreno y caminos:** suelo continuo **80×72**, plaza **20×18** y 36 corredores con ejes/anchuras en metadatos. `RPG/scripts/terreno_aldea.gd`, en `AcabadoTerreno`, crea al cargar una máscara **800×720**. `RPG/scripts/terreno_aldea.gdshader` mezcla hierba, tierra y explanada sobre el suelo original sin añadir relieve ni colisiones.
- **Edificios:** doce parcelas construidas con escenas propias, entre ellas `RPG/scenes/taberna.tscn`, `herreria.tscn`, `carpinteria.tscn`, `panaderia.tscn`, `herbolario.tscn` y `molino.tscn`, además de viviendas. Combinan módulos de `RPG/assets/aldea/` y utilería de `RPG/assets/objetos_medievales/`.
- **Decoración:** huertos, jardín, mirador, mercado y plaza se guardan por separado. `RPG/scenes/vegetacion_aldea.tscn` contiene vegetación colocada y formas de tronco; las plantas menores son visuales. `RPG/scripts/depuracion_parcelas.gd` oculta bordes de desarrollo durante el juego conservando sus datos.
- **Agua y alturas:** `RPG/scenes/rio.tscn` añade agua y orillas sobre el suelo continuo, sin excavar físicamente. `RPG/scripts/agua_estilizada.gdshader` anima la apariencia. `RPG/scenes/puente.tscn` aporta tablero elevado y rampas. `RPG/scripts/rueda_hidraulica.gd` gira el pivote de rueda sobre X a −9°/s; no calcula hidráulica.
- **Colisiones:** suelo y cuatro límites sólidos, muros perimetrales y puertas cerradas en edificios, obstáculos propios y barreras de río. El agua solo se cruza por el puente; no se permite rodear los extremos. Una reserva de parcela no equivale a una caja física completa.

**Cómo explicarlo durante la presentación:** «La aldea se construye modularmente sobre un suelo plano continuo. El material del terreno dibuja los caminos a partir de los corredores del plano. Los edificios y el puente tienen colisiones independientes de su imagen. El río y la rueda se animan visualmente y las barreras determinan por dónde se puede caminar».

### E.2. Bosque

**Archivos:** `RPG/scenes/bosque.tscn`, `RPG/scenes/mundo_bosque.tscn` y las herramientas `RPG/scripts/editor/construir_bosque.gd`, `construir_vegetacion_bosque.gd` y `construir_laguna_bosque.gd`. Detalles en `RPG/docs/plano_bosque.md`, `vegetacion_bosque.md` y `laguna_bosque.md`.

- **Terreno:** región **100×100**, con `RPG/scenes/bosque_terreno.res` y `bosque_colision.res`. `altura()` combina ondulaciones, elevaciones localizadas y mezclas para apoyar reservas. La geometría física base deriva de la malla.
- **Caminos:** siete rutas, principales de anchura 3,6 y secundarias de 2,6. `curva()` utiliza `Curve3D` y conserva puntos horneados. Los colores de vértice codifican caminos y reservas; `RPG/scripts/terreno_bosque.gdshader` produce el acabado.
- **Vegetación:** `RPG/scenes/vegetacion_bosque.tscn` y `vegetacion_bosque_datos.json` conservan distribución y datos. La herramienta excluye senderos/reservas y ajusta apoyos. Utiliza árboles, rocas, arbustos y plantas de KayKit, Forest Nature Updated y paquetes anteriores; parte del detalle usa MultiMesh.
- **Laguna:** `RPG/scenes/laguna_bosque.tscn` contiene agua visible a Y=−0,12, `RPG/scripts/agua_laguna.gdshader`, decoración ribereña y nenúfares geométricos propios. **La depresión es visual en el shader del terreno; la colisión original no se excava.** El interior permanece físicamente inaccesible.
- **Seguridad y pendientes:** suelo triangulado, cierres exteriores, obstáculos simplificados y barrera alrededor de la laguna. Las plantas pequeñas no necesitan bloquear.
- **Pendiente:** el arroyo y sus `PuentePrevisto*` son reservas, no agua y puentes construidos. Los nombres de las seis reservas de interés tampoco acreditan actividades jugables.

**Cómo explicarlo durante la presentación:** «El bosque tiene relieve real y siete senderos conectados. La vegetación se distribuyó previamente respetando claros y pasos. La laguna tiene agua animada, pero su depresión es visual y su interior está cerrado. El arroyo y los puentes opcionales siguen siendo planificación».

### E.3. Ruinas antiguas

**Archivos:** `RPG/scenes/ruinas.tscn`, `RPG/scenes/mundo_ruinas.tscn`, `RPG/scripts/editor/construir_ruinas.gd`, `RPG/scripts/terreno_ruinas.gdshader` y `RPG/scripts/piedra_ruinas.gdshader`. Plano: `RPG/docs/plano_ruinas.md`.

- **Terreno y caminos:** suelo de caja **80×80**, límites estáticos y caminos de anchura lógica 4,5. El shader mezcla hierba/tierra; las referencias de caminos no colisionan.
- **Arquitectura:** columnas, muros rotos, losas, altar, bancos y santuario con geometría propia de cajas y cilindros facetados. Materiales procedurales y distribución irregular producen el aspecto antiguo.
- **Alturas:** suelo mayoritariamente plano, plataforma baja y rampa continua de acceso al santuario. Las losas pequeñas son visuales sobre el suelo continuo.
- **Decoración y colisiones:** árboles y rocas reutilizados de los paquetes forestales/naturales. Las piezas grandes tienen formas físicas propias; no toda la vegetación bloquea. No se identifica agua regional implementada.
- **Conexión:** llega desde Bosque; `RPG/scenes/acceso_ruinas_bosque.tscn` aporta vestigios al acceso forestal. El santuario no implementa puzles, enemigos o misiones.

**Cómo explicarlo durante la presentación:** «Las ruinas son una región independiente conectada al bosque. Su arquitectura se construye con geometría sencilla de Godot y recursos naturales reutilizados. El santuario tiene una rampa física y los caminos se representan con un shader. Actualmente es un escenario explorable sin puzles ni misiones».

### E.4. Campos y Granjas

**Archivos:** `RPG/scenes/campos_granjas.tscn`, `RPG/scenes/mundo_campos_granjas.tscn`, `RPG/scripts/editor/construir_campos_granjas.gd` y `RPG/scripts/terreno_campos.gdshader`. Plano: `RPG/docs/plano_campos_granjas.md`.

- **Terreno:** recinto **100×90**, con faldón paisajístico exterior. `altura()` mantiene planos caminos y apoyos domésticos y eleva suavemente la periferia. Malla/colisión se guardan en `RPG/scenes/campos_terreno.res` y `campos_colision.res`.
- **Caminos:** catorce ejes con puntos y anchuras. La herramienta pasa segmentos y patios al shader para que acabado y plano compartan los datos.
- **Contenido:** granero, tres viviendas, seis huertos, trigo, establo/cobertizo, almacén y dos corrales vacíos. Combina geometría propia, módulos medievales y recursos agrícolas de `RPG/assets/granja/Farm_Harvest/`.
- **Plantas:** cuatro MultiMesh representan trigo y otros cinco agrupan vegetación. La herramienta exige render real para guardar sus buffers; es una restricción de autoría, no generación al iniciar el juego.
- **Física y agua:** muros, cercas segmentadas, postes y objetos grandes tienen colisiones; no hay una por planta. Edificios cerrados sin interiores accesibles, con huecos reales en cobertizos/portones abiertos. Hay agua estática decorativa en un bebedero; no un río regional ni natación.
- **Límite funcional:** no hay animales integrados en la región, crecimiento de cultivos, cosecha o inventario.

**Cómo explicarlo durante la presentación:** «La región rural tiene edificios, huertos y cultivos sobre colinas suaves. Sus caminos se guardan como ejes que también alimentan el material del suelo. Agrupamos muchas plantas con MultiMesh. La ambientación agrícola está construida, pero cultivar o cuidar animales todavía no son mecánicas disponibles».

### E.5. Montañas

**Archivos:** `RPG/scenes/montanas.tscn`, `RPG/scenes/mundo_montanas.tscn`, `RPG/scripts/editor/construir_montanas.gd` y `RPG/scripts/agua_montanas.gdshader`. Plano: `RPG/docs/plano_montanas.md`.

- **Terreno:** recinto **130×130**, paisaje exterior hasta ±96, malla triangulada con normales por cara y colores de vértice. Recursos `RPG/scenes/montanas_terreno.res` y `montanas_colision.res`.
- **Alturas:** `altura()` combina gradiente, ondulaciones, crestas y mesetas. `camino_cercano()` mezcla cotas de tramos próximos para evitar costuras. Los ejes de caminos son 3D y sus pendientes permiten subir sin salto. Los puntos principales rondan Y=2…29; las grandes crestas del fondo no son todas accesibles.
- **Agua:** garganta y cubeta excavadas en geometría real. `rio_x()` define el cauce sinuoso y `agua_y()` interpola cotas descendentes. Tres caídas usan láminas inclinadas, espuma y material animado; no simulan fluidos.
- **Puentes y colisiones:** tres puentes con tablero y barandas físicas. Barreras de márgenes/lago impiden entrar a la garganta y se conservan límites exteriores sólidos.
- **Recursos:** pinos, rocas y plantas de `RPG/assets/naturaleza/`, utilería medieval y geometría propia para portal, puentes, raíles y construcciones. Las instancias se ajustan al relieve antes de guardar.
- **Conexiones:** Aldea por el oeste y Minas en el portal. Aunque el marcador se llame `ConexionMinasFutura`, la envolvente configura un detector activo hacia Minas.

**Cómo explicarlo durante la presentación:** «Montañas utiliza desniveles reales y una colisión derivada de su malla. Las rutas suavizan las pendientes para conservar el controlador del personaje. El río desciende por una garganta excavada y se cruza por tres puentes. Las cascadas combinan geometría y shaders, y el portal conecta con Minas».

### E.6. Minas

**Archivos:** `RPG/scenes/minas.tscn`, `RPG/scenes/mundo_minas.tscn`, `RPG/scripts/editor/construir_minas.gd`, `RPG/scripts/editor/minas_geometria.gd` y `RPG/scripts/minas_visibilidad.gd`. Materiales en `RPG/scripts/suelo_minas.gdshader`, `roca_minas.gdshader` y `agua_minas.gdshader`. Plano: `RPG/docs/plano_minas.md`.

- **Construcción:** salas elípticas y corredores se unen mediante celdas; `dentro()` decide la huella y `terreno()` triangula suelo, paredes y bóvedas. El resultado queda guardado en la escena.
- **Alturas/caminos:** niveles físicos **0, −4 y −12** unidos por rampas continuas. `altura(z)` define las cotas y `cota()` añade la depresión del estanque. Los ejes de `Recorridos` sirven de referencia para pruebas, no de navegación de NPCs.
- **Decoración:** extracción, depósito, ramal abandonado, caverna, raíles, vagoneta y minerales. Hay geometría propia y modelos reutilizados de roca, faroles, pico, barriles, cajas y sacos; ver un pico no implica poder minar.
- **Agua:** estanque a **−13,1**, fondo físicamente excavado hasta **−14,5**. Orillas/barandas cierran el fondo; pasarela y plataforma tienen colisiones propias. No hay natación.
- **Física:** suelo y paredes con colisiones cóncavas derivadas de geometría; obstáculos grandes con formas propias. Las bóvedas visuales carecen de colisión al estar fuera del alcance del personaje.
- **Visibilidad:** `minas_visibilidad.gd` pasa posiciones del jugador/cámara a materiales. `roca_minas.gdshader` descarta fragmentos de bóvedas próximas y de roca en la línea de visión. **El recorte no elimina colisiones** y es local a Minas. Ambiente tenue y luces locales completan la escena.

**Cómo explicarlo durante la presentación:** «Minas tiene tres niveles conectados por rampas y túneles con suelo y paredes físicos. El estanque también tiene una excavación real, protegida por barreras. Un shader recorta rocas y techos próximos para poder ver al protagonista. La exploración existe, pero la minería sigue siendo decorativa».

## F. Sistema de transiciones entre regiones

**¿Qué hace?** Sustituye una región por otra bajo un fundido y sitúa al jugador en una entrada explícita.

**¿Dónde está implementado?**

| Archivo | Responsabilidad |
|---|---|
| `RPG/project.godot` | Registra `GestorRegiones` como Autoload persistente. |
| `RPG/scripts/gestor_regiones.gd` | Validación, fundidos, sustitución y recuperación. |
| `RPG/scripts/salida_region.gd` | Detector `Area3D`, destino y entrada solicitada. |
| `RPG/scripts/region_config.gd` | ID regional, rutas de jugador/cámara y entradas. |
| Escenas envolventes de las seis regiones | Configuración de detectores y `Marker3D` concretos. |

**¿Cómo funciona?**

1. La salida se coloca sobre `marcador_salida` y conecta `body_entered` con `_entrar()`. Solo acepta al jugador indicado por `Region`. Capa 0/máscara 1 permiten detectar sin actuar como muro.
2. Solicita al Autoload una `escena_destino` y una `entrada_destino`. `solicitar()` bloquea solicitudes simultáneas mediante `en_transicion` y difiere la operación.
3. `_ejecutar()` comprueba origen/ruta, detiene el proceso del jugador/cámara y anula velocidad. `_fundir(1.0)` anima un `ColorRect` negro en un `CanvasLayer` persistente durante **0,35 s**.
4. En negro carga e instancia un `PackedScene`. Valida configuración regional, marcador, jugador, cámara e ID antes de retirar el origen.
5. Retira el origen del árbol, añade el candidato y asigna `get_tree().current_scene`. Es una sustitución explícita; no utiliza `change_scene_to_file()`.
6. `obtener_entrada()` resuelve el `Marker3D`. Aparece en su posición **+0,05 Y**, reinicia velocidad/orientación visual y centra la cámara con ángulo inicial cero.
7. Libera la escena anterior, espera un fotograma físico, funde de vuelta y restaura los procesos. Emite `finalizada`. Ante fallos contemplados, `_recuperar()` restaura el origen y `_rechazar()` emite `rechazada`.

La separación entre apariciones y detectores evita retornos inmediatos. El bloqueo evita concurrencia; no hay un temporizador general de inmunidad. Los cierres exteriores permanecen detrás de las áreas y el jugador cambia de región antes de alcanzarlos.

| Conexión bidireccional | Escenas jugables |
|---|---|
| Aldea norte ↔ Bosque sur | `RPG/scenes/mundo.tscn` ↔ `RPG/scenes/mundo_bosque.tscn` |
| Bosque norte ↔ Ruinas sur | `RPG/scenes/mundo_bosque.tscn` ↔ `RPG/scenes/mundo_ruinas.tscn` |
| Aldea sur ↔ Campos norte | `RPG/scenes/mundo.tscn` ↔ `RPG/scenes/mundo_campos_granjas.tscn` |
| Aldea este ↔ Montañas oeste | `RPG/scenes/mundo.tscn` ↔ `RPG/scenes/mundo_montanas.tscn` |
| Montañas ↔ Minas | `RPG/scenes/mundo_montanas.tscn` ↔ `RPG/scenes/mundo_minas.tscn` |

**Ejemplo real: Aldea → Bosque.** En `RPG/scenes/mundo.tscn`, `Region/SalidaBosque` referencia `Aldea/SalidasRegionales/SalidaBosqueNorte/TransicionFutura`. Estas asignaciones serializadas indican el destino:

```text
escena_destino = "res://scenes/mundo_bosque.tscn"
entrada_destino = "bosque_aldea_sur"
```

En `RPG/scenes/mundo_bosque.tscn`, ese ID apunta a `../Bosque/Marcadores/RetornoAldea/AparicionSegura`. El gestor resuelve el marcador para colocar al personaje. El regreso usa `aldea_bosque_norte`, que corresponde a `Region/EntradaBosque` de Aldea, a Z=−32.

**Limitación:** el destino crea jugador/cámara nuevos. No se conserva inventario, posición histórica ni cambios regionales; el Autoload mantiene la infraestructura de transición, no una partida persistente.

**Cómo explicarlo durante la presentación:** «Un área entrega al gestor una escena y un ID de entrada. El gestor oscurece la pantalla, valida el destino y sustituye el escenario. Un Marker3D determina dónde aparece el protagonista. Bloqueamos cambios simultáneos y separamos entradas de detectores para evitar bucles».

## G. Sistema de colisiones y físicas

**¿Qué hace?** Mantiene al personaje apoyado y delimita superficies, obstáculos y pasos transitables.

**¿Dónde está implementado?** `RPG/scenes/jugador.tscn`, `RPG/scripts/jugador.gd`, escenas de regiones/construcciones y sus herramientas de autoría.

| Nodo o recurso | Uso |
|---|---|
| `CharacterBody3D` | Cuerpo del protagonista controlado por script. |
| `CollisionShape3D` + `CapsuleShape3D` | Volumen físico del jugador. |
| `StaticBody3D` | Suelos y obstáculos inmóviles. |
| `BoxShape3D` y formas simples | Aproximaciones de paredes, troncos y objetos. |
| `ConcavePolygonShape3D` | Superficies trianguladas estáticas de terreno/túneles. |
| `Area3D` | Detector de salidas o interacción, sin función de muro. |

**¿Cómo funciona?** Una malla visible no es automáticamente sólida. Los modelos reciben envolventes propias; no se presupone colisión en los glTF. Troncos/rocas grandes bloquean, hierba y flores pueden atravesarse. Los edificios se cierran por muros y puertas, sin bloquear toda la parcela.

`move_and_slide()` clasifica contactos con suelo o paredes. El personaje conserva el límite de pendiente predeterminado, aproximadamente 45°; las rampas se diseñan para él. `floor_snap_length` ayuda al descenso, pero no permite subir escalones arbitrarios. No hay salto ni escalada.

Hay tres casos de agua que conviene distinguir: río de Aldea sobre suelo continuo; laguna forestal con depresión visual y colisión base conservada; cauces/cubetas físicamente excavados en Montañas y Minas. Todos están protegidos por barreras. Sus materiales no implementan flotabilidad.

**Cómo explicarlo durante la presentación:** «La apariencia y la colisión son componentes distintos. Añadimos cuerpos estáticos a los elementos que deben bloquear y usamos una cápsula para el protagonista. Los terrenos inclinados tienen superficies físicas trianguladas. Diseñamos sus pendientes para conservar el mismo controlador sin salto».

## H. Modelos, sprites y materiales

**¿Dónde están?** En `RPG/assets/aldea/`, `naturaleza/`, `objetos_medievales/`, `bosque/kaykit_forest/`, `bosque/forest_nature_updated/`, `granja/Farm_Harvest/`, `granja/animales/` y `personajes/protagonista/`.

Los escenarios importan **glTF/GLB** como escenas reutilizables. Un glTF conserva BIN y texturas asociados; GLB empaqueta sus datos. Los animales disponibles incluyen **FBX** y alternativas OBJ/Blend; `RPG/scenes/pruebas_granja.tscn` los inspecciona en laboratorio, sin convertirlos en animales del mundo. La importación directa de Blender está deshabilitada.

Las hojas `RPG/assets/personajes/protagonista/Character_Idle.png` y `Character_Walk.png` proporcionan los fotogramas de `SpriteFrames`. La estética **low-poly** corresponde a geometrías estilizadas de pocos polígonos; no implica que todos los elementos sean pixel art.

`StandardMaterial3D` representa superficies habituales y puede aprovechar colores de vértice. `ShaderMaterial` permite mezcla de suelo, piedra procedural, agua animada o recorte de Minas. Un shader puede cambiar la imagen sin cambiar la física, como demuestra la laguna forestal.

Las escalas/posiciones de instancias adaptan modelos sin modificar originales ni escalar al protagonista. El inventario documental vigente registra 524 modelos canónicos, incluidos recursos no integrados; esta tarea no repitió su auditoría. No deben sumarse formatos alternativos como modelos nuevos.

`RPG/assets/` permanece excluida de nuevas incorporaciones a Git: clonar el código no garantiza disponer de recursos locales. Las licencias se consultan por paquete en el inventario; no existe una licencia única deducible de sus nombres.

**Cómo explicarlo durante la presentación:** «Combinamos escenas importadas con geometría propia. Guardamos las transformaciones de cada instancia y añadimos colisiones por separado. Los materiales dan el acabado y los shaders animan agua o mezclan el suelo. Tener un recurso disponible no implica integrarlo como sistema de juego».

## I. Arquitectura y comunicación entre sistemas

```text
project.godot
 ├─ Autoload GestorRegiones: permanece entre regiones
 └─ mundo.tscn: escena inicial
     ├─ Aldea: terreno, edificios, colisiones e interacción
     ├─ Jugador: jugador.gd + cápsula + AnimatedSprite3D
     ├─ CamaraPrincipal: camara_orbital.gd → objetivo Jugador
     └─ Region: entradas Marker3D y salidas Area3D
```

```text
Entrada + ejes de cámara → dirección → velocidad/gravedad
→ move_and_slide() → contactos con suelo/obstáculos
Entrada + velocidad → nombre de animación → AnimatedSprite3D
Jugador → centro suavizado de cámara → órbita y look_at()

body_entered → salida_region.gd → GestorRegiones.solicitar()
→ fundido → validar PackedScene/Region → sustituir escena
→ obtener_entrada() → Marker3D → aparición → restaurar control
```

Las referencias exportadas y `NodePath` conectan los nodos. Las señales comunican eventos; los metadatos describen el plano o previsiones y no ejecutan una transición por sí solos. No se identifica backend externo ni integración LLM.

### Interacción y minijuego de pesca

`RPG/scenes/punto_pesca.tscn`, instanciada en Aldea, reúne `Zona` (`Area3D`), `Aviso` (`Label3D`) y `MinijuegoPesca` (`CanvasLayer`). `RPG/scripts/pesca/punto_pesca.gd` muestra el aviso cuando entra un `CharacterBody3D`; actualmente eso identifica al protagonista. Incorporar NPCs del mismo tipo requeriría distinguirlos.

F o botón 0 del mando ejecuta `abrir_minijuego()`: pausa el árbol y abre `RPG/scenes/minijuego_pesca.tscn`. Su script `RPG/scripts/pesca/minijuego_pesca.gd` funciona en `PROCESS_MODE_ALWAYS`, gestiona instrucciones/partida/resultado y dibuja mediante la señal `draw` de un `Control`. `RPG/scripts/pesca/logica_pesca.gd`, clase `LogicaPesca`, mantiene reglas separadas y semilla opcional para pruebas deterministas.

La red se mueve con izquierda/derecha durante **60 s**. Pez atrapado **+10**, pez escapado **−5**, piedra atrapada **−10**. F/aceptar inicia o repite y Esc cierra. La señal `cerrado` permite reanudar el mundo. No hay recompensas de inventario ni récord persistente.

**Cómo explicarlo durante la presentación:** «Usamos referencias para localizar nodos y señales para comunicar eventos. En pesca, un área detecta cercanía y abre una interfaz que sigue procesándose con el mundo pausado. Las reglas están separadas del dibujo para poder probarlas de forma independiente. Al cerrar, una señal devuelve el control a la exploración».

## J. Funciones importantes del código

Las funciones de autoría se ejecutan solo al invocar sus herramientas, no durante la exploración.

| Función | Archivo | Qué hace | Cuándo se ejecuta |
|---|---|---|---|
| `_physics_process(delta)` | `RPG/scripts/jugador.gd` | Entrada, velocidad, gravedad y movimiento físico. | Cada paso de física. |
| `_actualizar_direccion_visual()` | `RPG/scripts/jugador.gd` | Elige orientación de pantalla. | Con entrada de movimiento. |
| `_actualizar_animacion()` | `RPG/scripts/jugador.gd` | Selecciona idle/walk y dirección. | Tras movimiento y al aparecer. |
| `_process(delta)` | `RPG/scripts/camara_orbital.gd` | Giro y seguimiento suavizado. | Cada fotograma activo. |
| `actualizar_orbita()` | `RPG/scripts/camara_orbital.gd` | Posición orbital y `look_at()`. | Inicio, seguimiento y transición. |
| `_ready()` / `pintar()` | `RPG/scripts/terreno_aldea.gd` | Construyen la máscara visual del suelo. | Al cargar el acabado activo. |
| `altura()` / `curva()` | `RPG/scripts/editor/construir_bosque.gd` | Calculan relieve y senderos horneados. | Autoría del bosque. |
| `libre()` | `RPG/scripts/editor/construir_vegetacion_bosque.gd` | Evita invadir pasos y reservas. | Al distribuir vegetación. |
| `construir()` | `RPG/scripts/editor/construir_ruinas.gd` | Compone ruinas y recursos. | Autoría de Ruinas. |
| `altura()` / `terreno()` | `RPG/scripts/editor/construir_campos_granjas.gd` | Generan suelo, colisión y parámetros de caminos. | Autoría rural. |
| `camino_cercano()` / `altura()` | `RPG/scripts/editor/construir_montanas.gd` | Mezclan rutas y relieve. | Autoría montañosa. |
| `hidrografia()` / `puente()` | `RPG/scripts/editor/construir_montanas.gd` | Construyen agua, seguridad y cruces. | Autoría montañosa. |
| `altura()` / `dentro()` / `terreno()` | `RPG/scripts/editor/minas_geometria.gd` | Definen niveles, huella y superficies físicas. | Autoría subterránea. |
| `_process(_delta)` | `RPG/scripts/minas_visibilidad.gd` | Envía posiciones a shaders de roca. | Cada fotograma activo en Minas. |
| `_entrar(cuerpo)` | `RPG/scripts/salida_region.gd` | Filtra jugador y solicita destino. | Señal `body_entered`. |
| `solicitar()` | `RPG/scripts/gestor_regiones.gd` | Bloquea concurrencia y difiere el cambio. | Salida válida. |
| `_ejecutar()` | `RPG/scripts/gestor_regiones.gd` | Valida y sustituye escenas; sitúa al jugador. | Solicitud aceptada. |
| `_fundir()` | `RPG/scripts/gestor_regiones.gd` | Anima opacidad con Tween. | Antes y después del cambio. |
| `_recuperar()` / `_rechazar()` | `RPG/scripts/gestor_regiones.gd` | Restauran origen e informan fallos contemplados. | Error de transición. |
| `obtener_entrada()` | `RPG/scripts/region_config.gd` | Resuelve un Marker3D por ID. | Validación y aparición. |
| `abrir_minijuego()` | `RPG/scripts/pesca/punto_pesca.gd` | Pausa el mundo y abre el panel. | Interacción cerca de la orilla. |
| `avanzar()` | `RPG/scripts/pesca/logica_pesca.gd` | Actualiza partida y puntuación. | Durante la pesca. |

## K. Preguntas probables durante la presentación

1. **¿Qué tipo de juego es?** Un RPG medieval de exploración y futura simulación de vida, con seis regiones y pesca jugable.
2. **¿Por qué Godot?** Encaja con escenas reutilizables, física 3D y sprites en un mismo entorno. El repositorio no acredita una comparación formal de motores.
3. **¿Qué es GDScript?** El lenguaje integrado de Godot utilizado para controlar nodos y responder a entradas/señales.
4. **¿Nodo y escena son lo mismo?** Un nodo tiene una función; una escena guarda un árbol de nodos reutilizable.
5. **¿El protagonista es 2D o 3D?** Visualmente es 2D, pero su cuerpo y movimiento son tridimensionales.
6. **¿Por qué mezclar ambos estilos?** Conserva la estética pixel art del personaje y aprovecha profundidad, iluminación y órbita del escenario.
7. **¿Cómo se mueve?** Lee acciones, calcula dirección relativa a cámara, ajusta velocidad y llama a `move_and_slide()`.
8. **¿La diagonal es más rápida?** No, la dirección se normaliza. Esto también limita la modulación de rapidez con stick parcial.
9. **¿Cómo se elige la animación?** Según reposo/caminata y una de cuatro direcciones de pantalla, mediante `SpriteFrames`.
10. **¿Cómo gira la cámara?** Q/E o stick derecho cambian un ángulo y el script rota su desplazamiento alrededor del jugador.
11. **¿Qué significa ortográfica?** La distancia no reduce el tamaño aparente como en perspectiva; mantiene una lectura uniforme de escala.
12. **¿Se generan mapas al entrar?** Se cargan escenas guardadas. Las herramientas construyen los terrenos previamente; la máscara visual de Aldea sí se prepara al cargar.
13. **¿Cómo se crean alturas?** Calculando cotas y triangulando mallas. Bosque, Campos, Montañas y Minas tienen relieve físico.
14. **¿Cómo se dibujan caminos?** Con máscaras, colores de vértice o parámetros de material derivados de ejes/anchuras del plano.
15. **¿Cómo funcionan las cascadas?** Son geometría inclinada y shaders animados sobre un cauce real; no una simulación de fluidos.
16. **¿Cómo se evita atravesar objetos?** Con cuerpos estáticos y formas de colisión; no todas las plantas necesitan bloquear.
17. **¿Cómo sube pendientes?** La cápsula sigue superficies inclinadas con `move_and_slide()` y ajuste al suelo, sin salto.
18. **¿Qué es un Area3D?** Un detector de cuerpos/áreas; aquí activa salidas y el aviso de pesca sin ser un muro.
19. **¿Para qué sirve Marker3D?** Guarda un punto espacial de entrada, salida o referencia de construcción.
20. **¿Cómo se conectan mapas?** El área entrega escena e ID al gestor, que funde, valida, sustituye y sitúa al protagonista.
21. **¿Cómo se evitan bucles?** Bloqueando solicitudes simultáneas y separando las apariciones de los detectores de retorno.
22. **¿Qué es MultiMesh?** Agrupa copias visuales de una malla; se usa en plantas/trigo y no crea colisiones automáticamente.
23. **¿Cómo funciona la pesca?** Pausa el mundo, abre una interfaz y permite mover una red para puntuar durante 60 segundos.
24. **¿Se guarda el progreso regional?** No; se crea una nueva instancia del destino y no hay inventario/guardado persistente.
25. **¿Qué falta para simular vida?** NPCs, rutinas, relaciones, diálogos, profesiones, inventario, misiones y eventos.

## L. Estado actual y aspectos pendientes

### Implementado y verificable por inspección

- Movimiento acelerado, frenado, gravedad y ocho animaciones del protagonista.
- Cámara orbital ortográfica compartida y controles de teclado/mando configurados.
- Seis regiones con geometría/colisiones y cinco conexiones bidireccionales explícitas.
- Gestor con fundidos, validación de entradas y recuperación ante errores contemplados.
- Aldea modular, huertos/vegetación decorativos, río, puente y rueda animada.
- Relieve forestal/rural/montañoso/subterráneo; puentes montañosos y túneles con rampas.
- Pesca con reglas, interfaz y detección separadas.

Esto acredita presencia de implementación, no funcionamiento exhaustivo, rendimiento ni aprobación visual en esta sesión.

### Parcial o con limitaciones

| Aspecto | Qué existe | Qué falta o limita |
|---|---|---|
| Simulación de vida | Entornos y espacios temáticos. | Interacciones sociales y oficios. |
| Agricultura/animales | Cultivos decorativos y laboratorio de animales. | Siembra, cosecha, cuidado y animales integrados en regiones. |
| Bosque | Relieve, vegetación, laguna y conexiones. | Arroyo/puentes previstos y actividades; depresión de laguna solo visual. |
| Ruinas/Minas | Arquitectura, exploración y utilería. | Puzles, minería interactiva o recompensas. |
| Pesca | Partida, resultado, repetición y cierre. | Inventario, recompensas y récord persistente. |
| Visibilidad | Cámara orbital y recorte local en Minas. | Solución global de oclusión y revisión visual de posiciones posibles. |
| Transiciones | Recrean regiones y resuelven apariciones. | Persistencia de cambios regionales. |
| Validación | Scripts y evidencias históricas documentadas. | No se repitieron ejecuciones o revisión gráfica para esta guía. |
| Documentación | Planos y registros detallados. | Resolver conflictos y conciliar descripciones históricas. |

No se identifican NPCs, navegación de NPCs, rutinas/memoria/relaciones, diálogos, inventario del jugador, misiones, eventos dinámicos, ciclo día/noche, backend o integración LLM. No se identifica combate tradicional y no forma parte de la visión documentada.

### Pruebas disponibles y alcance de esta revisión

| Área | Archivos existentes |
|---|---|
| Aldea | `RPG/tests/validar_aldea.gd`, entrada que hereda de `RPG/tests/validar_distribucion.gd`. |
| Cámara | `RPG/tests/validar_camara_orbital.gd`. |
| Río/puente de Aldea | `RPG/tests/validar_rio_puente.gd`. |
| Pesca | `RPG/tests/validar_pesca.gd`. |
| Bosque | `RPG/tests/validar_bosque.gd`, `validar_vegetacion_bosque.gd`, `validar_laguna_bosque.gd`. |
| Ruinas | `RPG/tests/validar_ruinas.gd`, `validar_bosque_ruinas.gd`. |
| Campos | `RPG/tests/validar_campos_granjas.gd`, `validar_transicion_campos.gd`. |
| Montañas | `RPG/tests/validar_montanas.gd`, `validar_transicion_montanas.gd`. |
| Minas | `RPG/tests/validar_minas.gd`, `validar_transicion_minas.gd`. |
| Gestor regional | `RPG/tests/validar_transiciones.gd`. |

Los validadores comprueban aspectos físicos y de integración; los capturadores aportan vistas para inspección. Headless no sustituye revisar texturas, escala, oclusión o experiencia jugable. Los resultados históricos del estado tienen fechas y limitaciones propias; no deben trasladarse automáticamente a esta combinación local de cambios.

**Alcance documental:** solo se creó `RPG/docs/guia_tecnica_presentacion.md`. No se ejecutaron herramientas de autoría ni se modificaron scripts, escenas, assets o configuración. `AGENTS.md` y `RPG/docs/estado_proyecto.md` se revisaron sin actualizarlos por la restricción expresa de conservar todos los archivos existentes. Sin commits ni pushes.
