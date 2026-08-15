# Guía de clase — Plantilla Godot 2D

Guía para el docente: cómo usar esta plantilla en una clase, qué enseña
cada archivo, en qué orden introducir los temas y qué errores anticipar.

---

## 1. Preparación (5 min)

Checklist antes de clase:

- [ ] `godot --version` devuelve **4.7.x** en todos los equipos.
- [ ] Copiar la plantilla a cada equipo (o clonar del repo del curso).
- [ ] `chmod +x setup.sh` ejecutado (o lanzar con `bash setup.sh`).
- [ ] Un proyecto de prueba ya generado con `--genre platformer` para
      proyectarlo en clase y abrirlo con `godot -e`.
- [ ] Verificar que F5 (play) funciona y que ESPACIO salta.
- [ ] Si el aula usa Windows: instruir Git Bash o WSL para `setup.sh`.

## 2. Cómo usar la plantilla en clase

1. Cada estudiante copia/descarga la carpeta `Godot2D-Template`.
2. Ejecuta `./setup.sh` y elige género + nombre.
3. Abre el proyecto generado: `godot -e <nombre>` (el editor).
4. Presiona **F5** para ejecutar; **F6** ejecuta la escena actual.
5. Al finalizar, cada uno abre `docs/CLASE.md` (se copia al proyecto).

## 3. Mapa del template — qué archivo enseña qué concepto

| Archivo | Concepto | Cuándo enseñarlo |
|---------|----------|------------------|
| `autoloads/game_manager.gd` | Autoloads, estado global, **bus de señales** | Bloque 2 |
| `scenes/hud/hud.gd` + `hud.tscn` | UI que observa señales, `%UniqueName`, contenedores | Bloque 2 |
| `scenes/main.gd` / `main.tscn` | Composición de escenas, instanciado | Bloque 1 |
| `scenes/player.gd` / `player.tscn` | `CharacterBody2D`, `move_and_slide()`, InputMap | Bloque 1 |
| `project.godot` → `[input]` | **InputMap**: acciones y eventos | Bloque 1 |
| `project.godot` → `[display]` | Stretch `canvas_items` (pixel-perfect) | Bloque 1 |
| platformer `player.gd` | Coyote time, jump buffer, gravedad | Bloque 3 |
| topdown `player.gd` | Vectores, normalización, facing | Bloque 3 |
| shooter `player.gd` + `bullet.gd` | `get_global_mouse_position()`, instanciar escenas, cooldown | Bloque 4 |
| roguelike `dungeon.gd` | Generación procedural, data-driven | Bloque 4 |
| puzzle `grid.gd` | `input_event`, UI que observa el store (re-dibuja sin decidir) | Bloque 5-6 |
| puzzle `stores/puzzle_store.gd` | Store Flux: estado puro, `reduce()` como único mutador | Bloque 6 |
| `core/flux/flux_action.gd` | Acción = intención de cambio; `execute()` entrega al dispatcher | Bloque 6 |
| `core/flux/flux_dispatcher.gd` | Dispatcher = "cartero": enruta la acción al store | Bloque 6 |
| `core/flux/flux_store.gd` | Store = estado + reactividad (`state_changed`, `set_state`) | Bloque 6 |
| leveldesign `scripts/level_data.gd` | **Niveles como DATOS**: Resource con arrays exportados | Bloque 7 |
| leveldesign `scripts/level_builder.gd` | Constructor genérico: datos → nodos con colisión | Bloque 7 |
| leveldesign `levels/level_0X.tres` | Curva de dificultad visible en los datos | Bloque 7 |
| leveldesign `stores/level_store.gd` | Store Flux del progreso entre niveles | Bloque 7 |

## 4. Orden de temas sugerido (7 bloques)

**Bloque 1 — Primeras escenas (2-4 h)**
Genre: `generic`
- Conceptos: nodos y árbol de escena, `CharacterBody2D`, `move_and_slide()`,
  InputMap (ver y añadir una acción en Project Settings → Input Map),
  movimiento 8 direcciones. Stretch mode y por qué `canvas_items`.

**Bloque 2 — Estado y UI (2-3 h)**
Genre: `generic` o `puzzle`
- Conceptos: autoloads (Project Settings → Autoload), señales
  (`score_changed`), "call down, signal up": el HUD escucha y se actualiza
  solo. `%UniqueName` vs rutas absolutas. Contenedores: `MarginContainer` →
  `VBoxContainer`.

**Bloque 3 — Game feel (2-4 h)**
Genre: `platformer` y `topdown`
- Conceptos: gravedad y salto, **coyote time** y **jump buffer** (leer los
  comentarios del `player.gd` plataformero en clase), vectores normalizados
  y por qué la diagonal no debe ir más rápido.

