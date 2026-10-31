# Estado del proyecto RPG

Última revisión: **30 de octubre de 2026**. Base: etapa 2 preparada y tamaño ortográfico **15 aprobado por el usuario y configurado en la cámara principal**. El selector local 23/19/17/15 de pruebas se conserva, con inicio en 23. Pendiente revisión manual del terreno antes de construir edificios. Las ejecuciones y su alcance se detallan en el registro de progreso.

## 1. Información general

- **Nombre provisional:** `RPG` en `RPG/project.godot`; el README lo denomina «RPG Medieval — Nombre por definir». No hay título definitivo documentado.
- **Motor objetivo:** Godot **4.7.2**, GDScript. La configuración declara `4.7` y Forward Plus; el inventario registra la versión exacta de una auditoría previa: `4.7.2.stable.official.ed1daf0bf`.
- **Renderizado y física:** Forward Plus, controlador Windows `d3d12`, Jolt Physics para 3D.
- **Tipo y objetivo:** proyecto inicialmente escolar de RPG medieval de fantasía y simulación de vida. Entorno 3D, personajes pixel art 2D dentro del mundo y cámara ortográfica inclinada; explorar y participar en la vida de una aldea. No está previsto combate tradicional.
- **Visión futura:** NPCs con personalidad, rutinas, memoria, relaciones y comportamientos; diálogos, interacciones sociales, profesiones como herrería y agricultura, minijuegos, misiones y eventos. Estos sistemas no están implementados.
- **Continuidad:** leer primero `AGENTS.md`. El inventario detallado está en `RPG/docs/inventario_assets.md`.

## 2. Funcionalidades implementadas en archivos

| Sistema | Estado comprobado por inspección | Archivos responsables |
|---|---|---|
| Escenario principal | `Mundo` instancia `Aldea` y `Jugador`, integra cámara, luz y ambiente. Su UID coincide con la escena inicial configurada. | `RPG/project.godot`, `RPG/scenes/mundo.tscn`. |
| Movimiento del protagonista | `CharacterBody3D`, velocidad configurable, aceleración/frenado, gravedad, desplazamiento relativo a cámara y `move_and_slide()`. Acciones para WASD y flechas. | `RPG/scripts/jugador.gd`, `RPG/scenes/jugador.tscn`, `RPG/project.godot`. |
| Animación direccional | Ocho animaciones: idle y walk en arriba, abajo, izquierda y derecha. `AnimatedSprite3D` con billboard y filtrado nearest; dos hojas de sprites. | `RPG/scenes/jugador_frames.tres`, `RPG/scenes/jugador.tscn`, `RPG/scripts/jugador.gd`. |
| Cámara de seguimiento | Ortográfica, tamaño aprobado 15, inclinación configurada de aproximadamente -32° respecto a la horizontal; objetivo `Jugador` y seguimiento suavizado exponencial conservados. El tamaño se configura solo en la escena; el script no lo sobrescribe. | `RPG/scenes/mundo.tscn`, `RPG/scripts/camara_seguimiento.gd`. |
| Selector local de cámara en pruebas | Panel con opciones 23/19/17/15 mediante ratón o teclas 1–4. Arranca en 23, cambia únicamente `Camera3D.size` de esa escena y conserva seguimiento/orientación. Sin foco de teclado en botones para mantener WASD/flechas. No altera la cámara del mundo. | `RPG/scenes/pruebas_assets.tscn`, `RPG/scenes/selector_distancia_assets.gd`. |
| Colisiones actuales | Cápsula original del jugador; suelo continuo y cuatro límites externos en aldea. Los marcadores no colisionan. La composición respaldada conserva sus sólidos originales. | `RPG/scenes/jugador.tscn`, `RPG/scenes/aldea.tscn`, `RPG/scenes/respaldos/`. |
| Distribución provisional de aldea | Terreno 80×72, plaza 20×18, ocho tramos principales de 4 unidades, accesos/senderos (36 tramos en total), 12 parcelas y reservas de jardines/ribera. No hay edificios definitivos. | `RPG/scenes/aldea.tscn`; plano actualizado en `RPG/docs/plano_aldea.md`. |
| Iluminación y ambiente | Luz direccional cálida con sombras y `WorldEnvironment` con fondo e iluminación ambiental. No hay ciclo día/noche. | `RPG/scenes/mundo.tscn`. |
| Inicio del mundo | Solo mensajes de bienvenida en `_ready()`; no implementa simulación social. | `RPG/scripts/mundo.gd`. |
| Pruebas automatizadas | La entrada actual verifica la distribución con suelo, movimiento, animaciones, cámara, límites, parcelas, accesos y conectividad. Las comprobaciones anteriores de cuatro edificios se conservan contra el respaldo. Ambas aprobadas en esta etapa; ver registro. | `RPG/tests/validar_aldea.gd`, `RPG/tests/validar_distribucion.gd`, `RPG/tests/validar_aldea_anterior.gd`. |

