# Auditoría general del RPG medieval

22 de noviembre de 2026 · rama `main` · revisión `7c91c6e`. En el informe, `scenes/`, `scripts/`, `tests/` y `data/` corresponden a subdirectorios de `RPG/`.

## A. Resumen ejecutivo

El RPG arranca directamente en la Aldea. El jugador puede caminar con teclado o mando, orbitar la cámara, cruzar el puente, recorrer rutas hacia cinco regiones exteriores, visitar interiores con F, conversar con cinco aldeanos, hacer un recado y jugar a pesca, cerveza, pan y forja. El contenido exterior está más avanzado en construcción y navegación que en actividades jugables. Hay once interiores conectados en las escenas, E01–E11. El molino E12 es exterior y su rueda gira.

La IA añade diálogo libre, planificación, conversaciones entre aldeanos y narrador. Se comprobó con respuestas simuladas según el registro de pruebas. La disponibilidad de OpenRouter, el funcionamiento con una cuenta real y el coste efectivo siguen pendientes. El guardado cubre historia, recuerdos y reloj en archivos locales. El RPG carece de guardado integral del mundo.

Se inspeccionaron las escenas y scripts de juego, los recursos y referencias, los autoloads, los datos narrativos, la documentación, Git y los validadores. Se inventariaron los assets por ruta, consultando procedencia y licencias en los documentos correspondientes. La revisión de referencias literales de recursos en escenas, scripts y datos encontró disponibles los destinos concretos comprobados. La plantilla dinámica de nombres de minijuego del generador de E01 se contrastó con las tres escenas de oficio. El análisis de referencias no valida cada importación, material o fotograma.

## B. Inventario de sistemas

**FUNCIONAL** indica que pasó una prueba local para el alcance indicado. **IMPLEMENTADO SIN VERIFICAR** indica que existe una implementación con comprobación pendiente. **PARCIAL** identifica funciones pendientes dentro de un sistema existente. **PROTOTIPO** describe una implementación experimental. **NO IMPLEMENTADO** indica que no se encontró implementación. **BLOQUEADO** se reserva para una función que depende de un requisito que impide usarla.

| Sistema | Estado | Evidencia | Observaciones |
|---|---|---|---|
| Movimiento y sprite | FUNCIONAL | `scenes/jugador.tscn`, `scripts/jugador.gd`, `jugador_frames.tres`. WASD, flechas o stick izquierdo. Pruebas de aldea, cámara y viajes. | Cápsula, gravedad, aceleración y frenado, movimiento relativo a cámara, animación idle/walk en cuatro direcciones. |
| Cámara | FUNCIONAL | `scripts/camara_orbital.gd`, `tests/validar_camara_orbital.gd`. Q/E o stick derecho. | Órbita horizontal y seguimiento suavizado. Tamaño exterior 15. Falta revisión visual de oclusión por cubiertas y follaje. |
| Aldea, caminos y colisiones | PARCIAL | `scenes/aldea.tscn`, `terreno_aldea.gd`, `tests/validar_aldea.gd`. | Suelo, plaza, caminos, doce exteriores, huertos, mercado, mirador y jardín. Dos fallos de recorrido en la regresión. |
| Río, puente y rueda | FUNCIONAL en las comprobaciones físicas y de giro de la regresión de aldea | `scenes/rio.tscn`, `puente.tscn`, `molino.tscn` y scripts de shaders/rueda. | Agua animada y barreras sobre suelo continuo. El puente es el cruce previsto. Falta revisión audiovisual. |
| Viajes, puertas e interiores E01–E11 | FUNCIONAL | `scripts/gestor_regiones.gd`, `salida_region.gd`, `region_config.gd`, `interiores/puerta_interior.gd`. Pruebas de entradas y retornos en § O. | Áreas automáticas fuera, F en puertas, escenas empaquetadas y marcadores. E12 carece de interior. |
| Población y recado | FUNCIONAL en los casos offline comprobados | `scenes/mundo.tscn`, `scripts/npc/`, `tests/validar_npcs_aldea.gd` y `validar_npc_pescador.gd`. | Cinco sprites y diálogos fijos. Progresión del recado y estadísticas locales se reinician al reconstruir la escena. |
| IA y narrador | PARCIAL | `scripts/ia/`, `data/historia/`, `tests/validar_ia_capa1.gd` a `capa3.gd`. | Flujos simulables. La conexión real exige Internet, confianza TLS, clave y modelo compatible. |
| Reloj, diario y memoria | PARCIAL | `reloj.gd`, `diario.gd`, `historia.gd`. J abre el diario. | Guarda narrativa, no el estado completo de la partida. Sin cambio de iluminación. |
| Cuatro minijuegos y audio | FUNCIONAL | `scripts/pesca/`, `scripts/minijuegos/`, validadores de pesca y oficio. | Estados de instrucciones, partida y resultado, puntuación y efectos Kenney. Sin progreso de profesión. |
| Pausa, opciones de IA y diálogo | PARCIAL | `menu_pausa.gd`, `dialogo_ia.gd`, `scripts/dialogo/caja_dialogo.gd`. Esc, F/A, flechas y texto según pantalla. | Pruebas de flujos bajo simulación. Falta revisión visual y de accesibilidad. |
| Escenas de muestra y autoría | PROTOTIPO / herramientas internas | `scenes/pruebas_*.tscn`, `scenes/respaldos/`, `scripts/editor/`. | Laboratorios, respaldo, generación de escenas y utilidades de assets. Se abren explícitamente y quedan fuera del flujo normal. |

## C. Mundo y regiones

