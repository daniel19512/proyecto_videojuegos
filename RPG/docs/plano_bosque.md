# Bosque — plano físico de fase 6A.1

Fecha: **4 de noviembre de 2026**. Base y vegetación aprobadas; conexiones Aldea ↔ Bosque ↔ Ruinas implementadas desde 6D. Laguna natural construida, pendiente revisión visual. Norte = −Z. Coordenadas locales de `Bosque` a identidad, en unidades Godot. Otras regiones permanecen pendientes. El contrato previsto de 6A.1 se conserva abajo; véase la configuración activa 6D al final.

## Escala y organización

Superficie **100×100**, X/Z=[−50,50], frente a 80×72 de la aldea. Los cierres físicos empiezan en ±49: quedan aproximadamente 98×98 interiores, reducidos por el radio 0,32 del jugador. Se conserva cápsula 1,60, sprite original, velocidad temporal 10 u/s y cámara orbital tamaño 15, inclinación y controles originales. Una travesía de 100 unidades requiere al menos 10 s a esa velocidad, 25 s con la antigua base 4; no incluye aceleración ni curvas. Los edificios de referencia tienen cuerpos 4×4–6×8; los claros de campamento/ruinas dejan huellas mayores sin convertirlos en templos o aldeas nuevas. Copas seleccionadas de aproximadamente 6–10 unidades necesitan exclusiones y revisión de oclusión posterior.

`RPG/scenes/bosque.tscn` contiene Terreno, Relieve, Caminos, LimitesNaturales, Reservas, Marcadores, Iluminacion, Entorno y VistaGeneral. F6 muestra la región completa. `RPG/scenes/pruebas_bosque.tscn` permite explorar con el jugador y la cámara compartidos, sin modificar sus recursos ni la escena inicial. El bosque no es hijo de la aldea.

## Seis zonas

Las reservas son elipses lógicas con `semiejes`, `id_zona`, descripción y exclusión de vegetación. Sus Marker3D `PuntoInteres` están apoyados en el terreno, sin planos flotantes ni colisión de parcela completa.

| ID | Zona | Centro X,Y,Z | Semiejes X,Z | Preparación |
|---|---|---|---|---|
| Z01 | Entrada | (0; 0,384; 41) | 6; 5 | Aparición segura, retorno, espacio de señal en (3;44) |
| Z02 | Claro central | (0; 0,80; 0) | 10; 9 | Cruce abierto; árbol futuro (0;−5), descanso (4;7), ambos sin decorar |
| Z03 | Campamento | (−25; 1,40; −25) | 9; 7 | Espacio para fogata, refugios y mobiliario futuros; sin NPC |
| Z04 | Vestigio de ruinas | (24; 1,80; −26) | 8; 7 | Arco/columnas/restos futuros; acceso a otra región, sin templo |
| Z05 | Mirador | (29; 3,80; 20) | 6; 5 | Colina continua con apoyo físico, sin precipicio ni plataforma flotante |
| Z06 | Ribera de laguna | (−18; 0,45; 21) | 4; 5 | Llegada segura al este de la reserva de agua; sin pesca/recolección |

## Senderos

Los puntos de control siguientes se interpolan como curvas Bézier locales y se guardan como polilíneas con separación aproximada 0,7. Los metadatos `eje`/`ancho` de cada nodo son el plano para decoración y comprobación; el color mezclado del suelo no amplía su anchura lógica. Tierra con borde irregular discreto y transición continua, sin superficies superpuestas.

| ID | Ancho | Recorrido de control X,Z |
|---|---:|---|
| P01 | 3,6 | (0;49), (0;41), (−3;31), (2;18), (−2;9), (0;0) |
| P02 | 3,6 | (0;0), (−10;−5), (−16;−15), (−25;−25) |
| P03 | 3,6 | (0;0), (10;−7), (15;−18), (24;−26), (22;−37), (20;−49) |
| P04 | 3,6 | (0;0), (11;5), (18;14), (29;20) |
| P05 | 3,6 | (0;0), (−9;8), (−13;16), (−18;21) |
| S01 | 2,6 | (−25;−25), (−32;−17), (−33;−6), (−25;4), (−19;12), (−18;21) |
| S02 | 2,6 | (24;−26), (33;−17), (36;−4), (34;8), (29;20) |

P01 une entrada y claro; P02–P05 llevan a las otras cuatro zonas. S01 cierra el circuito claro–campamento–laguna–claro; S02 cierra claro–ruinas–mirador–claro. Los recorridos no atraviesan laguna ni arroyo, por lo que **no hace falta construir un puente para mantener conectividad**. Los extremos regionales acaban ante cierres provisionales; no son pasos al exterior.

## Relieve, materiales y colisión

