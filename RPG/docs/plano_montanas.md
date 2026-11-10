# Montañas — fase 6F

Región independiente `RPG/scenes/montanas.tscn`, envolvente jugable `RPG/scenes/mundo_montanas.tscn`. Abrir esta última con F6, o llegar desde la salida oriental de Aldea tras cruzar su puente. Escena inicial permanente conservada. Construcción de 5 de noviembre de 2026; aprobación artística del usuario pendiente.

## Topografía y autoría

Recinto jugable 130×130, X/Z entre −65 y 65, con faldón paisajístico hasta ±96 para cubrir el encuadre orbital en los bordes. Malla continua de 192×192 celdas de una unidad, 73.728 triángulos; normales por cara, colores de vértice y material mate propio. Recurso `montanas_terreno.res`; colisión cóncava estática `montanas_colision.res` derivada de exactamente sus mismos triángulos. Sin plano horizontal oculto, saltos ni generación al jugar.

Autoría opcional `RPG/scripts/editor/construir_montanas.gd`, semilla 60661: escribe únicamente esa escena y esos dos recursos. Las modificaciones duraderas deben aplicarse también a la herramienta. Funciones separadas para relieve, caminos, agua, puentes, puntos de interés y paisaje. No se ejecuta para jugar. Sin dependencias adicionales, descargas ni modificaciones de originales.

El relieve combina gradiente norte-sur, ondulaciones, crestas irregulares, mesetas mezcladas suavemente, senderos y excavación de garganta/cubeta alpina. Rango de toda la malla, incluido paisaje inaccesible: **Y=−9,597…81,530**. Recorridos principales comprobados: **Y≈2…29**. Los extremos altos son fondo paisajístico; no se presentan como cimas visitables. Los cauces están por debajo del agua; el mínimo negativo exterior no es una caída fuera de la malla.

Los ejes publicados en `Montanas/Caminos` registran las alturas finales, después de mezclar mesetas. Ancho visual nominal 6,4; franja central comprobada de 2,4 más el radio de cápsula. Los tramos vecinos mezclan sus cotas por distancia para evitar costuras en curvas. No hay escaleras obligatorias: las subidas son superficies continuas adaptadas a la cápsula original de radio 0,32, `floor_snap_length=0.2` y pendiente máxima original de 45°. Se conserva velocidad 10, aceleración y frenado originales.

## Plano de zonas

Coordenadas X,Y,Z; norte=−Z. Las cotas de ejes intermedios pueden diferir ligeramente del perfil conceptual al mezclarse con mesetas.

| Zona | Centro/aproximación | Composición y acceso |
|---|---|---|
| A, llegada | (−52;2,04;48) | Valle bajo, señal, pinos y camino; salida de retorno en (−62;2,02;48), antes del cierre oeste |
| B, valle | (16;6;30) | Puente inferior, río excavado y ascenso hacia la terraza del campamento |
| C, campamento | (28;12;10) | Tres tiendas propias, fogata estática, troncos, barriles/cajas/saco, herramientas, farol y leña; acceso por (28;≈12;22) |
| D, mirador | (−32;23;−18) | Meseta segura y torre de señal en (−37;23;−18); torre cerrada, sin escalera ficticia; contemplación desde la meseta |
| E, ruinas | (30;29;−42) | Enlosado al norte, arco angular, columnas rotas, muro incompleto y helecho; acceso desde puente superior |
| F, mina | (45;20;−20) | Marco de madera, fondo oscuro sólido, rocas, raíles, traviesas, faroles y utilería; se llega por el frente desde (54;≈21;−18) |
| G, laderas | Distribución variable | 113 pinos de cinco variantes, rocas, hierba y flores; densidad menor en cotas altas; fuera de los senderos y primeros planos de llegada |
| Lago alpino | (−6;≈27,73;−53) | Cubeta excavada, orilla elíptica y nacimiento del río; sin natación |

Ruta principal: entrada → (−34;≈3;42) → (−22;6;30) → puente inferior → (16;6;30) → (28;≈12;22) → campamento → (38;≈18;−4) → puente intermedio → (−23;≈19;−4) → mirador → (−24;≈28;−34) → puente elevado → ruinas.

Descenso alternativo: ruinas → (54;≈25;−36) → (54;≈21;−18) → entrada minera → vuelta al cruce oriental → (48;≈16;−4) → (42;≈10;18) → (28;≈12;22). La mina es un ramal de ida/vuelta; su portal cerrado no forma parte de un paso a través de la montaña.

## Agua, garganta y puentes

Río serpenteante: X=−6+4·sin(0,065·Z), ancho variable aproximado 6,8–8,8. Nacimiento conectado al lago y flujo hacia +Z. Perfil de agua (Z;Y): (−54;≈27,8), (−42;27), (−26;26), (−23;18), (−10;17), (8;15), (11;7), (28;5), (42;3), (45;0,8), (70;≈0,24). Tres caídas con espuma e impacto en Z≈−23, 11 y 45. Las dos primeras descienden ocho unidades en tres horizontales; son láminas muy inclinadas, no simulación hidráulica ni partículas. Agua continúa después de cada caída.

Shader exclusivo `RPG/scripts/agua_montanas.gdshader`: turquesa, crestas suaves y movimiento hacia +Z; no modifica el río de Aldea ni la laguna forestal. Barreras discretas en las dos márgenes y perímetro del lago; no se permite entrar al fondo de la garganta. Los cuatro límites exteriores permanecen sólidos.