Las envolventes `scenes/mundo*.tscn` instancian la región, el jugador y la cámara. El arranque usa `mundo.tscn` por UID y coloca al protagonista en X=0, Y=0,05 y Z=0. El jugador entra en los detectores de borde para viajar. Los destinos se validan antes de sustituir la escena anterior. El gestor coloca al personaje a 0,05 unidades por encima del marcador, reinicia velocidad, orientación visual y órbita, y restaura el procesamiento al terminar el fundido. Los puntos de aparición y retornos se definen en `Region`. Los marcadores quedan separados de las áreas de viaje en las rutas previstas. Los cinco enlaces aprobaron en ambos sentidos.

| Región | Contenido y navegabilidad | Conexiones, entradas y estado |
|---|---|---|
| Aldea | Plaza, mercado decorativo, huertos, jardín, mirador, río, puente, cinco NPC, pesca y puertas de interiores. Terreno y límites sólidos. | Norte a Bosque, sur a Campos y este, tras el puente, a Montañas. Retornos `aldea_bosque_norte`, `aldea_campos_sur`, `aldea_camino_este`. PARCIAL por recorridos exteriores E04 y E12. |
| Bosque | FUNCIONAL como región explorable. Senderos, vegetación, laguna escenográfica y acceso a Ruinas. | Ida/vuelta con Aldea y Ruinas. Marcadores `bosque_aldea_sur` y `bosque_ruinas_norte`. Sin NPC o recolección conectada. |
| Campos y Granjas | FUNCIONAL como región explorable. Praderas, planteles, huertos, frutales, colmenas, granero y casa. Colisión y altura a partir del terreno construido. | Ida/vuelta con Aldea sur por `campos_aldea_norte`. Agricultura, animales y vida rural son pendientes de juego. |
| Montañas | FUNCIONAL como región explorable. Caminos en pendiente, puentes, cascadas, campamento, torre cerrada y portal minero. | Ida/vuelta con Aldea este y Minas. Entradas `camino_montanas_aldea_oeste` y `montanas_minas_norte`. Torre y campamento son escenografía. |
| Minas | FUNCIONAL como región explorable. Túneles, vetas y cristales, vías, vagonetas, agua y pasarela. Colisiones y recorte de roca para visibilidad. | Ida/vuelta con Montañas por `minas_montanas_sur`. Sin extracción. El recorte puede mostrar bordes visibles desde algunas orientaciones según la documentación. |
| Ruinas | FUNCIONAL como región explorable. Trazado de exploración y piedra en ruinas. | Ida/vuelta con Bosque por `ruinas_bosque_sur`. Sin puertas de mazmorra, enemigos o rompecabezas conectados. |

Los estados verificados de enlaces y pruebas físicas se detallan en § O. La integridad artística, recorrido libre con mando, oclusión en todos los ángulos y rendimiento gráfico permanecen pendientes. F también sirve para hablar o abrir paneles de juego. Cofres, herramientas, cultivos y puestos de mercado examinados son decorativos.

## D. Edificios e interiores

Las once salas están serializadas en `scenes/interiores/`. Se contrastaron en cada escena luz, suelo y cuerpos sólidos, muebles, puerta de salida y referencias de destino. La entrada exterior está en `mundo.tscn` y cada salida vuelve al marcador propio frente a su puerta. La puerta usa un área F con aviso y cambio de escena. Todos los interiores E01–E11 tienen iluminación, muebles y colisiones y carecen de NPC instanciado. El tabernero, la panadera y el herrero aparecen fuera.

La presentación de casa de muñecas oculta paredes visuales según el ángulo de cámara y conserva las colisiones. Muebles altos y tejados exteriores pueden ocultar parcialmente el sprite en algunos ángulos, según la galería y las notas históricas de `RPG/docs/interiores_aldea.md`.

| ID | Sala y decoración comprobable | F entrada/salida y retorno | Actividad y observaciones |
|---|---|---|---|
| E01 Taberna | `taberna_e01.tscn`. Barra, mesas, barriles y velas. | `taberna_e01_entrada` ↔ `aldea_taberna_e01`. | Cerveza junto a la barra. Paquete medv-cafe con licencia pendiente de aclarar para distribución. |
| E02 Panadería | `panaderia_e02.tscn`. Horno, artesa y despensa. | `interior_e02` ↔ `aldea_e02`. | Pan junto al horno. |
| E03 Herrería | `herreria_e03.tscn`. Forja, fuelle, yunque y herramientas. | `interior_e03` ↔ `aldea_e03`. | Forja junto al yunque. |
| E04 Carpintería | `carpinteria_e04.tscn`. Banco, sierra, tablones y ensamblaje. | `interior_e04` ↔ `aldea_e04`. | Taller decorativo. El recorrido exterior al camino público falla en la regresión de aldea. |
| E05 Herbolario | `herbolario_e05.tscn`. Mesas, mortero, hierbas y baldas. | `interior_e05` ↔ `aldea_e05`. | Sin comercio ni preparación jugable. |
| E06 Vivienda noroeste | `vivienda_e06.tscn`. Cama, cofre, mesa y vasija. | `interior_e06` ↔ `aldea_e06`. | Visita decorativa. |
| E07 Vivienda noreste | `vivienda_e07.tscn`. Biombo, cama, textiles y salón. | `interior_e07` ↔ `aldea_e07`. | Visita decorativa. |
| E08 Vivienda suroeste | `vivienda_e08.tscn`. Hogar, herramientas, cama y leña. | `interior_e08` ↔ `aldea_e08`. | Visita decorativa. |
| E09 Vivienda sur | `vivienda_e09.tscn`. Cocina compacta, cama, mesa y cofre. | `interior_e09` ↔ `aldea_e09`. | Visita decorativa. |
| E10 Vivienda del granjero | `vivienda_e10.tscn`. Dormitorio, bancos, despensa y aperos. | `interior_e10` ↔ `aldea_e10`. | Sin agricultura jugable. |
| E11 Vivienda floral | `vivienda_e11.tscn`. Textiles, macetas, flores y baldas. | `interior_e11` ↔ `aldea_e11`. | Visita decorativa. |
| E12 Molino | `scenes/molino.tscn`. Exterior con sólidos, canal y rueda. | NO IMPLEMENTADO. Sin sala, área de puerta F o marcador de retorno interior. | Rueda animada. La regresión detecta un fallo exterior. |

