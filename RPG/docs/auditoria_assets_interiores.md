# Auditoría de assets para interiores de la aldea

Fecha: **16 de noviembre de 2026**. Alcance: inspección y documentación; no se han construido interiores.

## Resumen ejecutivo

**Hay una base sólida para las seis viviendas, la sala de la taberna, el herbolario y la carpintería. No hay un conjunto completo que resuelva los doce interiores con sus funciones y variedad sin autoría adicional.** Panadería necesita productos y utensilios de elaboración; herrería necesita completar herramientas especializadas; el molino carece de un tren de molienda interior identificado.

Se censaron **867 archivos de modelo**, correspondientes a **524 recursos canónicos**: 443 glTF, 74 GLB y siete FBX animales. Se inspeccionaron estructuralmente y se decodificaron posiciones e índices de los **517 glTF/GLB (778 primitivas)**. Los siete FBX canónicos animales se revisaron a nivel de archivo/cabecera y se contrastaron con el catálogo previo; no se decodificaron sus rigs en esta sesión. Los formatos alternativos no suman modelos nuevos.

Se seleccionan **174 candidatos para interiores**: 85 Props, 72 Village, 11 Nature, dos forestales y cuatro agrícolas. Son **163 ADAPTABLE, cinco PARCIAL y seis NO CONFIRMADO**. Este número incluye variantes, módulos de arquitectura y ornamentación; no equivale a 174 muebles diferentes ni a 174 objetos aprobados visualmente. No se concede LISTO: faltan montaje, colisiones y comprobación visual en Godot. Los 350 canónicos restantes se registran aparte, sin utilidad interior prioritaria o con utilidad secundaria.

Lo mejor cubierto es mobiliario doméstico básico, almacenaje, libros, recipientes, vajilla, luminarias decorativas y arquitectura modular. Las mayores carencias son maquinaria de molino, utensilios específicos de panadería/herrería y variedad doméstica (mesas compactas, roperos altos, textiles). **No es obligatorio descargar un paquete para empezar.** Un complemento pequeño y coherente de oficios y mobiliario doméstico variado sería útil después de validar los recursos existentes; no conviene volver a adquirir camas, sillas, vajilla, frascos, sacos o barriles ya disponibles.

## Método, fuentes y límites

Se leyeron AGENTS.md, README.md, RPG/docs/estado_proyecto.md, RPG/docs/inventario_assets.md, RPG/docs/plano_aldea.md y RPG/docs/guia_tecnica_presentacion.md. Se recorrió RPG/assets/ y se inspeccionaron las doce escenas de edificios, sus referencias, nodos y subrecursos. La cápsula de RPG/scenes/jugador.tscn mide 0,64 de diámetro y 1,60 de alto; se conserva como referencia, sin cambiarla.

AGENTS.md y estado contienen marcas de conflicto; README conserva cifras y objetivos históricos. Se priorizan archivos locales y escenas reales. El plano también conserva funciones residenciales antiguas: E10/E11 figuran como residencia de panadería/molino en un registro anterior. Para esta evaluación se siguen las identidades solicitadas: E10 granjero y E11 floral; no se cambia su asignación en el proyecto.

La inspección actual verifica JSON/chunks GLB, nodos, mallas, primitivas, materiales, URI externas, existencia de dependencias, tamaño mínimo de buffers, lectura efectiva de posiciones e índices y rango de índices. No aparecieron URI externas ausentes, buffers más cortos que lo declarado, posiciones no finitas o índices fuera de rango. Se comprobaron cabeceras/dimensiones PNG de las 51 rutas externas de imagen referenciadas; esto no verifica su apariencia ni todos los PNG sueltos. FBX se comprobó por cabecera, OBJ por presencia de vértices, Blend por firma/contenedor; no constituye equivalencia geométrica nueva entre formatos.

**No se ejecutó Godot, no hubo importación nueva, prueba headless ni revisión visual real durante esta auditoría. Ningún modelo se confirma visualmente aquí.** Los nombres se usan como identificadores, contrastados con estructura, dimensiones y usos presentes en escenas; el contenido fino y el aspecto quedan pendientes. Las comprobaciones de importación/capturas del inventario y del catálogo de granja son antecedentes, no resultados repetidos hoy. Un intento de proyección diagnóstica en memoria no llegó a generar imagen; no se presenta como evidencia visual. No se escribieron scripts ni imágenes auxiliares.

### Censo de formatos y duplicación

| Formato | Archivos físicos | Tratamiento |
|---|---:|---|
| glTF | 443 | Canónicos: Village 176, Nature 68, Props 94, KayKit 105. |
| GLB | 74 | Canónicos: Forest Nature Updated 60 y Farm_Harvest 14. |
| FBX | 231 | 210 KayKit alternativos, 14 agrícolas alternativos y siete animales canónicos. |
| OBJ | 112 | 105 KayKit y siete animales; alternativas. |
| Blend | 7 | Fuentes de los siete animales, sin importación directa actual. |
| **Total** | **867** | **524 canónicos, 343 exportaciones alternativas**. BIN/MTL/texturas no son modelos. No se encontraron DAE en el censo. |

No se deduplican variantes artísticas por parecido: dos camas o dos puertas siguen siendo dos recursos, pero no dos categorías funcionales. KayKit repite los mismos 105 nombres en cuatro exportaciones. La equivalencia entre formatos y cuatro pares de hierba con igual geometría provienen de auditorías previas; no se recalculó una equivalencia topológica global hoy. Los grupos de libros, botellas o frutas se cuentan como un recurso cada uno, no por objeto representado.

## Inventario de candidatos

Estados: **LISTO**, utilizable directamente con comprobación suficiente; **ADAPTABLE**, necesita encaje, orientación, escala o ajuste local; **PARCIAL**, solo aporta parte de la solución; **NO CONFIRMADO**, interpretación o aprovechamiento requiere inspección adicional. ADAPTABLE es una propuesta técnica provisional, no aprobación artística. Las columnas de uso señalan destinos posibles, no integración actual.

Las dimensiones son **X×Y×Z locales de las posiciones de malla, en unidades fuente**, sin componer transformaciones de nodos ni deformación de piel. Los triángulos corresponden a primitivas triangulares base, una vez por malla del recurso; no incluyen instancias, sombras ni coste de escena. En particular Axe_Bronze y Crate_Wooden tienen transformaciones de nodo, y Chest_Wood tiene skin/jerarquía: no usar sus dimensiones crudas como AABB mundial. El tamaño final de cualquier candidato debe medirse instanciado. No se ha modificado ninguno.