Una malla triangulada continua de paso 1, **20.000 triángulos**, define tanto el aspecto como la colisión cóncava estática guardada. Colinas anchas, depresión suroeste, claros aplanados y cordón perimetral bajo. El mirador alcanza Y=3,8 sin escalón. La prueba mide cotas y pendientes reales; no cambia gravedad, `floor_snap_length`, parámetros del jugador ni su escala. No hay saltos obligatorios.

`RPG/scripts/terreno_bosque.gdshader` mezcla verdes naturales, marrones y variación tonal en coordenadas del mundo. Los colores de vértice codifican caminos y reservas secas. Material exclusivo del bosque, opaco y mate, sin tocar shader/materiales de la aldea. El arroyo conserva arcilla gris provisional. La laguna tiene agua y depresión visual local; véase la actualización de laguna natural al final.

Los cuatro cierres provisionales están agrupados bajo `LimitesNaturales/CierresProvisionales`. Son cajas delgadas invisibles en X/Z=±49,5, con extensión vertical suficiente sobre las colinas. El relieve visible sube gradualmente hacia el borde; no hay murallas ni paredes visibles. La banda exterior |X| o |Z|≥42 reserva arbolado denso futuro, excluyendo los accesos norte/sur de 6 unidades. La ocultación natural completa de estos límites depende de la fase de vegetación y rocas.

## Agua y puentes previstos

- Laguna seca reservada: centro (−29;22), semiejes (8;6), aproximadamente X=[−37,−21], Z=[16,28]. Depresión sobre suelo continuo. Cuarenta cajas pequeñas forman un cierre provisional de orilla; no se permite entrar en su reserva. Sustituir conjuntamente con cauce/orilla definitivos, sin eliminar seguridad antes de tiempo.
- Arroyo reservado de ancho 2,4: (−41;−50) → (−40;−30) → (−42;−10) → (−39;10) → (−34;19). Curva occidental fuera de los senderos; todavía es terreno seco, sin agua, barreras hidráulicas ni cascada.
- `PuentePrevisto1`: (−40;−30); `PuentePrevisto2`: (−39;9). Son ubicaciones opcionales para un cruce transversal futuro, **sin geometría ni ruta actual que dependa de ellas**. Ajustar su apoyo exacto al cauce definitivo. No se copia río, puente ni shader de la aldea.

## Contrato regional

Cada salida conserva los seis metadatos de la aldea y cuatro Marker3D. Y se obtiene del suelo +0,05; los X,Z se documentan abajo. Los identificadores de la región de ruinas son previstos, no acreditan que exista esa escena ni obligan a nuevas APIs.

| Nodo / ID | Destino / retorno previsto | Orientación | Aproximación y aparición X,Z | Transición futura X,Z | Límite X,Z | Camino |
|---|---|---|---|---|---|---|
| RetornoAldea / `bosque_aldea_sur` | Aldea / `aldea_bosque_norte` | (0;0;1) | (0;41) | (0;48) | (0;49) | Caminos/P01 |
| SalidaRuinas / `bosque_ruinas_norte` | Ruinas / `ruinas_bosque_sur` | (0;0;−1) | (22;−37) | (20;−48) | (20;−49) | Caminos/P03 |

`limite_provisional` apunta a `LimitesNaturales/CierresProvisionales`. Sin Area3D, teletransporte, guardado ni gestor de regiones. La salida norte de la aldea sigue cerrada e intacta.

## Exclusiones de vegetación y rendimiento

Conservar libres las seis reservas, la franja de los senderos más margen mínimo 0,5 para troncos, aparición/aproximación/transición, reservas de agua y posibles tableros. La ribera y el claro pueden recibir decoración baja en fases posteriores tras revisar pasos; no poblar automáticamente toda la elipse. Proteger el cruce central y el apoyo seguro del mirador, y comprobar copas a tamaño 15 en varios ángulos.

No se colocan los 72 modelos. Una superficie/material de terreno, una colisión estática continua, cuatro formas perimetrales y cuarenta formas de orilla. Una luz direccional con sombras y ambiente sencillo; sin scripts por objeto ni generación por fotograma. Para vegetación posterior, evaluar MultiMesh por modelo/superficie y sectores de unos 25×25, con colisiones simples separadas. La región vacía no demuestra el rendimiento de un bosque denso.

## Autoría, validación y evidencias

Recursos geométricos propios: `RPG/scenes/bosque_terreno.res` y `RPG/scenes/bosque_colision.res`, fuera de assets originales. La herramienta opcional `RPG/scripts/editor/construir_bosque.gd` los regenera junto con `bosque.tscn`; no se usa para jugar. Los cambios manuales que deban sobrevivir a una regeneración deben reflejarse también en esa herramienta.

Desde la raíz del repositorio, crear primero `RPG/logs/fase6a1_bosque_base/`. Usar un nombre nuevo de registro en cada ejecución:

```text
godot --headless --path RPG --fixed-fps 60 --log-file logs/fase6a1_bosque_base/<nombre_nuevo>.log --script res://tests/validar_bosque.gd
```

