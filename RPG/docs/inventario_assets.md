# Inventario y auditoría de assets — RPG

Fecha: **30 de octubre de 2026**. Auditoría del contenido local, no del catálogo completo comercial de los paquetes. Las categorías describen usos propuestos a partir de nombres y estructura; no sustituyen una revisión visual artística.

## 1. Resumen ejecutivo

**338 modelos glTF 2.0, 338 buffers BIN y 89 PNG.** Los 338 modelos se importaron y se instanciaron en Godot **4.7.2.stable.official.ed1daf0bf**, con 0 fallos, 339 nodos de malla, 542 superficies y 0 superficies sin material. Las 89 imágenes cargaron con dimensiones válidas. No se detectaron dependencias glTF ausentes ni referencias incorrectas en las comprobaciones realizadas.

| Paquete / carpeta relativa al repositorio | glTF | BIN | PNG | `.import` | Otros |
|---|---:|---:|---:|---:|---|
| `RPG/assets/aldea` | 176 | 176 | 54 | 230 | 0 INI |
| `RPG/assets/naturaleza/glTF` | 68 | 68 | 20 | 88 | 1 INI |
| `RPG/assets/objetos_medievales/glTF` | 94 | 94 | 13 | 107 | 0 INI |
| `RPG/assets/personajes` | 0 | 0 | 2 | 2 | 0 INI |

Los paquetes no incluyen edificios completos identificados en este contenido: viviendas, taberna, herrería y molino deberán componerse. Los nombres con números discontinuos no prueban archivos perdidos: solo se consideran faltantes las dependencias realmente referenciadas.

## 2. Método, integridad y límites

- Recorrido recursivo de las cuatro carpetas indicadas; lectura de los 338 JSON glTF y de sus URI, sin presuponer que BIN y glTF deban tener el mismo nombre.
- Comprobación de existencia y capitalización de rutas, tamaño declarado de buffers, límites de bufferViews/accessors, índices de imágenes/texturas y referencias de materiales. PNG referenciados con cabecera reconocible; carga de todos los PNG confirmada posteriormente en Godot.
- Hash SHA-256 de todos los recursos fuente para detectar duplicados exactos; no es una comparación de semejanza visual ni topológica.
- Revisión de `source_file` de los `.import`: sin discrepancias detectadas ni scripts de importación personalizados activos.
- Todos los glTF declaran versión 2.0; ninguno declara `extensionsUsed` ni `extensionsRequired`. No se detectaron animaciones glTF: son recursos estáticos; no implica incompatibilidad con el protagonista animado.
- No es una certificación exhaustiva de conformidad Khronos: la prueba funcional es la importación, carga e instanciación local descrita abajo.

### Validación de importación aislada

Se copiaron únicamente assets y sus ajustes `.import` a un proyecto temporal nuevo, sin escenas ni scripts del juego y sin reutilizar su caché `.godot`. Se usó configuración mínima Forward Plus/D3D12, igual que la selección del proyecto original, pero ejecución **headless**. No se abrió ni ejecutó ninguna escena existente.

Procedimiento histórico: se ejecutó Godot con `--headless --import` sobre una copia temporal aislada y después un validador temporal con `--script`. El ejecutable se obtuvo de la instalación local, no del repositorio. Se omiten las ubicaciones personales y temporales porque no son portables. El validador no está incluido en el proyecto; estos pasos describen la prueba realizada, no comandos autocontenidos para reproducirla.

El primer paso terminó y no registró errores ni advertencias detectados en los logs. El segundo terminó con código **0**: `AUDIT_RESULT models=338 images=89 failures=0`. Cargó cada glTF como PackedScene, lo instanció, recorrió mallas/materiales/colisiones y liberó la instancia; cargó también todas las texturas. El validador temporal necesitó corregir una anotación de tipo antes de la ejecución exitosa; no era un fallo de assets.

Las evidencias de aquella auditoría se generaron fuera del repositorio en un directorio temporal del sistema. No se incluyen enlaces ni rutas a ellas: no son recursos del proyecto y su disponibilidad no está garantizada. Los resultados resumidos aquí se conservan como registro histórico.

**Límites:** headless no valida el aspecto en GPU/D3D12, sombras, transparencia, orientación de normales, escala respecto al protagonista ni rendimiento real. Se recomienda una escena de pruebas nueva en la siguiente etapa, sin modificar las actuales. Las mallas suman 388.430 triángulos base al instanciar una unidad de cada recurso: no es un presupuesto de escena ni incluye todos los LOD. No se midió rendimiento.

### Duplicados exactos (no eliminados)

Se encontraron **20 grupos** SHA-256 con contenido idéntico (21 copias adicionales). No hay glTF completos idénticos ni nombres de modelo repetidos entre paquetes. Los BIN compartidos corresponden a variantes con materiales distintos; no deben tratarse como modelos sobrantes.

1. `RPG/assets/aldea/glTF/Floor_Brick.bin`; `RPG/assets/aldea/glTF/Floor_RedBrick.bin`; `RPG/assets/aldea/glTF/Floor_UnevenBrick.bin`

2. `RPG/assets/aldea/glTF/Overhang_RoofIncline_Plaster.bin`; `RPG/assets/aldea/glTF/Overhang_RoofIncline_UnevenBricks.bin`

3. `RPG/assets/aldea/glTF/Overhang_Roof_Plaster.bin`; `RPG/assets/aldea/glTF/Overhang_Roof_UnevenBricks.bin`

4. `RPG/assets/aldea/glTF/T_Brick_BaseColor.png`; `RPG/assets/aldea/Textures/T_Brick_BaseColor.png`

5. `RPG/assets/aldea/glTF/T_Brick_Normal.png`; `RPG/assets/aldea/Textures/T_Brick_Normal.png`

6. `RPG/assets/aldea/glTF/T_Plaster_BaseColor.png`; `RPG/assets/aldea/Textures/T_Plaster_BaseColor.png`

7. `RPG/assets/aldea/glTF/T_Plaster_Normal.png`; `RPG/assets/aldea/Textures/T_Plaster_Normal.png`

8. `RPG/assets/aldea/glTF/T_Plaster_ORM.png`; `RPG/assets/aldea/Textures/T_Plaster_ORM.png`

9. `RPG/assets/aldea/glTF/T_RedBrick_BaseColor.png`; `RPG/assets/aldea/Textures/T_RedBrick_BaseColor.png`

10. `RPG/assets/aldea/glTF/T_RockTrim_BaseColor.png`; `RPG/assets/aldea/Textures/T_RockTrim_BaseColor.png`

11. `RPG/assets/aldea/glTF/T_RockTrim_Normal.png`; `RPG/assets/aldea/Textures/T_RockTrim_Normal.png`

12. `RPG/assets/aldea/glTF/T_RockTrim_ORM.png`; `RPG/assets/aldea/Textures/T_RockTrim_ORM.png`

13. `RPG/assets/aldea/glTF/T_RoundTiles_BaseColor.png`; `RPG/assets/aldea/Textures/T_RoundTiles_BaseColor.png`

14. `RPG/assets/aldea/glTF/T_RoundTiles_Normal.png`; `RPG/assets/aldea/Textures/T_RoundTiles_Normal.png`

15. `RPG/assets/aldea/glTF/T_UnevenBrick_BaseColor.png`; `RPG/assets/aldea/Textures/T_UnevenBrick_BaseColor.png`

16. `RPG/assets/aldea/glTF/T_UnevenBrick_Normal.png`; `RPG/assets/aldea/Textures/T_UnevenBrick_Normal.png`

17. `RPG/assets/aldea/glTF/T_VineLeaf_png.png`; `RPG/assets/aldea/Textures/T_VineLeaf.png`

18. `RPG/assets/aldea/glTF/T_WoodTrim_BaseColor.png`; `RPG/assets/aldea/Textures/T_WoodTrim_BaseColor.png`

19. `RPG/assets/aldea/glTF/T_WoodTrim_Normal.png`; `RPG/assets/aldea/Textures/T_WoodTrim_Normal.png`

20. `RPG/assets/naturaleza/glTF/Bark_DeadTree_Normal.png`; `RPG/assets/naturaleza/glTF/Bark_TwistedTree_Normal.png`

Las copias de texturas en `Textures` y `glTF` son redundancia de distribución, no referencias rotas. Las imágenes con igual nombre en `Textures/Normals Godot-Unity` no coinciden byte a byte con sus homólogas de glTF; son variantes, no duplicados exactos. No se intercambiaron: comprobar visualmente su orientación antes de decidir un cambio. Que una carpeta mencione Godot no demuestra un error en los materiales glTF importados.

### Recursos no referenciados por los glTF examinados

Ningún BIN quedó sin referencia. Los siguientes PNG no aparecen en URI de estos glTF; esto **no significa** que estén sin uso en el proyecto ni que deban eliminarse. Incluye sprites usados por el jugador y texturas auxiliares/variantes del paquete:
- `RPG/assets/aldea/Textures/T_BottomWear.png`
- `RPG/assets/aldea/Textures/T_Brick_BaseColor.png`
- `RPG/assets/aldea/Textures/T_Brick_Normal.png`
- `RPG/assets/aldea/Textures/T_Brick_Roughness.png`
- `RPG/assets/aldea/Textures/T_BrushedNoise.png`
- `RPG/assets/aldea/Textures/T_Noise_Terrain.png`
- `RPG/assets/aldea/Textures/T_Plaster_BaseColor.png`
- `RPG/assets/aldea/Textures/T_Plaster_Normal.png`
- `RPG/assets/aldea/Textures/T_Plaster_ORM.png`
- `RPG/assets/aldea/Textures/T_RedBrick_BaseColor.png`
- `RPG/assets/aldea/Textures/T_RockTrim_BaseColor.png`
- `RPG/assets/aldea/Textures/T_RockTrim_Normal.png`
- `RPG/assets/aldea/Textures/T_RockTrim_ORM.png`
- `RPG/assets/aldea/Textures/T_RoundTiles_BaseColor.png`
- `RPG/assets/aldea/Textures/T_RoundTiles_Normal.png`
- `RPG/assets/aldea/Textures/T_RoundTiles_Roughness.png`
- `RPG/assets/aldea/Textures/T_TopWear.png`
- `RPG/assets/aldea/Textures/T_UnevenBrick_BaseColor.png`
- `RPG/assets/aldea/Textures/T_UnevenBrick_Normal.png`
- `RPG/assets/aldea/Textures/T_UnevenBrick_Roughness.png`
- `RPG/assets/aldea/Textures/T_VineLeaf.png`
- `RPG/assets/aldea/Textures/T_WindowGradient.png`
- `RPG/assets/aldea/Textures/T_WoodTrim_BaseColor.png`
- `RPG/assets/aldea/Textures/T_WoodTrim_Normal.png`
- `RPG/assets/aldea/Textures/T_WoodTrim_ORM.png`
- `RPG/assets/aldea/Textures/T_WoodTrim_Roughness.png`
- `RPG/assets/aldea/Textures/Normals Godot-Unity/T_Brick_Normal.png`
- `RPG/assets/aldea/Textures/Normals Godot-Unity/T_Plaster_Normal.png`
- `RPG/assets/aldea/Textures/Normals Godot-Unity/T_RockTrim_Normal.png`
- `RPG/assets/aldea/Textures/Normals Godot-Unity/T_RoundTiles_Normal.png`
- `RPG/assets/aldea/Textures/Normals Godot-Unity/T_UnevenBrick_Normal.png`
- `RPG/assets/aldea/Textures/Normals Godot-Unity/T_WoodTrim_Normal.png`
- `RPG/assets/naturaleza/glTF/Leaf_Pine.png`
- `RPG/assets/naturaleza/glTF/Leaves_GiantPine_C.png`
- `RPG/assets/naturaleza/glTF/Leaves_NormalTree.png`
- `RPG/assets/naturaleza/glTF/Leaves_TwistedTree.png`
- `RPG/assets/naturaleza/glTF/Rocks_Desert_Diffuse.png`
- `RPG/assets/personajes/protagonista/Character_Idle.png`
- `RPG/assets/personajes/protagonista/Character_Walk.png`

