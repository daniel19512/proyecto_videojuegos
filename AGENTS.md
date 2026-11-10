# Instrucciones permanentes para agentes

## Lectura inicial y fuentes de verdad

Estas instrucciones se aplican a todo el repositorio y a cualquier agente de programación, incluido Codex. El proyecto Godot está dentro de `RPG/`, no en la raíz.

Al comenzar cada tarea:

1. Leer `AGENTS.md` y `RPG/docs/estado_proyecto.md`.

2. Consultar los documentos relevantes; para recursos, leer `RPG/docs/inventario_assets.md`.

3. Inspeccionar los archivos relacionados y el estado de Git antes de modificar nada.

4. Identificar riesgos, cambios previos y restricciones de alcance; preservar el trabajo existente.

El código y la configuración inspeccionados determinan qué está implementado. El estado documenta el progreso y el siguiente objetivo; este archivo conserva reglas y decisiones duraderas. `README.md` presenta públicamente el RPG actual en Godot; úsalo para orientación general, pero verifica los detalles técnicos y el estado real en el código, `RPG/docs/estado_proyecto.md` y `RPG/docs/inventario_assets.md`. Ningún documento autoriza commits ni pushes sin permiso explícito.

## Visión del videojuego, no lista de funciones terminadas

Proyecto inicialmente escolar: RPG medieval de fantasía y simulación de vida, con entorno completamente 3D y personajes representados por sprites 2D pixel art dentro de ese entorno. La presentación utiliza cámara ortográfica inclinada.

La visión futura incluye explorar aldeas y otros escenarios; NPCs con personalidades, rutinas, memoria, relaciones y comportamientos; diálogos e interacciones sociales; profesiones como herrería y agricultura con minijuegos; misiones y eventos relacionados con la vida de la aldea. No está previsto un sistema de combate tradicional.

La base existente permite movimiento y presentación del protagonista en una aldea modular. El único minijuego implementado es la pesca junto al puente, acompañada por un NPC pescador con diálogo fijo. Los sistemas sociales, NPCs autónomos o con LLM, rutinas, profesiones, otros minijuegos, misiones y eventos no están implementados. No confundir modelos decorativos o nombres de nodos con sistemas de juego.

## Tecnologías y arquitectura actual

\- Versión objetivo: ****Godot 4.7.2****, con ****GDScript****. `RPG/project.godot` declara características `4.7` y `Forward Plus`; no codifica el parche exacto. El inventario registra una auditoría anterior con 4.7.2.

\- Renderizado Forward Plus; controlador de Windows configurado como `d3d12`. Física 3D: ****Jolt Physics****.

\- Escena principal: `RPG/scenes/mundo.tscn`, cuyo UID coincide con `run/main_scene` de `RPG/project.godot`.

\- `Mundo` reúne aldea, protagonista, cámara, luz solar y ambiente. La geometría y configuración visual se definen en escenas; el comportamiento de movimiento y seguimiento, en scripts separados.

\- El protagonista es `CharacterBody3D` con cápsula y `AnimatedSprite3D`; sus animaciones están en un recurso `SpriteFrames`. No es un personaje de malla 3D.

\- Los modelos se referencian como escenas glTF importadas. Las colisiones de la aldea se añaden en la escena, sin modificar los originales.

\- No hay backend de NPCs, integración LLM ni dependencias Python/Node.js implementadas. Las menciones históricas del README y los patrones de exclusión no acreditan esas tecnologías.

### Organización existente

\| Ubicación | Responsabilidad |

\|---|---|

\| `RPG/project.godot` | Configuración del motor, escena inicial y acciones de entrada. |

\| `RPG/assets/` | Modelos, texturas y sprites locales; excluidos intencionalmente de Git. |

\| `RPG/scenes/` | Escenas 3D `.tscn` y recurso `jugador_frames.tres`. |

\| `RPG/scripts/` | GDScript de jugador, cámara y mundo; archivos UID asociados. |

\| `RPG/tests/` | Script de validación `validar_aldea.gd`; no se ha identificado un framework externo de pruebas. |

\| `RPG/docs/` | Estado del proyecto e inventario detallado de assets. |

### Sistemas existentes y archivos responsables

\| Sistema | Archivos |

\|---|---|

\| Movimiento relativo a cámara, aceleración, frenado, gravedad y `move_and_slide()` | `RPG/scripts/jugador.gd`, `RPG/scenes/jugador.tscn`; entradas en `RPG/project.godot`. |

\| Animaciones idle/walk en cuatro direcciones | `RPG/scripts/jugador.gd`, `RPG/scenes/jugador_frames.tres`, `RPG/scenes/jugador.tscn`. |

\| Cámara orbital ortográfica 360° con seguimiento suavizado; tamaño 15 en el mundo principal | `RPG/scripts/camara_orbital.gd`, `RPG/scenes/mundo.tscn`; seguimiento fijo conservado para respaldos/muestras en `RPG/scripts/camara_seguimiento.gd`. |

\| Terreno 80×72, plaza 20×18, corredores, parcelas y reservas visuales de la etapa 2; suelo y límites sólidos | `RPG/scenes/aldea.tscn`; cápsula del personaje en `RPG/scenes/jugador.tscn`. |

\| Punto de interacción y minijuego de pesca | `RPG/scripts/pesca/`, `RPG/scenes/punto_pesca.tscn`, `RPG/scenes/minijuego_pesca.tscn`; acción `interactuar` en `RPG/project.godot`. |

\| Composición principal, iluminación y ambiente | `RPG/scenes/mundo.tscn`; `RPG/scripts/mundo.gd` solo imprime mensajes de bienvenida. |

\| Validación del mundo actual: movimiento, cámara, suelo, límites, conectividad, reservas y solapes | `RPG/tests/validar_aldea.gd` es la entrada de `RPG/tests/validar_distribucion.gd`. La composición anterior conserva sus comprobaciones en `RPG/tests/validar_aldea_anterior.gd`. Su existencia no equivale a una ejecución aprobada en cada sesión. |

