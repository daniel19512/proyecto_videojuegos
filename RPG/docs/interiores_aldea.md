# Interiores de Aldea — E01–E11

Implementación local del 16 de noviembre de 2026. El registro inicial de E01 se conserva a continuación; la ampliación E02–E11 está documentada al final. **E01–E11 están conectados; E12 permanece pendiente.** Sin NPCs nuevos, tiendas, inventario, fabricación, persistencia ni misiones.

## Arquitectura y archivos

- `RPG/scenes/interiores/taberna_e01.tscn`: escena jugable independiente, arquitectura, mobiliario, colisiones, ambiente, jugador original, cámara y configuración `Region`.
- `RPG/scenes/interiores/puerta_interior.tscn` y `RPG/scripts/interiores/puerta_interior.gd`: interacción reutilizable con destino, ID de entrada y texto exportados. Área de detección sin cuerpo sólido; solo reconoce al jugador configurado en la región actual.
- `RPG/scripts/interiores/visibilidad_interior.gd`: corte visual de paredes según la dirección de cámara. Los cuerpos sólidos están separados y no se desactivan.
- `RPG/scripts/editor/construir_taberna_interior.gd`: autoría offline opcional; guarda únicamente taberna_e01.tscn. No se ejecuta al jugar. Mantener aquí cualquier ajuste que deba sobrevivir a una regeneración.
- `RPG/scenes/mundo.tscn`: añade puerta exterior y marcador de retorno, sin editar aldea.tscn ni taberna.tscn.
- `RPG/tests/validar_interior_taberna.gd`: integración, recorridos, barridos físicos, órbita, cinco circuitos y capturas con ventana.

## Entrada, salida y transiciones

E01 conserva raíz (−8;0,003;−20), cuerpo 6×8 sin escalar y fachada +Z. La malla real de puerta ocupa X=[−8,572;−7,454], Z=[−16,023;−15,902], aproximadamente; el pivote de su instancia no es su centro. El centro X≈−8,013 confirma la alineación de la interacción en X=−8. Los cuatro cierres exteriores permanecen intactos.

`Mundo/PuertaTabernaE01`, en (−8;0,003;−15), muestra **[F] Entrar a la taberna** al solaparse con la cápsula. Caja de detección 1,8×2,4×1,5, centrada una unidad por encima de su raíz: zona próxima al umbral, sin alcance global. F o el botón A existente solicitan al Autoload `GestorRegiones` la escena interior y el ID `taberna_e01_entrada`. Se consumen eventos aceptados, se ignora repetición de teclado y se oculta el aviso durante la transición. La pesca y el diálogo quedan lejos de esta zona.

Se reutilizan sin editar gestor, Autoload y configuración regional: bloqueo de solicitudes simultáneas, desactivación temporal de física/cámara, fundidos de 0,35 s por sentido, carga y validación en negro, colocación por Marker3D y recuperación ante errores. No hay otro cambiador de escenas.

La región `TabernaE01` aparece en (0;0,05;3,65), mirando arriba; el gestor añade 0,05 Y y el personaje se apoya en el suelo. La puerta interior está al sur, Z=5; el detector está en (0;0;4,05). Un umbral, felpudo y rótulo SALIDA identifican el acceso incluso cuando la pared sur está recortada. Cerca aparece **[F] Salir de la taberna**. Destino mundo.tscn, ID `aldea_taberna_e01`, marcador (−8;0,02;−14,75), mirando abajo. Regresa frente a E01, fuera de su muro y sin activar otras conexiones. Una nueva pulsación es obligatoria: permanecer en el detector no produce reentrada automática.

El gestor conserva su modelo anterior: crea jugador/cámara originales en cada escena y vuelve a cargar Aldea al retornar. No se añade persistencia regional; los estados locales de nodos de una escena retirada, incluida la memoria de Tomás, se reinician igual que al viajar entre regiones. No existen inventario, salud ni progreso persistente del protagonista que transferir. No se promete conservación de un ángulo orbital previo: cada llegada usa el ángulo inicial del gestor y el encuadre configurado en destino.

## Distribución y presentación

Sala 8×10, moderadamente más holgada que el cuerpo exterior 6×8 para permitir circulación de la cápsula original de diámetro 0,64. No es una reproducción métrica del edificio. Suelo de tablas, zócalos de piedra, paredes de madera de 2,8, postes, vigas perimetrales, cuatro ventanas con parteluces y puerta enmarcada. Sin techo que obstruya la vista.

