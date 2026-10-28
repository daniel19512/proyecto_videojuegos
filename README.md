# RPG Medieval — Nombre por definir

> Un RPG medieval de simulación social, exploración y minijuegos, donde tus decisiones influyen en los personajes y en el mundo.

## 📖 Descripción

Este proyecto es un videojuego RPG 2D desarrollado en **GameMaker**, ambientado en un mundo medieval de fantasía.

A diferencia de los RPG tradicionales, el juego no se centra en el combate. Su propuesta consiste en explorar un mundo dinámico, realizar actividades, completar misiones, obtener recursos y establecer relaciones con sus habitantes.

Uno de los principales objetivos es implementar **NPCs semiautónomos impulsados por inteligencia artificial**, capaces de mantener conversaciones dinámicas, recordar acontecimientos y reaccionar a las decisiones del jugador.

## 🎮 Características planeadas

- **Exploración:** mundo medieval con pueblos, bosques, comercios y diferentes localizaciones.
- **Minijuegos:** actividades de pesca, agricultura, minería, cocina, artesanía y otras profesiones.
- **Sistema de misiones:** encargos y objetivos que pueden variar según las necesidades de los NPCs.
- **Inventario y recursos:** obtención, almacenamiento, intercambio y utilización de objetos.
- **NPCs con IA:** personajes con personalidades, recuerdos, relaciones y objetivos individuales.
- **Relaciones sociales:** las decisiones del jugador afectan la confianza y el comportamiento de los personajes.
- **Mundo dinámico:** rutinas, acontecimientos y cambios en el entorno.

Estas características representan la visión del proyecto y no necesariamente están implementadas todavía.

## 🧠 Sistema de inteligencia artificial

Se planea integrar un sistema de NPCs semiautónomos utilizando modelos de lenguaje (LLM).

Cada NPC podrá disponer de:

- Personalidad e identidad propias.
- Memoria persistente de acontecimientos importantes.
- Relaciones con el jugador y otros NPCs.
- Objetivos y necesidades individuales.
- Capacidad de proponer misiones y tomar decisiones dentro de las reglas del juego.

La lógica principal del videojuego será controlada por GameMaker, mientras que un servicio externo gestionará las interacciones con la IA y la memoria.

## 🛠️ Tecnologías

| Tecnología | Utilización |
|---|---|
| GameMaker LTS | Motor del videojuego |
| GML | Programación de la lógica del juego |
| Visual Studio Code | Entorno de desarrollo |
| Git y GitHub | Control de versiones y colaboración |
| Python / Node.js | Posible backend para IA |
| SQLite | Posible almacenamiento de memoria |

## 📂 Estructura del proyecto

La estructura podrá evolucionar durante el desarrollo.

```text
Repositorio/
├── ProyectoGameMaker/
│   ├── objects/
│   ├── sprites/
│   ├── rooms/
│   ├── scripts/
│   ├── options/
│   └── ProyectoGameMaker.yyp
├── .gitignore
└── README.md
```

## 🚀 Instalación y ejecución

1. Instalar una versión compatible de GameMaker LTS.
2. Clonar el repositorio:

   ```bash
   git clone https://github.com/USUARIO/REPOSITORIO.git
   ```

3. Abrir el archivo `.yyp` del proyecto en GameMaker.
4. Ejecutar el videojuego desde el IDE.

## 🤝 Desarrollo y colaboración

El código fuente se administra mediante Git y GitHub.

Para contribuir:

1. Descargar los últimos cambios con `git pull`.
2. Abrir el proyecto en GameMaker o VS Code.
3. Realizar y probar las modificaciones.
4. Guardar los archivos.
5. Registrar los cambios mediante `git commit`.
6. Subirlos con `git push`.

Se recomienda coordinar la edición de rooms y recursos compartidos para reducir conflictos.

## 📌 Estado del proyecto

**En desarrollo — Etapa inicial.**

Actualmente se está preparando la estructura del proyecto y definiendo los sistemas principales, los recursos gráficos y la arquitectura técnica.

## 📄 Licencia

Pendiente de definir. El contenido del repositorio no se considera automáticamente de libre uso por estar publicado en GitHub.

Los recursos de terceros deberán respetar sus respectivas licencias.
