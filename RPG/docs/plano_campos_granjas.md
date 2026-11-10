# Campos y Granjas — fase 6E

4 de noviembre de 2026. Región construida y conectada por el sur de Aldea. Escena jugable **`RPG/scenes/mundo_campos_granjas.tscn`**, contenido **`RPG/scenes/campos_granjas.tscn`**. Abrir con F6 o llegar caminando hacia el sur desde la aldea con F5. Sin animales, NPC, agricultura funcional ni persistencia. Revisión visual final del usuario pendiente.

## Distribución

Norte = −Z, sur = +Z. Recinto jugable **100×90**, X=[−50,50], Z=[−45,45]. Suelo de malla triangulada con colisión concordante; apoyos y caminos planos, colinas suaves periféricas. Faldón paisajístico 140×130 fuera de los cuatro cierres: evita ver un corte cercano al orbitar en los extremos, sin ampliar la zona accesible. No hay agua transitable, desniveles que exijan salto ni cambios de controlador.

| Conjunto | Centro/ubicación X,Z | Contenido y aproximación |
|---|---|---|
| A · Entrada | (0,−39) a (0,−29) | Camino, cercas laterales, cartel, flores, plantel de coles al oeste; frutales/colmenas al nordeste. Vista entre granero y casa |
| B · Granero principal | (−12,−24) | Cuerpo propio 8×10, muros de 3,8, cubierta a dos aguas con subida 2,1; madera, paja, juntas, entramado, ventilaciones, puertas grandes cerradas, base de piedra; acceso frontal (−12,−16) |
| B · Casa del granjero | (10,−25) | Cuerpo 4×6, cubierta/frontones originales bajo padre Y=0,60 a Y=3; porche, chimenea, ventanas, postigos, maceta, banco, cubo, leñera y huerto en (18,−25). Llegada (10,−20) |
| B · Patio | (0,−15) | Carreta apartada (−8,−10), pozo (6,−10), banco de trabajo, cajas de verduras, sacos, barriles, cuerda/hacha y heno junto al granero; eje central libre |
| C · Trigo | X=[−31,−14], Z=[−8,10] | Cuatro parcelas 7×7, pasillos cruzados; 1408 plantas con tallo, hojas y diez granos volumétricos por espiga. Espantapájaros al oeste, suministros fuera de pasos |
| C · Huertos principales | (8,−8) y (19,−8), 5×9 | Coles en tres etapas y zanahorias; corredor central X=16, cercas con puertas abiertas al sur, cestas de cosecha |
| D · Establo | (31,1) | 6×8, tres paredes y frente abierto en dos huecos con postes sólidos; cubierta, comedero, heno, taburete y cubos; aproximación (31,8) |
| D · Corrales | Rect2(20,13,8,10), Rect2(31,13,8,10) | Cercas, hojas de portón abiertas, comederos, heno, cubos, pequeñas manchas de pasto; bebedero con agua estática al este. Pasos X=24 y X=35 hacia Z=21 |
| D · Gallinero | (16,12) | Asset Farm & Harvest, instancia 1,3; vacío, sin aves o animaciones |
| E1 · Hortelana | Casa (−25,24) | Cuerpo 4×4, porche, leñera, maceta, barril, huerto 5×6 al oeste, cobertizo abierto (−33,16) y manzano (−32,33); acceso por (−25,29) |
| E2 · Cosechero | Casa (14,33) | Cuerpo 4×6, distinta parcela/disposición de E1; almacén propio (23,34), leñera, huerto de zanahorias (5,32), carreta y carga junto al almacén. Acceso desde (14,40) |
| F · Paisaje | Bordes, isla nordeste y claros entre caminos | Árboles de dos siluetas, seis manzanos, arbustos, dos flores silvestres, hierbas, rocas, colinas bajas y senderos alternativos. Vegetación alta retirada de los corredores |

Hay **seis huertos cercados** contando el plantel de entrada, el doméstico principal, los dos grandes y los dos de granjas secundarias. Los corrales son dos reservas adicionales, no huertos. Granero, tres viviendas, establo, cobertizo y almacén son siete construcciones distintas; no se atribuyen a un paquete edificios completos inexistentes.

```text
                        ALDEA
                          ↕
                     entrada norte
       plantel      granero · patio · casa     frutales/colmenas
           ╭──────────────┼──────────────────╮
           │    trigo     │    huertos       │
           │    ╬╬╬╬      ├──────── establo ──┤
           ╰──────┬───────┤  gallinero        │
             E1 · huerto │       corrales ───┤
                  ╰──────┤       ╰──────────╯
                         ╰──── E2 · almacén
```

## Caminos y exploración

Catorce nodos `CamposYGranjas/Caminos/*` guardan `eje` (PackedVector2Array) y `ancho`. La herramienta configura 43 segmentos; el shader recibe esos mismos datos, sin un segundo plano escrito a mano. Centros, anchuras y apoyos son la fuente de la validación física; el borde visual suavizado no redefine su paso libre.