Tres mesas para clientes: mesa larga occidental y dos mesas pequeñas al sur, seis sillas, comidas, tazas y velas. Barra de tres módulos al norte con dos taburetes, vajilla y servicio; dos estanterías traseras, tres barriles y pasillo occidental hacia almacén/servicio. La abertura occidental se conserva libre: no reponer el tercer taburete ni desplazar la mesa larga al norte sin revalidar.

Cámara compartida `camara_orbital.gd`, ortográfica **12**, desplazamiento (0;17;17), seguimiento original y Q/E o stick derecho. Vista más elevada, aproximadamente 44°, sin modificar el exterior (15). Cada pared tiene una normal; se ocultan sus mallas y decoración cuando apuntan hacia la cámara (`normal.dot(camara.global_basis.z) >= 0,15`). No se cambia su colisión. El interior no incorpora zoom ni inclinación controlable.

Ambiente propio cálido, sin luz solar de Aldea. Seis OmniLight3D sin sombras: tres velas de mesa, dos apliques y una luz de relleno. No hay luces por cada taza, simulación de fuego ni generación de geometría por fotograma. El corte por lado no garantiza visibilidad perfecta detrás de cada mueble alto desde toda posición.

## Assets y colisiones

Originales referenciados desde `RPG/assets/interiores_medievales/Taberna/medv-cafe/fbx/<nombre>.fbx`, conservando sus materiales importados. **23 modelos distintos**: counter_L/M/R; table01/03; chair01; stool; keg01/02; shelf01/02; basket-of-pastries; bowl-of-stew; platter-meal01/02; mug01/02; pitcher; jug01; table-candle; wall-candle; tapestry01/02. Se omiten las esquinas de barra, table02 y food-display para no saturar esta distribución. No se usan cafeteras ni gráficos modernos. Arquitectura complementaria propia con mallas de Godot.

El autor sitúa instancias usando la AABB transformada de sus mallas: centra X/Z y apoya la base sin alterar la escala ni los originales. El metadato `assets_utilizados` conserva las rutas exactas. Las instancias importadas mantienen su jerarquía; no se convierten sus descendientes en objetos nuevos.

Colisiones BoxShape3D simples, serializadas: suelo continuo, paredes, postes, tres mesas, seis sillas, barra por módulo, dos taburetes, barriles y estanterías. Muebles con caja envolvente por pieza, sin precisión por pata; no hay caja ocupando toda la habitación. Platos, alimentos, jarras, tapices y velas no tienen colisiones individuales. Paredes ocultas siguen impidiendo salir del recinto.

**Licencia de medv-cafe pendiente de verificación.** La selección está autorizada por el usuario para integración académica local, no comercial; no acredita autoría, CC0 ni permiso de redistribución. Los assets permanecen locales y excluidos de nuevas incorporaciones a Git. No se modifican fuentes ni se adjuntan modelos a esta documentación.

## Validación y evidencias

Godot **4.7.2.stable.official.ed1daf0bf**. Desde la raíz del repositorio, creando primero RPG/logs/ y usando un nombre de registro nuevo:

```text
godot --headless --path RPG --fixed-fps 60 --log-file logs/e01_integracion_nueva.log --script res://tests/validar_interior_taberna.gd
```

Omitir `--headless` para capturas; la prueba crea carpeta nueva `RPG/logs/taberna_e01_<fecha>_<ticks>/`. Los fotogramas fijos aceleran el tiempo simulado; no constituyen una medida de rendimiento. La fixture coloca al jugador delante del acceso exterior, camina los tramos finales con Input y no afirma recorrer toda Aldea desde el origen. Dentro recorre entrada, sala, almacén, detrás de barra y regreso sin teletransportes. Comprueba F lejos/cerca, avisos, bloqueo simultáneo, diez cambios, apariciones, apoyo, cápsula contra muebles/paredes, jugador original, velocidad, cámara y reposo sin reentrada.

Resultados ejecutados y revisados:

