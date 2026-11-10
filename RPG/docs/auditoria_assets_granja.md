# Auditoría de granja y animales — fase 6E.0

4 de noviembre de 2026. Auditoría local con Godot **4.7.2.stable.official.ed1daf0bf**. No se construye Campos y Granjas ni se activan salidas nuevas. **Pendiente aprobación visual del usuario.**

## Resultado e inventario reproducible

**21 modelos identificados: 14 agrícolas y 7 animales.** Hay 49 archivos de modelo: 14 GLB, 21 FBX, 7 OBJ y 7 Blend. Los formatos alternativos del mismo nombre se cuentan una sola vez; las tres etapas de col son tres variantes geométricas del mismo cultivo, no tres especies. El recuento describe modelos locales, no diversidad agrícola ni una deduplicación topológica del proyecto entero. Los 14 pares GLB/FBX tienen dimensiones equivalentes (diferencia máxima 0,000000477 unidades); OBJ/FBX de animales corresponden a las mismas especies, con diferencias de pose/exportación. No sumar Blend como animales adicionales.

El [catálogo completo JSON](catalogo_assets_granja.json) registra **cada nombre, todas las rutas exactas y formatos, dimensiones XYZ por formato, mínimos, materiales, colores, texturas, huesos y clips con duración/pistas**; incluye estructura de los 14 GLB y comprobación de dependencias. Es la tabla detallada procesable, sin redistribuir los modelos. El inventario general pasa de 503 a **524 recursos canónicos**: 443 glTF, 74 GLB y 7 FBX. No se recalcula la equivalencia geométrica entre todos los paquetes históricos.

Las carpetas reales son `RPG/assets/granja/Farm_Harvest/` (mayúsculas exactas) y `RPG/assets/granja/animales/`. Además de modelos hay licencias, ReadMe, Contents.csv, siete MTL, Preview.gif y paleta PNG. La carpeta ya contenía texturas extraídas, metadatos de importación y traducciones generadas del CSV: no representan modelos ni animaciones adicionales. Se preservan los 96 archivos no `.import` presentes al iniciar, comprobados por SHA-256.

## Farm & Harvest Free, Avramania

Canónico: `RPG/assets/granja/Farm_Harvest/glTF/<nombre>.glb`. Alternativa: `RPG/assets/granja/Farm_Harvest/FBX/<nombre>.fbx`. Ambos formatos importan para las 14 filas. Dimensiones aproximadas **X × Y × Z**, metros según ReadMe, medidas en Godot; no copiar el orden anchura/profundidad/altura de Contents.csv como XYZ.

| Nombre exacto | XYZ aproximado | Uso propuesto / observación |
|---|---|---|
| mdvl_farm_apple_tree_01 | 3,600 × 4,400 × 3,420 | Frutal; silueta facetada distinta del arbolado forestal |
| mdvl_farm_beehive_01 | 0,560 × 0,881 × 0,554 | Colmena decorativa, sin abejas ni apicultura |
| mdvl_farm_cabbage_stage_01 | 0,094 × 0,091 × 0,090 | Plántula, muy pequeña con cámara 15 |
| mdvl_farm_cabbage_stage_02 | 0,157 × 0,125 × 0,156 | Col intermedia |
| mdvl_farm_cabbage_stage_03 | 0,269 × 0,185 × 0,265 | Col madura, preferible para lectura de huerto |
| mdvl_farm_chicken_coop_01 | 1,893 × 1,925 × 1,816 | Gallinero disponible; no incluye gallinas |
| mdvl_farm_feed_trough_01 | 1,220 × 0,510 × 0,725 | Comedero de corral/establo |
| mdvl_farm_fruit_basket_01 | 0,486 × 0,533 × 0,486 | Cesta de fruta; 3646 triángulos declarados, relativamente densa para su tamaño |
| mdvl_farm_furrow_01 | 1,000 × 0,127 × 1,000 | Surco modular; origen en esquina, no centrar así en el mapa futuro |
| mdvl_farm_hay_bale_01 | 0,578 × 0,516 × 0,814 | Paca de heno/almacenamiento |
| mdvl_farm_haystack_02 | 1,338 × 0,981 × 0,994 | Montón de heno; 2768 triángulos declarados |
| mdvl_farm_milking_stool_01 | 0,358 × 0,390 × 0,354 | Taburete de ordeño decorativo |
| mdvl_farm_scarecrow_01 | 1,375 × 1,885 × 0,565 | Espantapájaros junto a cultivos/camino |
| mdvl_farm_well_cover_01 | 1,790 × 2,385 × 1,519 | Pozo con cubierta visible; verificar encaje futuro, no inferir funcionalidad |

