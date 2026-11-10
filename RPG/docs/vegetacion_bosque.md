# Vegetación del bosque — fase 6A.2

Fecha: 4 de noviembre de 2026. Implementación independiente de la aldea; aprobación visual pendiente del usuario. No incorpora campamento, ruinas, agua, transiciones ni gameplay.

## Composición y autoría

5.001 elementos: 329 árboles, 1.139 arbustos, 3.361 plantas, 133 rocas/piedras y 39 troncos/tocones. 36 modelos seleccionados reales, sin nuevos assets. Robles grande/mediano y olmo forman el dosel; abedules al oeste, coníferas y secos al noreste, CommonTree en la transición sur. Reservas abiertas y capas irregulares periféricas. Se excluyen A03 (hito futuro con peana), arbustos KayKit muy saturados y mobiliario/arquitectura de fases posteriores. No se inventan ramas: A14 aporta troncos caídos reales.

`RPG/scripts/editor/construir_vegetacion_bosque.gd` es una herramienta offline opcional, no un componente de ejecución. Semilla **62024** y catálogo `RPG/tests/seleccion_assets_bosque.json`. Primero mide AABB transformadas de cada modelo; separación según diámetro de copa (factor 0,36 periférico / 0,46 interior, mínimo 1,35 por radio). Muestreo de rechazo continuo, sin cuadrícula ni cantidad objetivo fija. Se aceptan 329 árboles por cobertura/espaciado del terreno disponible, por encima de la orientación inicial 180–300; se debe juzgar la densidad en las capturas.

Escalas uniformes por ID del catálogo, variación de árboles 0,85–1,10; plantas 0,80–1,15; rocas/troncos 0,70–1,00. C01 se reduce adicionalmente ×0,55 para evitar aspecto de edificio. Tabla siguiente registra rangos realmente guardados, no solo propuestas. Pivotes compensados por mínimo Y de AABB; apoyo con raycast sobre la malla física aprobada, árboles verticales y giro libre en Y. En relieve, compensar el mínimo central no garantiza contacto de cada extremo de un tronco largo; revisar visualmente los encuentros.

Escena persistente `RPG/scenes/vegetacion_bosque.tscn`, datos auditables `RPG/scenes/vegetacion_bosque_datos.json`. 438 grupos por categoría/modelo/sector 25×25, MultiMesh por cada malla importada con transformaciones internas y materiales originales conservados. Sin scripts individuales ni generación al iniciar. Sectores indexados desde esquina noroeste (-50,-50), X/Z crecientes. No hay descarte por distancia ni cambios globales de sombras/render.

Un StaticBody3D reúne 437 formas simples: cilindros de tronco radio 0,30/0,42 y altura máxima 3; cajas orientadas de troncos/tocones y rocas de más de 0,65 de alto. Sin colisión de copas, hierba, arbustos, flores, hongos o piedras pequeñas.

## Exclusiones y reproducción

Se conservan terreno, relieve, siete ejes y anchuras, seis reservas y cierres. Centros de árboles a más de semiancho + 0,55 + 2,60 de rutas; decoración baja excluye su radio horizontal más 0,55. Reservas elípticas ampliadas por radio + 0,70; laguna por radio + 1; arroyo por radio + 1,70; posibles puentes por radio + 3. Margen exterior según radio, sin expandir terreno. Sin objetos dentro de las reservas futuras.

Reproducción desde raíz del repositorio, con ejecutable local Godot 4.7.2:

```text
godot --path RPG --log-file logs/<nombre_nuevo>.log --script res://scripts/editor/construir_vegetacion_bosque.gd
godot --headless --path RPG --fixed-fps 60 --log-file logs/<otro_nombre>.log --script res://tests/validar_vegetacion_bosque.gd
```

Sin headless ni fixed-fps se generan capturas reales y galería en `RPG/logs/fase6a2_vegetacion_bosque/`. La herramienta de base conserva la referencia a vegetación cuando existe; regenerar la base no es necesario para esta fase. Dos ejecuciones del distribuidor produjeron datos con SHA-256 idéntico `880C140E7B2CC3C241DD6D4138003F4895D8FC1511385D2E6E3FF0366D6D98EA`.

## Modelos y sectores

