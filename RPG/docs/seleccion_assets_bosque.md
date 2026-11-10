# Fase 6A.0 — selección propuesta de assets del bosque

Fecha: **3 de noviembre de 2026**. **72 modelos propuestos; pendientes de aprobación visual. Bosque sin construir.** No se modifica aldea, controles, protagonista, NPCs, minijuegos ni project.godot. La referencia artística se interpreta desde las zonas y rasgos descritos en la solicitud; no se ha recibido una imagen de referencia en esta tarea.

[Galería final de 40 capturas](../logs/seleccion_assets_bosque/2026-11-03T22-04-32/galeria.html) · [Catálogo temporal](../logs/seleccion_assets_bosque/2026-11-03T22-04-32/catalogo_temporal.tscn) · [Tabla CSV](../logs/seleccion_assets_bosque/2026-11-03T22-04-32/seleccion.csv) · [Importación y compatibilidad](compatibilidad_assets_bosque.md) · [Manifest de selección](../tests/seleccion_assets_bosque.json)

Los originales y evidencias son locales: las evidencias bajo RPG/logs/ no se distribuyen por Git. Este documento y el manifest conservan la selección reproducible.

## Recuento comprobado

| Paquete nuevo | Archivos 3D | Entradas sin duplicar formatos | Geometrías diferentes medidas | Seleccionados |
|---|---:|---:|---:|---:|
| KayKit Forest Nature Pack 1.0 | 420 | 105 | 101 | 10 |
| Forest Nature Updated, hooray4brains | 60 | 60 | 60 | 23 |
| **Nuevos** | **480** | **165** | **161** | **33** |
| Quaternius ya disponible | 338 | 338 | No se recalcula aquí su equivalencia geométrica global | 39 |
| **Recursos canónicos del proyecto** | | **503** | No equivale a 503 siluetas diferentes | **72** |

Los 420 archivos KayKit son 105 glTF, 105 OBJ y 210 FBX (normal y Unity): 315 exportaciones alternativas no son modelos adicionales. Se comprobaron las cuatro rutas por nombre y 315 comparaciones de dimensiones y triángulos importados; 0 diferencias por encima de 0.0001 unidades. Dentro de las 165 entradas hay cuatro pares de hierba con geometría compartida; por eso se informa también **161 geometrías**, sin confundirlo con diversidad artística ni con identidad de material. Las variantes de una/dos caras siguen siendo alternativas, no variedad para el paisaje.

Se validaron 818 recursos importables del proyecto contando todos los formatos, sin fallos de carga/malla/material ausente. Los 72 seleccionados cargaron y se renderizaron; no se detectaron dependencias externas glTF ausentes. Detalle y limitaciones en el informe técnico.

## Dirección artística y suficiencia

**Sí, podemos empezar a construir el bosque tras aprobar esta selección, sin descargar nada más.** Forest Nature Updated resuelve las carencias más visibles de la auditoría anterior: árboles ramificados de copa plana, arbustos verdes, tocón, tronco caído, hongos moteados y bloques naturales. KayKit tiene mayor número bruto de entradas (105), especialmente rocas y matorrales; Forest Nature aporta mayor variedad útil de familias de árbol para esta referencia. Quaternius aporta helechos, detalle musgoso y prácticamente todo el mobiliario/arquitectura.

La base propuesta es **roble grande A01 + roble medio A02 + olmo A05**; abedul A04 cerca del agua, pino A07 y spruce A08 en fondos altos. A03 es un árbol hito ocasional, con peana verde y roca incorporadas: no usarlo como dosel repetido. KayKit verde lima, copas lisas/cúbicas y troncos naranjas contrasta con el verde frío facetado nuevo y con las hojas texturizadas Quaternius. Por eso se descartan las copas cúbicas y se dejan B05/B06 como opcionales; los CommonTree A09/A10 se concentran en el enlace desde aldea. **Compatibilidad por zonas y escala; no se afirma uniformidad artística automática entre paquetes.** El ajuste de tonos, si se aprueba después, deberá hacerse con materiales locales derivados, sin alterar originales.

