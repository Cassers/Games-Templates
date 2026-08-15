extends Node2D
## Escena principal del puzzle en estilo Flux: observa el store y reacciona.
##
## main.gd NO modifica el estado del juego ni una sola vez. Solo hace dos
## cosas, ambas muy Flux:
##
##   - Se SUSCRIBE a state_changed del store: cuando el estado cambia
##     (p. ej. el tablero gana), el store lo avisa y aquí reaccionamos
##     (mensaje + premio + actualizar el HUD).
##   - Pide cambios con ACCIONES: el botón "Reiniciar" no reinicia nada
##     por su cuenta, ejecuta la acción Flux "reset" y el store decide.
##
## El premio sigue saliendo por GameManager (como en la versión clásica),
## pero ahora DISPARADO por la señal del store, no por una señal del tablero.

# Patrón "preload type" de la plantilla: funciona a la primera, incluso en CLI.
const HudScript := preload("res://scenes/hud/hud.gd")
const GridScript := preload("res://scenes/grid.gd")
const PuzzleStoreScript := preload("res://stores/puzzle_store.gd")

# El mismo .tres que usa el tablero: ambas escenas comparten el MISMO store
# (Godot cachea los Resources, así que aquí y en Grid es la misma instancia).
@export var puzzle_store: PuzzleStoreScript

@onready var hud: HudScript = %HUD
@onready var grid: GridScript = %Grid
@onready var reset_button: Button = %ResetButton

# Guardia anti doble premio: recordamos el estado anterior de la victoria.
var _was_won: bool = false

func _ready() -> void:
	# Reinicia puntaje y vidas al arrancar.
	GameManager.reset()

	# La UI se suscribe al store: se entera SOLA de cada cambio de estado.
	puzzle_store.state_changed.connect(_on_puzzle_state_changed)
	reset_button.pressed.connect(_on_reset_pressed)

	hud.show_message("Activa todas las celdas con clic")

## Llega cada cambio de estado: premiamos SOLO en la transición
## perdido -> ganado (guardia con _was_won, para no pagar dos veces).
func _on_puzzle_state_changed(new_state: Dictionary) -> void:
	var won: bool = new_state.get("won", false) as bool
	if won and not _was_won:
		# El premio sale por el GameManager: emite score_changed y el HUD
		# se actualiza solo — sin tocar el HUD.
		GameManager.add_score(100)
		hud.show_message("¡Ganaste! +100 puntos")
	_was_won = won

## El botón "Reiniciar" no reinicia nada por su cuenta: ejecuta la acción
## Flux "reset" y el store devuelve el estado a cero (y emite state_changed).
func _on_reset_pressed() -> void:
	grid.reset_action.execute({})