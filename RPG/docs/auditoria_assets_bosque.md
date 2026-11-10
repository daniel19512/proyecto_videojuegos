# Auditoría de assets para la región del bosque

Fecha: **3 de noviembre de 2026**. Inspección y preparación visual exclusivamente; bosque sin construir y aldea intacta.

**338 modelos revisados; 122 seleccionados para el catálogo forestal; 216 alternativas no prioritarias.** Los 338 glTF se cargaron e instanciaron con malla válida en Godot 4.7.2. Se revisaron sus láminas reales en Forward+/D3D12, además de geometría, materiales y dependencias. Selección conservadora por utilidad directa o adaptación sencilla: no significa que los restantes sean incompatibles con cualquier escena de bosque.

[Galería completa](../logs/auditoria_assets_bosque/2026-11-03T21-27-33/galeria.html) · [Escena temporal](../logs/auditoria_assets_bosque/2026-11-03T21-27-33/catalogo_temporal.tscn) · [CSV de los 338 modelos](../logs/auditoria_assets_bosque/2026-11-03T21-27-33/modelos.csv) · [Mediciones completas](../logs/auditoria_assets_bosque/2026-11-03T21-27-33/mediciones.json)

Las evidencias bajo RPG/logs/ son locales y están excluidas de Git. Este informe conserva los resultados y la tabla de selección.

## Cobertura y método

Se consultaron AGENTS.md, estado, inventario y plano de aldea. Recorrido recursivo de RPG/assets/: 176 glTF de aldea, 68 de naturaleza y 94 de objetos medievales. La única carpeta adicional es personajes, con dos sprites PNG del protagonista; no añade modelos forestales. No se usaron recursos externos ni se cambiaron originales, importaciones o configuración.

Cada recurso se instanció sin abrir el mundo; las medidas son la unión de AABB de mallas, aplicando transformaciones de nodos. Se cuentan triángulos base de superficies importadas, no LOD ni rendimiento real. Materiales y URI se obtienen del glTF y se contrastan con flags de materiales importados. Las dimensiones X × Y × Z se expresan en unidades Godot a escala de instancia 1, aproximadamente metros según el plano. No son una propuesta de escala definitiva ni un tamaño de colisión.

El catálogo genera 34 láminas de hasta 12 recursos y una vista general (35 PNG, 1600×1000), con suelo neutro, luz direccional, ambiente y etiquetas. Las láminas normalizan cada modelo a una caja máxima de 3.8 para compararlo visualmente; las etiquetas muestran medidas fuente. La escena temporal contiene los 122 seleccionados a escala 1, por bloques separados; se puede inspeccionar con la cámara del editor. La vista general sirve para localizar grupos, las láminas para identificar piezas. La revisión artística final sigue a cargo del usuario; no se certifican todas las caras ni el aspecto en una región final.

Reproducción desde la raíz del repositorio, con Godot 4.7.2 disponible: 

`godot --path RPG --resolution 1600x1000 --log-file logs/<nombre_nuevo>.log --script res://tests/auditar_assets_bosque.gd`

Con --headless realiza solo carga y mediciones. Cada ejecución usa una subcarpeta nueva, sin sobrescribir evidencias anteriores. No carga scripts jugables ni cambia la escena principal.

## Cantidades y suficiencia

| Categoría primaria, sin duplicados | Cantidad | Evaluación | Observación |
|---|---:|---|---|
| Árboles de hoja ancha | 10 | Suficiente | Dos familias: cinco verdes y cinco rojos de gran porte. |
| Coníferas y árboles altos | 5 | Suficiente | Cinco siluetas de pino; los TwistedTree y DeadTree también aportan altura, sin contarlos dos veces. |
| Árboles secos o troncos | 5 | Limitada, pero reutilizable | Cinco árboles secos completos; sin tocones ni troncos caídos naturales independientes. |
| Arbustos y matorrales | 2 | Limitada, pero reutilizable | Una forma base: variante roja y variante verde con flores. |
| Hierba, flores, hongos y plantas | 28 | Suficiente | 22 modelos naturales y seis enredaderas arquitectónicas. Incluye corolas sin tallo. |
| Rocas, piedras y formaciones | 24 | Limitada, pero reutilizable | Tres rocas medianas, once piedras individuales y diez grupos de pavimento. Sin acantilados ni grandes formaciones. |
| Elementos de madera | 4 | Limitada, pero reutilizable | Cuatro piezas arquitectónicas; no son leña natural. |
| Cercas, señales y estructuras pequeñas | 5 | Limitada, pero reutilizable | Tres cercas bajas de madera y dos rejas metálicas. No hay señal direccional terminada entre los glTF. |
| Elementos para campamentos | 25 | Limitada, pero reutilizable | 25 objetos de apoyo; no hay tienda, saco de dormir ni hoguera completa. |
| Elementos adaptables a ruinas antiguas | 14 | Limitada, pero reutilizable | 14 piezas de arquitectura y cerámica; sin kit específico de ruina fracturada. |
| **Total seleccionado** | **122** | | |

De los 24 modelos de roca, solo tres son rocas volumétricas medianas; no presentar los otros 21 como grandes formaciones. Los cinco árboles secos completos se cuentan únicamente en su categoría, aunque sean altos. Los seis Prop_Vine se cuentan como plantas, aunque también sirvan para ruinas. Las 14 piezas de ruinas incluyen cuatro bloques, dos esquinas, un piso, una escalera, tres muros/marcos y tres cerámicas.

## Evaluación del bosque y propuesta de uso

**Los recursos permiten un bosque atractivo y coherente sin descargar paquetes ahora.** Hay dosel verde, pinos, árboles rojos especiales, sotobosque, hongos y piedras musgosas, con materiales estilizados compatibles. La variedad exige composición por zonas, no distribuir todos los colores uniformemente.

| Necesidad | Propuesta con recursos locales | Límite / trabajo futuro |
|---|---|---|
| Senderos explorables | Suelo propio con acabado de tierra; Pebble_Round discretos, Grass_Common y Fern en bordes; RockPath solo en pasos antiguos | Las piezas de pavimento no sustituyen un terreno continuo ni definen navegación |
| Vegetación variada | CommonTree_3/4/5 como base, _1/_2 en claros; Pine_4/5 para fondos; Bush_Common_Flowers, Fern_1, Plant_1 y Clover | Reducir plantas de 1–2.5 de altura según la lectura del personaje; no escalar protagonista |
| Claros naturales | Espacios abiertos rodeados por grupos de CommonTree, flores bajas, hierba y hongos en sombra | No llenar todo de vegetación ni ocluir el camino desde cámara inclinada |
| Rocas y desniveles | Rock_Medium_1/2/3 agrupadas, semienterradas y rotadas, con piedras pequeñas | Desnivel transitable requiere terreno y colisiones propios; escalar rocas enormemente repite textura y silueta |
| Campamento pequeño | Prop_Crate, Bag, Barrel, Stool, Cauldron, Bucket_Wooden_1, Rope_2, Pot_1 y Prop_Wagon opcional | Sin tienda, hoguera o cama de exterior terminadas; componer lona/refugio y anillo de fuego con geometría local cuando se autorice |
| Salida a ruinas | Disminuir flores, introducir DeadTree_1/2, TwistedTree_1 puntual, Prop_Vine, Prop_Brick, RockPath y Vase_Rubble_Medium | Wall_Arch es madera, los muros son intactos mixtos; no existe una ruina antigua completa |
| Entrada desde aldea | CommonTree y cerca baja Prop_WoodenFence_Single, sendero abierto y señal propia futura | Respetar contrato aldea_bosque_norte ↔ bosque_aldea_sur; no abrir límites ni crear transición en esta auditoría |

