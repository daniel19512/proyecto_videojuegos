# Plano de ampliación de la aldea medieval

Fecha: **30 de octubre de 2026**. **Plano y proporciones aprobados; etapa 2 implementada como distribución provisional en `RPG/scenes/aldea.tscn`.** Terreno, plaza, caminos y parcelas preparados, sin edificios definitivos. La sección 11 registra las reservas finales y su validación; revisar visualmente con F6 antes de construir.

## 1. Alcance y base inspeccionada

Diseño de una aldea acogedora con **12 edificios**: seis viviendas, taberna, panadería, herrería, carpintería, herbolario y molino. Los tres puestos del mercado no cuentan como edificios. El molino pertenece a la fase final, condicionada a disponer de sus piezas especiales. Antes de esa fase habrá 11 edificios.

Fuentes: `AGENTS.md`, `RPG/docs/estado_proyecto.md`, `RPG/docs/inventario_assets.md`; escenas `aldea.tscn`, `casa_modular.tscn`, `pruebas_assets.tscn`, `mundo.tscn`, `jugador.tscn` y `jugador_frames.tres` bajo `RPG/scenes/`; movimiento en `RPG/scripts/jugador.gd`. Se comprobaron los 338 archivos glTF locales por paquete y las medidas de los recursos de la tabla siguiente. La referencia artística se interpreta desde la descripción del usuario; no se ha inspeccionado una imagen adjunta.

La composición original de 32×32 con cuatro edificios quedó respaldada antes de sustituirla en la etapa 2: `RPG/scenes/respaldos/aldea_etapa1.tscn` y su mundo ejecutable independiente. El mundo actual presenta suelo de 80×72 y marcadores de esta distribución. No se han construido todavía las casas ni establecimientos descritos aquí. Cámara, protagonista y assets originales se conservan.

## 2. Escala real y dimensiones del terreno

Terreno preparado: **80 × 72 unidades**, límites X = [-40, 40], Z = [-36, 36], superficie de 5.760 unidades cuadradas. Suelo continuo transitable en Y = 0; el desnivel del cauce queda para su fase. Es una convención de diseño equivalente aproximadamente a metros, sin cambiar unidades ni escalar globalmente el mundo.

Origen: centro de plaza (0, 0). En las tablas se indica **(X, Z)**; norte = -Z, sur = +Z, este = +X. Son coordenadas del mundo con `Aldea` a identidad. El norte del plano no es necesariamente la parte superior de toda vista de juego. Las cotas Y y pivotes se resolverán al montar cada envoltorio.

El protagonista conserva cápsula de radio **0,32** y altura **1,60**, `pixel_size = 0.045` y cuadros de 40 × 48 píxeles: rectángulo del sprite de **1,80 × 2,16**, incluido margen transparente; no equivale a su silueta opaca. Velocidad actual: 4 unidades/s. La cámara principal utiliza el tamaño ortográfico **15 aprobado por el usuario**, con inclinación aproximada de -32° conservada: se recorrerán sectores, sin pretender mostrar el plano completo simultáneamente. El selector de la escena de assets sigue iniciando en 23 para futuras comparaciones.

### Medidas verificadas de los modelos

Dimensiones **X × Y × Z**, escala fuente 1, redondeadas a tres decimales. Obtenidas de la unión de límites `min/max` de accessors POSITION de todas las primitivas de cada glTF. En estos 17 recursos se comprobó un único nodo de malla sin transformación: los límites locales corresponden al modelo completo. Es medición estática de geometría, no comprobación gráfica ni de huecos transitables.

| Modelo | Dimensiones |
|---|---|
| `Wall_Plaster_Straight` | 2,000 × 3,125 × 0,406 |
| `Wall_Plaster_Door_Flat` | 2,000 × 3,123 × 0,406 |
| `Door_1_Flat` | 1,118 × 2,100 × 0,121 |
| `Roof_RoundTiles_4x4` | 5,513 × 4,249 × 5,561 |
| `Roof_RoundTiles_4x6` | 5,513 × 4,234 × 7,572 |
| `Roof_RoundTiles_6x8` | 8,250 × 5,672 × 9,683 |
| `Floor_UnevenBrick` / `Floor_WoodDark` | 2,000 × 0,020 × 2,000 cada uno |
| `Stall_Empty` | 1,845 × 2,627 × 0,932 |
| `Anvil_Log` | 0,929 × 1,073 × 0,821 |
| `Workbench` | 2,019 × 0,895 × 1,024 |
| `Bench` | 2,777 × 0,533 × 0,534 |
| `CommonTree_1` | 4,311 × 7,265 × 4,578 |
| `CommonTree_3` | 4,063 × 9,425 × 4,241 |
| `CommonTree_5` | 3,671 × 7,006 × 4,220 |
| `Bush_Common` | 1,915 × 1,582 × 1,965 |
| `Rock_Medium_1` | 3,225 × 2,260 × 2,989 |