- Headless final de distribución: **0 fallos / 225 comprobaciones**, `RPG/logs/e01_07_recorrido.log`.
- Forward+/D3D12, RTX 4060 Laptop, 1440×900: **0 / 225**, `RPG/logs/e01_09_forward_final.log`. Ocho vistas orbitales y cinco exteriores en `RPG/logs/taberna_e01_2026-11-16T19-49-54_2016/`; se inspeccionaron materiales, mesa/barra, ventanas, puerta y sprite en render real. Capturas adicionales y cierre de validación se registran en estado.
- Cierre gráfico con entrada/servicio/salida adicionales: **0 / 225**, `RPG/logs/e01_13_forward_cierre.log`; galería de 16 PNG en `RPG/logs/taberna_e01_2026-11-16T19-53-46_2026/galeria.html`. Ocho ángulos y posiciones funcionales revisados técnicamente. Junto a la barra, el mueble puede ocultar parcialmente las piernas; el sprite sigue reconocible. El encuadre sigue al jugador y puede cortar el extremo opuesto de la sala.
- Pesca: **0 fallos**, `RPG/logs/e01_08_pesca.log`. Diálogo/pescador: **0 fallos**, `RPG/logs/e01_08_npc.log`.
- Regresión regional: **0 / 281**, cinco circuitos Aldea ↔ Montañas y cadena Bosque/Ruinas/Campos, 16 cambios y 16 negros; `RPG/logs/e01_10_regiones_final.log`. Dos pruebas antiguas contaban cualquier Area3D como salida regional; ahora cuentan scripts salida_region y siguen comprobando ausencia de solapamientos. La integración E01 se verifica por separado.

No se presenta la primera ejecución fallida como aprobada: el controlador de prueba necesitó frenado predictivo para la velocidad original 10; se corrigió solo la fixture. También hubo un error de inferencia de tipo de esa variable y expectativas antiguas de áreas. Persisten el error del almacén de certificados del entorno y un aviso Jolt de capacidad de trabajos en ejecución simultánea. No son errores nuevos de carga del interior.

Pendientes: aprobación artística y recorrido manual del usuario, mando físico, benchmark de rendimiento y licencia de medv-cafe. Las capturas son revisión técnica de posiciones muestreadas. No se declara toda la Aldea libre de fallos históricos; consultar el estado y su regresión actual.

La regresión Aldea `RPG/logs/e01_12_aldea.log` conserva exactamente los dos fallos históricos de retorno E04 y conectividad E12, con 13.695 muestras y 36 corredores. Editor/importación `RPG/logs/e01_14_editor.log`: sin errores nuevos de sintaxis/carga; persisten certificados, avisos de capitalización de texturas de otros paquetes y restricción al guardar ajustes globales fuera del proyecto. No se modificaron fuentes para silenciar esos avisos.

## Añadir E02–E12

1. Crear una escena independiente con arquitectura/mobiliario propios, jugador y cámara compartidos, ambiente y nodo Region con ID único y diccionario de Marker3D de entrada.
2. Instanciar puerta_interior frente a la puerta real exterior y configurar escena/ID/texto. Añadir al diccionario Region de mundo.tscn un marcador de retorno seguro y orientación.
3. Instanciar la misma puerta dentro, configurada hacia mundo.tscn y ese ID de retorno. Fijar tamaño de cámara y normales de paredes si se usa el corte visual.
4. Serializar colisiones simples por obstáculo, mantener pasillos y verificar rango, recorrido, ambos sentidos, repetición, visibilidad orbital y regresiones. No es necesario ampliar GestorRegiones.

Al cerrar la primera entrega E01, la estructura estaba preparada para reutilización y los otros once interiores seguían pendientes. La ampliación siguiente incorpora E02–E11; no resuelve los mecanismos de molienda que faltan en E12.

## Ampliación E02–E11 — 16 de noviembre de 2026

Diez escenas independientes bajo `RPG/scenes/interiores/`. Comparten **la misma puerta_interior, region_config, GestorRegiones, jugador y cámara orbital que E01**, sin modificar esos componentes. Aldea se recarga al salir, decisión aceptada para esta fase; no hay base de datos, serialización ni memoria persistente. No se editaron aldea.tscn, los exteriores E01–E12 ni la escena interior E01.

### Escenas, distribución y recursos

Las cantidades cuentan **rutas distintas de modelos importados por interior**, no instancias, texturas ni geometría propia; cuerpo y tapa de cofre cuentan por separado. Rutas completas disponibles en el metadato `assets_utilizados` de cada escena y en la herramienta de autoría. Los muebles se apoyan y centran mediante la AABB transformada de sus mallas; ajustes únicamente de instancia, sin cambiar fuentes.