Las carencias específicas son tocones/troncos caídos/leña, arbustos verdes sin flores, grandes taludes/acantilados, tienda/saco de dormir/hoguera terminada, señal direccional terminada y mampostería antigua fracturada. Ninguna es un bloqueo visual para un primer bosque con campamento sencillo y una salida a ruinas. No se recomienda descargar ahora. Revaluar un kit especializado solo si se aprueba una ruina monumental o un paisaje de acantilados como requisito central. No se han verificado licencias nuevas; se conserva la limitación del inventario.

## Hallazgos de apariencia e importación

- **0 fallos de carga/instanciación entre 338; 0 dependencias glTF ausentes.** El render final usó Godot 4.7.2.stable.official.ed1daf0bf, Forward+/D3D12 y RTX 4060 Laptop. No se repitió una importación desde caché vacía: se validó la importación local existente y su render real.
- Bush_Common y TwistedTree usan follaje rojo intenso. Bush_Common_Flowers es verde con flores rosas; no son dos formas distintas de matorral.
- Petal_1–5 representan corolas completas sin tallo; Plant_7 y Plant_7_Big parecen grupos florales morados bajos. Clover tiene tallos altos. Fern ocupa ~2.83 × 0.84 × 2.65. Grass_* mide 1.07–1.87 de alto a escala fuente.
- Roof_Log es una viga trabajada larga; Wall_Arch es un marco fino de madera; RockPath son grupos de piedras, no roca individual ni terreno. Los muros de UnevenBrick incluyen madera/revoque y están intactos.
- Hay primitivas con COLOR_0 cuyo material importado tiene vertex_color_use_as_albedo=false. En la selección: **Bush_Common, Bush_Common_Flowers, Clover_1, Clover_2, CommonTree_1, CommonTree_2, CommonTree_3, CommonTree_4, CommonTree_5, DeadTree_1, DeadTree_2, DeadTree_3, DeadTree_4, DeadTree_5, Fern_1, Flower_3_Group, Flower_3_Single, Flower_4_Group, Flower_4_Single, Grass_Common_Short, Grass_Common_Tall, Grass_Wispy_Short, Grass_Wispy_Tall, Pine_1, Pine_2, Pine_3, Pine_4, Pine_5, Plant_1, Plant_1_Big, TwistedTree_1, TwistedTree_2, TwistedTree_3, TwistedTree_4, TwistedTree_5, Axe_Bronze, Bag, Barrel, Bench, Crate_Wooden, Pouch_Large, Stool, Table_Large, Vase_2, Vase_4, Vase_Rubble_Medium**. Las vasijas/escombros se ven muy blancos. Es una incidencia de apariencia a comprobar con overrides locales al utilizarlos; no se corrigió ni se modificó el original. El CSV identifica también casos fuera de la selección.
- Se registra el mensaje del motor «Failed to read the root certificate store» tanto headless como con ventana. No corresponde a un modelo ni impidió capturas/carga local. El primer intento del auditor tuvo un error de tipado de variable; se corrigió antes de las ejecuciones válidas.

Logs: RPG/logs/auditoria_bosque_02.log (headless), RPG/logs/auditoria_bosque_04_final.log (render final) y RPG/logs/auditoria_bosque_05_catalogo.log (recarga de escena guardada: 122 instancias glTF y 122 etiquetas, código 0). La validación no incluye la regresión del mundo: no se alteraron sus archivos ni se ejecutó la aldea.

## Rendimiento y colisiones propuestas

No se hizo benchmark de una región final ni optimización destructiva. Los costes siguientes son relativos al tamaño y frecuencia prevista de las piezas.

| Grupo | Evidencia | Recomendación futura |
|---|---|---|
| TwistedTree_1–5 | 9,134–10,104 triángulos por árbol, dos superficies, alturas 15.66–18.95 | Hitos escasos; no formar el dosel entero con ellos. Mucha superficie de follaje puede aumentar coste de recortes/sombras |
| DeadTree_1–5 | 5,648–6,557 triángulos sin hojas | Las ramas finas suponen detalle de geometría alto para fondo; reservar unos pocos ejemplares |
| CommonTree_1/2 frente a _3/4/5 | 6,265/5,648 frente a 3,505/4,066/3,182 | Preferir _3/5 para repetición cuando su silueta encaje; no sustituir variantes automáticamente |
| Pine_1–5 | 1,646–4,964; Pine_5 es el más ligero | Buen candidato de masas de fondo junto a CommonTree, con límites de sombra y distancia por decidir |
| Mushroom_Laetiporus | 3,216 triángulos en una pieza de ~1.37 de ancho | Detalle cercano puntual; demasiado coste para cubrir grandes áreas |
| RockPath_Round_Wide | 3,500 triángulos en un grupo casi plano de ~2.1 de lado | Evitar pavimentar todo el bosque con estos grupos; el suelo texturizado cubre grandes superficies mejor |
| Rocas medianas | 244–522 triángulos por roca | Adecuadas para agrupaciones y obstáculos simples; no usar sus triángulos detallados como colisión por defecto |
| Cuerda/cajas/farol | Rope_1/3 1,748; FarmCrate_Empty 1,928; Lantern_Wall 2,822 | Decoración localizada, no dispersión masiva; Prop_Crate 230 y Stool 152 son alternativas ligeras |

Materiales compartibles: Bark_NormalTree entre CommonTree y Pine; Leaves_NormalTree entre árboles y arbusto florido; Leaves_TwistedTree entre árboles rojos y Bush_Common; PathRocks entre 21 piedras/grupos; Rocks entre tres rocas; Leaves/Grass/Flowers/Mushrooms entre detalles; MI_WoodTrim/MI_RockTrim en aldea; familias MI_Trim_Furniture/Metal/Props/Cloth en objetos. Compartir nombre no demuestra identidad completa: contrastar textura, parámetros y colores de vértice antes de unificar. Las texturas exactas por recurso constan abajo y en el CSV. No se unificó ningún material.

MultiMesh propuesto por modelo y material: Grass_*, Clover, Fern, Plant_*, hongos comunes, Pebble_* y cada Rock_Medium; también masas de un mismo árbol si se necesita. Dividir por sectores espaciales para conservar culling, y por superficie cuando el modelo tenga varios materiales. MultiMesh reduce envíos de instancias, no triángulos ni coste del follaje; no crea colisiones individuales. No se implementó.

Colisiones futuras: cilindros/cápsulas en troncos, envolventes convexas simples en rocas grandes, cajas individuales en cercas/cajas/mesa/barril; muros perimetrales con huecos reales, no caja que llene todo el recinto. Hierba, corolas, hongos, pequeñas piedras y follaje sin colisión. El suelo soportará senderos y pendientes; los modelos decorativos no sustituyen ese soporte. No añadir colisión a cada planta ni a cada rama.

## Tabla de los 122 modelos seleccionados

Escala fuente 1; medidas aproximadas X × Y × Z. «Sí» indica PackedScene instanciada con malla válida. Todos los paths son relativos a la raíz del repositorio. Las texturas se expresan por código de conjunto para mantener legible la tabla; los conjuntos con rutas exactas aparecen después.

### Árboles de hoja ancha (10)