| Camino | Anchura | Función |
|---|---:|---|
| Entrada | 4,5 | (0,−44) → (0,−35) → (2,−29) → (0,−15) |
| Central | 4,5 | Patio → (0,−5) → (3,6) → (0,15) → (0,27) → (−3,35) |
| LazoOeste | 3,6 | Patio → frente del granero → X=−36 → (−25,13) → (0,15); rodea trigo |
| LazoEste | 4 | Patio → (30,−12) → (41,−5) → (43,13) → (43,25) → (38,28) → (23,28) → (0,27); rodea establo/corrales |
| GranjaOeste | 3,2 | (−25,13) → (−17,19) → (−17,29) → (−12,34) → (−3,35) |
| CasaOeste | 2,5 | (−17,29) → (−25,29) → (−35,30), accesos casa/huerto |
| GranjaSur | 3 | (23,28) → (28,30) → (29,36) → (28,41) → (14,40) |
| Establos | 3,2 | (3,6) → (16,7) → (31,8) → (42,8) |
| Huertos | 2,6 | (16,7) → (16,−7) |
| CruceTrigo | 2,2 | (−36,1) → (−22,1) → (0,1) |
| CorralOeste / CorralEste | 2,5 | Ejes verticales X=24 / X=35, Z=28 → 21, atraviesan sus portones abiertos |
| CasaPrincipal | 2,5 | Patio → (10,−17) → (10,−20) |
| Granero | 3 | (−12,−14) → (−12,−16) |

Los dos lazos y sus cruces permiten regresar por otro lado; los accesos domésticos tienen finales deliberados. Las plantas pequeñas no colisionan, de modo que los claros abiertos también se exploran. Edificios cerrados tienen paredes delgadas y puertas sólidas, sin interiores accesibles; establo/cobertizo conservan aberturas reales. Cercas segmentadas, carretas, banco, grandes suministros, troncos y rocas voluminosas tienen envolventes simples. No hay caja que cubra toda una parcela ni colisión por espiga, col, hierba o flor.

## Recursos y autoría

Se reutilizan los **14 GLB agrícolas** de `RPG/assets/granja/Farm_Harvest/glTF/`, prefijo `mdvl_farm_`: apple_tree_01, beehive_01, cabbage_stage_01/02/03, chicken_coop_01, feed_trough_01, fruit_basket_01, furrow_01, hay_bale_01, haystack_02, milking_stool_01, scarecrow_01 y well_cover_01. Suelo de surcos colocado por el origen fuente, sin centrar cada tesela. Raíces de verduras ajustadas al bancal en las instancias. No se utiliza ningún archivo de `animales/`.

Otros originales, íntegros:

- `RPG/assets/aldea/glTF/`: Roof_RoundTiles_4x4, Roof_RoundTiles_4x6, Roof_Front_Brick4 y Prop_Wagon. Tejados/frontones de viviendas bajo el mismo padre vertical 0,60, X/Z=1 y muros de tres unidades. Barns de tamaño propio usan cubierta propia, sin deformar esos módulos ni el protagonista.
- `RPG/assets/objetos_medievales/glTF/`: Bench, Bucket_Wooden_1, Pot_1, Workbench, Barrel, Bag, Crate_Wooden, FarmCrate_Carrot, FarmCrate_Apple, FarmCrate_Empty, Rope_1, Axe_Bronze y Carrot. Materiales Carrot/FarmCrate_Carrot duplicados localmente con colores de vértice habilitados y descendientes editables; originales/owners glTF conservados.
- `RPG/assets/naturaleza/glTF/`: CommonTree_1, CommonTree_5, Flower_3_Group, Flower_4_Group, Grass_Common_Short, Grass_Wispy_Short, Bush_Common_Flowers y Rock_Medium_1. No hace falta otro paquete ni copiar una región forestal. La selección forestal se revisó como complemento posible; esta primera versión utiliza Nature y los frutales agrícolas para mantener pradera abierta.

Se inspeccionaron las cercas modulares existentes; se usan cercas propias bajas ajustadas a puertas y anchuras de paso. Geometría propia: granero/almacén, muros y detalles domésticos, porches/chimeneas, establo/cobertizo, leñeras, cercas/portones, cartel, bebedero, espigas/hojas/tallos, manchas de pasto, terreno y cierres. Nada incrementa el inventario de modelos originales: siguen **524 canónicos**.

`RPG/scripts/editor/construir_campos_granjas.gd` es **autoría offline determinista, semilla 60615**, opcional; no corre al jugar. Solo regenera `campos_granjas.tscn`, `campos_terreno.res` y `campos_colision.res`. Escribir ajustes duraderos también en esta herramienta. Ejecutarla **con ventana**, como la autoría forestal, para que Godot conserve los nueve buffers MultiMesh (cuatro de trigo, cinco de vegetación). La herramienta rechaza headless: los primeros borradores con contadores guardados pero buffers vacíos no son la versión final. Sin dependencias ni plugins nuevos.

`RPG/scripts/terreno_campos.gdshader` mezcla tierra/hierba con variación continua, anchuras de caminos y patios procedentes de autoría; no anima ni desplaza vértices. Colisión y malla usan la misma altura de terreno. Los recursos binarios de terreno/colisión son externos a la escena, fuera de assets. Las plantas y la decoración se guardan, sin generación por fotograma.