Los nombres 4×4 y 6×8 expresan familias modulares, **no su ocupación exterior real**. Usar paredes en pasos de 2 unidades; preservar aleros al reservar parcelas. Una vivienda con cuerpo 4×4 necesita aproximadamente 5,6×5,6 solo para cubierta. Se propone parcela de al menos 8×8. Las paredes actuales y su casa de pruebas sirven de patrón de montaje; no copiar indiscriminadamente su altura de cubierta. La aldea actual comprime verticalmente algunos tejados; la casa de pruebas usa otra proporción. Resolver ese encaje visual en la primera etapa sin escalar al protagonista.

## 3. Distribución de edificios

Centros de futuros edificios, implementados como marcadores en la etapa 2; dimensiones en planta **X × Z**. La envolvente redondea hacia arriba la cubierta medida; no es una caja de colisión. Las parcelas incluyen jardín/servicio y no invaden corredores ajenos; los accesos propios sí entran en su parcela. E01/E02 tienen reservas recortadas y descentradas respecto al edificio: sus límites exactos figuran en la sección 11. Las futuras rotaciones orgánicas, hasta unos 8°, requieren recalcular aleros y accesos antes de aplicarlas.

| ID | Edificio | Centro (X, Z) | Cuerpo modular / envolvente de cubierta | Parcela | Acceso y actividad futura |
|---|---|---|---|---|---|
| E01 | Taberna | (-8, -20) | 6×8 / 8,3×9,7 | 11,5×12,5; descentrada | Sur; reunión, comidas y descanso |
| E02 | Panadería | (8, -20) | 4×6 / 5,6×7,6 | 9,5×11,5; descentrada | Sur; venta y preparación exterior |
| E03 | Herrería | (-23, -6) | 6×4 / 7,6×5,6 | 12×10 | Este; yunque, afilado y suministros |
| E04 | Carpintería | (-23, 7) | 6×4 / 7,6×5,6 | 12×10 | Este; banco de trabajo y madera |
| E05 | Herbolario | (21, 8) | 4×4 / 5,6×5,6 | 8×10 | Oeste; plantas y preparación |
| E06 | Vivienda noroeste | (-24, -23) | 4×6 / 5,6×7,6 | 10×12 | Este; residencia de artesanos |
| E07 | Vivienda noreste | (21, -24) | 4×4 / 5,6×5,6 | 8×10 | Oeste; residencia de comerciantes |
| E08 | Vivienda suroeste | (-24, 23) | 4×4 / 5,6×5,6 | 10×10 | Norte; jardín doméstico |
| E09 | Vivienda sur oeste | (-8, 24) | 4×4 / 5,6×5,6 | 10×10 | Norte; residencia de agricultores |
| E10 | Vivienda sur centro | (8, 25) | 4×4 / 5,6×5,6 | 8×10 | Norte; residencia de panadería |
| E11 | Vivienda sureste | (18, 24) | 4×4 / 5,6×5,6 | 10×10 | Norte; residencia del molino |
| E12 | Molino reservado | (21, -10) | 6×8 / 8,3×9,7 | 10×12 para edificio | Oeste; molienda futura; rueda al este fuera de parcela |

E03/E04 usan la familia 4×6 girada 90°. E01/E12 usan cubierta 6×8; comprobar frontones y cierre de muros antes de confirmar su montaje. Todos los edificios se componen modularmente; **no existen edificios completos listos**. Las funciones y asignaciones de habitantes son intenciones de diseño, no gameplay ni NPCs existentes. Conservar inicialmente fachadas cerradas, sin prometer interiores.

## 4. Zonas, plaza y paisaje

| Zona / elemento | Centro o límites (X, Z) | Reserva y función |
|---|---|---|
| Plaza | centro (0, 0); X [-10,10], Z [-9,9] | 20×18; borde irregular dentro de esta reserva |
| Fuente propuesta | (0, -4) | 4×4 de ocupación máxima, altura objetivo ≤1,8; pieza nueva pendiente |
| Puestos de mercado | (-6,-6), (6,-6), (7,1) | Cada uno con reserva 3×3 para modelo, vendedor y mercancía |
| Bancos | (-7,4), (7,6) | Reservas 3×2, fuera de cruces |
| Encuentro / eventos | centro (-2,4) | 6×4 despejado; reunión y futuras conversaciones |
| Llegada actual del jugador | (0,0) | Mantener libre al menos radio 1,5; no mover al protagonista |
| Patio herrería | (-18,-6) | 3×6; dejar salida este libre hacia calle |
| Patio carpintería | (-18,7) | 3×6; herramientas fuera del paso |
| Jardín de hierbas | (23,15) | 4×4; conexión con E05 sin cerrar calle sur |
| Huerto comunitario | (-32,5;15) | 6×5; separado de E08 y de su ramal |
| Huertos domésticos | (-8,32), (8,33) | 6×4 cada uno, sin bloquear fachadas norte |
| Arboleda oeste | X [-38,-31], Z [-30,30] | Grupos irregulares; claros junto a entradas |
| Fondo natural norte | X [-32,24], Z [-35,-30] | Árboles y rocas, con interrupción en salida norte |
| Ribera este | X [26,36], Z [-34,34] | Franja de 10 unidades reservada; no construir viviendas |
| Agua futura | eje X≈30, Z [-34,34] | Anchura inicial 4: X [28,32]; curvas solo dentro de la franja |
| Puente propuesto | (30,0) | Longitud este-oeste 8, X [26,34]; cruce provisional de suelo de 4; futuro puente con 3 libres |
| Rueda / canal del molino | X [25,28], Z [-13,-7] | Reserva técnica junto a E12, separada del puente |
| Mirador de ribera | (37,8) | 4×4; acceso por margen este desde puente |

