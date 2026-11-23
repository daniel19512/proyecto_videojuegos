# Ciclo visual día/noche

El controlador `RPG/scripts/ciclo_dia_noche.gd` lee `Reloj.segundos`. El día dura 720 segundos y conserva sus cuatro franjas narrativas. La tarde visual corresponde al índice «mediodía» del reloj y el atardecer al índice «tarde». Aldeanos, diálogos e IA siguen recibiendo los nombres originales. La hora continúa entre escenas, se detiene con la pausa del árbol y se recupera mediante el guardado existente.

| Franja visual | Índice y nombre de Reloj | Luz direccional base | Relleno exterior | Altura |
|---|---|---|---|---|
| Mañana | 0 · mañana | Dorada suave · 0,92 | 0,77 | 36° |
| Tarde | 1 · mediodía | Neutra cálida · 1,30 | 0,85 | 64° |
| Atardecer | 2 · tarde | Naranja · 0,78 | 0,66 | 19° |
| Noche | 3 · noche | Azul lunar · 0,31 | 0,56 | 49° |

Cada franja tiene una meseta alrededor de su centro. Una interpolación suavizada de aproximadamente 101 segundos cruza cada límite, incluido el cambio de día. La transición combina energía, color, elevación, azimut, relleno ambiental y color de fondo. Cada exterior reutiliza su luz direccional y su entorno, con una copia independiente del recurso por escena. El controlador lee la hora cada 0,1 s y evita reenviar valores durante las mesetas.

## Regiones e interiores

- Aldea emplea la paleta base. Bosque reduce la intensidad y usa un matiz verdoso. Campos conserva una apariencia clara con factor 0,96. Montañas aplica un matiz frío y Ruinas un matiz violáceo y menor intensidad.
- Minas mantiene el entorno subterráneo y sus luces de trabajo. Solo cambia el aporte junto a la bocamina, que desaparece al llegar la noche.
- E01–E12 conservan su iluminación cálida. El aporte diurno al ambiente es pequeño y cae a cero de noche, de modo que quedan el relleno base y las luces locales. E12 tiene además una luz localizada junto a la ventana oeste que sigue el ciclo.
- El cielo se representa mediante el color de fondo existente. La transición solar/lunar comparte una misma dirección principal y los colores complementan los materiales y shaders que ya usa cada región.

## Ajustes y validación

Ajustar las cuatro entradas de las paletas al inicio de `RPG/scripts/ciclo_dia_noche.gd`. Editar `tono_region` e `intensidad_region` en el nodo `CicloDiaNoche` de una región exterior para variar su perfil. El ambiente que mantiene un interior de noche se configura en su recurso `Environment` y en las luces locales.

Ejecutar desde la raíz del repositorio, con un nombre de registro nuevo.

```text
godot --headless --path RPG --log-file logs/ciclo_dia_noche_nuevo.log --script res://tests/validar_ciclo_dia_noche.gd
godot --path RPG --resolution 1280x720 --log-file logs/ciclo_dia_noche_grafico_nuevo.log --script res://tests/validar_ciclo_dia_noche.gd
```

La prueba comprueba avance, franjas, interpolación, pausa, recuperación desde un archivo de prueba, transiciones por las seis regiones, entrada y salida nocturnas de E12, luces y transmisión. Con ventana captura el render real a horas controladas en Aldea, Bosque y Campos, comprueba luminosidad y genera una galería HTML con el molino. Las cifras de FPS del capturador dependen del equipo, la carga y el encuadre. No constituyen un benchmark de los mapas completos.

Cierre del 22 de noviembre de 2026 con Godot 4.7.2: 75 comprobaciones headless y 92 con ventana, todas aprobadas. En la captura real Forward+/D3D12 a 1280×720, la luminancia media aproximada de la muestra central bajó de 0,56 a 0,26 en Aldea, de 0,45 a 0,21 en Bosque y de 0,76 a 0,40 en Campos entre tarde y noche. Galería en `RPG/logs/e12_ciclo_2026-11-22T22-03-08_2414/galeria.html`.
