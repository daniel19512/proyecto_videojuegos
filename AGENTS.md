# Mantenimiento de SapientIA

SapientIA es un RPG académico de simulación de vida medieval. Usa Godot 4.7.2, GDScript, Forward+/Direct3D 12 y Jolt. El mundo es 3D, los personajes son sprites pixel art y la cámara es ortográfica orbital.

## Trabajo y recursos

- Lee este archivo y `RPG/docs/estado_proyecto.md` al comenzar. Revisa Git antes de editar y conserva el trabajo existente. Consulta el código del módulo y `CREDITOS_Y_LICENCIAS.md` si cambias recursos.
- Usa `res://` para recursos y `user://` para datos de ejecución. Conserva rutas, UID, archivos de importación, dependencias de modelos y avisos legales. Comprueba referencias dinámicas, herramientas y pruebas antes de eliminar recursos.
- Mantén la rama actual. Los commits, pushes, reescrituras y publicaciones requieren autorización expresa. Deja fuera de Git los datos personales, claves, registros, cachés y `Distribucion/`.
- Actualiza el estado cuando cambie una funcionalidad o su validación y esta guía cuando cambien convenciones o arquitectura.

## Sistemas que debes preservar

- `scenes/presentacion/` y `scripts/presentacion/` contienen menú, ajustes, mapa, audio y Partidas. Preserva las cinco ranuras, la recuperación desde respaldo y la compatibilidad con teclado, ratón y mando.
- `scenes/mundo*.tscn`, `scenes/interiores/` y `scripts/gestor_regiones.gd` conectan regiones e interiores. Conserva las entradas por marcador, las colisiones y la validación del destino.
- `scripts/ia/`, `scripts/npc/` y `data/historia/` gestionan rutinas, diálogos, memoria y contexto. Conserva el modo local, la validación de respuestas y el límite de solicitudes. La clave opcional vive en `user://ia.cfg`. Usa perfiles aislados y simuladores en pruebas.
- `scripts/vida/` y `data/vida/` gestionan economía, inventario, oficios y misiones. Preserva los identificadores de catálogo y la compatibilidad de las partidas.
- Conserva el movimiento relativo a la cámara, el giro Q/E y stick derecho, F/A para interactuar y la navegación de interfaces por teclado, ratón y mando.

## Ejecutar, probar y exportar

Abre `RPG/project.godot` con Godot 4.7.2 y ejecuta F5. Crea `RPG/logs/` y usa nombres nuevos para los registros. Elige las pruebas pertinentes en `RPG/tests/`, como `validar_presentacion.gd`, `validar_apariencias.gd`, `validar_aldea.gd` o `validar_ia_capa1.gd`. Distingue las comprobaciones headless de las pruebas con ventana.

```text
godot --headless --path RPG --log-file logs/presentacion_nueva.log --script res://tests/validar_presentacion.gd
```

Instala las plantillas de la misma versión y crea la carpeta de destino. Ejecuta `godot --headless --path RPG --export-release "Windows x64"`. El perfil incluye los JSON de ejecución y genera EXE gráfico y PCK separado. Conserva ambos archivos juntos y verifica la ejecución fuera del editor. Antes de publicar, confirma los derechos del ejecutable y del árbol editable.