`RPG/scenes/casa_modular.tscn` contiene una casa con muros, puerta, ventana, tejado y esquinas, instanciada en `RPG/scenes/pruebas_assets.tscn`. `RPG/scenes/pruebas_proporciones.tscn` conserva las tres muestras comparativas. Ninguna sustituye al mundo principal ni representa edificios definitivos nuevos en la distribución.

## 3. Estado actual de la aldea

La escena `RPG/scenes/aldea.tscn` presenta la **distribución provisional de la etapa 2**, no la aldea artística definitiva:

- Terreno **80×72** centrado, superficie Y=0, caja de 0,5 de grosor y cuatro límites con cara interior en X=±40 / Z=±36. Solo suelo y límites son sólidos.
- Plaza central **20×18**, anillo y conexiones principales de 4 unidades; accesos de 2,5–3 y senderos de 2. Hay 36 tramos de marcadores planos conectados, sin colisión.
- Doce parcelas E01–E12: seis viviendas y seis establecimientos previstos. E10 está en **(8,25)**. Marcas finas y rótulos a ras de suelo; todavía no hay edificios definitivos ni interiores.
- Jardines/huertos, fuente/mercado y ribera/puente/rueda son reservas visuales. La franja oriental X=[26,36] permanece nivelada y transitable, sin agua, cauce ni barreras.
- Identidad de `Aldea`, aparición (0,0.05,0), protagonista, controlador, cámara principal, luz y configuración conservados en `mundo.tscn`, sin editar ese archivo.
- Composición anterior de 32×32, cuatro edificios y decoración preservada en `RPG/scenes/respaldos/aldea_etapa1.tscn` (copia exacta). Su mundo independiente es `RPG/scenes/respaldos/mundo_etapa1.tscn`; ejecutarlo con F6 permite revisarla sin sustituir archivos.

La nueva distribución aprobó ejecución headless y gráfica. Las marcas no equivalen a profesiones, NPCs, mercado funcional ni cultivo. La circulación entre futuros edificios y su oclusión deberá revisarse al construir cada etapa.

## 4. Assets disponibles

Recuento local repetido en esta revisión, coincidente con el inventario:

| Paquete identificado por el proyecto | Carpeta | glTF | BIN | PNG |
|---|---|---:|---:|---:|
| Quaternius Medieval Village MegaKit | `RPG/assets/aldea/` | 176 | 176 | 54 |
| Quaternius Stylized Nature MegaKit | `RPG/assets/naturaleza/` | 68 | 68 | 20 |
| Quaternius Fantasy Props MegaKit | `RPG/assets/objetos_medievales/` | 94 | 94 | 13 |
| Sprites del protagonista | `RPG/assets/personajes/` | 0 | 0 | 2 |
| **Total** | | **338** | **338** | **89** |

Los sprites usados son `RPG/assets/personajes/protagonista/Character_Idle.png` y `RPG/assets/personajes/protagonista/Character_Walk.png`.

Consultar `RPG/docs/inventario_assets.md` para modelos concretos, materiales, duplicados, procedencia pendiente y piezas especiales no identificadas. Su auditoría histórica informa importación/instanciación headless de 338 modelos sin fallos y carga de 89 imágenes; **no se repitió esa prueba en esta tarea**, ni acredita por sí sola escala, transparencia o calidad gráfica.

**`RPG/assets/` está excluida intencionalmente de Git** por `RPG/.gitignore`; se comprobó la regla y que no hay assets versionados. No cambiarla ni subir recursos a GitHub. Se necesita disponer de ellos localmente para abrir o ejecutar todas las escenas. No se verificaron licencias en esta revisión; el inventario no encontró textos de licencia en las carpetas auditadas.

## 5. Problemas, inconsistencias y limitaciones pendientes