| Zona prevista | Recursos principales | Condición de uso futuro |
|---|---|---|
| Entrada desde aldea | A09/A10, F01/F02, B10/B12, C10/C12 | Transición gradual a A01/A02; conservar contrato aldea_bosque_norte ↔ bosque_aldea_sur y no abrir límites en esta fase |
| Bosque central y ramales | A01/A02/A05, B01/B03/B07/B09, C03/C04 | Crear senderos despejados; cilindros de tronco separados de copas; no diseñar densidad antes de revisar oclusión a tamaño 15 |
| Claro del campamento | A13/A14, D01–D12, B14/B18 | Sin tienda/hoguera completa en los paquetes: componer refugio y hogar propios posteriormente |
| Ruinas antiguas | A11/A12, E01–E08, F05 | Kit adaptable, no ruina fracturada lista: no confundir muro mixto intacto con arquitectura antigua terminada |
| Mirador natural | A06, C01/C02/C05/C07 | Roca visual no equivale a plataforma transitable; resolver suelo y colisión del mirador en su fase |
| Laguna y arroyo | A04, B10/B14/B15, C08/C09, A14 en ribera | Agua, cauce y orillas deben diseñarse como geometría/shader regional; el suelo de muestra no incluye laguna navegable |
| Pequeños puentes | Madera propia futura; referencia técnica del puente actual del proyecto | Los paquetes no incluyen un puente pequeño terminado. Se puede derivar una escena regional propia sin editar el puente/aldea actual |

No existen carencias que justifiquen descargar otro paquete ahora. Persisten piezas que habrá que componer: agua/cauce, puentes pequeños, tienda/refugio y hogar, señal con destinos y ruina envejecida. Esa autoría local queda para una fase autorizada; no se ha realizado aquí.

## Organización y prioridades

| Grupo | Modelos |
|---|---:|
| A. Vegetación principal | 14 |
| B. Vegetación secundaria | 20 |
| C. Rocas y terreno | 13 |
| D. Campamento | 12 |
| E. Ruinas | 8 |
| F. Decoración ambiental | 5 |

Prioridades: **26 esenciales**, **34 complementarios**, **12 opcionales**. Los opcionales son reserva artística, no elementos que deban colocarse todos. Hay 23 Forest Nature Updated, 10 KayKit, 14 Quaternius Nature, 14 Quaternius Props y 11 Quaternius Village. Cada ID corresponde a una ruta única.

## Lista definitiva propuesta

La categoría de cada fila es la del grupo A–F donde aparece. Escalas y medidas detalladas por ID se encuentran en el informe técnico y en los rótulos de las capturas.

### A. Vegetación principal