**Bloque 4 — Instanciación y balas (2-3 h)**
Genre: `shooter` y `roguelike`
- Conceptos: instanciar escenas con `instantiate()` + `add_child()`,
  `Marker2D` como punto de spawn, cooldown con temporizador, generación
  procedural con bucles y listas de datos.

**Bloque 5 — Señales e interacción (2-3 h)**
Genre: `puzzle`
- Conceptos: señales propias (`signal win`), `input_event` en `Area2D`,
  constantes como punto de extensión (cambiar `GRID_SIZE`), desacoplamiento
  (el tablero no sabe quién escucha `win`).

**Bloque 6 — Arquitectura Flux: estado reactivo (2-3 h)**
Genre: `puzzle`
- Conceptos: el flujo Acción → Dispatcher → Store → señal → UI, el store
  como `Resource` (estado + `reduce()`), la UI que solo se SUSCRIBE,
  `set_state()` como único emisor, y cuándo usar Flux vs. cuándo NO.

### ¿Qué es Flux?

Flux es un patrón de arquitectura para el **estado** del juego: el estado
vive en un solo objeto (el **store**, un `Resource`) y nunca se modifica
desde la UI. Cuando algo quiere cambiar el estado, no lo muta directamente:
ejecuta una **acción** (`FluxAction.execute()`), el **dispatcher** la enruta
al store, y el store la procesa en `reduce()`. Al terminar emite
`state_changed` y toda la UI suscrita se actualiza sola. Una sola dirección,
cero acoplamiento.

```
       Acción (intención)           Dispatcher (cartero)            Store (estado)
  grid.gd: action.execute()  ──►  dispatcher.dispatch()  ──►  store.reduce()
                                                                   │
                                                                   ▼
   UI (grid.gd, main.gd)  ◄────  state_changed (señal)  ◄────  set_state()
          "me entero sola y repinto"
```

### El ejemplo del puzzle

En la versión clásica, `grid.gd` guardaba `_active_cells` y emitía `win`.
Ahora el estado (celdas, `active_count`, `won`) vive en `PuzzleStore`, un
`Resource` que ni siquiera está en el árbol de escena. `grid.gd` solo
DIBUJA las celdas y, ante un clic, ejecuta `action.execute({"cell_index": i})`
— no toca el estado. El store alterna la celda, recalcula y emite
`state_changed`; la UI (grid + main) reacciona repintando y mostrando el
mensaje. Reiniciar es otra acción (`reset`), por la misma tubería: el botón
"Reiniciar" del puzzle no reinicia nada por su cuenta, solo ejecuta la acción.

### ¿Por qué es poco código y reactivo?

- El estado tiene UN solo dueño: es imposible que dos scripts se pisen.
- La UI no pregunta, se SUSCRIBE (`state_changed.connect`): añadir un panel
  nuevo es conectar otra señal, no tocar la lógica.
- El store es un `Resource`: se puede probar sin escena ni árbol.
- `reduce()` es el único punto donde el estado cambia: fácil de auditar.

### ¿Cuándo usarlo y cuándo NO?

**SÍ — estado de juego**: puntajes, vidas, inventario, turnos, win/lose,
rondas, ajustes, dificultad, partidas... todo lo que "es" el juego y que
varias escenas necesitan compartir o reaccionar a él.

**NO — movimiento y game feel**: que el personaje salte no es estado de
Flux; eso sigue siendo `CharacterBody2D` en `_physics_process()`. Flux no
reemplaza la física, ni los temporizadores, ni la entrada: complementa el
estado. Regla simple: si cambia a 60 fps con la física, no es Flux; si es
un hecho del juego ("el jugador ganó", "tengo 3 monedas"), sí puede serlo.

### Ejercicios del Bloque 6

- Añade un contador de victorias al store (`"wins"` en el estado) que suba
  en cada victoria, y haz que el HUD lo muestre suscribiéndose a
  `state_changed`.
- Convierte `GRID_SIZE` en un `@export` del store y cámbialo desde el
  editor a 4: la UI se adapta sola (el tamaño ya no está duplicado).
- Crea un segundo store (p. ej. un inventario con acciones `add_item` /
  `remove_item`) y conéctalo a otra señal: observa que la UI nueva no
  necesita conocer a las demás.
- Haz que después de ganar, la victoria "enfríe" 3 segundos antes de poder
  volver a jugar (una acción nueva `lock` / `unlock`, o un temporizador en
  main.gd que ejecute la acción `reset`).