1. **README desactualizado:** `README.md` describe GameMaker, GML y estructura/ejecución que no corresponden al proyecto Godot actual. También contiene un flujo de commits/pushes que no constituye autorización. Se registra sin modificarlo en esta tarea.
2. **Versión exacta:** `project.godot` declara 4.7, no 4.7.2. En la tarea de escena de assets se localizó el ejecutable fuera de `PATH` y se confirmó `4.7.2.stable.official.ed1daf0bf`.
3. **Colisiones de nuevos recursos:** el inventario informa cero `CollisionShape3D` en los 338 modelos originales. La aldea sí tiene colisiones añadidas; los nuevos obstáculos transitables o sólidos necesitarán envoltorios y pruebas. No colisionar automáticamente toda la vegetación.
4. **Revisión visual pendiente:** escala frente al protagonista, pivotes, encajes, normales, ventanas, enredaderas, hojas/flores con transparencias, sombras, legibilidad y oclusión del sprite. Headless no sustituye revisión gráfica D3D12. No se midió rendimiento real.
5. **Elementos especiales:** el inventario no identifica agua/cauce/material de río, puente dedicado, rueda hidráulica ni mecanismo de molino. Hay módulos que podrían servir de base, no conjuntos listos. También quedan por preparar fragua/horno, huertos y sus etapas de cultivo, e interiores/interacciones.
6. **Escena independiente creada:** `RPG/scenes/pruebas_assets.tscn`, con prueba propia aprobada; quedan ajustes artísticos y recorrido manual completo. Los ocho fallos del mundo quedaron resueltos al restaurar las transformaciones accidentales de aldea y protagonista; ver registro.
7. **Sistemas de juego futuros ausentes:** NPCs, navegación de NPCs, rutinas/memoria/relaciones, diálogos, profesiones, minijuegos, inventario de jugador, misiones y eventos no se identificaron en el código actual. El inventario de assets es documentación, no un sistema de inventario jugable. No hay backend ni integración LLM implementada.
8. **Trabajo previo sin consolidar en Git:** al comenzar esta tarea ya existían cambios en `RPG/.gitignore`, `RPG/project.godot`, `RPG/scenes/mundo.tscn` y `RPG/scripts/camara_seguimiento.gd`, y archivos no versionados de aldea, casa modular, pruebas y documentación. Se preservaron; comprobar siempre el estado actual antes de trabajar, pues esta nota es una fotografía histórica.

## 6. Objetivo visual: referencia artística, no escena terminada

La referencia conceptual aprobada descrita por el usuario es una aldea medieval de fantasía acogedora, con plaza central, casas de madera y piedra, taberna, herrería, mercado, árboles, jardines, huertos, caminos naturales, río, puente y molino de agua.

**No se encontró la imagen conceptual en el repositorio durante esta inspección.** La descripción anterior procede del usuario, no de una inspección de la imagen. Los edificios y la plaza del prototipo no equivalen a haber alcanzado ese objetivo artístico.

## 7. Próximas etapas y siguiente objetivo

**Cámara aprobada:** el usuario eligió 15 tras comparar las cuatro vistas; ya está aplicado en el mundo y registrado en `AGENTS.md`. Se conserva `RPG/scenes/pruebas_assets.tscn` con su selector 23/19/17/15 para futuras comparaciones; su inicio en 23 es exclusivo de laboratorio.

**Prioridad actual:** revisar con F6 `RPG/scenes/mundo.tscn`, que ya contiene la distribución de etapa 2. El usuario aprobó cubiertas Y=0.60 para 4×4/4×6 y Y=0.55 para 6×8: aplicar esas proporciones al construir definitivamente. Las correcciones de parcelas y corredores están implementadas y documentadas en sección 11 del plano. No se inició etapa 3; esperar revisión del terreno antes de construir el núcleo de edificios.

**Secuencia de trabajo, pendiente de la revisión del terreno para continuar:**

1. **Completado:** crear `RPG/scenes/pruebas_assets.tscn` sin alterar el mundo existente.
2. **Etapa 1 aprobada:** proporciones de cubiertas confirmadas por el usuario. Conservar las muestras para verificar encajes, transparencias y oclusión de futuras variantes.
3. **Etapa 2 preparada y validada:** terreno y reservas reorganizados con respaldo previo. Pendiente revisión manual de distancias y distribución antes de la siguiente construcción.
4. Construir/ampliar la plaza y los caminos hacia la composición definitiva, partiendo de los elementos básicos ya existentes.
5. Mejorar los edificios y añadir objetos decorativos; preparar mercado y espacios de actividad según el diseño.
6. Incorporar vegetación y naturaleza preservando accesos y legibilidad.
7. Construir río, puente y molino; primero resolver las piezas y materiales especiales faltantes.
8. Desarrollar posteriormente NPCs, profesiones y simulación social; los diálogos, minijuegos, misiones y eventos pertenecen a esa visión futura, no al estado terminado.