Cada GLB tiene un material `mdvl_palette`, una imagen PNG embebida y ninguna animación. Textura externa original: `RPG/assets/granja/Farm_Harvest/Textures/mdvl_palette.png`, 256×256 según ReadMe. Los GLB son autocontenidos: ninguna URI externa pendiente; material PBR no metálico, rugosidad fuente ≈0,78. Godot conserva la textura/material; las imágenes extraídas por importador no son diseños nuevos. No asumir que el mismo nombre de material crea automáticamente un único recurso compartido o una única llamada de dibujo entre archivos. Se conserva el sombreado original y no se recalculan normales ni se fuerzan filtros/overrides.

El ReadMe también describe trigo, maíz, bancales, molinos y otras piezas de una biblioteca mayor: **no están en los 14 modelos presentes**. No se anotan como recursos disponibles. Raíces de cultivos, esquinas del surco y pivotes deben respetarse al colocar posteriormente: el laboratorio centra y apoya ejemplares para inspección, no propone sus coordenadas de montaje definitivas.

Licencia original `RPG/assets/granja/Farm_Harvest/License.txt`: **CC0 1.0**, uso/modificación/comercial sin crédito obligatorio; pide no volver a publicar el paquete tal cual, expresamente como petición y no condición. Conservar el texto original. ReadMe atribuye autoría a Avramania y describe construcción mediante scripts de Blender asistidos por IA; no se cambia esa procedencia.

## Farm Animals Pack, Quaternius

Canónico elegido: `RPG/assets/granja/animales/FBX/<nombre>.fbx`. Alternativas originales conservadas: `RPG/assets/granja/animales/OBJ/<nombre>.obj` con `.mtl` homónimo y `RPG/assets/granja/animales/Blends/<nombre>.blend`. **FBX conserva materiales, esqueleto y animaciones**, mediante el importador integrado existente (`fbx/importer=0`); no se convierte a GLB ni se instala Blender, FBX2glTF o plugins. Los siete OBJ importan como malla estática con materiales, pero pierden la animación y el rig. Importación directa Blend deshabilitada en la configuración existente: no se acredita prueba directa de los siete Blend ni se modifica esa configuración.

Dimensiones de referencia con deformación esquelética medida en CPU, escala fuente 1; las poses animadas cambian las cotas y estos valores no son cajas físicas. La galería parte de Idle t=0 y puede mostrar pequeñas diferencias respecto al reposo del JSON. Frente visible hacia **+Z**, vertical +Y; revisar cuatro vistas. La pose de malla sin aplicar bind/rig da resultados erróneos especialmente para Sheep y Pug: no usar su AABB cruda para apoyo, escala ni colisión.

| Nombre exacto | XYZ de referencia | Materiales importados | Huesos | Clips utilizables |
|---|---|---|---:|---|
| Cow | 2,267 × 5,148 × 9,173 | White, Black, Pink | 39 | Death, Idle, Jump, Run, Walk, WalkSlow |
| Horse | 2,559 × 6,906 × 9,241 | Material.003, Material.006 | 39 | Death, Idle, Jump, Run, Walk, WalkSlow |
| Llama | 1,568 × 5,858 × 4,907 | Brown, White, Grey | 35 | Idle, Jump |
| Pig | 3,304 × 4,575 × 9,770 | Material.003, Material | 35 | Idle, Jump |
| Pug | 1,447 × 2,653 × 3,500 | Beige, Brown | 35 | Idle, Jump |
| Sheep | 2,225 × 4,365 × 5,919 | White, Black | 35 | Idle, Jump |
| Zebra | 2,559 × 7,074 × 9,234 | White, Black | 39 | Death, Idle, Jump, Run, Walk, WalkSlow |

