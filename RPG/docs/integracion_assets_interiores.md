# Auditoría de integración — nuevos assets medievales

Fecha local: **16 de noviembre de 2026**. Esta auditoría selecciona recursos para una fase posterior; no construye interiores ni cambia el juego.

## 1. Resultado ejecutivo

Se encontraron **159 entradas canónicas de modelo** en los cinco paquetes: 92 GLB y 67 FBX exclusivos de medv-cafe. Hay **276 archivos importables GLB/FBX/OBJ** al contar exportaciones alternativas, más tres archivos Blend de autoría/demostración. No son 279 objetos diferentes. Los cofres y sus tapas, los módulos de barra y los conjuntos de comida también explican por qué entradas de catálogo no equivalen a muebles completos.

**Godot 4.7.2 cargó e instanció 276/276 archivos probados con mallas y materiales, sin superficies sin material y sin colisiones incorporadas detectadas.** La importación no estuvo libre de incidencias: dos FBX animados produjeron errores de Basis nula; hay avisos de capitalización en rutas de texturas FBX y avisos OBJ/MTL. Se recomiendan los GLB cuando existen. Los tres Blend no se importaron.

Se renderizaron **159 modelos canónicos con Forward+/D3D12** y se revisaron sus cinco hojas de contacto; también se abrieron detalles de cubiertos, cafetera, molinillo, señalética y taza blanca. Esto es una revisión técnica de una vista por modelo, normalizada para leer su forma; no es aprobación artística, comprobación orbital completa ni prueba de escala junto al protagonista.

Los **92 GLB de los cuatro paquetes con licencia local** permiten comenzar E01–E11 combinándolos con los recursos anteriores y pequeñas composiciones propias. La tabla los clasifica en **39 aportes, 35 alternativas funcionales, siete secundarios, diez fuera del alcance y uno excluido por estética**. No son 39 categorías nuevas: entre los aportes se cuentan componentes como cuerpo/tapa de cofre y variantes animadas.

**medv-cafe contiene 67 modelos técnicamente cargables, pero no se encontró licencia local.** Por decisión del usuario del 16 de noviembre de 2026, los 27 modelos detallados en E01 son una selección artística aprobada para integración local y uno de los recursos principales de la taberna. El proyecto es exclusivamente académico y no comercial; la verificación de licencia sigue pendiente. Los demás usos conservan su condición pendiente. Las cafeteras y gráficas de cafetería actual se excluyen de la propuesta medieval. No es necesario depender de este paquete para comenzar los once interiores mencionados.

**E12 sigue sin un conjunto de molienda:** faltan muelas, tolva, bancada, transmisión y salida de harina. Puede iniciarse su almacén y diseño espacial, pero no declararse resuelto el interior funcional del molino.

## 2. Alcance, fuentes y procedimiento

Se revisaron AGENTS.md, RPG/docs/estado_proyecto.md, RPG/docs/inventario_assets.md y los **174 candidatos** de RPG/docs/auditoria_assets_interiores.md, junto con archivos reales de los cinco paquetes, CSV, README, licencias y referencias de escenas anteriores. Las marcas de conflicto de AGENTS/estado siguen presentes; no se corrigieron. La guía técnica eliminada localmente al inicio no se restauró. La rama main se conservó.