| Nombre exacto | Ruta del modelo | X × Y × Z | Triángulos / superficies | Materiales; texturas | Importa | Utilidad propuesta |
|---|---|---|---|---|---|---|
| CommonTree_1 | `RPG/assets/naturaleza/glTF/CommonTree_1.gltf` | 4.31 × 7.26 × 4.58 | 6265 / 2 | Bark_NormalTree, Leaves_NormalTree; T01 (revisar COLOR_0) | Sí | Dosel verde principal; alternar siluetas y giros, con tronco fuera del sendero. |
| CommonTree_2 | `RPG/assets/naturaleza/glTF/CommonTree_2.gltf` | 4.46 × 7.64 × 4.28 | 5648 / 2 | Bark_NormalTree, Leaves_NormalTree; T01 (revisar COLOR_0) | Sí | Dosel verde principal; alternar siluetas y giros, con tronco fuera del sendero. |
| CommonTree_3 | `RPG/assets/naturaleza/glTF/CommonTree_3.gltf` | 4.06 × 9.43 × 4.24 | 3505 / 2 | Bark_NormalTree, Leaves_NormalTree; T01 (revisar COLOR_0) | Sí | Dosel verde principal; alternar siluetas y giros, con tronco fuera del sendero. |
| CommonTree_4 | `RPG/assets/naturaleza/glTF/CommonTree_4.gltf` | 3.83 × 9.44 × 3.76 | 4066 / 2 | Bark_NormalTree, Leaves_NormalTree; T01 (revisar COLOR_0) | Sí | Dosel verde principal; alternar siluetas y giros, con tronco fuera del sendero. |
| CommonTree_5 | `RPG/assets/naturaleza/glTF/CommonTree_5.gltf` | 3.67 × 7.01 × 4.22 | 3182 / 2 | Bark_NormalTree, Leaves_NormalTree; T01 (revisar COLOR_0) | Sí | Dosel verde principal; alternar siluetas y giros, con tronco fuera del sendero. |
| TwistedTree_1 | `RPG/assets/naturaleza/glTF/TwistedTree_1.gltf` | 13.52 × 16.73 × 11.55 | 9564 / 2 | Bark_TwistedTree, Leaves_TwistedTree; T02 (revisar COLOR_0) | Sí | Árbol retorcido rojo, hito fantástico junto a ruinas; uso escaso por escala y coste. |
| TwistedTree_2 | `RPG/assets/naturaleza/glTF/TwistedTree_2.gltf` | 10.56 × 18.95 × 9.20 | 9134 / 2 | Bark_TwistedTree, Leaves_TwistedTree; T02 (revisar COLOR_0) | Sí | Árbol retorcido rojo, hito fantástico junto a ruinas; uso escaso por escala y coste. |
| TwistedTree_3 | `RPG/assets/naturaleza/glTF/TwistedTree_3.gltf` | 11.36 × 16.07 × 11.51 | 10089 / 2 | Bark_TwistedTree, Leaves_TwistedTree; T02 (revisar COLOR_0) | Sí | Árbol retorcido rojo, hito fantástico junto a ruinas; uso escaso por escala y coste. |
| TwistedTree_4 | `RPG/assets/naturaleza/glTF/TwistedTree_4.gltf` | 10.38 × 18.74 × 11.29 | 9600 / 2 | Bark_TwistedTree, Leaves_TwistedTree; T02 (revisar COLOR_0) | Sí | Árbol retorcido rojo, hito fantástico junto a ruinas; uso escaso por escala y coste. |
| TwistedTree_5 | `RPG/assets/naturaleza/glTF/TwistedTree_5.gltf` | 9.49 × 15.66 × 9.39 | 10104 / 2 | Bark_TwistedTree, Leaves_TwistedTree; T02 (revisar COLOR_0) | Sí | Árbol retorcido rojo, hito fantástico junto a ruinas; uso escaso por escala y coste. |

### Coníferas y árboles altos (5)

| Nombre exacto | Ruta del modelo | X × Y × Z | Triángulos / superficies | Materiales; texturas | Importa | Utilidad propuesta |
|---|---|---|---|---|---|---|
| Pine_1 | `RPG/assets/naturaleza/glTF/Pine_1.gltf` | 4.94 × 7.32 × 4.54 | 3947 / 2 | Bark_NormalTree, Leaves_Pine; T03 (revisar COLOR_0) | Sí | Conífera para fondos y transición hacia zonas altas. |
| Pine_2 | `RPG/assets/naturaleza/glTF/Pine_2.gltf` | 5.73 × 7.38 × 5.22 | 3648 / 2 | Bark_NormalTree, Leaves_Pine; T03 (revisar COLOR_0) | Sí | Conífera para fondos y transición hacia zonas altas. |
| Pine_3 | `RPG/assets/naturaleza/glTF/Pine_3.gltf` | 3.61 × 7.39 × 4.00 | 4964 / 2 | Bark_NormalTree, Leaves_Pine; T03 (revisar COLOR_0) | Sí | Conífera para fondos y transición hacia zonas altas. |
| Pine_4 | `RPG/assets/naturaleza/glTF/Pine_4.gltf` | 5.80 × 10.24 × 5.37 | 3370 / 2 | Bark_NormalTree, Leaves_Pine; T03 (revisar COLOR_0) | Sí | Conífera para fondos y transición hacia zonas altas. |
| Pine_5 | `RPG/assets/naturaleza/glTF/Pine_5.gltf` | 6.42 × 8.72 × 6.22 | 1646 / 2 | Bark_NormalTree, Leaves_Pine; T03 (revisar COLOR_0) | Sí | Conífera para fondos y transición hacia zonas altas. |

### Árboles secos o troncos (5)

| Nombre exacto | Ruta del modelo | X × Y × Z | Triángulos / superficies | Materiales; texturas | Importa | Utilidad propuesta |
|---|---|---|---|---|---|---|
| DeadTree_1 | `RPG/assets/naturaleza/glTF/DeadTree_1.gltf` | 6.15 × 9.50 × 5.75 | 6169 / 1 | Bark_DeadTree; T04 (revisar COLOR_0) | Sí | Árbol muerto completo para lindes y acceso a ruinas; no es tocón. |
| DeadTree_2 | `RPG/assets/naturaleza/glTF/DeadTree_2.gltf` | 6.73 × 11.49 × 6.38 | 6557 / 1 | Bark_DeadTree; T04 (revisar COLOR_0) | Sí | Árbol muerto completo para lindes y acceso a ruinas; no es tocón. |
| DeadTree_3 | `RPG/assets/naturaleza/glTF/DeadTree_3.gltf` | 6.39 × 13.28 × 6.43 | 5802 / 1 | Bark_DeadTree; T04 (revisar COLOR_0) | Sí | Árbol muerto completo para lindes y acceso a ruinas; no es tocón. |
| DeadTree_4 | `RPG/assets/naturaleza/glTF/DeadTree_4.gltf` | 7.96 × 12.77 × 7.73 | 5702 / 1 | Bark_DeadTree; T04 (revisar COLOR_0) | Sí | Árbol muerto completo para lindes y acceso a ruinas; no es tocón. |
| DeadTree_5 | `RPG/assets/naturaleza/glTF/DeadTree_5.gltf` | 8.36 × 16.44 × 8.41 | 5648 / 1 | Bark_DeadTree; T04 (revisar COLOR_0) | Sí | Árbol muerto completo para lindes y acceso a ruinas; no es tocón. |

### Arbustos y matorrales (2)

| Nombre exacto | Ruta del modelo | X × Y × Z | Triángulos / superficies | Materiales; texturas | Importa | Utilidad propuesta |
|---|---|---|---|---|---|---|
| Bush_Common | `RPG/assets/naturaleza/glTF/Bush_Common.gltf` | 1.91 × 1.58 × 1.97 | 900 / 1 | Leaves_TwistedTree; T05 (revisar COLOR_0) | Sí | Matorral rojo de acento; no usarlo como arbusto verde por su nombre. |
| Bush_Common_Flowers | `RPG/assets/naturaleza/glTF/Bush_Common_Flowers.gltf` | 1.91 × 1.58 × 1.97 | 1368 / 2 | Leaves_NormalTree, Flowers; T06 (revisar COLOR_0) | Sí | Arbusto verde florido en bordes de claros; comparte silueta con Bush_Common. |

### Hierba, flores, hongos y plantas (28)