| Asset | Ruta exacta | Tipo de objeto | Edificios donde sirve | Estado | Observaciones: dimensiones locales; geometría; uso |
|---|---|---|---|---|---|
| Corner_Exterior_Wood | `RPG/assets/aldea/glTF/Corner_Exterior_Wood.gltf` | Estructura/cierre | E01–E12 según distribución | ADAPTABLE | 0.21×3.00×0.24; 12 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Corner_Interior_Big | `RPG/assets/aldea/glTF/Corner_Interior_Big.gltf` | Estructura/cierre | E01–E12 según distribución | ADAPTABLE | 0.33×3.00×0.37; 24 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Corner_Interior_Small | `RPG/assets/aldea/glTF/Corner_Interior_Small.gltf` | Estructura/cierre | E01–E12 según distribución | ADAPTABLE | 0.21×3.00×0.24; 12 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Door_1_Flat | `RPG/assets/aldea/glTF/Door_1_Flat.gltf` | Hoja de puerta | E01–E12 según distribución | ADAPTABLE | 1.12×2.10×0.12; 314 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Door_1_Round | `RPG/assets/aldea/glTF/Door_1_Round.gltf` | Hoja de puerta | E01–E12 según distribución | ADAPTABLE | 1.12×2.32×0.12; 470 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Door_2_Flat | `RPG/assets/aldea/glTF/Door_2_Flat.gltf` | Hoja de puerta | E01–E12 según distribución | ADAPTABLE | 1.11×2.10×0.26; 6032 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Door_2_Round | `RPG/assets/aldea/glTF/Door_2_Round.gltf` | Hoja de puerta | E01–E12 según distribución | ADAPTABLE | 1.12×2.33×0.26; 6188 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Door_4_Flat | `RPG/assets/aldea/glTF/Door_4_Flat.gltf` | Hoja de puerta | E01–E12 según distribución | ADAPTABLE | 1.12×2.09×0.21; 1044 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Door_4_Round | `RPG/assets/aldea/glTF/Door_4_Round.gltf` | Hoja de puerta | E01–E12 según distribución | ADAPTABLE | 1.11×2.32×0.21; 1228 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Door_8_Flat | `RPG/assets/aldea/glTF/Door_8_Flat.gltf` | Hoja de puerta | E01–E12 según distribución | ADAPTABLE | 1.12×2.10×0.20; 986 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Door_8_Round | `RPG/assets/aldea/glTF/Door_8_Round.gltf` | Hoja de puerta | E01–E12 según distribución | ADAPTABLE | 1.15×2.32×0.20; 1142 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| DoorFrame_Flat_Brick | `RPG/assets/aldea/glTF/DoorFrame_Flat_Brick.gltf` | Marco de puerta | E01–E12 según distribución | ADAPTABLE | 1.57×2.38×0.49; 1880 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| DoorFrame_Flat_WoodDark | `RPG/assets/aldea/glTF/DoorFrame_Flat_WoodDark.gltf` | Marco de puerta | E01–E12 según distribución | ADAPTABLE | 1.57×2.31×0.39; 56 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| DoorFrame_Round_Brick | `RPG/assets/aldea/glTF/DoorFrame_Round_Brick.gltf` | Marco de puerta | E01–E12 según distribución | ADAPTABLE | 1.60×2.59×0.48; 2046 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| DoorFrame_Round_WoodDark | `RPG/assets/aldea/glTF/DoorFrame_Round_WoodDark.gltf` | Marco de puerta | E01–E12 según distribución | ADAPTABLE | 1.41×2.56×0.54; 320 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Floor_Brick | `RPG/assets/aldea/glTF/Floor_Brick.gltf` | Suelo modular | E01–E12 según distribución | ADAPTABLE | 2.00×0.02×2.00; 4 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Floor_RedBrick | `RPG/assets/aldea/glTF/Floor_RedBrick.gltf` | Suelo modular | E01–E12 según distribución | ADAPTABLE | 2.00×0.02×2.00; 4 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Floor_UnevenBrick | `RPG/assets/aldea/glTF/Floor_UnevenBrick.gltf` | Suelo modular | E01–E12 según distribución | ADAPTABLE | 2.00×0.02×2.00; 4 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Floor_WoodDark_Half1 | `RPG/assets/aldea/glTF/Floor_WoodDark_Half1.gltf` | Suelo modular | E01–E12 según distribución | ADAPTABLE | 1.00×0.02×2.00; 32 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Floor_WoodDark_Half2 | `RPG/assets/aldea/glTF/Floor_WoodDark_Half2.gltf` | Suelo modular | E01–E12 según distribución | ADAPTABLE | 1.00×0.02×2.00; 32 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Floor_WoodDark_Half3 | `RPG/assets/aldea/glTF/Floor_WoodDark_Half3.gltf` | Suelo modular | E01–E12 según distribución | ADAPTABLE | 2.00×0.02×1.00; 16 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Floor_WoodDark_OverhangCorner | `RPG/assets/aldea/glTF/Floor_WoodDark_OverhangCorner.gltf` | Suelo modular | E01–E12 según distribución | ADAPTABLE | 1.00×0.02×1.76; 16 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Floor_WoodDark_OverhangCorner2 | `RPG/assets/aldea/glTF/Floor_WoodDark_OverhangCorner2.gltf` | Suelo modular | E01–E12 según distribución | ADAPTABLE | 0.96×0.02×1.75; 26 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Floor_WoodDark | `RPG/assets/aldea/glTF/Floor_WoodDark.gltf` | Suelo modular | E01–E12 según distribución | ADAPTABLE | 2.00×0.02×2.00; 32 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Floor_WoodLight_OverhangCorner | `RPG/assets/aldea/glTF/Floor_WoodLight_OverhangCorner.gltf` | Suelo modular | E01–E12 según distribución | ADAPTABLE | 1.00×0.02×1.76; 16 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Floor_WoodLight_OverhangCorner2 | `RPG/assets/aldea/glTF/Floor_WoodLight_OverhangCorner2.gltf` | Suelo modular | E01–E12 según distribución | ADAPTABLE | 0.96×0.02×1.75; 26 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Floor_WoodLight | `RPG/assets/aldea/glTF/Floor_WoodLight.gltf` | Suelo modular | E01–E12 según distribución | ADAPTABLE | 2.00×0.02×2.00; 32 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Prop_Chimney | `RPG/assets/aldea/glTF/Prop_Chimney.gltf` | Chimenea exterior, parcial para hogar | E01–E12 según distribución | PARCIAL | 0.95×3.18×1.00; 618 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Prop_Chimney2 | `RPG/assets/aldea/glTF/Prop_Chimney2.gltf` | Chimenea exterior, parcial para hogar | E01–E12 según distribución | PARCIAL | 0.95×3.00×0.99; 130 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Prop_Crate | `RPG/assets/aldea/glTF/Prop_Crate.gltf` | Estructura/cierre | E01–E12 según distribución | ADAPTABLE | 1.08×1.06×1.08; 230 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Prop_Support | `RPG/assets/aldea/glTF/Prop_Support.gltf` | Estructura/cierre | E01–E12 según distribución | ADAPTABLE | 0.20×1.71×2.04; 16 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Prop_WoodenFence_Extension1 | `RPG/assets/aldea/glTF/Prop_WoodenFence_Extension1.gltf` | Estructura/cierre | E01–E12 según distribución | PARCIAL | 2.05×0.84×0.11; 32 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Prop_WoodenFence_Extension2 | `RPG/assets/aldea/glTF/Prop_WoodenFence_Extension2.gltf` | Estructura/cierre | E01–E12 según distribución | PARCIAL | 2.03×0.84×0.11; 28 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Prop_WoodenFence_Single | `RPG/assets/aldea/glTF/Prop_WoodenFence_Single.gltf` | Estructura/cierre | E01–E12 según distribución | PARCIAL | 2.06×0.84×0.12; 40 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Stair_Interior_Rails | `RPG/assets/aldea/glTF/Stair_Interior_Rails.gltf` | Escalera/barandilla | E01–E12 según distribución | ADAPTABLE | 1.72×3.93×4.56; 3144 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Stair_Interior_Simple | `RPG/assets/aldea/glTF/Stair_Interior_Simple.gltf` | Escalera/barandilla | E01–E12 según distribución | ADAPTABLE | 1.68×3.03×4.62; 208 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Stair_Interior_Solid | `RPG/assets/aldea/glTF/Stair_Interior_Solid.gltf` | Escalera/barandilla | E01–E12 según distribución | ADAPTABLE | 1.77×3.05×4.71; 306 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Stair_Interior_SolidExtended | `RPG/assets/aldea/glTF/Stair_Interior_SolidExtended.gltf` | Escalera/barandilla | E01–E12 según distribución | ADAPTABLE | 1.77×3.05×6.16; 376 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Wall_Arch | `RPG/assets/aldea/glTF/Wall_Arch.gltf` | Muro/división potencial | E01–E12 según distribución | ADAPTABLE | 2.00×3.00×0.06; 196 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Wall_BottomCover | `RPG/assets/aldea/glTF/Wall_BottomCover.gltf` | Muro/división potencial | E01–E12 según distribución | ADAPTABLE | 2.00×0.24×0.43; 36 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Wall_Plaster_Door_Flat | `RPG/assets/aldea/glTF/Wall_Plaster_Door_Flat.gltf` | Muro/división potencial | E01–E12 según distribución | ADAPTABLE | 2.00×3.12×0.41; 92 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Wall_Plaster_Door_Round | `RPG/assets/aldea/glTF/Wall_Plaster_Door_Round.gltf` | Muro/división potencial | E01–E12 según distribución | ADAPTABLE | 2.00×3.12×0.41; 137 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Wall_Plaster_Door_RoundInset | `RPG/assets/aldea/glTF/Wall_Plaster_Door_RoundInset.gltf` | Muro/división potencial | E01–E12 según distribución | ADAPTABLE | 2.00×3.12×1.09; 180 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Wall_Plaster_Straight_Base | `RPG/assets/aldea/glTF/Wall_Plaster_Straight_Base.gltf` | Muro/división potencial | E01–E12 según distribución | ADAPTABLE | 2.00×3.12×0.41; 64 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Wall_Plaster_Straight_L | `RPG/assets/aldea/glTF/Wall_Plaster_Straight_L.gltf` | Muro/división potencial | E01–E12 según distribución | ADAPTABLE | 2.00×3.12×0.41; 72 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Wall_Plaster_Straight_R | `RPG/assets/aldea/glTF/Wall_Plaster_Straight_R.gltf` | Muro/división potencial | E01–E12 según distribución | ADAPTABLE | 2.00×3.12×0.41; 72 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Wall_Plaster_Straight | `RPG/assets/aldea/glTF/Wall_Plaster_Straight.gltf` | Muro/división potencial | E01–E12 según distribución | ADAPTABLE | 2.00×3.12×0.41; 86 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Wall_Plaster_Window_Thin_Round | `RPG/assets/aldea/glTF/Wall_Plaster_Window_Thin_Round.gltf` | Muro/división potencial | E01–E12 según distribución | ADAPTABLE | 2.00×3.12×0.41; 166 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Wall_Plaster_Window_Wide_Flat | `RPG/assets/aldea/glTF/Wall_Plaster_Window_Wide_Flat.gltf` | Muro/división potencial | E01–E12 según distribución | ADAPTABLE | 2.00×3.12×0.41; 96 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Wall_Plaster_Window_Wide_Flat2 | `RPG/assets/aldea/glTF/Wall_Plaster_Window_Wide_Flat2.gltf` | Muro/división potencial | E01–E12 según distribución | ADAPTABLE | 2.00×3.15×0.41; 122 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Wall_Plaster_Window_Wide_Round | `RPG/assets/aldea/glTF/Wall_Plaster_Window_Wide_Round.gltf` | Muro/división potencial | E01–E12 según distribución | ADAPTABLE | 2.00×3.12×0.41; 124 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Wall_Plaster_WoodGrid | `RPG/assets/aldea/glTF/Wall_Plaster_WoodGrid.gltf` | Muro/división potencial | E01–E12 según distribución | ADAPTABLE | 2.00×3.12×0.41; 248 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Wall_UnevenBrick_Door_Flat | `RPG/assets/aldea/glTF/Wall_UnevenBrick_Door_Flat.gltf` | Muro/división potencial | E01–E12 según distribución | ADAPTABLE | 2.00×3.12×0.41; 74 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Wall_UnevenBrick_Door_Round | `RPG/assets/aldea/glTF/Wall_UnevenBrick_Door_Round.gltf` | Muro/división potencial | E01–E12 según distribución | ADAPTABLE | 2.00×3.12×0.41; 136 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Wall_UnevenBrick_Straight | `RPG/assets/aldea/glTF/Wall_UnevenBrick_Straight.gltf` | Muro/división potencial | E01–E12 según distribución | ADAPTABLE | 2.00×3.12×0.41; 56 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Wall_UnevenBrick_Window_Thin_Round | `RPG/assets/aldea/glTF/Wall_UnevenBrick_Window_Thin_Round.gltf` | Muro/división potencial | E01–E12 según distribución | ADAPTABLE | 2.00×3.12×0.41; 158 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Wall_UnevenBrick_Window_Wide_Flat | `RPG/assets/aldea/glTF/Wall_UnevenBrick_Window_Wide_Flat.gltf` | Muro/división potencial | E01–E12 según distribución | ADAPTABLE | 2.00×3.12×0.41; 88 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Wall_UnevenBrick_Window_Wide_Round | `RPG/assets/aldea/glTF/Wall_UnevenBrick_Window_Wide_Round.gltf` | Muro/división potencial | E01–E12 según distribución | ADAPTABLE | 2.00×3.12×0.41; 116 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Window_Roof_Thin | `RPG/assets/aldea/glTF/Window_Roof_Thin.gltf` | Ventana | E01–E12 según distribución | ADAPTABLE | 0.85×1.18×1.18; 46 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Window_Roof_Wide | `RPG/assets/aldea/glTF/Window_Roof_Wide.gltf` | Ventana | E01–E12 según distribución | ADAPTABLE | 1.42×1.18×1.18; 66 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Window_Thin_Flat1 | `RPG/assets/aldea/glTF/Window_Thin_Flat1.gltf` | Ventana | E01–E12 según distribución | ADAPTABLE | 0.79×1.56×0.44; 112 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Window_Thin_Round1 | `RPG/assets/aldea/glTF/Window_Thin_Round1.gltf` | Ventana | E01–E12 según distribución | ADAPTABLE | 0.89×1.60×0.34; 418 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Window_Wide_Flat1 | `RPG/assets/aldea/glTF/Window_Wide_Flat1.gltf` | Ventana | E01–E12 según distribución | ADAPTABLE | 1.61×1.58×0.68; 160 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Window_Wide_Round1 | `RPG/assets/aldea/glTF/Window_Wide_Round1.gltf` | Ventana | E01–E12 según distribución | ADAPTABLE | 1.36×1.73×0.53; 354 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| WindowShutters_Thin_Flat_Closed | `RPG/assets/aldea/glTF/WindowShutters_Thin_Flat_Closed.gltf` | Postigo | E01–E12 según distribución | ADAPTABLE | 0.85×1.42×0.14; 96 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| WindowShutters_Thin_Flat_Open | `RPG/assets/aldea/glTF/WindowShutters_Thin_Flat_Open.gltf` | Postigo | E01–E12 según distribución | ADAPTABLE | 1.35×1.42×0.38; 96 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| WindowShutters_Thin_Round_Closed | `RPG/assets/aldea/glTF/WindowShutters_Thin_Round_Closed.gltf` | Postigo | E01–E12 según distribución | ADAPTABLE | 0.87×1.52×0.14; 112 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| WindowShutters_Thin_Round_Open | `RPG/assets/aldea/glTF/WindowShutters_Thin_Round_Open.gltf` | Postigo | E01–E12 según distribución | ADAPTABLE | 1.61×1.52×0.38; 112 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| WindowShutters_Wide_Flat_Closed | `RPG/assets/aldea/glTF/WindowShutters_Wide_Flat_Closed.gltf` | Postigo | E01–E12 según distribución | ADAPTABLE | 1.35×1.42×0.14; 120 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| WindowShutters_Wide_Flat_Open | `RPG/assets/aldea/glTF/WindowShutters_Wide_Flat_Open.gltf` | Postigo | E01–E12 según distribución | ADAPTABLE | 2.48×1.42×0.46; 120 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| WindowShutters_Wide_Round_Closed | `RPG/assets/aldea/glTF/WindowShutters_Wide_Round_Closed.gltf` | Postigo | E01–E12 según distribución | ADAPTABLE | 1.35×1.65×0.14; 136 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| WindowShutters_Wide_Round_Open | `RPG/assets/aldea/glTF/WindowShutters_Wide_Round_Open.gltf` | Postigo | E01–E12 según distribución | ADAPTABLE | 2.30×1.65×0.47; 136 tri.; Revisar cara interior, encaje, apoyo y colisión. |
| Flat_Fallen_Log | `RPG/assets/bosque/forest_nature_updated/Extras/Flat_Fallen_Log.glb` | Madera/tocón natural | E03, E04, E10, E12 | NO CONFIRMADO | 8.21×1.74×5.94; 618 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Flat_Tree_Stump | `RPG/assets/bosque/forest_nature_updated/Extras/Flat_Tree_Stump.glb` | Madera/tocón natural | E03, E04, E10, E12 | NO CONFIRMADO | 4.70×2.21×4.27; 504 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| mdvl_farm_cabbage_stage_03 | `RPG/assets/granja/Farm_Harvest/glTF/mdvl_farm_cabbage_stage_03.glb` | Producto/almacenaje agrícola candidato | E01, E02, E05–E12; E03/E04 como utilería | NO CONFIRMADO | 0.27×0.19×0.26; 1040 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| mdvl_farm_fruit_basket_01 | `RPG/assets/granja/Farm_Harvest/glTF/mdvl_farm_fruit_basket_01.glb` | Producto/almacenaje agrícola candidato | E01, E02, E05–E12; E03/E04 como utilería | NO CONFIRMADO | 0.49×0.53×0.49; 3646 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| mdvl_farm_hay_bale_01 | `RPG/assets/granja/Farm_Harvest/glTF/mdvl_farm_hay_bale_01.glb` | Producto/almacenaje agrícola candidato | E01, E02, E05–E12; E03/E04 como utilería | NO CONFIRMADO | 0.58×0.52×0.81; 332 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| mdvl_farm_milking_stool_01 | `RPG/assets/granja/Farm_Harvest/glTF/mdvl_farm_milking_stool_01.glb` | Asiento | E01, E02, E05–E12; E03/E04 como utilería | NO CONFIRMADO | 0.36×0.39×0.35; 96 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Clover_1 | `RPG/assets/naturaleza/glTF/Clover_1.gltf` | Recipiente, provisión o utilería | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 0.80×1.14×0.76; 379 tri.; Ornamental; no acredita especie medicinal/comestible. Revisar COLOR_0 y maceta separada. |
| Clover_2 | `RPG/assets/naturaleza/glTF/Clover_2.gltf` | Recipiente, provisión o utilería | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 0.85×1.26×0.84; 615 tri.; Ornamental; no acredita especie medicinal/comestible. Revisar COLOR_0 y maceta separada. |
| Fern_1 | `RPG/assets/naturaleza/glTF/Fern_1.gltf` | Planta decorativa, no hierba identificada | E05; E06–E11 como decoración | ADAPTABLE | 9.05×2.69×8.49; 288 tri.; Ornamental; no acredita especie medicinal/comestible. Revisar COLOR_0 y maceta separada. |
| Flower_3_Group | `RPG/assets/naturaleza/glTF/Flower_3_Group.gltf` | Planta decorativa, no hierba identificada | E05; E06–E11 como decoración | ADAPTABLE | 1.49×2.05×1.59; 755 tri.; Ornamental; no acredita especie medicinal/comestible. Revisar COLOR_0 y maceta separada. |
| Flower_3_Single | `RPG/assets/naturaleza/glTF/Flower_3_Single.gltf` | Planta decorativa, no hierba identificada | E05; E06–E11 como decoración | ADAPTABLE | 0.91×2.07×0.88; 285 tri.; Ornamental; no acredita especie medicinal/comestible. Revisar COLOR_0 y maceta separada. |
| Flower_4_Group | `RPG/assets/naturaleza/glTF/Flower_4_Group.gltf` | Planta decorativa, no hierba identificada | E05; E06–E11 como decoración | ADAPTABLE | 1.78×2.49×1.37; 1690 tri.; Ornamental; no acredita especie medicinal/comestible. Revisar COLOR_0 y maceta separada. |
| Flower_4_Single | `RPG/assets/naturaleza/glTF/Flower_4_Single.gltf` | Planta decorativa, no hierba identificada | E05; E06–E11 como decoración | ADAPTABLE | 1.07×2.42×0.77; 642 tri.; Ornamental; no acredita especie medicinal/comestible. Revisar COLOR_0 y maceta separada. |
| Plant_1_Big | `RPG/assets/naturaleza/glTF/Plant_1_Big.gltf` | Recipiente, provisión o utilería | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 2.89×3.76×3.13; 360 tri.; Ornamental; no acredita especie medicinal/comestible. Revisar COLOR_0 y maceta separada. |
| Plant_1 | `RPG/assets/naturaleza/glTF/Plant_1.gltf` | Recipiente, provisión o utilería | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 1.27×1.01×1.39; 120 tri.; Ornamental; no acredita especie medicinal/comestible. Revisar COLOR_0 y maceta separada. |
| Plant_7_Big | `RPG/assets/naturaleza/glTF/Plant_7_Big.gltf` | Recipiente, provisión o utilería | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 1.31×0.25×1.36; 112 tri.; Ornamental; no acredita especie medicinal/comestible. Revisar COLOR_0 y maceta separada. |
| Plant_7 | `RPG/assets/naturaleza/glTF/Plant_7.gltf` | Recipiente, provisión o utilería | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 1.05×0.25×0.96; 48 tri.; Ornamental; no acredita especie medicinal/comestible. Revisar COLOR_0 y maceta separada. |
| Anvil_Log | `RPG/assets/objetos_medievales/glTF/Anvil_Log.gltf` | Taller/herramienta | E03; E04 (soportes) | ADAPTABLE | 0.93×1.07×0.82; 3808 tri.; Yunque y tocón reunidos en una malla, tres primitivas: no son dos nodos separables. |
| Anvil | `RPG/assets/objetos_medievales/glTF/Anvil.gltf` | Taller/herramienta | E03; E04 (soportes) | ADAPTABLE | 1.08×0.56×0.40; 750 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Axe_Bronze | `RPG/assets/objetos_medievales/glTF/Axe_Bronze.gltf` | Taller/herramienta | E03, E04, E10, E12 | ADAPTABLE | 0.98×0.35×0.05; 826 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Bag | `RPG/assets/objetos_medievales/glTF/Bag.gltf` | Recipiente, provisión o utilería | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 0.66×0.80×0.54; 858 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Banner_1_Cloth | `RPG/assets/objetos_medievales/glTF/Banner_1_Cloth.gltf` | Decoración textil | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 0.81×2.25×0.06; 138 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Banner_1 | `RPG/assets/objetos_medievales/glTF/Banner_1.gltf` | Decoración textil | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 1.61×2.39×0.19; 448 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Banner_2_Cloth | `RPG/assets/objetos_medievales/glTF/Banner_2_Cloth.gltf` | Decoración textil | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 0.81×1.93×0.06; 119 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Banner_2 | `RPG/assets/objetos_medievales/glTF/Banner_2.gltf` | Decoración textil | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 1.61×2.08×0.19; 429 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Barrel_Apples | `RPG/assets/objetos_medievales/glTF/Barrel_Apples.gltf` | Recipiente, provisión o utilería | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 0.70×0.90×0.70; 2480 tri.; Conjunto de barril y contenido; no se acredita manzana suelta extraíble. |
| Barrel_Holder | `RPG/assets/objetos_medievales/glTF/Barrel_Holder.gltf` | Recipiente, provisión o utilería | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 1.36×1.26×0.74; 2676 tri.; Conjunto cuya separación funcional no está confirmada; no contarlo como barril y soporte independientes. |
| Barrel | `RPG/assets/objetos_medievales/glTF/Barrel.gltf` | Recipiente, provisión o utilería | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 0.70×0.90×0.70; 824 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Bed_Twin1 | `RPG/assets/objetos_medievales/glTF/Bed_Twin1.gltf` | Cama | E01–E12 según distribución | ADAPTABLE | 1.88×0.81×2.41; 1600 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Bed_Twin2 | `RPG/assets/objetos_medievales/glTF/Bed_Twin2.gltf` | Cama | E01–E12 según distribución | ADAPTABLE | 1.88×0.76×2.41; 1584 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Bench | `RPG/assets/objetos_medievales/glTF/Bench.gltf` | Asiento | E01–E12 según distribución | ADAPTABLE | 2.78×0.53×0.53; 404 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Book_5 | `RPG/assets/objetos_medievales/glTF/Book_5.gltf` | Libro/estante/lectura | E01–E12 según distribución | ADAPTABLE | 0.21×0.06×0.29; 96 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Book_7 | `RPG/assets/objetos_medievales/glTF/Book_7.gltf` | Libro/estante/lectura | E01–E12 según distribución | ADAPTABLE | 0.25×0.07×0.33; 724 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Book_Simplified_Single | `RPG/assets/objetos_medievales/glTF/Book_Simplified_Single.gltf` | Libro/estante/lectura | E01–E12 según distribución | ADAPTABLE | 0.06×0.27×0.21; 52 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Book_Stack_1 | `RPG/assets/objetos_medievales/glTF/Book_Stack_1.gltf` | Libro/estante/lectura | E01–E12 según distribución | ADAPTABLE | 0.28×0.21×0.23; 208 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Book_Stack_2 | `RPG/assets/objetos_medievales/glTF/Book_Stack_2.gltf` | Libro/estante/lectura | E01–E12 según distribución | ADAPTABLE | 0.27×0.20×0.23; 446 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Bookcase_2 | `RPG/assets/objetos_medievales/glTF/Bookcase_2.gltf` | Libro/estante/lectura | E01–E12 según distribución | ADAPTABLE | 1.46×2.54×0.43; 2148 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| BookGroup_Medium_1 | `RPG/assets/objetos_medievales/glTF/BookGroup_Medium_1.gltf` | Libro/estante/lectura | E01–E12 según distribución | ADAPTABLE | 1.06×0.30×0.25; 416 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| BookGroup_Medium_2 | `RPG/assets/objetos_medievales/glTF/BookGroup_Medium_2.gltf` | Libro/estante/lectura | E01–E12 según distribución | ADAPTABLE | 1.10×0.29×0.25; 468 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| BookGroup_Medium_3 | `RPG/assets/objetos_medievales/glTF/BookGroup_Medium_3.gltf` | Libro/estante/lectura | E01–E12 según distribución | ADAPTABLE | 1.04×0.29×0.25; 468 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| BookGroup_Small_1 | `RPG/assets/objetos_medievales/glTF/BookGroup_Small_1.gltf` | Libro/estante/lectura | E01–E12 según distribución | ADAPTABLE | 0.29×0.30×0.23; 104 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| BookGroup_Small_2 | `RPG/assets/objetos_medievales/glTF/BookGroup_Small_2.gltf` | Libro/estante/lectura | E01–E12 según distribución | ADAPTABLE | 0.23×0.28×0.24; 104 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| BookGroup_Small_3 | `RPG/assets/objetos_medievales/glTF/BookGroup_Small_3.gltf` | Libro/estante/lectura | E01–E12 según distribución | ADAPTABLE | 0.24×0.28×0.24; 130 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| BookStand | `RPG/assets/objetos_medievales/glTF/BookStand.gltf` | Libro/estante/lectura | E01–E12 según distribución | ADAPTABLE | 0.51×1.45×0.51; 1526 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Bottle_1 | `RPG/assets/objetos_medievales/glTF/Bottle_1.gltf` | Frasco/recipiente | E05; E06–E11 como decoración | ADAPTABLE | 0.11×0.36×0.11; 312 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Bucket_Metal | `RPG/assets/objetos_medievales/glTF/Bucket_Metal.gltf` | Recipiente, provisión o utilería | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 0.49×0.37×0.45; 540 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Bucket_Wooden_1 | `RPG/assets/objetos_medievales/glTF/Bucket_Wooden_1.gltf` | Recipiente, provisión o utilería | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 0.43×0.29×0.38; 976 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Cabinet | `RPG/assets/objetos_medievales/glTF/Cabinet.gltf` | Almacenaje/mueble | E01–E12 según distribución | ADAPTABLE | 1.36×1.00×0.36; 2388 tri.; Mueble bajo de ≈1,00 de alto; no sustituye automáticamente un ropero alto. |
| Candle_1 | `RPG/assets/objetos_medievales/glTF/Candle_1.gltf` | Luminaria decorativa | E01–E12 según distribución | ADAPTABLE | 0.09×0.13×0.11; 212 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Candle_2 | `RPG/assets/objetos_medievales/glTF/Candle_2.gltf` | Luminaria decorativa | E01–E12 según distribución | ADAPTABLE | 0.09×0.25×0.10; 210 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| CandleStick_Stand | `RPG/assets/objetos_medievales/glTF/CandleStick_Stand.gltf` | Luminaria decorativa | E01–E12 según distribución | ADAPTABLE | 0.73×1.31×0.73; 5738 tri.; 5.738 triángulos: coste alto frente al tamaño; evitar repetición excesiva. |
| CandleStick_Triple | `RPG/assets/objetos_medievales/glTF/CandleStick_Triple.gltf` | Luminaria decorativa | E01–E12 según distribución | ADAPTABLE | 0.44×0.46×0.14; 2528 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| CandleStick | `RPG/assets/objetos_medievales/glTF/CandleStick.gltf` | Luminaria decorativa | E01–E12 según distribución | ADAPTABLE | 0.26×0.16×0.18; 730 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Carrot | `RPG/assets/objetos_medievales/glTF/Carrot.gltf` | Recipiente, provisión o utilería | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 0.18×0.57×0.22; 634 tri.; COLOR_0 presente; comprobar colores de vértice sin modificar original. |
| Cauldron | `RPG/assets/objetos_medievales/glTF/Cauldron.gltf` | Recipiente, provisión o utilería | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 0.99×0.82×0.94; 2020 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Chain_Coil | `RPG/assets/objetos_medievales/glTF/Chain_Coil.gltf` | Taller/herramienta | E03; E04 (soportes) | ADAPTABLE | 1.07×0.09×0.91; 3744 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Chair_1 | `RPG/assets/objetos_medievales/glTF/Chair_1.gltf` | Asiento | E01–E12 según distribución | ADAPTABLE | 0.58×1.12×0.55; 496 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Chalice | `RPG/assets/objetos_medievales/glTF/Chalice.gltf` | Recipiente, provisión o utilería | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 0.12×0.26×0.12; 458 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Chandelier | `RPG/assets/objetos_medievales/glTF/Chandelier.gltf` | Luminaria decorativa | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 1.30×1.46×1.30; 5680 tri.; Pieza colgante de 1,46 de alto; revisar gálibo y crear iluminación aparte. |
| Chest_Wood | `RPG/assets/objetos_medievales/glTF/Chest_Wood.gltf` | Almacenaje/mueble | E01–E12 según distribución | ADAPTABLE | 1.28×0.72×0.76; 2546 tri.; Dos mallas, nodos Chest_Top/Chest_Bottom y armature: tapa/base diferenciadas; conservar jerarquía y rig. No se valida apertura. |
| Coin_Pile_2 | `RPG/assets/objetos_medievales/glTF/Coin_Pile_2.gltf` | Decoración/comercio | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 0.28×0.06×0.20; 1062 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Coin_Pile | `RPG/assets/objetos_medievales/glTF/Coin_Pile.gltf` | Decoración/comercio | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 0.20×0.07×0.15; 960 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Coin | `RPG/assets/objetos_medievales/glTF/Coin.gltf` | Decoración/comercio | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 0.07×0.07×0.01; 304 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Crate_Metal | `RPG/assets/objetos_medievales/glTF/Crate_Metal.gltf` | Recipiente, provisión o utilería | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 0.86×0.87×0.87; 2738 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Crate_Wooden | `RPG/assets/objetos_medievales/glTF/Crate_Wooden.gltf` | Recipiente, provisión o utilería | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 1.08×1.19×1.16; 1576 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| FarmCrate_Apple | `RPG/assets/objetos_medievales/glTF/FarmCrate_Apple.gltf` | Recipiente, provisión o utilería | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 0.71×0.24×0.41; 4028 tri.; Caja con contenido integrado; no sumar cada fruta como modelo. |
| FarmCrate_Carrot | `RPG/assets/objetos_medievales/glTF/FarmCrate_Carrot.gltf` | Recipiente, provisión o utilería | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 0.71×0.41×0.57; 5262 tri.; Caja y contenido integrado; COLOR_0 requiere comprobar vertex_color_use_as_albedo en material local, como huertos. |
| FarmCrate_Empty | `RPG/assets/objetos_medievales/glTF/FarmCrate_Empty.gltf` | Recipiente, provisión o utilería | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 0.71×0.24×0.41; 1928 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Lantern_Wall | `RPG/assets/objetos_medievales/glTF/Lantern_Wall.gltf` | Luminaria decorativa | E01–E12 según distribución | ADAPTABLE | 0.36×1.34×1.30; 2822 tri.; Dimensión Z≈1,30 incluye soporte; no confundirla con profundidad de la lámpara sola. Requiere luz de Godot aparte. |
| Mug | `RPG/assets/objetos_medievales/glTF/Mug.gltf` | Recipiente, provisión o utilería | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 0.19×0.18×0.15; 268 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Nightstand_Shelf | `RPG/assets/objetos_medievales/glTF/Nightstand_Shelf.gltf` | Almacenaje/mueble | E01–E12 según distribución | ADAPTABLE | 0.69×1.22×0.39; 262 tri.; Elemento estrecho de 1,22 de alto; no asumir mesilla baja convencional. |
| Peg_Rack | `RPG/assets/objetos_medievales/glTF/Peg_Rack.gltf` | Almacenaje/mueble | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 1.18×0.35×0.10; 712 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Pickaxe_Bronze | `RPG/assets/objetos_medievales/glTF/Pickaxe_Bronze.gltf` | Taller/herramienta | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 0.81×1.20×0.14; 776 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Pot_1_Lid | `RPG/assets/objetos_medievales/glTF/Pot_1_Lid.gltf` | Recipiente, provisión o utilería | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 0.54×0.28×0.49; 1292 tri.; Recurso de 0,28 de alto; no se certifica que sea solo una tapa extraíble; revisar visualmente antes de combinar. |
| Pot_1 | `RPG/assets/objetos_medievales/glTF/Pot_1.gltf` | Recipiente, provisión o utilería | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 0.54×0.22×0.49; 1068 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Potion_1 | `RPG/assets/objetos_medievales/glTF/Potion_1.gltf` | Frasco/recipiente | E05; E06–E11 como decoración | ADAPTABLE | 0.11×0.14×0.11; 440 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Potion_2 | `RPG/assets/objetos_medievales/glTF/Potion_2.gltf` | Frasco/recipiente | E05; E06–E11 como decoración | ADAPTABLE | 0.13×0.26×0.13; 472 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Potion_4 | `RPG/assets/objetos_medievales/glTF/Potion_4.gltf` | Frasco/recipiente | E05; E06–E11 como decoración | ADAPTABLE | 0.15×0.20×0.15; 536 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Pouch_Large | `RPG/assets/objetos_medievales/glTF/Pouch_Large.gltf` | Recipiente, provisión o utilería | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 0.23×0.16×0.12; 730 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Rope_1 | `RPG/assets/objetos_medievales/glTF/Rope_1.gltf` | Recipiente, provisión o utilería | E03, E04, E10, E12 | ADAPTABLE | 0.56×0.10×0.61; 1748 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Rope_2 | `RPG/assets/objetos_medievales/glTF/Rope_2.gltf` | Recipiente, provisión o utilería | E03, E04, E10, E12 | ADAPTABLE | 0.81×0.12×0.85; 1460 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Rope_3 | `RPG/assets/objetos_medievales/glTF/Rope_3.gltf` | Recipiente, provisión o utilería | E03, E04, E10, E12 | ADAPTABLE | 1.23×0.10×0.95; 1748 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Scroll_1 | `RPG/assets/objetos_medievales/glTF/Scroll_1.gltf` | Libro/estante/lectura | E05; E06–E11 como decoración | ADAPTABLE | 0.24×0.06×0.06; 512 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Scroll_2 | `RPG/assets/objetos_medievales/glTF/Scroll_2.gltf` | Libro/estante/lectura | E05; E06–E11 como decoración | ADAPTABLE | 0.23×0.06×0.06; 672 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Shelf_Arch | `RPG/assets/objetos_medievales/glTF/Shelf_Arch.gltf` | Almacenaje/mueble | E01–E12 según distribución | ADAPTABLE | 1.25×1.59×0.31; 1286 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Shelf_Simple | `RPG/assets/objetos_medievales/glTF/Shelf_Simple.gltf` | Almacenaje/mueble | E01–E12 según distribución | ADAPTABLE | 1.18×0.31×0.29; 480 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Shelf_Small_Bottles | `RPG/assets/objetos_medievales/glTF/Shelf_Small_Bottles.gltf` | Almacenaje/mueble | E01–E12 según distribución | ADAPTABLE | 1.14×0.65×0.28; 5234 tri.; Estante y contenido reunidos en una malla; tres primitivas no prueban frascos editables individualmente. |
| SmallBottle | `RPG/assets/objetos_medievales/glTF/SmallBottle.gltf` | Frasco/recipiente | E05; E06–E11 como decoración | ADAPTABLE | 0.06×0.12×0.05; 130 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| SmallBottles_1 | `RPG/assets/objetos_medievales/glTF/SmallBottles_1.gltf` | Frasco/recipiente | E05; E06–E11 como decoración | ADAPTABLE | 0.22×0.15×0.06; 486 tri.; Conjunto de frascos en una sola malla/primitiva; usar Bottle_1 o SmallBottle para frascos independientes. |
| Stool | `RPG/assets/objetos_medievales/glTF/Stool.gltf` | Asiento | E01–E12 según distribución | ADAPTABLE | 0.47×0.59×0.47; 152 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Table_Fork | `RPG/assets/objetos_medievales/glTF/Table_Fork.gltf` | Recipiente, provisión o utilería | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 0.05×0.01×0.26; 108 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Table_Knife | `RPG/assets/objetos_medievales/glTF/Table_Knife.gltf` | Recipiente, provisión o utilería | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 0.04×0.01×0.29; 54 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Table_Large | `RPG/assets/objetos_medievales/glTF/Table_Large.gltf` | Mesa/banco o componente | E01–E12 según distribución | ADAPTABLE | 2.85×0.81×1.10; 986 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Table_Plate | `RPG/assets/objetos_medievales/glTF/Table_Plate.gltf` | Recipiente, provisión o utilería | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 0.33×0.02×0.34; 172 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Table_Spoon | `RPG/assets/objetos_medievales/glTF/Table_Spoon.gltf` | Recipiente, provisión o utilería | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 0.05×0.02×0.27; 164 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Torch_Metal | `RPG/assets/objetos_medievales/glTF/Torch_Metal.gltf` | Luminaria decorativa | E01–E12 según distribución | ADAPTABLE | 0.22×0.65×0.39; 970 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Vase_2 | `RPG/assets/objetos_medievales/glTF/Vase_2.gltf` | Recipiente, provisión o utilería | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 0.69×0.52×0.69; 598 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| Vase_4 | `RPG/assets/objetos_medievales/glTF/Vase_4.gltf` | Recipiente, provisión o utilería | E01, E02, E05–E12; E03/E04 como utilería | ADAPTABLE | 0.36×0.49×0.36; 598 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |
| WeaponStand | `RPG/assets/objetos_medievales/glTF/WeaponStand.gltf` | Taller/herramienta | E03; E04 (soportes) | ADAPTABLE | 1.39×1.11×0.98; 2084 tri.; Soporte de armas reutilizable para herramientas con adaptación; no acredita herramientas incluidas. |
| Whetstone | `RPG/assets/objetos_medievales/glTF/Whetstone.gltf` | Taller/herramienta | E03; E04 (soportes) | ADAPTABLE | 1.14×1.17×0.90; 1100 tri.; Piedra de afilar con soporte; NO es piedra de molino. |
| Workbench_Drawers | `RPG/assets/objetos_medievales/glTF/Workbench_Drawers.gltf` | Mesa/banco o componente | E03, E04, E10, E12 | ADAPTABLE | 0.42×0.24×0.30; 364 tri.; Pieza pequeña de cajones (0,42 m de ancho); no es un segundo banco de trabajo completo. |
| Workbench | `RPG/assets/objetos_medievales/glTF/Workbench.gltf` | Mesa/banco o componente | E03, E04, E10, E12 | ADAPTABLE | 2.02×0.89×1.02; 1368 tri.; Geometría presente; función propuesta pendiente de confirmación visual y escala en escena. |