`RPG/scenes/casa_modular.tscn` se reutiliza en `RPG/scenes/pruebas_assets.tscn`; la aldea actual incorpora taberna E01 y vivienda E06 mediante `RPG/scenes/taberna.tscn` y `RPG/scenes/vivienda_noroeste.tscn`, con muros, cubierta y colisiones separados. Cada edificio usa cuatro cajas perimetrales, incluidas sus puertas cerradas; no llenar su volumen con una caja. E01–E12 están construidos; el estado y el plano registran sus escenas y validaciones actuales. La escena de pruebas es independiente y no sustituye la escena principal; reutiliza jugador, seguimiento e iluminación, y añade colisiones sin editar los glTF. Su prueba reproducible es `RPG/tests/validar_pruebas_assets.gd` (headless o con capturas en `user://` al ejecutarse con ventana). `RPG/scenes/pruebas_proporciones.tscn` compara tres cuerpos modulares mediante un controlador visual exclusivo y `RPG/tests/validar_proporciones.gd`. Consultar el estado para resultados y limitaciones.

La composición anterior de cuatro edificios se conserva en `RPG/scenes/respaldos/aldea_etapa1.tscn`; `RPG/scenes/respaldos/mundo_etapa1.tscn` permite abrirla y ejecutarla con F6 sin cambiar la escena principal. No sobrescribir esos respaldos al continuar. La validación anterior conserva todas sus comprobaciones, dirigida a ese mundo respaldado.

Proporciones aprobadas para futuros edificios definitivos: cuerpos 4×4 y 4×6 con cubierta a escala Y=0.60; cuerpos 6×8 con Y=0.55. Mantener X/Z a 1, muros y puertas sin escalar, y aplicar el mismo factor vertical a tejado y frontones mediante un padre común. La muestra apoya raíces en Y=0.003 y sitúa ese padre a Y=3 local; conservar los encajes y verificar la geometría de cada variante. No escalar al protagonista para adaptar arquitectura.

Las reservas lógicas de parcelas y jardines conservan sus nodos `Marca` como planos sin colisión. Los tres huertos construidos se instancian separadamente bajo `Huertos`, con obstáculos propios. Los metadatos de centros, reservas, accesos, anchuras y futuras cubiertas deben mantenerse coherentes con las marcas visibles; `validar_distribucion.gd` contrasta su geometría real. Los accesos solo pueden atravesar la reserva de su propia parcela/zona. Las reservas de río/puente/rueda admiten cruces previstos; la fase 4A conserva la caja de suelo continua y añade un cauce visual con barreras físicas; el paso sobre agua solo se permite por el puente.

El tamaño ortográfico aprobado para la cámara principal es **15**, configurado en `RPG/scenes/mundo.tscn` (`CamaraPrincipal.size`). El mundo y el laboratorio comparten `RPG/scripts/camara_orbital.gd`: órbita horizontal continua de 360°, inclinación de aproximadamente -32°, seguimiento del centro suavizado y radio conservado. `RPG/scripts/camara_orbital_assets.gd` es un adaptador del laboratorio sin duplicar la lógica. `camara_seguimiento.gd` conserva el seguimiento fijo de respaldos y muestras; ninguno de los scripts sobrescribe el tamaño ortográfico.

Controles persistentes en `RPG/project.godot`: Q/E y stick derecho X mediante `girar_camara_izquierda/derecha` (zona muerta 0.20); WASD/flechas y stick izquierdo X/Y mediante acciones de movimiento existentes. Al salir de la cámara se liberan estados, sin borrar acciones ni eventos de InputMap. El jugador conserva cuerpo físico sin rotar, parámetros originales y movimiento/animaciones relativos a pantalla. La acción `interactuar` (F y botón 0 del mando) es la tecla común para interacciones con el mundo; no reutilizar E, que gira la cámara. No incorporar zoom dinámico, inclinación controlable ni transparencia de obstáculos sin una tarea específica.

Conservar el selector local de `RPG/scenes/pruebas_assets.tscn` (23/19/17/15, inicio en 15) para comparar; su tamaño opcional no modifica la cámara del mundo. Validación orbital compartida: `RPG/tests/validar_camara_orbital_assets.gd` para laboratorio y `RPG/tests/validar_camara_orbital.gd` para mundo. `RPG/tests/validar_edificios_360.gd` verifica cierres geométricos y captura E01/E06 en ocho ángulos; esta geometría y headless no sustituyen la revisión visual de texturas, encajes y oclusión.
## Recursos y assets

Paquetes identificados por el proyecto y contenido local verificado:

\| Paquete | Carpeta | Recursos canónicos glTF/GLB |

\|---|---|---:|

\| Quaternius Medieval Village MegaKit | `RPG/assets/aldea/` | 176 |

\| Quaternius Stylized Nature MegaKit | `RPG/assets/naturaleza/` | 68 |

\| Quaternius Fantasy Props MegaKit | `RPG/assets/objetos_medievales/` | 94 |

\| KayKit Forest Nature Pack 1.0 | `RPG/assets/bosque/kaykit_forest/` | 105 glTF; FBX/OBJ alternativos no suman modelos. |

\| Forest Nature Updated, hooray4brains | `RPG/assets/bosque/forest_nature_updated/` | 60 GLB. |

\| Sprites del protagonista | `RPG/assets/personajes/protagonista/` | 0; dos hojas PNG: `Character_Idle.png` y `Character_Walk.png`. |

Total local verificado: ****503 recursos canónicos glTF/GLB**** (338 Quaternius anteriores y 165 nuevos). Los 480 archivos nuevos incluyen 315 exportaciones alternativas KayKit; sus 165 entradas contienen 161 geometrías según la comparación de 6A.0. No confundir rutas canónicas, geometrías y variedad visual. El inventario detallado y sus límites están en `RPG/docs/inventario_assets.md`; no confundir disponibilidad con integración en escenas o gameplay.