| Nombre exacto | Ruta del modelo | X × Y × Z | Triángulos / superficies | Materiales; texturas | Importa | Utilidad propuesta |
|---|---|---|---|---|---|---|
| Prop_Vine1 | `RPG/assets/aldea/glTF/Prop_Vine1.gltf` | 1.54 × 2.60 × 0.22 | 82 / 1 | MI_Vine; T07 | Sí | Enredadera plana/colgante sobre restos y rocas; requiere soporte visual. |
| Prop_Vine2 | `RPG/assets/aldea/glTF/Prop_Vine2.gltf` | 1.39 × 2.60 × 0.21 | 45 / 1 | MI_Vine; T07 | Sí | Enredadera plana/colgante sobre restos y rocas; requiere soporte visual. |
| Prop_Vine4 | `RPG/assets/aldea/glTF/Prop_Vine4.gltf` | 1.02 × 1.59 × 0.15 | 31 / 1 | MI_Vine; T07 | Sí | Enredadera plana/colgante sobre restos y rocas; requiere soporte visual. |
| Prop_Vine5 | `RPG/assets/aldea/glTF/Prop_Vine5.gltf` | 2.30 × 2.99 × 1.13 | 117 / 1 | MI_Vine; T07 | Sí | Enredadera plana/colgante sobre restos y rocas; requiere soporte visual. |
| Prop_Vine6 | `RPG/assets/aldea/glTF/Prop_Vine6.gltf` | 4.14 × 2.47 × 1.47 | 114 / 1 | MI_Vine; T07 | Sí | Enredadera plana/colgante sobre restos y rocas; requiere soporte visual. |
| Prop_Vine9 | `RPG/assets/aldea/glTF/Prop_Vine9.gltf` | 4.14 × 1.47 × 1.47 | 44 / 1 | MI_Vine; T07 | Sí | Enredadera plana/colgante sobre restos y rocas; requiere soporte visual. |
| Clover_1 | `RPG/assets/naturaleza/glTF/Clover_1.gltf` | 0.80 × 1.14 × 0.76 | 379 / 1 | Leaves; T08 (revisar COLOR_0) | Sí | Trébol alto de tres hojas; reducir para sotobosque. |
| Clover_2 | `RPG/assets/naturaleza/glTF/Clover_2.gltf` | 0.85 × 1.26 × 0.84 | 615 / 1 | Leaves; T08 (revisar COLOR_0) | Sí | Trébol alto de tres hojas; reducir para sotobosque. |
| Fern_1 | `RPG/assets/naturaleza/glTF/Fern_1.gltf` | 2.83 × 0.84 × 2.65 | 288 / 1 | Leaves; T08 (revisar COLOR_0) | Sí | Helecho ancho para sotobosque húmedo; deja espacio lateral. |
| Flower_3_Group | `RPG/assets/naturaleza/glTF/Flower_3_Group.gltf` | 1.49 × 2.05 × 1.59 | 755 / 2 | Leaves, Flowers; T09 (revisar COLOR_0) | Sí | Flor amarilla o coral con tallo; ajustar altura para no tapar al protagonista. |
| Flower_3_Single | `RPG/assets/naturaleza/glTF/Flower_3_Single.gltf` | 0.91 × 2.07 × 0.88 | 285 / 2 | Leaves, Flowers; T09 (revisar COLOR_0) | Sí | Flor amarilla o coral con tallo; ajustar altura para no tapar al protagonista. |
| Flower_4_Group | `RPG/assets/naturaleza/glTF/Flower_4_Group.gltf` | 1.78 × 2.49 × 1.37 | 1690 / 2 | Leaves, Flowers; T09 (revisar COLOR_0) | Sí | Flor amarilla o coral con tallo; ajustar altura para no tapar al protagonista. |
| Flower_4_Single | `RPG/assets/naturaleza/glTF/Flower_4_Single.gltf` | 1.07 × 2.42 × 0.77 | 642 / 2 | Leaves, Flowers; T09 (revisar COLOR_0) | Sí | Flor amarilla o coral con tallo; ajustar altura para no tapar al protagonista. |
| Grass_Common_Short | `RPG/assets/naturaleza/glTF/Grass_Common_Short.gltf` | 0.64 × 1.33 × 0.74 | 155 / 1 | Grass; T10 (revisar COLOR_0) | Sí | Hierba verde en grupos fuera del centro transitable; reducir altura fuente. |
| Grass_Common_Tall | `RPG/assets/naturaleza/glTF/Grass_Common_Tall.gltf` | 0.90 × 1.87 × 0.99 | 326 / 1 | Grass; T10 (revisar COLOR_0) | Sí | Hierba verde en grupos fuera del centro transitable; reducir altura fuente. |
| Grass_Wispy_Short | `RPG/assets/naturaleza/glTF/Grass_Wispy_Short.gltf` | 1.32 × 1.07 × 1.21 | 494 / 1 | Grass; T10 (revisar COLOR_0) | Sí | Hierba amarillenta para bordes secos, reducida respecto a escala fuente. |
| Grass_Wispy_Tall | `RPG/assets/naturaleza/glTF/Grass_Wispy_Tall.gltf` | 1.54 × 1.67 × 1.59 | 622 / 1 | Grass; T10 (revisar COLOR_0) | Sí | Hierba amarillenta para bordes secos, reducida respecto a escala fuente. |
| Mushroom_Common | `RPG/assets/naturaleza/glTF/Mushroom_Common.gltf` | 0.56 × 0.46 × 0.78 | 880 / 1 | Mushrooms; T11 | Sí | Grupo de hongos claros en sombra, cerca de árboles. |
| Mushroom_Laetiporus | `RPG/assets/naturaleza/glTF/Mushroom_Laetiporus.gltf` | 1.37 × 0.77 × 1.10 | 3216 / 1 | Mushrooms; T11 | Sí | Hongo en repisas naranjas, adosado a tronco/roca; detalle puntual por coste. |
| Petal_1 | `RPG/assets/naturaleza/glTF/Petal_1.gltf` | 0.46 × 0.24 × 0.45 | 13 / 1 | Flowers; T12 | Sí | Corola completa sin tallo, para suelo floral o composición propia. |
| Petal_2 | `RPG/assets/naturaleza/glTF/Petal_2.gltf` | 0.67 × 0.24 × 0.63 | 15 / 1 | Flowers; T12 | Sí | Corola completa sin tallo, para suelo floral o composición propia. |
| Petal_3 | `RPG/assets/naturaleza/glTF/Petal_3.gltf` | 0.62 × 0.19 × 0.61 | 15 / 1 | Flowers; T12 | Sí | Corola completa sin tallo, para suelo floral o composición propia. |
| Petal_4 | `RPG/assets/naturaleza/glTF/Petal_4.gltf` | 0.33 × 0.25 × 0.24 | 30 / 1 | Flowers; T12 | Sí | Corola completa sin tallo, para suelo floral o composición propia. |
| Petal_5 | `RPG/assets/naturaleza/glTF/Petal_5.gltf` | 0.83 × 0.29 × 0.80 | 15 / 1 | Flowers; T12 | Sí | Corola completa sin tallo, para suelo floral o composición propia. |
| Plant_1 | `RPG/assets/naturaleza/glTF/Plant_1.gltf` | 1.27 × 1.01 × 1.39 | 120 / 1 | Leaves; T08 (revisar COLOR_0) | Sí | Planta de hojas largas con puntas cálidas; acento, no vegetación dominante. |
| Plant_1_Big | `RPG/assets/naturaleza/glTF/Plant_1_Big.gltf` | 1.81 × 2.35 × 1.95 | 360 / 1 | Leaves; T08 (revisar COLOR_0) | Sí | Planta de hojas largas con puntas cálidas; acento, no vegetación dominante. |
| Plant_7 | `RPG/assets/naturaleza/glTF/Plant_7.gltf` | 1.05 × 0.25 × 0.96 | 48 / 1 | Leaves; T08 | Sí | Grupo bajo morado de apariencia floral; no asumir follaje verde. |
| Plant_7_Big | `RPG/assets/naturaleza/glTF/Plant_7_Big.gltf` | 1.31 × 0.25 × 1.36 | 112 / 1 | Leaves; T08 | Sí | Grupo bajo morado de apariencia floral; no asumir follaje verde. |