## Geometría propia existente que puede reutilizarse

Estos recursos están **dentro de escenas**, no en paquetes independientes. No se añaden al recuento de 174 modelos. Se inspeccionaron nodos, asignaciones de mesh y subrecursos: su existencia geométrica no demuestra apariencia ni funcionamiento. Una futura extracción requiere conservar materiales, transformaciones y colisiones pertinentes, sin instanciar el edificio exterior completo para obtener una herramienta. No se extrajo nada en esta tarea.

| Asset/conjunto | Ruta exacta y nodos | Uso | Estado | Evidencia y límites |
|---|---|---|---|---|
| Horno de panadería | RPG/scenes/panaderia.tscn → Horno | E02; adaptar hogar en E01/viviendas | PARCIAL | HornoBase, HornoCampana, Boca, DintelHorno, Conducto, Corona, leña y arcos con MeshInstance3D/subrecursos; base con colisión. Es una composición exterior, no horno interior listo. |
| Forja y martillo | RPG/scenes/herreria.tscn → Forja y Herramientas | E03 | PARCIAL | BaseFragua, FondoHogar, jambas, campana, chimenea, carbón/brasas; MangoMartillo y CabezaMartillo separados. No confundir ausencia de glTF dedicado con ausencia de representación. |
| Sierra, mazo, cepillo y escuadra | RPG/scenes/carpinteria.tscn → Herramientas | E04 | PARCIAL | SierraHoja/SierraArco/uniones; MangoMazo/CabezaMazo; Cepillo/HojaCepillo; EscuadraA/B. Piezas primitivas con mesh asignada, no kit de herramientas exportado. |
| Tablones/troncos y soportes | RPG/scenes/carpinteria.tscn → Almacen | E04; E03/E12 | PARCIAL | Tronco0–5, VigaLarga0–2 y soportes; hay colisión de pila. Reutilizar autoría antes de buscar madera externa. |
| Mesa de preparación y mortero | RPG/scenes/herbolario.tscn → MesaPreparacion | E05; mesa en E02 | PARCIAL | Tablero, patas, Mortero, HuecoMortero y ManoMortero; hueco representado por otra malla, no cavidad funcional certificada. Frascos es instancia SmallBottles_1. |
| Macetas, flores y jardineras | RPG/scenes/herbolario.tscn → Entrada; RPG/scenes/vivienda_e11.tscn → Exterior | E05/E11; viviendas | PARCIAL | Mallas propias de macetas/flores/hojas; materiales locales. No es un modelo botánico medicinal ni una colección independiente. |
| Mesa exterior compacta y leñera | RPG/scenes/vivienda_sur.tscn → Galeria/Mesa y Lenera; RPG/scenes/vivienda_suroeste.tscn → Lenera | E06–E11 | PARCIAL | Alternativa de geometría simple a reducir Table_Large; conservar escalas de utensilios y alturas de uso. |
| Rueda y eje hidráulico | RPG/scenes/molino.tscn → MecanismoHidraulico/RuedaHidraulicaPivot | E12, referencia constructiva | PARCIAL | Aros, Radios, Paletas y EjeVisual con piezas serializadas. No acredita engranajes, tolva ni piedras de molienda interiores. No mover ni alterar el mecanismo actual. |