| ID | Nombre exacto | Ruta | Paquete | Categoría | Uso previsto | Prioridad |
|---|---|---|---|---|---|---|
| A01 | Flat_Tree_Oak_large_green | `RPG/assets/bosque/forest_nature_updated/Trees/Oak/Flat_Tree_Oak_large_green.glb` | Forest Nature Updated | Vegetacion principal | Dosel frondoso principal; tres masas de copa y tronco ramificado. | esencial |
| A02 | Flat_Tree_Oak_medium_green | `RPG/assets/bosque/forest_nature_updated/Trees/Oak/Flat_Tree_Oak_medium_green.glb` | Forest Nature Updated | Vegetacion principal | Variante de copa más compacta para bordes de caminos. | esencial |
| A03 | Flat_Tree_Oak_hero_green | `RPG/assets/bosque/forest_nature_updated/Trees/Oak/Flat_Tree_Oak_hero_green.glb` | Forest Nature Updated | Vegetacion principal | Árbol hito del claro; incluye peana verde y roca, no usar junto al agua sin resolver el apoyo. | complementario |
| A04 | Flat_Tree_Birch_medium_green | `RPG/assets/bosque/forest_nature_updated/Trees/Birch/Flat_Tree_Birch_medium_green.glb` | Forest Nature Updated | Vegetacion principal | Abedul de corteza clara para borde de laguna y contraste vertical. | complementario |
| A05 | Flat_Tree_Elm_green | `RPG/assets/bosque/forest_nature_updated/Trees/Other/Flat_Tree_Elm_green.glb` | Forest Nature Updated | Vegetacion principal | Copa ancha de tono frío para variar el roble sin multiplicar tamaños. | esencial |
| A06 | Flat_Tree_Windswept_dark_green | `RPG/assets/bosque/forest_nature_updated/Trees/Other/Flat_Tree_Windswept_dark_green.glb` | Forest Nature Updated | Vegetacion principal | Árbol inclinado de silueta irregular para el mirador natural. | complementario |
| A07 | Flat_Tree_Pine_small | `RPG/assets/bosque/forest_nature_updated/Trees/Pine/Flat_Tree_Pine_small.glb` | Forest Nature Updated | Vegetacion principal | Pino abierto de ramas visibles; transición a zonas de roca. | esencial |
| A08 | Flat_Tree_Spruce_medium | `RPG/assets/bosque/forest_nature_updated/Trees/Spruce/Flat_Tree_Spruce_medium.glb` | Forest Nature Updated | Vegetacion principal | Conífera densa azul verdosa para fondos; distinta silueta del pino. | complementario |
| A09 | CommonTree_3 | `RPG/assets/naturaleza/glTF/CommonTree_3.gltf` | Quaternius Nature | Vegetacion principal | Enlace visual con la aldea; utilizar agrupado en la entrada, no alternar cada ejemplar con copas planas. | complementario |
| A10 | CommonTree_5 | `RPG/assets/naturaleza/glTF/CommonTree_5.gltf` | Quaternius Nature | Vegetacion principal | Segunda silueta verde de Quaternius para la transición desde aldea. | complementario |
| A11 | Tree_Bare_1_C_Color1 | `RPG/assets/bosque/kaykit_forest/Assets/gltf/Tree_Bare_1_C_Color1.gltf` | KayKit | Vegetacion principal | Árbol seco retorcido de ramas cortas junto al acceso a ruinas. | esencial |
| A12 | Tree_Bare_2_B_Color1 | `RPG/assets/bosque/kaykit_forest/Assets/gltf/Tree_Bare_2_B_Color1.gltf` | KayKit | Vegetacion principal | Árbol seco alto y estrecho para romper la silueta del dosel. | complementario |
| A13 | Flat_Tree_Stump | `RPG/assets/bosque/forest_nature_updated/Extras/Flat_Tree_Stump.glb` | Forest Nature Updated | Vegetacion principal | Tocón con anillos de corte y raíces; claros y campamento. | esencial |
| A14 | Flat_Fallen_Log | `RPG/assets/bosque/forest_nature_updated/Extras/Flat_Fallen_Log.glb` | Forest Nature Updated | Vegetacion principal | Tronco caído real para madera muerta; obstáculo lateral, sin bloquear ramales. | esencial |

### B. Vegetación secundaria

