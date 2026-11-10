# Fase 6A.0 — informe de importación y compatibilidad

Fecha: **3 de noviembre de 2026**. Complementa [la selección de 72 modelos](seleccion_assets_bosque.md). Evidencias finales en RPG/logs/seleccion_assets_bosque/2026-11-03T22-04-32/.

## Recursos y formatos

| Paquete | glTF | GLB | FBX | OBJ | BIN auxiliares | MTL auxiliares | Modelos canónicos | Geometrías sin repetir |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| KayKit | 105 | 0 | 210 | 105 | 105 | 105 | 105 | 101 |
| Forest Nature Updated | 0 | 60 | 0 | 0 | 0 | 0 | 60 | 60 |
| **Total nuevo** | **105** | **60** | **210** | **105** | **105** | **105** | **165** | **161** |

BIN y MTL no son modelos. FBX normal/Unity y OBJ/glTF comparten los 105 nombres KayKit. Las 315 comparaciones importadas con glTF dieron **0 discrepancias** en número de triángulos o dimensiones por encima de 0.0001. Esto acredita equivalencia de tamaño/coste, no identidad binaria de archivos, normales o parámetros PBR. Se eligen glTF y GLB; no hace falta incorporar otra dependencia para FBX en la ejecución del juego.

La comparación de geometría fuente usa posiciones referenciadas por triángulos, cuantizadas a 0.00001, ordenadas sin depender del índice o del orden de exportación; excluye material, UV, normales y transformaciones de nodo. **No es una prueba de equivalencia visual completa ni de siluetas a distinta escala.** Identifica cuatro pares KayKit: Grass_1_A_Color1 / Grass_1_Mesh; Grass_1_A_Singlesided_Color1 / Grass_1_SingleSided_Mesh; los dos pares análogos de Grass_2. Las variantes Mesh pueden tener materiales distintos. Los 60 GLB no repiten esa firma. No se deduplican ni borran fuentes.

## Licencias incluidas y procedencia

- **KayKit Forest Nature Pack 1.0**, Kay Lousberg: RPG/assets/bosque/kaykit_forest/License.txt declara **CC0**, uso personal/educativo/comercial y crédito apreciado pero no obligatorio. El archivo original se conserva.
- **Forest Nature Updated**, hooray4brains: RPG/assets/bosque/forest_nature_updated/README.txt permite uso personal y comercial, atribución apreciada no exigida, y **prohíbe revender o redistribuir los archivos originales**. No se etiqueta como CC0 ni se extienden esos permisos a otros paquetes. Se conserva el README; no se han consultado términos externos adicionales.
- Quaternius: se mantienen las limitaciones históricas de procedencia/licencias del inventario. Esta tarea no resuelve una licencia ausente del contenido local antiguo.

Se restableció /assets/ en RPG/.gitignore, cuya regla estaba comentada al comenzar, de acuerdo con AGENTS.md. Evita incorporar los paquetes nuevos. Los **1193 archivos de assets ya seguidos por Git antes de esta fase** no se desversionaron, movieron ni borraron: una regla de ignore no retira archivos ya seguidos. No se ejecutó git add, commit ni push.

## Materiales, texturas y escala

KayKit usa principalmente el material forest y un atlas forest_texture.png (copiado en las carpetas de formato y Textures); la paleta genera verdes lima, troncos naranjas y roca gris azulada. Las copias de atlas no son modelos. Las versiones Grass_*_Mesh tienen material de reserva; usar el recurso Color1 propuesto. Forest Nature Updated usa materiales de colores planos, sin depender de imágenes externas en sus GLB. Se conservan materiales originales en todas las capturas.

Las medidas son AABB de mallas con transformaciones de nodos aplicadas, a escala raíz 1. Se registra cada mínimo Y y se apoya la muestra compensando el pivote, sin modificar el recurso. Varios GLB tienen árboles de 12–27 unidades, rocas muy grandes, tronco de ~8.21 de longitud y tocón de ~4.70 de ancho. KayKit mezcla matas de menos de una unidad con árboles de 4–10.77. **No aplicar una escala global a todo un paquete.** Las escalas uniformes por ID son propuestas iniciales, no medidas ya aprobadas en el mundo. El protagonista permanece intacto.

Flat_Tree_Oak_hero_green incluye una peana verde saturada y una roca: su cota base no es la de un tronco simple y añade otra malla. Esa peana puede sobresalir sobre terreno/agua; usar el hito en un claro compatible o revisar un override local después. CommonTree y helechos Quaternius usan recorte/texturas; no se debe afirmar que comparten el lenguaje de planos mates Forest sin revisar una composición conjunta.