## Disponibilidad por edificio

ALTA significa que existen los muebles esenciales o representaciones locales aprovechables para su función; MEDIA, base útil con elementos característicos aún por crear; BAJA, falta el elemento funcional principal. **No son porcentajes ni certificación de un interior terminado.** Se evalúa ambientación estática; entrar en edificios, colisiones interiores, visibilidad y transiciones quedan fuera de esta tarea. “Reutilizar” significa duplicar instancias o adaptar composiciones en una futura tarea, sin retirar nada del exterior.

| Edificio | Assets disponibles | Elementos faltantes | Cobertura estimada |
|---|---|---|---|
| E01 — Taberna; RPG/scenes/taberna.tscn | Table_Large, Chair_1, Bench, Stool, Barrel/Holder, Mug, Chalice, vajilla, Cauldron, estantes, camas y luminarias; ya hay mesa/banco/jarra en exterior | Barra y trasbarra compactas; hogar interior y comida servida; adaptar horno doméstico | **ALTA para sala y dormitorio básicos**: mesas, asientos, bebida y descanso cubiertos; cocina/barra requieren autoría sencilla. Identidad distinta viable. |
| E02 — Panadería; RPG/scenes/panaderia.tscn | Horno propio, Bag, barriles, cajas; reutilizar Workbench como preparación, estantes, vajilla y cesta agrícola candidata | Hogazas/panes, masa, pala de horno, rodillo y artesa; no se identificó kit dedicado | **MEDIA**: horno y almacenaje reconocibles, pero la exposición/elaboración de pan no está cubierta por cajas y sacos. |
| E03 — Herrería; RPG/scenes/herreria.tscn | Anvil/Anvil_Log, Whetstone, Workbench, cubo, cadena; forja y martillo propios; Peg_Rack/WeaponStand adaptables | Tenazas, fuelle, metal en proceso y lingotes; ampliar variedad de herramientas | **MEDIA**: ya es reconocible mediante forja/yunque; completar estación de forja, no comprar otro yunque por defecto. |
| E04 — Carpintería; RPG/scenes/carpinteria.tscn | Workbench, Axe_Bronze, cuerda, cajas; sierra/mazo/cepillo/escuadra y madera propios | Prensa/tornillo de banco y virutas, tabla de proyectos/planos opcional | **ALTA para taller estático**: herramientas características y madera presentes al incluir geometría propia. Diferenciación clara de herrería. |
| E05 — Herbolario; RPG/scenes/herbolario.tscn | Frascos individuales y grupos, Potion, estantes, libros, Cauldron, plantas ornamentales; mesa y mortero propios | Manojos de hierbas secas identificables, bandejas de secado y etiquetas; especies medicinales no acreditadas | **ALTA para botica fantástica estática**: recipientes/preparación/consulta cubiertos; herbolario botánico detallado exige complementos. |
| E06 — Vivienda noroeste; RPG/scenes/vivienda_noroeste.tscn | Dos camas variantes, Cabinet, Chest_Wood, Nightstand_Shelf, asientos, estantes y vajilla; compartir mesa/hogar de otras composiciones | Mesa pequeña, hogar doméstico, ropero alto y textiles variados | **ALTA para vivienda modesta**: dormir/comer/guardar cubiertos; vestirla con libros/herramientas artesanas la diferencia. |
| E07 — Vivienda noreste; RPG/scenes/vivienda_noreste.tscn | Mismo fondo doméstico, Bookcase_2, libros, banco y cubos; arquitectura propia de dos niveles | Distribución familiar, escalera/descansillo que quepan y camas con diversidad; más textiles | **ALTA de mobiliario, condicionada al encaje de dos plantas**: no se afirma que una escalera de más de 4,5 de fondo entre en la huella compacta. |
| E08 — Vivienda suroeste; RPG/scenes/vivienda_suroeste.tscn | Fondo doméstico, Bag, FarmCrate_Carrot, cubo; leñera y herramienta exterior propias | Fogón/hogar interior, mesa compacta y pequeños enseres de cocina | **ALTA para hogar rural básico**: estilo rústico con madera y utensilios; repetición doméstica mitigable por composición. |
| E09 — Vivienda sur; RPG/scenes/vivienda_sur.tscn | Fondo doméstico, Pot_1, verduras, saco; mesa/galería propia como referencia | Más almacenamiento compacto, textiles y cocina local | **ALTA para vivienda modesta**: puede diferenciarse por conservas/huerto y galería; no hay variedad ilimitada de muebles. |
| E10 — Vivienda del granjero; RPG/scenes/vivienda_e10.tscn | Fondo doméstico, sacos, cubos, cajas agrícolas; cesta/taburete/paja Farm_Harvest candidatos | Aperos de interior (horca/azada), semillas etiquetadas; algunas herramientas rurales se pueden construir | **ALTA para casa rural**: dormir/comer/almacenar cubiertos, carácter agrícola mediante suministros; no equivale a granja funcional. |
| E11 — Vivienda floral; RPG/scenes/vivienda_e11.tscn | Fondo doméstico, Vase_2/4, plantas Nature y macetas/flores propias; mesa exterior como referencia | Flores cortadas/arreglos, textiles florales y variedad de maceteros | **ALTA para hogar floral básico**: jardín y recipientes aportan identidad; composición y materiales locales evitan repetir E06. |
| E12 — Molino; RPG/scenes/molino.tscn | Bag, Barrel, Crate_Wooden, Lantern_Wall, Rope_1; rueda/eje exteriores propios, madera y bancos reutilizables | Piedras de molienda, bancada, tolva, canal de grano/harina, transmisión y engranajes interiores | **BAJA**: almacén y energía exterior no representan molienda. Whetstone no sustituye una muela de molino. |