**11 interiores funcionales** en entrada, salida y retorno. Los once están terminados como salas visitables. La prueba de E04 valida su puerta y retorno inmediato. El recorrido exterior posterior hasta el camino público es la aserción que falla. La aprobación artística y jugable final queda por confirmar. Ver § O.

## E. NPCs

Se encontraron **cinco instancias jugables**, todas en `scenes/mundo.tscn` bajo `NPCs`. Comparten `scenes/npc_aldeano.tscn` y `scripts/npc/npc_aldeano.gd`, con recursos de animación propios en `scenes/npcs/`. Todos tienen idle y walk direccionales, conversación fija por F/A e integración opcional con IA y memoria narrativa por identificador.

Git identifica dos incorporaciones recientes. `9830fe3` añadió aldeanos con sprites propios y el recado del pan. `7c91c6e` incorporó el sistema OpenRouter que amplía el comportamiento de los cinco personajes. El censo de escenas actuales no encontró otra población jugable.

| Personaje | Puesto y comportamiento sin IA | Script y memoria/actividad especial |
|---|---|---|
| Tomás (`pescador`) | Orilla oeste, al sur del puente. Fijo en su puesto. | `npc_pescador.gd`. Recibe puntuación de pesca y comenta sus resultados. Conserva partidas y mejor puntuación mientras vive esa instancia. Registra el resultado como recuerdo narrativo incluso con IA apagada. |
| Marta (`panadera`) | Exterior de E02. Fija en su puesto. | Base y `recado_pan.gd`. Encarga llevar pan al guardia en el diálogo fijo. El horno jugable está dentro y no depende de ella. |
| Gonzalo (`herrero`) | Patio de E03. Fijo en su puesto. | Base. Diálogo del oficio. El minijuego de forja se activa dentro sin su intervención. |
| Anselmo (`tabernero`) | Fachada exterior de E01. Fijo en su puesto. | Base. Diálogo del oficio. La cerveza se juega dentro sin su intervención. |
| Bruno (`guardia`) | Recorre el anillo de calles, espera en puntos y se detiene ante el jugador. | `npc_patrulla.gd`. Sin cuerpo sólido. Destinatario del recado. |

El área de conversación usa cápsula de radio 1,3 y altura 2. La base muestra avisos y gira el sprite hacia el jugador. El modo fijo prioriza el recado sobre las primeras visitas y líneas habituales. El modo IA se intenta antes que esas líneas. Si abre correctamente, el recado fijo puede quedar inaccesible. Los NPC sólidos activan el cuerpo en el puesto y lo desactivan al desplazarse. Las puertas consumen eventos en `_unhandled_input`, mientras que NPC y minijuegos consultan el estado global de F. Las pruebas comprueban colocaciones concretas. Los encuentros móviles y posibles solapes requieren pruebas combinadas porque no se encontró un selector global de interacción.

`Aldeanos` usa rutinas, trabajar, ir a lugar, descansar, visitar a otro NPC y buscar al jugador. AStarGrid2D aproxima rutas sobre colisiones físicas y favorece caminos. Si el jugador sale de la Aldea, los nodos se eliminan con la escena, pero el autoload conserva planes y puede simular llegadas. Al regresar registra nuevas instancias. Un encuentro puede mostrarse con bocadillos si hay proximidad (distancia visible 12, encuentro 1,4), o convertirse en resumen y recuerdos cruzados. La animación de trabajo, la entrada de NPC en edificios y las relaciones numéricas siguen ausentes.

## F. Integración con modelos de lenguaje