| ID | Escena en RPG/scenes/interiores/ | Sala / cámara | Modelos distintos | Identidad y distribución |
|---|---|---|---:|---|
| E02 | panaderia_e02.tscn | 6×8 / 10 | 9 | Baldosas, horno de ladrillo al noroeste, artesa/masa/rodillo al noreste, atención al oeste y despensa de panes al este. Sacos, cesta, leña y pala de horno propia. |
| E03 | herreria_e03.tscn | 8×6 / 10 | 14 | Piedra oscura, forja real con fuelle y luz cálida, yunque sobre tocón, banco con lingotes/martillo/tenazas, herramientas, afiladora, carbón, cubo y barril. Sin espacio doméstico. |
| E04 | carpinteria_e04.tscn | 8×6 / 10 | 11 | Tablas, banco con prensa y corte al oeste, ensamblaje de silla al este, troncos, tablones inclinados, rueda en reparación, caja, barril y repisa. Sierra propia complementaria. |
| E05 | herbolario_e05.tscn | 6×6 / 8 | 10 | Piedra y revoco verde apagado; venta al oeste, preparación y mortero al este, ingredientes en baldas traseras, hierbas colgadas, macetas, libro, balanza y cesta. |
| E06 | vivienda_e06.tscn | 5×7 / 9 | 12 | Alcoba modesta con cabecero bajo al noroeste, cama rústica Twin1, cofre compacto, mesa para dos, vasija en repisa y saco. Mobiliario contenido. |
| E07 | vivienda_e07.tscn | 7×7 / 9 | 16 | Alcoba con biombo, cama con cojín/cabecero tapizado, salón con alfombra, armario panelado propio, librero, dos cofres, vajilla, cortinas, cuadro y tapiz azul propio. |
| E08 | vivienda_e08.tscn | 6×6 / 8 | 11 | Hogar con caldero al noroeste, cama rústica Twin2 al este, banco con herramientas, leña/materiales prácticos, caja, saco, barril y vasija. |
| E09 | vivienda_e09.tscn | 5×5 / 7 | 12 | Vivienda compacta, cama occidental, mesa para dos y alfombra pequeña, cofre, repisa y rincón de cocina bajo en lugar del hogar grande de E08. |
| E10 | vivienda_e10.tscn | 6,5×7 / 9 | 15 | Dormitorio rural, mesa con bancos familiares, despensa delimitada por zócalo bajo, grano/provisiones, cofre, pala agrícola, cesta de fruta y barril; sigue siendo vivienda. |
| E11 | vivienda_e11.tscn | 6×6 / 8 | 16 | Dormitorio oriental con textiles y cortina, mesa occidental, alfombra, cofre, macetas, flores en vasijas sobre baldas y cuadro. Ambiente doméstico claro, sin mostrador ni taller herbal. |

Fuentes: Avramania Interiors_Furniture (camas, cofres/tapas, mesas, asientos, repisas, textiles, plantas y luminarias), Food_Market (panes, grano, balanza, cerveza y hierbas), Props_Tools_Fencing (cestas/herramientas/rueda), LowPolyBlacksmithPack (forja/fuelle, metal, herramientas y troncos). Originales anteriores Props para camas Twin, yunque, barriles, caja, libros, botellas y afiladora; Nature para flores; Farm_Harvest para cesta de fruta. Revoco y ladrillo reutilizan texturas locales de Village mediante recursos propios. **No se amplía el uso de medv-cafe fuera de E01.** Licencias locales y límites en integracion_assets_interiores.md; las fuentes históricas conservan sus pendientes.

### Autoría y configuración

Nuevos archivos compartidos:

- `RPG/scripts/editor/construir_interiores_aldea.gd`: autoría offline de los diez interiores; guarda únicamente esas diez escenas. Hereda de la herramienta E01 para reutilizar las primitivas de autoría (material/caja/colisión/AABB/luz), pero sobrescribe el constructor y diseña cada interior en su propia función. No invoca el constructor E01 ni escribe su escena. No hay generación durante el juego.
- `RPG/scripts/interiores/edificios_interiores.json`: parámetros de autoría/prueba, ID, nombre, escena, dimensiones, paleta y acceso exterior inspeccionado. No implementa un segundo sistema de transición. Si se cambia un acceso, mantener también coherentes las instancias/marcadores serializados en mundo.tscn.
- `RPG/tests/validar_interiores_aldea.gd`: prueba común de los diez interiores; reutiliza utilidades de Input, frenado y espera de la prueba E01 sin modificarla.