| ID | Modelo | Cantidad | Escala mínima–máxima |
|---|---|---:|---:|
| A01 | Flat_Tree_Oak_large_green | 22 | 0.484–0.610 |
| A02 | Flat_Tree_Oak_medium_green | 46 | 0.444–0.571 |
| A04 | Flat_Tree_Birch_medium_green | 94 | 0.545–0.703 |
| A05 | Flat_Tree_Elm_green | 16 | 0.477–0.614 |
| A07 | Flat_Tree_Pine_small | 30 | 0.469–0.590 |
| A08 | Flat_Tree_Spruce_medium | 52 | 0.675–0.868 |
| A09 | CommonTree_3 | 29 | 0.730–0.926 |
| A10 | CommonTree_5 | 18 | 0.854–1.091 |
| A11 | Tree_Bare_1_C_Color1 | 11 | 0.916–1.100 |
| A12 | Tree_Bare_2_B_Color1 | 11 | 1.277–1.512 |
| A13 | Flat_Tree_Stump | 22 | 0.253–0.355 |
| A14 | Flat_Fallen_Log | 17 | 0.354–0.497 |
| B01 | Flat_Bush_Clumps_medium | 275 | 0.344–0.494 |
| B02 | Flat_Bush_Clumps_small | 295 | 0.320–0.460 |
| B03 | Flat_Bush_medium | 286 | 0.288–0.414 |
| B04 | Flat_Bush_with_Flowers | 283 | 0.320–0.460 |
| B07 | Flat_Grass_large | 285 | 0.200–0.287 |
| B08 | Flat_Grass_small | 277 | 0.152–0.218 |
| B09 | Grass_2_C_Color1 | 264 | 0.560–0.804 |
| B10 | Fern_1 | 271 | 0.400–0.574 |
| B11 | Clover_1 | 286 | 0.281–0.402 |
| B12 | Grass_Common_Short | 299 | 0.281–0.402 |
| B13 | Grass_Wispy_Short | 275 | 0.320–0.458 |
| B14 | Flat_Mushroom_Brown_small | 275 | 0.400–0.573 |
| B15 | Flat_Mushroom_Red_large | 283 | 0.600–0.862 |
| B18 | Flower_3_Group | 262 | 0.200–0.287 |
| B19 | Flower_4_Group | 299 | 0.160–0.230 |
| B20 | Plant_7 | 285 | 0.801–1.149 |
| C01 | Rock_1_M_Color1 | 13 | 0.519–0.699 |
| C03 | Rock_3_C_Color1 | 23 | 0.715–0.962 |
| C04 | Rock_3_H_Color1 | 9 | 0.795–0.917 |
| C08 | Flat_Rock_05 | 10 | 0.735–0.982 |
| C09 | Flat_Rock_08 | 26 | 0.720–0.989 |
| C10 | Rock_Medium_1 | 14 | 0.494–0.699 |
| C12 | Pebble_Round_1 | 22 | 0.715–0.987 |
| C13 | Pebble_Round_4 | 16 | 0.706–1.000 |

| Sector X,Z | Elementos |
|---|---:|
| S00 | 284 |
| S01 | 220 |
| S02 | 306 |
| S03 | 438 |
| S10 | 394 |
| S11 | 271 |
| S12 | 174 |
| S13 | 280 |
| S20 | 331 |
| S21 | 227 |
| S22 | 262 |
| S23 | 358 |
| S30 | 446 |
| S31 | 299 |
| S32 | 285 |
| S33 | 426 |

## Validación técnica

Prueba específica headless: **0 fallos / 95.502 comprobaciones**, `RPG/logs/fase6a2_especifica_02.log`. Incluye rutas de modelos, 5.001 apoyos reales, exclusión de centros de senderos/reservas y toda la regresión anterior: siete rutas conectadas, seis zonas, límites/laguna, control negativo y catorce recorridos con apoyo continuo. Los rayos que miden exclusivamente terreno excluyen el cuerpo vegetal para no confundir la cima de una roca con suelo; las consultas de cápsula y los recorridos siguen incluyendo toda la vegetación. No se relajan tolerancias ni se desactivan obstáculos.

La prueba específica hereda la anterior y agrega 32 vistas de juego a tamaño 15, además de vistas generales y comparación idéntica sin/con vegetación. La orientación se establece solo en el capturador, sin modificar la cámara compartida. Oclusión de un sprite por dosel denso sigue siendo una limitación a evaluar en cada orientación; no hay transparencia automática. Pendiente aprobación visual del usuario antes de cualquier fase posterior.

La autoría necesita render real: Godot headless no conserva los buffers MultiMesh al guardar. La herramienta rechaza ese modo antes de escribir; las pruebas físicas sí funcionan headless. Primeras evidencias forward_01 mostraron el defecto y no son válidas como resultado visual ni rendimiento vegetal. Se regeneró con Forward+/D3D12 y se añadió comprobación de cada buffer persistido.