- **Transporte y configuración.** `servicio_ia.gd` crea un `HTTPRequest` por solicitud y envía un POST HTTPS a OpenRouter Chat Completions con un token Bearer. Modelo predeterminado `z-ai/glm-5.3-flash`, editable en Esc → Opciones de IA. OpenRouter es el único servicio observado. No hay backend propio. El código guarda la clave mediante `ConfigFile.save` en `user://ia.cfg`, en texto legible. El campo de entrada la oculta en pantalla. Un escaneo por patrones de claves OpenRouter y claves privadas no encontró coincidencias en los archivos de proyecto inspeccionados. El alcance excluye el historial de Git y los datos privados de Godot.
- **Contexto.** `prompts_ia.gd` arma mensajes con instrucciones de sistema distintas para diálogo, narrador, planificador y encuentros. `premisa.json` contiene mundo, fichas y personalidades distintas. El diálogo envía ficha, resumen, hilos abiertos, recuerdos, rumores, indicación del narrador, estado actual y hasta seis entradas recientes turno a turno, además del mensaje nuevo. El texto libre se recorta a 200 caracteres. El narrador usa el estado narrativo y hechos recientes. Planificación y encuentros usan fichas, lugares, franja, motivos, contexto narrativo y estado de los implicados.
- **Respuesta.** Solicita `json_schema` estricto y `provider.require_parameters`. Espera HTTP 200, extrae `choices[0].message.content`, limpia envoltura textual y analiza un diccionario. La UI muestra respuesta, hasta tres opciones de 80 caracteres, escribir libremente y despedirse. El narrador actualiza hilos, diario e indicaciones. Las acciones se restringen a IDs, lugares y verbos conocidos en el código del planificador.
- **Tiempo, límites y coste.** Timeout de 25 s por intento. Solicita razonamiento mínimo. Un 404 con razonamiento provoca un intento sin ese parámetro, que se recuerda por modelo. Un JSON interno inválido permite otro intento con el doble de salida. Límites iniciales: conversación 400, narrador 800, plan 700, encuentro visible 500, resumen 200 tokens. El presupuesto de sesión predeterminado es 200.000. Se contabilizan `usage.total_tokens` y `usage.cost` cuando llegan. Es un umbral de admisión basado en uso ya reportado. Puede sobrepasarse con solicitudes en curso o reintentos. Ausencia de `usage` deja el consumo sin reflejar.
- **Degradación.** Sin clave, con IA apagada o presupuesto agotado se usan líneas y rutinas fijas. Un fallo en el primer turno devuelve al diálogo fijo. Si falla tras empezar la conversación IA, aparece una despedida genérica. Planes y encuentros fallidos tienen sus propias ramas. Las solicitudes son asíncronas. El diálogo pausa el mundo, y Esc no lo cierra mientras espera. Planificación, narración y encuentros operan en sus autoloads sin requerir pausar toda la escena.
- **Validación y privacidad.** El proveedor recibe texto libre y recuerdos cuando forman parte del prompt. El código registra extractos de errores HTTP y de JSON inválido. El parseo confía en tipos y tamaños de ciertas estructuras, por ejemplo indexa `choices[0]` tras comprobar solo que exista la propiedad. Un resultado vacío o con forma inesperada puede producir error y dejar un diálogo en espera. El simulador evita la red y también el parser HTTP, TLS, reintentos y contabilidad real. Para una prueba futura, usar una clave dedicada con límite de gasto, entrada ficticia, una única comprobación desde Opciones, y revisar gasto/resultado sin compartir registros que contengan contenido privado. La prueba exige autorización para el consumo.

## G. Memoria, persistencia y datos

No se encontró base de datos, servidor de estado ni dependencia SQLite. Los datos de autoría son JSON en `data/historia/` y el catálogo de edificios en `scripts/interiores/`. La partida narrativa usa `user://historia.json`, versión 1. Guarda hilos, resumen, diario (hasta 30 entradas), hasta diez hechos recientes, reloj, indicaciones y memoria separada por NPC: hasta ocho recuerdos y seis rumores por ID, recortados a 140 caracteres cada uno. Guarda ante cambios relevantes y el reloj guarda al cambiar de franja, periódicamente cada 30 segundos y ante petición de cierre de ventana.

| Acción | Qué se conserva | Qué se reinicia o se pierde |
|---|---|---|
| Cerrar diálogo | Memoria narrativa, hechos, reloj y contadores del NPC actual. | La ventana se cierra. El búfer de conversación se limpia al abrir la siguiente charla. No se escribe transcripción completa. |
| Entrar a un edificio | Historia, reloj y estado temporal de autoloads. | Se reemplaza la escena Aldea. El recado, estadísticas locales de pesca y contador de visitas pertenecen a sus instancias. |
| Cambiar de región | Los mismos autoloads viven y los planes pueden seguir simulándose. | Posición y órbita anterior se sustituyen por el marcador de destino. El mundo local se vuelve a instanciar al volver. |
| Cerrar y volver a abrir | Historia guardada, reloj y configuración de IA. | Planes activos, posiciones, recorridos, puntuaciones de sesión, estado del recado y contadores de coste. El jugador vuelve al arranque. |
| «Nueva historia» | Configuración de IA. | Reinicia historia, recuerdos, rumores, diario y reloj. El botón actúa sobre historia, sin un sistema de ranuras o reinicio completo del mundo. |

El LLM recibe selecciones resumidas de esta memoria. Relaciones persistentes como afinidad, reputación o compromisos verificables no tienen modelo propio. El JSON se sobrescribe directamente y la carga valida diccionario y versión antes de acceder a campos esperados. Una escritura interrumpida o datos incompletos son riesgos de pérdida. La reconstrucción desde premisa ante carga fallida puede sobrescribir el archivo. `Historia.narrar()` descarta por cantidad de hechos capturados. Si se supera el tope de diez mientras la solicitud sigue pendiente, es posible eliminar hechos más recientes de los previstos.

## H. Minijuegos

Los cuatro se activan con F/A dentro de su zona. Tras instrucciones, F/Enter/A según el control de aceptación inicia la partida. Esc cancela y el resultado permite volver a jugar. Cada ronda dura 60 s y devuelve puntos, con bonificaciones y penalizaciones. El temporizador marca el fin de ronda. No se encontró una meta obligatoria de victoria, derrota binaria, recompensa material ni récord persistente. Quien abre el panel pausa el mundo y al cerrarse restaura el control. Los efectos del panel y de aciertos/errores usan recursos Kenney.

| Minijuego y ubicación | Juego y controles | Resultado, NPC y prueba |
|---|---|---|
| Pesca · orilla oeste, al sur del puente | Izquierda/derecha, A/D o stick para mover la red. Atrapar peces, evitar piedras. | +10 pez, −5 pez escapado, −10 piedra. Tomás recibe el resultado. `validar_pesca.gd`, `validar_npc_pescador.gd`. |
| Cerveza · E01 | Mover el caldero con el eje horizontal. Recoger cebada, lúpulo, agua y levadura en el orden de la receta. | +5 correcto, −5 fuera de orden, +20 receta. Activación independiente del tabernero. |
| Pan · E02 | Izquierda/derecha elige entre cuatro bocas. F o aceptar saca el pan. | +10 dorado, −3 crudo, −5 quemado. Puede carbonizarse si se deja. Independiente del recado. |
| Forja · E03 | F o aceptar golpea al pasar por zona de acierto. Abajo recalienta la pieza. | +4 por golpe, +20 por completar cinco golpes válidos, −2 fuera de zona y −3 en frío. El herrero exterior no controla el minijuego. |