| ID | Nombre exacto | Ruta | Paquete | Categoría | Uso previsto | Prioridad |
|---|---|---|---|---|---|---|
| B01 | Flat_Bush_Clumps_medium | `RPG/assets/bosque/forest_nature_updated/Bushes/Flat_Bush_Clumps_medium.glb` | Forest Nature Updated | Vegetacion secundaria | Matorral agrupado de verde medio para sotobosque. | esencial |
| B02 | Flat_Bush_Clumps_small | `RPG/assets/bosque/forest_nature_updated/Bushes/Flat_Bush_Clumps_small.glb` | Forest Nature Updated | Vegetacion secundaria | Masa más baja, alargada y oscura para borde de caminos. | complementario |
| B03 | Flat_Bush_medium | `RPG/assets/bosque/forest_nature_updated/Bushes/Flat_Bush_medium.glb` | Forest Nature Updated | Vegetacion secundaria | Arbusto individual redondeado para zonas menos densas. | esencial |
| B04 | Flat_Bush_with_Flowers | `RPG/assets/bosque/forest_nature_updated/Bushes/Flat_Bush_with_Flowers.glb` | Forest Nature Updated | Vegetacion secundaria | Arbusto florido para el claro; no repetir junto a todos los caminos. | complementario |
| B05 | Bush_1_E_Color1 | `RPG/assets/bosque/kaykit_forest/Assets/gltf/Bush_1_E_Color1.gltf` | KayKit | Vegetacion secundaria | Grupo redondeado verde lima; reservar a puntos iluminados si se aprueba el contraste. | opcional |
| B06 | Bush_4_E_Color1 | `RPG/assets/bosque/kaykit_forest/Assets/gltf/Bush_4_E_Color1.gltf` | KayKit | Vegetacion secundaria | Matorral de silueta puntiaguda; solo si se aprueba la mayor simplificación KayKit. | opcional |
| B07 | Flat_Grass_large | `RPG/assets/bosque/forest_nature_updated/Grass/Flat_Grass_large.glb` | Forest Nature Updated | Vegetacion secundaria | Mata ancha de hierba para masas de sotobosque y ribera. | esencial |
| B08 | Flat_Grass_small | `RPG/assets/bosque/forest_nature_updated/Grass/Flat_Grass_small.glb` | Forest Nature Updated | Vegetacion secundaria | Hierba de pocas hojas para borde bajo y transiciones. | complementario |
| B09 | Grass_2_C_Color1 | `RPG/assets/bosque/kaykit_forest/Assets/gltf/Grass_2_C_Color1.gltf` | KayKit | Vegetacion secundaria | Hierba en grupo de geometría real a dos caras; dispersión por sectores. | esencial |
| B10 | Fern_1 | `RPG/assets/naturaleza/glTF/Fern_1.gltf` | Quaternius Nature | Vegetacion secundaria | Helecho de sotobosque húmedo; conservar espacio lateral. | esencial |
| B11 | Clover_1 | `RPG/assets/naturaleza/glTF/Clover_1.gltf` | Quaternius Nature | Vegetacion secundaria | Trébol para pequeños detalles de suelo; reducir tallos altos. | complementario |
| B12 | Grass_Common_Short | `RPG/assets/naturaleza/glTF/Grass_Common_Short.gltf` | Quaternius Nature | Vegetacion secundaria | Hierba texturizada de enlace con aldea, agrupada por zona. | complementario |
| B13 | Grass_Wispy_Short | `RPG/assets/naturaleza/glTF/Grass_Wispy_Short.gltf` | Quaternius Nature | Vegetacion secundaria | Hierba amarillenta puntual en mirador seco, no base verde. | opcional |
| B14 | Flat_Mushroom_Brown_small | `RPG/assets/bosque/forest_nature_updated/Mushrooms/Flat_Mushroom_Brown_small.glb` | Forest Nature Updated | Vegetacion secundaria | Hongo marrón pequeño para grupos sombreados. | esencial |
| B15 | Flat_Mushroom_Red_large | `RPG/assets/bosque/forest_nature_updated/Mushrooms/Flat_Mushroom_Red_large.glb` | Forest Nature Updated | Vegetacion secundaria | Hongo rojo moteado legible desde cámara ortográfica; acento fantástico. | complementario |
| B16 | Mushroom_Laetiporus | `RPG/assets/naturaleza/glTF/Mushroom_Laetiporus.gltf` | Quaternius Nature | Vegetacion secundaria | Hongo en repisas para troncos; usar poco por coste geométrico. | opcional |
| B17 | Flat_Flowers_red | `RPG/assets/bosque/forest_nature_updated/Extras/Flat_Flowers_red.glb` | Forest Nature Updated | Vegetacion secundaria | Grupo floral rojo/rosa junto al claro; escala baja. | complementario |
| B18 | Flower_3_Group | `RPG/assets/naturaleza/glTF/Flower_3_Group.gltf` | Quaternius Nature | Vegetacion secundaria | Flor coral texturizada para entrada y claros. | complementario |
| B19 | Flower_4_Group | `RPG/assets/naturaleza/glTF/Flower_4_Group.gltf` | Quaternius Nature | Vegetacion secundaria | Flor amarilla en pocos puntos; mayor coste que la flor coral. | opcional |
| B20 | Plant_7 | `RPG/assets/naturaleza/glTF/Plant_7.gltf` | Quaternius Nature | Vegetacion secundaria | Flores moradas bajas, no follaje genérico; acento discreto. | opcional |

### C. Rocas y terreno

