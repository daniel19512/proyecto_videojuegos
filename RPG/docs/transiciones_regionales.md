# Transiciones regionales — fases 6B, 6D y 6E

Estado vigente, 5 de noviembre de 2026: **Montañas ↔ Aldea, Campos y Granjas ↔ Aldea ↔ Bosque ↔ Ruinas Antiguas activas**. Minas e interiores siguen desconectados. Configuración de Montañas en la sección 6F al final y en `RPG/docs/plano_montanas.md`. Las secciones anteriores conservan sus resultados históricos; las referencias a este/sur desconectados corresponden a aquellas fases. Mapas anteriores, laguna, cierres y gestor original conservados.

## Arquitectura y flujo

`RPG/project.godot` registra `GestorRegiones` como Autoload. `RPG/scripts/gestor_regiones.gd` conserva un CanvasLayer 100 con ColorRect negro anclado a toda la pantalla. La escena inicial sigue siendo `RPG/scenes/mundo.tscn`; `RPG/scenes/mundo_bosque.tscn` hereda la composición existente de `pruebas_bosque.tscn`, sin copiar escenario, personaje ni cámara a archivos nuevos. Las escenas de contenido `aldea.tscn` y `bosque.tscn` no se modifican.

Cada mundo jugable contiene `Region` con `RPG/scripts/region_config.gd`: `id_region`, rutas de jugador/cámara y diccionario `entradas` que relaciona identificadores con Marker3D. `GestorRegiones.region_actual` consulta ese ID; no deduce regiones por nombres de archivo ni guarda coordenadas en el gestor.

Cada Area3D con `RPG/scripts/salida_region.gd` define `escena_destino`, `entrada_destino` y `marcador_salida`. En `_ready()` se apoya en el marcador existente y desplaza el detector +1 Y. Solo acepta el cuerpo del protagonista configurado de la escena actual, no decoración ni otros cuerpos. La solicitud se reserva inmediatamente y la ejecución se difiere fuera del callback de física.

1. La entrada caminando solicita el destino; solicitudes simultáneas devuelven false.
2. Se verifica existencia de ruta y configuración de origen; se congelan física del jugador y seguimiento/orbita de cámara, anulando velocidad.
3. Fundido a negro **0,35 segundos** mediante Tween.
4. Bajo negro se carga e instancia la escena; se verifica configuración, entrada, jugador y cámara antes de retirar el origen.
5. Se retira el mundo anterior del árbol, se añade el nuevo y se actualiza `current_scene`. La nueva instancia crea su único jugador/cámara originales. El origen se libera; nunca hay dos protagonistas simultáneamente dentro del árbol.
6. El jugador se coloca en el Marker3D +0,05 Y; velocidad cero, animación idle hacia el interior. La órbita vuelve a ángulo horizontal 0, centro en el jugador y tamaño original 15, usando la API existente del controlador. No se altera ningún script del personaje o cámara.
7. Tras una señal real de `physics_frame`, fundido de entrada **0,35 segundos**, restauración del procesamiento y señal `finalizada`. Los estados de acciones se liberan al salir la cámara original, sin borrar eventos InputMap.

La carga es síncrona bajo negro: la pausa de carga puede prolongar el negro en equipos lentos. No se añaden hilos, pantallas complejas ni temporizadores de inicialización. Al cambiar de región se restablece su escena; **no se conserva estado mutable regional**, inventario o guardado. Es una limitación explícita de esta fase.

## Detectores y apariciones

Coordenadas X,Y,Z locales de mundos a identidad. Ambos detectores usan capa 0, máscara 1, monitorable=false y una caja sin respuesta física; los cierres detrás permanecen intactos.