La plaza usa `Floor_UnevenBrick` de 2×2 en el centro y bordes quebrados; no convertir todo el terreno en pavimento. La fuente queda al norte del origen para conservar la aparición actual. Reservar circulación de al menos 2,5 unidades alrededor de su huella, desplazando mercancía si hace falta; los puestos quedan a los lados, nunca formando una barrera transversal. Conectar el acceso norte mediante dos brazos X≈±3,5 entre Z=-9 y Z=0, rodeando la fuente. El acceso sur llega al espacio libre del origen.

La asimetría nace de patios, jardines y retranqueos diferentes, no de romper encajes modulares. Cubiertas cálidas, muros claros, madera y vegetación de hoja ancha sustentan el carácter colorido; cambios de materiales o iluminación requerirán evaluación posterior. Empezar con 12–18 árboles en bordes y pocos arbustos junto a viviendas; las copas de 4–5 unidades no deben ocultar cruces ni fachadas. Sus posiciones individuales se decidirán durante el montaje tras revisar la cámara, dentro de las zonas reservadas.

### Esquema orientativo (sin escala; mandan las tablas)

```text
                         NORTE (-Z)
                 bosque / salida norte
     E06           E01          E02       E07     ~ río ~
        \            |            |        /      ~     ~
         +----------- calle norte --------+       ~     ~
         |                               | E12 + rueda ~
  E03 -- patio      mercado / fuente      |       ~     ~
         |          PLAZA CENTRAL         +=======puente==>
  E04 -- patio         llegada            |       ~     ~
         |                               |-- E05 ~     ~
 huerto  +----------- calle sur ---------+ jardín~     ~
    E08           E09          E10      E11       ~     ~
                 huertos / salida sur
                         SUR (+Z)
```

## 5. Caminos conectados y transitables

Anchuras **libres entre colisiones**, sin contar aleros, mercancía, troncos ni follaje que impida leer el paso:

| Tipo | Anchura recomendada | Criterio |
|---|---|---|
| Entrada sur y conexión plaza–puente | 4 | Dos cápsulas y margen visual; carros decorativos en apartaderos |
| Anillo de distribución | 4 | Trayectos principales y cruces futuros de NPCs |
| Ramales a viviendas y talleres | 2,5–3 | Evitar embudos; 3 frente a trabajos exteriores |
| Puente | 3 libres | Barandillas por fuera de esos 3; 4 de ancho estructural aproximado |
| Senderos de huerto / jardín | 2 | Uso peatonal secundario |
| Bolsas de interacción | 2×2 mínimo | Laterales a las rutas; ampliar a 3×3 para colas |

Dos cápsulas ocupan 1,28 unidades de ancho sin márgenes. Los 2,5–4 recomendados permiten circulación y separan actividades de las rutas, pero no garantizan por sí solos navegación futura.

Red base mediante polilíneas de ejes; las curvas artísticas deberán mantenerse en sus corredores:

- **Anillo:** (-14,-12) → (14,-12) → (14,14) → (-14,14) → (-14,-12), ancho 4. Es estructura de conectividad, no obligación de dejar esquinas rectas visualmente.
- **Enlaces plaza:** desde (0,-12) a (0,-9), (-14,0) a (-10,0), (10,0) a (14,0), (0,9) a (0,14). Dentro de plaza, rodear la fuente por los brazos indicados.
- **Sur:** (0;35,5) → (0,14) → (0,9), ancho 4. Pasa entre E09 y E10 sin cruzar sus parcelas. Norte: (0;-35,5) → (0,-9), ancho 4 entre taberna y panadería, unido al anillo en Z=-12. Los extremos quedan dentro del límite sólido.
- **Ribera:** (10,0) → (26,0) → (34,0) → (38,5;0), ancho 4, todo sobre suelo continuo. Desde (37,0) a (37,8), sendero de 2 al mirador. El futuro puente reducirá a 3 su ancho libre cuando se construya; no hay puente/cauce actualmente.
- **E01/E02:** sus puertas sur, aproximadamente (-8,-16) y (8,-17), enlazan en perpendicular con la calle Z=-12. **E03/E04:** puertas este en torno a (-20,-6) y (-20,7), por sus patios hasta X=-14. Ajustar la posición exacta al módulo de puerta, que puede estar descentrado.
- **E05/E12:** puertas oeste cerca de (19,8) y (18,-10) hasta X=14, ancho 3. Mantener libre la acera occidental del molino y separar canal/rueda al este.
- **E06:** acceso → (-16,5;-23) → (-16,5;-12) → (-14,-12), ancho 2,5. **E07:** acceso → (14,25;-24) → (14,25;-12) → (14,-12), ancho 2,5. El segundo cabe entre las reservas de panadería y molino, con 0,5 de margen a cada lado.
- **E08:** acceso norte → (-24,16) → (-14,16) → (-14,14), ancho 2,5. **E09/E10:** accesos en X=-8 / 8 → Z=17 → X=0, conectando con entrada sur. **E11:** acceso → (18,17) → (14,17) → (14,14). Mantener libre esa franja al sur del anillo.
- Huerto comunitario: (-24,16) → (-29,5;16); huertos traseros: (0,32) → (-5,32) y (0,33) → (5,33), ancho 2 desde la entrada sur. Jardín: (16,8) → (16,15) → (21,15), ancho 2. No depender de atravesar futuras casas cerradas.

