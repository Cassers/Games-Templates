# Herramientas de assets gratuitas (accesibles para la IA)

Guía para la IA orquestadora: cómo generar sprites, escenarios y sonidos para el
proyecto SIN depender de assets externos pagos. Stack base ya instalado +
opciones pesadas disponibles bajo demanda. Todo gratis.

## Cómo usa esto la orquestadora

- Necesidad de placeholder/arte rápido → stack base (Pollinations o Kenney).
- SFX retro instantáneo → jsfxr.
- Necesidad real de calidad/volumen que el stack base no cubre → evaluar las
  opciones pesadas (sección 4) y proponer su instalación ANTES, explicando el
  plan (regla del proyecto: explicar antes de tocar producción).
- Las herramientas VIVEN en `.tools/` del repo, pero `node_modules` NO se
  commitea: un clonador restaura las dependencias con `pnpm install` dentro de
  `.tools/pollinations-mcp` (y `.tools/sfxr`). El repo es la base para todos
  los géneros (no hay generador por script): el asistente del proyecto
  configura el género a demanda y las tools heredan tal cual.

## 1. Pollinations MCP — sprites, escenarios y audio (instalado)

| Campo | Valor |
|---|---|
| Paquete | `@pollinations/mcp` v2.4.0 (oficial, MIT) |
| Instalación | `.tools/pollinations-mcp/` (pnpm; `node_modules` restaurado con `pnpm install`) |
| Config | El repo trae su propio `opencode.json` (raíz) → `mcp.pollinations` con ruta RELATIVA: funciona tras clonar sin tocar configs globales. La config global del desarrollador sigue existiendo y la orquestadora la actualiza aparte |
| Uso | Herramientas MCP del servidor: generación de imágenes con `transparent: true` para sprites recortados, escenarios/backgrounds, audio |
| Costo | Gratis; anónimo con rate-limit; key `sk_` gratis en enter.pollinations.ai desbloquea todos los modelos (0 Pollen) |
| Notas | Nombre correcto: `@pollinations/mcp` (`@pollinations_ai/mcp` NO existe, 404) |

## 2. jsfxr — SFX 8-bit procedural (instalado)

- Comando: `node .tools/sfxr/gen.js <tipo> <salida.wav>`
- Tipos: `pickup|coin`, `laser|shoot`, `explosion|boom`, `powerup`, `hit|hurt`, `jump`, `blip|select`, `random`
- Verificado: WAV PCM16 44100 Hz mono válido.
- Cero descargas, CPU, instantáneo → ideal para prototipos y placeholders de sonido.

## 3. Kenney.nl — bancos CC0 (script instalado)

- Comando: `bash .tools/fetch-kenney.sh <slug> <destino>`
- Verificado: `ui-audio` → 52 archivos. Licencia CC0 (uso libre, atribución opcional).
- Slugs de ejemplo: `platformer-tiles-extended`, `game-icons`, `space-shooter-redux`, `jukebox-1` (música), `ui-audio`.
- Lista completa de packs: https://kenney.nl/assets (el slug es la parte final de la URL).

## 4. Opciones pesadas — RECOMENDACIONES (no instaladas; activar solo si la necesidad real lo justifica)

### 4.1 freesound.org — 600k+ SFX reales (API)

- MCP: `MuShan-bit/freesound-mcp` — herramientas `freesound_search` / `freesound_download`.
- Requiere: API key GRATIS en https://freesound.org/apiv2/apply (proceso manual del desarrollador).
- Config: MCP local con env `FREESOUND_API_KEY=<key>`.
- Uso: cuando se necesiten SFX reales licenciados (foley, ambientes, voces) que el stack base no cubre.
- El comando de instalación exacto no está verificado: investigar en el momento de instalar.

### 4.2 sfx-gen-mcp + Stable Audio Open 1.0 — audio generado local (GPU)

- MCP: `JimCline/sfx-gen-mcp` (alternativa de una sola herramienta: `CoreEpoch/mcp-soundfx`).
- Local text→SFX/ambience hasta 47 s, 44.1 kHz estéreo; corre en la RTX 4070 SUPER 12 GB (~8 GB fp16).
- Requiere: aceptar licencia gated en Hugging Face + `hf auth login`; instalación npm/pip. Puede exponer un servidor HTTP en el puerto 8756.
- Uso: cuando la generación local de audio sin costos por llamada valga la pena (SFX/ambientes recurrentes).

### 4.3 ComfyUI + MCP — calidad máxima local de sprites (GPU)

- MCP: `artokun/comfyui-mcp` (mantenido activamente); servidor: `pip install comfy-cli && comfy install --nvidia`; ~2-3 GB de modelos; UI/servidor en http://127.0.0.1:8188; luego MCP local con env `COMFYUI_URL=http://127.0.0.1:8188`.
- Nota: si el launcher pide `npx`, aplicar la regla de pnpm (binario instalado vía pnpm o necesidad documentada); la decisión la toma la orquestadora.
- Uso: cuando el proyecto requiera sprites/escenarios de calidad final (SDXL/Flux, ControlNet, LoRA) y no baste con Pollinations.

## 5. Criterio rápido de decisión

| Necesidad | Herramienta |
|---|---|
| Sprite/escenario rápido (placeholder o definitivo ligero) | Pollinations MCP |
| Sprites/tilesets/UI CC0 ya hechos | Kenney (`fetch-kenney.sh`) |
| SFX retro instantáneo | jsfxr |
| SFX reales licenciados | freesound-mcp (pedir key) |
| Audio generado local (SFX/ambientes 47 s) | sfx-gen-mcp |
| Calidad máxima local de sprites | ComfyUI + MCP |

## Verificación

- Pollinations: el servidor imprime `Pollinations MCP Server vX running on stdio / API: https://gen.pollinations.ai`.
- jsfxr: `ffprobe <salida.wav>` → `pcm_s16le`, `44100 Hz`, `mono`.
- Kenney: el script termina con `✓ Pack '<slug>' (CC0) → <destino> (N archivos)`.