| Región | Detector | Centro real aproximado | Caja | Aparición al volver/entrar | ID |
|---|---|---|---|---|---|
| Aldea | `Mundo/Region/SalidaBosque` | (0;1,02;−35,5), desde `Aldea/SalidasRegionales/SalidaBosqueNorte/TransicionFutura` | 4×3×1,4 | `Region/EntradaBosque`: (0;0,02;−32) +0,05 Y; mirando abajo/+Z al interior | `aldea_bosque_norte` |
| Bosque | `MundoBosque/Region/SalidaAldea` | (0;1,803;48), desde `Bosque/Marcadores/RetornoAldea/TransicionFutura` | 3,6×3×1,4 | `Bosque/Marcadores/RetornoAldea/AparicionSegura`: (0;0,434;41) +0,05 Y; mirando arriba/−Z al interior | `bosque_aldea_sur` |

Se reutilizan los IDs estables y marcadores de salida. La aldea recibe un Marker3D específico más interior que Aproximacion Z=−34; separa su cápsula del detector y evita bucle. En bosque se reutiliza `AparicionSegura` sin editar el recurso de contenido. La distancia centro a centro detector/aparición es 3,5 y 7 unidades respectivamente. Los detectores cubren los anchos existentes de 4 y 3,6 y se activan antes del cierre. Las otras salidas de aldea y salida norte del bosque no tienen Area3D ni destino activo.

## Errores y ampliación

Ruta inexistente: aviso y desbloqueo sin fundido. Recurso que no carga, entrada ausente o región incompleta: conservar el origen, fundir de regreso y restaurar procesamiento antes de emitir `rechazada`. No se retira el origen hasta validar el candidato. Los avisos incluyen ruta o ID y se conservan en logs. Un script arbitrario defectuoso dentro de una futura región no queda aislado por este gestor; validar la escena antes de conectarla.

Para añadir una conexión futura, cuando ambas regiones estén construidas y autorizadas:

1. Añadir `Region` a su escena jugable y configurar identificador/rutas de jugador y cámara.
2. Crear Marker3D seguro e incorporarlo al diccionario de entradas por ID estable. El metadato opcional `direccion_visual` usa arriba/abajo/izquierda/derecha en pantalla; por defecto arriba, con órbita restablecida a 0.
3. Añadir Area3D con caja que cubra el camino y script `salida_region.gd`; asignar ruta de escena destino, ID de entrada y ruta al marcador de salida.
4. Configurar el retorno por separado y comprobar separaciones, suelo, cinco viajes y errores. No reescribir el gestor ni activar automáticamente metadatos de regiones futuras.

## Pruebas y evidencias

Desde raíz del repositorio, crear `RPG/logs/fase6b_transiciones/` y usar nombres nuevos:

```text
godot --headless --path RPG --fixed-fps 60 --log-file logs/fase6b_transiciones/<nuevo>.log --script res://tests/validar_transiciones.gd
godot --path RPG --log-file logs/fase6b_transiciones/<otro>.log --script res://tests/validar_transiciones.gd
```

La prueba inicia la escena real, comprueba movimiento en aldea, prepara el primer acercamiento norte y luego **camina desde cada aparición al detector sin invocar body_entered manualmente**. Hace cinco viajes completos ida/vuelta, diez cambios, comprueba bloqueos/fundidos/recuperación, marcador seguro, reposo sin bucles, instancia única de jugador y cámara activa, movimiento en bosque, órbita mediante entrada y velocidad 10. Tres controles negativos: escena inexistente, entrada inexistente y escena sin configuración. Dos resoluciones verifican que el fundido cubra el viewport lógico (no comparar con píxeles físicos de ventana debido al stretch del proyecto). Se captura estado intermedio del fundido además de negro completo.

Headless final `10_headless_cobertura.log`: **0 fallos / 182 comprobaciones, diez trayectos**. Regresión de bosque `06_regresion_bosque.log`: **0 / 95.502**. Regresión de aldea a tiempo real `08_regresion_aldea_tiempo_real.log`: **dos fallos preexistentes E04/E12**, 13.695 muestras y 36 corredores. El proceso devuelve código 0 aunque haya fallos: se informa el contador interno y no se declara aprobada.