| ID | Nombre exacto | Ruta | Paquete | Categoría | Uso previsto | Prioridad |
|---|---|---|---|---|---|---|
| C01 | Rock_1_M_Color1 | `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_1_M_Color1.gltf` | KayKit | Rocas y terreno | Afloramiento estratificado agrupado para base visual del mirador. | complementario |
| C02 | Rock_1_N_Color1 | `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_1_N_Color1.gltf` | KayKit | Rocas y terreno | Columna natural estratificada como hito; no es torre ni ruina. | opcional |
| C03 | Rock_3_C_Color1 | `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_3_C_Color1.gltf` | KayKit | Rocas y terreno | Roca pequeña facetada para repetición junto a caminos. | esencial |
| C04 | Rock_3_H_Color1 | `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_3_H_Color1.gltf` | KayKit | Rocas y terreno | Roca mediana redondeada para agrupaciones. | esencial |
| C05 | Rock_3_R_Color1 | `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_3_R_Color1.gltf` | KayKit | Rocas y terreno | Gran roca irregular KayKit, silueta ancha para lindes. | complementario |
| C06 | Flat_Boulder_01 | `RPG/assets/bosque/forest_nature_updated/Rocks/Flat_Boulder_01.glb` | Forest Nature Updated | Rocas y terreno | Gran bloque bajo natural para cerrar vistas y apoyar desniveles visuales. | esencial |
| C07 | Flat_Boulder_03 | `RPG/assets/bosque/forest_nature_updated/Rocks/Flat_Boulder_03.glb` | Forest Nature Updated | Rocas y terreno | Afloramiento oscuro vertical para mirador y entrada a ruinas. | complementario |
| C08 | Flat_Rock_05 | `RPG/assets/bosque/forest_nature_updated/Rocks/Flat_Rock_05.glb` | Forest Nature Updated | Rocas y terreno | Dos piedras angulares agrupadas, diferente silueta de roca individual. | complementario |
| C09 | Flat_Rock_08 | `RPG/assets/bosque/forest_nature_updated/Rocks/Flat_Rock_08.glb` | Forest Nature Updated | Rocas y terreno | Piedra ancha y baja para borde de laguna y arroyo. | esencial |
| C10 | Rock_Medium_1 | `RPG/assets/naturaleza/glTF/Rock_Medium_1.gltf` | Quaternius Nature | Rocas y terreno | Roca musgosa de transición junto a la aldea y restos antiguos. | complementario |
| C11 | Rock_Medium_2 | `RPG/assets/naturaleza/glTF/Rock_Medium_2.gltf` | Quaternius Nature | Rocas y terreno | Segunda silueta musgosa más baja; evita repetir la misma roca. | complementario |
| C12 | Pebble_Round_1 | `RPG/assets/naturaleza/glTF/Pebble_Round_1.gltf` | Quaternius Nature | Rocas y terreno | Piedra pequeña musgosa de sendero antiguo; sin colisión individual. | esencial |
| C13 | Pebble_Round_4 | `RPG/assets/naturaleza/glTF/Pebble_Round_4.gltf` | Quaternius Nature | Rocas y terreno | Variación de piedra plana para dispersión de senderos. | complementario |

### D. Campamento

| ID | Nombre exacto | Ruta | Paquete | Categoría | Uso previsto | Prioridad |
|---|---|---|---|---|---|---|
| D01 | Bag | `RPG/assets/objetos_medievales/glTF/Bag.gltf` | Quaternius Props | Campamento | Saco de provisiones. | esencial |
| D02 | Barrel | `RPG/assets/objetos_medievales/glTF/Barrel.gltf` | Quaternius Props | Campamento | Barril junto a suministros. | esencial |
| D03 | Cauldron | `RPG/assets/objetos_medievales/glTF/Cauldron.gltf` | Quaternius Props | Campamento | Caldero central, requiere hogar propio futuro. | esencial |
| D04 | Crate_Wooden | `RPG/assets/objetos_medievales/glTF/Crate_Wooden.gltf` | Quaternius Props | Campamento | Caja reforzada de víveres. | complementario |
| D05 | Bucket_Wooden_1 | `RPG/assets/objetos_medievales/glTF/Bucket_Wooden_1.gltf` | Quaternius Props | Campamento | Cubo junto al agua o área de cocina. | complementario |
| D06 | Pot_1 | `RPG/assets/objetos_medievales/glTF/Pot_1.gltf` | Quaternius Props | Campamento | Olla abierta para cocinar. | complementario |
| D07 | Rope_2 | `RPG/assets/objetos_medievales/glTF/Rope_2.gltf` | Quaternius Props | Campamento | Cuerda enrollada junto a equipo. | complementario |
| D08 | Stool | `RPG/assets/objetos_medievales/glTF/Stool.gltf` | Quaternius Props | Campamento | Asiento sencillo de bajo coste. | esencial |
| D09 | Table_Large | `RPG/assets/objetos_medievales/glTF/Table_Large.gltf` | Quaternius Props | Campamento | Mesa de preparación de comida. | complementario |
| D10 | Chest_Wood | `RPG/assets/objetos_medievales/glTF/Chest_Wood.gltf` | Quaternius Props | Campamento | Cofre de suministros; sin sistema de inventario. | opcional |
| D11 | Lantern_Wall | `RPG/assets/objetos_medievales/glTF/Lantern_Wall.gltf` | Quaternius Props | Campamento | Farol con soporte: necesita poste propio; sin luz funcional incluida. | complementario |
| D12 | Axe_Bronze | `RPG/assets/objetos_medievales/glTF/Axe_Bronze.gltf` | Quaternius Props | Campamento | Hacha de trabajo decorativa; no implica combate. | opcional |