## Recursos faltantes y decisión de obtención

“Faltante” significa sin recurso dedicado identificado o sin solución interior lista. Cuando existe una representación en escenas se indica reutilización, evitando pedir un paquete para reemplazarla. No se comprobó visualmente cada silueta, por lo que las ausencias de detalle fino deben confirmarse antes de comprar.

| Prioridad | Necesidad y destino | Solución aconsejada | Lo existente que evita duplicación |
|---|---|---|---|
| Alta | Tren de molienda E12: dos muelas, tolva, bancada, conducto de harina y transmisión | Construir cilindros/cajas/ejes estáticos en Godot para versión estilizada; buscar conjunto externo coherente si se desea engranaje detallado y mecánica legible | Rueda/eje exteriores, sacos y almacenaje ya existen; no volver a adquirirlos. |
| Alta | Panes, masa y preparación E02 | Hogazas con mallas sencillas y artesa/pala/rodillo con primitivas; externo si se necesita comida variada de cerca | Horno propio y Workbench cubren estructura y banco; la cesta agrícola es candidata, no cesta vacía certificada. |
| Alta | Tenazas/fuelle E03 | Tenazas y lingotes con geometría simple; fuelle externo o autoría específica por su silueta | Reutilizar forja, martillo, yunque, cubo y afiladora presentes. |
| Alta | Hogar/cocina interior de viviendas y E01 | Adaptar horno/forja existentes y crear hogar pequeño con campana; comprobar que no sea solo chimenea exterior | Prop_Chimney/2 aportan conducto exterior; Pot_1, Cauldron y vajilla ya existen. |
| Alta | Barra de taberna y mostrador de panadería | Cajas/tableros y material local en Godot; conservar altura y espacio de paso | Table_Large, Cabinet y Shelf_Simple como referencia, sin deformar desproporcionadamente utensilios. |
| Media | Mesa compacta, escritorio y ropero alto | Mesa/escritorio sencillos en Godot; armario alto externo si se busca detalle/variedad | Cabinet es bajo; Nightstand_Shelf no garantiza mesilla convencional; adaptar mesa propia de E09/E11. |
| Media | Hierbas colgadas/secas y bandejas E05 | Composición low-poly propia o pequeño complemento botánico con especies legibles | Frascos, libros, mortero y plantas ornamentales ya están. No identificar un helecho como hierba medicinal. |
| Media | Prensa y piezas de trabajo E04 | Cajas/cilindros para prensa, recortes y virutas simples | Sierra, mazo, cepillo, escuadra, tablones y troncos propios ya presentes. |
| Media | Aperos E10, cestas vacías y provisiones domésticas diversas | Reutilizar referencias rurales y cesta Farm_Harvest tras revisión; primitivas para horca/azada; externo solo para detalle adicional | No recomendar descargar sacos, barriles ni una cesta con fruta antes de inspeccionar la candidata existente. |
| Media | Alfombras, mantas, cortinas, cojines y tapices domésticos | Planos/mallas simples con materiales propios para versión básica; pequeño paquete textil si se necesita variedad | Banner_1/2 y Cloth son estandartes; adaptables como paños, no alfombras domésticas certificadas. |
| Media | Escalera compacta/divisiones de E07 | Diseño específico con geometría de Godot tras medir la escena | Stair_Interior_* existen pero son largos; no pedir escaleras por ausencia de archivo. |
| Baja | Cuadros, etiquetas, letreros interiores y arreglos florales | Marcos/cajas y planos en Godot; combinar flores/macetas existentes | No hay cuadros identificados como tales; libros, pergaminos y estandartes aportan decoración. |
| Baja | Comida secundaria, jarras grandes y cacerolas adicionales | Reutilizar Mug, Bottle_1, Vase_2/4, Pot_1/Cauldron según silueta; complemento externo solo tras revisión | Hay bebida, vajilla, verduras y recipiente; jarra con asa/pico y sartén no están acreditadas. |

