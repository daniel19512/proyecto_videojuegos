<p align="center">
  <img src="RPG/assets/branding/sapientIA.png" alt="Logotipo de SapientIA" width="172">
</p>

# SapientIA

SapientIA es un RPG de simulación de vida medieval desarrollado como proyecto académico. Combina escenarios tridimensionales low-poly, personajes pixel art en 2D y conversaciones opcionales con inteligencia artificial. Explora a tu ritmo, conoce a los aldeanos y aprende oficios en un mundo tranquilo, sin combate ni presión de supervivencia.

## Descargar SapientIA para Windows (64 bits)

**Versión oficial v1.0.0**

### Cómo jugar

1. Descarga el archivo ZIP.
2. Extrae todos los archivos en una carpeta.
3. Ejecuta `SapientIA.exe`.
4. ¡Disfruta de SapientIA!

No necesitas instalar Godot ni descargar el código fuente.

[Ver publicación oficial de SapientIA v1.0.0](https://github.com/daniel19512/proyecto_videojuegos/releases/tag/v1.0.0)

## Qué puedes hacer

- Recorre Aldea, Bosque, Campos y Granjas, Montañas, Minas y Ruinas. Entra en los edificios y usa tu vivienda para guardar objetos o descansar.
- Conoce a 21 personajes con perfiles y horarios propios. Observa sus desplazamientos, encuentros y visitas. Al conversar, hacer regalos y resolver encargos puedes desarrollar amistad y confianza.
- Sigue la historia principal opcional, acepta misiones predefinidas o recibe encargos generados por IA cuando está activa.
- Cultiva, pesca, mina, recolecta y comercia. Administra objetos en la mochila y en cofres y desbloquea recetas con la progresión de oficios. Los seis minijuegos cubren pesca, cerveza, pan, forja, carpintería y molienda.
- Elige entre ocho apariencias y guarda en cinco ranuras independientes. El mundo tiene ciclo de día y noche, música y sonido ambiental. El menú permite configurar vídeo, audio y controles.

## Controles predeterminados

| Acción | Teclado y ratón | Mando |
|---|---|---|
| Moverse | WASD o flechas | Stick izquierdo |
| Girar la cámara | Q/E | Stick derecho |
| Interactuar | F | A |
| Comerciar | T | X |
| Mochila | I | Y |
| Diario | J | Pulsar stick izquierdo |
| Mapa | M | Ver |
| Pausa | Esc | Menú |
| Barra rápida | [ / ], R | LB/RB, pulsar stick derecho |
| Navegar, aceptar y volver | Flechas, Enter, Esc o ratón | Cruceta o stick izquierdo, A y B |

## Arquitectura e IA

Godot 4.7.2 y GDScript organizan el juego en nodos, escenas reutilizables y módulos. El aldeano base encapsula interacción y presentación. Sus variantes extienden el comportamiento mediante herencia, y cada escena compone sprites, detección y colisiones. Las señales notifican acciones entre interfaces y sistemas. `GestorRegiones` abstrae las transiciones y elige los marcadores de llegada. Los autoloads `Partidas`, `EstadoMundo` e `Historia` conservan estado jugable, memoria y relaciones en `user://`.

`SimuladorNPC` aplica reglas locales de horarios, navegación y encuentros. Si activas IA en **Ajustes → IA** y guardas tu clave de OpenRouter, Godot envía solicitudes HTTP con JSON al modelo configurado. El contexto combina el perfil del personaje, la situación del mundo, recuerdos y relaciones. El cliente valida el esquema de la respuesta y el juego verifica los encargos propuestos antes de aplicarlos. Las reglas locales conservan el control de inventario, recompensas, desplazamientos y cambios de región. Ante una caída de red o sin clave, se usan rutinas y respuestas locales.

La clave se guarda en `user://ia.cfg`. Las partidas se guardan por separado en `user://partidas/`.

## Desarrollo

1. Clona el repositorio con `git clone https://github.com/daniel19512/proyecto_videojuegos.git`. Para editar, necesitas una copia autorizada de los recursos correspondientes a la revisión local de entrega. Git gestiona el código y GitHub aloja el proyecto. Esta entrega carece de objetos gestionados mediante Git LFS.
2. Abre `RPG/project.godot` en Godot 4.7.2 y ejecuta con F5. Puedes dejar OpenRouter desactivado.
3. Instala las plantillas de exportación de la misma versión y usa el perfil **Windows x64** en modo Release. Crea primero la carpeta de destino.

```powershell
New-Item -ItemType Directory -Force Distribucion/SapientIA_Windows_x64
godot --headless --path RPG --export-release "Windows x64"
```

```text
RPG/
  assets/   Recursos visuales, audio y fuentes
  data/     Perfiles, lugares, catálogos y misiones en JSON
  scenes/   Regiones, interiores, personajes e interfaces
  scripts/  Sistemas de juego y herramientas de edición
  tests/    Validaciones del proyecto
  docs/     Estado técnico y catálogo agrícola
  project.godot
  export_presets.cfg
Distribucion/   Entrega ejecutable local
```

## Autores

**Daniel Alejandro Berrio Restrepo**

**Samuel Castro Carmona**

Estudiantes de Ciencias de la Computación. Proyecto académico de 2026.

Consulta las atribuciones de modelos, sprites, iconos, fuentes, música y audio, así como las condiciones de redistribución. [Créditos y licencias](CREDITOS_Y_LICENCIAS.md) · [Documentación técnica](RPG/docs/estado_proyecto.md)