`validar_minijuegos_oficio.gd` prueba reglas, sonido cargado y eventos de reproducción, cierre, reinicio y separación de la salida para los tres oficios. `validar_pesca.gd` prueba reglas, apertura, pausa, resultado y cierre. Las comprobaciones automatizadas cubren la restauración del árbol y la UI en esos casos. La revisión audiovisual y una sesión con mando físico permanecen pendientes.

## I. Interfaz de usuario

| Interfaz | Estado y manejo | Revisión pendiente |
|---|---|---|
| Inicio | Arranque directo en Aldea. Sin menú principal, perfiles o pantalla de selección de partida. | Decidir su alcance con el guardado. |
| Pausa y opciones | Esc. Continuar, diario, opciones de IA, nueva historia con confirmación y salida. El menú de IA incluye clave, modelo, tope y estado de uso. | Foco, mando, resoluciones estrechas y resultado de «Probar conexión» real. |
| Diálogo fijo e IA | Caja fija con efecto de escritura. En IA, flechas/opciones, F, Enter, texto y Esc. | Test visual de textos largos, foco, espera, contraste y errores. |
| Contexto y bocadillos | Label3D en puertas, NPC y minijuegos. Bocadillos NPC–NPC y signo para búsqueda del jugador. En E01 se vieron legibles los avisos de entrada y salida a 1280×720. | Proximidad competida y legibilidad desde distintas orientaciones. |
| Diario y reloj | J o menú de pausa. Muestra franja, historia y sucesos recientes. | El panel tiene tamaño mínimo de 720×520. Falta comprobar ventanas más pequeñas y mandos. |
| Minijuegos | Temporizador, puntuación, instrucciones, resultado y audio. | Marco, escalado, colores y entrada con un mando real. |
| Viajes | Fundido oscuro con una capa CanvasLayer 100. Carga síncrona durante el negro. | Tiempo de carga en frío y falta de indicador de progreso. |

El proyecto declara stretch `canvas_items` y aspecto `expand`. El diálogo IA usa márgenes laterales fijos de 120 y alto nominal de unos 306 píxeles, con texto ajustable. El tamaño mínimo del menú de pausa es 620 de ancho. Riesgo estático de desborde con texto largo y ventanas estrechas. No hubo revisión visual en varias resoluciones. Tampoco se identificaron opciones generales de vídeo, audio, accesibilidad o reasignación de controles.

## J. Sistemas RPG

| Sistema | Estado |
|---|---|
| Misiones | PARCIAL. Un recado con estados de ejemplo y hilos narrativos del LLM. Sin diario de misiones mecánico, recompensas o estado de mundo ligado a su resolución. |
| Guardar y cargar | PARCIAL. Narrativa, reloj y configuración, sin ranuras ni posición persistente. |
| Tiempo | FUNCIONAL en el alcance lógico comprobado. Día de doce minutos, cuatro franjas, pausa durante interfaces. |
| Ciclo día/noche | PARCIAL. La franja sirve para rutinas e interfaz. Falta variación visual de luz, cielo y ambiente. |
| Oficios y progresión | PARCIAL. Hay partidas por puntos. Faltan progresión de profesión, recompensas y uso en la economía. |
| Inventario, objetos recogibles, equipamiento | NO IMPLEMENTADO. El pan del recado es un estado, sin objeto manipulable. |
| Estadísticas, salud, energía, experiencia y niveles | NO IMPLEMENTADO. Decisiones de diseño pendientes. |
| Economía, monedas y tiendas | NO IMPLEMENTADO. Mercado, mostradores y oficios son escenografía o entradas de minijuego. |
| Combate y enemigos | NO IMPLEMENTADO. El diseño actual prioriza vida social y exploración tranquila. |

## K. Arquitectura, assets y colaboración