## Calidad y compatibilidad

### Escala y orientación

La escala típica de muebles es compatible en principio con personaje de 1,60: Chair_1 ≈0,58×1,12×0,55, Stool ≈0,47×0,59×0,47, Table_Large ≈2,85×0,81×1,10 y Workbench ≈2,02×0,89×1,02 en coordenadas de malla. Cada cama ocupa ≈1,88×2,41 en planta; encajar cama, mesa y pasillos en cuerpos 4×4 exige distribución cuidadosa. No escalar al protagonista para ganar espacio.

Los suelos completos son módulos ≈2×2, grosor visual ≈0,02. Los muros son aproximadamente 2 de ancho y 3,12 de alto. Door_1_Flat ≈1,12×2,10 es dimensión exterior de hoja, no paso libre certificado. Stair_Interior_Simple llega a ≈4,62 de fondo; SolidExtended ≈6,16. La barandilla Rails alcanza ≈3,93 de alto en coordenadas fuente. No asumir que sirven sin rediseño en E07.

La altura fuente suele estar en Y; herramientas pueden venir acostadas, con rotación/escala de nodo. Orientación frontal, pivotes de apoyo y alineación fina no se validaron visualmente. Se recomienda una futura prueba de muebles con el protagonista original, sin alterar aún cámara ni controles.

### Materiales, texturas y estilo

Los Props inspeccionados incluyen materiales trim PBR (por ejemplo MI_Trim_Furniture, MI_Trim_Metal y MI_Trim_Props) con referencias a texturas base/normal/metallic-roughness y uso frecuente de doubleSided. No basta con que la URI exista: UV, brillo, normales, transparencia y lectura a cámara 15 siguen pendientes de render. Hay COLOR_0 en numerosos muebles, objetos y plantas; no es una particularidad exclusiva de las zanahorias. Revisar cómo lo usa el material importado y, si se necesita, hacer overrides locales posteriores sin editar fuentes.

Village/Props son la base más consistente entre sí por materiales y diseño. Nature puede aportar macetas/flores con ajustes locales. Farm_Harvest usa paleta embebida y puede contrastar con los trims texturados; los dos recursos forestales propuestos requieren confirmar escala, color y acabado. Se puede mantener una estética low-poly si se unifican densidad aparente, rugosidad, color y proporciones mediante instancias/materiales locales autorizados en otra fase. No se certifica mezcla visual hoy.

Hay modelos muy económicos (Stool 152 triángulos, Chair_1 496, Table_Large 986, Workbench 1.368) y utilería más costosa (Shelf_Small_Bottles 5.234, Chandelier 5.680, CandleStick_Stand 5.738). Un estilo low-poly no garantiza bajo coste al repetir decenas de objetos pequeños. No se midieron FPS ni presupuesto de GPU; escoger detalle según distancia y reutilizar mallas/materiales.

### Submallas, separación y colisiones

Entre Village y Props solo Chest_Wood presenta más de una malla en el archivo: dos mallas con nodos y skin. Su tapa y base se distinguen estructuralmente, pero abrirlo/extraerlas preservando deformación no se probó. No asumir animación operativa.

Anvil_Log, Shelf_Small_Bottles, Barrel_Apples y FarmCrate_* son una malla con varias primitivas; normalmente estas separan materiales, no objetos editables. No hay nodos independientes que permitan retirar con seguridad cada fruta, frasco o tocón. SmallBottles_1 es incluso una sola primitiva. Utilizar los modelos individuales cuando existen (Anvil, Bottle_1, SmallBottle, Carrot, FarmCrate_Empty); separar geometría sería trabajo posterior sobre una copia, fuera del alcance actual.

