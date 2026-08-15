extends Node2D
## Escena principal del género Level Design: orquesta builder + Flux + UI.
##
## Nada de este archivo sabe CÓMO se ve un nivel concreto: main.gd es el
## "pegamento" entre piezas genéricas:
##
##   - LevelStore (Flux): el estado del progreso (nivel actual).
##   - LevelBuilder: construye el nivel que el store indique.
##   - HUD + botones: la UI, que solo OBSERVA y PIDE cambios con acciones.
##
## Flujo: el jugador toca la meta → LevelBuilder emite goal_reached →
## main.gd ejecuta la acción Flux "complete_level" → el store avanza de
## nivel y emite state_changed → main.gd reconstruye el nivel y reubica al
## jugador. Reiniciar es otra acción ("restart_level"), por la misma
## tubería: la señal viaja, el nivel se reconstruye en su sitio.

# Patrón "preload type" de la plantilla: funciona a la primera, incluso en CLI.
const HudScript := preload("res://scenes/hud/hud.gd")
const PlayerScript := preload("res://scenes/player.gd")
const LevelDataScript := preload("res://scripts/level_data.gd")
const LevelBuilderScript := preload("res://scripts/level_builder.gd")
const LevelStoreScript := preload("res://stores/level_store.gd")
const FluxActionScript := preload("res://core/flux/flux_action.gd")
const FluxDispatcherScript := preload("res://core/flux/flux_dispatcher.gd")

# El store (instancia .tres): el progreso de la campaña vive aquí.
# Se asigna en el editor de main.tscn (ExtResource).
@export var level_store: LevelStoreScript

# Referencias de la escena por %UniqueName (nada de rutas absolutas).
@onready var hud: HudScript = %HUD
@onready var player: PlayerScript = %Player
@onready var level_builder: LevelBuilderScript = %LevelBuilder
@onready var level_root: Node2D = %LevelRoot
@onready var complete_action: FluxActionScript = %CompleteLevelAction
@onready var restart_action: FluxActionScript = %RestartLevelAction
@onready var dispatcher: FluxDispatcherScript = %LevelDispatcher
@onready var next_button: Button = %NextButton
@onready var restart_button: Button = %RestartButton

# Nivel que el HUD muestra actualmente; sirve para detectar la transición
# "se completó uno" y premiar exactamente una vez por nivel. Empieza en 0
# (el nivel con el que arranca el store), no en -1, para que la PRIMERA
# victoria también premie.
var _current_level_shown: int = 0
# ¿La campaña ya se mostró terminada? Sirve para premiar el ÚLTIMO nivel
# exactamente una vez (al completarlo, el store no avanza current_level:
# deja el índice en el último nivel y marca finished).
var _was_finished: bool = false
# Guardia anti doble activación de la meta (dos cuerpos en el mismo frame).
var _handling_goal: bool = false

func _ready() -> void:
	GameManager.reset()

	# --- Cableado Flux (se hace UNA vez): acción -> dispatcher -> store ---
	dispatcher.store = level_store
	complete_action.dispatcher = dispatcher
	restart_action.dispatcher = dispatcher

	# El builder construye dentro de LevelRoot (un nodo vacío).
	level_builder.target_parent = level_root

	# Suscripciones: la escena REACCIONA, no pregunta.
	level_store.state_changed.connect(_on_state_changed)
	level_builder.goal_reached.connect(_on_goal_reached)
	next_button.pressed.connect(_on_next_pressed)
	restart_button.pressed.connect(_on_restart_pressed)

	# Cargamos el primer nivel (sin esperar ninguna señal).
	_rebuild_level()

## Construye el nivel actual del store, reubica al jugador y actualiza el
## HUD. Es la ÚNICA función que toca el builder: la usan el arranque, el
## avance de nivel y el reinicio.
func _rebuild_level() -> void:
	var level: LevelDataScript = level_store.latest_level()
	if level == null:
		hud.show_message("No hay niveles cargados (añádelos al LevelStore)")
		return

	level_builder.level_data = level
	level_builder.build()
	player.position = level.player_spawn

	# HUD: nivel actual + progreso de la campaña (el nombre permanece).
	var progress := "%d/%d" % [int(level_store.state["current_level"]) + 1, level_store.levels.size()]
	hud.message_label.text = "%s — %s" % [level.level_name, progress]

## Llega CADA cambio del store. Si la campaña terminó, mensaje final; si
## no, reconstruimos el nivel (que sea el mismo o el siguiente: el store
## ya decidió) y premiamos la transición exactamente una vez.
func _on_state_changed(_new_state: Dictionary) -> void:
	if _new_state["finished"]:
		# Completar el ÚLTIMO nivel también premia: el store no avanzó
		# current_level (se quedó en el último y marcó finished), así que
		# el premio se decide aquí, con la guardia de una sola vez.
		if not _was_finished:
			GameManager.add_score(100)
		_was_finished = true
		_current_level_shown = int(_new_state["current_level"])
		hud.show_message("¡Completaste todos los niveles!")
		return

	var current: int = int(_new_state["current_level"])
	# ¿Acabamos de completar un nivel? (current avanzó respecto a lo mostrado)
	if current > _current_level_shown:
		# Premio vía GameManager: emite score_changed y el HUD se actualiza solo.
		GameManager.add_score(100)
	_current_level_shown = current
	_rebuild_level()

## Meta alcanzada: pedimos el cambio al store con una ACCIÓN Flux.
## El guard evita dobles disparos (dos cuerpos entrando el mismo frame).
func _on_goal_reached() -> void:
	if _handling_goal:
		return
	_handling_goal = true
	complete_action.execute({})
	_handling_goal = false

## Botón "Siguiente nivel": también es una acción Flux. Si la campaña ya
## terminó, el store ignora (estado finished) — la señal igual llega y el
## HUD repite el mensaje final, para que se vea que el estado manda.
func _on_next_pressed() -> void:
	complete_action.execute({})

## Botón "Reiniciar nivel": acción Flux "restart_level": el store solo
## notifica y main.gd reconstruye el MISMO nivel en su sitio.
func _on_restart_pressed() -> void:
	restart_action.execute({})