**Propuestas técnicas del inventario, aún no decisiones implementadas:** usar una casa, un árbol, un puesto y el protagonista como muestra inicial; fijar medidas de puertas y caminos; crear envoltorios con colisiones simples; medir oclusión y rendimiento antes de densificar vegetación. MultiMesh, shaders de agua u otras herramientas requieren evaluación posterior; no son dependencias actuales.

## 8. Validación y registro de progreso

### 30 de octubre de 2026 — documentación permanente inicial

- Creados `AGENTS.md` en la raíz del repositorio y `RPG/docs/estado_proyecto.md` como referencia de progreso.
- Inspeccionados configuración, escenas, scripts, animaciones, prueba e inventario; repetidos los recuentos de assets y comprobada su exclusión de Git.
- Registradas reglas permanentes de actualización documental y separación entre visión, implementación y validación.
- No se ejecutó el motor ni `RPG/tests/validar_aldea.gd` en esta revisión documental. No se atribuyen resultados nuevos de ejecución a la prueba existente. El comando orientativo y sus requisitos se conservan en `AGENTS.md`.
- Alcance exclusivamente documental: sin cambios a escenas, scripts, controles, cámara, protagonista, modelos ni configuración funcional. Sin commits ni pushes.

### 30 de octubre de 2026 — escena independiente de pruebas de assets

- Creada `RPG/scenes/pruebas_assets.tscn`: suelo de 32 × 32, casa modular al noroeste, mercado al noreste, herrería exterior al suroeste y naturaleza irregular al sureste. Abrir la escena y ejecutarla como escena actual (F6), no cambiar la escena principal.
- Reutiliza `casa_modular.tscn`, protagonista y script/configuración de seguimiento ortográfico (tamaño 23); conserva luz cálida, sombras y ambiente de `mundo.tscn`. No se modificaron sus archivos originales ni los controles.
- Modelos de arquitectura, mediante la casa existente: `Wall_Plaster_Straight`, `Wall_Plaster_Door_Flat`, `Wall_Plaster_Window_Wide_Flat`, `Door_1_Flat`, `Window_Wide_Flat1`, `Roof_RoundTiles_4x4`, `Roof_Front_Brick4`, `Corner_Exterior_Wood`.
- Mercado: `Stall_Empty`, `Barrel`, `Barrel_Apples`, `Crate_Wooden`, `FarmCrate_Apple`. Taller: `Anvil_Log`, `Workbench`, `Whetstone`, `Axe_Bronze`, `Pickaxe_Bronze`. Naturaleza: `CommonTree_1/3/5`, `Bush_Common`, `Bush_Common_Flowers`, `Flower_3_Group`, `Grass_Common_Short`, `Rock_Medium_1`. Todos son recursos locales existentes; sin modificaciones a assets.
- Colisiones: cajas simples para casa cerrada, puesto y mobiliario, cilindros de troncos, cajas de rocas, suelo y límites. Vegetación baja sin colisión. No hay interiores ni mercado/herrería funcionales.
- Añadido `RPG/tests/validar_pruebas_assets.gd`. Ejecutado con Godot `4.7.2.stable.official.ed1daf0bf` en headless y con ventana Forward+/D3D12: **0 fallos, 13 obstáculos comprobados y 79 superficies con material**. Comprueba suelo, movimiento y dirección visual en cuatro sentidos, seguimiento, barridos reales de cápsula y pasos muestreados. La primera ejecución detectó un paso ocupado junto a las manzanas; se separó el barril y ambas ejecuciones finales aprobaron.
- Capturas generadas y examinadas: `user://pruebas_assets_arquitectura.png`, `user://pruebas_assets_mercado.png`, `user://pruebas_assets_herreria.png`, `user://pruebas_assets_naturaleza.png`. No equivale a recorrido manual exhaustivo ni medición de rendimiento. La casa tiene cubierta visualmente alta; revisar proporción antes de cambiar módulos. Flores/hierba se redujeron localmente para no alcanzar altura humana; algunos detalles resultan pequeños con tamaño 23. Vegetación saturada frente a arquitectura y suelo: evaluar armonía sin cambiar todavía iluminación/materiales originales. Posible oclusión al pasar detrás de copas y edificios; no hay sistema de desvanecimiento.
- Comando reproducible desde la raíz, con `godot` como ejecutable local: `godot --headless --path RPG --script res://tests/validar_pruebas_assets.gd`. Sin `--headless` guarda las cuatro capturas.
- También ejecutada `validar_aldea.gd`: **8 fallos**, relativos a seis obstáculos (Taberna, ViviendaEste, Valla07/08/09, CajaHuerto), caminos y accesos. No se corrigieron por estar fuera de alcance. Los hashes de todos los archivos previos coincidían con la captura inicial antes de actualizar esta documentación; no se atribuyen estos fallos a la escena independiente.
- Se preservaron rama, cambios previos, escena principal y assets. Solo se añadieron escena/prueba y se actualizaron `AGENTS.md` y este estado. Sin commits ni pushes. No quedaron procesos de prueba pendientes; se conservó el editor que estaba abierto.