Los glTF/GLB son recursos de representación; la lectura actual no certifica cuerpos/colisiones importadas. El inventario histórico informa cero CollisionShape3D en los 338 Quaternius. Las colisiones añadidas en edificios están en escenas envolventes y no viajan automáticamente con un mueble glTF. Prever cajas/cápsulas simplificadas para muebles grandes y suelo; utensilios pequeños pueden ser decorativos sin colisión. No usar una caja del edificio completo como colisión de interior ni confundir suelos de cuatro triángulos con suelo físico cerrado.

### Riesgos al implementar después

Las escenas actuales son exteriores con puertas/cierres físicos; no son interiores transitables. Hay que resolver encaje, pasos, interacción de puertas o transición a escenas independientes y oclusión desde la cámara orbital en una tarea específica. No se modificaron esos sistemas. Las luces dibujadas por un farol o vela no acreditan Light3D ni llama animada. Las formas del horno/forja/mortero son decorativas; no implementan cocción, forja o preparación.

No hay fallo nuevo de importación demostrado; tampoco se repitió una importación. Los antecedentes de OBJ/MTL, Blend sin prueba directa, certificados y caché pertenecen a los informes previos, no a una ejecución actual. Conservar glTF/BIN/texturas juntos y usar las rutas canónicas. Las licencias deben seguir las fuentes locales documentadas: no extender CC0 de KayKit/Farm_Harvest/animales a todos los paquetes; Forest Nature Updated tiene condiciones propias y restricciones de redistribución.

## Recomendaciones de reutilización y complemento

1. Empezar por una vivienda y una sala de taberna para validar escala de camas, asientos, almacenaje y circulación; después reutilizar una biblioteca doméstica común variando distribución, oficios, textiles y plantas. Esto es recomendación, no implementación autorizada.
2. Priorizar Props/Village; no tratar 174 candidatos como lista que deba instanciarse completa. Reutilizar recursos entre edificios mediante instancias futuras; conservar los exteriores y originales.
3. Aprovechar el horno, forja, mortero y herramientas primitivas ya creadas. Convertirlos más adelante en escenas propias solo si una tarea lo autoriza; verificar owners/materiales/colisiones y no ejecutar herramientas de regeneración para esta auditoría.
4. Para el molino, diseñar primero una cadena visual coherente de energía a molienda; sacos/barriles no compensan la ausencia de muelas y tolva. La rueda actual es referencia y debe permanecer intacta.
5. Si se decide obtener un paquete, la especificación más útil es **utilería medieval de oficios con molino/panadería/herrería**, complementada por muebles domésticos compactos y textiles. Preferir glTF/GLB con piezas separadas, pivotes claros, medidas coherentes, materiales PBR mates o paleta compatible y licencia verificable. Evitar paquetes dominados por armas, edificios exteriores, barriles/cajas o naturaleza ya cubierta. No se investigó ni recomendó un producto comercial concreto ni se descargó nada.

## Evaluación final

1. **¿Suficientes para los doce interiores?** Para iniciar todos y completar muchos ambientes básicos, sí; para doce interiores visualmente completos y funcionalmente diferenciados sin añadir geometría, no. Falta maquinaria y utilería específica.
2. **¿Casi completos con lo existente?** E01 sala/dormitorio, E04 y E05 incluyendo geometría propia, y E06–E11 como viviendas modestas. Necesitan composición, cocina/barra o detalles y comprobación visual, no un nuevo juego completo de muebles.
3. **¿Quién necesita más recursos?** E12 primero; después E02 y E03. Su cobertura no se deduce del número de cajas o de decoración.
4. **¿Qué categorías faltan?** Molienda/transmisión, elaboración de pan, tenazas/fuelle, muebles domésticos compactos/variados y textiles. No faltan por completo camas, sillas, armarios bajos, estantes, mortero, vajilla ni iluminación decorativa.
5. **¿Estética consistente?** Viable con Props/Village como núcleo y control de escala/materiales; combinación visual no confirmada en esta sesión.
6. **¿Descargar mobiliario medieval es necesario?** No para comenzar; geometría simple y reutilización permiten avanzar. Es aconsejable un complemento selectivo si se busca detalle y variedad con menos autoría manual.
7. **¿Qué paquete complementa mejor?** Uno pequeño de talleres/cocina/molino y textiles/muebles compactos, con piezas independientes; elegir según los huecos comprobados, sin comprar de nuevo lo que ya existe.

## Anexo: canónicos no seleccionados como base interior

Este anexo completa el censo de 524 sin sumar formatos alternativos. “Secundario” no significa imposible de reutilizar: rocas, hongos, animales o armas pueden ambientar un caso especial, pero no sustituyen mobiliario esencial. Los tejados y piezas de fachada no constituyen suelos/divisiones interiores listos. Su geometría glTF/GLB también se decodificó; los siete animales tienen solo revisión de archivo actual y antecedentes del catálogo de granja.