La regresión geométrica de aldea originalmente activaba la nueva salida al caminar contra su límite norte y perdía la referencia al mundo liberado (`05_regresion_aldea.log`). Se adaptó explícitamente su fixture para desactivar solo la monitorización del detector al probar los cierres; no se omite ninguna comprobación de límites, obstáculos o recorridos. Las transiciones activas se prueban en su prueba específica. Con fixed-fps, la comprobación antigua de rueda comparaba tiempo simulado con reloj real y añadió un fallo; se repitió sin fixed-fps y solo quedaron E04/E12. No se modifica rueda, tolerancias ni esas pruebas.

Primeras ejecuciones de la nueva prueba comparaban ColorRect con tamaño físico de ventana, generando dos falsos fallos de cobertura; se corrigió la comparación con `get_visible_rect()` y pasa en ambas resoluciones. No se cambió el fundido para ocultar el fallo. Persiste el aviso de certificados del entorno; errores deliberados se registran como WARNING. No se afirma prueba manual con teclado/mando: ejecución gráfica automatizada y revisión de capturas.

## Prueba manual y archivos

Abrir el proyecto en Godot 4.7.2 y pulsar F5. Desde la plaza ir al norte (W con órbita inicial), seguir el camino entre taberna y panadería hasta la señal Bosque. El fundido lleva a la entrada sur del bosque mirando al interior. Caminar hacia el sur (S con órbita inicial) por el sendero de retorno hasta el cierre para volver a la aldea. Probar Q/E y repetir. F6 sobre `mundo_bosque.tscn` permite iniciar directamente en el bosque conectado; `pruebas_bosque.tscn` continúa siendo laboratorio aislado. No se abren las salidas a otras regiones.

Creados: `RPG/scripts/gestor_regiones.gd`, `RPG/scripts/region_config.gd`, `RPG/scripts/salida_region.gd`, `RPG/scenes/mundo_bosque.tscn`, `RPG/tests/validar_transiciones.gd` y este documento; UID asociados cuando los genera el motor. Modificados: `RPG/project.godot` (solo Autoload), `RPG/scenes/mundo.tscn` (configuración/entrada/detector invisibles), `RPG/tests/validar_distribucion.gd` (fixture de prueba), `AGENTS.md`, `RPG/docs/estado_proyecto.md`, `RPG/docs/plano_aldea.md` y `RPG/docs/plano_bosque.md`. Sin editar contenido de escenarios, protagonista, cámara, vegetación, río/puente, NPCs o minijuegos. Inventario no cambia, sin assets nuevos. Cambios previos conservados; sin commits ni pushes. Detenerse en 6B.

Cierre gráfico final `RPG/logs/fase6b_transiciones/11_forward_final.log`: Godot 4.7.2, Forward+/D3D12 RTX 4060 Laptop, **0 fallos / 187 comprobaciones y diez trayectos**. Cinco PNG y galería revisados (salida norte, fundido parcial, negro completo, entrada al bosque y retorno orientado al interior) en `RPG/logs/fase6b_transiciones/2026-11-04T12-45-19_1808/galeria.html`. Se comprueba cobertura lógica en ventanas 960×540 y 1280×800; no se realizó una sesión manual de pantalla completa o mando físico. No se alteran ajustes globales de render. Fase 6B terminada; pendiente aprobación del usuario.

## Conexión activa 6D — Bosque ↔ Ruinas

Autorizada por la solicitud de fase 6D. Se amplía únicamente la configuración de `mundo_bosque.tscn` y `mundo_ruinas.tscn`: **gestor_regiones.gd, region_config.gd y salida_region.gd permanecen idénticos**. Mismo Autoload y fundidos de 0,35 s por sentido, bloqueo de solicitudes simultáneas, validación bajo negro y recuperación de errores. No hay persistencia ni nuevos sistemas.