### 30 de octubre de 2026 — restauración de transformaciones accidentales

- Cambiadas únicamente dos transformaciones en `RPG/scenes/mundo.tscn`: instancia `Aldea` a identidad (posición y rotación cero, escala unitaria) y aparición de `Jugador` a `(0, 0.05, 0)`, sin rotación y con escala unitaria. `Mundo` ya tenía transformación identidad; cámara y contenido local de la aldea conservados.
- El punto de aparición del jugador se recuperó exactamente del commit `d928ffd`. La aldea aún no está versionada: su identidad se reconstruyó a partir de la raíz de su escena, el terreno horizontal documentado, el diagnóstico previo aprobado al nivelarla en memoria y la confirmación del usuario sobre el cambio accidental; no se presenta como recuperación exacta desde Git.
- Ejecutado `RPG/tests/validar_aldea.gd` sin modificarlo, con Godot `4.7.2.stable.official.ed1daf0bf`: **0 fallos, 19 sólidos y 196 superficies con material**, tanto headless como con ventana Forward+/D3D12. Aprobados apoyo sobre terreno, movimiento, animaciones, seguimiento y centrado de cámara, caminos y accesos. Desaparecieron los ocho fallos anteriores.
- Revisada la captura final `user://aldea_renovada.png`: protagonista visible en el centro de la plaza y terreno nivelado. No equivale a recorrido manual exhaustivo. La ejecución headless restringida emitió errores de acceso al log y certificados del sistema; la ejecución con ventana y permisos aprobados finalizó correctamente.
- Sin cambios a geometría, distribución, assets, scripts, pruebas, controles ni escena principal configurada. Cambios previos preservados; sin commits ni pushes. `AGENTS.md` no requiere actualización: no cambian arquitectura ni reglas permanentes.

### 30 de octubre de 2026 — plano de ampliación pendiente de aprobación

- Creado `RPG/docs/plano_aldea.md`: terreno propuesto de 80 × 72 unidades, 12 edificios (seis viviendas y seis establecimientos, incluido molino), plaza de 20 × 18, tres puestos, anillo de caminos de 4 unidades, jardines/huertos y reserva oriental de ribera de 10 unidades.
- Inspeccionadas escenas y recursos locales; medidas estáticas de 17 modelos mediante límites de geometría glTF sin transformaciones de nodo. El plano contempla aleros reales, cápsula de 0,64 de diámetro y 1,60 de altura, escala del sprite y cámara existentes. Coordenadas y parcelas son propuestas, no nuevas posiciones implementadas.
- Identificadas dependencias pendientes para fuente, agua/cauce, rueda de molino, horno/fragua y cultivos; puente y edificios requieren composición modular. Profesiones, NPCs y rutinas solo tienen reservas espaciales.
- Validación de esta fase exclusivamente documental/estática, sin ejecutar Godot ni realizar revisión gráfica nueva. Los 0 fallos de la aldea pertenecen a la validación anterior, no al plano.
- Solo se creó el plano y se actualizó este estado. `AGENTS.md` revisado sin cambios: no se ha adoptado una decisión técnica permanente nueva. Sin modificaciones a escenas, scripts, assets, controles, cámara ni protagonista; trabajo previo preservado, sin commits ni pushes. Siguiente paso: aprobación del usuario antes de implementar.

### 30 de octubre de 2026 — etapa 1, comparación de proporciones

