# SKILLS/INDEX.md

Índice de las habilidades de orquestación del proyecto: las skills que el orquestador usa al delegar y las propias que el proyecto vaya adquiriendo.

## Skills de juego del proyecto (en el repo)

Viajan CON el repo en `.opencode/skills/` (autocargadas por opencode vía
`opencode.json`) — self-contained para cualquier clonador:

| Skill | Cuándo se usa |
|-------|---------------|
| `godot-4-architecture` | Arquitectura del juego: componentes, FSM, Custom Resources |
| `godot-ui` | UI responsiva, themes, Containers, HUDs |
| `godot-gut-testing` | Pruebas GUT headless del proyecto |
| `godot-shader-lab` | Shaders 2D, CanvasItem, partículas |
| `level-designer` | Campañas y niveles como datos (.tres) — **NO viaja en el repo**: es un agente del hub de Metis (ver abajo) |

## Capacidades del entorno de Metis (sesiones de Sergio)

La orquestación en las sesiones de Sergio usa el hub de Metis: investigación
(`deep-research`), orquestación (`orchestrator`), creación de skills
(`skill-creator`/`skill-forge`), documentación del motor por versión (MCP
Context7), SDD y RDD — referenciadas en CLAUDE.md, sección "Skills del
orquestador". También el agente `level-designer` (niveles como datos) vive en
Metis y se invoca desde las sesiones de Sergio, no desde el clon. Estas
capacidades NO viajan en el repo; viven en el entorno del que las mantiene.

## Habilidades propias del proyecto

- [Assets IA] docs/ASSETS.md "herramientas gratuitas de assets para la IA orquestadora: Pollinations MCP, jsfxr, Kenney CC0 y opciones pesadas (freesound, sfx-gen, ComfyUI) activables bajo demanda"

Como mi ventana de contexto es limitada, divido el conocimiento: cada actividad repetible se documenta en una skill específica. Antes de una actividad nueva reviso si existe una habilidad: uso `find-skills` para buscar, y `skill-creator` para crear una si no encuentro (aunque ya sepa resolverla, siempre documento cómo).