**Bloque 7 — Level Design: los niveles son datos (2-4 h)**
Genre: `leveldesign`
- Conceptos: separar DATOS del CÓDIGO, `Resource` como receta de nivel
  (`LevelData`), constructor genérico (`LevelBuilder`), curva de dificultad
  diseñada con números y Flux como estado del progreso (LevelStore).

### La idea central: datos ≠ código

Un nivel NO es una escena ni un script: es un paquete de DATOS (`LevelData`,
un `Resource`) que dice dónde está el jugador, dónde está la meta y qué
plataformas hay. El código, en cambio, es GENÉRICO: `LevelBuilder` se
escribe UNA vez y construye cualquier nivel que reciba. Cambiar el juego =
editar un `.tres` en el inspector; ampliar el juego = escribir más cosas
en el builder, sin tocar los niveles ya hechos.

```
   LevelData (datos)                 LevelBuilder (código)
   level_01.tres  ────────────►   build(): por cada entrada →
   level_02.tres                  StaticBody2D + forma + ColorRect
   level_03.tres                  + zona meta (Area2D verde)
```

### Cómo crear un nivel nuevo (paso a paso, CERO código)

1. Duplica `levels/level_01.tres` (archivo → Duplicate) y llámalo
   `level_04.tres`.
2. Ábrelo en el editor: rellena `Level Name`, `Player Spawn`,
   `Goal Position` y la lista `Platforms` (cada fila: `position` = centro,
   `size` = ancho/alto; los valores se pican o se arrastran).
3. Añádelo a la lista `levels` de `stores/level_store.tres` (inspector):
   arrastra `level_04.tres` ahí.
4. Pulsa F5: el nuevo nivel aparece al terminar el anterior. Sin escribir
   código. Ese es el punto: el level design es una TAREA DE DATOS.

### La curva de dificultad (calcular, no adivinar)

Los tres niveles de ejemplo muestran la progresión EN LOS DATOS:

- **Nivel 1 (Calentamiento)**: 4 plataformas; desniveles de 60 px, todo
  alcanzable con salto sencillo desde la plataforma anterior. Meta encima
  de la última plataforma.
- **Nivel 2 (Saltos)**: 5 plataformas; un gran hueco (~300 px) con una
  isla como escalón intermedio, y una escalera final de dos saltos encadenados
  (dos plataformas a 70 px una de la otra: subir, aterrizar y volver a saltar).
- **Nivel 3 (La torre)**: 7 plataformas; ascenso vertical de ~70 px por
  plataforma y dos saltos al límite (80 px, el máximo que el personaje puede
  subir). Plataformas más estrechas: cada aterrizaje exige puntería.

La regla para diseñar niveles justos (¡enséñala a los estudiantes!):
la altura máxima de un salto es `altura = vel² / (2 · gravedad)`.
Con el player del template (gravedad 980, salto −400):
`altura = 400² / (2·980) ≈ 81 px`. Es decir: **ningún desnivel de más de
~80 px es superable**, y subir 70 px ya es exigir casi todo el salto.
Horizontalmente, un salto en llano avanza `velocidad · tiempo_vuelo = 220 · (2·400/980) ≈ 180 px`;
cualquier hueco mayor necesita escalones intermedios. Con estas dos cuentas
se diseña una campaña entera sin abrir el editor más de lo necesario.

### Conexión con Flux

El progreso entre niveles es estado → vive en `LevelStore` (un FluxStore).
Completar un nivel = acción `complete_level` → el store avanza
`current_level` (o marca `finished`) → `state_changed` → `main.gd` y el
builder reaccionan solos (nivel nuevo, jugador en el spawn, HUD al día).
Reiniciar es otra acción (`restart_level`) que solo notifica: la UI pide,
el store decide, el mundo obedece. El puzzle enseñó Flux con un estado de
tablero; aquí Flux sostiene la CAMPAÑA.

### Ejercicios del Bloque 7

- Crea el nivel 4 copiando `level_03.tres` y hazlo MÁS FÁCIL (escalones de
  70 px en vez de 80, plataformas anchas) y luego una variante MÁS DIFÍCIL
  (desnivel de 100 px es imposible... ¿puedes hacerlo posible con un
  "trampolín"? Pista: el salto solo depende de `jump_velocity`).
- Desafío: que el builder coloree las plataformas por TAMAÑO (pequeñas =
  peligrosas, en rojo). Es la prueba de que el builder puede decidir cosas
  nuevas SIN tocar los niveles.
- Añade un contador de intentos al LevelStore: cuenta cuántas veces llega
  la acción `restart_level` y muéstralo en el HUD (suscríbete a
  `state_changed` y lee el nuevo campo — el store merece un estado más rico).