Todos los nombres de clip llevan prefijo exacto `Armature|` (por ejemplo `Armature|Walk`). Hay **26 clips**, 35 o 39 pistas por clip; Idle dura 6,25 s, duraciones restantes en JSON. Todos se importan sin bucle (`loop=0`); un sistema futuro deberá decidir bucles y transiciones, sin modificar los originales ahora. Los cuatro animales con solo Idle/Jump **no tienen marcha/carrera utilizable disponible en estos FBX**. No interpretar las seis acciones de Cow como comunes a todo el paquete.

Los materiales son colores planos, sin texturas externas, con uso de color de vértice habilitado por el importador. Se ven colores y facetas en Forward+/D3D12 sin magenta ni superficies sin material en los controles efectuados. Estilo compatible como candidato low-poly, sujeto a aprobación artística. **Los tamaños originales son excesivos frente al protagonista**. Propuesta futura, no aplicada: Cow ≈0,30, Horse ≈0,30, Pig ≈0,18, Sheep ≈0,25, Llama ≈0,32, Pug ≈0,18 como escalas uniformes iniciales por instancia; afinar silueta y encaje con comederos/puertas, sin escalar al jugador. Zebra se descarta del conjunto agrícola medieval base; Llama y Pug son opcionales según dirección artística. No hay colisiones, IA, root motion regional o interacción implementados por esta auditoría.

Licencia `RPG/assets/granja/animales/License.txt`: **Farm Animals Pack by Quaternius, CC0 1.0 Universal**, crédito no obligatorio; incluye crédito sugerido. Este texto sí permite identificar la licencia de este paquete; no resuelve automáticamente las licencias pendientes de otros Quaternius históricos.

## Preparación de Campos y Granjas

| Necesidad | Selección propuesta | Complementos / trabajo pendiente |
|---|---|---|
| Gallinero | chicken_coop_01 | Faltan gallina, gallo, pollitos, huevos/nidos si se desean; no usar otro animal como sustituto |
| Corrales | feed_trough_01 + heno | Cercas de aldea `Prop_WoodenFence_Single`, `Extension1`, `Extension2`; construir puertas/aperturas, colisiones y disposición |
| Huertos y cultivos | furrow_01 + cabbage_stage_03; 01/02 como variantes decorativas | Zanahoria existente de Props; faltan trigo/maíz y otros cultivos dedicados si el diseño los pide |
| Almacenamiento | hay_bale_01, haystack_02, fruit_basket_01 | Props: Bag, Barrel, Crate_Wooden, FarmCrate_Empty, FarmCrate_Apple/Carrot; no constituyen inventario jugable |
| Caminos | scarecrow_01, apple_tree_01, well_cover_01 | Carro `RPG/assets/aldea/glTF/Prop_Wagon.gltf`; piedras/hierba baja de Nature; mantener pasos libres |
| Animales | Cow, Sheep, Pig, Horse | Ajuste por instancia y áreas adecuadas; marcha solo disponible en Cow/Horse de esta selección |
| Granero y establos | No hay edificio completo nuevo | Componer muros, entramado, puertas, cubierta, postes, boxes y aleros; gallinero no sustituye granero |

Complementos verificados sin integrarlos: aldea `RPG/assets/aldea/glTF/Wall_Plaster_WoodGrid.gltf`, `Roof_Log.gltf`, `Door_1_Flat.gltf` y las cercas anteriores; naturaleza `RPG/assets/naturaleza/glTF/CommonTree_1.gltf`, `Grass_Common_Short.gltf`, `Rock_Medium_1.gltf`, flores/helechos ya inventariados; objetos medievales bajo `RPG/assets/objetos_medievales/glTF/` (rutas exactas de utilería indicadas arriba más `Bucket_Wooden_1.gltf`). Bosque: `RPG/assets/bosque/kaykit_forest/Assets/gltf/Bush_1_A_Color1.gltf` para setos bajos y los árboles/rocas/troncos de la selección forestal en `RPG/docs/seleccion_assets_bosque.md`; escoger bordes rurales abiertos sin copiar toda la vegetación forestal. Sus licencias mantienen las restricciones de cada paquete. No se construye ni coloca nada en mapas existentes.

## Laboratorio y evidencias