| Origen y detector | Marcador de salida X,Y,Z | Centro Area3D (+1 Y) y caja | Destino y entrada | Aparición base X,Y,Z y orientación |
|---|---|---|---|---|
| Bosque, Region/SalidaRuinas | Bosque/Marcadores/SalidaRuinas/TransicionFutura: (20;1,0035956;−48) | (20;2,0035956;−48), 3,6×3×1,4 | mundo_ruinas.tscn, ruinas_bosque_sur | Ruinas/Marcadores/EntradaBosque: (0;0,05;34), arriba/−Z |
| Ruinas, Region/SalidaBosque | Ruinas/Marcadores/RetornoBosque: (0;0;37) | (0;1;37), 4,5×3×1,4 | mundo_bosque.tscn, bosque_ruinas_norte | Region/EntradaRuinas: (22;1,8886713;−37), abajo/+Z |

El gestor añade +0,05 Y a las apariciones. Separaciones horizontales con los detectores: aproximadamente 11,18 en bosque y 3 en ruinas. Ambas apariciones tienen terreno firme y quedan fuera de todas las áreas. La entrada forestal desde aldea sigue en (0;0,43386927;41), ID `bosque_aldea_sur`, y no se reemplaza. `Region/EntradaRuinas` coincide con la aparición ya prevista de SalidaRuinas, pero vive en la envolvente para fijar orientación hacia el interior sin editar el recurso de bosque. El metadato histórico `activa=false` del marcador de ruinas no gobierna el sistema: mandan las Area3D configuradas explícitamente en los mundos.

Acceso por P03, desde el claro (0;0), pasando por Z04 (24;−26) y (22;−37), hasta (20;−48). Sin cruzar laguna ni intervenir en la salida sur. `RPG/scenes/acceso_ruinas_bosque.tscn` añade dos restos de columna propios en (17,8;−43) y (24,5;−43), fuera del sendero. Terreno medido Y≈1,532 y 1,701; bases hundidas aproximadamente 0,03 para encajar con la pendiente, fustes de 1,4/0,75 y colisiones cilíndricas simples. Sin editar modelos originales, importar paquetes ni reconstruir mapas. Los cierres exteriores se conservan detrás de las áreas.

### Prueba desde F5

1. Iniciar normalmente en la aldea. Caminar al norte hasta la salida Bosque.
2. Desde la aparición sur del bosque, seguir P01 al claro central; tomar P03 al noreste hacia Z04 y continuar al norte por el sendero, entre los dos restos de columna. El detector anterior al cierre lleva a las ruinas.
3. En ruinas se aparece al sur mirando al interior; avanzar hacia las estructuras. Para volver, seguir el sendero al sur hasta Z=37.
4. El retorno al bosque aparece junto a la salida norte, mirando hacia el claro. Seguir P03 de vuelta al claro y P01 al sur hasta la salida Aldea.

WASD/flechas y Q/E se conservan; las direcciones son relativas a pantalla. F6 sobre las escenas mundo_bosque/mundo_ruinas también usa conexiones activas; pruebas_bosque sigue aislado. No se modifica la escena inicial permanente.

### Validación 6D

`RPG/tests/validar_bosque_ruinas.gd` reutiliza utilidades de la prueba 6B. Prepara una única posición inicial en aldea junto a su salida; después recorre físicamente P01/P03 con acciones Input y el controlador original, sin teletransportarse entre accesos ni emitir body_entered manualmente. Cinco circuitos D, más Aldea → Bosque → Ruinas → Bosque → Ruinas → Bosque → Aldea: **26 cambios**. Comprueba ambas entradas del bosque, orientación, separaciones, reposo sin bucles, número de áreas autorizadas, ausencia de duplicados, control, animación/orientación, tamaño y velocidad originales, una órbita completa por región y órbita posterior en cada llegada. El negro completo exige jugador bloqueado; las solicitudes simultáneas se rechazan y se observan estados intermedios del fundido.

Desde la raíz del repositorio, crear la carpeta local y usar nombres nuevos:

```text
godot --headless --path RPG --fixed-fps 60 --log-file logs/fase6d_bosque_ruinas/<nuevo>.log --script res://tests/validar_bosque_ruinas.gd
godot --path RPG --fixed-fps 60 --log-file logs/fase6d_bosque_ruinas/<otro>.log --script res://tests/validar_bosque_ruinas.gd
```