La carpeta de herrería descubierta automáticamente es **RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/**. No se dedujeron nombres de un catálogo comercial: todas las rutas del informe se contrastaron con archivos locales.

### Prueba real aislada

1. Se copiaron los archivos de fuente a un proyecto temporal, preservando jerarquías y sin copiar la caché ni los .import originales. Los originales no se usaron como destino de importación. No se movió ni convirtió ningún modelo original.
2. Se creó configuración mínima solo en esa copia: Godot 4.7, Forward Plus/D3D12 y Blend deshabilitado, como en el proyecto principal. No se editó RPG/project.godot.
3. El ejecutable local confirmó **4.7.2.stable.official.ed1daf0bf**. La importación desde caché vacía terminó con código 0, con los errores/avisos detallados abajo; un código 0 no significa ausencia de incidencias.
4. Un validador temporal cargó e instanció todos los GLB/FBX/OBJ, recorrió mallas, superficies, materiales, texturas, AABB, colisiones y AnimationPlayer. Resultado: **276 recursos, cero fallos de carga/malla/material**.
5. Se capturó cada canónico aislado en GPU **NVIDIA GeForce RTX 4060 Laptop**, Forward+/D3D12. Una cámara propia del catálogo se ajustó al objeto; no se modificó la cámara del RPG. No se midió rendimiento.
6. Se compararon SHA-256 de archivos fuente con recursos anteriores y se contrastaron variantes de formato. Se realizó además una huella de posiciones/índices importados entre los 159 nuevos canónicos.

Evidencias temporales, excluidas de la entrega versionable: **RPG/logs/integracion_interiores_2026-11-17T00-17-01-969Z/**. El sufijo de carpeta usa UTC y por eso contiene el día 17; la fecha local de la auditoría es el día 16.

| Evidencia | Ruta relativa al repositorio |
|---|---|
| Importación desde caché vacía | RPG/logs/integracion_interiores_2026-11-17T00-17-01-969Z/01_importacion.log |
| Carga/instanciación y datos por formato | RPG/logs/integracion_interiores_2026-11-17T00-17-01-969Z/02_modelos.log y modelos.json |
| Render real y listado de capturas | RPG/logs/integracion_interiores_2026-11-17T00-17-01-969Z/03_render.log y capturas.json |
| Huellas de geometría | RPG/logs/integracion_interiores_2026-11-17T00-17-01-969Z/04_geometrias.log y geometrias.json |
| Galería de 159 originales | RPG/logs/integracion_interiores_2026-11-17T00-17-01-969Z/galeria.html |
| Hojas revisadas | RPG/logs/integracion_interiores_2026-11-17T00-17-01-969Z/hoja_00.png hasta hoja_04.png |

## 3. Censo por paquete, formatos y texturas

| Paquete y carpeta exacta | Entradas canónicas | Formatos alternativos presentes | Texturas/materiales y resultado |
|---|---:|---|---|
| RPG/assets/interiores_medievales/Alimentos/Food_Market/ | 22 GLB en glTF/ | 22 FBX en FBX/ | Paleta mdvl_palette.png de 256×256 embebida en GLB; copia externa en Textures/. 44/44 archivos cargables. |
| RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/ | 20 GLB en glTF/ | 20 FBX en FBX/ | Misma estrategia de paleta; FBX con aviso textures/Textures. 40/40 cargables. |
| RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/ | 25 GLB en GLB/ | 25 FBX, 25 OBJ+MTL y Blacksmith_AllAssets.blend | Colores planos por material, sin texturas necesarias. 75/75 GLB/FBX/OBJ cargables. Blend colectivo sin prueba directa. |
| RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/ | 25 GLB en glTF/ | 25 FBX en FBX/ | Paleta embebida, cuatro modelos con skin/clip de fuego. FBX con incidencias detalladas. 50/50 cargables. |
| RPG/assets/interiores_medievales/Taberna/medv-cafe/ | 67 FBX en fbx/ | all-merged.blend y demo-scene.blend, colectivos | Texturas en tex/, materiales de madera/tela/metal/alimentos, normales y otros mapas presentes. 67/67 FBX cargables; licencia no encontrada. |
| **Total** | **159** | **159 FBX + 92 GLB + 25 OBJ = 276 archivos probados; tres Blend no probados** | **92 pares GLB/FBX no suman variedad; 25 OBJ repiten herrería.** |

Las imágenes de referencia de los paquetes son tres paletas en Textures/ y **69 imágenes en medv-cafe/tex/ (64 JPG y cinco PNG)**: 72 archivos de textura de esas ubicaciones. Se observaron además copias de paletas extraídas por Godot junto a modelos y metadatos .import; no se cuentan como texturas artísticas distintas ni como modelos. No se modificaron filtros, materiales o importaciones del proyecto principal por parte de esta auditoría.

Los README Avramania describen familias y funciones más amplias que las ediciones gratuitas locales: no se presuponen portones, relojes, hornos u otros modelos que no figuren en el censo. Los CSV locales de 22/20/25 coinciden con las entradas realmente encontradas. La herrería suma 2.268 triángulos en sus 25 modelos base según la ficha y los datos cargados; no son 25 estaciones completas.

## 4. Compatibilidad y problemas detectados

### Importación y materiales

- **Sin fallos de carga:** 276 recursos probados tenían malla y material. “Material presente” no garantiza todos sus mapas correctamente conectados. La compatibilidad comprobada corresponde a Windows y Godot 4.7.2; no es una exportación probada a Linux, móvil o web.
- **Errores concretos de FBX:** mdvl_interiors_walltorch_01.fbx y mdvl_interiors_flame_02.fbx generaron dos mensajes cada uno sobre Basis de escala cero no normalizable para Quaternion. Aun así generaron recursos cargables. Seleccionar sus GLB; no declarar reparado ni validado el FBX animado. No se cambiaron fuentes.
- **Rutas con mayúsculas/minúsculas:** avisos sobre textures/mdvl_palette.png frente a Textures/mdvl_palette.png en FBX de Props_Tools_Fencing e Interiors_Furniture. Windows toleró la diferencia; podría fallar en un sistema sensible a mayúsculas. Preferir GLB con paleta embebida. No se renombró ninguna carpeta para ocultarlo.
- **OBJ de herrería:** avisos sobre componente ambiental MTL ignorada por PBR. Los materiales sí cargaron; no equivale a archivos de textura ausentes. GLB conserva una vía más directa.
- **Cerámica blanca de medv-cafe:** mug03.fbx importa GlazedTerracotta001 con normal conectada, pero sin textura de albedo. El archivo tex/GlazedTerracotta001.jpg sí existe; no falta el archivo, falta la conexión en ese material importado. Se observa blanca en la captura. La misma situación aparece en la pieza de cerámica de drip-coffee-maker.fbx, que además se excluye por temática. Otros materiales de vidrio, cera y aura son colores planos legítimos; no se etiquetan automáticamente como textura perdida.
- **PBR de medv-cafe:** los mapas auxiliares presentes en tex/ no garantizan que el FBX los conecte todos. En muchas superficies se cargan albedo y normal; roughness/especular/metallic deben revisarse al construir materiales locales. No se rehicieron materiales durante esta tarea.
- **Incidencias del entorno:** lectura del almacén de certificados, acceso a user:// y caché de shaders; el editor temporal no pudo guardar ajustes globales. Los registros se conservan con estos mensajes. No hubo bloqueo de carga ni de las 159 capturas por ellos.

### Animaciones, piezas y colisiones

Los GLB candle_01, flame_01, flame_02 y walltorch_01 contienen burn_loop en la fuente. Godot los importó como **burn, 3 segundos, bucle activado**. Hay clip y skin, pero no se hizo una prueba temporal por fotogramas de cada llama: las capturas no certifican movimiento. La nomenclatura importada debe comprobarse antes de reproducirlos; no buscar ciegamente burn_loop en AnimationPlayer. La geometría de llama no crea Light3D por sí sola.

La tapa chest_lid_01 es un archivo separado del cuerpo chest_01, una mejora respecto a depender del rig de Chest_Wood antiguo. El README da offsets de ensamblaje en coordenadas de Blender; **no copiarlos sin conversión a Godot ni sin revisar la base importada**. El cofre abierto y su tapa suman dos recursos, un mueble. Lo mismo se aplica a módulos de mostrador y conjuntos: no sumar cada alimento o herramienta de un conjunto como modelo independiente. Los FBX de medv-cafe pueden contener varias mallas/superficies: basket-of-jars tiene 17 superficies registradas; su separación y apariencia deben conservar transformaciones/materiales, no se extrajeron piezas aquí.

**Cero CollisionShape3D en las 276 instancias examinadas.** Se necesitarán colisiones simplificadas en nuevas escenas envolventes para muebles grandes/suelos, evitando colisionar individualmente cubiertos, hierbas y alimentos. Ningún archivo garantiza hueco de puerta, paso del personaje o navegación.

### Escala y orientación

Las dimensiones de las tablas son **X×Y×Z del AABB de mallas en la raíz importada**, en unidades de Godot, sin escalado de adaptación. Incluyen jerarquías transformadas; no sustituyen límites precisos de cada pieza ni AABB deformada durante una animación. Los triángulos son geometría base de superficies, sin LOD alternativos, sombras o coste de todas las instancias.

La mesa Avramania mide aproximadamente 0,77×0,76×1,39; la cama 1,974×1,190×1,274; la silla tiene altura próxima a 0,98. Son más fáciles de distribuir en las viviendas pequeñas que Table_Large y las camas Twin antiguas de ≈1,88×2,41 en planta. El protagonista conserva cápsula 0,64×1,60; no debe escalarse para acomodar arquitectura.

**forge.glb mide 2×4,05×1,60**, demasiado alto para un interior de unos tres metros sin diseño específico. No reducir la forja completa hasta deformar sus proporciones funcionales; preferir la forja propia existente o una composición interior nueva. Counter_M de medv-cafe mide 1,50×1,15×0,90; Stool de ese paquete llega a 0,805 de alto, frente a mesa a 0,81: no emparejarlos como asiento de mesa común sin comprobar ergonomía. Son medidas para elegir variantes, no escalados aprobados.

Los README Avramania describen orientaciones en ejes Blender (frente hacia −Y fuente). Tras importación Godot el eje vertical es Y y el frente debe verificarse por la base/rotación del nodo. No trasladar instrucciones de ejes de Blender literalmente. Las 92 parejas GLB/FBX coinciden en número de triángulos y dimensiones del AABB dentro de 0,001 unidades en esta prueba; esto no certifica identidad de materiales, animaciones ni topología.

### Estética y mezcla de paquetes

Avramania ofrece colores planos y paleta cálida; Village/Props antiguos usan trims más detallados. Pueden convivir como núcleo estilizado, aunque conviene mantener familias de muebles coherentes por habitación. Los 25 Blacksmith son extremadamente simples: usarlos para las piezas que faltan y conservar el yunque/forja antiguos evita que todo el taller pierda detalle. medv-cafe tiene más textura de superficie y detalle de comida; no mezclarlo masivamente con la paleta plana sin revisión artística y licencia.

Los 159 canónicos van de 12 a 2.428 triángulos por entrada en la carga realizada. Un objeto de pocas caras con muchas superficies puede costar más llamadas de dibujo que una malla algo más detallada de material único; las paletas iguales embebidas no garantizan que Godot deduplique automáticamente todos los materiales. No se realizaron benchmarks ni optimización.

## 5. Duplicados y comparación con los 174 anteriores

- **Duplicación de formatos:** 92 GLB tienen un FBX del mismo nombre; los 25 de herrería añaden OBJ. Son exportaciones alternativas, no 117 modelos adicionales. Las escenas colectivas Blend no incrementan el catálogo de piezas individuales.
- **Duplicados binarios exactos:** no se encontraron SHA-256 de archivos de modelo nuevos idénticos entre sí ni a los modelos canónicos del inventario anterior, incluidos sus 174 candidatos. Esto compara bytes, no semejanza visual.
- **Geometría reutilizada:** table-cloth01.fbx y table-cloth02.fbx comparten la misma huella de posiciones/índices importados; cambian material/textura. Hay **158 huellas para 159 entradas**. La huella preserva orden de vértices/superficies y no normaliza rotación, escala o triangulación: no es una prueba global de 158 geometrías matemáticamente únicas.
- **Redundancia funcional:** 35 de los 92 GLB se clasifican como alternativas a objetos ya existentes. Las barras, manteles y otros candidatos de medv-cafe pueden añadir variantes, pero se mantienen condicionados por licencia. Un nuevo martillo como archivo independiente aporta reutilización aunque ya hubiera uno hecho con primitivas dentro de herreria.tscn.

| Categoría anterior | Recursos que ya existían | Aporte real o decisión |
|---|---|---|
| Dormir/sentarse/comer | Bed_Twin1/2, Chair_1, Bench, Stool, Table_Large | Cama/mesa más compactas y nuevos respaldos; no faltaba toda la categoría. |
| Almacenaje | Cabinet, Chest_Wood, Shelf_*, Crate_Wooden | Cofre y tapa separados; más cajas/estantes redundantes. **No hay ropero alto nuevo identificado.** |
| Recipientes y vajilla | Mug, Chalice, Bottle_1, Potion_*, Pot_1, Cauldron, cubiertos/plato | Cuenco, jarra/barrilete y variantes; mantener cubiertos antiguos para evitar el conjunto de lectura moderna. |
| Alimentos | Zanahoria y cajas de fruta/verdura; cesta con fruta candidata | Pan/hogazas, queso, carne, pescado, cebolla, uvas y manzana suelta amplían funciones; col y zanahoria nuevas son redundancia. |
| Herrería | Anvil_Log, Whetstone, Workbench, forja y martillo propios | Fuelle, tenazas, lingotes y herraduras cubren vacíos principales. No sustituir afiladora por “piedra de molino”. |
| Carpintería | Banco, hacha, sierra/cepillo/escuadra/mazo propios | Banco con prensa visible y herramientas independientes; la carretilla/rueda son accesorios. |
| Herbolario | Frascos/libros, mesa y mortero propios | Manojo de hierbas y balanza disponibles con licencia; secadero específico medv-cafe aún condicionado. |
| Textiles y cuadros | Estandartes, decoración propia, sin alfombra doméstica identificada | Alfombra, cortina, cojín y cuadro cubren la carencia; manteles/tapices medv-cafe pendientes de licencia. |
| Iluminación | Velas/faroles/antorchas estáticos | Llamas con clips y variantes compactas; requieren luces y prueba temporal. |
| Molino | Rueda y eje exteriores propios, sacos/barriles | Más grano, pesaje, ganchos y almacenaje; **muelas/tolva/transmisión siguen ausentes**. |

## 6. Catálogo de los cuatro paquetes con licencia local

APORTE significa nueva función, representación independiente o mejora relevante; ALTERNATIVA significa solapamiento funcional, no duplicado binario. SECUNDARIO/FUERA DE ALCANCE no significa moderno. Se prioriza el GLB; todos los renglones tienen carga real y una vista revisada. No implican integración o aprobación artística.

| Modelo | Ruta exacta recomendada | AABB X×Y×Z | Triángulos | Aporte/decisión | Destinos posibles |
|---|---|---|---:|---|---|
| mdvl_food_ale_mug_01 | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_ale_mug_01.glb` | 0.142×0.119×0.098 | 388 | ALTERNATIVA — Jarra de madera; redundante con Mug. | E01/E06–E11 |
| mdvl_food_apple_01 | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_apple_01.glb` | 0.085×0.084×0.084 | 418 | APORTE — Fruta individual; las cajas antiguas no daban manzanas separadas. | E01/E02/E10 |
| mdvl_food_bowl_01 | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_bowl_01.glb` | 0.244×0.068×0.144 | 388 | APORTE — Cuenco con asa/mango de madera; complementa vajilla antigua. | E01/E06–E11 |
| mdvl_food_cabbage_01 | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_cabbage_01.glb` | 0.172×0.132×0.165 | 1448 | ALTERNATIVA — Col recogida; solapa con Farm_Harvest/cabbage_stage_03. | E01/E10 |
| mdvl_food_carrot_01 | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_carrot_01.glb` | 0.232×0.062×0.112 | 370 | ALTERNATIVA — Zanahoria; solapa con Carrot. | E01/E10 |
| mdvl_food_cask_01 | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_cask_01.glb` | 0.345×0.426×0.401 | 1300 | ALTERNATIVA — Barrilete con grifo; variante útil de barril, no categoría nueva. | E01 |
| mdvl_food_cheese_wheel_01 | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_cheese_wheel_01.glb` | 0.292×0.112×0.300 | 1270 | APORTE — Rueda de queso con porción abierta. | E01/E02/E06–E11 |
| mdvl_food_coin_01 | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_coin_01.glb` | 0.027×0.004×0.027 | 148 | ALTERNATIVA — Moneda; solapa con Coin. | E01/E02 |
| mdvl_food_coin_stack_01 | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_coin_stack_01.glb` | 0.057×0.025×0.047 | 396 | ALTERNATIVA — Monedas agrupadas; solapa con Coin_Pile. | E01/E02 |
| mdvl_food_cutlery_01 | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_cutlery_01.glb` | 0.278×0.032×0.154 | 1004 | EXCLUIR ESTÉTICA — Conjunto sobre bandeja blanca con líneas rojas: lectura de servicio contemporáneo. Preferir Table_Fork/Knife/Spoon antiguos. | Ninguno de inicio |
| mdvl_food_fish_01 | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_fish_01.glb` | 0.372×0.057×0.121 | 600 | APORTE — Pescado como alimento; distinto del minijuego 2D. | E01/E08 |
| mdvl_food_grain_sack_01 | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_grain_sack_01.glb` | 0.360×0.517×0.348 | 938 | APORTE — Saco abierto con grano visible; solapa en volumen con Bag, aporta contenido legible. | E02/E10/E12 |
| mdvl_food_grapes_01 | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_grapes_01.glb` | 0.084×0.179×0.091 | 708 | APORTE — Racimo de uvas independiente. | E01/E02 |
| mdvl_food_ham_01 | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_ham_01.glb` | 0.402×0.114×0.223 | 750 | APORTE — Pieza de carne/jamón. | E01/E06–E11 |
| mdvl_food_herb_bundle_01 | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_herb_bundle_01.glb` | 0.343×0.285×0.344 | 666 | APORTE — Manojo colgante; cubre hierbas secas decorativas. No prueba especie medicinal. | E05/E10 |
| mdvl_food_loaf_01 | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_loaf_01.glb` | 0.220×0.113×0.214 | 350 | APORTE — Hogaza; cubre carencia de pan. | E01/E02/E06–E11 |
| mdvl_food_onion_01 | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_onion_01.glb` | 0.077×0.101×0.076 | 386 | APORTE — Cebolla individual. | E01/E02/E10 |
| mdvl_food_plate_01 | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_plate_01.glb` | 0.240×0.034×0.240 | 376 | ALTERNATIVA — Plato; solapa con Table_Plate. | E01/E06–E11 |
| mdvl_food_potion_01 | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_potion_01.glb` | 0.076×0.114×0.075 | 494 | ALTERNATIVA — Frasco con líquido; solapa con Potion_1/2/4. | E05 |
| mdvl_food_produce_crate_01 | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_produce_crate_01.glb` | 0.532×0.121×0.352 | 240 | ALTERNATIVA — Bandeja/caja baja; solapa con FarmCrate_Empty. | E02/E10/E12 |
| mdvl_food_roll_01 | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_roll_01.glb` | 0.092×0.057×0.086 | 190 | APORTE — Panecillo, tamaño distinto de hogaza. | E01/E02 |
| mdvl_food_scales_01 | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_scales_01.glb` | 0.525×0.563×0.200 | 686 | APORTE — Balanza de platillos; útil para venta y preparación. | E02/E05/E12 |
| mdvl_props_axe_01 | `RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/glTF/mdvl_props_axe_01.glb` | 0.334×0.919×0.060 | 334 | ALTERNATIVA — Hacha de trabajo; solapa con Axe_Bronze. | E04/E10 |
| mdvl_props_barrel_01 | `RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/glTF/mdvl_props_barrel_01.glb` | 0.625×0.780×0.624 | 2348 | ALTERNATIVA — Barril; solapa con Barrel. | E01/E12 |
| mdvl_props_basket_01 | `RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/glTF/mdvl_props_basket_01.glb` | 0.523×0.592×0.523 | 2200 | APORTE — Cesta vacía con asa, confirmada visualmente. Antiguo catálogo tenía cesta con fruta candidata. | E02/E05/E10 |
| mdvl_props_cart_wheel_01 | `RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/glTF/mdvl_props_cart_wheel_01.glb` | 0.352×0.840×0.841 | 765 | APORTE — Rueda de carro de radios, independiente. No es engranaje ni muela. | E04/E12 como pieza de reparación |
| mdvl_props_crate_01 | `RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/glTF/mdvl_props_crate_01.glb` | 0.511×0.527×0.495 | 1529 | ALTERNATIVA — Caja cerrada; solapa con Crate_Wooden. | E04/E12 |
| mdvl_props_feed_trough_01 | `RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/glTF/mdvl_props_feed_trough_01.glb` | 0.721×0.653×1.202 | 764 | SECUNDARIO — Comedero exterior; ya hay Farm_Harvest. No esencial para interiores de vivienda. | E10 anexo |
| mdvl_props_fence_wood_01 | `RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/glTF/mdvl_props_fence_wood_01.glb` | 1.000×1.256×0.100 | 264 | SECUNDARIO — Valla; no sustituye tabique interior sólido. | E10 anexo |
| mdvl_props_fence_wood_end_01 | `RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/glTF/mdvl_props_fence_wood_end_01.glb` | 0.050×1.256×0.100 | 24 | SECUNDARIO — Poste final de la valla; componente, no otro mueble. | E10 anexo |
| mdvl_props_grave_marker_01 | `RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/glTF/mdvl_props_grave_marker_01.glb` | 0.531×0.804×0.308 | 340 | FUERA DE ALCANCE — Elemento funerario; medieval pero ajeno a los doce interiores. | Ninguno |
| mdvl_props_hammer_01 | `RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/glTF/mdvl_props_hammer_01.glb` | 0.190×0.467×0.104 | 280 | APORTE — Martillo como modelo independiente; antes existía geometría propia. | E03/E04 |
| mdvl_props_pot_01 | `RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/glTF/mdvl_props_pot_01.glb` | 0.370×0.266×0.292 | 339 | ALTERNATIVA — Olla con tapa integrada; solapa con Pot_1/Pot_1_Lid. | E01/E06–E11 |
| mdvl_props_public_bench_01 | `RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/glTF/mdvl_props_public_bench_01.glb` | 1.400×0.986×0.510 | 616 | ALTERNATIVA — Banco con respaldo; nueva variante frente al Bench sin respaldo. | E01/E06–E11 |
| mdvl_props_rope_coil_01 | `RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/glTF/mdvl_props_rope_coil_01.glb` | 0.655×0.328×0.657 | 1388 | ALTERNATIVA — Cuerda enrollada; solapa con Rope_1/2/3. | E04/E12 |
| mdvl_props_sack_01 | `RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/glTF/mdvl_props_sack_01.glb` | 0.518×0.636×0.537 | 1529 | ALTERNATIVA — Saco cerrado; solapa con Bag. | E02/E10/E12 |
| mdvl_props_shovel_01 | `RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/glTF/mdvl_props_shovel_01.glb` | 0.214×1.367×0.063 | 368 | APORTE — Pala de mango largo; nueva herramienta independiente. | E10/E12 |
| mdvl_props_signpost_01 | `RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/glTF/mdvl_props_signpost_01.glb` | 1.340×2.066×0.136 | 192 | SECUNDARIO — Poste indicador exterior; no necesario como mueble interior. | Ninguno de inicio |
| mdvl_props_tombstone_01 | `RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/glTF/mdvl_props_tombstone_01.glb` | 0.740×1.000×0.350 | 304 | FUERA DE ALCANCE — Lápida; no descartar por modernidad, sino por función. | Ninguno |
| mdvl_props_wall_stone_01 | `RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/glTF/mdvl_props_wall_stone_01.glb` | 1.010×0.995×0.322 | 792 | SECUNDARIO — Murete; no resuelve arquitectura de habitación por sí solo. | E10 anexo |
| mdvl_props_water_trough_01 | `RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/glTF/mdvl_props_water_trough_01.glb` | 1.344×0.649×0.684 | 1304 | SECUNDARIO — Abrevadero exterior. | E10 anexo |
| mdvl_props_wheelbarrow_01 | `RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/glTF/mdvl_props_wheelbarrow_01.glb` | 1.523×0.725×0.460 | 1736 | APORTE — Carretilla de madera; útil de oficio, colocar sin bloquear. | E04/E10/E12 anexo |
| anvil | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/anvil.glb` | 1.300×0.647×0.450 | 56 | ALTERNATIVA — Solapa con Anvil/Anvil_Log; silueta mucho más simple. | E03 |
| barrel_swords | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/barrel_swords.glb` | 0.666×1.200×0.700 | 72 | FUERA DE ALCANCE — Barril con espadas integrado; no esencial en RPG sin combate. | E03 opcional |
| battle_axe | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/battle_axe.glb` | 0.360×1.175×0.060 | 44 | FUERA DE ALCANCE — Arma, no hacha de carpintería preferida. | E03 opcional |
| bellows | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/bellows.glb` | 1.500×0.693×0.300 | 68 | APORTE — Fuelle; cubre carencia esencial de E03. | E03 |
| chain_hook | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/chain_hook.glb` | 0.124×2.000×0.124 | 340 | APORTE — Cadena vertical y gancho; distinta función de Chain_Coil. | E03/E04/E12 |
| coal_pile | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/coal_pile.glb` | 0.898×0.559×0.857 | 60 | APORTE — Carbón como utilería independiente; brasas ya existen en forja local. | E03 |
| dagger | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/dagger.glb` | 0.150×0.520×0.050 | 50 | FUERA DE ALCANCE — Arma decorativa; no necesaria. | E03 opcional |
| forge | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/forge.glb` | 2.000×4.050×1.600 | 84 | ALTERNATIVA — Forja completa de 4,05 de altura: no cabe bajo techo de 3 sin adaptación. Ya hay Forja propia. | E03, no primera opción |
| grindstone | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/grindstone.glb` | 0.840×0.800×0.800 | 92 | ALTERNATIVA — Afiladora manual; solapa con Whetstone. No es molino harinero. | E03/E04 |
| helmet | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/helmet.glb` | 0.520×0.625×0.483 | 52 | FUERA DE ALCANCE — Armadura decorativa; no necesaria. | E03 opcional |
| horseshoe | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/horseshoe.glb` | 0.350×0.050×0.333 | 92 | APORTE — Herradura independiente; mejora identidad del oficio. | E03/E10 |
| ingot_stack | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/ingot_stack.glb` | 0.940×0.300×0.150 | 72 | APORTE — Lingotes agrupados; cubren carencia de material de trabajo. | E03 |
| ore_rocks | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/ore_rocks.glb` | 0.833×0.535×0.656 | 80 | APORTE — Mena como recurso de taller, sin sistema de minería. | E03 |
| pickaxe | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/pickaxe.glb` | 1.040×1.038×0.072 | 48 | ALTERNATIVA — Pico; solapa con Pickaxe_Bronze. | E03/E12 almacén |
| quench_barrel | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/quench_barrel.glb` | 0.799×0.800×0.840 | 144 | ALTERNATIVA — Barril de enfriado; aporta uso de taller, ya existe Barrel/cubo. | E03 |
| round_shield | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/round_shield.glb` | 0.960×0.900×0.960 | 192 | FUERA DE ALCANCE — Escudo; no esencial. | E03 opcional |
| smith_hammer | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/smith_hammer.glb` | 0.280×0.870×0.100 | 32 | APORTE — Martillo de herrero independiente; alternativa a martillo propio o Props. | E03 |
| smithy_sign | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/smithy_sign.glb` | 0.950×2.000×0.120 | 48 | SECUNDARIO — Letrero de herrería; exterior o pared de taller. | E03 |
| sword | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/sword.glb` | 0.300×1.295×0.080 | 70 | FUERA DE ALCANCE — Espada; solapa con Sword_Bronze y no es prioridad. | E03 opcional |
| tongs | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/tongs.glb` | 0.142×0.726×0.050 | 36 | APORTE — Tenazas: cubren carencia esencial de E03. | E03 |
| tool_rack | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/tool_rack.glb` | 1.900×1.800×0.140 | 144 | APORTE — Soporte con herramientas; complemento más directo que WeaponStand. Revisar conjunto antes de extraer piezas. | E03/E04 |
| water_bucket | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/water_bucket.glb` | 0.476×0.462×0.500 | 136 | ALTERNATIVA — Cubo; solapa con Bucket_Metal/Wooden. | E03/E12 |
| weapon_crate | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/weapon_crate.glb` | 1.040×1.020×0.500 | 48 | FUERA DE ALCANCE — Caja con armas; no equivale a caja vacía. | E03 opcional |
| wood_log_pile | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/wood_log_pile.glb` | 1.000×0.460×0.760 | 112 | ALTERNATIVA — Pila independiente; ya hay troncos propios de carpintería. | E04/E12 |
| workbench | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/workbench.glb` | 2.000×1.050×0.800 | 96 | ALTERNATIVA — Banco de trabajo; ya existe Workbench y geometría propia. | E03/E04 |
| mdvl_interiors_altar_01 | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_altar_01.glb` | 1.420×1.310×0.820 | 2428 | FUERA DE ALCANCE — Altar con símbolos religiosos; no es armario doméstico ni mesa de herbolario. | Ninguno |
| mdvl_interiors_anvil_01 | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_anvil_01.glb` | 0.644×0.721×0.644 | 394 | ALTERNATIVA — Yunque con tocón; solapa con Anvil_Log. | E03 |
| mdvl_interiors_bed_01 | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_bed_01.glb` | 1.974×1.190×1.274 | 1056 | ALTERNATIVA — Cama de planta más compacta que Bed_Twin1/2. | E06–E11; E01 dormitorio |
| mdvl_interiors_bench_01 | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_bench_01.glb` | 1.240×0.960×0.480 | 616 | ALTERNATIVA — Banco con respaldo; solapa funcionalmente con Bench. | E01/E06–E11 |
| mdvl_interiors_candle_01 | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_candle_01.glb` | 0.155×0.239×0.116 | 430 | APORTE — Vela con llama y clip de 3 s; antes había velas estáticas. | E01/E05/E06–E11 |
| mdvl_interiors_cauldron_01 | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_cauldron_01.glb` | 0.555×0.684×0.545 | 1397 | ALTERNATIVA — Caldero para colgar; solapa con Cauldron, combinar con potcrane. | E01/E05/E06–E11 |
| mdvl_interiors_chair_01 | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_chair_01.glb` | 0.470×0.980×0.465 | 428 | ALTERNATIVA — Silla de madera; solapa con Chair_1. | E01/E06–E11 |
| mdvl_interiors_chest_01 | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_chest_01.glb` | 0.837×0.340×0.525 | 816 | APORTE — Cuerpo de cofre sin tapa, separado por archivo; usar con chest_lid. | E06–E11/E01 |
| mdvl_interiors_chest_lid_01 | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_chest_lid_01.glb` | 0.744×0.268×0.507 | 256 | APORTE — Tapa separada; componente del cofre, no segundo mueble. | E06–E11/E01 |
| mdvl_interiors_curtain_01 | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_curtain_01.glb` | 1.187×1.040×0.110 | 372 | APORTE — Cortina con barra; cubre textil doméstico ausente. | E06–E11/E01 |
| mdvl_interiors_cushion_01 | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_cushion_01.glb` | 0.400×0.148×0.400 | 340 | APORTE — Cojín con borlas; cubre textil ausente. | E06–E11/E01 |
| mdvl_interiors_flame_01 | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_flame_01.glb` | 0.026×0.062×0.023 | 58 | APORTE — Llama pequeña animada independiente; no emite luz de escena. | E01/E05/E06–E11 |
| mdvl_interiors_flame_02 | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_flame_02.glb` | 0.172×0.230×0.150 | 256 | APORTE — Llama grande animada; preferir GLB por incidencias FBX. | E01/E02/E03 |
| mdvl_interiors_lantern_01 | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_lantern_01.glb` | 0.133×0.289×0.133 | 338 | ALTERNATIVA — Farol compacto de sobremesa; distinto del soporte Lantern_Wall. | E01/E04/E06–E12 |
| mdvl_interiors_painting_01 | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_painting_01.glb` | 0.856×0.721×0.060 | 716 | APORTE — Cuadro figurativo de castillo, confirmado visualmente. | E01/E06/E07/E11 |
| mdvl_interiors_pew_01 | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_pew_01.glb` | 1.840×1.070×0.490 | 1008 | ALTERNATIVA — Banco largo de madera; aprovechable sin altar, comprobar estilo. | E01 opcional |
| mdvl_interiors_pot_01 | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_pot_01.glb` | 0.253×0.237×0.310 | 680 | ALTERNATIVA — Olla; solapa con Pot_1, nueva variante compacta. | E01/E06–E11 |
| mdvl_interiors_potcrane_01 | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_potcrane_01.glb` | 0.210×1.430×0.960 | 1028 | APORTE — Brazo y cadena para colgar caldero; no es hogar completo. | E01/E06–E11 |
| mdvl_interiors_pottedplant_01 | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_pottedplant_01.glb` | 0.732×0.779×0.666 | 802 | APORTE — Maceta con planta como modelo independiente; ya había composiciones propias. | E05/E06/E11 |
| mdvl_interiors_rug_01 | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_rug_01.glb` | 1.600×0.028×1.600 | 532 | APORTE — Alfombra doméstica; cubre carencia previa. | E01/E06–E11 |
| mdvl_interiors_shelf_01 | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_shelf_01.glb` | 1.000×0.264×0.230 | 72 | ALTERNATIVA — Repisa compacta; solapa con Shelf_Simple. | E01/E02/E05–E12 |
| mdvl_interiors_table_01 | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_table_01.glb` | 0.770×0.760×1.390 | 464 | APORTE — Mesa compacta 0,77×1,39 en planta; complementa Table_Large. | E01/E02/E05–E11 |
| mdvl_interiors_walltorch_01 | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_walltorch_01.glb` | 0.164×0.674×0.290 | 516 | APORTE — Antorcha con llama animada; preferir GLB por incidencias FBX. | E01/E03/E12 |
| mdvl_interiors_woodpile_01 | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_woodpile_01.glb` | 1.019×0.696×0.893 | 804 | ALTERNATIVA — Leñero completo independiente; ya había leñeras propias. | E02/E04/E06–E12 |
| mdvl_interiors_workbench_01 | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_workbench_01.glb` | 1.600×1.005×0.838 | 1064 | ALTERNATIVA — Banco con tornillo/prensa visible; mejora variante de carpintería. | E04/E03 |

## 7. medv-cafe: candidatos condicionados y exclusiones

**No incorporar estos archivos todavía sin confirmar su licencia y procedencia.** No se puede transferir CC0 de los otros paquetes a este. La siguiente tabla describe viabilidad técnica/visual; no concede autorización de uso. Todos cargaron en Godot, pero los ajustes materiales, de gráficos y de escala siguen pendientes.

| Modelo | Ruta exacta | AABB X×Y×Z | Triángulos | Selección artística y limitación |
|---|---|---|---:|---|
| balance-scale | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/balance-scale.fbx` | 0.226×0.193×0.085 | 282 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **Uso pendiente de licencia.** |
| basket-of-jars | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/basket-of-jars.fbx` | 0.250×0.127×0.490 | 740 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **Uso pendiente de licencia.** |
| basket-of-pastries | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/basket-of-pastries.fbx` | 0.266×0.232×0.267 | 500 | APORTE/VARIANTE: Comida preparada o exposición con más detalle texturado que Avramania. **E01: selección artística aprobada para integración académica local; verificación de licencia pendiente.** |
| bottle01 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/bottle01.fbx` | 0.113×0.384×0.104 | 126 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **Uso pendiente de licencia.** |
| bottle02 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/bottle02.fbx` | 0.117×0.256×0.117 | 178 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **Uso pendiente de licencia.** |
| bowl-of-stew | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/bowl-of-stew.fbx` | 0.141×0.060×0.163 | 104 | APORTE/VARIANTE: Comida preparada o exposición con más detalle texturado que Avramania. **E01: selección artística aprobada para integración académica local; verificación de licencia pendiente.** |
| chair01 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/chair01.fbx` | 0.588×1.261×0.872 | 272 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **E01: selección artística aprobada para integración académica local; verificación de licencia pendiente.** |
| coffee-beans-prep | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/coffee-beans-prep.fbx` | 0.161×0.014×0.161 | 84 | EXCLUIR TEMA: Preparación de café sobre lámina; no necesaria para taberna medieval. **Uso pendiente de licencia.** |
| coffee-grinder | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/coffee-grinder.fbx` | 0.236×0.353×0.159 | 268 | NO SELECCIONAR DE INICIO: Molinillo manual de café: no es eléctrico; posible adaptación a especias, nunca molino de grano de E12. **Uso pendiente de licencia.** |
| column01 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/column01.fbx` | 0.250×3.000×0.300 | 12 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **Uso pendiente de licencia.** |
| column02 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/column02.fbx` | 1.501×3.000×0.250 | 32 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **Uso pendiente de licencia.** |
| column03 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/column03.fbx` | 0.875×3.000×0.250 | 22 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **Uso pendiente de licencia.** |
| column04 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/column04.fbx` | 0.875×3.000×0.250 | 22 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **Uso pendiente de licencia.** |
| counter_BL | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/counter_BL.fbx` | 1.357×1.150×1.356 | 116 | APORTE: Módulo de barra de madera; cubre mostrador, con encaje y licencia por verificar. **E01: selección artística aprobada para integración académica local; verificación de licencia pendiente.** |
| counter_BR | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/counter_BR.fbx` | 1.352×1.150×1.351 | 116 | APORTE: Módulo de barra de madera; cubre mostrador, con encaje y licencia por verificar. **E01: selección artística aprobada para integración académica local; verificación de licencia pendiente.** |
| counter_L | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/counter_L.fbx` | 1.600×1.150×0.900 | 44 | APORTE: Módulo de barra de madera; cubre mostrador, con encaje y licencia por verificar. **E01: selección artística aprobada para integración académica local; verificación de licencia pendiente.** |
| counter_M | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/counter_M.fbx` | 1.500×1.150×0.900 | 44 | APORTE: Módulo de barra de madera; cubre mostrador, con encaje y licencia por verificar. **E01: selección artística aprobada para integración académica local; verificación de licencia pendiente.** |
| counter_R | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/counter_R.fbx` | 1.600×1.150×0.900 | 44 | APORTE: Módulo de barra de madera; cubre mostrador, con encaje y licencia por verificar. **E01: selección artística aprobada para integración académica local; verificación de licencia pendiente.** |
| crate01 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/crate01.fbx` | 0.700×0.700×0.700 | 108 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **Uso pendiente de licencia.** |
| crate02 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/crate02.fbx` | 0.700×0.723×0.700 | 330 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **Uso pendiente de licencia.** |
| door01 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/door01.fbx` | 1.350×2.065×0.240 | 408 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **Uso pendiente de licencia.** |
| drip-coffee-maker | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/drip-coffee-maker.fbx` | 0.459×0.535×0.220 | 534 | EXCLUIR TEMA: Cafetera de goteo con servicio de tazas; evitar lectura de cafetería contemporánea. **Uso pendiente de licencia.** |
| floor | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/floor.fbx` | 3.000×0.072×3.000 | 12 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **Uso pendiente de licencia.** |
| food-bread01 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/food-bread01.fbx` | 0.193×0.083×0.161 | 40 | APORTE/VARIANTE: Comida preparada o exposición con más detalle texturado que Avramania. **Uso pendiente de licencia.** |
| food-bread02 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/food-bread02.fbx` | 0.290×0.065×0.162 | 100 | APORTE/VARIANTE: Comida preparada o exposición con más detalle texturado que Avramania. **Uso pendiente de licencia.** |
| food-bread03 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/food-bread03.fbx` | 0.789×0.126×0.141 | 44 | APORTE/VARIANTE: Comida preparada o exposición con más detalle texturado que Avramania. **Uso pendiente de licencia.** |
| food-bread04 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/food-bread04.fbx` | 0.372×0.093×0.161 | 40 | APORTE/VARIANTE: Comida preparada o exposición con más detalle texturado que Avramania. **Uso pendiente de licencia.** |
| food-display | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/food-display.fbx` | 1.840×1.323×0.819 | 440 | APORTE: Expositor abierto de madera; no vitrina refrigerada. **E01: selección artística aprobada para integración académica local; verificación de licencia pendiente.** |
| food-sausage | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/food-sausage.fbx` | 0.375×0.065×0.296 | 128 | APORTE/VARIANTE: Comida preparada o exposición con más detalle texturado que Avramania. **Uso pendiente de licencia.** |
| fruit-apple | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/fruit-apple.fbx` | 0.119×0.133×0.116 | 49 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **Uso pendiente de licencia.** |
| herb-drying-hanger | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/herb-drying-hanger.fbx` | 0.697×0.562×0.089 | 334 | APORTE: Secadero de hierbas con manojos; forma específica nueva frente a manojo suelto. **Uso pendiente de licencia.** |
| jug01 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/jug01.fbx` | 0.214×0.174×0.204 | 142 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **E01: selección artística aprobada para integración académica local; verificación de licencia pendiente.** |
| keg01 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/keg01.fbx` | 0.693×0.746×0.765 | 434 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **E01: selección artística aprobada para integración académica local; verificación de licencia pendiente.** |
| keg02 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/keg02.fbx` | 0.849×0.868×0.849 | 212 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **E01: selección artística aprobada para integración académica local; verificación de licencia pendiente.** |
| menu-stand01 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/menu-stand01.fbx` | 0.560×1.640×0.480 | 324 | ADAPTABLE: Soporte utilizable; revisar/sustituir ilustración y menú antes de integrarlo. **Uso pendiente de licencia.** |
| menu-stand02 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/menu-stand02.fbx` | 0.270×0.257×0.197 | 118 | ADAPTABLE: Soporte utilizable; revisar/sustituir ilustración y menú antes de integrarlo. **Uso pendiente de licencia.** |
| menu-stand03 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/menu-stand03.fbx` | 0.700×1.690×0.242 | 174 | EXCLUIR GRÁFICA: Pizarra con iconografía de cafetería; soporte de madera adaptable tras sustituir gráfica. **Uso pendiente de licencia.** |
| mug01 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/mug01.fbx` | 0.152×0.120×0.104 | 160 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **E01: selección artística aprobada para integración académica local; verificación de licencia pendiente.** |
| mug02 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/mug02.fbx` | 0.134×0.120×0.092 | 136 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **E01: selección artística aprobada para integración académica local; verificación de licencia pendiente.** |
| mug03 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/mug03.fbx` | 0.145×0.120×0.099 | 212 | ADAPTABLE: Cerámica blanca facetada; falta mapa de albedo conectado aunque existe en tex. No inferir un material ausente. **Uso pendiente de licencia.** |
| pitcher | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/pitcher.fbx` | 0.211×0.269×0.169 | 248 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **E01: selección artística aprobada para integración académica local; verificación de licencia pendiente.** |
| plaque | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/plaque.fbx` | 0.627×0.746×0.058 | 130 | EXCLUIR GRÁFICA: Texto inglés “Coffee fresh” y bebida para llevar; requeriría otra gráfica. **Uso pendiente de licencia.** |
| platter-meal01 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/platter-meal01.fbx` | 0.301×0.095×0.293 | 353 | APORTE/VARIANTE: Comida preparada o exposición con más detalle texturado que Avramania. **E01: selección artística aprobada para integración académica local; verificación de licencia pendiente.** |
| platter-meal02 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/platter-meal02.fbx` | 0.393×0.135×0.314 | 320 | APORTE/VARIANTE: Comida preparada o exposición con más detalle texturado que Avramania. **E01: selección artística aprobada para integración académica local; verificación de licencia pendiente.** |
| platter-of-pie | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/platter-of-pie.fbx` | 0.161×0.043×0.185 | 90 | APORTE/VARIANTE: Comida preparada o exposición con más detalle texturado que Avramania. **Uso pendiente de licencia.** |
| pouch-of-coins | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/pouch-of-coins.fbx` | 0.144×0.122×0.150 | 248 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **Uso pendiente de licencia.** |
| shelf01 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/shelf01.fbx` | 1.200×2.120×0.610 | 162 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **E01: selección artística aprobada para integración académica local; verificación de licencia pendiente.** |
| shelf02 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/shelf02.fbx` | 1.000×1.530×0.610 | 92 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **E01: selección artística aprobada para integración académica local; verificación de licencia pendiente.** |
| shield | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/shield.fbx` | 0.666×0.666×0.039 | 44 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **Uso pendiente de licencia.** |
| stool | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/stool.fbx` | 0.389×0.805×0.389 | 124 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **E01: selección artística aprobada para integración académica local; verificación de licencia pendiente.** |
| table-candle | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/table-candle.fbx` | 0.137×0.126×0.138 | 204 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **E01: selección artística aprobada para integración académica local; verificación de licencia pendiente.** |
| table-cloth01 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/table-cloth01.fbx` | 1.335×0.126×1.335 | 44 | APORTE/VARIANTE: Textil útil; table-cloth01/02 comparten posiciones/índices y difieren en material. **Uso pendiente de licencia.** |
| table-cloth02 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/table-cloth02.fbx` | 1.335×0.126×1.335 | 44 | APORTE/VARIANTE: Textil útil; table-cloth01/02 comparten posiciones/índices y difieren en material. **Uso pendiente de licencia.** |
| table-cloth03 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/table-cloth03.fbx` | 2.240×0.320×0.600 | 48 | APORTE/VARIANTE: Textil útil; table-cloth01/02 comparten posiciones/índices y difieren en material. **Uso pendiente de licencia.** |
| table01 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/table01.fbx` | 1.100×0.810×1.100 | 204 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **E01: selección artística aprobada para integración académica local; verificación de licencia pendiente.** |
| table02 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/table02.fbx` | 1.600×0.810×1.600 | 228 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **E01: selección artística aprobada para integración académica local; verificación de licencia pendiente.** |
| table03 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/table03.fbx` | 2.200×0.810×1.100 | 276 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **E01: selección artística aprobada para integración académica local; verificación de licencia pendiente.** |
| tapestry01 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/tapestry01.fbx` | 0.710×1.206×0.041 | 40 | APORTE/VARIANTE: Textil útil; table-cloth01/02 comparten posiciones/índices y difieren en material. **E01: selección artística aprobada para integración académica local; verificación de licencia pendiente.** |
| tapestry02 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/tapestry02.fbx` | 0.710×1.740×0.041 | 41 | APORTE/VARIANTE: Textil útil; table-cloth01/02 comparten posiciones/índices y difieren en material. **E01: selección artística aprobada para integración académica local; verificación de licencia pendiente.** |
| veg-tomato | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/veg-tomato.fbx` | 0.122×0.120×0.116 | 54 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **Uso pendiente de licencia.** |
| wall-candle | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/wall-candle.fbx` | 0.069×0.239×0.200 | 418 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **E01: selección artística aprobada para integración académica local; verificación de licencia pendiente.** |
| wall01_d01 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/wall01_d01.fbx` | 3.000×3.000×0.190 | 92 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **Uso pendiente de licencia.** |
| wall01_full | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/wall01_full.fbx` | 3.000×3.000×0.190 | 44 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **Uso pendiente de licencia.** |
| wall01f_full | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/wall01f_full.fbx` | 3.000×3.000×0.300 | 80 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **Uso pendiente de licencia.** |
| wall01f_w01 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/wall01f_w01.fbx` | 3.000×3.000×0.300 | 100 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **Uso pendiente de licencia.** |
| window01 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/window01.fbx` | 1.400×1.570×0.340 | 182 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **Uso pendiente de licencia.** |
| window02 | `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/window02.fbx` | 1.400×1.570×0.340 | 284 | ALTERNATIVA: Utilería o arquitectura compatible visualmente con adaptación; contrastar con fondo anterior. **Uso pendiente de licencia.** |

No se descarta el molinillo por tener motor eléctrico: la captura muestra un mecanismo manual de manivela. Se omite de la selección inicial por su función de café y por licencia; podría adaptarse a especias tras revisión. La cafetera de goteo y sus tazas, el texto de café para llevar y la pizarra con iconografía de cafetería introducen otra temática. Las estructuras de barra/expositor sí son de madera y aprovechables en principio. Las armas, lápidas y altar de otros paquetes se dejan fuera por función del juego, no por modernidad.

## 8. Selección por edificio

Esta selección combina **nuevos modelos con licencia local y recursos anteriores**, conservando la necesidad de revisar las licencias históricas del fondo anterior según inventario. E01 incorpora además la selección artística aprobada de medv-cafe para integración académica local, con verificación de licencia pendiente; la decisión no se extiende automáticamente a otros edificios. “Listo para comenzar” significa que hay base suficiente para autoría del interior, no edificio terminado, transición implementada ni mobiliario ya colocado.

### E01 — Taberna

**Selección artística aprobada para integración local:** utilizar `RPG/assets/interiores_medievales/Taberna/medv-cafe/` como uno de los recursos principales de decoración de E01. El proyecto es exclusivamente académico y no comercial. Esta decisión actualiza la planificación; el interior todavía no está construido y la aprobación artística no acredita una licencia.

Priorizar los siguientes **27 modelos**, verificados en la carpeta `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/`. Cada nombre corresponde al archivo `<nombre>.fbx` de esa carpeta:

| Uso previsto | Modelos prioritarios |
|---|---|
| Barra medieval modular | `counter_BL`, `counter_BR`, `counter_L`, `counter_M`, `counter_R` |
| Mesas de distintos tamaños | `table01`, `table02`, `table03` |
| Asientos | `chair01`, `stool` |
| Barriles | `keg01`, `keg02` |
| Estanterías | `shelf01`, `shelf02` |
| Expositor abierto de alimentos | `food-display` |
| Comida preparada | `basket-of-pastries`, `bowl-of-stew`, `platter-meal01`, `platter-meal02` |
| Vajilla | `mug01`, `mug02`, `pitcher`, `jug01` |
| Iluminación decorativa | `table-candle`, `wall-candle` |
| Decoración de paredes | `tapestry01`, `tapestry02` |

Criterios para la integración posterior:

- Componer la barra con los módulos que encajen; no es obligatorio colocar todas las variantes ni se fijan cantidades. El hogar/fogón sigue requiriendo diseño propio.
- Combinar estos modelos con Avramania y objetos medievales existentes cuando convenga, utilizando los complementos de la tabla siguiente. Revisar en contexto texturas, colores y proporciones para mantener coherencia visual.
- Conservar al protagonista sin escalar y reservar espacio suficiente entre entrada, barra, mesas y asientos. Validar encajes, circulación y colisiones simplificadas al construir. El taburete mide aproximadamente 0,805 de alto frente a mesas de 0,81: evaluar su uso junto a la barra de 1,15 y comprobar ergonomía antes de emparejarlo con mesas.
- No utilizar cafeteras modernas, carteles de café para llevar, iconografía contemporánea ni elementos que rompan la ambientación medieval. Excluir `drip-coffee-maker`, `coffee-beans-prep`, `plaque` y la gráfica contemporánea de `menu-stand03`; el molinillo de café sigue fuera de la selección inicial.
- Otros modelos del paquete pueden considerarse si encajan con una taberna medieval; la decisión no aprueba automáticamente los 67 modelos. Las velas son decoración y no acreditan luces dinámicas o animaciones implementadas.
- Conservar intactos los originales: no eliminar, modificar, mover ni renombrar modelos, texturas o archivos fuente. Los ajustes posteriores deben hacerse en instancias o recursos propios.

**Licencia pendiente:** no se encontró licencia en la copia descargada; autoría, condiciones y atribución siguen sin confirmar. El destino es académico local, exclusivamente no comercial. No asumir CC0 ni que el uso académico conceda automáticamente permiso de uso o redistribución. Obtener y verificar procedencia y licencia antes de decidir cualquier distribución del juego o de los recursos. La selección artística no autoriza subir originales a Git ni redistribuirlos.

**Complementos disponibles de Avramania y objetos medievales** (la prioridad de mobiliario de E01 pasa a medv-cafe):

| Uso | Modelo y ruta exacta |
|---|---|
| Mesa compacta | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_table_01.glb` |
| Sillas | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_chair_01.glb` |
| Banco | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_bench_01.glb` |
| Jarra de cerveza | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_ale_mug_01.glb` |
| Barrilete | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_cask_01.glb` |
| Hogaza/queso | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_loaf_01.glb` |
| Queso | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_cheese_wheel_01.glb` |
| Vela | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_candle_01.glb` |
| Alfombra | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_rug_01.glb` |
| Taburete (existente) | `RPG/assets/objetos_medievales/glTF/Stool.gltf` |
| Mesa de grupo (existente) | `RPG/assets/objetos_medievales/glTF/Table_Large.gltf` |

### E02 — Panadería

LISTA para comenzar con horno propio y productos nuevos. Aún hay que crear artesa, masa, rodillo y pala de horno; una pala de tierra no sustituye esta última.

| Uso | Modelo y ruta exacta |
|---|---|
| Hogaza | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_loaf_01.glb` |
| Panecillo | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_roll_01.glb` |
| Saco de grano | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_grain_sack_01.glb` |
| Balanza | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_scales_01.glb` |
| Cesta vacía | `RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/glTF/mdvl_props_basket_01.glb` |
| Bandeja/caja | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_produce_crate_01.glb` |
| Repisa | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_shelf_01.glb` |
| Leñero | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_woodpile_01.glb` |
| Banco de preparación (existente) | `RPG/assets/objetos_medievales/glTF/Workbench.gltf` |

### E03 — Herrería

LISTA para comenzar: fuelle, tenazas y lingotes cubren los huecos principales. Conservar la forja propia como referencia; forge.glb mide 4,05 de alto.

| Uso | Modelo y ruta exacta |
|---|---|
| Fuelle | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/bellows.glb` |
| Tenazas | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/tongs.glb` |
| Lingotes | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/ingot_stack.glb` |
| Martillo | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/smith_hammer.glb` |
| Carbón | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/coal_pile.glb` |
| Herraduras | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/horseshoe.glb` |
| Soporte de herramientas | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/tool_rack.glb` |
| Cadena/gancho | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/chain_hook.glb` |
| Yunque con tocón (existente) | `RPG/assets/objetos_medievales/glTF/Anvil_Log.gltf` |
| Afiladora (existente) | `RPG/assets/objetos_medievales/glTF/Whetstone.gltf` |
| Cubo (existente) | `RPG/assets/objetos_medievales/glTF/Bucket_Metal.gltf` |

### E04 — Carpintería

LISTA para comenzar. El banco nuevo muestra tornillo/prensa; se pueden conservar sierra, cepillo y escuadra propios de la escena existente.

| Uso | Modelo y ruta exacta |
|---|---|
| Banco con prensa | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_workbench_01.glb` |
| Martillo | `RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/glTF/mdvl_props_hammer_01.glb` |
| Hacha | `RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/glTF/mdvl_props_axe_01.glb` |
| Pila de madera | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/wood_log_pile.glb` |
| Rueda en reparación | `RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/glTF/mdvl_props_cart_wheel_01.glb` |
| Cadena/gancho | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/chain_hook.glb` |
| Cuerda (existente) | `RPG/assets/objetos_medievales/glTF/Rope_1.gltf` |

### E05 — Herbolario

LISTO para comenzar con hierbas colgadas, pesaje, frascos y mortero propio. El secadero de medv-cafe queda como opción posterior a la licencia.

| Uso | Modelo y ruta exacta |
|---|---|
| Hierbas | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_herb_bundle_01.glb` |
| Balanza | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_scales_01.glb` |
| Mesa | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_table_01.glb` |
| Maceta | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_pottedplant_01.glb` |
| Cesta | `RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/glTF/mdvl_props_basket_01.glb` |
| Vela | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_candle_01.glb` |
| Frasco individual (existente) | `RPG/assets/objetos_medievales/glTF/SmallBottle.gltf` |
| Estante con botellas (existente) | `RPG/assets/objetos_medievales/glTF/Shelf_Small_Bottles.gltf` |
| Libros/estantería (existente) | `RPG/assets/objetos_medievales/glTF/Bookcase_2.gltf` |

### E06 — Vivienda noroeste

LISTA para comenzar. Identidad de artesanos mediante herramientas/libros; falta diseñar hogar compacto y confirmar el encaje.

| Uso | Modelo y ruta exacta |
|---|---|
| Cama compacta | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_bed_01.glb` |
| Cuerpo cofre | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_chest_01.glb` |
| Tapa cofre | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_chest_lid_01.glb` |
| Mesa | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_table_01.glb` |
| Silla | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_chair_01.glb` |
| Cortina | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_curtain_01.glb` |
| Farol | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_lantern_01.glb` |
| Mueble bajo (existente) | `RPG/assets/objetos_medievales/glTF/Cabinet.gltf` |
| Libro (existente) | `RPG/assets/objetos_medievales/glTF/Book_5.gltf` |

### E07 — Vivienda noreste

LISTA para comenzar mobiliario familiar; escalera/descansillo compactos de dos niveles siguen requiriendo diseño propio.

| Uso | Modelo y ruta exacta |
|---|---|
| Cama | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_bed_01.glb` |
| Mesa | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_table_01.glb` |
| Silla | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_chair_01.glb` |
| Cojín | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_cushion_01.glb` |
| Alfombra | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_rug_01.glb` |
| Cortina | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_curtain_01.glb` |
| Cuadro | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_painting_01.glb` |
| Cofre alternativo completo (existente) | `RPG/assets/objetos_medievales/glTF/Chest_Wood.gltf` |
| Estantería (existente) | `RPG/assets/objetos_medievales/glTF/Bookcase_2.gltf` |

### E08 — Vivienda suroeste

LISTA para comenzar hogar rural. Brazo de caldero y leña ayudan a componer un fogón, pero no sustituyen su base ni colisiones.

| Uso | Modelo y ruta exacta |
|---|---|
| Cama | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_bed_01.glb` |
| Mesa | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_table_01.glb` |
| Banco | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_bench_01.glb` |
| Olla | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_pot_01.glb` |
| Caldero | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_cauldron_01.glb` |
| Brazo del caldero | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_potcrane_01.glb` |
| Leñero | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_woodpile_01.glb` |
| Saco doméstico (existente) | `RPG/assets/objetos_medievales/glTF/Bag.gltf` |

### E09 — Vivienda sur

LISTA para comenzar. Diferenciar con almacenaje y alimentos del huerto, conservando la galería exterior.

| Uso | Modelo y ruta exacta |
|---|---|
| Cama | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_bed_01.glb` |
| Mesa | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_table_01.glb` |
| Silla | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_chair_01.glb` |
| Olla | `RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/glTF/mdvl_props_pot_01.glb` |
| Cesta | `RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/glTF/mdvl_props_basket_01.glb` |
| Repisa | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_shelf_01.glb` |
| Cortina | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_curtain_01.glb` |
| Verduras en caja (existente) | `RPG/assets/objetos_medievales/glTF/FarmCrate_Carrot.gltf` |

### E10 — Vivienda del granjero

LISTA para comenzar vivienda y almacenaje doméstico; mantener pala/carretilla en zona de servicio si ocupan demasiado espacio.

| Uso | Modelo y ruta exacta |
|---|---|
| Cama | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_bed_01.glb` |
| Mesa | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_table_01.glb` |
| Silla | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_chair_01.glb` |
| Saco con grano | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_grain_sack_01.glb` |
| Cesta | `RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/glTF/mdvl_props_basket_01.glb` |
| Pala | `RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/glTF/mdvl_props_shovel_01.glb` |
| Farol | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_lantern_01.glb` |
| Caja agrícola (existente) | `RPG/assets/objetos_medievales/glTF/FarmCrate_Empty.gltf` |

### E11 — Vivienda floral

LISTA para comenzar. Macetas y textiles nuevos aportan identidad; las flores propias existentes siguen siendo reutilizables.

| Uso | Modelo y ruta exacta |
|---|---|
| Cama | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_bed_01.glb` |
| Mesa | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_table_01.glb` |
| Silla | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_chair_01.glb` |
| Maceta | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_pottedplant_01.glb` |
| Alfombra | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_rug_01.glb` |
| Cortina | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_curtain_01.glb` |
| Cuadro | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_painting_01.glb` |
| Jarrón (existente) | `RPG/assets/objetos_medievales/glTF/Vase_4.gltf` |

### E12 — Molino

LISTO solo para comenzar almacén/taller y plantear el interior; NO completo como molino harinero. Faltan los elementos de molienda y transmisión.

| Uso | Modelo y ruta exacta |
|---|---|
| Grano visible | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_grain_sack_01.glb` |
| Balanza | `RPG/assets/interiores_medievales/Alimentos/Food_Market/glTF/mdvl_food_scales_01.glb` |
| Saco cerrado | `RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/glTF/mdvl_props_sack_01.glb` |
| Cadena/gancho | `RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/GLB/chain_hook.glb` |
| Farol | `RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/glTF/mdvl_interiors_lantern_01.glb` |
| Rueda de carro como reparación, no transmisión | `RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/glTF/mdvl_props_cart_wheel_01.glb` |
| Barril (existente) | `RPG/assets/objetos_medievales/glTF/Barrel.gltf` |
| Banco (existente) | `RPG/assets/objetos_medievales/glTF/Workbench.gltf` |
| Caja (existente) | `RPG/assets/objetos_medievales/glTF/Crate_Wooden.gltf` |

### Composiciones anteriores que conviene preservar y reutilizar como referencia

| Edificio | Ruta exacta y conjunto existente | Qué evita volver a buscar |
|---|---|---|
| E02 | RPG/scenes/panaderia.tscn → Horno | Horno y campana ya representados con geometría propia; no hay horno nuevo en la edición gratuita de Interiors_Furniture. |
| E03 | RPG/scenes/herreria.tscn → Forja y Herramientas | Forja, martillo y brasas existentes; conservarlos mientras se diseña una adaptación interior. |
| E04 | RPG/scenes/carpinteria.tscn → Herramientas y Almacen | Sierra, mazo, cepillo, escuadra, troncos y vigas; no se encontraron nuevos modelos dedicados de sierra/cepillo en los cinco catálogos individuales. |
| E05 | RPG/scenes/herbolario.tscn → MesaPreparacion | Mesa, Mortero, HuecoMortero y ManoMortero; los nuevos frascos no sustituyen el mortero. |
| E11 | RPG/scenes/vivienda_e11.tscn → Exterior | Macetas y flores propias para ampliar la variante floral. |
| E12 | RPG/scenes/molino.tscn → MecanismoHidraulico | Rueda, radios, paletas y eje exteriores; no moverlos para resolver el interior. |

## 9. Recursos todavía faltantes y molino

### Prioridad alta

- **E12:** pareja de muelas de molienda, bancada, tolva, dosificador/canal de grano, transmisión con ejes/engranajes y salida de harina. Ninguno de los cinco paquetes aporta un conjunto harinero identificado. grindstone y Whetstone son afiladoras; cart_wheel es rueda de carro y coffee-grinder es molinillo pequeño, no sustitutos.
- **E02:** masa, artesa, rodillo y pala de horno. Los panes ya no deben pedirse como recurso faltante. Se pueden construir estos utensilios con cajas/cilindros y malla sencilla de Godot en una tarea posterior.
- **Viviendas/E01:** hogar/fogón requieren composición; se puede reutilizar autoría de horno/forja. E01 planifica la barra con los módulos medv-cafe aprobados para integración local, pendientes de encaje y circulación. Potcrane aporta suspensión, no fuego, campana ni mampostería.

### Prioridad media

Ropero alto y escritorio dedicado con más diversidad; escalera/descansillo que quepan en E07; bandejas de secado y etiquetas de herbolario; más tipos de utensilio agrícola si el interior de E10 lo requiere. Ya existen alfombra, cortina, cojín, cuadro, cesta vacía, hierbas, fuelle y tenazas: no recomendarlos otra vez como ausencias totales.

### Propuesta constructiva para E12

1. Preservar el exterior y el eje hidráulico original. Diseñar una bancada independiente alineada visualmente con la transmisión prevista, sin mover el edificio o su rueda.
2. Representar las dos muelas con cilindros de piedra de pocas caras y hueco/surcos visibles mediante geometría sencilla; la forma de afiladora no acredita el mecanismo correcto.
3. Construir tolva de madera como tronco de pirámide invertida, canal de grano y cajón de harina; añadir granos/sacos Avramania y balanza como lectura de actividad.
4. Añadir ejes y ruedas dentadas propias coherentes con el eje exterior. Primero validar disposición estática y circulación; cualquier animación funcional o de molienda sería una tarea aparte. La cadena/gancho nueva sirve para elevación o almacén, no demuestra un sistema de poleas completo.
5. Reservar paso para cápsula de 0,64 y zonas de trabajo. No escalar al protagonista ni colisionar el edificio como caja completa. No inventar dimensiones finales antes de medir la escena interior.

**No hace falta descargar otro paquete para comenzar estas formas low-poly.** Un conjunto externo específico de molienda solo sería útil si se desea más detalle o ahorrar autoría mecánica; esta auditoría no buscó ni descargó productos adicionales.

## 10. Licencias y atribuciones

Resumen de textos locales, no verificación de la cadena de derechos en un sitio externo. Las rutas siguientes son las fuentes de las condiciones; conservarlas con procedencia. No se consultaron tiendas ni se asignó una licencia por el nombre de un paquete.

| Paquete | Fuente exacta | Condiciones documentadas y atribución |
|---|---|---|
| Food & Market, Avramania | RPG/assets/interiores_medievales/Alimentos/Food_Market/License.txt | CC0 1.0; permite uso/modificación y comercial, sin crédito obligatorio. Solicita no volver a subir el paquete tal cual, expresamente como petición y no condición. Crédito opcional: Avramania — Food & Market. |
| Props, Tools & Fencing, Avramania | RPG/assets/interiores_medievales/Herramientas/Props_Tools_Fencing/License.txt | Mismas condiciones CC0 y petición; atribución opcional a Avramania. |
| Interiors & Furniture, Avramania | RPG/assets/interiores_medievales/Mobiliario/Interiors_Furniture/License.txt | Mismas condiciones CC0 y petición; atribución opcional a Avramania. |
| Low Poly Blacksmith Pack, reodesuxz | RPG/assets/interiores_medievales/Herreria/LowPolyBlacksmithPack_v1.0/LICENSE.txt | Uso personal/comercial y modificación permitidos; no requiere atribución, crédito apreciado: Low Poly Blacksmith Pack by reodesuxz. Prohíbe revender/sublicenciar/redistribuir archivos como assets independientes o parte de otro paquete/biblioteca, modificados o no, y usarlos para entrenar/ajustar IA. No es CC0. |
| medv-cafe | Carpeta RPG/assets/interiores_medievales/Taberna/medv-cafe/; sin LICENSE/README de licencia localizado | Autor y condiciones no confirmados en la copia local. No se puede determinar atribución ni autorización de distribución. Selección artística de E01 aprobada para integración académica local, exclusivamente no comercial; verificación de procedencia/licencia pendiente. No es CC0 acreditado ni el uso académico concede automáticamente permiso de redistribución del juego o de los originales. |

Los README Avramania declaran autoría por scripts de Blender con asistencia de un asistente de programación; Herramientas y Mobiliario también declaran algunas mallas iniciales de Tripo AI. Esto se registra como procedencia declarada, sin atribuir esa técnica a todas las piezas ni convertirlo en una licencia distinta. No se subieron originales a ningún servicio externo de análisis.

## 11. Integridad, límites y cierre

Se verificaron los hashes de los archivos fuente registrados: **no cambiaron los modelos, texturas, licencias ni catálogos de la copia original**. No hubo escritura intencional de esta auditoría sobre assets, escenas, scripts o ajustes de importación del proyecto principal.

**Observación de concurrencia:** ya había otra instancia de Godot antes de iniciar las pruebas temporales. Durante la sesión cambiaron metadatos .import y aparecieron más .import/texturas de paleta extraídas en la carpeta original. Se registró la variación; no se puede atribuir su causa solo a partir del censo. No se borraron ni revirtieron esos derivados, y no se afirma que la carpeta completa permaneciera byte a byte inmutable. Las pruebas descritas usaron --path del proyecto temporal; los hashes de las fuentes existentes sí se conservaron.

En Git ya estaban presentes la eliminación de RPG/docs/guia_tecnica_presentacion.md, el informe anterior sin seguimiento y los nuevos paquetes sin seguimiento. Se preservaron. La comprobación de exclusión no confirmó ignore para el modelo nuevo consultado; **no se añadieron assets a Git ni se modificó .gitignore**. Debe conservarse la política de no incorporarlos al versionado; la auditoría no autoriza add, commit ni push.

Único documento creado: **RPG/docs/integracion_assets_interiores.md**. Los logs, JSON, galería y capturas son evidencia temporal bajo RPG/logs/; las herramientas de inspección y la importación se realizaron en una copia temporal, sin modificar los scripts del juego. AGENTS.md, estado_proyecto.md y el inventario general se leyeron y **no se actualizaron**, porque esta tarea limita los cambios al informe y a la inspección. La auditoría anterior tampoco se modificó.

**Conclusión:** E01–E11 tienen recursos suficientes para comenzar la construcción con la selección inmediata, conservando trabajo de composición, escala, colisiones y detalles propios. E12 permite comenzar diseño/almacén, pero necesita autoría del mecanismo de molienda. E01 prioriza 27 modelos medv-cafe aprobados artísticamente para integración académica local; la licencia sigue sin encontrarse en la copia descargada y su verificación permanece pendiente. La decisión no aprueba automáticamente los 67 modelos ni acredita permiso de redistribución. No se construyeron interiores, no se descargaron paquetes, no se alteró gameplay ni configuración y no hubo commits ni pushes.