El archivo INI de naturaleza no es un modelo ni una dependencia declarada por glTF. No se cambiaron sus contenidos.

## 3. Inventario por categorías

Cada modelo aparece una sola vez según su uso principal. La ruta relativa al repositorio identifica el recurso instanciable `.gltf`; su BIN y sus imágenes quedaron verificados. La categoría Rocas incluye adoquines, piedras de camino y ladrillos sueltos; Otros incluye césped, tréboles, hongos y equipo. Las piezas con cubierta ya hecha siguen siendo arquitectura modular, no casas completas.

| Categoría | Modelos |
|---|---:|
| Edificios | 0 |
| Arquitectura modular | 164 |
| Árboles | 20 |
| Arbustos | 7 |
| Flores | 9 |
| Rocas | 28 |
| Mobiliario | 13 |
| Herramientas | 8 |
| Mercado | 18 |
| Herrería | 7 |
| Decoración | 51 |
| Otros | 13 |

### Edificios (0)

No se identificaron modelos de edificios completos. El kit de arquitectura permite construirlos con los módulos del apartado siguiente.

### Arquitectura modular (164)

| Modelo | Paquete | Ruta relativa al repositorio |
|---|---|---|
| `Balcony_Cross_Corner` | aldea | `RPG/assets/aldea/glTF/Balcony_Cross_Corner.gltf` |
| `Balcony_Cross_Straight` | aldea | `RPG/assets/aldea/glTF/Balcony_Cross_Straight.gltf` |
| `Balcony_Simple_Corner` | aldea | `RPG/assets/aldea/glTF/Balcony_Simple_Corner.gltf` |
| `Balcony_Simple_Straight` | aldea | `RPG/assets/aldea/glTF/Balcony_Simple_Straight.gltf` |
| `Corner_ExteriorWide_Brick` | aldea | `RPG/assets/aldea/glTF/Corner_ExteriorWide_Brick.gltf` |
| `Corner_ExteriorWide_Wood` | aldea | `RPG/assets/aldea/glTF/Corner_ExteriorWide_Wood.gltf` |
| `Corner_Exterior_Brick` | aldea | `RPG/assets/aldea/glTF/Corner_Exterior_Brick.gltf` |
| `Corner_Exterior_TopDown` | aldea | `RPG/assets/aldea/glTF/Corner_Exterior_TopDown.gltf` |
| `Corner_Exterior_TopOnly` | aldea | `RPG/assets/aldea/glTF/Corner_Exterior_TopOnly.gltf` |
| `Corner_Exterior_Wood` | aldea | `RPG/assets/aldea/glTF/Corner_Exterior_Wood.gltf` |
| `Corner_Interior_Big` | aldea | `RPG/assets/aldea/glTF/Corner_Interior_Big.gltf` |
| `Corner_Interior_Small` | aldea | `RPG/assets/aldea/glTF/Corner_Interior_Small.gltf` |
| `DoorFrame_Flat_Brick` | aldea | `RPG/assets/aldea/glTF/DoorFrame_Flat_Brick.gltf` |
| `DoorFrame_Flat_WoodDark` | aldea | `RPG/assets/aldea/glTF/DoorFrame_Flat_WoodDark.gltf` |
| `DoorFrame_Round_Brick` | aldea | `RPG/assets/aldea/glTF/DoorFrame_Round_Brick.gltf` |
| `DoorFrame_Round_WoodDark` | aldea | `RPG/assets/aldea/glTF/DoorFrame_Round_WoodDark.gltf` |
| `Door_1_Flat` | aldea | `RPG/assets/aldea/glTF/Door_1_Flat.gltf` |
| `Door_1_Round` | aldea | `RPG/assets/aldea/glTF/Door_1_Round.gltf` |
| `Door_2_Flat` | aldea | `RPG/assets/aldea/glTF/Door_2_Flat.gltf` |
| `Door_2_Round` | aldea | `RPG/assets/aldea/glTF/Door_2_Round.gltf` |
| `Door_4_Flat` | aldea | `RPG/assets/aldea/glTF/Door_4_Flat.gltf` |
| `Door_4_Round` | aldea | `RPG/assets/aldea/glTF/Door_4_Round.gltf` |
| `Door_8_Flat` | aldea | `RPG/assets/aldea/glTF/Door_8_Flat.gltf` |
| `Door_8_Round` | aldea | `RPG/assets/aldea/glTF/Door_8_Round.gltf` |
| `Floor_Brick` | aldea | `RPG/assets/aldea/glTF/Floor_Brick.gltf` |
| `Floor_RedBrick` | aldea | `RPG/assets/aldea/glTF/Floor_RedBrick.gltf` |
| `Floor_UnevenBrick` | aldea | `RPG/assets/aldea/glTF/Floor_UnevenBrick.gltf` |
| `Floor_WoodDark` | aldea | `RPG/assets/aldea/glTF/Floor_WoodDark.gltf` |
| `Floor_WoodDark_Half1` | aldea | `RPG/assets/aldea/glTF/Floor_WoodDark_Half1.gltf` |
| `Floor_WoodDark_Half2` | aldea | `RPG/assets/aldea/glTF/Floor_WoodDark_Half2.gltf` |
| `Floor_WoodDark_Half3` | aldea | `RPG/assets/aldea/glTF/Floor_WoodDark_Half3.gltf` |
| `Floor_WoodDark_OverhangCorner` | aldea | `RPG/assets/aldea/glTF/Floor_WoodDark_OverhangCorner.gltf` |
| `Floor_WoodDark_OverhangCorner2` | aldea | `RPG/assets/aldea/glTF/Floor_WoodDark_OverhangCorner2.gltf` |
| `Floor_WoodLight` | aldea | `RPG/assets/aldea/glTF/Floor_WoodLight.gltf` |
| `Floor_WoodLight_OverhangCorner` | aldea | `RPG/assets/aldea/glTF/Floor_WoodLight_OverhangCorner.gltf` |
| `Floor_WoodLight_OverhangCorner2` | aldea | `RPG/assets/aldea/glTF/Floor_WoodLight_OverhangCorner2.gltf` |
| `HoleCover_90Angle` | aldea | `RPG/assets/aldea/glTF/HoleCover_90Angle.gltf` |
| `HoleCover_90Half` | aldea | `RPG/assets/aldea/glTF/HoleCover_90Half.gltf` |
| `HoleCover_90Stairs` | aldea | `RPG/assets/aldea/glTF/HoleCover_90Stairs.gltf` |
| `HoleCover_Straight` | aldea | `RPG/assets/aldea/glTF/HoleCover_Straight.gltf` |
| `HoleCover_StraightHalf` | aldea | `RPG/assets/aldea/glTF/HoleCover_StraightHalf.gltf` |
| `Overhang_Plaster_Corner` | aldea | `RPG/assets/aldea/glTF/Overhang_Plaster_Corner.gltf` |
| `Overhang_Plaster_Corner_Front` | aldea | `RPG/assets/aldea/glTF/Overhang_Plaster_Corner_Front.gltf` |
| `Overhang_Plaster_Long` | aldea | `RPG/assets/aldea/glTF/Overhang_Plaster_Long.gltf` |
| `Overhang_Plaster_Short` | aldea | `RPG/assets/aldea/glTF/Overhang_Plaster_Short.gltf` |
| `Overhang_RoofIncline_Plaster` | aldea | `RPG/assets/aldea/glTF/Overhang_RoofIncline_Plaster.gltf` |
| `Overhang_RoofIncline_UnevenBricks` | aldea | `RPG/assets/aldea/glTF/Overhang_RoofIncline_UnevenBricks.gltf` |
| `Overhang_Roof_Plaster` | aldea | `RPG/assets/aldea/glTF/Overhang_Roof_Plaster.gltf` |
| `Overhang_Roof_UnevenBricks` | aldea | `RPG/assets/aldea/glTF/Overhang_Roof_UnevenBricks.gltf` |
| `Overhang_Side_Plaster_Long_L` | aldea | `RPG/assets/aldea/glTF/Overhang_Side_Plaster_Long_L.gltf` |
| `Overhang_Side_Plaster_Long_R` | aldea | `RPG/assets/aldea/glTF/Overhang_Side_Plaster_Long_R.gltf` |
| `Overhang_Side_Plaster_Short_L` | aldea | `RPG/assets/aldea/glTF/Overhang_Side_Plaster_Short_L.gltf` |
| `Overhang_Side_Plaster_Short_R` | aldea | `RPG/assets/aldea/glTF/Overhang_Side_Plaster_Short_R.gltf` |
| `Overhang_Side_UnevenBrick_Long_L` | aldea | `RPG/assets/aldea/glTF/Overhang_Side_UnevenBrick_Long_L.gltf` |
| `Overhang_Side_UnevenBrick_Long_R` | aldea | `RPG/assets/aldea/glTF/Overhang_Side_UnevenBrick_Long_R.gltf` |
| `Overhang_Side_UnevenBrick_Short_L` | aldea | `RPG/assets/aldea/glTF/Overhang_Side_UnevenBrick_Short_L.gltf` |
| `Overhang_Side_UnevenBrick_Short_R` | aldea | `RPG/assets/aldea/glTF/Overhang_Side_UnevenBrick_Short_R.gltf` |
| `Overhang_UnevenBrick_Corner` | aldea | `RPG/assets/aldea/glTF/Overhang_UnevenBrick_Corner.gltf` |
| `Overhang_UnevenBrick_Corner_Front` | aldea | `RPG/assets/aldea/glTF/Overhang_UnevenBrick_Corner_Front.gltf` |
| `Overhang_UnevenBrick_Long` | aldea | `RPG/assets/aldea/glTF/Overhang_UnevenBrick_Long.gltf` |
| `Overhang_UnevenBrick_Short` | aldea | `RPG/assets/aldea/glTF/Overhang_UnevenBrick_Short.gltf` |
| `Prop_Chimney` | aldea | `RPG/assets/aldea/glTF/Prop_Chimney.gltf` |
| `Prop_Chimney2` | aldea | `RPG/assets/aldea/glTF/Prop_Chimney2.gltf` |
| `Prop_ExteriorBorder_Corner` | aldea | `RPG/assets/aldea/glTF/Prop_ExteriorBorder_Corner.gltf` |
| `Prop_ExteriorBorder_Straight1` | aldea | `RPG/assets/aldea/glTF/Prop_ExteriorBorder_Straight1.gltf` |
| `Prop_ExteriorBorder_Straight2` | aldea | `RPG/assets/aldea/glTF/Prop_ExteriorBorder_Straight2.gltf` |
| `Prop_MetalFence_Ornament` | aldea | `RPG/assets/aldea/glTF/Prop_MetalFence_Ornament.gltf` |
| `Prop_MetalFence_Simple` | aldea | `RPG/assets/aldea/glTF/Prop_MetalFence_Simple.gltf` |
| `Prop_Support` | aldea | `RPG/assets/aldea/glTF/Prop_Support.gltf` |
| `Prop_WoodenFence_Extension1` | aldea | `RPG/assets/aldea/glTF/Prop_WoodenFence_Extension1.gltf` |
| `Prop_WoodenFence_Extension2` | aldea | `RPG/assets/aldea/glTF/Prop_WoodenFence_Extension2.gltf` |
| `Prop_WoodenFence_Single` | aldea | `RPG/assets/aldea/glTF/Prop_WoodenFence_Single.gltf` |
| `Roof_2x4_RoundTile` | aldea | `RPG/assets/aldea/glTF/Roof_2x4_RoundTile.gltf` |
| `Roof_Dormer_RoundTile` | aldea | `RPG/assets/aldea/glTF/Roof_Dormer_RoundTile.gltf` |
| `Roof_FrontSupports` | aldea | `RPG/assets/aldea/glTF/Roof_FrontSupports.gltf` |
| `Roof_Front_Brick2` | aldea | `RPG/assets/aldea/glTF/Roof_Front_Brick2.gltf` |
| `Roof_Front_Brick4` | aldea | `RPG/assets/aldea/glTF/Roof_Front_Brick4.gltf` |
| `Roof_Front_Brick4_Half_L` | aldea | `RPG/assets/aldea/glTF/Roof_Front_Brick4_Half_L.gltf` |
| `Roof_Front_Brick4_Half_R` | aldea | `RPG/assets/aldea/glTF/Roof_Front_Brick4_Half_R.gltf` |
| `Roof_Front_Brick6` | aldea | `RPG/assets/aldea/glTF/Roof_Front_Brick6.gltf` |
| `Roof_Front_Brick6_Half_L` | aldea | `RPG/assets/aldea/glTF/Roof_Front_Brick6_Half_L.gltf` |
| `Roof_Front_Brick6_Half_R` | aldea | `RPG/assets/aldea/glTF/Roof_Front_Brick6_Half_R.gltf` |
| `Roof_Front_Brick8` | aldea | `RPG/assets/aldea/glTF/Roof_Front_Brick8.gltf` |
| `Roof_Front_Brick8_Half_L` | aldea | `RPG/assets/aldea/glTF/Roof_Front_Brick8_Half_L.gltf` |
| `Roof_Front_Brick8_Half_R` | aldea | `RPG/assets/aldea/glTF/Roof_Front_Brick8_Half_R.gltf` |
| `Roof_Log` | aldea | `RPG/assets/aldea/glTF/Roof_Log.gltf` |
| `Roof_Modular_RoundTiles` | aldea | `RPG/assets/aldea/glTF/Roof_Modular_RoundTiles.gltf` |
| `Roof_RoundTile_2x1` | aldea | `RPG/assets/aldea/glTF/Roof_RoundTile_2x1.gltf` |
| `Roof_RoundTile_2x1_Long` | aldea | `RPG/assets/aldea/glTF/Roof_RoundTile_2x1_Long.gltf` |
| `Roof_RoundTiles_4x4` | aldea | `RPG/assets/aldea/glTF/Roof_RoundTiles_4x4.gltf` |
| `Roof_RoundTiles_4x6` | aldea | `RPG/assets/aldea/glTF/Roof_RoundTiles_4x6.gltf` |
| `Roof_RoundTiles_4x8` | aldea | `RPG/assets/aldea/glTF/Roof_RoundTiles_4x8.gltf` |
| `Roof_RoundTiles_6x10` | aldea | `RPG/assets/aldea/glTF/Roof_RoundTiles_6x10.gltf` |
| `Roof_RoundTiles_6x12` | aldea | `RPG/assets/aldea/glTF/Roof_RoundTiles_6x12.gltf` |
| `Roof_RoundTiles_6x14` | aldea | `RPG/assets/aldea/glTF/Roof_RoundTiles_6x14.gltf` |
| `Roof_RoundTiles_6x4` | aldea | `RPG/assets/aldea/glTF/Roof_RoundTiles_6x4.gltf` |
| `Roof_RoundTiles_6x6` | aldea | `RPG/assets/aldea/glTF/Roof_RoundTiles_6x6.gltf` |
| `Roof_RoundTiles_6x8` | aldea | `RPG/assets/aldea/glTF/Roof_RoundTiles_6x8.gltf` |
| `Roof_RoundTiles_8x10` | aldea | `RPG/assets/aldea/glTF/Roof_RoundTiles_8x10.gltf` |
| `Roof_RoundTiles_8x12` | aldea | `RPG/assets/aldea/glTF/Roof_RoundTiles_8x12.gltf` |
| `Roof_RoundTiles_8x14` | aldea | `RPG/assets/aldea/glTF/Roof_RoundTiles_8x14.gltf` |
| `Roof_RoundTiles_8x8` | aldea | `RPG/assets/aldea/glTF/Roof_RoundTiles_8x8.gltf` |
| `Roof_Support2` | aldea | `RPG/assets/aldea/glTF/Roof_Support2.gltf` |
| `Roof_Tower_RoundTiles` | aldea | `RPG/assets/aldea/glTF/Roof_Tower_RoundTiles.gltf` |
| `Roof_Wooden_2x1` | aldea | `RPG/assets/aldea/glTF/Roof_Wooden_2x1.gltf` |
| `Roof_Wooden_2x1_Center` | aldea | `RPG/assets/aldea/glTF/Roof_Wooden_2x1_Center.gltf` |
| `Roof_Wooden_2x1_Center_Mirror` | aldea | `RPG/assets/aldea/glTF/Roof_Wooden_2x1_Center_Mirror.gltf` |
| `Roof_Wooden_2x1_Corner` | aldea | `RPG/assets/aldea/glTF/Roof_Wooden_2x1_Corner.gltf` |
| `Roof_Wooden_2x1_L` | aldea | `RPG/assets/aldea/glTF/Roof_Wooden_2x1_L.gltf` |
| `Roof_Wooden_2x1_Middle` | aldea | `RPG/assets/aldea/glTF/Roof_Wooden_2x1_Middle.gltf` |
| `Roof_Wooden_2x1_R` | aldea | `RPG/assets/aldea/glTF/Roof_Wooden_2x1_R.gltf` |
| `Stair_Interior_Rails` | aldea | `RPG/assets/aldea/glTF/Stair_Interior_Rails.gltf` |
| `Stair_Interior_Simple` | aldea | `RPG/assets/aldea/glTF/Stair_Interior_Simple.gltf` |
| `Stair_Interior_Solid` | aldea | `RPG/assets/aldea/glTF/Stair_Interior_Solid.gltf` |
| `Stair_Interior_SolidExtended` | aldea | `RPG/assets/aldea/glTF/Stair_Interior_SolidExtended.gltf` |
| `Stairs_Exterior_NoFirstStep` | aldea | `RPG/assets/aldea/glTF/Stairs_Exterior_NoFirstStep.gltf` |
| `Stairs_Exterior_Platform` | aldea | `RPG/assets/aldea/glTF/Stairs_Exterior_Platform.gltf` |
| `Stairs_Exterior_Platform45` | aldea | `RPG/assets/aldea/glTF/Stairs_Exterior_Platform45.gltf` |
| `Stairs_Exterior_Platform45Clean` | aldea | `RPG/assets/aldea/glTF/Stairs_Exterior_Platform45Clean.gltf` |
| `Stairs_Exterior_PlatformU` | aldea | `RPG/assets/aldea/glTF/Stairs_Exterior_PlatformU.gltf` |
| `Stairs_Exterior_SidePlatform` | aldea | `RPG/assets/aldea/glTF/Stairs_Exterior_SidePlatform.gltf` |
| `Stairs_Exterior_Sides` | aldea | `RPG/assets/aldea/glTF/Stairs_Exterior_Sides.gltf` |
| `Stairs_Exterior_Sides45` | aldea | `RPG/assets/aldea/glTF/Stairs_Exterior_Sides45.gltf` |
| `Stairs_Exterior_SidesU` | aldea | `RPG/assets/aldea/glTF/Stairs_Exterior_SidesU.gltf` |
| `Stairs_Exterior_SingleSide` | aldea | `RPG/assets/aldea/glTF/Stairs_Exterior_SingleSide.gltf` |
| `Stairs_Exterior_SingleSideThick` | aldea | `RPG/assets/aldea/glTF/Stairs_Exterior_SingleSideThick.gltf` |
| `Stairs_Exterior_Straight` | aldea | `RPG/assets/aldea/glTF/Stairs_Exterior_Straight.gltf` |
| `Stairs_Exterior_Straight_Center` | aldea | `RPG/assets/aldea/glTF/Stairs_Exterior_Straight_Center.gltf` |
| `Stairs_Exterior_Straight_L` | aldea | `RPG/assets/aldea/glTF/Stairs_Exterior_Straight_L.gltf` |
| `Stairs_Exterior_Straight_R` | aldea | `RPG/assets/aldea/glTF/Stairs_Exterior_Straight_R.gltf` |
| `Wall_Arch` | aldea | `RPG/assets/aldea/glTF/Wall_Arch.gltf` |
| `Wall_BottomCover` | aldea | `RPG/assets/aldea/glTF/Wall_BottomCover.gltf` |
| `Wall_Plaster_Door_Flat` | aldea | `RPG/assets/aldea/glTF/Wall_Plaster_Door_Flat.gltf` |
| `Wall_Plaster_Door_Round` | aldea | `RPG/assets/aldea/glTF/Wall_Plaster_Door_Round.gltf` |
| `Wall_Plaster_Door_RoundInset` | aldea | `RPG/assets/aldea/glTF/Wall_Plaster_Door_RoundInset.gltf` |
| `Wall_Plaster_Straight` | aldea | `RPG/assets/aldea/glTF/Wall_Plaster_Straight.gltf` |
| `Wall_Plaster_Straight_Base` | aldea | `RPG/assets/aldea/glTF/Wall_Plaster_Straight_Base.gltf` |
| `Wall_Plaster_Straight_L` | aldea | `RPG/assets/aldea/glTF/Wall_Plaster_Straight_L.gltf` |
| `Wall_Plaster_Straight_R` | aldea | `RPG/assets/aldea/glTF/Wall_Plaster_Straight_R.gltf` |
| `Wall_Plaster_Window_Thin_Round` | aldea | `RPG/assets/aldea/glTF/Wall_Plaster_Window_Thin_Round.gltf` |
| `Wall_Plaster_Window_Wide_Flat` | aldea | `RPG/assets/aldea/glTF/Wall_Plaster_Window_Wide_Flat.gltf` |
| `Wall_Plaster_Window_Wide_Flat2` | aldea | `RPG/assets/aldea/glTF/Wall_Plaster_Window_Wide_Flat2.gltf` |
| `Wall_Plaster_Window_Wide_Round` | aldea | `RPG/assets/aldea/glTF/Wall_Plaster_Window_Wide_Round.gltf` |
| `Wall_Plaster_WoodGrid` | aldea | `RPG/assets/aldea/glTF/Wall_Plaster_WoodGrid.gltf` |
| `Wall_UnevenBrick_Door_Flat` | aldea | `RPG/assets/aldea/glTF/Wall_UnevenBrick_Door_Flat.gltf` |
| `Wall_UnevenBrick_Door_Round` | aldea | `RPG/assets/aldea/glTF/Wall_UnevenBrick_Door_Round.gltf` |
| `Wall_UnevenBrick_Straight` | aldea | `RPG/assets/aldea/glTF/Wall_UnevenBrick_Straight.gltf` |
| `Wall_UnevenBrick_Window_Thin_Round` | aldea | `RPG/assets/aldea/glTF/Wall_UnevenBrick_Window_Thin_Round.gltf` |
| `Wall_UnevenBrick_Window_Wide_Flat` | aldea | `RPG/assets/aldea/glTF/Wall_UnevenBrick_Window_Wide_Flat.gltf` |
| `Wall_UnevenBrick_Window_Wide_Round` | aldea | `RPG/assets/aldea/glTF/Wall_UnevenBrick_Window_Wide_Round.gltf` |
| `WindowShutters_Thin_Flat_Closed` | aldea | `RPG/assets/aldea/glTF/WindowShutters_Thin_Flat_Closed.gltf` |
| `WindowShutters_Thin_Flat_Open` | aldea | `RPG/assets/aldea/glTF/WindowShutters_Thin_Flat_Open.gltf` |
| `WindowShutters_Thin_Round_Closed` | aldea | `RPG/assets/aldea/glTF/WindowShutters_Thin_Round_Closed.gltf` |
| `WindowShutters_Thin_Round_Open` | aldea | `RPG/assets/aldea/glTF/WindowShutters_Thin_Round_Open.gltf` |
| `WindowShutters_Wide_Flat_Closed` | aldea | `RPG/assets/aldea/glTF/WindowShutters_Wide_Flat_Closed.gltf` |
| `WindowShutters_Wide_Flat_Open` | aldea | `RPG/assets/aldea/glTF/WindowShutters_Wide_Flat_Open.gltf` |
| `WindowShutters_Wide_Round_Closed` | aldea | `RPG/assets/aldea/glTF/WindowShutters_Wide_Round_Closed.gltf` |
| `WindowShutters_Wide_Round_Open` | aldea | `RPG/assets/aldea/glTF/WindowShutters_Wide_Round_Open.gltf` |
| `Window_Roof_Thin` | aldea | `RPG/assets/aldea/glTF/Window_Roof_Thin.gltf` |
| `Window_Roof_Wide` | aldea | `RPG/assets/aldea/glTF/Window_Roof_Wide.gltf` |
| `Window_Thin_Flat1` | aldea | `RPG/assets/aldea/glTF/Window_Thin_Flat1.gltf` |
| `Window_Thin_Round1` | aldea | `RPG/assets/aldea/glTF/Window_Thin_Round1.gltf` |
| `Window_Wide_Flat1` | aldea | `RPG/assets/aldea/glTF/Window_Wide_Flat1.gltf` |
| `Window_Wide_Round1` | aldea | `RPG/assets/aldea/glTF/Window_Wide_Round1.gltf` |