Para las regresiones existentes de transiciones, ruinas y bosque/laguna, añadir `-- --fase6d`: concentra sus evidencias en subcarpetas de `RPG/logs/fase6d_bosque_ruinas/`. El test local de ruinas verifica que solo exista el retorno a Bosque y desactiva su monitorización en la fixture para probar los cuatro cierres sin abandonar la escena; no se retira ninguna comprobación física. El test 6B reconoce ahora las dos áreas del bosque y comprueba que ambas estén separadas de la aparición, manteniendo sus controles negativos y cinco viajes.

Resultados finales 6D, Godot 4.7.2.stable.official.ed1daf0bf:

| Ejecución | Resultado | Registro bajo `RPG/logs/fase6d_bosque_ruinas/` |
|---|---|---|
| Circuito nuevo headless | **0 fallos / 512**, cinco D y 26 cambios | `05_circuito_headless_final.log` |
| Circuito nuevo Forward+/D3D12, RTX 4060 Laptop | **0 / 517**, cinco D y 26 cambios | `06_circuito_forward.log` |
| Regresión 6B Aldea ↔ Bosque | **0 / 187**, diez trayectos, errores deliberados | `07_regresion_transiciones.log` |
| Regresión ruinas | **0 / 517**, cierres y cinco zonas | `08_regresion_ruinas.log` |
| Regresión laguna y bosque | **0 / 21.116**, catorce recorridos, orillas conservadas | `09_regresion_laguna_bosque.log` |
| Regresión aldea a tiempo real | **2 fallos conocidos E04/E12**, 13.695 muestras, 36 corredores | `10_regresion_aldea.log` |

Galería gráfica revisada: `RPG/logs/fase6d_bosque_ruinas/2026-11-04T20-38-01_2061/galeria.html`: acceso forestal con columnas, llegada a ruinas, regreso por su sendero, aparición forestal desde ruinas y negro completo. Una cámara temporal de prueba encuadra el acceso; no modifica archivos ni teletransporta al jugador. No se afirma sesión manual física o aprobación visual. La carga sigue siendo síncrona bajo negro, con la limitación de pausa en equipos lentos ya documentada.

Los errores de certificados del entorno persisten, sin fallos de carga de las escenas. Los WARNING de entradas inexistentes son controles negativos esperados. Borradores de prueba corrigieron orden de inicialización de current_scene y una comparación incorrecta de órbita tras volver por ±PI; el gestor y los controladores no se tocaron. La comparación de hashes antes/después conserva bosque/ruinas/laguna originales, gestor, salida_region, jugador, cámara orbital y project.godot (`protegidos_antes.json` y `protegidos_despues.json` en la carpeta de evidencias).

Archivos creados: `RPG/scenes/acceso_ruinas_bosque.tscn`, `RPG/tests/validar_bosque_ruinas.gd` y UID cuando lo genere Godot. Modificados en 6D: `RPG/scenes/mundo_bosque.tscn`, `RPG/scenes/mundo_ruinas.tscn`; fixtures en `RPG/tests/validar_transiciones.gd`, `RPG/tests/validar_ruinas.gd`, `RPG/tests/validar_bosque.gd`; documentación en `AGENTS.md`, `RPG/docs/estado_proyecto.md`, `RPG/docs/transiciones_regionales.md`, `RPG/docs/plano_bosque.md`, `RPG/docs/plano_ruinas.md`. Los demás cambios locales ya existían. Sin commits ni pushes. Detenerse tras 6D para revisión del usuario.

## Fase 6E — Aldea ↔ Campos y Granjas

`RPG/scenes/mundo_campos_granjas.tscn` incorpora `Region.id_region=CamposYGranjas`, jugador/cámara originales y contenido independiente `campos_granjas.tscn`. No hay otro gestor ni cambios en scripts de transición, cámara, jugador o project.godot. Plano y recursos: `RPG/docs/plano_campos_granjas.md`.