****Toda `RPG/assets/` debe permanecer excluida de nuevas incorporaciones a Git.**** No quitar la exclusión, no forzar su incorporación y no intentar subir modelos a GitHub. Clonar el repositorio no basta para obtener los recursos: deben estar disponibles localmente con sus rutas originales. No modificar, eliminar, mover ni renombrar assets originales sin autorización. Conservar procedencia y condiciones de licencia cuando se disponga de ellas; no asumir licencias por el nombre del paquete.

## Convenciones obligatorias de rutas

\- En Godot, utilizar `res\://` para recursos del proyecto; su raíz corresponde a `RPG/`.

\- Utilizar `user://` para archivos del usuario o datos generados durante la ejecución cuando corresponda.

\- En documentación e informes, usar rutas relativas a la raíz del repositorio, por ejemplo `RPG/scenes/aldea.tscn` y `RPG/docs/inventario_assets.md`. Para referencias de Godot: `res\://scenes/aldea.tscn`.

\- No incluir rutas absolutas de Windows, Linux o macOS, nombres de usuario ni ubicaciones personales en documentación, informes o código persistido.

\- En scripts externos, resolver rutas a partir de una ubicación conocida del proyecto, no de un directorio personal ni del directorio de trabajo accidental.

\- No modificar las referencias internas de archivos glTF sin justificación; conservar las relaciones entre glTF, BIN y texturas.

## Reglas de programación y alcance

1. Inspeccionar los archivos relevantes antes de modificarlos y respetar la arquitectura existente.

2. Realizar cambios pequeños, organizados y verificables; no reescribir sistemas completos para un ajuste puntual.

3. Trabajar únicamente en el alcance solicitado; no modificar funcionalidades ajenas.

4. Mantener compatibilidad con Godot 4.7.2 y usar GDScript claro y mantenible, siguiendo las convenciones existentes.

5. Evitar dependencias innecesarias y mantener separadas las responsabilidades de escenas y scripts.

6. Preservar las funcionalidades existentes y comprobar errores y compatibilidad durante la implementación.

7. Validar los cambios antes de declararlos terminados; distinguir revisión estática, ejecución headless y revisión visual real.

8. No modificar ni eliminar assets originales sin autorización.

9. No alterar controles, cámara ni protagonista salvo que la tarea lo requiera.

## Git y GitHub

\- Trabajar sobre la rama indicada por el usuario. Si no indica otra, preservar la rama actual; no cambiarla por iniciativa propia.

\- No ejecutar commits ni pushes sin autorización explícita; nunca hacerlos automáticamente al finalizar.

\- No modificar `.gitignore` innecesariamente. Mantener `RPG/assets/` excluida de Git aunque un comentario antiguo diga que la exclusión es temporal.

\- No subir temporales ni cachés de Godot, incluida `RPG/.godot/`.

\- Mantener versionados `AGENTS.md` y los documentos del proyecto salvo indicación contraria. Esto no autoriza a ejecutar un commit.

\- No revertir ni incorporar como propios cambios previos del usuario. Revisar el diff y comunicar qué archivos se tocaron realmente.

## Registros de pruebas y validaciones

**Todos los archivos de registro generados durante pruebas y validaciones deben almacenarse en `RPG/logs/`. No generar archivos `.log` en la raíz de `RPG/`.** Son registros temporales excluidos de Git por `/logs/` en `RPG/.gitignore`; no incluirlos en commits ni forzar su incorporación. Conservar los registros existentes y no sobrescribirlos sin autorización; usar nombres nuevos para ejecuciones adicionales.

La carpeta se crea localmente antes de validar, ya que Git no la distribuye. Godot 4.7.2 resuelve `--log-file` respecto a la raíz del proyecto indicada por `--path`: desde la raíz del repositorio usar `--path RPG --log-file logs/<nombre>.log`; desde `RPG/`, usar `--path . --log-file logs/<nombre>.log`. Ambos escriben en `RPG/logs/`. Las redirecciones de terminal se resuelven respecto al directorio actual: desde la raíz del repositorio usar `RPG/logs/<nombre>.log`; desde `RPG/`, usar `logs/<nombre>.log`. No cambiar por ello la lógica de las pruebas ni la configuración de registro del juego.
## Validación y cierre obligatorio

1. Validar los cambios según su alcance. Para lógica o escenas, considerar la prueba existente, desde la raíz del repositorio, con un ejecutable de Godot 4.7.2 disponible en el entorno:

   ```text

   godot --headless --path RPG --log-file logs/validar_aldea.log --script res://tests/validar_aldea.gd

   ```

   `godot` representa el ejecutable configurado en el entorno, no una herramienta incluida en el repositorio. El mundo actual guarda capturas `user://distribucion_*.png` al ejecutar la prueba con ventana; headless no sustituye una revisión gráfica. La prueba anterior se ejecuta con `--script res://tests/validar_aldea_anterior.gd`, requiere los assets locales y conserva su captura separada `user://aldea_etapa1_respaldada.png`. No sustituir la validación actual por la del respaldo.

2. Revisar los archivos editados y el diff final; preservar los cambios ajenos.

3. Informar archivos modificados, qué se implementó, pruebas realizadas y resultados, problemas y limitaciones. Si no fue posible ejecutar el motor, decirlo expresamente.

4. Revisar si corresponde actualizar ambos documentos y declarar en cada informe final si se actualizaron o por qué no correspondía.

5. No hacer commits ni pushes automáticamente.

## Mantenimiento automático y permanente de la documentación

Codex y cualquier otro agente deben ****revisar y mantener actualizados `AGENTS.md` y `RPG/docs/estado_proyecto.md` conforme evolucione el proyecto****, dentro del alcance autorizado de cada tarea.