### Árboles (20)

| Modelo | Paquete | Ruta relativa al repositorio |
|---|---|---|
| `CommonTree_1` | naturaleza | `RPG/assets/naturaleza/glTF/CommonTree_1.gltf` |
| `CommonTree_2` | naturaleza | `RPG/assets/naturaleza/glTF/CommonTree_2.gltf` |
| `CommonTree_3` | naturaleza | `RPG/assets/naturaleza/glTF/CommonTree_3.gltf` |
| `CommonTree_4` | naturaleza | `RPG/assets/naturaleza/glTF/CommonTree_4.gltf` |
| `CommonTree_5` | naturaleza | `RPG/assets/naturaleza/glTF/CommonTree_5.gltf` |
| `DeadTree_1` | naturaleza | `RPG/assets/naturaleza/glTF/DeadTree_1.gltf` |
| `DeadTree_2` | naturaleza | `RPG/assets/naturaleza/glTF/DeadTree_2.gltf` |
| `DeadTree_3` | naturaleza | `RPG/assets/naturaleza/glTF/DeadTree_3.gltf` |
| `DeadTree_4` | naturaleza | `RPG/assets/naturaleza/glTF/DeadTree_4.gltf` |
| `DeadTree_5` | naturaleza | `RPG/assets/naturaleza/glTF/DeadTree_5.gltf` |
| `Pine_1` | naturaleza | `RPG/assets/naturaleza/glTF/Pine_1.gltf` |
| `Pine_2` | naturaleza | `RPG/assets/naturaleza/glTF/Pine_2.gltf` |
| `Pine_3` | naturaleza | `RPG/assets/naturaleza/glTF/Pine_3.gltf` |
| `Pine_4` | naturaleza | `RPG/assets/naturaleza/glTF/Pine_4.gltf` |
| `Pine_5` | naturaleza | `RPG/assets/naturaleza/glTF/Pine_5.gltf` |
| `TwistedTree_1` | naturaleza | `RPG/assets/naturaleza/glTF/TwistedTree_1.gltf` |
| `TwistedTree_2` | naturaleza | `RPG/assets/naturaleza/glTF/TwistedTree_2.gltf` |
| `TwistedTree_3` | naturaleza | `RPG/assets/naturaleza/glTF/TwistedTree_3.gltf` |
| `TwistedTree_4` | naturaleza | `RPG/assets/naturaleza/glTF/TwistedTree_4.gltf` |
| `TwistedTree_5` | naturaleza | `RPG/assets/naturaleza/glTF/TwistedTree_5.gltf` |