Abrir **`RPG/scenes/pruebas_granja.tscn` con F6**. Modelo individual centrado, escala fuente 1, protagonista original congelado como referencia, entorno neutro, cámara compartida sin editar (ortográfica 15 e inclinación habitual). Botones y RePag/AvPag cambian modelo; Q/E conserva órbita. Botón de animación recorre clips y después para. No es región activa ni incorpora controles al proyecto; el suelo de muestra es visual, sin prueba de circulación física.

Galería final: **`RPG/logs/auditoria_assets_granja/2026-11-04T21-02-22_2103/galeria.html`**. Cuatro vistas por modelo, ocho detalles de piezas pequeñas y tres tiempos por cada clip: **170 PNG**. Detalles indican cámara diferente sin reescalar modelo; no confundir con escala de juego. Capturas reales Forward+/D3D12 en RTX 4060 Laptop; revisión técnica de materiales, frentes, perfiles y secuencias. Las 26 secuencias tienen tres imágenes distintas por SHA-256; se revisan además poses visibles, sin presentar el hash como certificación exhaustiva de todas las deformaciones. El usuario conserva la aprobación visual final.

Pruebas bajo `RPG/logs/auditoria_assets_granja/`:

- `03_medicion.log`: carga inicial de 42 formatos, 0 fallos; cotas crudas iniciales sustituidas por medición esquelética posterior.
- `06_medicion_cpu.log`: 42 formatos, 0 fallos, pose deformada sin depender del render headless.
- `13_galeria_final.log`: 42 formatos, 0 fallos y galería final. `mediciones.json` conserva datos de esta ejecución.
- Importación **sin caché previa** en proyecto aislado `importacion_limpia_02/`, sin `.import` copiados ni acceso a la caché principal: `logs/11_importacion_limpia.log`, `logs/12_validacion_limpia.log`, 42 formatos/0 fallos, salida 0. Fuente Blend conservada pero no importada; compatibilidad gráfica certificada por separado en el proyecto real Forward+.
- `10_carga_mundo.log`: escena principal abre durante 120 fotogramas headless, salida 0. No equivale a repetir recorridos ni regresión regional completa, innecesaria al no alterar mapas/sistemas.
- `14_editor_final.log` y `15_escena_laboratorio.log`: editor/importación y apertura F6 equivalente del laboratorio durante 120 fotogramas headless, salida 0; UID de ambos GDScript generados y conservados. Editor mantiene los avisos de entorno descritos abajo.
- `integridad_fuentes_final.json`: 96 archivos fuente/preexistentes preservados. `integridad_proyecto_final.json`: archivos preexistentes de escenas/scripts/tests, configuración y exclusiones sin cambios durante esta tarea.

Avisos reales: el importador OBJ ignora la iluminación ambiente de los MTL al usar PBR; no falta material, pero no se acredita equivalencia exacta del sombreado MTL legado. Error del entorno al leer certificados; editor no puede guardar ajustes globales fuera del proyecto. Importación inicial aislada `importacion_limpia_01` no pudo abrir su primer log al faltar el directorio; se creó una segunda copia limpia con registros preparados, sin presentar ese primer intento como evidencia final. Borrador inicial tuvo un error de inferencia GDScript y luego una medición mediante bake dependiente del servidor gráfico falló en headless; se corrigieron en herramientas de auditoría, no en assets. Sus registros se conservan. No se instalan dependencias ni se alteran preferencias globales.

Reproducción desde la raíz del repositorio (usar el ejecutable disponible de Godot 4.7.2 y **nombres de log nuevos**):

```text
godot --headless --path RPG --log-file logs/auditoria_assets_granja/nueva_medicion.log --script res://tests/auditar_assets_granja.gd
godot --path RPG --log-file logs/auditoria_assets_granja/nueva_galeria.log --script res://tests/auditar_assets_granja.gd
node RPG/tests/inventariar_assets_granja.mjs
```

El script Node utiliza solo módulos integrados del Node ya disponible, genera el catálogo documental desde mediciones y contrasta la instantánea local inicial si existe. No es dependencia de ejecución del juego. Logs, copias aisladas y capturas están excluidos de Git. Assets continúan excluidos; no hay commits/pushes. **Auditoría terminada: esperar aprobación visual antes de construir Campos y Granjas.**