En coordenadas con decimales se usa punto y coma para separar X y Z; la escena almacena los números con punto decimal. Los puntos de aproximación a cada futura fachada se registran como metadato `acceso` y son exteriores al cuerpo previsto, no puertas implementadas.

Objetivo de pendientes inicial: calles casi planas; puente a la cota de sus accesos, sin escalones. Senderos de tierra requieren geometría/material nuevos: `RockPath_*` aporta piedras, no un suelo continuo. Conservar apoyo físico continuo aunque cambie el acabado visible. En la futura implementación, comprobar el recorrido desde el origen hasta cada fachada, puesto, huerto y puente mediante barridos de cápsula y recorrido real.

## 6. Profesiones, NPCs y ampliaciones

Reservar puestos de actividad fuera de los ejes: herrero en patio E03, carpintero en E04, panadero ante E02, herbolario en jardín E05, agricultores en huertos y molinero en patio oeste E12. La taberna y plaza concentran descansos y encuentros; prever puntos de espera laterales de 3×3 junto a establecimientos, sin bloquear puertas. Esos puntos no crean NPCs ni navegación.

Rutinas espaciales posibles: E06 → taller → mercado → taberna; E09 → huerto → mercado → vivienda; E11 → molino → panadería → plaza. Los caminos forman bucles para evitar que toda actividad deba atravesar el centro. Asignación, horarios, navegación, diálogos e interacciones serán tareas independientes.

Ampliaciones: salida norte hacia bosque, sur hacia cultivos y este tras el puente hacia otra zona. Preservar bocas de conexión de 4 unidades; no ocuparlas con edificios o árboles. El margen oriental actual es paisajístico y pequeño: un nuevo barrio requerirá ampliar terreno más allá de X=40. No incluye ya otros edificios en el recuento de 12.

## 7. Recursos existentes y piezas que faltan

Las rutas de esta tabla son relativas a la raíz del repositorio. Cada nombre representa un archivo `.gltf` dentro de la carpeta indicada; no renombrar ni editar fuentes.

| Carpeta | Recursos locales seleccionados | Uso |
|---|---|---|
| `RPG/assets/aldea/glTF/` | `Wall_Plaster_Straight`, `Wall_Plaster_WoodGrid`, `Wall_Plaster_Door_Flat`, `Wall_Plaster_Window_Wide_Flat`, `Door_1_Flat`, `Window_Wide_Flat1`, `Corner_Exterior_Wood` | Casas y establecimientos modulares |
| `RPG/assets/aldea/glTF/` | `Wall_UnevenBrick_Straight`, `Wall_UnevenBrick_Door_Flat`, `Wall_UnevenBrick_Window_Wide_Flat` | Variantes de zócalo/fachada de talleres |
| `RPG/assets/aldea/glTF/` | `Roof_RoundTiles_4x4`, `Roof_RoundTiles_4x6`, `Roof_RoundTiles_6x8`, `Roof_Front_Brick4`, `Prop_Chimney`, `Prop_Chimney2` | Cubiertas; verificar frontones adecuados de cada tamaño |
| `RPG/assets/aldea/glTF/` | `Floor_UnevenBrick`, `Floor_WoodDark`, `Prop_WoodenFence_Single`, `Prop_WoodenFence_Extension1`, `Prop_Crate`, `Prop_Wagon`, `Prop_Vine1` | Pavimento, posible tablero de puente, cercas y detalles |
| `RPG/assets/objetos_medievales/glTF/` | `Stall_Empty`, `Stall_Cart_Empty`, `FarmCrate_Apple`, `FarmCrate_Carrot`, `Crate_Wooden`, `Barrel`, `Barrel_Apples`, `Bag` | Mercado y suministros |
| `RPG/assets/objetos_medievales/glTF/` | `Anvil_Log`, `Workbench`, `Workbench_Drawers`, `Whetstone`, `Axe_Bronze`, `Bucket_Wooden_1` | Patios profesionales |
| `RPG/assets/objetos_medievales/glTF/` | `Bench`, `Table_Large`, `Chair_1`, `Mug`, `Lantern_Wall`, `Pot_1`, `Carrot` | Descanso y utilería; no representan servicios funcionales |
| `RPG/assets/naturaleza/glTF/` | `CommonTree_1`, `CommonTree_3`, `CommonTree_5`, `Bush_Common`, `Bush_Common_Flowers`, `Flower_3_Group`, `Grass_Common_Short`, `Fern_1`, `Rock_Medium_1`, `RockPath_Round_Wide`, `RockPath_Round_Thin` | Jardines, bordes y ribera |