### Rocas, piedras y formaciones (24)

| Nombre exacto | Ruta del modelo | X × Y × Z | Triángulos / superficies | Materiales; texturas | Importa | Utilidad propuesta |
|---|---|---|---|---|---|---|
| Pebble_Round_1 | `RPG/assets/naturaleza/glTF/Pebble_Round_1.gltf` | 0.50 × 0.10 × 0.37 | 136 / 1 | PathRocks; T13 | Sí | Piedra baja con bordes musgosos para senderos y restos dispersos. |
| Pebble_Round_2 | `RPG/assets/naturaleza/glTF/Pebble_Round_2.gltf` | 0.45 × 0.09 × 0.41 | 114 / 1 | PathRocks; T13 | Sí | Piedra baja con bordes musgosos para senderos y restos dispersos. |
| Pebble_Round_3 | `RPG/assets/naturaleza/glTF/Pebble_Round_3.gltf` | 0.45 × 0.10 × 0.48 | 128 / 1 | PathRocks; T13 | Sí | Piedra baja con bordes musgosos para senderos y restos dispersos. |
| Pebble_Round_4 | `RPG/assets/naturaleza/glTF/Pebble_Round_4.gltf` | 0.41 × 0.10 × 0.45 | 126 / 1 | PathRocks; T13 | Sí | Piedra baja con bordes musgosos para senderos y restos dispersos. |
| Pebble_Round_5 | `RPG/assets/naturaleza/glTF/Pebble_Round_5.gltf` | 0.42 × 0.10 × 0.35 | 124 / 1 | PathRocks; T13 | Sí | Piedra baja con bordes musgosos para senderos y restos dispersos. |
| Pebble_Square_1 | `RPG/assets/naturaleza/glTF/Pebble_Square_1.gltf` | 0.43 × 0.13 × 0.44 | 104 / 1 | PathRocks; T13 | Sí | Piedra baja con bordes musgosos para senderos y restos dispersos. |
| Pebble_Square_2 | `RPG/assets/naturaleza/glTF/Pebble_Square_2.gltf` | 0.39 × 0.14 × 0.28 | 78 / 1 | PathRocks; T13 | Sí | Piedra baja con bordes musgosos para senderos y restos dispersos. |
| Pebble_Square_3 | `RPG/assets/naturaleza/glTF/Pebble_Square_3.gltf` | 0.37 × 0.16 × 0.32 | 52 / 1 | PathRocks; T13 | Sí | Piedra baja con bordes musgosos para senderos y restos dispersos. |
| Pebble_Square_4 | `RPG/assets/naturaleza/glTF/Pebble_Square_4.gltf` | 0.34 × 0.17 × 0.29 | 48 / 1 | PathRocks; T13 | Sí | Piedra baja con bordes musgosos para senderos y restos dispersos. |
| Pebble_Square_5 | `RPG/assets/naturaleza/glTF/Pebble_Square_5.gltf` | 0.35 × 0.15 × 0.45 | 72 / 1 | PathRocks; T13 | Sí | Piedra baja con bordes musgosos para senderos y restos dispersos. |
| Pebble_Square_6 | `RPG/assets/naturaleza/glTF/Pebble_Square_6.gltf` | 0.46 × 0.14 × 0.26 | 65 / 1 | PathRocks; T13 | Sí | Piedra baja con bordes musgosos para senderos y restos dispersos. |
| RockPath_Round_Small_1 | `RPG/assets/naturaleza/glTF/RockPath_Round_Small_1.gltf` | 1.06 × 0.11 × 1.48 | 998 / 1 | PathRocks; T13 | Sí | Grupo de adoquines planos, especialmente útil en tramo antiguo hacia ruinas. |
| RockPath_Round_Small_2 | `RPG/assets/naturaleza/glTF/RockPath_Round_Small_2.gltf` | 1.14 × 0.10 × 1.35 | 1126 / 1 | PathRocks; T13 | Sí | Grupo de adoquines planos, especialmente útil en tramo antiguo hacia ruinas. |
| RockPath_Round_Small_3 | `RPG/assets/naturaleza/glTF/RockPath_Round_Small_3.gltf` | 1.18 × 0.11 × 1.29 | 1002 / 1 | PathRocks; T13 | Sí | Grupo de adoquines planos, especialmente útil en tramo antiguo hacia ruinas. |
| RockPath_Round_Thin | `RPG/assets/naturaleza/glTF/RockPath_Round_Thin.gltf` | 1.46 × 0.11 × 2.09 | 2254 / 1 | PathRocks; T13 | Sí | Grupo de adoquines planos, especialmente útil en tramo antiguo hacia ruinas. |
| RockPath_Round_Wide | `RPG/assets/naturaleza/glTF/RockPath_Round_Wide.gltf` | 2.11 × 0.11 × 2.13 | 3500 / 1 | PathRocks; T13 | Sí | Grupo de adoquines planos, especialmente útil en tramo antiguo hacia ruinas. |
| RockPath_Square_Small_1 | `RPG/assets/naturaleza/glTF/RockPath_Square_Small_1.gltf` | 1.02 × 0.15 × 0.97 | 783 / 1 | PathRocks; T13 | Sí | Grupo de adoquines planos, especialmente útil en tramo antiguo hacia ruinas. |
| RockPath_Square_Small_2 | `RPG/assets/naturaleza/glTF/RockPath_Square_Small_2.gltf` | 0.99 × 0.15 × 0.97 | 559 / 1 | PathRocks; T13 | Sí | Grupo de adoquines planos, especialmente útil en tramo antiguo hacia ruinas. |
| RockPath_Square_Small_3 | `RPG/assets/naturaleza/glTF/RockPath_Square_Small_3.gltf` | 0.84 × 0.17 × 1.08 | 568 / 1 | PathRocks; T13 | Sí | Grupo de adoquines planos, especialmente útil en tramo antiguo hacia ruinas. |
| RockPath_Square_Thin | `RPG/assets/naturaleza/glTF/RockPath_Square_Thin.gltf` | 1.56 × 0.18 × 1.99 | 1793 / 1 | PathRocks; T13 | Sí | Grupo de adoquines planos, especialmente útil en tramo antiguo hacia ruinas. |
| RockPath_Square_Wide | `RPG/assets/naturaleza/glTF/RockPath_Square_Wide.gltf` | 2.05 × 0.18 × 1.99 | 2256 / 1 | PathRocks; T13 | Sí | Grupo de adoquines planos, especialmente útil en tramo antiguo hacia ruinas. |
| Rock_Medium_1 | `RPG/assets/naturaleza/glTF/Rock_Medium_1.gltf` | 3.23 × 2.26 × 2.99 | 342 / 1 | Rocks; T14 | Sí | Roca musgosa para agrupaciones, límites naturales y desniveles visuales. |
| Rock_Medium_2 | `RPG/assets/naturaleza/glTF/Rock_Medium_2.gltf` | 3.05 × 1.90 × 2.48 | 244 / 1 | Rocks; T14 | Sí | Roca musgosa para agrupaciones, límites naturales y desniveles visuales. |
| Rock_Medium_3 | `RPG/assets/naturaleza/glTF/Rock_Medium_3.gltf` | 3.42 × 2.32 × 3.48 | 522 / 1 | Rocks; T14 | Sí | Roca musgosa para agrupaciones, límites naturales y desniveles visuales. |