Actualizar ****`AGENTS.md`**** cuando se implemente un sistema importante que cambie la arquitectura, se incorporen paquetes de assets, herramientas o dependencias, cambie la organización del repositorio, se establezcan convenciones, se tomen decisiones técnicas permanentes, cambien las reglas de trabajo o aparezca información duradera importante para futuras sesiones.

Actualizar ****`RPG/docs/estado_proyecto.md`**** cuando se complete una etapa, se añada una funcionalidad, cambien prioridades o el estado de un sistema, se detecte o resuelva un problema relevante o se establezca el siguiente objetivo.

Reglas de mantenimiento:

1. Leer ambos documentos al comenzar y actualizarlos al finalizar cuando existan cambios relevantes.

2. No duplicar información innecesaria: instrucciones y arquitectura estable aquí; progreso, problemas, historial y siguiente objetivo en el estado; detalle de assets en el inventario.

3. No registrar funciones futuras como terminadas ni confundir pruebas pendientes con aprobadas.

4. No borrar decisiones que sigan siendo válidas; mantener contenido conciso y fácil de consultar.

5. No convertir `AGENTS.md` en un historial de tareas; conservar ese historial en el estado.

6. Indicar en cada informe final si se actualizaron estos documentos.

7. No realizar cambios documentales si no hay información nueva relevante.

## Límites de distribución durante el juego

`RPG/scripts/depuracion_parcelas.gd`, asignado a la raíz de `RPG/scenes/aldea.tscn`, controla las mallas `Borde*` de Parcelas, Jardines, Reservas y Plaza. La propiedad exportada `mostrar_limites_parcelas` es falsa por defecto: los límites de desarrollo permanecen disponibles en edición y se ocultan al ejecutar. Puede activarse en el Inspector de `Mundo/Aldea` antes de F6 o en el Inspector remoto durante la ejecución. No eliminar ni mover reservas, identificadores o metadatos para ocultar marcas. Las pruebas deben comprobar geometría lógica independientemente de la visibilidad y conservar la detección de bloqueos reales. Las marcas de relleno no son parte de este interruptor.

## Río, puente y rueda — fase 4A

`RPG/scenes/rio.tscn` y `RPG/scenes/puente.tscn` se instancian en `aldea.tscn`. Geometría y colisiones serializadas en escenas; agua opaca animada en `RPG/scripts/agua_estilizada.gdshader`. Suelo 80×72 Y=0 conservado, sin excavación; agua principal Y=0.32 y alimentación lateral Y=0.322, provisionales. Desde fase 4A.1, agua/orillas/barreras cubren Z=[-48,48] y la reserva lógica alcanza los límites jugables Z=±36: no conservar pasos de tierra en extremos ni permitir rodear el río fuera del puente. El shader expone velocidad, ondas, reflejos y colores; capas hacia +Z a 0.65 y 0.468 u/s por defecto. Mantener barreras del río y abertura del cruce, sin permitir caminar sobre agua. Puente centrado en (30,0,0), longitud 8 y 3 libres; tablero Y=0.48 y rampas dentro de reserva. No modificar los metadatos del corredor estructural de 4 para adaptar el ancho libre del puente.

`RPG/scripts/rueda_hidraulica.gd` anima exclusivamente `RuedaHidraulicaPivot` sobre X a -9°/s; las paletas inferiores avanzan hacia +Z como la corriente. Pivote mundial (26.5,2.503,-10), eje y soportes conservados; soportes fijos fuera del pivote. El canal llega a la rueda dentro de las reservas técnicas. No trasladar el molino ni añadir física hidráulica para ajustar la integración.

`RPG/tests/validar_rio_puente.gd` valida agua, cruce, barandas y giro; con ventana y `-- --capturas` guarda siete vistas y una secuencia de cámara fija en una subcarpeta nueva de `RPG/logs/fase4a1_rio_mejorado/`. Verificar movimiento con fotogramas distintos, no solo mediante una captura estática. La regresión compartida comprueba apoyo a la cota del puente, tres unidades libres solo en el cruce y barreras verificadas; conserva controles de edificios y detección de obstáculos. Los recorridos E12 comprueban sus accesos norte/sur y ambas márgenes mediante el puente; está prohibido usar suelo al norte/sur del río para cerrar un circuito. Las pruebas verifican por separado que ambos extremos y los límites exteriores bloqueen el rodeo. Véanse coordenadas y limitaciones en el plano y resultados en el estado. La aprobación visual sigue a cargo del usuario.
## Terreno y caminos — fase 4B.1

`RPG/scripts/terreno_aldea.gd`, en el nodo `AcabadoTerreno` de `aldea.tscn`, crea una máscara determinista 800×720 a partir de los 36 corredores existentes y la plaza. `RPG/scripts/terreno_aldea.gdshader` mezcla hierba, tierra y explanada en coordenadas del mundo sobre la caja original del suelo. No añade geometría ni colisiones. Mantener marcas, transformaciones y metadatos como fuente lógica del plano; no sustituirlos por el contorno visual del shader. Las marcas de relleno y rótulos se ocultan con el acabado; los bordes Borde* siguen controlados por `depuracion_parcelas.gd`. No tocar escenas de edificios para ajustar el terreno. El capturador `RPG/tests/validar_terreno_caminos.gd` genera ocho parejas antes/después y galería en una subcarpeta nueva de `RPG/logs/fase4b1_terreno_caminos/`; desactiva temporalmente el acabado sin modificar archivos guardados. Revisión visual del usuario necesaria antes de 4B.2.

## Huertos decorativos — fase 4B.2

Tres escenas propias bajo `RPG/scenes/`: `huerto_comunitario.tscn`, `huerto_e09.tscn`, `huerto_e10.tscn`, instanciadas en `Aldea/Huertos` sobre sus reservas aprobadas, conservando las marcas lógicas de `Jardines`. E06 ya tenía huerto; no confundir las tres reservas agrícolas construidas con JardínHierbas, mirador o mercado, aún pendientes. Cultivos decorativos, sin sistemas agrícolas jugables. Cercas y tutores bajos; 16 formas individuales en tres cuerpos físicos, sin colisión por planta ni caja de parcela completa.