| Puente | Centro aproximado | Cota del tablero | Función |
|---|---|---|---|
| Inferior | (−2,28;6;30) | 6 | Valle oeste ↔ terraza del campamento |
| Intermedio | (−7,03;18;−4) | 18 | Campamento ↔ ascenso al mirador |
| Elevado | (−9,21;28;−34) | 28 | Mirador ↔ ruinas superiores |

Cada tablero mide 18×4,4, con superficie sólida, estribos, tablones, vigas y dos barandas. Anchura interior aproximada 4,18. Los extremos descansan sobre las laderas continuas; el fondo real del cauce queda por debajo. Recorridos con Input cruzan los tres en ambos sentidos.

## Conexiones

Reutilizados `GestorRegiones`, `region_config.gd`, `salida_region.gd` y fundidos de 0,35 s, sin editar esos scripts.

| Origen | Detector/marcador | Destino e ID de entrada | Aparición base |
|---|---|---|---|
| Aldea | `Region/SalidaMontanas`, marcador estable `Aldea/SalidasRegionales/SalidaCaminoEste/TransicionFutura` (39,5;0,02;0), caja 1,4×3×4 | `mundo_montanas.tscn`, `camino_montanas_aldea_oeste` | Montañas (−52;2,04;48), mirando derecha/+X |
| Montañas | `Region/SalidaAldea`, `Montanas/Marcadores/RetornoAldea` (−62;2,02;48), caja 1,4×3×6 | `mundo.tscn`, `aldea_camino_este` | `Region/EntradaMontanas` (36;0,02;0), mirando izquierda/−X |

El gestor añade +0,05 Y; las apariciones no solapan detectores. Cierres originales detrás de las áreas conservados: la transición ocurre antes de alcanzarlos. No se reconstruye el puente de Aldea ni se modifica su contenido visual. Metadatos históricos `CaminoMontanas` se conservan; la región jugable se identifica explícitamente como `Montanas`.

`Montanas/Marcadores/ConexionMinasFutura` en (45;20;−23,2): `id_salida=montanas_minas_norte`, `destino_previsto=Minas`, `retorno_previsto=minas_montanas_sur`, `activa=false`. El Marker3D y sus metadatos históricos permanecen intactos. Desde el 8 de noviembre de 2026, `mundo_montanas.tscn` configura explícitamente un Area3D sobre él y conecta con Minas; su caja alcanza el frente del cierre original sin retirar rocas/fondo. Retorno específico en `Region/EntradaMinas` (45;20,05;−18). Detalle y pruebas en `RPG/docs/plano_minas.md`. El exterior no se rediseñó.

## Recursos y límites

Originales reutilizados intactos de `RPG/assets/naturaleza/glTF/`: Pine_1–5, Rock_Medium_1–3, Fern_1, Flower_3_Group y Grass_Wispy_Short. De `RPG/assets/objetos_medievales/glTF/`: Barrel, Crate_Wooden, Bag, Lantern_Wall y Pickaxe_Bronze. Ajustes por instancia según AABB; colisiones simplificadas propias. No se identificó una vagoneta específica adecuada ni se atribuye un modelo minero inexistente al paquete. Tiendas, torre, ruinas, portal, raíles, puentes, agua y terreno son geometría propia fuera de assets. Total de originales conservado: 524; exclusión de Git intacta.

Escenas importadas/materiales reutilizados, sin scripts por árbol ni generación por fotograma. Terreno en un recurso estático y colisión compartida de superficie; detalle acotado a centenares de instancias, sin miles de plantas ni nuevos MultiMesh. No hay benchmark universal de rendimiento.

La comprobación de visibilidad por rayos físicos cubre seis puntos en ocho orientaciones y evita cámaras dentro del relieve; no demuestra visibilidad de cada píxel ni toda posición intermedia. Copas, torre y portal pueden ocultar detalles desde ángulos traseros. La aprobación artística y el recorrido manual con teclado/mando siguen a cargo del usuario. No hay transparencia de obstáculos, zoom, ajustes globales de cámara, NPC, combate, minería, natación ni persistencia.

## Reproducción y evidencia

Desde raíz del repositorio, con Godot 4.7.2 disponible:

```text
godot --headless --path RPG --fixed-fps 60 --log-file logs/fase6f_montanas/<nuevo_fisica>.log --script res://tests/validar_montanas.gd
godot --headless --path RPG --fixed-fps 60 --log-file logs/fase6f_montanas/<nuevo_regional>.log --script res://tests/validar_transicion_montanas.gd
godot --path RPG --fixed-fps 60 --log-file logs/fase6f_montanas/<nuevo_capturas>.log --script res://tests/capturar_montanas.gd
```

El capturador solo genera vistas; no sustituye la prueba física. Galerías/capturas y registros nuevos bajo `RPG/logs/fase6f_montanas/`. Los resultados finales concretos y rutas de galería se registran en `RPG/docs/estado_proyecto.md`. Pruebas de regresión de Bosque/Ruinas/Campos aceptan `-- --fase6f` para concentrar evidencias aquí. Los dos fallos históricos de Aldea E04/E12 no se ocultan ni se corrigen en esta fase.