- Proyecto Godot 4.7, ejecutable probado 4.7.2, Forward Plus/D3D12 y Jolt. Escenas y recursos guardan geometría, físicas, materiales y sprite frames. GDScript controla movimiento, shaders, navegación, interacción, UI y reglas. No se encontró un backend Python/Node ni dependencia externa de ejecución fuera del motor, assets y OpenRouter opcional. El `.mjs` de tests es inventario de autoría.
- Ocho autoloads en orden declarado: GestorRegiones, IA, Historia, Reloj, Aldeanos, DialogoIA, Diario y MenuPausa. Las señales enlazan cambio regional, historia, franjas, uso de IA, cierre de paneles y fin de partidas. Historia es estado compartido, incluido reloj. El orden de arranque y las rutas `Region/Jugador/CamaraPrincipal` son dependencias entre escenas y scripts.
- Las reglas de minijuego son separables de sus paneles y tienen lógica determinista con semilla. Los tres oficios comparten `minijuego_base.gd`. Pesca mantiene un flujo de panel similar por separado. Cada abridor gestiona la pausa. Las herramientas de editor regeneran escenas y no se requieren al jugar. La carga regional síncrona y la construcción de la cuadrícula de aldeanos pueden provocar pausas en frío. No se midió su duración gráfica ni el rendimiento sostenido.
- Censo de archivos bajo assets, incluidos auxiliares, ocultos e imports: Aldea 636, Naturaleza 245, Props 308, Bosque 1199, Granja 168, Interiores 1006, Audio 77 y Personajes 24. La suma de **3663 archivos** coincide con las 3663 rutas de assets versionadas. En `RPG/.gitignore` la exclusión `#/assets/` está comentada, discrepancia con AGENTS.md. `.godot/` y `logs/` sí están ignorados. Revisar procedencia y redistribución antes de publicar más recursos, en especial los FBX de E01. Los documentos de auditoría de interiores describen candidatos y licencias con mayor detalle.
- Por formato, se contaron 176 glTF de Aldea, 68 de Naturaleza, 94 de Props y 105 de Bosque, además de 60 GLB en Bosque. Granja contiene 14 GLB y exportaciones FBX/OBJ. Interiores contiene 92 GLB, 159 FBX y 25 OBJ. Los formatos alternativos y piezas de un mismo conjunto pueden duplicar geometría y el censo no acredita su uso dentro de una escena.
- Están presentes AGENTS.md, estado_proyecto.md, inventario_assets.md, interiores_aldea.md, integracion_assets_interiores.md y auditoria_assets_interiores.md. **AGENTS.md y estado_proyecto.md contienen marcadores de conflicto versionados**. Hay pasajes que anuncian conexiones o interiores como pendientes pese a que existen en las escenas. README describe la base actual con mayor acierto, pero su coste ilustrativo no fue verificado y el recado fijo tiene una interacción con el modo IA que merece documentarse.
- Para desarrollar en equipo, abrir `RPG/project.godot` con 4.7.2, comprobar que estén presentes los recursos referenciados y ejecutar F5. F6 en una escena envolvente permite entrar directamente a una región. Cada desarrollador configura por separado sus credenciales en Opciones de IA. Los datos personales quedan en `user://`. La rama `main` estaba limpia al inicio.

## L. Errores y riesgos

| Gravedad | Hallazgo | Evidencia |
|---|---|---|
| Alta | La regresión de Aldea falla en recorridos exteriores. Estas aserciones aparecen en registros históricos y vuelven a salir en la auditoría. | `tests/validar_distribucion.gd`, § O. |
| Alta | Lectura directa de una elección, tipos JSON poco defendidos y salida del diálogo deshabilitada durante espera. Un fallo de contrato puede prolongar o dejar atascada la pausa. | `scripts/ia/servicio_ia.gd`, `dialogo_ia.gd`. Inspección estática. |
| Alta | Conflictos de documentación y política de assets desalineada con Git. Afecta instrucciones de los dos desarrolladores y eventual distribución. | AGENTS.md, `docs/estado_proyecto.md`, `.gitignore` y censo Git. |
| Media | Guardado narrativo sin escritura atómica, validación estructural escasa y sin copia de recuperación. | `scripts/ia/historia.gd`. Inspección estática. |
| Media | El recado puede quedar oculto con IA y reinicia al salir y volver. Posibles competencias de F con NPC móviles. | `scripts/npc/npc_aldeano.gd`, `recado_pan.gd`, `scripts/interiores/puerta_interior.gd`. |
| Media | El validador aislado de río y puente puede anunciar cero fallos aunque abandone el recorrido con error de script. El ensayo activa la salida a Montañas, libera al jugador anterior y luego intenta consultarlo. | `tests/validar_rio_puente.gd`, `tests/validar_distribucion.gd:1235`, `rio_puente_fisica.log`. La regresión principal suspende los detectores regionales para la prueba física. |
| Media | Umbral de tokens con sobrepaso posible, configuración legible en disco y extractos de respuesta en logs. | `scripts/ia/servicio_ia.gd`. |
| Media | «Probar conexión» aplica y guarda opciones antes del diagnóstico. Habilitar IA puede además programar una solicitud de planificación. | `scripts/ia/menu_pausa.gd`, `aldeanos.gd`. Verificar con presupuesto y datos de prueba. |
| Media | La sesión headless informa que no pudo leer el almacén raíz de certificados. El efecto sobre HTTPS real queda sin comprobar. | Logs de auditoría. Incidencia histórica del entorno. |
| Media | Márgenes y mínimos de paneles, oclusión y carga en negro sin medición en resoluciones o hardware variados. | `scripts/ia/`, `scripts/gestor_regiones.gd`, planos regionales. |
| Baja | El laboratorio de proporciones exige velocidad 4 y la escena compartida usa el valor 10 que comprueban los interiores actuales. Falla la aserción combinada de escala y velocidad. | `tests/validar_proporciones.gd`, `scripts/jugador.gd` y `proporciones.log`. |

## M. Pendientes

- **Confirmados:** resolver los recorridos con fallo, reconciliar documentación y política de assets, verificar TLS y robustez de IA con respuestas anómalas, completar QA visual y con mando. El interior E12 sigue pendiente si se mantiene en el alcance.
- **Parciales:** guardado narrativo, recado, planificación social y progresión de oficios. El tiempo lógico aún carece de ciclo visual. Las regiones exteriores tienen exploración sin actividades propias.
- **Opcionales:** unificar los patrones de panel si se amplían los minijuegos, incorporar indicadores de carga según medición, ampliar opciones de accesibilidad y presentación.
- **Decisiones de diseño:** alcance de inventario, economía, recompensas, profesiones, guardado de mundo y uso de las regiones externas. Mantener como decisión explícita la ausencia de combate tradicional.

## N. Próximos pasos y matriz de prioridades