`RPG/scripts/editor/construir_huertos.gd` es una herramienta de autoría opcional que regenera únicamente esas tres escenas; no ejecutarla para jugar ni para un simple ajuste manual de escena. Los cambios que deban sobrevivir a una regeneración también deben aplicarse en la herramienta. No introducir generación por fotograma. Las escenas guardan geometría y colisiones; materiales locales de Carrot/FarmCrate_Carrot habilitan colores de vértice sin editar materiales originales. Para guardar overrides en descendientes de glTF, marcar editable la instancia y conservar la propiedad original de sus hijos; no reasignar sus owners como nodos nuevos.

`RPG/tests/validar_huertos.gd` comparte los controles de `validar_distribucion.gd` y genera 31 capturas en una subcarpeta nueva de `RPG/logs/fase4b2_huertos/`. La regresión solo admite cuerpos agrícolas como mobiliario tras verificar formas, geometría, contención y pasos; nunca exceptuar la reserva completa ni los 36 corredores. Se conserva la aserción de retorno E04 y la velocidad temporal 10. Las cubiertas existentes pueden ocultar los huertos traseros desde el norte; consultar estado y capturas antes de afirmar que la revisión orbital está libre de oclusión. Aprobación visual del usuario antes de continuar jardines.

## Regiones independientes y salidas — fase 4B.6

El mundo futuro se organiza en escenas regionales independientes conectadas; la aldea sigue siendo la región principal. `RPG/scenes/salidas_aldea.tscn`, instanciada como `Aldea/SalidasRegionales`, define tres salidas estables: norte a Bosque, sur a CamposYGranjas y este a CaminoMontanas mediante el puente. Cada salida conserva metadatos `id_salida`, `destino_previsto`, `orientacion`, `camino_conexion`, `limite_provisional` y `retorno_previsto`, además de Marker3D `Aproximacion`, `TransicionFutura` y `LimiteProvisional`. Mantener estos identificadores al implementar transiciones.

<<<<<<< Updated upstream
Las regiones exteriores, Area3D y cambios de escena aún no existen. Los cuatro límites físicos originales permanecen cerrados; los límites norte, sur y este son el cierre provisional documentado después de los marcadores futuros. No abrirlos ni permitir caminar fuera del terreno hasta que la escena de destino y el sistema de transición estén implementados conjuntamente. Las señales son geometría estática sin colisión; no bloquean los corredores. Minas y ruinas se conectarán a través de regiones futuras, no requieren salidas directas nuevas desde la aldea.

## Interacciones y minijuego de pesca

`RPG/scenes/punto_pesca.tscn`, instanciado como `Aldea/PuntoPesca` en la orilla oeste al sur del puente (26.9, 0, 4), es el patrón de punto de interacción: `Area3D` de solo detección (`collision_layer = 0`), sin cuerpos sólidos, aviso `Label3D` visible solo con el protagonista dentro y apertura con `interactuar`. Detecta al protagonista como el único `CharacterBody3D` del mundo; por eso los NPCs actuales son `StaticBody3D`. Si un NPC pasa a moverse como `CharacterBody3D`, cambiar antes la detección a un grupo o a una referencia explícita. No mover el punto dentro del agua, del tablero del puente ni de corredores sin revalidar.

Los minijuegos se abren pausando el árbol (`get_tree().paused = true`) y su interfaz corre en `PROCESS_MODE_ALWAYS`. Así se congelan protagonista, cámara y animaciones sin editar sus scripts; quien abre el panel quita la pausa al recibir su señal `cerrado`. Mantener separadas las reglas puras (`RPG/scripts/pesca/logica_pesca.gd`, `LogicaPesca`, determinista con semilla) y la vista (`minijuego_pesca.gd`, dibujo con `_draw()` y estados instrucciones/partida/resultado). Los gráficos son formas provisionales dibujadas por código; pueden sustituirse por sprites sin tocar la lógica. Puntuación: pez +10, pez escapado −5, piedra atrapada −10; partida de 60 s. No hay recompensas, inventario ni guardado de récords.

`RPG/tests/validar_pesca.gd` valida reglas e integración en `mundo.tscn` (aviso, pausa, inicio, resultado y Esc). Si se cambian reglas o constantes, actualizar la prueba. La aprobación jugable y visual sigue a cargo del usuario.
<<<<<<< Updated upstream

Los NPCs se instancian en `Mundo/NPCs` (`RPG/scenes/mundo.tscn`), no dentro de `Aldea`: la regresión cuenta exactamente 36 `StaticBody3D` en la aldea. `RPG/scenes/npc_pescador.tscn` (`RPG/scripts/npc/npc_pescador.gd`) es el primer NPC, Tomás, en (27, 0, 8): `StaticBody3D` con cápsula igual a la del protagonista, sprite del protagonista con `modulate` verdoso (no hay sprites propios de NPC), zona de conversación de radio 1,3 separada de la zona de pesca, y diálogo fijo según sus partidas mediante la señal `partida_terminada(puntuacion)` del minijuego. Su memoria solo dura la sesión. `RPG/scenes/caja_dialogo.tscn` (`RPG/scripts/dialogo/caja_dialogo.gd`) es la caja de diálogo reutilizable: `mostrar(nombre, lineas)`, efecto de escritura, F/A avanza, Esc cierra, señal `cerrado`; quien la abre pausa y quita la pausa. Mantener separadas las zonas de interacción contiguas, porque comparten la tecla F. Prueba: `RPG/tests/validar_npc_pescador.gd`.
=======
=======
Las escenas envolventes conectan Aldea ↔ Bosque desde 6B, Bosque ↔ Ruinas desde 6D y Aldea sur ↔ Campos y Granjas desde 6E; montañas, minas e interiores siguen pendientes. Los cuatro límites físicos originales permanecen cerrados; los límites norte, sur y este son el cierre provisional documentado después de los marcadores futuros. No abrirlos ni permitir caminar fuera del terreno hasta que la escena de destino y el sistema de transición estén implementados conjuntamente. Las señales son geometría estática sin colisión; no bloquean los corredores. Las ruinas se conectan a través del bosque desde 6D; las minas lo harán mediante regiones futuras. No requieren salidas directas nuevas desde la aldea.

