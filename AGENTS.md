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

La base existente permite movimiento y presentación del protagonista en una aldea modular. Los sistemas sociales, NPCs, profesiones, minijuegos, misiones y eventos no están implementados. No confundir modelos decorativos o nombres de nodos con sistemas de juego.

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

\| Cámara ortográfica inclinada con seguimiento suavizado; tamaño aprobado 15 en el mundo principal | `RPG/scripts/camara_seguimiento.gd`, `RPG/scenes/mundo.tscn`. |

\| Terreno 80×72, plaza 20×18, corredores, parcelas y reservas visuales de la etapa 2; suelo y límites sólidos | `RPG/scenes/aldea.tscn`; cápsula del personaje en `RPG/scenes/jugador.tscn`. |

\| Composición principal, iluminación y ambiente | `RPG/scenes/mundo.tscn`; `RPG/scripts/mundo.gd` solo imprime mensajes de bienvenida. |

\| Validación del mundo actual: movimiento, cámara, suelo, límites, conectividad, reservas y solapes | `RPG/tests/validar_aldea.gd` es la entrada de `RPG/tests/validar_distribucion.gd`. La composición anterior conserva sus comprobaciones en `RPG/tests/validar_aldea_anterior.gd`. Su existencia no equivale a una ejecución aprobada en cada sesión. |

`RPG/scenes/casa_modular.tscn` se reutiliza en `RPG/scenes/pruebas_assets.tscn`; la aldea actual no contiene edificios definitivos. La escena de pruebas es independiente y no sustituye la escena principal; reutiliza jugador, seguimiento e iluminación, y añade colisiones sin editar los glTF. Su prueba reproducible es `RPG/tests/validar_pruebas_assets.gd` (headless o con capturas en `user://` al ejecutarse con ventana). `RPG/scenes/pruebas_proporciones.tscn` compara tres cuerpos modulares mediante un controlador visual exclusivo y `RPG/tests/validar_proporciones.gd`. Consultar el estado para resultados y limitaciones.

La composición anterior de cuatro edificios se conserva en `RPG/scenes/respaldos/aldea_etapa1.tscn`; `RPG/scenes/respaldos/mundo_etapa1.tscn` permite abrirla y ejecutarla con F6 sin cambiar la escena principal. No sobrescribir esos respaldos al continuar. La validación anterior conserva todas sus comprobaciones, dirigida a ese mundo respaldado.

Proporciones aprobadas para futuros edificios definitivos: cuerpos 4×4 y 4×6 con cubierta a escala Y=0.60; cuerpos 6×8 con Y=0.55. Mantener X/Z a 1, muros y puertas sin escalar, y aplicar el mismo factor vertical a tejado y frontones mediante un padre común. La muestra apoya raíces en Y=0.003 y sitúa ese padre a Y=3 local; conservar los encajes y verificar la geometría de cada variante. No escalar al protagonista para adaptar arquitectura.

En la distribución provisional, parcelas y jardines son reservas, no obstáculos ni edificios: sus nodos `Marca` contienen planos sin colisión. Los metadatos de centros, reservas, accesos, anchuras y futuras cubiertas deben mantenerse coherentes con las marcas visibles; `validar_distribucion.gd` contrasta su geometría real. Los accesos solo pueden atravesar la reserva de su propia parcela/zona. Las reservas de río/puente/rueda admiten cruces previstos; el suelo sigue continuo hasta autorizar el cauce.

El tamaño ortográfico aprobado para la cámara principal es **15**, configurado en `RPG/scenes/mundo.tscn` (`CamaraPrincipal.size`). `camara_seguimiento.gd` no fija ni sobrescribe el tamaño: mantiene orientación y seguimiento. Conservar el selector local de `RPG/scenes/pruebas_assets.tscn` (23/19/17/15, inicio en 23) para comparar; ese valor inicial de laboratorio y las cámaras de respaldos/muestras no sustituyen la decisión del mundo principal.

## Recursos y assets

Paquetes identificados por el proyecto y contenido local verificado:

\| Paquete | Carpeta | Modelos glTF |

\|---|---|---:|

\| Quaternius Medieval Village MegaKit | `RPG/assets/aldea/` | 176 |

\| Quaternius Stylized Nature MegaKit | `RPG/assets/naturaleza/` | 68 |

\| Quaternius Fantasy Props MegaKit | `RPG/assets/objetos_medievales/` | 94 |

\| Sprites del protagonista | `RPG/assets/personajes/protagonista/` | 0; dos hojas PNG: `Character_Idle.png` y `Character_Walk.png`. |

Total local verificado: ****338 modelos 3D****. El inventario detallado y sus límites están en `RPG/docs/inventario_assets.md`; no confundir disponibilidad con integración en escenas o gameplay.

****Toda `RPG/assets/` está excluida de Git intencionalmente.**** No quitar la exclusión, no forzar su incorporación y no intentar subir modelos a GitHub. Clonar el repositorio no basta para obtener los recursos: deben estar disponibles localmente con sus rutas originales. No modificar, eliminar, mover ni renombrar assets originales sin autorización. Conservar procedencia y condiciones de licencia cuando se disponga de ellas; no asumir licencias por el nombre del paquete.

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

## Validación y cierre obligatorio

1. Validar los cambios según su alcance. Para lógica o escenas, considerar la prueba existente, desde la raíz del repositorio, con un ejecutable de Godot 4.7.2 disponible en el entorno:

   ```text

   godot --headless --path RPG --script res\://tests/validar_aldea.gd

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