`RPG/scenes/mundo.tscn` añade diez instancias de puerta_interior y diez Marker3D al diccionario Region. No se reemplazan las entradas anteriores. IDs de interior `interior_e02`…`interior_e11`; retorno `aldea_e02`…`aldea_e11`; regiones `InteriorE02`…`InteriorE11`. Interior siempre mira arriba al entrar, con puerta al sur; el retorno exterior mira hacia fuera de la fachada correspondiente. Fundidos, validación de destino, bloqueo simultáneo y restauración de control siguen en el gestor original.

### Accesos exteriores medidos

Coordenadas X/Z de las interacciones y retornos. Y de interacción=0,003; Y de retorno=0,02, más 0,05 que añade el gestor. Detector original 1,8×2,4×1,5, girado 90° para fachadas este/oeste. No se activan dos puertas desde el mismo punto.

| ID | Fachada | Interacción X/Z | Retorno X/Z | Evidencia física |
|---|---|---|---|---|
| E02 | sur | 8,487 / −16,05 | 8,487 / −15,80 | Malla puerta X=[7,928;9,046], Z≈−16,963. |
| E03 | este | −19,10 / −6 | −18,85 / −6 | Abertura existente del cobertizo entre postes del frente X=−20; no tiene hoja. |
| E04 | este | −19,10 / 7 | −18,85 / 7 | Abertura existente del taller X=−20, pasillo de trabajo Z=7; no tiene hoja. |
| E05 | oeste | 17,95 / 8 | 17,70 / 8 | Puerta en X=[18,82;18,94], centrada Z=8. |
| E06 | este | −21 / −22,987 | −20,75 / −22,987 | Puerta X≈−21,963; centro Z≈−22,987, pivote original distinto del centro. |
| E07 | oeste | 17,95 / −24,35 | 17,70 / −24,35 | Puerta X≈18,975, centro Z=−24,35. |
| E08 | norte | −24 / 20 | −24 / 19,75 | Puerta centrada X=−24, Z≈20,965. |
| E09 | norte | −8,55 / 21 | −8,55 / 20,75 | Puerta desplazada X=−8,55, Z≈21,965. |
| E10 | norte | 8 / 22 | 8 / 21,75 | Puerta centrada X=8, Z≈22,925. |
| E11 | norte | 18 / 21 | 18 / 20,75 | Puerta centrada X=18, Z≈21,925. |

Cada salida muestra `[F] Salir`; los accesos muestran nombre propio, con retorno independiente. El detector no abre nada por sí solo. El texto vuelve a estar disponible tras retornar, pero se necesita otra pulsación. Las colisiones exteriores permanecen intactas.

### Cámara, física y navegación

Todos conservan el script orbital de E01, desplazamiento 0/17/17 y Q/E/stick; solo cambia tamaño ortográfico según la tabla. El exterior permanece en 15. Muros recortados con visibilidad_interior.gd, techo omitido; arquitectura y adornos del lado próximo se ocultan juntos sin retirar cuerpos físicos. El seguimiento puede recortar el extremo opuesto de la habitación; no es una cámara fija cenital. Muebles altos pueden ocultar parcialmente al sprite según posición y ángulo; no se promete visibilidad de cada píxel.

Colisiones simples por pared, cama, mesa, asiento, banco, cofre, mueble grande, forja/horno, herramientas voluminosas y provisiones grandes. No por platos, frascos, flores o herramientas pequeñas. Suelo continuo sólido con acabado de tablas/baldosas; umbral bajo transitable, sin escaleras falsas. El biombo de E07 y la despensa de E10 dejan libre el corredor central. El recorrido de prueba visita también un puesto lateral o alcoba propio de cada edificio y vuelve caminando a la salida.

Ambiente independiente cálido, con dos luces de relleno/farol sin sombras por sala; horno/forja/hogar añaden una tercera luz. Tres como máximo, sin partículas ni simulación. La apariencia verdosa de E05 procede principalmente del revoco y vegetación; E11 es más clara y doméstica.

### Pruebas, incidencias y límites

Godot 4.7.2.stable.official.ed1daf0bf. Registro y capturas nuevos exclusivamente bajo `RPG/logs/interiores_e02_e11/`. Ejecución reproducible desde raíz del repositorio, con un nombre de registro nuevo:

```text
godot --headless --path RPG --fixed-fps 60 --log-file logs/interiores_e02_e11/validacion_nueva.log --script res://tests/validar_interiores_aldea.gd
```

Omitir --headless y añadir --resolution 1440x900 para capturas Forward+/D3D12. Cada ejecución crea subcarpeta propia con resultados JSON; tres ciclos por edificio, 30 circuitos/60 transiciones. La fixture coloca al jugador fuera del rango delante de cada fachada; el tramo final y los interiores se recorren con Input/controlador original. No afirma recorrer toda Aldea desde el punto inicial ni medir FPS con el reloj de prueba.

Headless final `09_headless_final.log`: **0 fallos / 2.543 comprobaciones**. Incluye F fuera/dentro de rango, aviso único, bloqueo simultáneo, destino/retorno propios, movimiento real y apoyo, protagonista y cámara únicos, materiales de todas las superficies, contención geométrica de modelos, detección física de la cápsula en cada cuerpo sólido, pared bloqueante, Q/E, reposo y ausencia de reentrada. E01 vuelve a pasar **0/225** (`11_regresion_e01.log`); Aldea↔Bosque y recuperación de errores **0/267**, diez viajes (`12_regresion_bosque.log`); pesca y diálogo **0 fallos** (`13_pesca.log`, `14_dialogo.log`). Resultado gráfico final y galería se consignan al cierre, sin presentar revisiones iniciales como finales.

Fallos históricos, reproducidos antes de incorporar puertas:

- **E04:** no es una pared que cierre el acceso nuevo. La fixture antigua pulsa izquierda 45 fotogramas y frena solo 12: aún queda velocidad −5,2. Los 60 fotogramas hacia la derecha incluyen invertir esa velocidad y no bastan para superar X=−18,5. La ejecución base termina X≈−19,097. El ensayo aislado prolongado alcanza X≈−15,577 a 90 fotogramas, sin contactos laterales. Evidencia `02_base_historicos.log` y `07_causa_e04.log`. No se cambian ni jugador, ni exterior, ni aserción histórica; el nuevo acceso y sus tres retornos se prueban por separado.
- **E12:** el recorrido de la fixture atraviesa una colisión existente de `Aldea/EspaciosConstruidos/Mirador/Colisiones` en torno a (35;6,3), antes de recorrer toda la margen este. Se identifica cuerpo/forma en `02_base_historicos.log`. No se modifica E12 ni el mirador ni se omite su fallo. El circuito no implica un defecto nuevo de interiores.

Correcciones de iteración: una ruta de provisión agrícola supuesta se sustituyó por la cesta de fruta realmente existente; se corrigieron posiciones de retorno durante autoría, parpadeo en vigas coplanares, apoyo de vasijas/baldas, maceta sin apoyo y cofre con superficies oscuras superpuestas. Originales intactos. Persisten certificados, avisos Jolt con concurrencia y fallo de escritura de caché de shaders del entorno; no se presentan los logs como libres de avisos. No hay errores nuevos de sintaxis/carga acreditados por las ejecuciones finales; el editor y el resultado gráfico se registran al cierre.

**E12 quedó fuera del alcance de esa fase y se incorporó después, como se describe abajo.** Pendientes aprobación artística y recorrido manual del usuario, mando físico y benchmark general. Persistencia y memoria de NPCs se aplazan expresamente; no se implementaron soluciones temporales de guardado. Sin commits ni pushes.

### Minijuegos de oficio — 22 de noviembre de 2026

E01, E02 y E03 incluyen un `PuntoMinijuego` (cerveza, pan y forja) creado también por las herramientas de autoría. Es un `Area3D` sin cuerpo sólido, sobre suelo libre, cuya zona no se solapa con `Salida`. Detalle en `AGENTS.md` y prueba en `RPG/tests/validar_minijuegos_oficio.gd`.

### Cierre de validación E02–E11