**Pendientes reales:** fuente completa y agua; terreno/cauce y material de río; rueda hidráulica, eje y mecanismo de molino; horno de panadería y fragua; bancales y plantas cultivables. No están identificados como modelos dedicados locales. El puente requiere diseño modular con tableros, soportes y barandillas; su compatibilidad y encajes aún no están probados. El cuerpo del molino sí puede componerse con muros/tejados existentes, pero sin rueda no constituye un molino visual completo. No se presume que cajas de manzanas sean manzanos ni que una chimenea sea un horno.

Estas piezas deberán crearse como recursos nuevos o adquirirse con procedencia/licencia comprobada mediante tareas posteriores autorizadas. No son requisito para aprobar la distribución; sí bloquean sus acabados definitivos. `RPG/assets/` continúa excluida de Git.

## 8. Etapas propuestas tras aprobar el plano

1. **Confirmar escala y encajes:** usar la escena independiente de pruebas para revisar casa, cubierta, puerta, árbol y puesto desde la cámara existente. Validar silueta del protagonista, aleros, materiales y accesos. Sin fijar una escala global nueva.
2. **Bloqueo de terreno y recorridos:** ampliar superficie y límites, marcar plaza, parcelas, caminos y reserva de río con volúmenes simples. Mantener aparición y verificar conectividad antes de detalle. No bloquear físicamente toda la reserva del río si todavía no hay cauce.
3. **Núcleo de vida:** plaza y sus rodeos, taberna, herrería, dos viviendas y mercado. Fuente solo cuando exista un recurso aprobado; reservar su huella mientras tanto. Recuperar la validación funcional de la base y revisar visibilidad caminando.
4. **Barrio completo:** panadería, carpintería, herbolario y cuatro viviendas restantes: 11 edificios en total. Añadir patios y puntos de actividad sin implementar aún profesiones o NPCs.
5. **Naturaleza y acabado:** huertos decorativos, jardines, arboledas, caminos de tierra y transiciones. Ajustar densidad según oclusión y tiempos de cuadro medidos.
6. **Ribera y molino:** resolver piezas faltantes, cauce, agua, puente y E12. Verificar caídas, bordes, apoyos, colisiones y lectura del agua. Obtener los 12 edificios; solo después valorar animación de rueda y sonido como tareas propias.
7. **Preparación social posterior:** aprobar puntos de actividad y recorridos con el escenario definitivo; planificar navegación y rutinas sin confundir esta reserva espacial con un sistema implementado.

Cada etapa necesita validación estática, ejecución headless apropiada y revisión gráfica con el protagonista. La prueba `RPG/tests/validar_aldea.gd` contiene supuestos de cuatro edificios y recorridos actuales: deberá revisarse cuando se autorice cambiar la escena; su resultado histórico no valida esta ampliación.

## 9. Riesgos y recomendaciones de aceptación

- **Aleros, pivotes y giros:** algunos límites mínimos son negativos; apoyar modelos por su geometría y no solo por el origen. Recalcular envolventes al girar. No usar el nombre del recurso como medida ni convertir toda cubierta en colisión a ras de suelo.
- **Oclusión:** cámara baja inclinada y copas de 7–9,4 unidades pueden tapar al protagonista. Priorizar masas altas en bordes/norte y jardines bajos al sur de rutas. No añadir desvanecimiento ni cambiar cámara en esta tarea; comprobar antes si basta redistribuir.
- **Accesos:** las medidas de la puerta son exteriores, no ancho útil del hueco. Mantener aproximación libre y verificar cápsula si se autorizan interiores en el futuro. Ahora siguen cerrados.
- **Terreno y río:** una caja de suelo continua bajo el agua impediría un cauce real. Diseñar geometría y colisiones de orillas al construirlo; definir barreras seguras mientras no haya natación. Separar visual y físicamente agua, puente y terreno.
- **Recursos faltantes:** fuente y molino son riesgos de alcance; resolver prototipos de piezas antes de detallar la ribera o anunciarla terminada. No sustituirlos por modelos supuestos.
- **Rendimiento:** 12 edificios modulares, árboles y sombras aumentan instancias/dibujados. Medir en Forward Plus/D3D12; evaluar reutilización y MultiMesh solo después, sin nuevas dependencias por anticipado.
- **Navegación futura:** espacios de espera y anchuras permiten prepararla, pero no existe aún backend de NPCs ni navegación implementada. Verificar cruces con varios agentes cuando se construya ese sistema.
- **Control de alcance:** conservar cambios previos y construir por etapas autorizadas. Este documento no autoriza modificar escenas, controles, cámara, protagonista o assets, ni realizar commits/pushes.

**Revisión de la planificación inicial:** inspección estática de documentos, escenas, geometría fuente y reservas/coordenadas. No se ejecutó Godot durante aquella fase. La ejecución posterior de la etapa 1 y las correcciones detectadas se documentan a continuación; no confundir la revisión inicial con sus resultados.

