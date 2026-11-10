# Ruinas Antiguas — fase 6C

Construcción del 4 de noviembre de 2026, pendiente de revisión visual del usuario. **Desde 6D, conexión Bosque ↔ Ruinas activa** por configuración de las escenas jugables. La laguna y las regiones anteriores se conservan. El registro 6C se mantiene como historial; véase la configuración activa al final.

## Escenas y apertura

Abrir `RPG/scenes/mundo_ruinas.tscn` y pulsar **F6**. No cambiar la escena inicial del proyecto. Movimiento y órbita con los controles existentes: WASD/flechas, Q/E y mando. El protagonista, su velocidad temporal 10 y los scripts compartidos permanecen intactos; cámara ortográfica 15.

`RPG/scenes/ruinas.tscn` contiene la geometría serializada, materiales, instancias originales, colisiones y marcadores. `mundo_ruinas.tscn` añade jugador, cámara, luz natural, ambiente y configuración regional existente. No se genera el mapa al jugar.

## Plano y coordenadas

Dimensiones: **80×80**, X/Z=[-40,40], suelo Y=0. Cuatro cierres sólidos invisibles en los bordes, rodeados por arbolado. Norte corresponde a -Z.

```text
                         NORTE (-Z)
                  D · Santuario (0,-25)
                            |
                            |
                  C · Plaza (0,0) ───── E · Jardín (23,2)
                         / 
    Desvío (-17,9) ─ B · Camino (-7,13)
                           \
                     A · Entrada (0,29)
                            |
                     Aparición (0,34)
                  Retorno futuro (0,37)
                          SUR (+Z)
```

Todas las coordenadas siguientes son X,Z salvo indicación Y:

| Zona | Centro | Construcción |
|---|---|---|
| A, entrada | (0,29) | Sendero despejado, robles periféricos, muros rotos en (-5,29), (6,26), (-6,20). |
| B, camino antiguo | (-7,13) | Columnas de alturas distintas en (-11,17), (-3,17), (-11,6), (-18,6); columna caída en (-13,16); desvío a (-17,9). |
| C, plaza | (0,0) | Losas incompletas en una retícula original deteriorada de aproximadamente 18×15; seis columnas rotas, fragmentos y pedestal vacío (-5,-4). Sin estatua inventada. |
| D, santuario | (0,-25) | Plataforma 17×14 con superficie Y=0,30; rampa 4,5×3,1 desde Z≈-15; columnas en (±5,-18,8), dintel partido oeste; cuatro paños de sillares incompletos y altar (0,-29). Interior abierto integrado en el mapa. |
| E, jardín | (23,2) | Bancos de piedra en (18,-3) y (28,-3); rocas en (18,-7), (29,7), (30,-9); árboles, flores, helechos y tronco caído (27,11). |

Camino principal: (0,36) → (0,24) → (-7,13) → (0,0) → (0,-24). Bifurcaciones: (0,0) → (23,2), y (-7,13) → (-17,9). Anchura lógica 4,5; mezcla visual de tierra/hierba de bordes irregulares. `Ruinas/Caminos` conserva extremos y anchuras como metadatos; sus cajas no se dibujan ni colisionan. La superficie visual la produce el shader sobre el suelo original.

## Recursos y colisiones

Originales locales reutilizados sin edición:

- `RPG/assets/bosque/forest_nature_updated/Trees/Oak/Flat_Tree_Oak_medium_green.glb` y `Flat_Tree_Oak_large_green.glb`: arbolado, apoyo y escala ajustados por AABB.
- `RPG/assets/bosque/forest_nature_updated/Extras/Flat_Fallen_Log.glb`: tronco caído del jardín.
- `RPG/assets/naturaleza/glTF/Rock_Medium_1.gltf`: rocas grandes del jardín.
- En la misma carpeta natural: `Fern_1.gltf`, `Grass_Wispy_Short.gltf`, `Flower_3_Group.gltf`, `Bush_Common_Flowers.gltf`.

Se inspeccionaron módulos de muro, arco y escaleras medievales existentes. Para evitar representar una vivienda conservada como santuario, la arquitectura antigua usa cajas y cilindros de siete caras propios: bases, columnas, dintel roto, sillares de alturas variables, plataforma/rampa, losas, bancos, altar y escombros. Los shaders `piedra_ruinas.gdshader` y `terreno_ruinas.gdshader` usan colores procedurales, sin texturas adicionales. No se incorporan paquetes ni se alteran originales o licencias; se mantiene la exclusión de assets.

Suelo, límites, muros, columnas, plataforma, rampa, pedestal, bancos, escombros grandes, troncos de árbol, rocas grandes y tronco caído tienen formas simples. El tronco caído usa una caja orientada según su instancia; árboles/rocas usan cilindros aproximados. Flores, hierba, helechos, arbustos, fragmentos bajos y losas no bloquean. Las juntas de las losas no son huecos físicos: el suelo debajo es continuo. No hay navegación de NPCs, combate ni interacción.

## Preparación regional