### E. Ruinas

| ID | Nombre exacto | Ruta | Paquete | Categoría | Uso previsto | Prioridad |
|---|---|---|---|---|---|---|
| E01 | Corner_Exterior_Brick | `RPG/assets/aldea/glTF/Corner_Exterior_Brick.gltf` | Quaternius Village | Ruinas | Hilera de piedra de esquina para restos de muro; no columna clásica terminada. | complementario |
| E02 | Prop_Brick1 | `RPG/assets/aldea/glTF/Prop_Brick1.gltf` | Quaternius Village | Ruinas | Bloque suelto de mampostería para escombros. | esencial |
| E03 | Prop_Brick3 | `RPG/assets/aldea/glTF/Prop_Brick3.gltf` | Quaternius Village | Ruinas | Segunda forma de bloque caído. | complementario |
| E04 | Floor_UnevenBrick | `RPG/assets/aldea/glTF/Floor_UnevenBrick.gltf` | Quaternius Village | Ruinas | Pavimento antiguo parcial; el suelo de la región debe aportar apoyo. | esencial |
| E05 | Stairs_Exterior_Straight | `RPG/assets/aldea/glTF/Stairs_Exterior_Straight.gltf` | Quaternius Village | Ruinas | Escalinata pequeña de acceso a restos, con colisión propia futura. | complementario |
| E06 | Wall_UnevenBrick_Door_Round | `RPG/assets/aldea/glTF/Wall_UnevenBrick_Door_Round.gltf` | Quaternius Village | Ruinas | Hueco de puerta de muro intacto mixto; requiere composición para parecer antiguo. | opcional |
| E07 | Prop_Vine5 | `RPG/assets/aldea/glTF/Prop_Vine5.gltf` | Quaternius Village | Ruinas | Enredadera ramificada para cubrir restos de muro. | esencial |
| E08 | Vase_Rubble_Medium | `RPG/assets/objetos_medievales/glTF/Vase_Rubble_Medium.gltf` | Quaternius Props | Ruinas | Escombro cerámico: revisar COLOR_0 y material blanco mediante override local al utilizarlo. | opcional |

### F. Decoración ambiental

| ID | Nombre exacto | Ruta | Paquete | Categoría | Uso previsto | Prioridad |
|---|---|---|---|---|---|---|
| F01 | Prop_WoodenFence_Single | `RPG/assets/aldea/glTF/Prop_WoodenFence_Single.gltf` | Quaternius Village | Decoracion ambiental | Cerca rural baja para entrada desde aldea y campamento. | esencial |
| F02 | Prop_WoodenFence_Extension1 | `RPG/assets/aldea/glTF/Prop_WoodenFence_Extension1.gltf` | Quaternius Village | Decoracion ambiental | Tramo complementario sin duplicar poste en unión. | complementario |
| F03 | Prop_Vine1 | `RPG/assets/aldea/glTF/Prop_Vine1.gltf` | Quaternius Village | Decoracion ambiental | Enredadera vertical estrecha para roca o poste con soporte visual. | complementario |
| F04 | Prop_Support | `RPG/assets/aldea/glTF/Prop_Support.gltf` | Quaternius Village | Decoracion ambiental | Madera trabajada para poste de señal/refugio propio, no señal terminada. | complementario |
| F05 | Torch_Metal | `RPG/assets/objetos_medievales/glTF/Torch_Metal.gltf` | Quaternius Props | Decoracion ambiental | Antorcha estática para entrada a ruinas, sin fuego ni luz funcional. | opcional |