## 10. Etapa 1: muestra de proporciones y revisión de reservas

Durante la etapa 1 se autorizó únicamente esta muestra independiente. Abrir `RPG/scenes/pruebas_proporciones.tscn` y ejecutar **F6**. Recorrer con WASD/flechas: a la izquierda hay un cuerpo 4×4, en el centro 4×6 y a la derecha 6×8, todos con puertas cerradas. El selector **«Comparar cubiertas originales»** alterna escala vertical 1 y la proporción de cada edificio, incluido su frontón. No cambia escala horizontal, fuentes, protagonista ni cámara. Sus 48×32 pertenecen solo al laboratorio. Posteriormente el usuario aprobó las proporciones y autorizó la etapa 2; ver sección 11.

### Proporciones aprobadas visualmente por el usuario al iniciar la etapa 2

| Muestra | Muros / cubierta | Escala de cubierta X,Y,Z | Base de cubierta Y / altura total aproximada | Recomendación |
|---|---|---|---|---|
| Vivienda compacta | 4×4 / `Roof_RoundTiles_4x4` | (1, 0.60, 1) | 3,003 / 5,243 | Variante principal para viviendas pequeñas |
| Vivienda alargada | 4×6 / `Roof_RoundTiles_4x6` | (1, 0.60, 1) | 3,003 / 5,234 | Viviendas largas, panadería y talleres; girar junto con el cuerpo si corresponde |
| Edificio grande | 6×8 / `Roof_RoundTiles_6x8` | (1, 0.55, 1) | 3,003 / 5,693 | Taberna y cuerpo del molino, con frontón `Roof_Front_Brick6` |

Muros de aproximadamente 3,125 de alto, sin escalar; colocación de la raíz en Y=0,003 para compensar el mínimo ligeramente negativo de las mallas. Puertas existentes sin escalar: alrededor de 1,118 de ancho y 2,100 de alto, frente a cápsula de 0,64×1,60. El conjunto de tejado y frontones se comprime mediante un padre común para conservar su relación vertical. A escala vertical original, las alturas totales son aproximadamente 6,737, 6,721 y 7,893: predominan mucho más en la vista ortográfica, y la cubierta grande puede salir del encuadre al acercarse a la puerta.

Las capturas Forward Plus/D3D12 muestran puertas y ventanas frontales legibles y muros apoyados; la prueba geométrica obtuvo **12/12 muestras de puerta frontal visibles** en las tres propuestas, también en las originales. Por tanto, la preferencia por reducir altura es artística y de encuadre; no se atribuye a las originales un bloqueo de puerta que no se observó. Con el edificio girado 90°, el faldón oculta una franja superior del muro, pero conserva lectura del cuerpo; revisar el acceso lateral definitivo de herrería/molino cuando se componga, pues la muestra tiene puerta en el frontón. Sigue existiendo oclusión al caminar detrás de edificios cerrados: esta etapa no añade desvanecimiento. No acredita interiores transitables ni revisión visual exhaustiva.

### Conflictos detectados y ajustes propuestos al plano

Registro de la revisión de etapa 1 sobre las coordenadas originales: se revisaron rectángulos de parcelas y corredores con su **anchura completa**, no solo ejes. Las propuestas de esta tabla eran pendientes entonces; la sección 11 registra su resolución y prevalece para la implementación actual.

| Encuentro | Diagnóstico del plano original | Ajuste propuesto |
|---|---|---|
| Taberna / calle norte | Parcela X [-14,-2], Z [-27,-13] invade la calle Z [-14,-10] en 12×1. El edificio no invade la calle. | Recortar el borde sur de parcela a Z=-14,5, manteniendo centro del edificio. No colocar terraza/vallas sobre el corredor. |
| Vivienda E10 / entrada sur | Parcela X [0,10], Z [20,30] invade la entrada X [-2,2] en 2×10. El tejado queda a solo unas 0,24 de su borde oriental; un giro de 8° puede invadir visualmente el camino. | Proponer E10 en (8,25), parcela 8×10, X [4,12]. Trasladar también su acceso y huerto doméstico a X=8. Conserva separación respecto a E11. |
| Ramal E06 / taberna | El ramal de 2,5 con eje X=-14 ocupa desde X=-15,25 hasta X=-12,75, solapando 1,25 de anchura con la parcela de taberna. | Llevar el tramo vertical al eje X=-16,5 y conectar al anillo por Z=-12; mantener libre ese corredor. |
| Ramal E07 / panadería | El eje X=14 y ancho 2,5 penetran 0,25 en el borde este de parcela de panadería (X=13). No alcanzan el cuerpo del edificio. | Llevar ese tramo al eje X=15,5 y conectar al anillo en Z=-12. Recortar además el borde sur de parcela a Z=-14,5 para dejar margen frente a calle. |
| Jardín / acceso E11 | El extremo del ramal a E11, de ancho 2,5, llega a X=19,25; el jardín empieza en X=19 y hay solape de esquina de 0,25×1,25. | Reducir el jardín a 4×4 en (23,15), X [21,25]; conservar el sendero libre. |
| Molino / rueda | La parcela del edificio termina en X=26 y la reserva de rueda empieza en X=25: una unidad compartida intencional para el acople. | Marcar esa franja como servicio del molino, sin vallas ni segunda actividad. Mantener cuerpo 6×8 cardinal: si la puerta se coloca al oeste, montarla en muro lateral; girar todo 90° intercambiaría la huella y exigiría recalcular parcela/ribera. |