`Region.id_region = Ruinas`, entrada registrada `ruinas_bosque_sur` → `Ruinas/Marcadores/EntradaBosque` en **(0;0,05;34)**. El jugador de F6 aparece en (0;0,08;34). `RetornoBosque` en (0;0;37) conserva `id_salida=ruinas_bosque_sur`, `destino_previsto=Bosque`, `activa=false`.

En 6C no existía Area3D de salida. Desde 6D, `MundoRuinas/Region/SalidaBosque` usa ese marcador y carga `mundo_bosque.tscn`, entrada `bosque_ruinas_norte`. Su caja 4,5×3×1,4 tiene centro (0;1;37), tres unidades en planta detrás de la aparición; el cierre sur sigue intacto. El metadato `activa=false` pertenece a la preparación histórica y no controla las conexiones: la Area3D se configura en la envolvente, sin cambiar `ruinas.tscn` ni su herramienta. Llegar desde el bosque usa `ruinas_bosque_sur`, mirando arriba/−Z. El retorno aparece en bosque (22;1,8886713;−37) +0,05 Y, mirando abajo/+Z. Resultados vigentes en `RPG/docs/transiciones_regionales.md`; los siguientes son históricos de 6C.

## Autoría y validación reproducibles

Herramienta opcional: `RPG/scripts/editor/construir_ruinas.gd`, semilla 60481. **Regenera exclusivamente ruinas.tscn**; los ajustes que deban sobrevivir a su uso deben mantenerse también en ella. No es necesaria para F6.

Desde la raíz del repositorio, sustituyendo `godot` por Godot 4.7.2 disponible:

```text
godot --headless --path RPG --fixed-fps 60 --log-file logs/fase6c_ruinas/<nombre_nuevo>.log --script res://tests/validar_ruinas.gd
godot --path RPG --fixed-fps 60 --log-file logs/fase6c_ruinas/<otro_nombre_nuevo>.log --script res://tests/validar_ruinas.gd
```

La segunda variante genera cuatro orientaciones por zona y plano superior, sin modificar la cámara guardada. Cada ejecución crea una subcarpeta nueva. La prueba mueve la cápsula real con `move_and_slide()` por el circuito en ambos sentidos, el jardín y el desvío; comprueba apoyo, formas sólidas detectables individualmente, cuatro cierres, órbita en ocho ángulos, configuración de entrada y ausencia de Area3D activas. No equivale a recorrido manual exhaustivo o comprobación de todas las posibles aproximaciones a cada obstáculo.

Resultados en Godot **4.7.2.stable.official.ed1daf0bf**:

| Prueba | Resultado | Registro en `RPG/logs/fase6c_ruinas/` |
|---|---|---|
| Ruinas headless, versión guardada final | **0 fallos / 517 comprobaciones** | `15_colision_tronco_final.log` |
| Ruinas Forward+/D3D12, NVIDIA RTX 4060 Laptop | **0 / 538**, 21 PNG | `11_forward_definitivo.log` |
| Bosque, regresión | **0 / 20.485** | `07_regresion_bosque.log` |
| Aldea ↔ Bosque | **0 / 182**, diez trayectos | `08_regresion_transiciones.log` |
| Aldea completa, tiempo real | **2 fallos preexistentes E04/E12**, 13.695 muestras, 36 corredores | `12_regresion_aldea.log` |
| Apertura/importación de editor headless | Sin errores de sintaxis/carga de estas escenas; restricciones de guardado de ajustes globales | `16_editor_importacion.log` |

Galería final: `RPG/logs/fase6c_ruinas/2026-11-04T20-25-05_2012/galeria.html`. Contiene A–E en 0°, 90°, 180°, 270° y `plano_superior.png`. Se revisaron las cinco zonas en muestras oblicuas y un plano superior; no se afirma aprobación artística ni recorrido manual. Tras capturar se ajustó únicamente la forma física del tronco caído, sin cambiar su aspecto, y se repitió headless.

Limitaciones: persisten errores del entorno al leer certificados y guardar caché de shaders; el editor no puede guardar ajustes globales fuera del proyecto. No impidieron carga, render ni pruebas físicas. Los controles negativos regionales emiten avisos esperados. La regresión de aldea conserva los retornos E04/E12 ya documentados, sin corregirlos fuera de alcance. Algunas copas pueden ocultar al protagonista desde ciertos ángulos en el jardín/perímetro; no se implementa transparencia. Sin benchmark prolongado ni nueva prueba manual de mando. **Detenerse aquí para aprobación visual antes de conectar Bosque ↔ Ruinas.**

## Conexión 6D y revisión pendiente

El mapa original y su autoría 6C permanecen sin editar. La configuración activa vive en `RPG/scenes/mundo_ruinas.tscn`; abrirla con F6 permite volver al bosque. Cinco circuitos completos y la secuencia de visitas repetidas se validan en `RPG/tests/validar_bosque_ruinas.gd`. Registros y capturas de esta fase exclusivamente en `RPG/logs/fase6d_bosque_ruinas/`, resultados en `RPG/docs/transiciones_regionales.md`. La instrucción histórica de esperar antes de conectar queda sustituida por la solicitud explícita de 6D; al terminar la conexión se espera nuevamente revisión del usuario, sin comenzar otra fase.