- El usuario aprobó el plano general y autorizó esta etapa independiente. Creada `RPG/scenes/pruebas_proporciones.tscn`: laboratorio de 48×32 con tres cuerpos modulares, 4×4 en (-13,-6), 4×6 en (0,-6) y 6×8 en (14,-6), muros sin escalar de aproximadamente 3,125 de altura y puertas originales. Raíces en Y=0,003 para apoyar las mallas; colisiones de caja cubren los muros exteriores, con perímetros y accesos despejados. Puertas cerradas, sin interiores.
- Propuesta artística: cubierta 4×4 para viviendas compactas y 4×6 para viviendas alargadas/talleres, ambas con escala vertical 0,60; 6×8 para taberna/molino con 0,55. Solo se escalan verticalmente tejado y frontones mediante un padre común a Y=3,003 global. Alturas totales aproximadas: 5,243 / 5,234 / 5,693. Se conserva la huella horizontal real, con aleros; frontón `Roof_Front_Brick4` en las pequeñas y `Roof_Front_Brick6` en la grande. No son proporciones aprobadas definitivamente.
- `RPG/scenes/pruebas_proporciones.gd` controla únicamente un selector visual de la muestra que alterna original Y=1 y propuesta. Abrir la escena y ejecutar F6; recorrer con los controles existentes y usar «Comparar cubiertas originales». Reutiliza jugador, animaciones, movimiento y configuración/script de cámara sin editar sus fuentes; aparición de laboratorio en (0,0.05,3). No se cambió la escena principal configurada.
- Añadido `RPG/tests/validar_proporciones.gd`. Godot confirmado como `4.7.2.stable.official.ed1daf0bf`. Resultado final **0 fallos en headless y con ventana Forward Plus/D3D12**: apoyo, escala/cápsula/velocidad conservadas, idle/walk en cuatro direcciones, seguimiento, tres edificios con 12 barridos de cápsula, acceso desde paseo, perímetros muestreados, detención caminando contra fachada y selector original/propuesta. Las tres propuestas tienen **12/12 puntos de puerta frontal sin oclusión por cubierta** en el muestreo geométrico. Las originales también: la recomendación responde a proporción/encuadre, no a una supuesta puerta bloqueada.
- Generadas 12 capturas en `user://proporciones_<variante>_<vista>.png`, con variantes `Vivienda4x4`, `Vivienda4x6`, `Edificio6x8` y vistas `propuesta`, `original`, `lateral`, `orientacion_este`. Revisadas comparaciones frontales y de faldones con edificio girado, sin cambiar orientación de cámara. Las fachadas frontales conservan lectura; los faldones ocultan una franja superior lateral. La cubierta original grande puede salir del encuadre cerca de la puerta. Al pasar detrás de edificios permanece oclusión normal; no se añadió desvanecimiento. No equivale a recorrido manual exhaustivo ni verificación de puertas laterales definitivas.
- Repetidas sin modificar las pruebas existentes: `validar_aldea.gd` **0 fallos, 19 sólidos, 196 superficies con material**; `validar_pruebas_assets.gd` **0 fallos, 13 obstáculos, 79 superficies con material**, ambas headless con código de salida 0. La primera ejecución restringida de la nueva prueba emitió errores de log/certificados del sistema; la repetición con permisos y la ejecución gráfica final terminaron sin esos errores.
- Revisión estática de parcelas/corredores con anchura completa: solapes de taberna con calle norte (12×1), E10 con entrada sur (2×10), ramal E06 con parcela de taberna (1,25 de anchura), ramal E07 con panadería (0,25) y esquina del jardín con ramal E11 (0,25×1,25). Son conflictos de reservas, no nuevas colisiones físicas demostradas. Propuestas detalladas en sección 10 del plano: recortar bordes sur de taberna/panadería, E10 a (8,25) con parcela 8×10 y huerto alineado, ejes de ramales a X=-16,5 / 15,5, jardín 4×4 en (23,15), y acople rueda/molino reservado sin girar su huella inadvertidamente.
- Solo se añadieron la escena, su controlador visual y su prueba; se actualizaron el plano y este estado. `AGENTS.md` revisado sin cambios porque no hay nueva arquitectura ni proporciones permanentes aprobadas. Escenas anteriores, mundo, aldea, protagonista, cámara, configuración, assets y cambios previos preservados. Sin commits ni pushes. Siguiente paso: revisión/aprobación visual del usuario antes de la etapa 2.

### 30 de octubre de 2026 — etapa 2, terreno y distribución inicial

