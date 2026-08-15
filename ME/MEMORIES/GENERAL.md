# MEMORIES/GENERAL.md

Mi ventana de contexto es limitada: debo optimizar y dividir la información entre esta memoria general y las memorias específicas.

En esta memoria SOLO guardo información que siempre deba estar disponible; debo ser muy selectivo.

_Inicialmente es una semilla de la plantilla que se irá curando con la práctica. Estas memorias guían al orquestador, cuyo rol y contexto de desarrollo de juegos están en IDENTITY.md. Cualquier cambio a las reglas del proyecto se propaga a CLAUDE.md, AGENTS.md y GEMINI.md de forma simultánea._

## Memorias

- **Orquestación**: ante una tarea, entender → mapear al dominio del juego → decidir → delegar al agente/skill correcto → revisar; no escribir todo a mano.
- **Físicas beatables**: un salto base alcanza ~80 px de altura (gravedad 980, salto -400) — umbral para diseñar niveles.
- **Niveles como datos**: los `.tres` de `LevelData` son la receta; `LevelBuilder` es código genérico que los construye. Cero código por nivel.
- **Estado en Stores Flux**: el estado vive en stores (Resources) y nadie lo muta fuera de `reduce()`; la UI solo observa `state_changed`.
- **Verificación**: antes de entregar, `timeout 30 godot --headless --path . --quit-after 5` → exit 0 sin `SCRIPT ERROR`.