# Estado de SapientIA

SapientIA es la entrega académica de Daniel Alejandro Berrio Restrepo y Samuel Castro Carmona. La base jugable está completa. La publicación requiere confirmar los derechos de distribución y verificar la distribución pública del árbol editable y de la compilación.

## Arquitectura actual

| Área | Implementación |
|---|---|
| Arranque e interfaz | `RPG/scenes/presentacion/menu_principal.tscn`, `Ajustes`, `Partidas`, `AudioJuego`, mapa, HUD y tema compartido de Cinzel y Alegreya. |
| Mundo | Seis mundos regionales y doce interiores. `GestorRegiones` valida y aplica entradas por marcador. `CicloDiaNoche` mantiene el reloj. |
| Personajes | El protagonista usa `CharacterBody3D` y `AnimatedSprite3D`. `npc_aldeano.gd` se reutiliza por composición y herencia. Los perfiles y lugares se definen en `RPG/data/historia/`. |
| Simulación social | `SimuladorNPC` y `Historia` mantienen rutinas, visitas, interacciones, memoria y relaciones. `IA` y `DialogoIA` enriquecen las conversaciones mediante OpenRouter cuando se habilita. |
| Economía y misiones | `EstadoMundo`, inventario, tiendas, cofres, oficios, recursos y catálogos de `RPG/data/vida/`. Las misiones generativas pasan por validación local. |
| Guardado | Cinco ranuras `user://partidas/`, con temporales y copias de respaldo. Preferencias en `user://opciones.cfg`, clave opcional en `user://ia.cfg`. |
| Exportación | Perfil `Windows x64` en Release con Godot 4.7.2, icono oficial, EXE gráfico y PCK separado. Los JSON de runtime se incluyen explícitamente. |

## Juego y mantenimiento

La Aldea enlaza con Bosque, Campos y Granjas y Montañas. Bosque enlaza con Ruinas y Montañas con Minas. Doce interiores reutilizan el sistema de puertas y puntos de llegada. En la vivienda E06 se puede usar el cofre y descansar hasta las 06:00.

La población incluye 21 NPC con perfiles, rutinas, encuentros y relaciones de amistad y confianza. El simulador local conserva la autoridad sobre desplazamientos, recompensas y estado. OpenRouter amplía las conversaciones y propone encargos con JSON validado. El modo local funciona con la IA desactivada o sin conexión. La historia principal es opcional y convive con misiones predefinidas y encargos generativos.

La economía integra cultivo, pesca, minería, recolección, comercio, mochila y cofres. Hay seis minijuegos y progresión de oficios y recetas. El menú incluye ocho apariencias del protagonista, mapa, diario, ajustes de vídeo y audio, y reasignación de controles. WASD o flechas y stick izquierdo mueven al personaje. Q/E o stick derecho giran la cámara. F/A interactúa, T/X comercia, I/Y abre mochila, J o stick izquierdo abre diario, M/Ver abre mapa y Esc/Menú abre pausa.

Abre `RPG/project.godot` y ejecuta F5. Conserva el catálogo agrícola para las herramientas de autoría. Usa perfiles aislados en pruebas. Exporta con las plantillas 4.7.2 y el perfil `Windows x64` en Release. Mantén el EXE y el PCK juntos en `Distribucion/`. Los permisos para publicar se documentan en [Créditos y licencias](../../CREDITOS_Y_LICENCIAS.md). La revisión con mando físico y en otro equipo sigue pendiente.
## Validación de la entrega local

Godot 4.7.2 importó y exportó la revisión actual. Las rutas de las dos paletas de interiores coinciden en minúsculas con las que requieren los modelos. La validación de apariencias pasó 1.256 comprobaciones. Se cargaron 19 recursos de interiores y transiciones, 77 de regiones, interfaz y audio, y se verificaron las 49 rutas del catálogo agrícola.

El ejecutable Release arrancó fuera del proyecto con Direct3D 12 y cerró con código 0. El aviso del almacén de certificados de Windows no impidió ese arranque. OpenRouter en línea y el recorrido interactivo de la compilación quedan pendientes. La generación del EXE y PCK es local. El árbol editable y el paquete jugable requieren confirmar los permisos de terceros antes de publicarse.