## Assets del bosque — fase 6A.0

Los dos paquetes forestales son recursos locales disponibles; el bosque independiente está construido y aprobado hasta 6A.2. El catálogo 6A.0 por sí solo no acredita esa construcción. Las rutas canónicas para nuevas escenas son los glTF de `RPG/assets/bosque/kaykit_forest/Assets/gltf/` y los GLB bajo `RPG/assets/bosque/forest_nature_updated/`; no contar OBJ, FBX y FBX Unity como modelos adicionales. Conservar originales y sus relaciones con BIN/texturas. Las medidas fuente varían mucho entre paquetes: ajustar únicamente instancias y apoyo de pivotes, nunca al protagonista ni todo el paquete con una escala global.

KayKit incluye CC0 en `License.txt`. El `README.txt` de Forest Nature Updated permite uso personal/comercial y atribución opcional, pero prohíbe revender o redistribuir archivos originales; no atribuirle CC0. Las licencias históricas Quaternius conservan sus limitaciones documentadas. Mantener la regla de exclusión de assets; no desversionar automáticamente recursos ya seguidos por Git.

La selección propuesta, aún pendiente de aprobación visual, se documenta en `RPG/docs/seleccion_assets_bosque.md` y `RPG/docs/compatibilidad_assets_bosque.md`, con 72 IDs y rutas en `RPG/tests/seleccion_assets_bosque.json`. `RPG/tests/seleccionar_assets_bosque.gd` solo inspecciona/captura un catálogo aislado bajo `RPG/logs/seleccion_assets_bosque/`; normaliza piezas para leer detalles, sin representar escala relativa de una región. No usar el catálogo ni su validación MultiMesh temporal como evidencia de bosque construido, rendimiento de escena final, colisiones o transición regional implementada.

## Transiciones regionales — fases 6B y 6D

`RPG/project.godot` registra el Autoload `GestorRegiones` (`RPG/scripts/gestor_regiones.gd`). Las escenas jugables `RPG/scenes/mundo.tscn` (Aldea, inicial), `RPG/scenes/mundo_bosque.tscn` (Bosque, envolvente del laboratorio existente) y `RPG/scenes/mundo_ruinas.tscn` (Ruinas) contienen un nodo `Region` con `RPG/scripts/region_config.gd`: identificador, rutas de jugador/cámara y diccionario de entradas Marker3D por ID. `RPG/scripts/salida_region.gd` controla Area3D configuradas con escena destino, ID de entrada y marcador de salida; solo acepta al protagonista de la escena actual. No activar automáticamente destinos previstos en metadatos.

Están activas Aldea norte ↔ Bosque sur y Bosque norte ↔ Ruinas sur. La segunda reutiliza P03 y `Bosque/Marcadores/SalidaRuinas/TransicionFutura` (20;1,004;−48); entrada de retorno `Region/EntradaRuinas` (22;1,889;−37), ID `bosque_ruinas_norte`, mirando abajo/+Z. Ruinas reutiliza `EntradaBosque` (0;0,05;34) y `RetornoBosque` (0;0;37), ID `ruinas_bosque_sur`. Detectores activos y orientación se configuran en las escenas envolventes, sin interpretar el metadato histórico `activa` de los marcadores. `acceso_ruinas_bosque.tscn` añade dos restos de columna fuera de P03, sin reconstruir bosque/laguna. La conexión original conserva su configuración: reutiliza `TransicionFutura` y los IDs `aldea_bosque_norte` / `bosque_aldea_sur`; aparición aldea Z=-32 y bosque en `AparicionSegura` Z=41. Los cierres siguen intactos detrás de las áreas. Fundido 0,35 s por sentido en CanvasLayer persistente; carga/validación mientras está negro, origen conservado hasta validar destino, bloqueo de solicitudes simultáneas y recuperación de control ante errores. Cada región crea su jugador/cámara originales; se retira la anterior antes de añadir la nueva. No hay persistencia de estado regional, inventario o guardado.

`RPG/tests/validar_transiciones.gd` prueba las áreas activas con cinco viajes ida/vuelta, fundidos, apariciones, control, órbita, errores y ausencia de duplicados/bucles. La fixture de `validar_distribucion.gd` desactiva solo el detector regional para medir los cuatro cierres físicos sin cambiar de escena; mantiene todas las comprobaciones geométricas. Evidencias en `RPG/logs/fase6b_transiciones/`. Guía y ampliación por configuración en `RPG/docs/transiciones_regionales.md`. No convertir los laboratorios aislados en regiones activas ni modificar cámara/jugador para añadir conexiones.

Desde 6D, `RPG/tests/validar_bosque_ruinas.gd` camina P01/P03 y valida cinco circuitos Aldea → Bosque → Ruinas → Bosque → Aldea, la secuencia de visitas repetidas, ambas entradas forestales, fundidos, control y órbita. Evidencias en `RPG/logs/fase6d_bosque_ruinas/`. Las pruebas locales de ruinas desactivan solo su detector para medir los cierres; la prueba regional conserva las áreas activas. El argumento de pruebas `--fase6d` concentra evidencias de regresión de bosque, ruinas y Aldea ↔ Bosque en esa carpeta. No abrir otros destinos ni añadir persistencia sin tarea específica.

## Assets de granja y animales — fase 6E.0