En el bloqueo definitivo conviene dar al menos 0,5 de margen paisajístico entre parcela decorada y corredor, además de la anchura libre; reservar separadamente los accesos que atraviesan su propia parcela. No reducir los caminos para esconder estos solapes.

### Evidencia y límite de la validación

- `RPG/tests/validar_proporciones.gd`: **0 fallos** tanto headless como con ventana Forward Plus/D3D12 en Godot 4.7.2; tres edificios, apoyo, animaciones idle/walk en cuatro direcciones, seguimiento, 12 barridos de cápsula, aproximación a puertas, perímetros muestreados y detención real caminando contra fachadas. También comprueba el selector original/propuesta.
- Se generaron 12 capturas en `user://proporciones_<variante>_<vista>.png`: variantes `Vivienda4x4`, `Vivienda4x6`, `Edificio6x8`; vistas `propuesta`, `original`, `lateral`, `orientacion_este`. En la vista `lateral` el personaje está al lado, conservando orientación de cámara; `orientacion_este` gira temporalmente el edificio para inspeccionar el faldón. Las rotaciones y posiciones de captura no se guardan en la escena.
- `RPG/tests/validar_aldea.gd`: **0 fallos, 19 sólidos y 196 superficies con material**, headless. `RPG/tests/validar_pruebas_assets.gd`: **0 fallos, 13 obstáculos y 79 superficies con material**, headless. Ambas pruebas existentes se conservaron sin cambios.
- Revisión de reservas exclusivamente numérica/estática; aún no hay terreno ampliado ni prueba física de todo el plano. No se midió rendimiento ni se implementaron interiores, profesiones o NPCs.
- Reproducir desde la raíz del repositorio: `godot --headless --path RPG --script res://tests/validar_proporciones.gd`. Sin `--headless`, añade las capturas. Las escenas y recursos existentes se preservaron.

## 11. Etapa 2: distribución provisional implementada

Abrir **`RPG/scenes/mundo.tscn` y ejecutar F6** para recorrer el terreno. La escena principal configurada no cambió; instancia `aldea.tscn` a identidad y conserva la aparición (0,0.05,0), el jugador y la cámara. La copia anterior se puede recorrer abriendo `RPG/scenes/respaldos/mundo_etapa1.tscn` con F6, sin intercambiar archivos ni reconfigurar el proyecto.

### Reservas finales de parcelas

Los centros corresponden a futuros edificios. Los límites de reservas pueden ser asimétricos: **no recentrar E01/E02 a partir de sus marcas**. Todos los aleros de las envolventes previstas caben en sus parcelas. Coordenadas de esta tabla con punto decimal para evitar ambigüedad.

| ID | Centro X,Z | Reserva X (mínimo → máximo) | Reserva Z (mínimo → máximo) | Punto de aproximación X,Z |
|---|---|---|---|---|
| E01 | (-8, -20) | -14 → -2.5 | -27 → -14.5 | (-8, -15.2) |
| E02 | (8, -20) | 3 → 12.5 | -26 → -14.5 | (8, -16.2) |
| E03 | (-23, -6) | -29 → -17 | -11 → -1 | (-19.1, -6) |
| E04 | (-23, 7) | -29 → -17 | 2 → 12 | (-19.1, 7) |
| E05 | (21, 8) | 17 → 25 | 3 → 13 | (18.2, 8) |
| E06 | (-24, -23) | -29 → -19 | -29 → -17 | (-21.2, -23) |
| E07 | (21, -24) | 17 → 25 | -29 → -19 | (18.2, -24) |
| E08 | (-24, 23) | -29 → -19 | 18 → 28 | (-24, 20.2) |
| E09 | (-8, 24) | -13 → -3 | 19 → 29 | (-8, 21.2) |
| E10 | (8, 25) | 4 → 12 | 20 → 30 | (8, 22.2) |
| E11 | (18, 24) | 13 → 23 | 19 → 29 | (18, 21.2) |
| E12 | (21, -10) | 16 → 26 | -16 → -4 | (17.2, -10) |

### Ajustes resueltos al llevar el plano al terreno