| Prioridad | Tarea | Estado actual | Motivo | Dependencias |
|---|---|---|---|---|
| P1 | Acotar y corregir los recorridos E04 y E12 | Regresión reproducida | Recuperar navegación exterior estable | Pruebas de recorrido y colisiones |
| P1 | Reconciliar documentación, procedencia y distribución de assets | Conflictos versionados y assets ya presentes en Git | Evitar que ambos desarrolladores trabajen con instrucciones diferentes | Decisión conjunta y revisión de licencias |
| P1 | Validar respuestas IA, cancelación, costes y manejo de TLS | Cliente real sin verificar | Evitar pausas atascadas y gasto inesperado | Fixtures de HTTP, permiso para prueba de servicio y clave dedicada |
| P1 | Definir contrato de persistencia y proteger el guardado | Narrativa local y recado/planes de sesión | Preservar datos y continuidad entre escenas | Decidir qué se guarda y cómo migrar |
| P2 | Probar recorridos con mando y variantes visuales, y decidir E12 | Headless y contenido exterior | Comprobar avisos, paneles, oclusión y recorrido real | Versión estable para recorrer y criterios del equipo |
| P2 | Añadir la primera actividad regional o progresión de oficio elegida | Exploración y minijuegos aislados | Dar continuidad a la sesión de juego | Decisión de diseño sobre recompensas y persistencia |
| P3 | Ampliar ciclo visual y presentación | Reloj lógico | Refuerzo ambiental | Decisión artística y rendimiento |

No se comprobó un P0 para el arranque o el juego offline en el equipo auditado.

## O. Pruebas reproducibles y evidencias

Godot `4.7.2.stable.official.ed1daf0bf`, desde la raíz de `RPG/`. Registros en `RPG/logs/auditoria_general_20261122_213005/`. Los scripts de integración activan el modo de pruebas del cliente IA. Las capas que necesitan respuestas usan un simulador. El arranque directo usó un perfil nuevo dentro de la carpeta de evidencia. No se realizaron solicitudes reales a OpenRouter.

Se identificaron 53 archivos `validar_*.gd`. Se ejecutaron 52 entradas. `validar_distribucion.gd` se ejercitó a través de `validar_aldea.gd`, que hereda sus comprobaciones sin añadir implementación. La tabla agrupa suites relacionadas y consigna los resultados válidos de las repeticiones.

```text
godot --headless --path . --log-file logs/<nombre-nuevo>.log --script res://tests/validar_<prueba>.gd
```

Para repetir Bosque–Ruinas, Campos, Montañas y Minas se usó `--fixed-fps 60` en las suites de **transición**, según las instrucciones de transición y las comprobaciones de giro por fotogramas. La repetición de interiores E02–E11 también se hizo con ese parámetro para completar la suite a tiempo. La regresión pesada de Aldea usa tiempo real para comparar la rueda con el reloj.

| Prueba | Resultado | Evidencia |
|---|---|---|
| Arranque por escena principal | APROBÓ con código 0. Carga la Aldea desde la configuración del proyecto en perfil nuevo. | `arranque.log`. |
| Aldea | FALLÓ. E04 retorno exterior al camino público y E12 conexión de accesos norte/sur y ambas márgenes por puente. 13.695 muestras, 36 corredores. | `aldea.log`. Los dos fallos aparecen también en `RPG/logs/interiores_e02_e11/02_base_historicos.log` y en el estado previo. |
| Cámara principal | APROBÓ. Órbita, vuelta completa y entrada analógica simulada. | `camara_orbital.log`. |
| E01 | APROBÓ en headless y con ventana. 225 comprobaciones, cinco ciclos por ejecución. Restablece jugador y cámara. Se revisaron la captura de aproximación exterior y la de aparición interior a 1280×720. | `interior_taberna.log`, `interior_taberna_visual.log`, `RPG/logs/taberna_e01_2026-11-22T21-38-03_2484/`. |
| E02–E11 | APROBÓ. 2.569 comprobaciones, 30 ciclos y 60 viajes. Materiales, sólidos, animación, cámara, entrada, salida y retorno. | `interiores_aldea_60fps.log`. El primer intento a tiempo real agotó su espera tras certificar E02–E05. |
| Pesca, pescador, aldeanos, oficios | APROBARON las cuatro suites. Incluyen diálogo fijo, recado, reglas, apertura/cierre, vuelta a la partida, resultado, colisiones de ejemplo y carga de audio. | `pesca.log`, `npc_pescador.log`, `npcs_aldea.log`, `minijuegos_oficio.log`. |
| IA 1–3 | APROBARON con simulador. Capa 1 guarda/recupera una historia temporal en perfil aislado. Capas 2 y 3 comprueban planificación, navegación y simulación o bocadillos. | `ia_capa1_perfil.log`, `ia_capa2.log`, `ia_capa3.log`. El intento inicial de capa 1 falló al guardar/recuperar el fixture con el perfil predeterminado y dejó errores derivados. La repetición con `APPDATA` temporal pasó. |
| Aldea ↔ Bosque | APROBÓ. 287 comprobaciones y 10 viajes. | `transiciones.log`. |
| Bosque ↔ Ruinas | APROBÓ. 638 comprobaciones y 26 cambios. | `bosque_ruinas_60fps.log`. El intento sin paso fijo produjo aserciones de órbita. |
| Aldea ↔ Campos | APROBÓ. 447 comprobaciones y 16 viajes. | `transicion_campos_60fps.log`. El intento sin paso fijo produjo aserciones de órbita. |
| Aldea ↔ Montañas | APROBÓ. 379 comprobaciones y 16 viajes. | `transicion_montanas_60fps.log`. |
| Montañas ↔ Minas | APROBÓ. 189 comprobaciones y 12 viajes. | `transicion_minas_60fps.log`. |
| Recorridos físicos de Bosque, Campos, Montañas, Minas y Ruinas | APROBARON con paso fijo. Respectivamente 20.485, 1.160, 4.355, 1.207 y 517 comprobaciones. Campos informó 0 bloqueos y las pruebas cubren trayectos previstos. | `bosque_60fps.log`, `campos_granjas_60fps.log`, `montanas_60fps.log`, `minas_60fps.log`, `ruinas_60fps.log`. |
| Laguna y vegetación forestal | APROBARON. 21.116 y 95.502 comprobaciones respectivamente. | `laguna_bosque.log`, `vegetacion_bosque.log`. |
| Terreno, salidas, huertos, jardín, mercado, mirador y vegetación de Aldea | APROBARON. Cobertura de reservas y geometría de las respectivas escenas. | `terreno_caminos.log`, `salidas.log`, `huertos.log`, `jardines.log`, `mercado_plaza.log`, `mirador.log`, `vegetacion.log`. |
| Molino | FALLÓ. Repite la aserción de conectividad E12 de la Aldea. | `molino.log`. |
| Río y puente aislados | INCONCLUSO. Tras el cruce oeste–este se activa el viaje a Montañas y la comprobación accede al jugador ya liberado. El contador final dice cero, pero la suite se interrumpe. La regresión de Aldea sí verificó ambos cruces aislados y las barreras. | `rio_puente_fisica.log`, `aldea.log`. |
| Exterior y órbita de edificios | APROBARON E01/E06, carpintería, herbolario, herrería y las vistas o recorridos específicos de las viviendas ensayadas. Las entradas generales de panadería, herrería y vivienda noreste heredan la misma regresión y repiten E04/E12. | `edificios_360.log`, `carpinteria_360.log`, `herbolario_360.log`, `herreria_360.log`, `vivienda*.log`, `panaderia.log`, `herreria.log`. |
| Laboratorios y aldea respaldada | APROBARON laboratorio de assets, su cámara y aldea anterior. FALLÓ proporciones por la comprobación que espera velocidad 4. | `pruebas_assets.log`, `camara_orbital_assets.log`, `aldea_anterior.log`, `proporciones.log`. |