Contenido local auditado: `RPG/assets/granja/Farm_Harvest/` (14 GLB y sus 14 FBX alternativos) y `RPG/assets/granja/animales/` (siete animales en FBX/OBJ/Blend). **21 modelos adicionales, 49 archivos de modelo, total canónico vigente 524** frente a los 503 glTF/GLB de 6A.0. Canónicos agrícolas GLB y animales FBX con importador integrado, sin conversiones ni plugins nuevos; ambos paquetes traen CC0 1.0, sin resolver licencias históricas ajenas. Rutas, materiales, dimensiones y animaciones en `RPG/docs/auditoria_assets_granja.md` y `RPG/docs/catalogo_assets_granja.json`. Mantener originales y exclusión de assets.

`RPG/scenes/pruebas_granja.tscn` es laboratorio aislado, no región activa: escala fuente, protagonista original congelado, cámara compartida 15 sin editar y preview local de animaciones. `RPG/scripts/galeria_granja.gd` mide animales con bind/pose esquelética; la AABB cruda de malla es incorrecta especialmente para Sheep/Pug. Ajustar posteriormente solo instancias, nunca protagonista/originales. `RPG/tests/auditar_assets_granja.gd` valida 42 formatos GLB/FBX/OBJ y captura bajo `RPG/logs/auditoria_assets_granja/`; Blend se conserva sin importación directa (ya deshabilitada). `RPG/tests/inventariar_assets_granja.mjs` usa módulos integrados del Node existente, solo para auditoría documental; no es dependencia del juego.

Los siete FBX conservan 26 clips con prefijo `Armature|`: Cow/Horse/Zebra tienen Death/Idle/Jump/Run/Walk/WalkSlow; Llama/Pig/Pug/Sheep solo Idle/Jump. No asumir marcha/carrera para todos ni bucles (importados sin loop). Los 14 agrícolas son estáticos; las tres etapas de col no son especies distintas. No inferir trigo/maíz/molinos del ReadMe genérico: no están en esta edición local. Desde 6E Campos y Granjas, granero/establos y salida sur están construidos/conectados; gallinas y sistemas agrícolas/animales permanecen pendientes. La nueva región no utiliza animales y no resuelve su escala. Revisión visual del usuario antes de otra etapa.

## Campos y Granjas y conexión sur — fase 6E

`RPG/scenes/campos_granjas.tscn` es la región rural independiente, recinto jugable 100×90 y faldón paisajístico exterior cerrado al jugador. `RPG/scenes/mundo_campos_granjas.tscn` es su envolvente jugable (`Region.id_region=CamposYGranjas`), con jugador y cámara orbital originales, tamaño 15. Plano, fuentes y reproducción en `RPG/docs/plano_campos_granjas.md`. Granero, tres viviendas, seis huertos, trigo decorativo, establo/cobertizo, almacén y dos corrales vacíos no implementan agricultura, animales, inventario o NPC.

Conexión activa adicional Aldea sur ↔ Campos norte, mediante el mismo GestorRegiones y fundidos 0,35 s. `Mundo/Region/SalidaCampos` reutiliza el marcador estable `Aldea/SalidasRegionales/SalidaCamposSur/TransicionFutura` (0;0,02;35,5), destino mundo_campos_granjas.tscn, entrada `campos_aldea_norte` en `CamposYGranjas/Marcadores/EntradaAldea` (0;0,05;−39), mirando abajo/+Z. Retorno `Region/SalidaAldea` sobre `Marcadores/RetornoAldea` (0;0;−43), destino mundo.tscn y entrada `aldea_campos_sur` en `Region/EntradaCampos` (0;0,02;32), mirando arriba/−Z. El gestor añade +0,05 Y. EntradaBosque y conexiones anteriores intactas; límites originales detrás de detectores conservados, salida este pendiente. No interpretar metadatos históricos de señales como activación automática.

Autoría offline opcional `RPG/scripts/editor/construir_campos_granjas.gd`, semilla 60615: regenera únicamente campos_granjas.tscn, campos_terreno.res y campos_colision.res. Requiere render real para guardar los nueve buffers MultiMesh (cuatro de trigo y cinco de vegetación); rechaza headless como la autoría forestal. No ejecutar para jugar ni generar por fotograma. Mantener ajustes duraderos también en la herramienta. Malla y colisión del terreno comparten alturas; `terreno_campos.gdshader` recibe los ejes/anchuras de catorce caminos y patios desde autoría, sin desplazar terreno en shader. Las viviendas 4×4/4×6 conservan muros y XZ, factor Y=0,60 conjunto para cubiertas/frontones; granero/almacén grandes usan geometría propia. Colisiones por muros, segmentos de cerca, postes y obstáculos; nunca por planta ni toda una parcela. Originales agrícolas y vegetales intactos, sin animales ni dependencias nuevas.

`RPG/tests/validar_campos_granjas.gd` cubre recursos, ausencia de animales, buffers, anchuras completas, recorridos de catorce caminos ida/vuelta, muros/puertas/huecos abiertos, cuerpos físicos, cierres y órbita; con ventana captura once puntos en cuatro ángulos y plano. `RPG/tests/capturar_campos_granjas.gd` solo genera vistas/rendimiento para iteración visual y no sustituye validación física. `RPG/tests/validar_transicion_campos.gd` camina cinco circuitos Aldea ↔ Campos y cadena por cuatro regiones, con áreas activas, fundidos, entradas independientes, control/órbita, ausencia de bucles/duplicados y solicitudes simultáneas. Evidencias en `RPG/logs/fase6e_campos_granjas/`; `--fase6e` concentra allí regresiones anteriores. Fixtures físicas locales desactivan solo sus detectores durante medición de cierres; pruebas regionales mantienen todas las áreas. No retirar aserciones ni tolerancias para ocultar fallos históricos E04/E12.
## Montañas y conexión oriental — fase 6F