| Ruta exacta | Clasificación para esta tarea |
|---|---|
| `RPG/assets/aldea/glTF/Balcony_Cross_Corner.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Balcony_Cross_Straight.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Balcony_Simple_Corner.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Balcony_Simple_Straight.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Corner_ExteriorWide_Brick.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Corner_ExteriorWide_Wood.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Corner_Exterior_Brick.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Corner_Exterior_TopDown.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Corner_Exterior_TopOnly.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/HoleCover_90Angle.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/HoleCover_90Half.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/HoleCover_90Stairs.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/HoleCover_Straight.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/HoleCover_StraightHalf.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Overhang_Plaster_Corner.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Overhang_Plaster_Corner_Front.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Overhang_Plaster_Long.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Overhang_Plaster_Short.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Overhang_RoofIncline_Plaster.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Overhang_RoofIncline_UnevenBricks.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Overhang_Roof_Plaster.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Overhang_Roof_UnevenBricks.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Overhang_Side_Plaster_Long_L.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Overhang_Side_Plaster_Long_R.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Overhang_Side_Plaster_Short_L.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Overhang_Side_Plaster_Short_R.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Overhang_Side_UnevenBrick_Long_L.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Overhang_Side_UnevenBrick_Long_R.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Overhang_Side_UnevenBrick_Short_L.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Overhang_Side_UnevenBrick_Short_R.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Overhang_UnevenBrick_Corner.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Overhang_UnevenBrick_Corner_Front.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Overhang_UnevenBrick_Long.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Overhang_UnevenBrick_Short.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Prop_Brick1.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Prop_Brick2.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Prop_Brick3.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Prop_Brick4.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Prop_ExteriorBorder_Corner.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Prop_ExteriorBorder_Straight1.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Prop_ExteriorBorder_Straight2.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Prop_MetalFence_Ornament.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Prop_MetalFence_Simple.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Prop_Vine1.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Prop_Vine2.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Prop_Vine4.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Prop_Vine5.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Prop_Vine6.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Prop_Vine9.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Prop_Wagon.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_2x4_RoundTile.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_Dormer_RoundTile.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_FrontSupports.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_Front_Brick2.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_Front_Brick4.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_Front_Brick4_Half_L.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_Front_Brick4_Half_R.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_Front_Brick6.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_Front_Brick6_Half_L.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_Front_Brick6_Half_R.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_Front_Brick8.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_Front_Brick8_Half_L.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_Front_Brick8_Half_R.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_Log.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_Modular_RoundTiles.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_RoundTiles_4x4.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_RoundTiles_4x6.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_RoundTiles_4x8.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_RoundTiles_6x10.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_RoundTiles_6x12.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_RoundTiles_6x14.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_RoundTiles_6x4.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_RoundTiles_6x6.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_RoundTiles_6x8.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_RoundTiles_8x10.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_RoundTiles_8x12.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_RoundTiles_8x14.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_RoundTiles_8x8.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_RoundTile_2x1.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_RoundTile_2x1_Long.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_Support2.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_Tower_RoundTiles.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_Wooden_2x1.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_Wooden_2x1_Center.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_Wooden_2x1_Center_Mirror.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_Wooden_2x1_Corner.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_Wooden_2x1_L.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_Wooden_2x1_Middle.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Roof_Wooden_2x1_R.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Stairs_Exterior_NoFirstStep.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Stairs_Exterior_Platform.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Stairs_Exterior_Platform45.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Stairs_Exterior_Platform45Clean.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Stairs_Exterior_PlatformU.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Stairs_Exterior_SidePlatform.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Stairs_Exterior_Sides.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Stairs_Exterior_Sides45.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Stairs_Exterior_SidesU.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Stairs_Exterior_SingleSide.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Stairs_Exterior_SingleSideThick.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Stairs_Exterior_Straight.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Stairs_Exterior_Straight_Center.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Stairs_Exterior_Straight_L.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/aldea/glTF/Stairs_Exterior_Straight_R.gltf` | Exterior/cubierta u ornamento arquitectónico; reutilización interior específica no acreditada. |
| `RPG/assets/bosque/forest_nature_updated/Bushes/Flat_Bush_Clumps_large.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Bushes/Flat_Bush_Clumps_medium.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Bushes/Flat_Bush_Clumps_small.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Bushes/Flat_Bush_large.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Bushes/Flat_Bush_medium.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Bushes/Flat_Bush_small.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Bushes/Flat_Bush_with_Flowers.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Extras/Flat_Flowers_red.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Extras/Flat_Forest_Ground.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Grass/Flat_Grass_large.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Grass/Flat_Grass_medium.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Grass/Flat_Grass_small.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Mushrooms/Flat_Mushroom_Brown_large.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Mushrooms/Flat_Mushroom_Brown_medium.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Mushrooms/Flat_Mushroom_Brown_small.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Mushrooms/Flat_Mushroom_Red_large.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Mushrooms/Flat_Mushroom_Red_small.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Rocks/Flat_Boulder_01.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Rocks/Flat_Boulder_02.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Rocks/Flat_Boulder_03.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Rocks/Flat_Rock_01.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Rocks/Flat_Rock_02.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Rocks/Flat_Rock_03.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Rocks/Flat_Rock_04.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Rocks/Flat_Rock_05.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Rocks/Flat_Rock_06.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Rocks/Flat_Rock_07.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Rocks/Flat_Rock_08.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Rocks/Flat_Rock_09.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Rocks/Flat_Rock_10.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Trees/Birch/Flat_Tree_Birch_hero_green.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Trees/Birch/Flat_Tree_Birch_large_green.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Trees/Birch/Flat_Tree_Birch_medium_green.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Trees/Birch/Flat_Tree_Birch_small_green.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Trees/Cypress/Flat_Tree_Cypress_large.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Trees/Cypress/Flat_Tree_Cypress_medium.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Trees/Cypress/Flat_Tree_Cypress_small.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Trees/Oak/Flat_Tree_Oak_hero_green.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Trees/Oak/Flat_Tree_Oak_large_green.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Trees/Oak/Flat_Tree_Oak_medium_green.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Trees/Oak/Flat_Tree_Oak_small_green.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Trees/Other/Flat_Tree_Elm_green.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Trees/Other/Flat_Tree_Maple_red.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Trees/Other/Flat_Tree_Windswept_dark_green.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Trees/Other/Flat_Tree_with_Mistletoe.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Trees/Park Trees/Flat_Tree_Park_large_green.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Trees/Park Trees/Flat_Tree_Park_medium_green.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Trees/Park Trees/Flat_Tree_Park_small_green.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Trees/Pine/Flat_Tree_Pine_hero.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Trees/Pine/Flat_Tree_Pine_large.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Trees/Pine/Flat_Tree_Pine_medium.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Trees/Pine/Flat_Tree_Pine_small.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Trees/Simple Trees/Flat_Tree_Simple_large.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Trees/Simple Trees/Flat_Tree_Simple_medium.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Trees/Simple Trees/Flat_Tree_Simple_small.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Trees/Spruce/Flat_Tree_Spruce_large.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Trees/Spruce/Flat_Tree_Spruce_medium.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/forest_nature_updated/Trees/Spruce/Flat_Tree_Spruce_small.glb` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Bush_1_A_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Bush_1_B_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Bush_1_C_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Bush_1_D_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Bush_1_E_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Bush_1_F_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Bush_1_G_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Bush_2_A_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Bush_2_B_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Bush_2_C_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Bush_2_D_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Bush_2_E_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Bush_2_F_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Bush_3_A_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Bush_3_B_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Bush_3_C_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Bush_4_A_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Bush_4_B_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Bush_4_C_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Bush_4_D_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Bush_4_E_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Bush_4_F_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Grass_1_A_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Grass_1_A_Singlesided_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Grass_1_B_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Grass_1_B_Singlesided_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Grass_1_C_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Grass_1_C_Singlesided_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Grass_1_D_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Grass_1_D_Singlesided_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Grass_1_Mesh.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Grass_1_SingleSided_Mesh.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Grass_2_A_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Grass_2_A_Singlesided_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Grass_2_B_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Grass_2_B_Singlesided_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Grass_2_C_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Grass_2_C_Singlesided_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Grass_2_D_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Grass_2_D_Singlesided_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Grass_2_Mesh.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Grass_2_SingleSided_Mesh.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_1_A_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_1_B_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_1_C_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_1_D_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_1_E_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_1_F_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_1_G_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_1_H_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_1_I_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_1_J_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_1_K_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_1_L_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_1_M_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_1_N_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_1_O_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_1_P_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_1_Q_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_2_A_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_2_B_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_2_C_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_2_D_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_2_E_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_2_F_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_2_G_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_2_H_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_3_A_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_3_B_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_3_C_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_3_D_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_3_E_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_3_F_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_3_G_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_3_H_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_3_I_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_3_J_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_3_K_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_3_L_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_3_M_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_3_N_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_3_O_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_3_P_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_3_Q_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Rock_3_R_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Tree_1_A_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Tree_1_B_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Tree_1_C_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Tree_2_A_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Tree_2_B_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Tree_2_C_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Tree_2_D_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Tree_2_E_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Tree_3_A_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Tree_3_B_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Tree_3_C_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Tree_4_A_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Tree_4_B_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Tree_4_C_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Tree_Bare_1_A_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Tree_Bare_1_B_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Tree_Bare_1_C_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Tree_Bare_2_A_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Tree_Bare_2_B_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/bosque/kaykit_forest/Assets/gltf/Tree_Bare_2_C_Color1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/granja/Farm_Harvest/glTF/mdvl_farm_apple_tree_01.glb` | Producción/instalación agrícola exterior; no aporta mobiliario doméstico esencial. |
| `RPG/assets/granja/Farm_Harvest/glTF/mdvl_farm_beehive_01.glb` | Producción/instalación agrícola exterior; no aporta mobiliario doméstico esencial. |
| `RPG/assets/granja/Farm_Harvest/glTF/mdvl_farm_cabbage_stage_01.glb` | Producción/instalación agrícola exterior; no aporta mobiliario doméstico esencial. |
| `RPG/assets/granja/Farm_Harvest/glTF/mdvl_farm_cabbage_stage_02.glb` | Producción/instalación agrícola exterior; no aporta mobiliario doméstico esencial. |
| `RPG/assets/granja/Farm_Harvest/glTF/mdvl_farm_chicken_coop_01.glb` | Producción/instalación agrícola exterior; no aporta mobiliario doméstico esencial. |
| `RPG/assets/granja/Farm_Harvest/glTF/mdvl_farm_feed_trough_01.glb` | Producción/instalación agrícola exterior; no aporta mobiliario doméstico esencial. |
| `RPG/assets/granja/Farm_Harvest/glTF/mdvl_farm_furrow_01.glb` | Producción/instalación agrícola exterior; no aporta mobiliario doméstico esencial. |
| `RPG/assets/granja/Farm_Harvest/glTF/mdvl_farm_haystack_02.glb` | Producción/instalación agrícola exterior; no aporta mobiliario doméstico esencial. |
| `RPG/assets/granja/Farm_Harvest/glTF/mdvl_farm_scarecrow_01.glb` | Producción/instalación agrícola exterior; no aporta mobiliario doméstico esencial. |
| `RPG/assets/granja/Farm_Harvest/glTF/mdvl_farm_well_cover_01.glb` | Producción/instalación agrícola exterior; no aporta mobiliario doméstico esencial. |
| `RPG/assets/naturaleza/glTF/Bush_Common.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/Bush_Common_Flowers.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/CommonTree_1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/CommonTree_2.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/CommonTree_3.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/CommonTree_4.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/CommonTree_5.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/DeadTree_1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/DeadTree_2.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/DeadTree_3.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/DeadTree_4.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/DeadTree_5.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/Grass_Common_Short.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/Grass_Common_Tall.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/Grass_Wispy_Short.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/Grass_Wispy_Tall.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/Mushroom_Common.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/Mushroom_Laetiporus.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/Pebble_Round_1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/Pebble_Round_2.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/Pebble_Round_3.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/Pebble_Round_4.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/Pebble_Round_5.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/Pebble_Square_1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/Pebble_Square_2.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/Pebble_Square_3.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/Pebble_Square_4.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/Pebble_Square_5.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/Pebble_Square_6.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/Petal_1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/Petal_2.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/Petal_3.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/Petal_4.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/Petal_5.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/Pine_1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/Pine_2.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/Pine_3.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/Pine_4.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/Pine_5.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/RockPath_Round_Small_1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/RockPath_Round_Small_2.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/RockPath_Round_Small_3.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/RockPath_Round_Thin.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/RockPath_Round_Wide.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/RockPath_Square_Small_1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/RockPath_Square_Small_2.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/RockPath_Square_Small_3.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/RockPath_Square_Thin.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/RockPath_Square_Wide.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/Rock_Medium_1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/Rock_Medium_2.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/Rock_Medium_3.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/TwistedTree_1.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/TwistedTree_2.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/TwistedTree_3.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/TwistedTree_4.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/naturaleza/glTF/TwistedTree_5.gltf` | Paisaje/vegetación/roca; decoración secundaria o adaptación específica, sin función de mueble. |
| `RPG/assets/objetos_medievales/glTF/Cage_Small.gltf` | Secundario: arma, llave, entrenamiento, puesto exterior o decoración de daño; no esencial. |
| `RPG/assets/objetos_medievales/glTF/Dummy.gltf` | Secundario: arma, llave, entrenamiento, puesto exterior o decoración de daño; no esencial. |
| `RPG/assets/objetos_medievales/glTF/Key_Gold.gltf` | Secundario: arma, llave, entrenamiento, puesto exterior o decoración de daño; no esencial. |
| `RPG/assets/objetos_medievales/glTF/Key_Metal.gltf` | Secundario: arma, llave, entrenamiento, puesto exterior o decoración de daño; no esencial. |
| `RPG/assets/objetos_medievales/glTF/Shield_Wooden.gltf` | Secundario: arma, llave, entrenamiento, puesto exterior o decoración de daño; no esencial. |
| `RPG/assets/objetos_medievales/glTF/Stall_Cart_Empty.gltf` | Secundario: arma, llave, entrenamiento, puesto exterior o decoración de daño; no esencial. |
| `RPG/assets/objetos_medievales/glTF/Stall_Empty.gltf` | Secundario: arma, llave, entrenamiento, puesto exterior o decoración de daño; no esencial. |
| `RPG/assets/objetos_medievales/glTF/Sword_Bronze.gltf` | Secundario: arma, llave, entrenamiento, puesto exterior o decoración de daño; no esencial. |
| `RPG/assets/objetos_medievales/glTF/Vase_Rubble_Medium.gltf` | Secundario: arma, llave, entrenamiento, puesto exterior o decoración de daño; no esencial. |
| `RPG/assets/granja/animales/FBX/Cow.fbx` | Animal; fuera de mobiliario interior. Cabecera revisada, sin nueva decodificación de rig/importación. |
| `RPG/assets/granja/animales/FBX/Horse.fbx` | Animal; fuera de mobiliario interior. Cabecera revisada, sin nueva decodificación de rig/importación. |
| `RPG/assets/granja/animales/FBX/Llama.fbx` | Animal; fuera de mobiliario interior. Cabecera revisada, sin nueva decodificación de rig/importación. |
| `RPG/assets/granja/animales/FBX/Pig.fbx` | Animal; fuera de mobiliario interior. Cabecera revisada, sin nueva decodificación de rig/importación. |
| `RPG/assets/granja/animales/FBX/Pug.fbx` | Animal; fuera de mobiliario interior. Cabecera revisada, sin nueva decodificación de rig/importación. |
| `RPG/assets/granja/animales/FBX/Sheep.fbx` | Animal; fuera de mobiliario interior. Cabecera revisada, sin nueva decodificación de rig/importación. |
| `RPG/assets/granja/animales/FBX/Zebra.fbx` | Animal; fuera de mobiliario interior. Cabecera revisada, sin nueva decodificación de rig/importación. |

## Validación y alcance de cambios

Revisión estática de fuentes y geometría en memoria, contraste de recuentos y comprobación de rutas. Las medidas no sustituyen AABB instanciadas, importación ni revisión visual. No se ejecutaron pruebas del juego: al cambiar solo documentación no aportaban validación del contenido visual y podían generar archivos adicionales.

Único archivo creado: **RPG/docs/auditoria_assets_interiores.md**. AGENTS.md y RPG/docs/estado_proyecto.md se revisaron y se mantienen sin cambios por la instrucción expresa de crear únicamente este documento; tampoco se modifica el inventario general. No se corrigieron conflictos previos. No se modificaron escenas, scripts, assets, importaciones, configuraciones ni funcionalidades. Sin commits ni pushes.