- **Taberna:** bordes este X=-2.5 y sur Z=-14.5 para separar la reserva de entrada norte, ahora también de 4 unidades, y calle norte. Centro del futuro edificio conservado.
- **Panadería:** borde este X=12.5 y sur Z=-14.5. Ramal noreste sobre X=14.25: un corredor de 2.5 ocupa X=[13,15.5], dejando 0.5 tanto a panadería como a molino (que empieza en X=16). La propuesta anterior de X=15.5 invadía la reserva del molino y se corrigió antes de implantarla.
- **E10:** centro (8,25), reserva 8×10 y huerto alineado en (8,33), conforme al ajuste solicitado.
- **Huerto comunitario:** centro (-32.5,15), tamaño 6×5. Su reserva anterior invadía 3×1 de E08; ahora queda fuera de su parcela y de su ramal. La futura arboleda occidental deberá respetar el huerto y no ocuparlo con árboles.
- **Jardín de hierbas:** 4×4 en (23,15); ramal de 2 unidades fuera de E05 y E11. Los patios profesionales permanecen como espacio dentro/de acceso a sus propias parcelas, sin mobiliario en esta fase.
- **Ribera:** reserva X=[26,36], Z=[-34,34], con cruce futuro X=[26,34], Z=[-2,2]. Todo conserva suelo Y=0. El acople de rueda X=[25,28], Z=[-13,-7] comparte una unidad con su propio molino y parte de la ribera de forma intencional; no hay agua, excavación, barandilla ni colisión adicional.

Los solapes permitidos son accesos que entran en **su propia** parcela/jardín, cruces entre caminos, plaza con sus reservas interiores y reservas técnicas de ribera/rueda/puente. No se excluyen globalmente los accesos del control: su metadato identifica el único propietario permitido. No quedan intersecciones de área positiva entre parcelas/jardines ni entre sus reservas y corredores ajenos.

### Geometría, legibilidad y protección

Suelo: una caja 80×0.5×72 centrada en (0,-0.25,0). Cuatro límites externos de 0.2 de espesor y 3 de altura tienen su cara interior en X=±40 / Z=±36. La cápsula se detiene antes de esos bordes; no se han puesto barreras alrededor del futuro río. Solo hay **cinco cuerpos sólidos** en la aldea: suelo y cuatro límites.

Plaza, 36 tramos de camino y reservas son planos de color mate con líneas finas y rótulos a ras de suelo, sin colisión ni sombras propias. Ocho tramos principales tienen 4 unidades: cuatro lados de anillo, entrada norte, entrada sur, enlace oeste de plaza y conexión oriental/ribera. Accesos: 3 o 2.5; senderos de jardines/mirador/huertos: 2. Los extremos de entradas quedan en Z=±35.5 y la conexión este termina en X=38.5, dentro de límites. No son pavimentos ni senderos artísticos definitivos; las marcas rectas priorizan evaluar espacio y conectividad.

El respaldo `RPG/scenes/respaldos/aldea_etapa1.tscn` se comprobó **idéntico byte a byte** a la aldea anterior antes de sustituirla. Su mundo de respaldo cambia únicamente la referencia de aldea y omite el UID global duplicado de escena; no modifica cámara ni protagonista. La prueba anterior se conserva en `RPG/tests/validar_aldea_anterior.gd` con sus mismas comprobaciones: solo cambian ruta de mundo, nombre de captura e instrucciones de ejecución. No sobrescribir estos respaldos al continuar.

### Resultados de validación

Godot **4.7.2.stable.official.ed1daf0bf**:

| Prueba | Ejecución | Resultado |
|---|---|---|
| `validar_aldea.gd` → `validar_distribucion.gd` | Headless y ventana Forward Plus/D3D12 | **0 fallos**, 5.086 muestras de cápsula/suelo, 36 corredores y 12 barridos contra límites |
| `validar_aldea_anterior.gd` | Headless | **0 fallos**, 19 sólidos y 196 superficies con material en respaldo |
| `validar_pruebas_assets.gd` | Headless | **0 fallos**, 13 obstáculos y 79 superficies con material |
| `validar_proporciones.gd` | Headless | **0 fallos**, tres edificios de la muestra anterior |

La prueba actual verifica tamaño físico/visual y cota del suelo; aparición e identidad; movimiento/animaciones; anchuras visibles contra metadatos; apoyo y libertad de cápsula por toda la extensión y a través de corredores; centros y aleros de 12 parcelas; reservas fuera de ribera; cruces de propiedades; grafo de conectividad a plaza; marcha real a través de ribera y contra los cuatro límites; seguimiento/centrado y materiales. Un control negativo mueve temporalmente E10 sobre la entrada y comprueba que el detector rechaza el solape; luego lo restaura en memoria.

Capturas generadas y revisadas: `user://distribucion_plaza.png`, `distribucion_norte.png`, `distribucion_sur.png`, `distribucion_oeste.png`, `distribucion_ribera.png`, `distribucion_cenital.png` (las seis bajo `user://`). La cenital usa una cámara temporal de diagnóstico; no se guarda ni modifica la cámara principal. Las marcas permiten leer los sectores; revisar manualmente en F6 la sensación de distancia antes de autorizar los edificios. No se certifica aún el recorrido entre futuros obstáculos, navegación de NPCs ni rendimiento del escenario final.

Comando actual desde la raíz: `godot --headless --path RPG --script res://tests/validar_aldea.gd`. Para la composición anterior: sustituir el script por `res://tests/validar_aldea_anterior.gd`. Quitar `--headless` produce capturas. La ampliación de esta fase está terminada como distribución provisional: la etapa 3, los edificios definitivos, la vegetación y el río siguen sin construir.