### Arbustos (7)

| Modelo | Paquete | Ruta relativa al repositorio |
|---|---|---|
| `Bush_Common` | naturaleza | `RPG/assets/naturaleza/glTF/Bush_Common.gltf` |
| `Bush_Common_Flowers` | naturaleza | `RPG/assets/naturaleza/glTF/Bush_Common_Flowers.gltf` |
| `Fern_1` | naturaleza | `RPG/assets/naturaleza/glTF/Fern_1.gltf` |
| `Plant_1` | naturaleza | `RPG/assets/naturaleza/glTF/Plant_1.gltf` |
| `Plant_1_Big` | naturaleza | `RPG/assets/naturaleza/glTF/Plant_1_Big.gltf` |
| `Plant_7` | naturaleza | `RPG/assets/naturaleza/glTF/Plant_7.gltf` |
| `Plant_7_Big` | naturaleza | `RPG/assets/naturaleza/glTF/Plant_7_Big.gltf` |

### Flores (9)

| Modelo | Paquete | Ruta relativa al repositorio |
|---|---|---|
| `Flower_3_Group` | naturaleza | `RPG/assets/naturaleza/glTF/Flower_3_Group.gltf` |
| `Flower_3_Single` | naturaleza | `RPG/assets/naturaleza/glTF/Flower_3_Single.gltf` |
| `Flower_4_Group` | naturaleza | `RPG/assets/naturaleza/glTF/Flower_4_Group.gltf` |
| `Flower_4_Single` | naturaleza | `RPG/assets/naturaleza/glTF/Flower_4_Single.gltf` |
| `Petal_1` | naturaleza | `RPG/assets/naturaleza/glTF/Petal_1.gltf` |
| `Petal_2` | naturaleza | `RPG/assets/naturaleza/glTF/Petal_2.gltf` |
| `Petal_3` | naturaleza | `RPG/assets/naturaleza/glTF/Petal_3.gltf` |
| `Petal_4` | naturaleza | `RPG/assets/naturaleza/glTF/Petal_4.gltf` |
| `Petal_5` | naturaleza | `RPG/assets/naturaleza/glTF/Petal_5.gltf` |

### Rocas (28)

| Modelo | Paquete | Ruta relativa al repositorio |
|---|---|---|
| `Prop_Brick1` | aldea | `RPG/assets/aldea/glTF/Prop_Brick1.gltf` |
| `Prop_Brick2` | aldea | `RPG/assets/aldea/glTF/Prop_Brick2.gltf` |
| `Prop_Brick3` | aldea | `RPG/assets/aldea/glTF/Prop_Brick3.gltf` |
| `Prop_Brick4` | aldea | `RPG/assets/aldea/glTF/Prop_Brick4.gltf` |
| `Pebble_Round_1` | naturaleza | `RPG/assets/naturaleza/glTF/Pebble_Round_1.gltf` |
| `Pebble_Round_2` | naturaleza | `RPG/assets/naturaleza/glTF/Pebble_Round_2.gltf` |
| `Pebble_Round_3` | naturaleza | `RPG/assets/naturaleza/glTF/Pebble_Round_3.gltf` |
| `Pebble_Round_4` | naturaleza | `RPG/assets/naturaleza/glTF/Pebble_Round_4.gltf` |
| `Pebble_Round_5` | naturaleza | `RPG/assets/naturaleza/glTF/Pebble_Round_5.gltf` |
| `Pebble_Square_1` | naturaleza | `RPG/assets/naturaleza/glTF/Pebble_Square_1.gltf` |
| `Pebble_Square_2` | naturaleza | `RPG/assets/naturaleza/glTF/Pebble_Square_2.gltf` |
| `Pebble_Square_3` | naturaleza | `RPG/assets/naturaleza/glTF/Pebble_Square_3.gltf` |
| `Pebble_Square_4` | naturaleza | `RPG/assets/naturaleza/glTF/Pebble_Square_4.gltf` |
| `Pebble_Square_5` | naturaleza | `RPG/assets/naturaleza/glTF/Pebble_Square_5.gltf` |
| `Pebble_Square_6` | naturaleza | `RPG/assets/naturaleza/glTF/Pebble_Square_6.gltf` |
| `RockPath_Round_Small_1` | naturaleza | `RPG/assets/naturaleza/glTF/RockPath_Round_Small_1.gltf` |
| `RockPath_Round_Small_2` | naturaleza | `RPG/assets/naturaleza/glTF/RockPath_Round_Small_2.gltf` |
| `RockPath_Round_Small_3` | naturaleza | `RPG/assets/naturaleza/glTF/RockPath_Round_Small_3.gltf` |
| `RockPath_Round_Thin` | naturaleza | `RPG/assets/naturaleza/glTF/RockPath_Round_Thin.gltf` |
| `RockPath_Round_Wide` | naturaleza | `RPG/assets/naturaleza/glTF/RockPath_Round_Wide.gltf` |
| `RockPath_Square_Small_1` | naturaleza | `RPG/assets/naturaleza/glTF/RockPath_Square_Small_1.gltf` |
| `RockPath_Square_Small_2` | naturaleza | `RPG/assets/naturaleza/glTF/RockPath_Square_Small_2.gltf` |
| `RockPath_Square_Small_3` | naturaleza | `RPG/assets/naturaleza/glTF/RockPath_Square_Small_3.gltf` |
| `RockPath_Square_Thin` | naturaleza | `RPG/assets/naturaleza/glTF/RockPath_Square_Thin.gltf` |
| `RockPath_Square_Wide` | naturaleza | `RPG/assets/naturaleza/glTF/RockPath_Square_Wide.gltf` |
| `Rock_Medium_1` | naturaleza | `RPG/assets/naturaleza/glTF/Rock_Medium_1.gltf` |
| `Rock_Medium_2` | naturaleza | `RPG/assets/naturaleza/glTF/Rock_Medium_2.gltf` |
| `Rock_Medium_3` | naturaleza | `RPG/assets/naturaleza/glTF/Rock_Medium_3.gltf` |

