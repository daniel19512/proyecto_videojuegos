# Minas — región subterránea

Implementación del 8 de noviembre de 2026 en Godot 4.7.2. Abrir `RPG/scenes/mundo_minas.tscn` con F6 para explorar directamente, o llegar caminando desde el portal existente de Montañas. La escena inicial sigue siendo Aldea. Contenido ambiental: sin extracción, inventario, NPC ni nuevas mecánicas.

## Escenas, autoría y organización

- `RPG/scenes/minas.tscn`: geometría, colisiones, materiales, utilería, iluminación y marcadores guardados. No genera el escenario al jugar.
- `RPG/scenes/mundo_minas.tscn`: envolvente regional, jugador original, cámara orbital compartida tamaño 15, ambiente y salida a Montañas.
- `RPG/scripts/editor/construir_minas.gd`: autoría opcional por zonas, semilla 70708; guarda únicamente minas.tscn. `minas_geometria.gd` aporta topología y utilidades. No ejecutar este archivo base directamente. Los cambios manuales que deban sobrevivir a una regeneración deben trasladarse a la fuente correspondiente.
- `TerrenoYTuneles`, `RocasDeBorde`, `ZonaA_Entrada`…`ZonaF_Depositos`, `AguaYOrillas`, `Recorridos`, `Marcadores` separan responsabilidades. Los ejes 3D en `Recorridos` son referencias de validación, no navegación de NPC.

La huella irregular une salas elípticas y tramos quebrados mediante 2.417 celdas de una unidad. Suelo continuo triangulado con colisión derivada de la misma malla; paredes perimetrales cerradas, respaldadas por roca facetada. Extensión aproximada X=−31…29, Z=−97…11. No hay plano horizontal de respaldo ni desplazamiento de terreno en shader. Las colisiones cóncavas estáticas aceptan ambas caras; bóvedas visuales sin colisión porque quedan fuera del alcance del protagonista.

## Zonas y cotas

Coordenadas X,Y,Z; norte=−Z.

| Zona | Ubicación aproximada | Contenido |
|---|---|---|
| A, entrada | (0;0;0) | Galería amplia, refuerzos, faroles, raíles, barril/caja, pico y señal a Montañas. Aparición separada ocho unidades del centro de salida. |
| B, galería | (−6;−0,57;−22) → (0;−3,43;−32) | Curva y primera rampa, madera y tramos de vía; bifurcación al depósito. |
| C, extracción | (8;−4;−40) | Sala ensanchada, frente mineral gris/cobre/azul integrado en macizo rocoso, pico/pala, faroles y vagoneta cargada sobre raíles. |
| D, profunda | (7;−4,31;−49) → (−6;−7,69;−60) → (−5;−10,77;−70) | Descenso progresivo, menos faroles, soportes inclinados y humedad visual en el acabado. |
| E, caverna | (8;−12;−82), semiejes 21×15 | Bóveda de once unidades, columnas, estalactitas/estalagmitas, cristales, estanque, pasarela y plataforma con pescante antiguo. |
| F, depósito | (−23;−4;−38) | Ramal occidental de almacenamiento, cajas, saco, barril, madera, pala y segunda vagoneta. |
| F, abandonado | (−26;−11,38;−72) | Segundo ramal, vías interrumpidas, soporte deteriorado, derrumbe sólido y filón final. |

Nivel superior Y=0 hasta Z=−20. Primera rampa baja cuatro unidades en catorce horizontales (≈15,95°), nivel intermedio Y=−4 entre Z=−34 y −48. Segunda rampa baja ocho unidades en veintiséis horizontales (≈17,10°); nivel inferior Y=−12 desde Z=−74. Pendientes inferiores a los 45° originales; no requieren salto ni modificación de cápsula. Pasarela/plataforma enrasadas con el camino: se evitó un escalón que el controlador no podía subir.

## Estanque y seguridad

Centro (16;−13,1;−84), superficie elíptica de semiejes 5,5×4,5 y 32 triángulos, orientada hacia arriba. Fondo excavado hasta Y=−14,5 mediante geometría real; transición rocosa a camino Y=−12. El shader `RPG/scripts/agua_minas.gdshader` aporta tonos azul verdosos, ondulación discreta y reflejo moderado; no deforma la colisión ni implementa natación.

Orillas rocosas y baranda perimetral física bloquean el acceso al fondo; el agua carece de colisión. La prueba camina hacia ella y verifica la detención, además de medir el fondo por rayo. Pasarela al oeste y plataforma de observación transitables, con colisión propia y barandas. Las paredes cierran los extremos de los ramales y todo el perímetro del terreno.

## Visibilidad, iluminación y controles

No se editan cámara, jugador ni acciones. Q/E y stick derecho mantienen la órbita 360°; movimiento original relativo a pantalla. Sin nuevos controles especiales.