| Origen / Area3D | Marcador y centro real | Caja | Destino / ID de llegada | Aparición base y orientación |
|---|---|---|---|---|
| Aldea / Region/SalidaCampos | SalidaCamposSur/TransicionFutura existente (0;0,02;35,5); área (0;1,02;35,5) | 4×3×1,4 | mundo_campos_granjas.tscn / campos_aldea_norte | CamposYGranjas/Marcadores/EntradaAldea (0;0,05;−39), abajo/+Z |
| Campos / Region/SalidaAldea | CamposYGranjas/Marcadores/RetornoAldea (0;0;−43); área (0;1;−43) | 4,5×3×1,4 | mundo.tscn / aldea_campos_sur | Region/EntradaCampos (0;0,02;32), arriba/−Z |

IDs previstos de 4B.6 preservados. El gestor añade +0,05 Y; separaciones horizontales 4 y 3,5, sin solapamiento inicial. EntradaBosque sigue en Z=−32. No se edita `aldea.tscn`, ni se retiran límites: el detector sur se activa antes del cierre sólido, igual que el norte. Los metadatos históricos de señales no activan destinos por sí mismos. Salida este continúa pendiente; no hay persistencia regional.

Prueba desde F5: caminar al sur desde plaza, cruzar detector de Campos, explorar la región y regresar por el camino norte hasta su detector. Se vuelve a Z=32 de aldea mirando al interior; desde allí siguen disponibles bosque y ruinas. Fundido 0,35 s por sentido, controles restaurados y cámara 15 compartida.

`RPG/tests/validar_transicion_campos.gd` comprueba cinco Aldea → Campos → Aldea, más Aldea → Bosque → Ruinas → Bosque → Aldea → Campos → Aldea: 16 cambios por ejecución desde la aparición inicial, movimiento real con Input y áreas activas, sin teletransportes ni señales manuales. Verifica marcadores/orientación, fundidos parciales y negro, bloqueo simultáneo, reposo sin bucles, jugador/cámara únicos, control recuperado y órbita completa en cuatro regiones. Al cruzar la aldea rodea su pozo por los corredores existentes.

Las regresiones 6B/6D mantienen recorridos y controles negativos. Solo se actualiza el número esperado de áreas en aldea a dos y se añaden comprobaciones explícitas de su conexión sur; la dirección de movimiento recuperado usa el metadato del marcador, conservando las orientaciones previas. La fixture de distribución desactiva ambos detectores únicamente durante los controles de cuatro cierres; la prueba regional los conserva activos. No se eliminan controles físicos ni se relajan tolerancias para obtener resultados positivos. `--fase6e` deriva evidencias de regresión a `RPG/logs/fase6e_campos_granjas/` sin cambiar su lógica.

Ejecutar desde la raíz del repositorio, creando logs y usando nombres nuevos:

```text
godot --headless --fixed-fps 60 --path RPG --log-file logs/fase6e_campos_granjas/<nuevo>.log --script res://tests/validar_transicion_campos.gd
godot --fixed-fps 60 --path RPG --log-file logs/fase6e_campos_granjas/<nuevo_visual>.log --script res://tests/validar_transicion_campos.gd
```

Ejecuciones finales, resultados y galerías en el registro 6E de `RPG/docs/estado_proyecto.md`. Se mantienen las incidencias de entorno de certificados y caché de shaders; no se declaran logs sin avisos. Revisión artística y recorrido manual del usuario pendientes. Sin commits ni pushes.

## Conexión activa 6F — Aldea este ↔ Montañas

`RPG/scenes/mundo.tscn` añade únicamente la entrada y el detector orientales; contenido de Aldea y puente conservados. `Region/SalidaMontanas` usa el marcador estable `Aldea/SalidasRegionales/SalidaCaminoEste/TransicionFutura` (39,5;0,02;0), caja 1,4×3×4 y destino `res://scenes/mundo_montanas.tscn`, entrada `camino_montanas_aldea_oeste`. Aparición en `Montanas/Marcadores/EntradaAldea` (−52;2,04;48), mirando derecha/+X. La región nueva declara `Region.id_region=Montanas`.