### Mobiliario (13)

| Modelo | Paquete | Ruta relativa al repositorio |
|---|---|---|
| `Bed_Twin1` | objetos | `RPG/assets/objetos_medievales/glTF/Bed_Twin1.gltf` |
| `Bed_Twin2` | objetos | `RPG/assets/objetos_medievales/glTF/Bed_Twin2.gltf` |
| `Bench` | objetos | `RPG/assets/objetos_medievales/glTF/Bench.gltf` |
| `Bookcase_2` | objetos | `RPG/assets/objetos_medievales/glTF/Bookcase_2.gltf` |
| `Cabinet` | objetos | `RPG/assets/objetos_medievales/glTF/Cabinet.gltf` |
| `Chair_1` | objetos | `RPG/assets/objetos_medievales/glTF/Chair_1.gltf` |
| `Chest_Wood` | objetos | `RPG/assets/objetos_medievales/glTF/Chest_Wood.gltf` |
| `Nightstand_Shelf` | objetos | `RPG/assets/objetos_medievales/glTF/Nightstand_Shelf.gltf` |
| `Shelf_Arch` | objetos | `RPG/assets/objetos_medievales/glTF/Shelf_Arch.gltf` |
| `Shelf_Simple` | objetos | `RPG/assets/objetos_medievales/glTF/Shelf_Simple.gltf` |
| `Shelf_Small_Bottles` | objetos | `RPG/assets/objetos_medievales/glTF/Shelf_Small_Bottles.gltf` |
| `Stool` | objetos | `RPG/assets/objetos_medievales/glTF/Stool.gltf` |
| `Table_Large` | objetos | `RPG/assets/objetos_medievales/glTF/Table_Large.gltf` |

### Herramientas (8)

| Modelo | Paquete | Ruta relativa al repositorio |
|---|---|---|
| `Axe_Bronze` | objetos | `RPG/assets/objetos_medievales/glTF/Axe_Bronze.gltf` |
| `Bucket_Metal` | objetos | `RPG/assets/objetos_medievales/glTF/Bucket_Metal.gltf` |
| `Bucket_Wooden_1` | objetos | `RPG/assets/objetos_medievales/glTF/Bucket_Wooden_1.gltf` |
| `Peg_Rack` | objetos | `RPG/assets/objetos_medievales/glTF/Peg_Rack.gltf` |
| `Pickaxe_Bronze` | objetos | `RPG/assets/objetos_medievales/glTF/Pickaxe_Bronze.gltf` |
| `Rope_1` | objetos | `RPG/assets/objetos_medievales/glTF/Rope_1.gltf` |
| `Rope_2` | objetos | `RPG/assets/objetos_medievales/glTF/Rope_2.gltf` |
| `Rope_3` | objetos | `RPG/assets/objetos_medievales/glTF/Rope_3.gltf` |

### Mercado (18)

| Modelo | Paquete | Ruta relativa al repositorio |
|---|---|---|
| `Prop_Crate` | aldea | `RPG/assets/aldea/glTF/Prop_Crate.gltf` |
| `Prop_Wagon` | aldea | `RPG/assets/aldea/glTF/Prop_Wagon.gltf` |
| `Bag` | objetos | `RPG/assets/objetos_medievales/glTF/Bag.gltf` |
| `Barrel` | objetos | `RPG/assets/objetos_medievales/glTF/Barrel.gltf` |
| `Barrel_Apples` | objetos | `RPG/assets/objetos_medievales/glTF/Barrel_Apples.gltf` |
| `Barrel_Holder` | objetos | `RPG/assets/objetos_medievales/glTF/Barrel_Holder.gltf` |
| `Carrot` | objetos | `RPG/assets/objetos_medievales/glTF/Carrot.gltf` |
| `Coin` | objetos | `RPG/assets/objetos_medievales/glTF/Coin.gltf` |
| `Coin_Pile` | objetos | `RPG/assets/objetos_medievales/glTF/Coin_Pile.gltf` |
| `Coin_Pile_2` | objetos | `RPG/assets/objetos_medievales/glTF/Coin_Pile_2.gltf` |
| `Crate_Metal` | objetos | `RPG/assets/objetos_medievales/glTF/Crate_Metal.gltf` |
| `Crate_Wooden` | objetos | `RPG/assets/objetos_medievales/glTF/Crate_Wooden.gltf` |
| `FarmCrate_Apple` | objetos | `RPG/assets/objetos_medievales/glTF/FarmCrate_Apple.gltf` |
| `FarmCrate_Carrot` | objetos | `RPG/assets/objetos_medievales/glTF/FarmCrate_Carrot.gltf` |
| `FarmCrate_Empty` | objetos | `RPG/assets/objetos_medievales/glTF/FarmCrate_Empty.gltf` |
| `Pouch_Large` | objetos | `RPG/assets/objetos_medievales/glTF/Pouch_Large.gltf` |
| `Stall_Cart_Empty` | objetos | `RPG/assets/objetos_medievales/glTF/Stall_Cart_Empty.gltf` |
| `Stall_Empty` | objetos | `RPG/assets/objetos_medievales/glTF/Stall_Empty.gltf` |

### Herrería (7)

| Modelo | Paquete | Ruta relativa al repositorio |
|---|---|---|
| `Anvil` | objetos | `RPG/assets/objetos_medievales/glTF/Anvil.gltf` |
| `Anvil_Log` | objetos | `RPG/assets/objetos_medievales/glTF/Anvil_Log.gltf` |
| `Chain_Coil` | objetos | `RPG/assets/objetos_medievales/glTF/Chain_Coil.gltf` |
| `WeaponStand` | objetos | `RPG/assets/objetos_medievales/glTF/WeaponStand.gltf` |
| `Whetstone` | objetos | `RPG/assets/objetos_medievales/glTF/Whetstone.gltf` |
| `Workbench` | objetos | `RPG/assets/objetos_medievales/glTF/Workbench.gltf` |
| `Workbench_Drawers` | objetos | `RPG/assets/objetos_medievales/glTF/Workbench_Drawers.gltf` |

### Decoración (51)

| Modelo | Paquete | Ruta relativa al repositorio |
|---|---|---|
| `Prop_Vine1` | aldea | `RPG/assets/aldea/glTF/Prop_Vine1.gltf` |
| `Prop_Vine2` | aldea | `RPG/assets/aldea/glTF/Prop_Vine2.gltf` |
| `Prop_Vine4` | aldea | `RPG/assets/aldea/glTF/Prop_Vine4.gltf` |
| `Prop_Vine5` | aldea | `RPG/assets/aldea/glTF/Prop_Vine5.gltf` |
| `Prop_Vine6` | aldea | `RPG/assets/aldea/glTF/Prop_Vine6.gltf` |
| `Prop_Vine9` | aldea | `RPG/assets/aldea/glTF/Prop_Vine9.gltf` |
| `Banner_1` | objetos | `RPG/assets/objetos_medievales/glTF/Banner_1.gltf` |
| `Banner_1_Cloth` | objetos | `RPG/assets/objetos_medievales/glTF/Banner_1_Cloth.gltf` |
| `Banner_2` | objetos | `RPG/assets/objetos_medievales/glTF/Banner_2.gltf` |
| `Banner_2_Cloth` | objetos | `RPG/assets/objetos_medievales/glTF/Banner_2_Cloth.gltf` |
| `BookGroup_Medium_1` | objetos | `RPG/assets/objetos_medievales/glTF/BookGroup_Medium_1.gltf` |
| `BookGroup_Medium_2` | objetos | `RPG/assets/objetos_medievales/glTF/BookGroup_Medium_2.gltf` |
| `BookGroup_Medium_3` | objetos | `RPG/assets/objetos_medievales/glTF/BookGroup_Medium_3.gltf` |
| `BookGroup_Small_1` | objetos | `RPG/assets/objetos_medievales/glTF/BookGroup_Small_1.gltf` |
| `BookGroup_Small_2` | objetos | `RPG/assets/objetos_medievales/glTF/BookGroup_Small_2.gltf` |
| `BookGroup_Small_3` | objetos | `RPG/assets/objetos_medievales/glTF/BookGroup_Small_3.gltf` |
| `BookStand` | objetos | `RPG/assets/objetos_medievales/glTF/BookStand.gltf` |
| `Book_5` | objetos | `RPG/assets/objetos_medievales/glTF/Book_5.gltf` |
| `Book_7` | objetos | `RPG/assets/objetos_medievales/glTF/Book_7.gltf` |
| `Book_Simplified_Single` | objetos | `RPG/assets/objetos_medievales/glTF/Book_Simplified_Single.gltf` |
| `Book_Stack_1` | objetos | `RPG/assets/objetos_medievales/glTF/Book_Stack_1.gltf` |
| `Book_Stack_2` | objetos | `RPG/assets/objetos_medievales/glTF/Book_Stack_2.gltf` |
| `Bottle_1` | objetos | `RPG/assets/objetos_medievales/glTF/Bottle_1.gltf` |
| `Cage_Small` | objetos | `RPG/assets/objetos_medievales/glTF/Cage_Small.gltf` |
| `CandleStick` | objetos | `RPG/assets/objetos_medievales/glTF/CandleStick.gltf` |
| `CandleStick_Stand` | objetos | `RPG/assets/objetos_medievales/glTF/CandleStick_Stand.gltf` |
| `CandleStick_Triple` | objetos | `RPG/assets/objetos_medievales/glTF/CandleStick_Triple.gltf` |
| `Candle_1` | objetos | `RPG/assets/objetos_medievales/glTF/Candle_1.gltf` |
| `Candle_2` | objetos | `RPG/assets/objetos_medievales/glTF/Candle_2.gltf` |
| `Cauldron` | objetos | `RPG/assets/objetos_medievales/glTF/Cauldron.gltf` |
| `Chalice` | objetos | `RPG/assets/objetos_medievales/glTF/Chalice.gltf` |
| `Chandelier` | objetos | `RPG/assets/objetos_medievales/glTF/Chandelier.gltf` |
| `Lantern_Wall` | objetos | `RPG/assets/objetos_medievales/glTF/Lantern_Wall.gltf` |
| `Mug` | objetos | `RPG/assets/objetos_medievales/glTF/Mug.gltf` |
| `Pot_1` | objetos | `RPG/assets/objetos_medievales/glTF/Pot_1.gltf` |
| `Pot_1_Lid` | objetos | `RPG/assets/objetos_medievales/glTF/Pot_1_Lid.gltf` |
| `Potion_1` | objetos | `RPG/assets/objetos_medievales/glTF/Potion_1.gltf` |
| `Potion_2` | objetos | `RPG/assets/objetos_medievales/glTF/Potion_2.gltf` |
| `Potion_4` | objetos | `RPG/assets/objetos_medievales/glTF/Potion_4.gltf` |
| `Scroll_1` | objetos | `RPG/assets/objetos_medievales/glTF/Scroll_1.gltf` |
| `Scroll_2` | objetos | `RPG/assets/objetos_medievales/glTF/Scroll_2.gltf` |
| `SmallBottle` | objetos | `RPG/assets/objetos_medievales/glTF/SmallBottle.gltf` |
| `SmallBottles_1` | objetos | `RPG/assets/objetos_medievales/glTF/SmallBottles_1.gltf` |
| `Table_Fork` | objetos | `RPG/assets/objetos_medievales/glTF/Table_Fork.gltf` |
| `Table_Knife` | objetos | `RPG/assets/objetos_medievales/glTF/Table_Knife.gltf` |
| `Table_Plate` | objetos | `RPG/assets/objetos_medievales/glTF/Table_Plate.gltf` |
| `Table_Spoon` | objetos | `RPG/assets/objetos_medievales/glTF/Table_Spoon.gltf` |
| `Torch_Metal` | objetos | `RPG/assets/objetos_medievales/glTF/Torch_Metal.gltf` |
| `Vase_2` | objetos | `RPG/assets/objetos_medievales/glTF/Vase_2.gltf` |
| `Vase_4` | objetos | `RPG/assets/objetos_medievales/glTF/Vase_4.gltf` |
| `Vase_Rubble_Medium` | objetos | `RPG/assets/objetos_medievales/glTF/Vase_Rubble_Medium.gltf` |