## Descartes de la selección inicial

Se retienen 33 de las 165 entradas nuevas; **132 quedan en reserva**, además de las exportaciones alternativas. No se elimina ningún archivo. [Listado completo con rutas y motivo por modelo](../logs/seleccion_assets_bosque/2026-11-03T22-04-32/descartados_nuevos.csv).

| Modelos/familia | Motivo |
|---|---|
| FBX/FBX Unity/OBJ KayKit | Exportaciones alternativas del mismo nombre; glTF conserva una ruta canónica coherente con el proyecto |
| Grass_1_Mesh, Grass_2_Mesh y versiones SingleSided_Mesh | Geometría repetida; materiales sin la variante forest texturizada seleccionada |
| Grass_*_Singlesided_Color1 | Evitar repetir versión de una cara y de dos caras; para cámara orbital se priorizan matas volumétricas |
| Tree_2_* KayKit | Copas cúbicas, aspecto muy geométrico frente al bosque ramificado elegido |
| Tree_1_*, Tree_3_*, Tree_4_* KayKit | Familias lisas/limas; no aportan suficiente coherencia con los robles/olmo seleccionados |
| Flat_Tree_Birch_hero_green | 4498 triángulos y tres superficies; se prefiere el abedul medio, sin varios tamaños casi equivalentes |
| Flat_Tree_Park_*, Flat_Tree_Simple_* y Cypress | Copas genéricas o ciprés regular; los robles, olmo, abedul y dos coníferas ya cubren la variedad principal |
| Flat_Tree_Maple_red y Quaternius TwistedTree | Rojo muy intenso; TwistedTree además supera 9000 triángulos por ejemplar. No son base del bosque verde propuesto |
| Otros tamaños de pino/spruce, arbusto/hongo y muchas rocas | Reserva de formas; evitar llenar 60–80 plazas con variantes que se pueden resolver con escala/giro de instancias |
| Flat_Forest_Ground | Malla de suelo completa de 146×146 y 6751 triángulos; no decide el terreno regional, laguna ni ramales. Excluida de la selección de construcción |
| Quaternius DeadTree, RockPath extensos y mobiliario fino sobrante | KayKit secos son mucho más ligeros; caminos requieren suelo continuo; cubertería y objetos de interior no aportan a la vista orbital |

## Galería y reproducción

La galería final contiene **40 PNG 1800×1100**: 15 paneles de hasta seis modelos, 24 vistas orbitales (0/90/180/270° de un representante por grupo) y una vista general. Los paneles normalizan cada pieza a una dimensión máxima de 4 unidades para leer detalles; **no muestran tamaños relativos de construcción**. Cada rótulo indica ID, nombre, origen, AABB fuente y escala propuesta. La escena temporal guarda esos modelos normalizados en seis bloques; se explora con la cámara del editor. El manifest y la tabla técnica conservan las escalas de uso. La órbita real de representantes es a unos -32.5°; los paneles de seis usan una inclinación más alta para separar filas.

Desde la raíz del repositorio, con un ejecutable Godot 4.7.2 disponible:

`godot --path RPG --resolution 1800x1100 --log-file logs/<nombre_nuevo>.log --script res://tests/seleccionar_assets_bosque.gd -- res://tests/seleccion_assets_bosque.json`

Con --headless solo mide/valida; sin manifest recorre todos los modelos disponibles. Cada ejecución crea una carpeta nueva bajo RPG/logs/seleccion_assets_bosque/. La configuración de tamaño/escala de ventana es temporal en el capturador; no se guarda en project.godot ni toca la cámara jugable.

## Cierre

Selección, catálogo e informe preparados; la validación técnica no equivale a aprobación artística. Se actualizaron AGENTS.md, estado e inventario para registrar los nuevos paquetes y esta propuesta, sin declarar construido el bosque. Se conserva la auditoría anterior como historial. No se hicieron commits ni pushes. **Esperar aprobación visual antes de construir la región.**