Retorno `MundoMontanas/Region/SalidaAldea`, marcador `Montanas/Marcadores/RetornoAldea` (−62;2,02;48), caja 1,4×3×6: destino `res://scenes/mundo.tscn`, entrada independiente `aldea_camino_este` en `Region/EntradaMontanas` (36;0,02;0), mirando izquierda/−X. El gestor añade +0,05 Y, coloca las áreas +1 Y y conserva fundido 0,35 s, exclusión de solicitudes simultáneas, recuperación y un solo protagonista/cámara. No se editan gestor, jugador, cámara ni conexiones anteriores. Cierres detrás de detectores intactos; no se camina fuera del terreno de Aldea.

Desde F5, rodear el puesto oriental del mercado y seguir el corredor Ribera al puente; cruzarlo hasta la señal Montañas. Desde la llegada baja en Montañas, avanzar hacia +X para explorar o regresar hacia −X hasta el detector. No reutilizar las entradas norte/sur para esta conexión. La mina solo tiene `Marcadores/ConexionMinasFutura` con metadatos inactivos y fondo físico; no contiene detector ni escena destino.

`RPG/tests/validar_transicion_montanas.gd` camina desde la aparición inicial: cinco Aldea → Montañas → Aldea, luego Bosque → Ruinas → Bosque → Aldea → Campos → Aldea. Dieciséis cambios y dieciséis negros; comprueba fundidos parciales, separación/orientación de llegadas, control recuperado, reposo sin bucles y solicitudes simultáneas. Headless `RPG/logs/fase6f_montanas/11_transiciones.log`: 0 fallos / 253 comprobaciones. Forward+/D3D12 `32_transiciones_forward.log`: 0 / 264; incluye once PNG y galería de ida/vuelta. Resultados actualizados y rutas concretas en el estado. La regresión geométrica de Aldea desactiva únicamente los tres detectores para medir sus cierres; las pruebas regionales los mantienen activos. Las expectativas de número de áreas pasan de dos a tres en Aldea, conservando las de Bosque y demás regiones.
## Conexión activa — Montañas ↔ Minas, 8 de noviembre de 2026

`RPG/scenes/mundo_montanas.tscn` añade `Region/SalidaMinas` sobre el marcador existente `Montanas/Marcadores/ConexionMinasFutura` (45;20;−23,2), detector 3,5×5×5,4. Su frente se alcanza caminando antes del cierre minero conservado. Destino `res://scenes/mundo_minas.tscn`, entrada `minas_montanas_sur` en (0;0,05;0), mirando arriba/−Z. El regreso usa `Minas/Marcadores/RetornoMontanas` (0;0;8), caja 4×3×1,5, destino mundo_montanas.tscn, ID `montanas_minas_norte` y marcador `Region/EntradaMinas` (45;20,05;−18), mirando abajo/+Z.

El gestor original añade 0,05 Y y conserva fundidos 0,35 s, bloqueo simultáneo y recuperación. No cambian destinos anteriores, jugador, cámara, controles ni exterior de Montañas. Los metadatos históricos inactivos permanecen como antecedentes; las áreas explícitas de la envolvente determinan la conexión actual. Esta sección sustituye la descripción histórica de Minas pendiente de 6F.

`RPG/tests/validar_transicion_minas.gd` recorre cinco ida/vuelta por áreas activas, con llegada desde Aldea y regreso hasta ella: doce cambios y negros, apariciones sobre suelo fuera de detectores, orientación, control/órbita, jugador/cámara únicos y reposo sin bucles. Evidencias gráficas y headless en `RPG/logs/fase_minas/`; reproducción y límites en `RPG/docs/plano_minas.md`. La prueba física local de Montañas desactiva ambos detectores para medir cierres sin viajar; la prueba regional los conserva activos. `--fase-minas` deriva evidencias de las dos regresiones de Montañas a esa carpeta.