### Otros (13)

| Modelo | Paquete | Ruta relativa al repositorio |
|---|---|---|
| `Clover_1` | naturaleza | `RPG/assets/naturaleza/glTF/Clover_1.gltf` |
| `Clover_2` | naturaleza | `RPG/assets/naturaleza/glTF/Clover_2.gltf` |
| `Grass_Common_Short` | naturaleza | `RPG/assets/naturaleza/glTF/Grass_Common_Short.gltf` |
| `Grass_Common_Tall` | naturaleza | `RPG/assets/naturaleza/glTF/Grass_Common_Tall.gltf` |
| `Grass_Wispy_Short` | naturaleza | `RPG/assets/naturaleza/glTF/Grass_Wispy_Short.gltf` |
| `Grass_Wispy_Tall` | naturaleza | `RPG/assets/naturaleza/glTF/Grass_Wispy_Tall.gltf` |
| `Mushroom_Common` | naturaleza | `RPG/assets/naturaleza/glTF/Mushroom_Common.gltf` |
| `Mushroom_Laetiporus` | naturaleza | `RPG/assets/naturaleza/glTF/Mushroom_Laetiporus.gltf` |
| `Dummy` | objetos | `RPG/assets/objetos_medievales/glTF/Dummy.gltf` |
| `Key_Gold` | objetos | `RPG/assets/objetos_medievales/glTF/Key_Gold.gltf` |
| `Key_Metal` | objetos | `RPG/assets/objetos_medievales/glTF/Key_Metal.gltf` |
| `Shield_Wooden` | objetos | `RPG/assets/objetos_medievales/glTF/Shield_Wooden.gltf` |
| `Sword_Bronze` | objetos | `RPG/assets/objetos_medievales/glTF/Sword_Bronze.gltf` |

### Protagonista 2D
- `RPG/assets/personajes/protagonista/Character_Idle.png`
- `RPG/assets/personajes/protagonista/Character_Walk.png`

Son dos hojas PNG, no modelos 3D. Ambas cargan como Texture2D. No se modificaron SpriteFrames, AnimatedSprite3D, escenas, cámara ni controles; la prueba de recursos no comprueba la configuración de sus animaciones.

## 4. Selección recomendada para una aldea acogedora

Los nombres siguientes remiten a las rutas relativas al repositorio del inventario; son propuestas de uso, no edificios ya generados.

| Zona | Recursos prioritarios | Uso propuesto |
|---|---|---|
| Plaza central | `Floor_UnevenBrick`, `Floor_Brick`, `RockPath_Round_Wide`, `RockPath_Round_Thin`, `Bench`, `Lantern_Wall`, `Bush_Common_Flowers` | Plaza pequeña irregular, bancos e iluminación cálida. Los faroles requieren luces/efectos añadidos; el modelo no garantiza iluminación dinámica. |
| Viviendas | `Wall_Plaster_Straight`, `Wall_Plaster_WoodGrid`, `Wall_Plaster_Door_Round`, `DoorFrame_Round_WoodDark`, `Door_1_Round`, `Window_Wide_Round1`, `WindowShutters_Wide_Round_Open`, `Roof_RoundTiles_4x6`, `Prop_Chimney` | Construir pocas tipologías de casas y variar cubierta, huecos, aleros y decoración. |
| Taberna | Módulos de vivienda + `Roof_RoundTiles_6x8`, `Prop_Chimney2`, `Table_Large`, `Chair_1`, `Stool`, `Barrel`, `Mug`, `Chalice`, `Chandelier`, `Bed_Twin1` | Exterior de mayor volumen y mobiliario de sala/dormitorios; todavía no es un edificio preparado. |
| Herrería | `Anvil`, `Anvil_Log`, `Whetstone`, `Workbench`, `Workbench_Drawers`, `WeaponStand`, `Chain_Coil`, `Prop_Chimney` | Taller abierto junto a la plaza. Falta una fragua/horno específico y sus efectos de fuego. |
| Mercado | `Stall_Empty`, `Stall_Cart_Empty`, `FarmCrate_Apple`, `FarmCrate_Carrot`, `FarmCrate_Empty`, `Barrel_Apples`, `Crate_Wooden`, `Prop_Wagon` | Dos o tres puestos con mercancía y carro; variar disposición sin saturar la plaza. |
| Huertos | `Carrot`, `FarmCrate_Carrot`, `Bucket_Wooden_1`, `Prop_WoodenFence_Single`, `Prop_WoodenFence_Extension1`, `Grass_Common_Short` | Delimitación y utilería; la zanahoria es un prop, no un sistema de cultivo ni una familia de etapas de crecimiento. |
| Naturaleza cercana | `CommonTree_1` a `CommonTree_5`, `Bush_Common`, `Bush_Common_Flowers`, `Flower_3_Group`, `Flower_4_Group`, `Clover_1`, `Fern_1`, `Rock_Medium_1`, `Mushroom_Common` | Arbolado de hoja ancha, flores y grupos irregulares de vegetación para la zona acogedora. |
| Bosque exterior | `Pine_1` a `Pine_5`, `TwistedTree_1` a `TwistedTree_5`, `DeadTree_1` a `DeadTree_5` | Reservar árboles retorcidos y secos para bordes de bosque y zonas narrativas, no dominar el centro acogedor. |

## 5. Compatibilidad y preparación pendiente

- **Importación compatible en la versión exacta instalada:** 4.7.2, corroborada por ejecutable y Engine.get_version_info(), no inferida únicamente de `config/features` (que declara 4.7).
- **Materiales presentes:** 0 superficies sin material. Hay 7 modelos de arquitectura con materiales BLEND, 6 con MASK y 33 de naturaleza con MASK: revisar ventanas, enredaderas, hojas y flores desde la cámara real por recorte, orden de transparencias y sombras. Esta cuenta indica modelos que tienen al menos un material de ese modo, no superficies.
- **Colisiones:** 0 CollisionShape3D en las 338 instancias. Se necesitan colisiones simplificadas para suelo, casas, puente y obstáculos relevantes, en futuras escenas envoltorio; evitar colisionar toda hoja y piedra pequeña.
- **No hay gameplay listo:** no se detectaron animaciones glTF. Interacciones, luces, efectos, navegación, interiores accesibles y oclusión del protagonista requieren preparación posterior.
- **Escala/pivotes:** las dimensiones se pudieron obtener al instanciar, pero falta contrastarlas visualmente con el personaje y probar encajes de pared, cubierta, puerta y escaleras. No aplicar escalados masivos todavía.
- **Normales:** conservar por ahora las referencias originales de los glTF. Comparar relieve y dirección de iluminación con las variantes Godot-Unity antes de proponer sustituciones.
- **Rendimiento:** aprovechar la configuración existente de generación de LOD y shadow meshes; medir después densidad de vegetación, sombras y repetición de materiales. Considerar MultiMesh para elementos estáticos repetidos cuando exista una distribución definitiva. No se añadió ningún plugin ni dependencia.
- **Git:** exclusión intencional de assets confirmada con `git check-ignore`. El inventario puede versionarse, pero otra máquina no tendrá los modelos solo por clonar el repositorio: conservar los paquetes y sus condiciones de licencia por separado. No se evaluó licencia porque no se encontró texto de licencia dentro de las cuatro carpetas auditadas.

## 6. Qué falta para río, puente, molino y caminos naturales

| Elemento | Disponible en estas carpetas | Falta / siguiente trabajo |
|---|---|---|
| Río | Rocas medianas, guijarros, helechos y vegetación para ribera. | No se identificaron malla/material/shader de agua, cauce, terreno de orillas, corriente, espuma ni sonido. Crear cauce y agua, transiciones de ribera y decidir colisiones/zonas de baño. |
| Puente | `Floor_WoodDark`, `Floor_WoodLight`, soportes y vallas pueden servir de materia prima. | No hay modelo dedicado de puente. Diseñar estructura, estribos, barandillas y superficie transitable con colisión y navegación. El encaje y resistencia visual de estos módulos no se probaron. |
| Molino de agua | Módulos de muros, tejados, chimeneas y mobiliario para el edificio. | No hay rueda hidráulica, eje, engranajes, piedra de moler ni conjunto de molino identificados. Modelar/adquirir esas piezas y después animar rueda y flujo; si se elige molino de viento, también faltan aspas. |
| Caminos naturales | 10 `RockPath_*`, 11 `Pebble_*`, césped y piedras medianas. | Estas son mallas de piedra, no senderos continuos de tierra. Falta terreno continuo y material de tierra/barro con mezcla suave hacia hierba; opcionalmente curvas de camino, decals, bordes y control de pendiente. |
| Huertos funcionales | Zanahoria suelta, cajas, cubos y cercas. | Faltan surcos/bancales, plantas cultivadas y etapas de crecimiento/cosecha, semillas, azada y regadera específicas. Las cajas de manzana no equivalen a manzanos ni frutales. |
| Servicios de aldea | Puestos, mobiliario, herramientas, utilería, yunque y banco de afilar. | No se identificaron pozo/fuente, fragua/horno, señal de taberna con identidad propia, NPCs ni animales. Priorizar según el diseño; no todos son imprescindibles para la primera prueba. |

La ausencia se refiere al contenido local inventariado y a sus nombres/estructuras; no afirma que esas piezas no existan en ediciones completas o en otros paquetes del autor.

## 7. Recomendaciones para la siguiente etapa

1. Preparar una **escena nueva de pruebas**, con una casa modular mínima, un árbol, un puesto y el protagonista como referencia de escala. Revisar materiales, normales, transparencias, pivotes y encajes desde la cámara de juego.
2. Fijar medidas de puertas, altura de plantas, anchura de caminos y espacio de interacción; crear futuras escenas envoltorio reutilizables con colisiones simples, sin editar los glTF.
3. Prototipar terreno/cauce/camino y encargar las piezas especiales de puente y molino antes de detallar toda la aldea.
4. Definir luego el esquema de plaza, viviendas, taberna, herrería, mercado y huertos; distribuir vegetación al final para preservar legibilidad y accesos.
5. Medir navegación, oclusión del sprite y rendimiento en ejecución gráfica. Solo después ampliar densidad y decoración.
6. Mantener assets fuera de Git según la política actual; registrar por separado procedencia, versión de paquete y licencia cuando se disponga de esos documentos.