- **Headless definitivo: 0 fallos / 2.569 comprobaciones**, `RPG/logs/interiores_e02_e11/18_animaciones_cierre.log`, con confirmación de animación walk reproducida durante recorrido y reposo al detenerse. Tres ciclos por cada edificio, 60 viajes. Repetición anterior tras ajuste de visibilidad: 0/2.539 (`16_headless_cierre.log`).
- **Gráfico completo: 0/2.543**, `10_forward_final.log`. Después se ajustó únicamente la pertenencia de recipientes a las paredes/repisa que se ocultan: E06/E08/E09/E10 se repitieron **0/951**, doce circuitos/24 viajes (`17_forward_repisas.log`). No se modificó diseño, cámara ni colisión para esa corrección. El cambio de contador se debe a la ubicación de los adornos en el árbol y al nuevo control de animación, no a fallos omitidos.
- **Galería final de 100 PNG con enlaces verificados:** `RPG/logs/interiores_e02_e11/galeria_final.html`. Selecciona las vistas finales de cada edificio: seis de la ejecución `ejecucion_2026-11-16T20-15-36_2290/` y cuatro de `ejecucion_2026-11-16T20-21-24_2229/`. Cada edificio aporta ocho ángulos, entrada y exterior. Se inspeccionaron técnicamente vistas opuestas de los diez, materiales, cofres, apoyos de vasijas, mobiliario y accesos representativos. No se afirma una revisión manual exhaustiva de cada posición ni aprobación artística. Muebles altos pueden ocultar parte del sprite en una vista; en fachadas norte el tejado exterior original también puede ocultarlo desde la cámara sur, sin afectar F.
- **Editor/importación:** `19_editor.log`, sin errores nuevos de sintaxis ni carga; UID generados. Persisten aviso de certificados, fallo de caché de shaders y restricción de ajustes globales fuera del proyecto. Son incidencias registradas del entorno; no se declara ejecución libre de avisos.
- Archivos creados en esta ampliación: diez escenas, construir_interiores_aldea.gd y UID, edificios_interiores.json, validar_interiores_aldea.gd y UID. Archivos existentes modificados aquí: mundo.tscn, esta guía, estado_proyecto.md, inventario_assets.md y AGENTS.md. Las modificaciones previas de .gitignore, fixtures regionales y E01 se preservaron y no se atribuyen a esta ampliación. Sin cambios en exteriores, E01, E12, jugador, gestor o cámara compartida. `git diff --check` sin errores de espacios; Git avisa de normalización de finales de línea.

## Interior del molino E12

Sala de 6×8 con puerta oeste, piso de tablas, zócalos, vigas, ventanas y paredes de recorte visual independientes de los cuerpos físicos. La fachada exterior se toma de `Aldea/Edificios/E12/Entrada/Puerta`: raíz (21;0,003;−10) más posición local (−3,12;1,12;0). El detector `PuertaE12` usa X/Z (17,88;−10). F o el botón de interacción inicia el fundido y coloca al jugador dentro en (−1,85;0,07;0), más el margen vertical del gestor. «[F] Salir del molino» devuelve al marcador (17,4;0,02;−10), mirando hacia la puerta. La puerta exterior conserva su colisión y la reentrada exige otra pulsación.

La muela inferior es fija. El árbol entra por el este a Y=2,5, como la rueda exterior, y mueve dos engranajes a 90°. Un husillo transmite el giro a la muela superior. Se comparte la velocidad nominal de −9°/s de la rueda exterior y la corona gira en sentido inverso a 12°/s, por la relación 16:12. La tolva de tablas abierta y su conducto alimentan visualmente las muelas. Una caja estática protege la bancada. El camino rodea la transmisión y da acceso a almacenaje, banco y salida.

`RPG/scripts/editor/construir_molino_interior.gd` regenera solo `RPG/scenes/interiores/molino_e12.tscn`. Reutiliza barril y caja Quaternius, farol y banco de Interiors Furniture, saco de grano y balanza de Food Market y canasta de Props Tools Fencing. Las muelas, ejes, dientes, tolva y sacos de harina son geometría propia. Las lámparas cálidas permanecen activas y la ventana oeste recibe aporte diurno del ciclo visual.

`RPG/tests/validar_interiores_aldea.gd` cubre E02–E12 con tres circuitos por edificio y admite `-- --edificios=E12`. E01 conserva su prueba propia. `RPG/tests/validar_ciclo_dia_noche.gd` comprueba el giro, el resguardo y el retorno de noche, y genera vistas con ventana. El retorno exterior E04 ahora espera el frenado y la posición objetivo a 10 u/s. En E12 se verificó que el antiguo itinerario de la margen este intersectaba la barandilla del mirador. El validador comprueba un desvío por X=34,5 mediante consultas de cápsula, un tramo a pie y el cruce autorizado por el puente.