## Cierre gráfico y rendimiento real

Godot 4.7.2, Forward+/D3D12, RTX 4060 Laptop: regresión gráfica completa **0 fallos / 95.982 comprobaciones**, incluidas 438 comprobaciones de buffers y capturas, `RPG/logs/fase6a2_forward_02.log`. Galería final ampliada: `RPG/logs/fase6a2_vegetacion_bosque/2026-11-04T12-00-03_5831/galeria.html`, **44 PNG**, log `RPG/logs/fase6a2_capturas_metricas_03.log`. Incluye superior completa, vistas de seis zonas, perímetro, escala de jugador, 32 orientaciones y comparación antes/después con idéntica cámara. La vista superior ya muestra la distribución de árboles; no se añade una representación conceptual.

Se revisaron visualmente la superior y muestras de claro central, sendero sur, ruinas, mirador, ribera y perímetro. Caminos claros y dosel variado; contraste más frío en coníferas, verdes claros en robles/abedules. La captura periférica (0;−42), fuera de senderos, oculta al protagonista por densidad; no afirmar visibilidad universal en sotobosque. El sendero (-3;31) a 180° tiene copa próxima al lado derecho del sprite, cuyo rostro sigue visible. Materiales originales producen acentos florales vivos y madera naranja de secos KayKit; sujetos a aprobación artística. La reserva de laguna sigue seca, gris, sin agua construida. No se revisaron manualmente todos los apoyos de cada hoja ni todas las posiciones continuas de órbita.

| Muestra | Mediana ms | p95 ms | Draw calls |
|---|---:|---:|---:|
| Base 6A.1, claro, 180 frames | 6,959 | 7,328 | 6 |
| Vegetación, claro, 180 frames | 6,951 | 7,480 | 777 |
| Entrada, 120 frames | 6,959 | 7,581 | 897 |
| Claro, 120 frames | 6,948 | 7,513 | 764 |
| Campamento, 120 frames | 6,933 | 8,728 | 555 |
| Ruinas, 120 frames | 6,961 | 7,478 | 614 |
| Mirador, 120 frames | 6,910 | 7,644 | 1.110 |
| Ribera, 120 frames | 6,965 | 7,583 | 839 |
| Sendero sur, 120 frames | 6,926 | 7,483 | 889 |
| Perímetro norte, 120 frames | 6,945 | 7,506 | 383 |

Muestras a cámara 15, 1600×1000, sin fixed-fps; mediana equivale a 143,6–144,7 FPS. No representan tiempos GPU aislados ni garantizan todos los equipos; cercanía a 144 FPS sugiere límite de presentación. Memoria de vídeo informada por motor ~247 MiB, global del proceso; objetos renderizados 383–1.110 según vista/pases, no equivale al número de modelos ni nodos. Detalle en `rendimiento_zonas.json`. La comparación puntual de 180 frames cuenta 414.267 primitivas frente a 100.006 base. El texto heredado de rendimiento.txt en esas evidencias conserva erróneamente «Escena base sin vegetacion»; las cifras 777 draw calls y las capturas corresponden a vegetación visible. Se corrigió el rótulo para ejecuciones posteriores sin sobrescribir registros existentes.

Pendiente: aprobación artística y recorrido manual del usuario, especialmente oclusión fuera de caminos, acentos florales y ocultación de bordes desde posiciones extremas. No expandir terreno ni iniciar campamento/agua/ruinas hasta nueva tarea. Persisten mensajes del motor de certificados y caché de shaders; sin fallos de recursos o parseo en cierres. No se ejecutó regresión de aldea al no modificar ese mundo.

## Archivos de esta fase

Creados: `RPG/scenes/vegetacion_bosque.tscn`, `RPG/scenes/vegetacion_bosque_datos.json`, `RPG/scripts/editor/construir_vegetacion_bosque.gd`, `RPG/tests/validar_vegetacion_bosque.gd`, este documento. Modificados sobre la base local previa: `RPG/scenes/bosque.tscn` (referencia), `RPG/scripts/editor/construir_bosque.gd` (conserva referencia al regenerar), `RPG/tests/validar_bosque.gd` (rayos de cota y rótulo de rendimiento), `RPG/docs/plano_bosque.md` y `RPG/docs/estado_proyecto.md`. AGENTS revisado sin edición nueva; inventario y cambios previos ajenos preservados. Sin commits ni pushes.