## 8. Alcance de cambios

Único archivo creado dentro del proyecto por esta tarea: `RPG/docs/inventario_assets.md`. Herramientas auxiliares, copia de recursos y logs permanecen en el directorio temporal externo al repositorio. No se generó una aldea, no se cambiaron escenas, scripts, configuración ni assets, y no se hicieron commits ni pushes. Los cambios que ya existían al iniciar la auditoría se preservaron. La comprobación final compara hashes del contenido del proyecto (excluyendo la caché `.godot`) con la captura inicial.

## Uso incorporado en E02 — 1 de noviembre de 2026

`RPG/scenes/panaderia.tscn` reutiliza originales sin modificarlos ni añadir paquetes:

- `RPG/assets/aldea/glTF/`: `Wall_Plaster_WoodGrid`, `Wall_Plaster_Straight`, `Wall_Plaster_Window_Wide_Flat`, `Wall_Plaster_Door_Flat`, `Window_Wide_Flat1`, `Door_1_Flat`, `DoorFrame_Flat_WoodDark`, `Roof_RoundTiles_4x6`, `Roof_Front_Brick4`; texturas `T_RoundTiles_Normal.png`, `T_RoundTiles_Roughness.png`, `T_UnevenBrick_BaseColor.png`. Cubierta con material local y escala vertical 0.60 compartida con frontones.
- `RPG/assets/objetos_medievales/glTF/`: `Barrel`, `Crate_Wooden`, `Bag` (dos sacos), `Lantern_Wall` decorativo.
- Primitivas dentro de la escena, fuera de assets/: hogazas achatadas/cortes, bandeja, mostrador, toldo a franjas, cartel/Label3D, horno/chimenea, leña, revoco de cierre, vigas y zócalos. No son modelos originales ni sistemas de juego. Sin cesta dedicada identificada.

Total conservado: 338 modelos originales; procedencia/licencias pendientes sin cambios. El paquete sigue sin horno dedicado: E02 resuelve su horno decorativo mediante geometría local. Recursos cargados y revisados en ocho vistas Forward+/D3D12; aprobación artística pendiente del usuario.

## Uso incorporado en E03 — 1 de noviembre de 2026

`RPG/scenes/herreria.tscn` reutiliza sin modificar los originales:

- `RPG/assets/objetos_medievales/glTF/`: `Anvil_Log` (yunque con tocón disponible, no modelado de nuevo), `Workbench`, `Whetstone`, `Bucket_Metal`, `Barrel`, `Crate_Wooden` y `Chain_Coil`.
- `RPG/assets/aldea/glTF/T_UnevenBrick_BaseColor.png`: material local de mampostería gris con repetición UV, sin editar la imagen fuente.
- Geometría local de Godot fuera de assets/: muros, postes, riostras, cubiertas bajas de pizarra/madera, forja completa con brasas emisivas estáticas y chimenea, carbón, leña, barras, martillo, tenazas y soportes. La forja resuelve una pieza dedicada ausente del paquete; no implica fabricación, fuego dinámico ni interacción.

Se mantienen 338 modelos originales, los mismos paquetes y la exclusión de assets en Git. Recursos de E03 cargados en Godot 4.7.2 y capturados con Forward+/D3D12; aprobación artística pendiente del usuario.

## Uso incorporado en E04 — 1 de noviembre de 2026

`RPG/scenes/carpinteria.tscn` reutiliza `Workbench`, `Axe_Bronze`, `Crate_Wooden` y `Rope_1`, todos en `RPG/assets/objetos_medievales/glTF/`, con rutas locales verificadas y sin modificar originales. La lista local no contiene modelos dedicados de sierra ni cepillo de carpintero; se representan mediante geometría sencilla de Godot, junto con mazo y escuadra a escala del banco.

Primitivas fuera de assets/: postes, muros parciales, riostras, bases de piedra, cubierta a una pendiente, caballetes, troncos/testas/soportes, tablones, vigas, virutas, bastidor de puerta y taburete en proceso. Materiales locales exclusivos de E04. Sin nuevos paquetes, modelos originales ni dependencias; total conservado de 338 glTF. Capturas técnicas Forward+/D3D12 disponibles, aprobación artística pendiente.

## Uso incorporado en E05 — 2 de noviembre de 2026

`RPG/scenes/herbolario.tscn` reutiliza originales con rutas verificadas, sin modificarlos:

- `RPG/assets/objetos_medievales/glTF/SmallBottles_1.gltf`: conjunto de frascos en mesa, escala local 1.8 para legibilidad.
- `RPG/assets/objetos_medievales/glTF/Barrel.gltf`: agua de riego al noreste, escala 1; colisión simplificada de 0.7×0.9×0.7 añadida en escena.
- `RPG/assets/naturaleza/glTF/Fern_1.gltf`: helecho al noroeste, escala local 0.65 y apoyo corregido según su AABB.

Primitivas de Godot fuera de assets/: muros/entramado/zócalos, frontones, cubierta verde de tablillas y secadero, puerta/letrero, ventanas/repisas, macetas, cinco bancales con plantas estilizadas de cinco familias, cuerda y siete manojos colgantes, mesa/mortero/mano y estantería con nueve tarros. No se atribuyen especies botánicas exactas a modelos importados ni se inventan rutas de morteros/hierbas específicas. Materiales locales exclusivos de E05.

Sin paquetes, dependencias ni modelos originales nuevos: permanecen 338 glTF y su exclusión intencional de Git. Recursos cargados en Godot 4.7.2 y ocho vistas Forward+/D3D12 revisadas técnicamente; aprobación artística pendiente del usuario. Sin sistemas de cultivo, medicina o alquimia.

## Uso incorporado en E07 — 2 de noviembre de 2026

`RPG/scenes/vivienda_noreste.tscn` reutiliza originales sin modificarlos, con rutas locales comprobadas:

- `RPG/assets/objetos_medievales/glTF/Bench.gltf`: banco del patio, escala 0.8; ancho real 2.22, colisión simplificada 2.25×0.5×0.48.
- `RPG/assets/objetos_medievales/glTF/Barrel.gltf`: agua al sureste, escala 0.85 y caja individual.
- `RPG/assets/objetos_medievales/glTF/Bucket_Wooden_1.gltf`: cubo junto al barril, escala 0.8.
- `RPG/assets/objetos_medievales/glTF/Bag.gltf`: saco doméstico al noreste, escala 0.8; no se atribuye al paquete una cesta no identificada.
- `RPG/assets/objetos_medievales/glTF/Lantern_Wall.gltf`: farol decorativo junto a puerta oeste, escala 0.45; sin luz dinámica nueva.
- `RPG/assets/aldea/glTF/T_UnevenBrick_BaseColor.png`: piedra de planta baja/chimenea mediante material exclusivo E07; textura fuente intacta.

Primitivas locales fuera de assets/: plantas baja/alta, zócalos, entramado, ménsulas, puerta/protección, ventanas/postigos, chimenea, leñera, tendedero/telas, losas y jardineras con soportes/flores. Cubierta cerrada propia en `RPG/scenes/vivienda_noreste_cubierta.tres`, con cuatro aguas y hileras chocolate en relieve dentro de la escena. No se reutilizó ni recoloreó un material compartido por otro edificio. Se inspeccionaron también las carpetas de aldea/naturaleza; no se incorporó un paquete nuevo ni se modificó vegetación original.

Se mantienen los 338 glTF originales y la exclusión de assets en Git. Carga y controles específicos aprobados en Godot 4.7.2 headless y Forward+/D3D12; ocho capturas revisadas técnicamente, pendientes de aprobación visual del usuario. Sin interiores, rutinas domésticas ni gameplay. La incidencia de retorno de E04 con velocidad temporal 10 se registra en el estado, no es un fallo de recursos E07.

## Uso incorporado en E08/E09 — 2 de noviembre de 2026

Escenas independientes `RPG/scenes/vivienda_suroeste.tscn` y `RPG/scenes/vivienda_sur.tscn`. Originales de `RPG/assets/objetos_medievales/glTF/` reutilizados sin modificaciones:

| Modelo | E08 | E09 |
|---|---|---|
| Bench | Banco noroeste, escala 0.62 | Banco de galería, escala 0.62, giro 90° |
| Barrel | Agua este, escala 0.90 | Agua oeste, escala 0.85 |
| Bag | Saco trasero, escala 0.85 | Semillas al sur, escala 0.65 |
| FarmCrate_Carrot | Caja agrícola, escala 0.80 | Caja de verduras, escala 0.70 |
| Bucket_Wooden_1 | Cubo, escala 0.80 | — |
| Pot_1 | — | Recipiente sobre mesa, escala 0.65 |

`RPG/assets/aldea/glTF/T_UnevenBrick_BaseColor.png`: piedra mediante materiales exclusivos de cada casa. Carpetas de aldea/naturaleza consultadas; sin vegetación importada adicional ni paquetes nuevos. No se atribuye una cesta específica al paquete: se usan cajas FarmCrate_Carrot.
Geometría local fuera de assets/: muros, yeso, entramado, puertas/ventanas/postigos, chimeneas, leñeras/troncos, rastrillo E08, galería/mesa/postes y jardineras/plantas/losas E09. Cubierta E08 con 144 haces pentagonales de paja y diez haces de cumbrera; E09 con 108 placas de pizarra y cubierta secundaria. Colisiones añadidas en cada escena; cubo, recipiente, plantas y herramienta pequeña sin colisión extra. No se recolorean recursos compartidos.
Permanecen 338 glTF originales y la exclusión de assets en Git; procedencia/licencias pendientes sin cambios. Recursos y apoyos validados en Godot 4.7.2 headless y Forward+/D3D12. Dieciséis capturas y una conjunta revisadas técnicamente; viviendas construidas, pendientes de aprobación visual del usuario. Sin huertos generales, cultivo ni gameplay.

## Uso incorporado en E10/E11 — 2 de noviembre de 2026

Escenas independientes `RPG/scenes/vivienda_e10.tscn` y `RPG/scenes/vivienda_e11.tscn`; originales de `RPG/assets/objetos_medievales/glTF/` reutilizados sin modificar:

| Modelo | E10 | E11 |
|---|---|---|
| Barrel | Agua oeste, escala 0.8 | Agua este, escala 0.8 |
| Bag | Semillas bajo cobertizo, 0.65; saco trasero, 0.7 | — |
| FarmCrate_Carrot | Caja de verduras en patio sur, 0.7 | — |
| Bucket_Wooden_1 | Cubo oeste, 0.65 | — |
| Bench | — | Banco oeste, 0.62 |
| Lantern_Wall | — | Farol junto a puerta, 0.4, sin luz dinámica nueva |

Ambas usan `RPG/assets/aldea/glTF/T_UnevenBrick_BaseColor.png` en materiales de piedra exclusivos de cada escena. Se mantienen intactos la imagen y los materiales originales/compartidos. No se añaden paquetes ni dependencias: permanecen 338 modelos glTF, excluidos intencionalmente de Git; licencias/procedencia pendientes sin cambios.