`RPG/scenes/montanas.tscn` contiene relieve real continuo y colisión derivada de su malla, garganta/lago/río descendente con tres caídas, tres puentes transitables y puntos de interés a cotas 2–29. Envolvente `RPG/scenes/mundo_montanas.tscn`, `Region.id_region=Montanas`, jugador y cámara originales (tamaño 15). Autoría offline opcional `RPG/scripts/editor/construir_montanas.gd`, semilla 60661: regenera solo montanas.tscn, montanas_terreno.res y montanas_colision.res; no se ejecuta al jugar. Mantener ajustes duraderos también en la herramienta. Ejes 3D de Caminos conservan las cotas finales, mezcladas en curvas para evitar costuras. Relieve de fondo hasta ±96, recinto cerrado ±65. Plano y limitaciones en `RPG/docs/plano_montanas.md`.

Desde 6F está activa Aldea este ↔ Montañas oeste, con los mismos scripts/Autoload y fundidos de 0,35 s. `Mundo/Region/SalidaMontanas` reutiliza `Aldea/SalidasRegionales/SalidaCaminoEste/TransicionFutura` (39,5;0,02;0), después del puente, destino mundo_montanas.tscn, entrada estable `camino_montanas_aldea_oeste` en (−52;2,04;48), derecha/+X. Retorno en (−62;2,02;48), entrada propia `aldea_camino_este` en `Region/EntradaMontanas` (36;0,02;0), izquierda/−X. El gestor añade +0,05 Y. Cierres físicos originales conservados detrás de áreas; contenido de Aldea/puente intacto. Esta conexión sustituye las menciones históricas de salida oriental pendiente, sin activar metadatos automáticamente.

Portal exterior conservado: `Montanas/Marcadores/ConexionMinasFutura` (45;20;−23,2), `montanas_minas_norte`, retorno previsto `minas_montanas_sur`, activa=false. Desde la fase Minas, el detector explícito de mundo_montanas.tscn reutiliza ese marcador; los metadatos históricos permanecen intactos. El fondo sólido continúa detrás del área, sin rediseñar el exterior. Sin NPC, combate, natación ni minería. Barreras de río/cubeta impiden entrar en garganta; puentes tienen barandas y colisiones propias. No retirar seguridad para facilitar pruebas. Originales reutilizados intactos, sin paquetes ni dependencias nuevos.

`RPG/tests/validar_montanas.gd` camina las rutas con Input y controlador original, asciende/desciende, cruza puentes en ambos sentidos, verifica anchura/pendientes, coincidencia malla/colisión, agua descendente, cierre minero y cámara en ocho ángulos de seis puntos. Sus rayos físicos no sustituyen revisión gráfica de copas/materiales. `RPG/tests/capturar_montanas.gd` solo captura. `RPG/tests/validar_transicion_montanas.gd` camina cinco circuitos y una cadena por las regiones anteriores. Evidencias en `RPG/logs/fase6f_montanas/`; regresiones de bosque/ruinas/campos aceptan --fase6f. Fixture local de distribución desactiva solo sus tres detectores para medir cierres; las pruebas regionales los mantienen activos. Cámara/jugador/gestor y escenas de regiones anteriores sin editar.
## Minas y conexión con Montañas — fase Minas

`RPG/scenes/minas.tscn` contiene la región subterránea; `RPG/scenes/mundo_minas.tscn` añade jugador/cámara originales, ambiente y configuración `Region.id_region=Minas`. Tres cotas reales: 0, −4 y −12, rampas continuas, extracción, depósito y ramal abandonado, caverna y estanque excavado (agua −13,1; fondo −14,5). Suelo/paredes con colisión, obstáculos individuales, orilla cerrada al jugador; sin minería interactiva ni sistemas adicionales. Plano y reproducción en `RPG/docs/plano_minas.md`.

Conexión activa Montañas ↔ Minas con el gestor original y fundidos 0,35 s. `MundoMontanas/Region/SalidaMinas` usa `Montanas/Marcadores/ConexionMinasFutura` (45;20;−23,2); detector 3,5×5×5,4 alcanza el frente del portal antes de sus rocas. Destino mundo_minas.tscn, entrada `minas_montanas_sur` en `Minas/Marcadores/EntradaMontanas` (0;0,05;0). Salida de Minas en (0;0;8), retorno a `montanas_minas_norte` en `MundoMontanas/Region/EntradaMinas` (45;20,05;−18), mirando abajo/+Z. El gestor añade 0,05 Y. Conservar separaciones de aparición y cierre exterior; no interpretar metadatos históricos como activación.

Autoría offline `RPG/scripts/editor/construir_minas.gd`, apoyada por `minas_geometria.gd`, guarda solo minas.tscn. No ejecutarla para jugar; mantener ajustes duraderos en ambas fuentes según responsabilidad. Recorte exclusivo de roca/techos en `RPG/scripts/minas_visibilidad.gd` y `roca_minas.gdshader`: abre visualmente bóvedas próximas y superficies entre jugador/cámara, sin tocar colisiones, controles o cámara compartida. Suelo y agua tienen shaders propios. Materiales compartidos locales, doce luces sin sombras; sin nuevos paquetes/dependencias ni originales modificados.

`RPG/tests/validar_minas.gd` recorre los tres niveles y dos ramales con Input/controlador original; prueba paredes, suelo, agua/barrera, pasarela, órbita y captura ocho vistas por siete posiciones y movimiento del agua. `validar_transicion_minas.gd` camina cinco circuitos Montañas ↔ Minas y cadena completa desde/hasta Aldea, con áreas activas, fundidos y controles. Evidencias en `RPG/logs/fase_minas/`. Las pruebas locales de Montañas desactivan ambos detectores para medir cierres; las regionales los mantienen activos. --fase-minas concentra las evidencias de regresión de Montañas y sus transiciones. Revisión artística/manual pendiente del usuario; las capturas no garantizan toda posición posible de oclusión.
>>>>>>> Stashed changes
>>>>>>> Stashed changes