### Elementos de madera (4)

| Nombre exacto | Ruta del modelo | X × Y × Z | Triángulos / superficies | Materiales; texturas | Importa | Utilidad propuesta |
|---|---|---|---|---|---|---|
| Prop_Support | `RPG/assets/aldea/glTF/Prop_Support.gltf` | 0.20 × 1.71 × 2.04 | 16 / 1 | MI_WoodTrim; T15 | Sí | Soporte/viga arquitectónica para cobertizo sencillo o restos de madera. |
| Roof_FrontSupports | `RPG/assets/aldea/glTF/Roof_FrontSupports.gltf` | 5.49 × 0.23 × 0.65 | 60 / 1 | MI_WoodTrim; T15 | Sí | Soporte/viga arquitectónica para cobertizo sencillo o restos de madera. |
| Roof_Log | `RPG/assets/aldea/glTF/Roof_Log.gltf` | 1.15 × 1.39 × 10.70 | 164 / 1 | MI_WoodTrim; T15 | Sí | Viga arquitectónica larga (~10.70), no tronco caído natural; adaptar solo en instancia. |
| Roof_Support2 | `RPG/assets/aldea/glTF/Roof_Support2.gltf` | 0.20 × 0.74 × 0.77 | 84 / 1 | MI_WoodTrim; T15 | Sí | Soporte/viga arquitectónica para cobertizo sencillo o restos de madera. |

### Cercas, señales y estructuras pequeñas (5)

| Nombre exacto | Ruta del modelo | X × Y × Z | Triángulos / superficies | Materiales; texturas | Importa | Utilidad propuesta |
|---|---|---|---|---|---|---|
| Prop_MetalFence_Ornament | `RPG/assets/aldea/glTF/Prop_MetalFence_Ornament.gltf` | 1.95 × 2.85 × 0.16 | 3988 / 1 | MI_MetalOrnaments; T16 | Sí | Reja alta para restos de recinto antiguo; evitar aspecto urbano repetido. |
| Prop_MetalFence_Simple | `RPG/assets/aldea/glTF/Prop_MetalFence_Simple.gltf` | 1.95 × 2.87 × 0.16 | 2744 / 1 | MI_MetalOrnaments; T16 | Sí | Reja alta para restos de recinto antiguo; evitar aspecto urbano repetido. |
| Prop_WoodenFence_Extension1 | `RPG/assets/aldea/glTF/Prop_WoodenFence_Extension1.gltf` | 2.05 × 0.84 × 0.11 | 32 / 1 | MI_WoodTrim; T15 | Sí | Cerca rural baja cerca de la entrada de aldea o campamento. |
| Prop_WoodenFence_Extension2 | `RPG/assets/aldea/glTF/Prop_WoodenFence_Extension2.gltf` | 2.03 × 0.84 × 0.11 | 28 / 1 | MI_WoodTrim; T15 | Sí | Cerca rural baja cerca de la entrada de aldea o campamento. |
| Prop_WoodenFence_Single | `RPG/assets/aldea/glTF/Prop_WoodenFence_Single.gltf` | 2.06 × 0.84 × 0.12 | 40 / 1 | MI_WoodTrim; T15 | Sí | Cerca rural baja cerca de la entrada de aldea o campamento. |

### Elementos para campamentos (25)

| Nombre exacto | Ruta del modelo | X × Y × Z | Triángulos / superficies | Materiales; texturas | Importa | Utilidad propuesta |
|---|---|---|---|---|---|---|
| Prop_Crate | `RPG/assets/aldea/glTF/Prop_Crate.gltf` | 1.08 × 1.06 × 1.08 | 230 / 1 | MI_WoodTrim; T15 | Sí | Caja de madera simple de bajo coste. |
| Prop_Wagon | `RPG/assets/aldea/glTF/Prop_Wagon.gltf` | 1.95 × 1.53 × 4.02 | 1672 / 1 | MI_WoodTrim_Wear; T15 | Sí | Carro de dos ruedas, apoyo narrativo junto a entrada/campamento. |
| Axe_Bronze | `RPG/assets/objetos_medievales/glTF/Axe_Bronze.gltf` | 0.29 × 0.83 × 0.05 | 826 / 1 | MI_Trim_Props_Vertex; T17 (revisar COLOR_0) | Sí | Hacha decorativa de trabajo, sin implementar combate. |
| Bag | `RPG/assets/objetos_medievales/glTF/Bag.gltf` | 0.66 × 0.80 × 0.54 | 858 / 2 | MI_Trim_Cloth, MI_Trim_Furniture; T18 (revisar COLOR_0) | Sí | Saco de provisiones. |
| Barrel | `RPG/assets/objetos_medievales/glTF/Barrel.gltf` | 0.70 × 0.90 × 0.70 | 824 / 2 | MI_Trim_Furniture, MI_Trim_Metal; T19 (revisar COLOR_0) | Sí | Barril de provisiones. |
| Bench | `RPG/assets/objetos_medievales/glTF/Bench.gltf` | 2.78 × 0.53 × 0.53 | 404 / 2 | MI_Trim_Furniture, MI_Trim_Metal; T19 (revisar COLOR_0) | Sí | Banco largo de campamento. |
| Bucket_Metal | `RPG/assets/objetos_medievales/glTF/Bucket_Metal.gltf` | 0.49 × 0.37 × 0.45 | 540 / 1 | MI_Trim_Metal; T20 | Sí | Cubo metálico. |
| Bucket_Wooden_1 | `RPG/assets/objetos_medievales/glTF/Bucket_Wooden_1.gltf` | 0.43 × 0.29 × 0.38 | 976 / 2 | MI_Trim_Furniture, MI_Trim_Metal; T19 | Sí | Cubo de madera. |
| Candle_1 | `RPG/assets/objetos_medievales/glTF/Candle_1.gltf` | 0.09 × 0.13 × 0.11 | 212 / 1 | MI_Trim_Props; T17 | Sí | Vela pequeña estática; no incluye llama funcional. |
| Candle_2 | `RPG/assets/objetos_medievales/glTF/Candle_2.gltf` | 0.09 × 0.25 × 0.10 | 210 / 1 | MI_Trim_Props; T17 | Sí | Vela alta estática; no incluye llama funcional. |
| Cauldron | `RPG/assets/objetos_medievales/glTF/Cauldron.gltf` | 0.99 × 0.82 × 0.94 | 2020 / 1 | MI_Trim_Metal; T20 | Sí | Caldero de cocina; sin hoguera incluida. |
| Chest_Wood | `RPG/assets/objetos_medievales/glTF/Chest_Wood.gltf` | 1.28 × 0.72 × 0.76 | 2546 / 4 | MI_Trim_Furniture, MI_Trim_Metal; T19 | Sí | Cofre de suministros. |
| Crate_Wooden | `RPG/assets/objetos_medievales/glTF/Crate_Wooden.gltf` | 0.84 × 0.93 × 0.91 | 1576 / 2 | MI_Trim_Furniture, MI_Trim_Metal; T19 (revisar COLOR_0) | Sí | Caja reforzada de suministros; más cara que Prop_Crate. |
| FarmCrate_Empty | `RPG/assets/objetos_medievales/glTF/FarmCrate_Empty.gltf` | 0.71 × 0.24 × 0.41 | 1928 / 2 | MI_Trim_Furniture, MI_Trim_Metal; T19 | Sí | Caja abierta pequeña, detalle cercano. |
| Lantern_Wall | `RPG/assets/objetos_medievales/glTF/Lantern_Wall.gltf` | 0.36 × 1.34 × 1.30 | 2822 / 1 | MI_Trim_Metal; T20 | Sí | Farol con soporte de pared; necesita poste o estructura, sin luz añadida. |
| Mug | `RPG/assets/objetos_medievales/glTF/Mug.gltf` | 0.19 × 0.18 × 0.15 | 268 / 2 | MI_Trim_Metal, MI_Trim_Furniture; T21 | Sí | Jarra de madera y metal, detalle cercano. |
| Pot_1 | `RPG/assets/objetos_medievales/glTF/Pot_1.gltf` | 0.54 × 0.22 × 0.49 | 1068 / 1 | MI_Trim_Metal; T20 | Sí | Olla abierta. |
| Pot_1_Lid | `RPG/assets/objetos_medievales/glTF/Pot_1_Lid.gltf` | 0.54 × 0.28 × 0.49 | 1292 / 1 | MI_Trim_Metal; T20 | Sí | Olla con tapa; alternativa a Pot_1. |
| Pouch_Large | `RPG/assets/objetos_medievales/glTF/Pouch_Large.gltf` | 0.23 × 0.16 × 0.12 | 730 / 2 | MI_Trim_Props_Vertex, MI_Trim_Metal; T22 (revisar COLOR_0) | Sí | Bolsa de cuero, detalle cercano. |
| Rope_1 | `RPG/assets/objetos_medievales/glTF/Rope_1.gltf` | 0.56 × 0.10 × 0.61 | 1748 / 1 | MI_Trim_Furniture; T23 | Sí | Cuerda enrollada compacta. |
| Rope_2 | `RPG/assets/objetos_medievales/glTF/Rope_2.gltf` | 0.81 × 0.12 × 0.85 | 1460 / 1 | MI_Trim_Furniture; T23 | Sí | Cuerda enrollada irregular. |
| Rope_3 | `RPG/assets/objetos_medievales/glTF/Rope_3.gltf` | 1.23 × 0.10 × 0.95 | 1748 / 1 | MI_Trim_Furniture; T23 | Sí | Cuerda extendida/enrollada más ancha. |
| Stool | `RPG/assets/objetos_medievales/glTF/Stool.gltf` | 0.47 × 0.59 × 0.47 | 152 / 1 | MI_Trim_Furniture; T23 (revisar COLOR_0) | Sí | Taburete de bajo coste. |
| Table_Large | `RPG/assets/objetos_medievales/glTF/Table_Large.gltf` | 2.85 × 0.81 × 1.10 | 986 / 2 | MI_Trim_Furniture, MI_Trim_Metal; T19 (revisar COLOR_0) | Sí | Mesa de provisiones. |
| Torch_Metal | `RPG/assets/objetos_medievales/glTF/Torch_Metal.gltf` | 0.22 × 0.65 × 0.39 | 970 / 1 | MI_Trim_Metal; T20 | Sí | Soporte de antorcha metálico, sin llama ni luz funcional. |