- Añade un botón "Siguiente nivel" junto a... ya existe; ahora haz que la
  meta solo premie si el jugador llega SIN reiniciar (estado de Flux puro:
  `attempts` en el store, premio proporcional).

> Para diseñar una campaña completa sin escribir niveles a mano, el agente
> **level-designer** de Metis (planes `ME/AGENTS/`) genera niveles como
> datos usando exactamente esta estructura (LevelData + .tres).

## 5. Ejercicios por género

- **Plataformero**: añade una segunda vida de salto (doble salto);
  inventa una plataforma móvil (un `StaticBody2D` → `AnimationPlayer` no
  existe en el template: usa `_process` moviendo la posición y llama
  `move_and_slide` del jugador — o mejor, cambia la plataforma a
  `AnimatableBody2D` y muévela en `_physics_process`).
- **Top-down**: haz que el jugador no pueda salir de la sala
  (ya lo hacen las paredes); añade una puerta que al tocarla
  (`body_entered`) sume puntos con `GameManager.add_score(50)`.
- **Shooter**: crea un enemigo `StaticBody2D` con `Area2D` en la capa
  "enemies", y haz que la bala lo detecte: pon `collision_mask = 3` en
  `bullet.tscn` y usa la señal `body_entered` para destruir ambos.
- **Roguelike**: sigue el bloque "CÓMO EXTENDER" del `dungeon.gd`:
  segunda sala, generador con `randi() % N` y spawn del jugador aleatorio.
- **Puzzle**: cambia `GRID_SIZE` a 4 (en `stores/puzzle_store.gd`); el botón
  "Reiniciar" ya existe — ahora haz que ganar requiera encender una cruz
  (fila + columna completas). Si te atreves, pasa el cierre de la victoria
  al bloque 6.

## 6. Errores comunes de estudiantes

| Síntoma | Causa típica | Solución |
|---------|--------------|----------|
| "No se mueve" | La acción del InputMap con otro nombre, o `velocity` sin `move_and_slide()` | Revisar `project.godot → [input]` y el orden de `_physics_process` |
| El jugador atraviesa el suelo | La `CollisionShape2D` sin forma asignada, o la capa/máscara en 0 | Revisar `collision_layer`/`collision_mask` del `CharacterBody2D` |
| La bala no aparece | `bullet_scene` sin asignar en el editor | Asignar `bullet.tscn` en el inspector de `Player` |
| El HUD no muestra puntos | La conexión a la señal hecha antes de que exista el nodo | Conectar en `_ready()` después de `@onready`; ver `hud.gd` |
| El clic no activa celdas | Falta el `CollisionShape2D` en el `Area2D` | Las celdas del puzzle las crea el código: revisar `_create_cell()` |
| "Parse Error" al abrir | Editor del aula con Godot < 4.7 | Actualizar o chequear `config/features=PackedStringArray("4.7", ...)` |
| El color no cambia con el facing | Comparación de vectores sin `normalized()` | Ver `topdown/player.gd`: comparar tras normalizar |

## 7. Referencia rápida GDScript 2.0

```gdscript
# Tipado estricto: toda variable y parámetro declara su tipo.
var vidas: int = 3
var direccion: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")

# @export: valores visibles/ajustables en el inspector del editor.
@export var speed: float = 300.0

# Señales: declarar, emitir y conectar.
signal win
win.emit()
%Grid.win.connect(_on_grid_win)

# Contexto (call down): los padres llaman métodos de los hijos.
func _on_grid_win() -> void:
	GameManager.add_score(100)   # el autoload se usa por nombre

# Nada de rutas absolutas: %NombreÚnico o @export var nodo: Node.
@onready var hud: Control = %HUD

# Flux en una frase: acción → dispatcher → store → señal → UI.
action.execute({"cell_index": i})      # la UI PIDE el cambio (no lo hace)
puzzle_store.state_changed.connect(f)  # la UI se SUSCRIBE al resultado
func reduce(action, payload): ...      # el ÚNICO lugar donde muta el estado
```

Reglas de oro repetidas en toda la plantilla:

1. **Llamar hacia abajo, señalar hacia arriba** (call down, signal up).
2. **La UI nunca modifica el estado del juego**; solo observa señales.
3. **Nada de rutas absolutas** (`$../../HUD/...`): `%UniqueName` o `@export`.
4. **Composición sobre herencia profunda**: escenas pequeñas que se instancian.
5. **Datos como datos**: constantes y `@export` en vez de magia hardcodeada
   esparcida por el código.