Se mantiene la observación de COLOR_0 desactivado en algunos materiales Quaternius, especialmente Vase_Rubble_Medium, que se ve blanco. La presencia de COLOR_0 no demuestra por sí sola un error (puede ser blanco o información auxiliar); el hallazgo visual y la revisión posterior mediante overrides son los relevantes. No se corrigió ningún material fuente.

## Validaciones ejecutadas y limitaciones

| Comprobación | Resultado / evidencia |
|---|---|
| Apertura/importación del proyecto en Godot 4.7.2 con editor headless | Nuevos 480 modelos importados; RPG/logs/seleccion_bosque_01_importacion.log |
| Carga de todos los formatos y modelos antiguos | **818 recursos, 0 fallos de carga/malla/material ausente**; RPG/logs/seleccion_bosque_03_mediciones.log |
| Dependencias fuente de los 165 glTF/GLB nuevos | **0 referencias externas ausentes**; JSON de fuentes y compatibilidad |
| Render real final | Forward+/D3D12, RTX 4060 Laptop, **72 recursos y 40 PNG guardados**, 0 fallos contabilizados por el capturador; RPG/logs/seleccion_bosque_09_apoyos_final.log |
| Escena temporal guardada y recargada | **72 contenedores con referencias y medidas**, guardado OK; mismo log y RPG/logs/seleccion_bosque_10_validacion_cierre.log |
| Asignación de mallas a MultiMesh temporal | **73 mallas de los 72 modelos**, dos transformaciones por recurso, 0 fallos; RPG/logs/seleccion_bosque_10_validacion_cierre.log |
| Integridad de fuentes tras validación | **0 fuentes alteradas**, comparación SHA-256 contra la lectura inicial de fuentes de esta fase (excluye metadatos .import/.uid y cachés) |
| Mundo y sistemas jugables | No se ejecutó regresión de aldea porque no cambian sus escenas/scripts; no se declaran aprobados los fallos históricos del mundo |

Incidencias de entorno registradas, sin ocultarlas: el motor no puede leer el almacén de certificados; el editor headless no puede guardar ajustes personales fuera del workspace; OBJ avisa que el ambiente Ka del MTL se ignora en PBR; Forward+ informa fallos al escribir algunas entradas de caché de shaders (_save_to_cache). **No son referencias de modelo rotas**, pero los logs no están libres de mensajes ERROR/WARNING. Las capturas y la recarga terminaron y se revisaron sus imágenes. No se modificó project.godot para evitar estos mensajes. Dos intentos iniciales del capturador necesitaron corregir tipado; una primera serie de rótulos se sustituyó por una nueva ejecución con filas legibles, conservando evidencias anteriores.

La prueba MultiMesh comprueba asignación de mallas estáticas y transformaciones, no rendimiento GPU de una región poblada, uniformidad de material en múltiples superficies ni soporte de interacción individual. La órbita gráfica se hizo sobre seis representantes a cuatro ángulos, no sobre cada modelo en 360°. El terreno final, oclusión por densidad, navegación, colisiones transitables, agua animada y puentes no se implementan ni validan aquí.

## Rendimiento propuesto

Los 72 ejemplares suman **51471 triángulos base, 112 superficies y 73 nodos de malla**, sin contar suelo/rótulos del catálogo. No es un presupuesto de región ni una cifra de draw calls. Las superficies cuentan sus materiales efectivos; el número de materiales distintos se lista por modelo, no se equiparan materiales solo por coincidir el nombre. No se modifican LOD, normales, geometría o texturas.

Repetición intensiva: hierba KayKit Grass_2_C y Forest Flat_Grass, arbustos elegidos, hongos Forest, Pebble y rocas ligeras. Árboles Forest principales tienen menos triángulos que CommonTree texturizados; revisar el número de superficies antes de extender una familia. MultiMesh por modelo/malla y sectores espaciales conserva culling más útil que un único bosque completo. Cada malla puede mantener varias superficies/materiales; eso no equivale a un único envío de dibujo. No genera colisiones ni estados de interacción por instancia.

Mayor coste de la selección: CommonTree_3 3505, Mushroom_Laetiporus 3216, CommonTree_5 3182, Lantern_Wall 2822, Chest_Wood 2546 y Cauldron 2020 triángulos. El hongo de repisas y farol/cofre son detalle puntual. Fuera de selección, Flat_Forest_Ground tiene 6751 triángulos y Birch hero 4498; Quaternius TwistedTree alcanza 10104. No son necesariamente demasiado pesados aislados; sí merecen evitar repetición masiva para el valor visual que aportan.