## Conexión Aldea ↔ Campos y Granjas

Se conserva `GestorRegiones`, `region_config.gd`, `salida_region.gd`, Autoload, escena inicial y fundidos de **0,35 s**. Solo se amplía `RPG/scenes/mundo.tscn`; `aldea.tscn`, señales, suelo, límites y edificios no se editan. El detector se activa antes del cierre sur sólido, igual que la conexión norte: no se necesita abrir un agujero físico ni caminar fuera del terreno.

| Origen | Salida / centro real | Destino | Entrada base / orientación |
|---|---|---|---|
| Aldea | Region/SalidaCampos, marcador existente SalidaCamposSur/TransicionFutura (0;0,02;35,5); área (0;1,02;35,5), caja 4×3×1,4 | mundo_campos_granjas.tscn | campos_aldea_norte → CamposYGranjas/Marcadores/EntradaAldea (0;0,05;−39), abajo/+Z |
| CamposYGranjas | Region/SalidaAldea, Marcadores/RetornoAldea (0;0;−43); área (0;1;−43), caja 4,5×3×1,4 | mundo.tscn | aldea_campos_sur → Region/EntradaCampos (0;0,02;32), arriba/−Z |

El gestor añade +0,05 Y. Separación detector/aparición 4 en granja y 3,5 en aldea, fuera de todo detector. IDs estables de 4B.6 conservados. EntradaBosque sigue en Z=−32 y no se usa al regresar de la granja. No se interpreta `transiciones_implementadas=false` histórico de la escena de señales como estado del gestor: las áreas explícitas de los mundos gobiernan las conexiones actuales. Salida este sigue pendiente.

## Validación y evidencias

Todo bajo **`RPG/logs/fase6e_campos_granjas/`**, con nombres/subcarpetas nuevos. Pruebas reproducibles desde la raíz del repositorio (ejecutable Godot 4.7.2 disponible; crear logs antes):

```text
godot --path RPG --log-file logs/fase6e_campos_granjas/<autoria_nueva>.log --script res://scripts/editor/construir_campos_granjas.gd
godot --headless --fixed-fps 60 --path RPG --log-file logs/fase6e_campos_granjas/<fisica_nueva>.log --script res://tests/validar_campos_granjas.gd
godot --fixed-fps 60 --path RPG --log-file logs/fase6e_campos_granjas/<visual_nueva>.log --script res://tests/validar_campos_granjas.gd
godot --fixed-fps 60 --path RPG --log-file logs/fase6e_campos_granjas/<viajes_nueva>.log --script res://tests/validar_transicion_campos.gd
```

`validar_campos_granjas.gd` mide bandas completas con la cápsula original, recorre cada polilínea en ambos sentidos mediante física, contrasta muros/puertas/huecos, formas activas y detectables, cuatro cierres, ausencia de animales, recursos, nueve buffers guardados y órbita. La fixture local desactiva solo el retorno para medir el cierre norte; la prueba regional mantiene todas las áreas activas.

`validar_transicion_campos.gd` hace cinco Aldea → Granja → Aldea y la cadena Aldea → Bosque → Ruinas → Bosque → Aldea → Granja → Aldea: **16 cambios**, desde la aparición inicial de aldea, sin teletransportes ni señales de área emitidas manualmente. Comprueba fundidos intermedios/negro, marcadores/orientación, control y movimiento, cámara 15/orbita completa en cuatro regiones, ausencia de duplicados, bucles y solicitudes simultáneas. Rodea el pozo existente de plaza por su camino; no altera el escenario para simplificar el circuito.

Las pruebas anteriores mantienen comprobaciones y controles negativos. Se actualiza únicamente la expectativa de dos áreas activas en aldea, añadiendo controles explícitos de salida sur, y la fixture física local desactiva ambos detectores para seguir midiendo los cierres. La orientación de marcha tras aparecer se toma del marcador, equivalente a los casos anteriores y correcta para la nueva entrada. `--fase6e` concentra evidencias existentes de regresión aquí, sin cambiar su lógica física. No se han retirado las aserciones de retorno E04/E12 ni relajado tolerancias.

`capturar_campos_granjas.gd` permite iterar solo las vistas; su salida dice **SOLO_CAPTURAS**, no se presenta como aprobación física. Las galerías tienen once puntos de interés en cuatro orientaciones con cámara habitual 15 más plano superior ampliado. Algunas fachadas/tejados pueden ocultar al sprite al acercarse desde el lado posterior; sin transparencia de obstáculos ni modificación de cámara. Aprobación artística y recorrido manual del usuario pendientes. Las mediciones breves de rendimiento a 1440×900 en RTX 4060 Laptop son muestras locales, no benchmark general ni promesa para otro hardware.

Resultados y rutas finales de las ejecuciones están registrados en el estado del proyecto. Persisten avisos del entorno de certificados/guardado de caché de shaders; no se atribuyen a referencias de assets ausentes. Los borradores conservan fallos de tipado, 27 muestras de borde invadidas corregidas moviendo objetos/rutas y autoría MultiMesh headless descartada. No se esconden esos intentos. Sin commits ni pushes.
