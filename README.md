# Plantilla de clase Godot 2D

Plantilla de proyecto **Godot 4.7** (GDScript 2.0, GL Compatibility) pensada
para enseñar desarrollo de videojuegos 2D. Incluye arquitectura **Flux** para
el estado, **niveles como datos**, memoria **ME/** para la IA orquestadora y
**herramientas de assets** integradas para generar sprites, escenarios y
sonido sin depender de nada externo de pago.

## Estructura: una sola rama

El repo tiene UNA sola rama: `main`. Es la base genérica (jugador 8
direcciones + HUD) e integra el **núcleo transversal de level design**: los
niveles son datos (`.tres` + `LevelData` + `LevelBuilder` genérico +
`LevelStore` con Flux), listo para usarse en CUALQUIER género. El level
design no es un género: es una forma de trabajar heredada desde la base.

**No hay ramas por género ni generador por script.** El género se configura
**a demanda**: el asistente del proyecto (la IA de orquestación que vive en
`ME/`, ver sección "IA orquestadora") configura la base según lo que pida el
desarrollador — plataformero, top-down, shooter, roguelike, puzzle o level
design. Los starters de referencia de cada género se conservan en la
historia del repo (`1e8ed5a:starters/<genero>/`) y el asistente los aplica
cuando hace falta.

```bash
git clone https://github.com/Cassers/Games-Templates.git
```

## Requisitos

- **Godot 4.7** (probado con 4.7.1; binario oficial `godot` en PATH).
- **pnpm** (para restaurar las dependencias de las herramientas de assets).
- `ffprobe` opcional (verificación de WAV).

## Uso rápido

```bash
godot -e .                                  # abrir el editor
godot --path .                              # jugar
timeout 30 godot --headless --path . --quit-after 5   # smoke test (exit 0, sin SCRIPT ERROR)
```

## Herramientas de assets — `.tools/`

| Herramienta | Qué hace |
|---|---|
| **Pollinations MCP** | Sprites, escenarios y audio por IA (configurado en `opencode.json` con ruta relativa; funciona en cualquier clon) |
| **sfxr** | SFX 8-bit procedural al instante (`node .tools/sfxr/gen.js <tipo> <salida.wav>`) |
| **fetch-kenney.sh** | Descarga bancos CC0 de Kenney.nl (`bash .tools/fetch-kenney.sh <slug> <destino>`) |

`node_modules` NO se commitea. Tras clonar, restaurar dependencias:

```bash
cd .tools/pollinations-mcp && pnpm install
cd ../sfxr && pnpm install
```

Detalle completo y criterio de decisión: `docs/ASSETS.md`.

## Skills — `.opencode/skills/`

El repo trae sus skills de desarrollo (godot-4-architecture, godot-ui,
godot-gut-testing, godot-shader-lab). Se cargan automáticamente al abrir el
proyecto en opencode (config en `opencode.json`).

## IA orquestadora

Todos los proyectos generados incluyen un orquestador de IA documentado:
`CLAUDE.md`/`AGENTS.md`/`GEMINI.md` (idénticos entre sí) + la carpeta `ME/`
con su identidad, memorias e índice de habilidades, y un bootstrap de
configuración por proyecto. Ver la sección "El proyecto" de `CLAUDE.md`.

### Configurar el género con el asistente

Al abrir un clon con la IA, el asistente ejecuta su bootstrap (`ME/`) y luego
configura la base según lo que quiera el desarrollador:

1. **Cuenta qué quieres construir** (plataformero, top-down, shooter,
   roguelike, puzzle, level design…). No hay ramas ni scripts que elegir.
2. El asistente aplica el **starter de referencia** del género desde la
   historia del repo (`git show 1e8ed5a:starters/<genero>/…`), o construye
   las escenas equivalentes, y ajusta `project.godot` (nombre, tema, input).
3. Verifica con el smoke headless y te dice QUÉ / CÓMO / VERIFICACIÓN.

Ese es el flujo: la base es la misma para todos, y el género es una
configuración que la IA hace contigo, no una rama que clonas.

## Arquitectura (resumen)

- **Núcleo Flux** (`core/flux/`): Acción → Dispatcher → Store. El estado vive
  en stores (Resources) y se muta solo en `reduce()`; la UI se suscribe a
  señales.
- **GameManager** (autoload): puntaje, vidas y bus de señales.
- **Niveles como datos**: los niveles son `.tres` (receta de `LevelData`);
  `LevelBuilder` es código genérico que los construye.
- **HUD**: solo observa señales, nunca toca el estado.

Guía didáctica completa con ejercicios: `docs/CLASE.md`.

## Licencia de assets

- Bancos de Kenney.nl: **CC0** (uso libre, atribución opcional).
- Placeholders propios de la plantilla (`ColorRect` y primitivas): libres.