Mantener colisiones simples independientes: cilindros en troncos, cajas/cápsulas en troncos caídos y mobiliario, convexas de pocas caras en grandes rocas. Pequeña vegetación, escombros y piedras de camino sin colisión individual. En ruinas conservar huecos de acceso; no llenar todo el recinto con una caja. El mirador necesita soporte físico propio, no asumir que el afloramiento visual es transitable.

Materiales reutilizables: atlas forest KayKit; familias de color plano idéntico dentro de Forest tras contrastar parámetros; Leaves/Grass/Flowers/PathRocks Quaternius; MI_WoodTrim/MI_RockTrim Village; MI_Trim_Furniture/Metal Props. No se unificaron automáticamente: nombres iguales no prueban parámetros o color de vértice idénticos. La diferencia de saturación e iluminación aparente entre paquetes es artística, no un fallo de importación.

## Medidas, geometría, materiales y colisión por ID

Todos cargan con material y malla válidos. X × Y × Z en unidades fuente, escala uniforme propuesta por instancia; superficies son las base importadas. Las imágenes embebidas GLB, cuando existen, se referencian como subrecursos; no implican un PNG externo faltante.

| ID | Dimensiones fuente | Escala propuesta | Triángulos | Superficies / materiales distintos | Materiales | Repetición / MultiMesh | Colisión propuesta |
|---|---|---:|---:|---|---|---|---|
| A01 | 12.06 × 15.24 × 8.81 | 0.56 | 394 | 2 / 2 | trunk oak, bush  | Moderada/alta por sectores | Cilindro de tronco; copa sin colisión |
| A02 | 10.85 × 12.52 × 7.60 | 0.52 | 302 | 2 / 2 | trunk oak, bush  | Moderada/alta por sectores | Cilindro de tronco; copa sin colisión |
| A03 | 16.12 × 16.31 × 12.30 | 0.64 | 1681 | 4 / 4 | bush brighter, bush , trunk oak, rock brighter | Moderada/puntual | Cilindro de tronco; copa sin colisión |
| A04 | 3.39 × 14.88 × 3.19 | 0.64 | 520 | 3 / 3 | bark, mushroom dots, grass | Moderada/puntual | Cilindro de tronco; copa sin colisión |
| A05 | 13.09 × 14.38 × 8.24 | 0.56 | 464 | 2 / 2 | trunk, elm | Moderada/alta por sectores | Cilindro de tronco; copa sin colisión |
| A06 | 10.33 × 15.38 × 8.88 | 0.52 | 774 | 2 / 2 | trunk oak, cypress | Moderada/alta por sectores | Cilindro de tronco; copa sin colisión |
| A07 | 7.92 × 16.68 × 8.18 | 0.54 | 1576 | 2 / 2 | trunk, pine | Moderada/alta por sectores | Cilindro de tronco; copa sin colisión |
| A08 | 5.64 × 12.64 × 5.72 | 0.79 | 385 | 2 / 2 | trunk, spruce | Moderada/alta por sectores | Cilindro de tronco; copa sin colisión |
| A09 | 4.06 × 9.43 × 4.24 | 0.85 | 3505 | 2 / 2 | Bark_NormalTree, Leaves_NormalTree | Moderada/puntual | Cilindro de tronco; copa sin colisión |
| A10 | 3.67 × 7.01 × 4.22 | 1.00 | 3182 | 2 / 2 | Bark_NormalTree, Leaves_NormalTree | Moderada/puntual | Cilindro de tronco; copa sin colisión |
| A11 | 3.74 × 5.26 × 2.07 | 1.05 | 936 | 1 / 1 | forest | Moderada/alta por sectores | Cilindro de tronco; copa sin colisión |
| A12 | 1.79 × 5.54 × 0.66 | 1.44 | 448 | 1 / 1 | forest | Moderada/alta por sectores | Cilindro de tronco; copa sin colisión |
| A13 | 4.70 × 2.21 × 4.27 | 0.36 | 504 | 3 / 3 | trunk dark, wood, wood light | Moderada/puntual | Caja/cilindro bajo |
| A14 | 8.21 × 1.74 × 5.94 | 0.50 | 618 | 2 / 2 | trunk dark, wood | Moderada/alta por sectores | Cápsula/caja orientada |
| B01 | 3.61 × 2.34 × 2.99 | 0.43 | 98 | 2 / 2 | bush , bush darker | Alta; MultiMesh por modelo/sector | Sin colisión |
| B02 | 3.23 × 1.38 × 2.58 | 0.40 | 168 | 1 / 1 | bush darker | Alta; MultiMesh por modelo/sector | Sin colisión |
| B03 | 2.92 × 2.34 × 2.99 | 0.36 | 56 | 1 / 1 | bush  | Alta; MultiMesh por modelo/sector | Sin colisión |
| B04 | 2.74 × 2.15 × 2.90 | 0.40 | 362 | 2 / 2 | bush brighter, mapple | Alta; MultiMesh por modelo/sector | Sin colisión |
| B05 | 1.58 × 0.81 × 1.32 | 1.40 | 552 | 1 / 1 | forest | Alta; MultiMesh por modelo/sector | Sin colisión |
| B06 | 2.70 × 1.30 × 2.28 | 1.00 | 284 | 1 / 1 | forest | Alta; MultiMesh por modelo/sector | Sin colisión |
| B07 | 1.97 × 2.18 × 1.16 | 0.25 | 286 | 3 / 3 | canopy, bush brighter, bush  | Puntual; MultiMesh posible, no abarata geometría | Sin colisión |
| B08 | 0.51 × 1.34 × 0.52 | 0.19 | 78 | 3 / 3 | canopy, bush brighter, bush  | Puntual; MultiMesh posible, no abarata geometría | Sin colisión |
| B09 | 0.90 × 0.94 × 0.76 | 0.70 | 528 | 1 / 1 | forest | Alta; MultiMesh por modelo/sector | Sin colisión |
| B10 | 2.83 × 0.84 × 2.65 | 0.50 | 288 | 1 / 1 | Leaves | Alta; MultiMesh por modelo/sector | Sin colisión |
| B11 | 0.80 × 1.14 × 0.76 | 0.35 | 379 | 1 / 1 | Leaves | Alta; MultiMesh por modelo/sector | Sin colisión |
| B12 | 0.64 × 1.33 × 0.74 | 0.35 | 155 | 1 / 1 | Grass | Alta; MultiMesh por modelo/sector | Sin colisión |
| B13 | 1.32 × 1.07 × 1.21 | 0.40 | 494 | 1 / 1 | Grass | Alta; MultiMesh por modelo/sector | Sin colisión |
| B14 | 0.45 × 0.50 × 0.45 | 0.50 | 140 | 2 / 2 | mushroom stem, mushroom top2 | Alta; MultiMesh por modelo/sector | Sin colisión |
| B15 | 0.41 × 0.51 × 0.41 | 0.75 | 856 | 3 / 3 | mushroom stem, mushroom top red.001, mushroom dots | Puntual; MultiMesh posible, no abarata geometría | Sin colisión |
| B16 | 1.37 × 0.77 × 1.10 | 0.50 | 3216 | 1 / 1 | Mushrooms | Puntual; MultiMesh posible, no abarata geometría | Sin colisión |
| B17 | 1.94 × 1.75 × 1.47 | 0.29 | 1248 | 3 / 3 | pale pink, red, bush  | Puntual; MultiMesh posible, no abarata geometría | Sin colisión |
| B18 | 1.49 × 2.05 × 1.59 | 0.25 | 755 | 2 / 2 | Leaves, Flowers | Puntual; MultiMesh posible, no abarata geometría | Sin colisión |
| B19 | 1.78 × 2.49 × 1.37 | 0.20 | 1690 | 2 / 2 | Leaves, Flowers | Puntual; MultiMesh posible, no abarata geometría | Sin colisión |
| B20 | 1.05 × 0.25 × 0.96 | 1.00 | 48 | 1 / 1 | Leaves | Alta; MultiMesh por modelo/sector | Sin colisión |
| C01 | 3.91 × 3.52 × 2.71 | 1.30 | 528 | 1 / 1 | forest | Alta/moderada, por forma y sector | Convexa simple/cajas; apoyo transitable separado si procede |
| C02 | 2.30 × 4.50 × 2.24 | 1.20 | 355 | 1 / 1 | forest | Alta/moderada, por forma y sector | Convexa simple/cajas; apoyo transitable separado si procede |
| C03 | 0.81 × 0.97 × 0.86 | 1.00 | 84 | 1 / 1 | forest | Alta/moderada, por forma y sector | Convexa simple/cajas; apoyo transitable separado si procede |
| C04 | 1.95 × 2.06 × 1.76 | 1.00 | 168 | 1 / 1 | forest | Alta/moderada, por forma y sector | Convexa simple/cajas; apoyo transitable separado si procede |
| C05 | 5.16 × 3.85 × 4.21 | 1.00 | 320 | 1 / 1 | forest | Alta/moderada, por forma y sector | Convexa simple/cajas; apoyo transitable separado si procede |
| C06 | 14.10 × 10.71 × 10.76 | 0.50 | 50 | 1 / 1 | rock | Alta/moderada, por forma y sector | Convexa simple/cajas; apoyo transitable separado si procede |
| C07 | 11.31 × 17.65 × 9.01 | 0.40 | 66 | 1 / 1 | rock darker | Alta/moderada, por forma y sector | Convexa simple/cajas; apoyo transitable separado si procede |
| C08 | 2.64 × 2.74 × 2.22 | 1.00 | 40 | 1 / 1 | rock | Alta/moderada, por forma y sector | Convexa simple/cajas; apoyo transitable separado si procede |
| C09 | 0.74 × 0.51 × 0.60 | 1.00 | 20 | 1 / 1 | rock brighter | Alta/moderada, por forma y sector | Convexa simple/cajas; apoyo transitable separado si procede |
| C10 | 3.23 × 2.26 × 2.99 | 0.70 | 342 | 1 / 1 | Rocks | Alta/moderada, por forma y sector | Convexa simple/cajas; apoyo transitable separado si procede |
| C11 | 3.05 × 1.90 × 2.48 | 0.80 | 244 | 1 / 1 | Rocks | Alta/moderada, por forma y sector | Convexa simple/cajas; apoyo transitable separado si procede |
| C12 | 0.50 × 0.10 × 0.37 | 1.00 | 136 | 1 / 1 | PathRocks | Alta/moderada, por forma y sector | Sin colisión |
| C13 | 0.41 × 0.10 × 0.45 | 1.00 | 126 | 1 / 1 | PathRocks | Alta/moderada, por forma y sector | Sin colisión |
| D01 | 0.66 × 0.80 × 0.54 | 1.00 | 858 | 2 / 2 | MI_Trim_Cloth, MI_Trim_Furniture | Localizada; MultiMesh solo si se repite | Caja/cilindro individual si bloquea paso |
| D02 | 0.70 × 0.90 × 0.70 | 1.00 | 824 | 2 / 2 | MI_Trim_Furniture, MI_Trim_Metal | Localizada; MultiMesh solo si se repite | Caja/cilindro individual si bloquea paso |
| D03 | 0.99 × 0.82 × 0.94 | 1.00 | 2020 | 1 / 1 | MI_Trim_Metal | Localizada; MultiMesh solo si se repite | Caja/cilindro individual si bloquea paso |
| D04 | 0.84 × 0.93 × 0.91 | 1.00 | 1576 | 2 / 2 | MI_Trim_Furniture, MI_Trim_Metal | Localizada; MultiMesh solo si se repite | Caja/cilindro individual si bloquea paso |
| D05 | 0.43 × 0.29 × 0.38 | 1.00 | 976 | 2 / 2 | MI_Trim_Furniture, MI_Trim_Metal | Localizada; MultiMesh solo si se repite | Sin colisión decorativa |
| D06 | 0.54 × 0.22 × 0.49 | 1.00 | 1068 | 1 / 1 | MI_Trim_Metal | Localizada; MultiMesh solo si se repite | Sin colisión decorativa |
| D07 | 0.81 × 0.12 × 0.85 | 1.00 | 1460 | 1 / 1 | MI_Trim_Furniture | Localizada; MultiMesh solo si se repite | Sin colisión decorativa |
| D08 | 0.47 × 0.59 × 0.47 | 1.00 | 152 | 1 / 1 | MI_Trim_Furniture | Localizada; MultiMesh solo si se repite | Caja/cilindro individual si bloquea paso |
| D09 | 2.85 × 0.81 × 1.10 | 1.00 | 986 | 2 / 2 | MI_Trim_Furniture, MI_Trim_Metal | Localizada; MultiMesh solo si se repite | Caja/cilindro individual si bloquea paso |
| D10 | 1.28 × 0.72 × 0.76 | 1.00 | 2546 | 4 / 2 | MI_Trim_Furniture, MI_Trim_Metal | Localizada; MultiMesh solo si se repite | Caja/cilindro individual si bloquea paso |
| D11 | 0.36 × 1.34 × 1.30 | 1.00 | 2822 | 1 / 1 | MI_Trim_Metal | Localizada; MultiMesh solo si se repite | Sin colisión decorativa |
| D12 | 0.29 × 0.83 × 0.05 | 1.00 | 826 | 1 / 1 | MI_Trim_Props_Vertex | Localizada; MultiMesh solo si se repite | Sin colisión decorativa |
| E01 | 0.53 × 3.02 × 0.58 | 1.00 | 3102 | 1 / 1 | MI_RockTrim | Localizada; MultiMesh solo si se repite | Cajas/forma simple; conservar huecos y apoyo |
| E02 | 0.35 × 0.21 × 0.25 | 1.00 | 108 | 1 / 1 | MI_RockTrim | Localizada; MultiMesh solo si se repite | Sin colisión decorativa |
| E03 | 0.38 × 0.25 × 0.22 | 1.00 | 126 | 1 / 1 | MI_RockTrim | Localizada; MultiMesh solo si se repite | Sin colisión decorativa |
| E04 | 2.00 × 0.02 × 2.00 | 1.00 | 4 | 1 / 1 | MI_UnevenBrick | Localizada; MultiMesh solo si se repite | Cajas/forma simple; conservar huecos y apoyo |
| E05 | 2.00 × 1.20 × 2.08 | 1.00 | 62 | 2 / 2 | MI_RockTrim, MI_Brick | Localizada; MultiMesh solo si se repite | Cajas/forma simple; conservar huecos y apoyo |
| E06 | 2.00 × 3.12 × 0.41 | 1.00 | 136 | 3 / 3 | MI_WoodTrim, MI_Plaster, MI_UnevenBrick | Localizada; MultiMesh solo si se repite | Cajas/forma simple; conservar huecos y apoyo |
| E07 | 2.30 × 2.99 × 1.13 | 1.00 | 117 | 1 / 1 | MI_Vine | Localizada; MultiMesh solo si se repite | Sin colisión decorativa |
| E08 | 0.80 × 0.17 × 0.60 | 1.00 | 1113 | 1 / 1 | MI_Trim_Props_Vertex | Localizada; MultiMesh solo si se repite | Sin colisión decorativa |
| F01 | 2.06 × 0.84 × 0.12 | 1.00 | 40 | 1 / 1 | MI_WoodTrim | Localizada; MultiMesh solo si se repite | Cajas por tramo, mantener apertura |
| F02 | 2.05 × 0.84 × 0.11 | 1.00 | 32 | 1 / 1 | MI_WoodTrim | Localizada; MultiMesh solo si se repite | Cajas por tramo, mantener apertura |
| F03 | 1.54 × 2.60 × 0.22 | 1.00 | 82 | 1 / 1 | MI_Vine | Localizada; MultiMesh solo si se repite | Sin colisión salvo poste de paso |
| F04 | 0.20 × 1.71 × 2.04 | 1.00 | 16 | 1 / 1 | MI_WoodTrim | Localizada; MultiMesh solo si se repite | Sin colisión salvo poste de paso |
| F05 | 0.22 × 0.65 × 0.39 | 1.00 | 970 | 1 / 1 | MI_Trim_Metal | Localizada; MultiMesh solo si se repite | Sin colisión salvo poste de paso |

## Inventario completo nuevo y trazabilidad

[CSV de los 165 recursos canónicos](../logs/seleccion_assets_bosque/2026-11-03T22-04-32/inventario_nuevos.csv) · [132 descartes de selección](../logs/seleccion_assets_bosque/2026-11-03T22-04-32/descartados_nuevos.csv) · [Mediciones seleccionadas y texturas importadas](../logs/seleccion_assets_bosque/2026-11-03T22-04-32/mediciones.json) · [Resumen verificable](../logs/seleccion_assets_bosque/2026-11-03T22-04-32/informe_compatibilidad.json).

El inventario fuente detallado, hashes, materiales PBR y correspondencias de cuatro formatos por nombre se conserva localmente en RPG/logs/seleccion_assets_bosque/fuentes_2026-11-04T02-51-03.469Z.json. La auditoría mide lectura local; no certifica el contenido total comercial de ningún paquete ni atribuye recursos ausentes a esta versión gratuita.

La revisión final corrigió únicamente el expositor para conservar la traslación de raíz de los GLB al compensar su AABB. Los apoyos del catálogo se comprobaron de nuevo; no se editó la geometría ni el pivote fuente. Las capturas de ejecuciones anteriores se conservan como borradores, no como galería final.