`RPG/scripts/minas_visibilidad.gd` actualiza dos materiales locales con posiciones de jugador/cámara. `roca_minas.gdshader` recorta las bóvedas a menos de 32 unidades horizontales y abre una ventana de radio seis alrededor del segmento visual del personaje a la cámara. Las paredes siguen colisionando; no es un sistema global de transparencia. Los minerales y obstáculos permanecen físicos/visuales en su posición. La solución permite leer la sala alrededor del jugador; tiene un borde de recorte visible y no equivale a una simulación de cámara interior bajo cada techo.

Ambiente tenue azul grisáceo, diez faroles cálidos y dos luces frías de caverna, sin sombras dinámicas ni luz por cada cristal. Cristales con emisión muy baja; agua sin reflejos de pantalla costosos. Materiales locales compartidos y mallas reutilizadas; sin dependencias nuevas. No se realizó benchmark universal de FPS ni prueba con mando físico.

## Recursos reutilizados

Originales intactos de `RPG/assets/objetos_medievales/glTF/`: `Lantern_Wall`, `Pickaxe_Bronze`, `Barrel`, `Crate_Wooden`, `Bag`. De `RPG/assets/naturaleza/glTF/`: `Rock_Medium_1`. Escala y apoyo ajustados por instancia a partir de AABB. Colisiones propias individuales para objetos voluminosos; sin colisión por mineral o grava.

Vagonetas, raíles/traviesas, palas, soportes, señal, macizos minerales, bóvedas, columnas, cristales, plataforma y pescante son geometría propia de Godot fuera de assets. No se atribuyen vagonetas/palas a modelos inexistentes. Ningún original, BIN, textura o importación fuente fue modificado; no se añadieron paquetes ni modelos al inventario canónico (524). Assets continúan excluidos de nuevas incorporaciones a Git.

## Montañas ↔ Minas

El exterior `RPG/scenes/montanas.tscn`, sus recursos y su herramienta de construcción se conservan sin rediseño. Integración limitada a `RPG/scenes/mundo_montanas.tscn`:

| Sentido | Detector | Destino y aparición base |
|---|---|---|
| Montañas → Minas | `Region/SalidaMinas`, sobre `Montanas/Marcadores/ConexionMinasFutura` (45;20;−23,2), caja 3,5×5×5,4 | `res://scenes/mundo_minas.tscn`, ID `minas_montanas_sur`, `Minas/Marcadores/EntradaMontanas` (0;0,05;0), mirando arriba/−Z |
| Minas → Montañas | `Region/SalidaMontanas`, sobre `Minas/Marcadores/RetornoMontanas` (0;0;8), caja 4×3×1,5 | `res://scenes/mundo_montanas.tscn`, ID `montanas_minas_norte`, `Region/EntradaMinas` (45;20,05;−18), mirando abajo/+Z |

Gestor original, un único Autoload y fundidos de 0,35 s por sentido; añade 0,05 Y a cada aparición. La caja exterior alcanza el frente caminable antes de las rocas/fondo originales: no es necesario retirarlos. Los metadatos históricos `activa=false` del escenario exterior se conservan; la conexión se configura explícitamente en la envolvente. El retorno no solapa el detector. No cambian los destinos anteriores de Montañas/Aldea/Bosque/Ruinas/Campos.

Desde Aldea: salida este → llegada baja de Montañas → puente inferior → terraza del campamento → sendero oriental por (42;≈10;18), (48;≈16;−4), (54;≈21;−18) → frente del portal en (45;20;−18). Seguir al norte activa Minas. El regreso aparece frente al mismo portal, orientado hacia el exterior.

## Validación y reproducción

Desde la raíz del repositorio, con nombres nuevos para no sobrescribir evidencias:

```text
godot --headless --path RPG --fixed-fps 60 --log-file logs/fase_minas/<nuevo_recorrido>.log --script res://tests/validar_minas.gd
godot --path RPG --fixed-fps 60 --log-file logs/fase_minas/<nuevo_visual>.log --script res://tests/validar_minas.gd
godot --path RPG --fixed-fps 60 --log-file logs/fase_minas/<nuevo_regional>.log --script res://tests/validar_transicion_minas.gd
godot --headless --path RPG --fixed-fps 60 --log-file logs/fase_minas/<nueva_regresion>.log --script res://tests/validar_montanas.gd -- --fase-minas
```

Crear previamente `RPG/logs/fase_minas/`. Recorrido: tres cotas, ramales ida/vuelta, estanque bloqueado, cubeta real, superficies y paredes, pasarela y órbita mediante Input. Con ventana: siete posiciones × ocho ángulos, dos tiempos de agua y galería. La comparación de píxeles del agua se restringe a su proyección con cámara fija. Transiciones: cinco circuitos Montañas ↔ Minas más llegada y retorno desde/hasta Aldea, doce cambios/negros, control, cámara, apariciones, solicitudes simultáneas y reposo sin bucles.

Resultados definitivos y rutas de evidencias en `RPG/docs/estado_proyecto.md`. La revisión técnica de capturas no sustituye la aprobación artística ni un recorrido manual del usuario por cada rincón. El recorte puede mostrar discontinuidades de roca en sus bordes; no se garantiza ausencia de oclusión de toda utilería desde cualquier posición.