- Aprobadas por el usuario las cubiertas 4×4/4×6 con Y=0.60 y 6×8 con Y=0.55 para los futuros edificios definitivos. Registradas como decisión permanente en `AGENTS.md` y en metadatos de las parcelas; todavía no se construyeron edificios.
- Antes de sustituir la composición se creó `RPG/scenes/respaldos/aldea_etapa1.tscn`, comprobada idéntica byte a byte a la aldea existente. `RPG/scenes/respaldos/mundo_etapa1.tscn` conserva la composición ejecutable con cámara/protagonista originales: solo cambia la referencia de aldea y elimina el UID global duplicado de la escena. No requiere restaurar archivos para abrirla con F6.
- Sustituido el contenido de `RPG/scenes/aldea.tscn` por terreno plano 80×72, plaza 20×18, 36 tramos conectados (ocho principales de 4 unidades), 12 parcelas, cinco reservas de jardín/huertos/mirador y reservas técnicas de ribera/puente/rueda/fuente/mercado. Solo suelo y cuatro límites tienen colisión. Marcas de planos mates, líneas finas y rótulos a ras de suelo; sin muros, cubos de edificios, assets nuevos ni obstáculos de río.
- E10 en (8,25), parcela 8×10 y huerto alineado. Recortadas reservas de taberna/panadería; ramal NO en X=-16.5 y NE en X=14.25, con 0.5 de margen entre panadería y molino. Jardín 4×4 en (23,15). Huerto comunitario a (-32.5,15), 6×5, tras detectar que la reserva anterior invadía E08. Todos los demás centros de edificios conservados. Coordenadas/bordes exactos y motivos en sección 11 del plano.
- Se conservaron los cinco aspectos protegidos en sus archivos: `mundo.tscn` (incluida identidad de `Aldea` y aparición (0,0.05,0)), protagonista, animaciones, controlador y cámara. El mundo existente incorpora la nueva distribución por su referencia de aldea; no se cambió la escena principal configurada, iluminación ni assets originales.
- `RPG/tests/validar_aldea.gd` es ahora entrada de `validar_distribucion.gd`; la prueba original se conserva con todas sus comprobaciones en `validar_aldea_anterior.gd` contra el mundo respaldado. Solo cambian instrucciones de ejecución, ruta de mundo y nombre de captura. No se descartó la cobertura de cuatro edificios, sólidos y materiales.
- Godot `4.7.2.stable.official.ed1daf0bf`: distribución **0 fallos** en headless y con ventana Forward Plus/D3D12, **5.086 muestras de suelo/cápsula, 36 corredores y 12 barridos contra límites**. Verifica apoyo en toda la extensión y corredores, dimensiones físicas/visuales, origen, movimiento/idle/walk, cámara, centros/alero de parcelas, reservas fuera de ribera, conectividad a plaza, materiales, cruce real de ribera y detención real contra límites. Detector de solapes comprobado con control negativo: E10 temporalmente sobre entrada sur. Los accesos propios son excepciones explícitas por propietario; no se ignoraron todos los accesos.
- Regresiones headless: respaldo anterior **0 fallos, 19 sólidos, 196 superficies con material**; assets **0 fallos, 13 obstáculos, 79 superficies con material**; proporciones **0 fallos, tres edificios**. Código de salida 0 en las ejecuciones finales. El nuevo validador requirió corregir dos anotaciones de tipo antes de ejecutarse; no eran fallos de recursos ni de geometría.
- Generadas y revisadas capturas `user://distribucion_plaza.png`, `user://distribucion_norte.png`, `user://distribucion_sur.png`, `user://distribucion_oeste.png`, `user://distribucion_ribera.png` y `user://distribucion_cenital.png`. La última usa cámara temporal de diagnóstico no guardada. La visual permite leer reservas y recorridos; no equivale a revisión manual exhaustiva, navegación de NPCs ni medición de rendimiento con edificios definitivos.
- Actualizados `AGENTS.md` (arquitectura/validaciones vigentes, respaldos y proporciones permanentes), `RPG/docs/plano_aldea.md` y este estado. Se preservaron rama `main`, cambios previos y escenas de muestras. Sin commits ni pushes. **Siguiente paso:** abrir `RPG/scenes/mundo.tscn` con F6 y revisar distancias/recorridos antes de autorizar la etapa 3.

### 30 de octubre de 2026 — selector de distancia en pruebas de assets