### Elementos adaptables a ruinas antiguas (14)

| Nombre exacto | Ruta del modelo | X × Y × Z | Triángulos / superficies | Materiales; texturas | Importa | Utilidad propuesta |
|---|---|---|---|---|---|---|
| Corner_ExteriorWide_Brick | `RPG/assets/aldea/glTF/Corner_ExteriorWide_Brick.gltf` | 0.71 × 3.04 × 0.76 | 2882 / 1 | MI_RockTrim; T24 | Sí | Hilera vertical de piedra para esquina de restos o pilares compuestos. |
| Corner_Exterior_Brick | `RPG/assets/aldea/glTF/Corner_Exterior_Brick.gltf` | 0.53 × 3.02 × 0.58 | 3102 / 1 | MI_RockTrim; T24 | Sí | Hilera vertical de piedra para esquina de restos o pilares compuestos. |
| Floor_UnevenBrick | `RPG/assets/aldea/glTF/Floor_UnevenBrick.gltf` | 2.00 × 0.02 × 2.00 | 4 / 1 | MI_UnevenBrick; T25 | Sí | Pavimento antiguo modular de muy poco espesor; requiere suelo real. |
| Prop_Brick1 | `RPG/assets/aldea/glTF/Prop_Brick1.gltf` | 0.35 × 0.21 × 0.25 | 108 / 1 | MI_RockTrim; T24 | Sí | Bloque suelto para escombro de mampostería. |
| Prop_Brick2 | `RPG/assets/aldea/glTF/Prop_Brick2.gltf` | 0.40 × 0.24 × 0.22 | 94 / 1 | MI_RockTrim; T24 | Sí | Bloque suelto para escombro de mampostería. |
| Prop_Brick3 | `RPG/assets/aldea/glTF/Prop_Brick3.gltf` | 0.38 × 0.25 × 0.22 | 126 / 1 | MI_RockTrim; T24 | Sí | Bloque suelto para escombro de mampostería. |
| Prop_Brick4 | `RPG/assets/aldea/glTF/Prop_Brick4.gltf` | 0.26 × 0.25 × 0.22 | 126 / 1 | MI_RockTrim; T24 | Sí | Bloque suelto para escombro de mampostería. |
| Stairs_Exterior_Straight | `RPG/assets/aldea/glTF/Stairs_Exterior_Straight.gltf` | 2.00 × 1.20 × 2.08 | 62 / 2 | MI_RockTrim, MI_Brick; T26 | Sí | Escalera de piedra para pequeño desnivel construido; requiere colisión propia. |
| Wall_Arch | `RPG/assets/aldea/glTF/Wall_Arch.gltf` | 2.00 × 3.00 × 0.06 | 196 / 1 | MI_WoodTrim; T15 | Sí | Marco de arco de madera plano; no es un arco de piedra antiguo. |
| Wall_UnevenBrick_Door_Round | `RPG/assets/aldea/glTF/Wall_UnevenBrick_Door_Round.gltf` | 2.00 × 3.12 × 0.41 | 136 / 3 | MI_WoodTrim, MI_Plaster, MI_UnevenBrick; T27 | Sí | Muro intacto mixto con madera/revoque; adaptar composición, no ruina fracturada lista. |
| Wall_UnevenBrick_Straight | `RPG/assets/aldea/glTF/Wall_UnevenBrick_Straight.gltf` | 2.00 × 3.12 × 0.41 | 56 / 3 | MI_WoodTrim, MI_Plaster, MI_UnevenBrick; T27 | Sí | Muro intacto mixto con madera/revoque; adaptar composición, no ruina fracturada lista. |
| Vase_2 | `RPG/assets/objetos_medievales/glTF/Vase_2.gltf` | 0.69 × 0.52 × 0.69 | 598 / 1 | MI_Trim_Props_Vertex; T17 (revisar COLOR_0) | Sí | Vasija ornamental para hallazgo antiguo; revisar color de vértice. |
| Vase_4 | `RPG/assets/objetos_medievales/glTF/Vase_4.gltf` | 0.36 × 0.49 × 0.36 | 598 / 1 | MI_Trim_Props_Vertex; T17 (revisar COLOR_0) | Sí | Vasija ornamental para hallazgo antiguo; revisar color de vértice. |
| Vase_Rubble_Medium | `RPG/assets/objetos_medievales/glTF/Vase_Rubble_Medium.gltf` | 0.80 × 0.17 × 0.60 | 1113 / 1 | MI_Trim_Props_Vertex; T17 (revisar COLOR_0) | Sí | Restos cerámicos para ruinas; color de vértice requiere revisión local. |

## Conjuntos de texturas con rutas exactas

Incluyen imágenes declaradas en cada glTF seleccionado (albedo, normal y ORM cuando existen); no son paquetes nuevos ni materiales cambiados. El JSON conserva las propiedades PBR fuente y los flags importados.