Los intentos sin paso fijo de Bosque–Ruinas y de transiciones de Campos, Montañas y Minas se cortaron por tiempo. Las repeticiones a 60 FPS simulado completaron los recorridos de las cuatro suites. Las pruebas físicas de Campos y Montañas también se completaron con paso fijo y los intentos a tiempo real agotaron la espera. La prueba física de Minas a tiempo real completó 1.207 comprobaciones con un fallo en la vuelta completa de cámara por entrada. La misma prueba con paso fijo y el validador de cámara principal aprobaron. El fallo dependió del modo de ejecución observado y queda registrada la limitación de la comprobación por fotogramas.

El mensaje sobre el almacén raíz de certificados aparece en las ejecuciones y en evidencia histórica. Las advertencias de destino inexistente en pruebas de recuperación pueden ser controles negativos deliberados. Las pruebas sirven para los casos que recorren, usan posiciones de ensayo y generan inputs en el motor. Quedan pendientes la conectividad y el coste real, exploración libre con mando físico, verificación de audio con escucha, resoluciones adicionales, oclusiones, calidad artística y rendimiento gráfico. Los capturadores e inventariadores especializados de Bosque, Granja y Montañas quedaron fuera de esta ejecución. Son herramientas de catálogo o evidencias artísticas. AGENTS.md y `RPG/docs/estado_proyecto.md` se revisaron y quedan sin editar por el alcance de auditoría.

## RESUMEN PARA EL EQUIPO

1. **Qué tenemos.** Una aldea medieval con doce edificios por fuera, once salas visitables y cinco regiones alrededor.
2. **Qué podemos jugar.** Mover al protagonista, girar la cámara, viajar entre regiones, entrar y salir con F, hablar, hacer un recado y jugar cuatro actividades. Los recorridos exteriores de la carpintería y el molino aún fallan en la prueba de Aldea.
3. **Qué se incorporó a los NPC.** Tomás, Marta, Gonzalo, Anselmo y Bruno tienen sprites y diálogos propios. Bruno patrulla. La capa de IA permite que todos se muevan, se visiten, busquen al jugador y hablen entre sí.
4. **Cómo funciona la IA.** Godot envía el contexto a OpenRouter si cada desarrollador configura su propia clave. El flujo con respuestas simuladas funciona y los diálogos fijos permiten jugar offline. La conexión real sigue por comprobar.
5. **Qué minijuegos hay.** Pesca junto al puente, cerveza en la taberna, pan en la panadería y forja en la herrería.
6. **Qué recuerdan.** La historia, los rumores, recuerdos y la hora se guardan localmente. El recado y los contadores de instancia se reinician al volver a cargar la Aldea. No hay base de datos ni guardado integral.
7. **Cuántos interiores.** Once funcionales y probados, E01–E11. E12 tiene rueda y exterior, pero carece de sala visitable.
8. **Qué está incompleto.** Progresión de oficio, actividades regionales, continuidad del mundo, iluminación según la hora y misiones más allá del recado y los hilos narrativos.
9. **Qué errores atender.** Recorridos E04 y E12, manejo de respuestas IA y espera, guardado frágil y documentos con conflictos. Revisar los assets ya versionados antes de distribuir.
10. **Qué haríamos después.** Estabilizar navegación, acordar las reglas de assets y documentación, reforzar IA y guardado y recorrer el juego con ventana y mando.
11. **Qué debe decidir el equipo.** Alcance de inventario, economía, recompensas, persistencia del mundo, interior del molino y primera actividad propia de una región exterior.