Sin `--headless` ni `--fixed-fps`, la misma prueba produce diez PNG, galería HTML y muestra de rendimiento en una subcarpeta nueva. Verifica identidad entre caras físicas/visibles, cobertura de suelo, pendientes, seis zonas, grafo conectado, agua fuera de caminos, anchuras con cápsula, contrato regional, cierres perimetrales y de laguna, control negativo de obstáculo y catorce recorridos reales con el controlador original. El frenado de prueba respeta v²/(2a) sin alterar el jugador. El tamaño de cámara de las capturas no cambia el laboratorio ni el mundo.

Los resultados finales y las rutas de galería se registran en `RPG/docs/estado_proyecto.md`. Los fallos históricos E04/E12 de la aldea siguen pendientes; no se ejecuta su regresión porque no cambia ningún archivo de ese mundo. La revisión gráfica técnica no sustituye aprobación visual del usuario. **Detenerse en 6A.1 antes de vegetación, decoración o sistemas jugables.**

## Vegetación 6A.2 — 4 de noviembre de 2026

6A.1 aprobada por el usuario. Se añade únicamente `Vegetacion`, referencia a `RPG/scenes/vegetacion_bosque.tscn`; terreno físico/visible, shader, ejes, anchuras, reservas, marcadores y cierres permanecen intactos. 329 árboles, 1.139 arbustos, 3.361 plantas, 133 rocas y 39 troncos/tocones en dieciséis sectores. Dosel de roble/olmo, transición sur con CommonTree, abedules occidentales y coníferas/secos al noreste. Las seis reservas y el agua futura permanecen sin construir. Detalle de escalas, sectores, exclusiones, colisiones, reproducción y evidencias en `RPG/docs/vegetacion_bosque.md`. La autoría MultiMesh se ejecuta con render real; no usar headless para regenerarla. Aprobación visual pendiente antes de continuar.

## Fase 6B — retorno jugable a aldea

La envolvente `RPG/scenes/mundo_bosque.tscn` hereda `pruebas_bosque.tscn` y añade configuración regional/detector sin editar esta región de contenido. `Region/SalidaAldea` reutiliza `Marcadores/RetornoAldea/TransicionFutura` (0;0,803;48), desplazada +1 Y, caja 3,6×3×1,4. Destino `RPG/scenes/mundo.tscn`, entrada `aldea_bosque_norte`. La llegada desde aldea reutiliza `AparicionSegura` en (0;0,434;41), ID `bosque_aldea_sur`, mirando hacia −Z. Cierres, vegetación, terreno y senderos intactos. La salida norte a ruinas continúa inactiva. El laboratorio aislado conserva su regresión; la envolvente permite F6 conectado. Guía en `RPG/docs/transiciones_regionales.md`.

## Laguna natural — mejora localizada

La reserva (-29;22), semiejes 8×6, contiene ahora agua azul verdosa a Y=-0,12 y orilla irregular. El vertex shader de terreno deforma solo el interior cerrado al jugador hasta Y=-0,72 y enlaza con las cotas originales; la física de suelo y las cuarenta barreras originales se conservan. La escena independiente RPG/scenes/laguna_bosque.tscn incorpora treinta elementos de orilla y seis nenúfares propios, sin nuevas colisiones. Senderos, árboles, Z06 y transiciones intactos. El arroyo y los puentes previstos siguen pendientes. Detalle, límites y validaciones en RPG/docs/laguna_bosque.md. Esperar revisión visual.

## Conexión activa 6D

P03 conduce ahora a las ruinas mediante `MundoBosque/Region/SalidaRuinas`, apoyada en el marcador previsto (20;1,0035956;−48), centro de detector (20;2,0035956;−48), caja 3,6×3×1,4. Destino `mundo_ruinas.tscn`, entrada `ruinas_bosque_sur`. El retorno usa la nueva entrada de envolvente `Region/EntradaRuinas`, ID `bosque_ruinas_norte`, en (22;1,8886713;−37), con orientación abajo/+Z; coincide con la aparición prevista pero evita editar el bosque original. Desde aldea se mantiene `bosque_aldea_sur` en (0;0,43386927;41). El gestor añade +0,05 Y a ambas.

`VestigiosAccesoRuinas`, instancia de `RPG/scenes/acceso_ruinas_bosque.tscn` exclusivamente en el mundo jugable, aporta dos columnas rotas fuera del camino en X,Z=(17,8;−43) y (24,5;−43); fustes con colisión simple. P01/P03, siete senderos, reservas, vegetación, laguna, suelo y cierres originales permanecen intactos. El laboratorio aislado no activa transiciones. Pruebas y coordenadas completas: `RPG/docs/transiciones_regionales.md`, apartado 6D. La descripción anterior de la salida norte pendiente corresponde al contrato histórico 6A/6B; desde 6D está activa en su envolvente.