- Añadido a `RPG/scenes/pruebas_assets.tscn` un panel discreto en la esquina superior izquierda con título «DISTANCIA DE CÁMARA», cuatro opciones exclusivas y texto de selección: 23 Original, 19 Intermedia, 17 Cercana y 15 Muy cercana. Instrucciones visibles: ratón o teclas 1–4; WASD/flechas para caminar. Arranca en 23 cada vez que se ejecuta con F6.
- Creado `RPG/scenes/selector_distancia_assets.gd`, exclusivo de ese panel. Cambia instantáneamente solo `size` de la cámara local; conserva el seguimiento suavizado existente, inclinación, orientación, desplazamiento y altura de encuadre. Los botones no reciben foco; el manejador consume únicamente las teclas 1–4, sin modificar el mapa de entradas. No hay transición de zoom ni persistencia de selección.
- Validación auxiliar temporal fuera del repositorio, sin modificar pruebas existentes: eventos de clic dirigidos al viewport, teclas 1–4 y selección exclusiva; comprobación de que el clic no mueve al protagonista ni captura foco; WASD y cuatro flechas con walk/idle en los cuatro tamaños; convergencia del seguimiento, orientación invariable, cápsula/escala originales y barridos contra casa/árbol en cada vista. Compara transformaciones de todas las mallas antes/después para confirmar la distribución intacta.
- Godot `4.7.2.stable.official.ed1daf0bf`: prueba específica y regresión completa `RPG/tests/validar_pruebas_assets.gd` aprobadas en headless y con ventana Forward Plus/D3D12: **0 fallos; 13 obstáculos y 79 superficies con material** en la regresión. Logs finales sin errores ni advertencias. La comprobación inicial detectó un tipo de control no disponible, sustituido por `CheckBox` con `ButtonGroup`; los eventos de ratón de la prueba se dirigieron explícitamente al viewport para funcionar también sin ventana.
- Generadas 16 capturas comparativas `user://distancia_<tamano>_<zona>.png` para tamaños 23, 19, 17, 15 y zonas `casa`, `mercado`, `herreria`, `naturaleza`, además de las cuatro capturas habituales de la prueba existente. Revisado el panel y el encuadre en las comparaciones: el protagonista permanece fuera del panel. Con 15 la cubierta alta original de la casa puede salir del borde superior al acercarse; árboles y geometría conservan su oclusión existente. El acercamiento mejora el tamaño aparente del sprite, pero no cambia sus píxeles, escala ni proporciones físicas. No es aprobación de una distancia ni recorrido manual exhaustivo.
- Archivos de producto: solo escena de assets y script local nuevo; este estado registra el resultado. Mundo, aldea, cámara compartida, protagonista, colisiones, modelos, materiales, distribución, configuración y cambios previos preservados. `AGENTS.md` revisado sin cambios porque no se eligió una distancia permanente. `RPG/docs/plano_aldea.md` revisado sin cambios: la distribución y las proporciones aprobadas no cambian. Sin commits ni pushes.

### 30 de octubre de 2026 — tamaño ortográfico principal aprobado: 15

- El usuario eligió definitivamente 15 tras la comparación visual. Cambiada únicamente la propiedad `CamaraPrincipal.size` de 23.0 a 15.0 en `RPG/scenes/mundo.tscn`. Conservadas orientación, inclinación, desplazamiento, altura de encuadre y seguimiento suave; `RPG/scripts/camara_seguimiento.gd` inspeccionado sin cambios porque no fija ni sobrescribe el tamaño.
- Actualizada solo la expectativa de tamaño en `RPG/tests/validar_distribucion.gd`: ahora exige 15, manteniendo inclinación y todas las demás comprobaciones. La entrada `validar_aldea.gd` sigue delegando en esa prueba. Respaldos, muestras y selector de distancias conservados sin modificaciones.
- Godot `4.7.2.stable.official.ed1daf0bf`: `validar_aldea.gd` **0 fallos** tanto headless como con ventana Forward Plus/D3D12, con código de salida 0; **5.086 muestras de suelo/cápsula, 36 corredores y 12 barridos contra límites**. Aprobados inicio con tamaño 15, movimiento/idle/walk, seguimiento/centrado, apoyo, límites, reservas y materiales. Revisada la captura gráfica de plaza con el encuadre más cercano. No equivale a recorrido manual exhaustivo ni validación de edificios futuros.
- Actualizados `AGENTS.md` y este estado; corregida también la referencia vigente de cámara en `RPG/docs/plano_aldea.md`, sin cambiar distribución. Protagonista, scripts, sprite, colisiones, aldea, assets y selector preservados. Cambios previos conservados; sin commits ni pushes.

Mantener este documento al completar etapas, cambiar prioridades/estado, detectar o resolver problemas y definir el siguiente objetivo. Revisar también `AGENTS.md` y actualizarlo únicamente si cambia información permanente; evitar duplicar el inventario o convertir las instrucciones en un historial.