Geometría local de Godot fuera de assets/: muros, entramado, ventanas/postigos, puertas/herrajes, frontones, chimeneas, losas y cubiertas con 168 tablillas por vivienda. E10: cobertizo bajo, almacenamiento, rastrillo, leñera y alero. E11: arco poligonal de nueve piezas, jardineras/macetas, flores estilizadas de cuatro colores, mesa y almacén doméstico. No se atribuyen flores, herramientas agrícolas o arcos dedicados a rutas inexistentes del paquete. Arquitectura estática, sin interiores ni gameplay.

Recursos, materiales y apoyos comprobados con Godot 4.7.2 headless; ocho capturas por casa y una conjunta con Forward+/D3D12 revisadas técnicamente. Construidas técnicamente, pendientes de aprobación visual del usuario. Sin construir Huerto E10 ni modificar Jardín general.

## Uso incorporado en E12 — 2 de noviembre de 2026

`RPG/scenes/molino.tscn` reutiliza originales sin modificar de `RPG/assets/objetos_medievales/glTF/`: Bag (grano, harina y reserva), Barrel (barril sur), Crate_Wooden (caja norte), Rope_1 (cuerda en plataforma), Lantern_Wall (farol decorativo sin luz nueva). Escalas locales 0.65–0.95 para utilería y 0.45 para farol. La caja se eleva 0.055 local para corregir el mínimo negativo de su geometría importada; sacos de carga apoyados sobre plataforma a Y=0.37. Piedra usa `RPG/assets/aldea/glTF/T_UnevenBrick_BaseColor.png` con material exclusivo E12. No se alteran imágenes ni materiales compartidos.

No se identificó un modelo dedicado de rueda hidráulica; inspección de nombres locales en aldea, naturaleza y objetos medievales mantiene ese límite del inventario. Rueda, eje, soportes, muros, altillo, cubierta, entrada y plataforma se construyen con primitivas locales fuera de assets/. Rueda estática con pivote independiente X, cuatro aros segmentados, radios, paletas y herrajes; sin engranajes funcionales, animación ni agua. La pieza nueva de escena no aumenta el inventario de modelos originales: permanecen 338 glTF, los mismos paquetes, licencias pendientes y exclusión de Git.

Carga, materiales, apoyos y reservas validados con Godot 4.7.2 headless y Forward+/D3D12; ocho capturas y una contextual revisadas técnicamente. Pendiente aprobación visual del usuario y diseño de la cota/alimentación del río. No se incorporan assets nuevos de naturaleza, río o puente.

## Recursos propios de fase 4A — 2 de noviembre de 2026

`RPG/scenes/rio.tscn` y `RPG/scenes/puente.tscn` contienen geometría propia serializada de Godot, fuera de assets/: cintas trianguladas continuas de agua/orillas/canal; 35 piedras low-poly de SphereMesh; estribos, 24 tablones, vigas, postes, pasamanos y riostras. Materiales locales de piedra, tierra húmeda y dos tonos de madera; agua mediante `RPG/scripts/agua_estilizada.gdshader`, opaca y animada. No son modelos de Quaternius ni incrementan el inventario de originales.

Sin nuevos paquetes, glTF, texturas externas, dependencias o modificaciones a assets originales. Permanecen 338 glTF y la exclusión intencional de `RPG/assets/`; procedencia/licencias pendientes sin cambios. No se identificaron juncos dedicados ni se añadieron plantas ribereñas. El agua y el puente anteriormente ausentes se resuelven con recursos propios; `RPG/scripts/rueda_hidraulica.gd` anima la geometría E12 existente, sin reemplazarla. Cauce físico excavado y continuidad paisajística de extremos pendientes. Comprobados recursos y material en Godot 4.7.2 headless y Forward+/D3D12; ocho capturas técnicas, aprobación visual del usuario pendiente. Sin simulación hidráulica, navegación de NPCs ni pesca/natación.

## Uso incorporado en huertos — fase 4B.2, 2 de noviembre de 2026

Tres escenas propias: `RPG/scenes/huerto_comunitario.tscn`, `huerto_e09.tscn`, `huerto_e10.tscn`. Originales existentes de `RPG/assets/objetos_medievales/glTF/`, sin modificaciones:

| Original | Uso nuevo |
|---|---|
| Carrot.gltf | 12 zanahorias del comunitario, escalas 0.92/1.01/1.10, raíces parcialmente integradas en bancal |
| FarmCrate_Carrot.gltf | Caja de cosecha comunitario 0.95; E09 1.05; apoyo corregido por mínimo fuente Y≈-0.016 |
| Barrel.gltf | Barril del comunitario, escala 0.73, caja de colisión propia |
| Bucket_Wooden_1.gltf | Cubo de E09, escala 1.2, sin colisión extra |
| FarmCrate_Empty.gltf | Caja vacía pequeña E10, escala 0.8, sin colisión extra |
| Bag.gltf | Saco E10, escala 0.70, caja de colisión propia |

Carrot y las zanahorias de FarmCrate_Carrot tienen COLOR_0: se habilita `vertex_color_use_as_albedo` mediante materiales duplicados y overrides locales guardados en las nuevas escenas. Los glTF, BIN, texturas, materiales de origen y ejemplares de viviendas permanecen intactos. No se inventan modelos de col, calabaza, cebolla, tomatera, rastrillo o regadera: cultivos adicionales, bancales, pasos, cercas y tutores se construyen con geometría propia sencilla fuera de assets/. Las cercas originales identificadas en el inventario se consultaron; se opta por tramos propios bajos ajustados a reservas y aperturas.

Se mantienen **338 glTF originales**, mismos paquetes, exclusión intencional de Git y licencias/procedencia pendientes sin cambios. Sin dependencias, paquetes, texturas externas ni plantas de vegetación general nuevos. Son cultivos decorativos; no se incorporan etapas funcionales de crecimiento, semillas, inventario agrícola o cosecha. Recursos y materiales de las escenas finales comprobados en Godot 4.7.2 headless y Forward+/D3D12; capturas y oclusión de viviendas traseras documentadas en el estado. Pendiente aprobación visual del usuario.

## Uso incorporado en jardín — fase 4B.3, 2 de noviembre de 2026

`RPG/scenes/jardin_hierbas.tscn` reutiliza originales intactos de naturaleza: `Flower_3_Group.gltf`, `Flower_4_Group.gltf`, `Fern_1.gltf`; de objetos medievales: `Pot_1.gltf`. Tamaños locales ajustados según AABB para lectura baja dentro de 4×4. `Bush_Common.gltf` se inspeccionó y probó, pero no se incorpora en la escena final: su textura local roja resultó demasiado intensa para la composición.

Geometría propia fuera de assets/: doce flores de cinco pétalos, follaje/arbusto verde bajo, planta de maceta, tres pequeñas manchas de tierra, cinco losas y piedras de borde; materiales locales mates. Sin texturas, paquetes, dependencias ni modelos originales nuevos. Se mantienen 338 glTF originales y su exclusión intencional de Git; licencias pendientes sin cambios. Sin colisiones en plantas pequeñas ni jardinería jugable. Recursos comprobados en Godot 4.7.2 headless y Forward+/D3D12; once vistas, aprobación visual pendiente.

## Recursos propios del mirador — fase 4B.4, 2 de noviembre de 2026

`RPG/scenes/mirador.tscn` usa únicamente primitivas y materiales locales de Godot: losa de piedra, cantos de tablón, barandilla rústica, banco, farol estático y dos piedras bajas. Se consultaron los modelos locales de banco y farol, pero la reserva de 4×4 y el paso central requerían proporciones ajustadas; por ello se resolvieron con geometría propia sencilla sin atribuir rutas nuevas ni modificar originales.

No se incorporan paquetes, glTF, texturas, scripts de ejecución ni dependencias. Permanecen 338 modelos originales, su exclusión intencional de Git y las licencias/procedencia pendientes. La escena añade dos colisiones simples para mobiliario voluminoso; no añade interacción, luz dinámica, sistema para sentarse ni vegetación general.

## Uso incorporado en mercado y plaza — fase 4B.5, 2 de noviembre de 2026

`RPG/scenes/mercado.tscn` reutiliza originales intactos de objetos medievales: Stall_Cart_Empty, dos instancias de Stall_Empty, FarmCrate_Apple, FarmCrate_Carrot, FarmCrate_Empty, Barrel_Apples, Crate_Wooden y Bag. `RPG/scenes/plaza_decorada.tscn` reutiliza dos Bench y dos Pot_1. Escalas y posiciones se ajustan por instancia; no se editan glTF, BIN, texturas ni materiales fuente.

Geometría local: toldos rojo apagado/azul grisáceo/oliva, postes de dos puestos, telas dobladas y rollo; pozo pequeño con brocal, agua estática, postes y tejadillo; piedras bajas. No se atribuye al paquete un pozo, cestas, textiles o fuente inexistentes. Permanecen 338 glTF, mismos paquetes, exclusión de Git y licencias pendientes. Sin dependencias, scripts de juego, luces dinámicas, NPC, comercio o navegación.

## Recursos propios de salidas regionales — fase 4B.6, 2 de noviembre de 2026

`RPG/scenes/salidas_aldea.tscn` usa únicamente geometría local de Godot: postes, tablas, flechas, Label3D y seis piedras bajas. No se incorpora ningún glTF porque las señales requieren texto/destino y dimensiones específicas junto a corredores existentes. Sin texturas, paquetes, dependencias ni modificación de originales.

Permanecen 338 modelos glTF y su exclusión de Git. Las señales no tienen colisión; los cierres provisionales reutilizan los límites físicos ya existentes. Sin vegetación general, escenas exteriores, Area3D, transiciones o sistemas regionales funcionales.

## Uso incorporado en vegetación general — fase 4B.7, 2 de noviembre de 2026

`RPG/scenes/vegetacion_aldea.tscn` reutiliza originales intactos de `RPG/assets/naturaleza/glTF/`:

| Original | Instancias | Uso |
|---|---:|---|
| CommonTree_1.gltf | 6 | Arbolado periférico principal |
| CommonTree_3.gltf | 5 | Variación de copa y silueta |
| CommonTree_5.gltf | 5 | Variación de copa y silueta |
| Bush_Common.gltf | 9 | Sotobosque bajo |
| Bush_Common_Flowers.gltf | 9 | Acentos florales periféricos |
| Grass_Common_Short.gltf | 13 | Hierba baja dispersa |
| Grass_Wispy_Short.gltf | 7 | Hierba fina dispersa |
| Flower_3_Group.gltf | 6 | Grupos florales aislados |
| Flower_4_Group.gltf | 6 | Grupos florales aislados |
| Rock_Medium_1.gltf | 7 | Rocas de borde sin colisión |

Escalas, giros y posiciones se ajustan por instancia; no se modifican glTF, BIN, texturas ni materiales fuente. Los 16 árboles reciben cilindros simples agrupados en un cuerpo físico local; arbustos, plantas y rocas no reciben colisión. No se añaden scripts individuales, shaders, texturas, paquetes ni dependencias.

Permanecen **338 glTF originales**, su exclusión intencional de Git y las licencias/procedencia pendientes. No se incorporan árboles talados, frutas, recolección, crecimiento, viento ni interacción forestal. Carga, materiales, apoyos, distribución y rendimiento técnico comprobados con Godot 4.7.2 headless y Forward+/D3D12; aprobación visual del usuario pendiente.