- **T01:** `RPG/assets/naturaleza/glTF/Bark_NormalTree_Normal.png`; `RPG/assets/naturaleza/glTF/Bark_NormalTree.png`; `RPG/assets/naturaleza/glTF/Leaves_NormalTree_C.png`
- **T02:** `RPG/assets/naturaleza/glTF/Bark_TwistedTree_Normal.png`; `RPG/assets/naturaleza/glTF/Bark_TwistedTree.png`; `RPG/assets/naturaleza/glTF/Leaves_TwistedTree_C.png`
- **T03:** `RPG/assets/naturaleza/glTF/Bark_NormalTree_Normal.png`; `RPG/assets/naturaleza/glTF/Bark_NormalTree.png`; `RPG/assets/naturaleza/glTF/Leaf_Pine_C.png`
- **T04:** `RPG/assets/naturaleza/glTF/Bark_DeadTree_Normal.png`; `RPG/assets/naturaleza/glTF/Bark_DeadTree.png`
- **T05:** `RPG/assets/naturaleza/glTF/Leaves_TwistedTree_C.png`
- **T06:** `RPG/assets/naturaleza/glTF/Leaves_NormalTree_C.png`; `RPG/assets/naturaleza/glTF/Flowers.png`
- **T07:** `RPG/assets/aldea/glTF/T_VineLeaf_png.png`
- **T08:** `RPG/assets/naturaleza/glTF/Leaves.png`
- **T09:** `RPG/assets/naturaleza/glTF/Leaves.png`; `RPG/assets/naturaleza/glTF/Flowers.png`
- **T10:** `RPG/assets/naturaleza/glTF/Grass.png`
- **T11:** `RPG/assets/naturaleza/glTF/Mushrooms.png`
- **T12:** `RPG/assets/naturaleza/glTF/Flowers.png`
- **T13:** `RPG/assets/naturaleza/glTF/PathRocks_Diffuse.png`
- **T14:** `RPG/assets/naturaleza/glTF/Rocks_Diffuse.png`
- **T15:** `RPG/assets/aldea/glTF/T_WoodTrim_Normal.png`; `RPG/assets/aldea/glTF/T_WoodTrim_BaseColor.png`; `RPG/assets/aldea/glTF/T_WoodTrim_Roughness.png`
- **T16:** `RPG/assets/aldea/glTF/T_MetalOrnaments_BaseColor.png`; `RPG/assets/aldea/glTF/T_MetalOrnaments_Roughness.png`
- **T17:** `RPG/assets/objetos_medievales/glTF/T_Trim_Props_Normal.png`; `RPG/assets/objetos_medievales/glTF/T_Trim_Props_BaseColor.png`; `RPG/assets/objetos_medievales/glTF/T_Trim_Props_ORM.png`
- **T18:** `RPG/assets/objetos_medievales/glTF/T_Trim_Cloth_Normal.png`; `RPG/assets/objetos_medievales/glTF/T_Trim_Cloth_BaseColor.png`; `RPG/assets/objetos_medievales/glTF/T_Trim_Cloth_ORM.png`; `RPG/assets/objetos_medievales/glTF/T_Trim_Furniture_Normal.png`; `RPG/assets/objetos_medievales/glTF/T_Trim_Furniture_BaseColor.png`; `RPG/assets/objetos_medievales/glTF/T_Trim_Furniture_ORM.png`
- **T19:** `RPG/assets/objetos_medievales/glTF/T_Trim_Furniture_Normal.png`; `RPG/assets/objetos_medievales/glTF/T_Trim_Furniture_BaseColor.png`; `RPG/assets/objetos_medievales/glTF/T_Trim_Furniture_ORM.png`; `RPG/assets/objetos_medievales/glTF/T_Trim_Metal_Normal.png`; `RPG/assets/objetos_medievales/glTF/T_Trim_Metal_BaseColor.png`; `RPG/assets/objetos_medievales/glTF/T_Trim_Metal_ORM.png`
- **T20:** `RPG/assets/objetos_medievales/glTF/T_Trim_Metal_Normal.png`; `RPG/assets/objetos_medievales/glTF/T_Trim_Metal_BaseColor.png`; `RPG/assets/objetos_medievales/glTF/T_Trim_Metal_ORM.png`
- **T21:** `RPG/assets/objetos_medievales/glTF/T_Trim_Metal_Normal.png`; `RPG/assets/objetos_medievales/glTF/T_Trim_Metal_BaseColor.png`; `RPG/assets/objetos_medievales/glTF/T_Trim_Metal_ORM.png`; `RPG/assets/objetos_medievales/glTF/T_Trim_Furniture_Normal.png`; `RPG/assets/objetos_medievales/glTF/T_Trim_Furniture_BaseColor.png`; `RPG/assets/objetos_medievales/glTF/T_Trim_Furniture_ORM.png`
- **T22:** `RPG/assets/objetos_medievales/glTF/T_Trim_Props_Normal.png`; `RPG/assets/objetos_medievales/glTF/T_Trim_Props_BaseColor.png`; `RPG/assets/objetos_medievales/glTF/T_Trim_Props_ORM.png`; `RPG/assets/objetos_medievales/glTF/T_Trim_Metal_Normal.png`; `RPG/assets/objetos_medievales/glTF/T_Trim_Metal_BaseColor.png`; `RPG/assets/objetos_medievales/glTF/T_Trim_Metal_ORM.png`
- **T23:** `RPG/assets/objetos_medievales/glTF/T_Trim_Furniture_Normal.png`; `RPG/assets/objetos_medievales/glTF/T_Trim_Furniture_BaseColor.png`; `RPG/assets/objetos_medievales/glTF/T_Trim_Furniture_ORM.png`
- **T24:** `RPG/assets/aldea/glTF/T_RockTrim_Normal.png`; `RPG/assets/aldea/glTF/T_RockTrim_BaseColor.png`; `RPG/assets/aldea/glTF/T_RockTrim_ORM.png`
- **T25:** `RPG/assets/aldea/glTF/T_UnevenBrick_Normal.png`; `RPG/assets/aldea/glTF/T_UnevenBrick_BaseColor.png`; `RPG/assets/aldea/glTF/T_UnevenBrick_Roughness.png`
- **T26:** `RPG/assets/aldea/glTF/T_RockTrim_Normal.png`; `RPG/assets/aldea/glTF/T_RockTrim_BaseColor.png`; `RPG/assets/aldea/glTF/T_RockTrim_ORM.png`; `RPG/assets/aldea/glTF/T_Brick_Normal.png`; `RPG/assets/aldea/glTF/T_Brick_BaseColor.png`; `RPG/assets/aldea/glTF/T_Brick_Roughness.png`
- **T27:** `RPG/assets/aldea/glTF/T_WoodTrim_Normal.png`; `RPG/assets/aldea/glTF/T_WoodTrim_BaseColor.png`; `RPG/assets/aldea/glTF/T_WoodTrim_Roughness.png`; `RPG/assets/aldea/glTF/T_Plaster_Normal.png`; `RPG/assets/aldea/glTF/T_Plaster_BaseColor.png`; `RPG/assets/aldea/glTF/T_Plaster_ORM.png`; `RPG/assets/aldea/glTF/T_UnevenBrick_Normal.png`; `RPG/assets/aldea/glTF/T_UnevenBrick_BaseColor.png`; `RPG/assets/aldea/glTF/T_UnevenBrick_Roughness.png`

## Cierre de alcance

Se añadió RPG/tests/auditar_assets_bosque.gd, este informe y un registro en RPG/docs/estado_proyecto.md; inventario enlaza esta revisión complementaria. AGENTS.md revisado sin cambios: no se incorporan sistemas, paquetes ni convenciones permanentes. Plano, escenas existentes, scripts jugables, NPCs y assets originales sin editar. La escena temporal y las evidencias están únicamente en RPG/logs/auditoria_assets_bosque/. Sin commits ni pushes. **Detenerse aquí y esperar aprobación del usuario antes de diseñar o construir el bosque.**
