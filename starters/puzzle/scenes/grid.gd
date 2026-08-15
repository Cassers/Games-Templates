extends Node2D
## Tablero 3x3 en estilo Flux: la UI dibuja, el STORE decide.
##
## En la versión clásica, este script guardaba el estado (_active_cells)
## y emitía `win`. Ahora el estado vive en PuzzleStore: grid.gd solo...
##
##   1. DIBUJA las celdas (la apariencia no es estado de Flux).
##   2. Ante un clic, PIDE el cambio al store con una acción Flux
##      (action.execute) — nunca muta el estado por su cuenta.
##   3. Se SUSCRIBE a state_changed: cuando el store cambia algo, esta
##      escena se entera sola y repinta. Nadie le avisa manualmente.
##
## Regla de oro que enseña: la UI no es dueña del estado, es una OBSERVADORA.

# Crono del trio Flux, con el patrón `preload` de la plantilla (funciona a
# la primera en CLI, sin depender de la caché de class_name del editor).
const FluxActionScript := preload("res://core/flux/flux_action.gd")
const FluxDispatcherScript := preload("res://core/flux/flux_dispatcher.gd")
const FluxStoreScript := preload("res://core/flux/flux_store.gd")

# Tamaño en píxeles de cada celda cuadrada.
const CELL_SIZE: int = 64

# El store (instancia .tres del PuzzleStore): el estado del juego vive aquí.
# Se asigna en el editor de grid.tscn.
@export var puzzle_store: FluxStoreScript

# Los nodos del trio que cableamos en _ready (definidos en grid.tscn).
@onready var action: FluxActionScript = %PuzzleAction
@onready var reset_action: FluxActionScript = %ResetAction
@onready var dispatcher: FluxDispatcherScript = %PuzzleDispatcher

# Visuales de las celdas, por índice. SOLO apariencia: el estado real
# (activa/apagada) lo decide el store, no este arreglo.
var _cell_visuals: Array = []

func _ready() -> void:
	# --- Cableado Flux (se hace UNA vez, aquí) ---
	# Unimos los tres eslabones: acción -> dispatcher -> store.
	dispatcher.store = puzzle_store
	action.dispatcher = dispatcher
	reset_action.dispatcher = dispatcher

	# La UI se suscribe al estado: cada cambio la repinta sola.
	puzzle_store.state_changed.connect(_on_state_changed)

	# Construimos las celdas y las pintamos con el estado inicial.
	_build_grid(_grid_size())
	_apply_state(puzzle_store.state)

## El tamaño de la rejilla lo define el STORE (su constante GRID_SIZE).
## Aquí lo derivamos del estado para no duplicar la constante.
func _grid_size() -> int:
	var cell_count: int = (puzzle_store.state["cells"] as Array).size()
	return int(sqrt(cell_count))

## Construye toda la rejilla en un bucle simple, celda por índice.
func _build_grid(grid_size: int) -> void:
	for i in grid_size * grid_size:
		_create_cell(i, grid_size)

## Crea UNA celda (zona de clic + visual), centrada en el tablero.
func _create_cell(index: int, grid_size: int) -> void:
	# --- Zona de clic: Area2D con su forma rectangular ---
	var cell := Area2D.new()
	var shape := CollisionShape2D.new()
	var rect_shape := RectangleShape2D.new()
	rect_shape.size = Vector2(CELL_SIZE, CELL_SIZE)
	shape.shape = rect_shape
	cell.add_child(shape)

	# --- Visual: ColorRect del mismo tamaño ---
	var visual := ColorRect.new()
	visual.size = Vector2(CELL_SIZE, CELL_SIZE)
	visual.position = -visual.size / 2.0
	visual.color = Color(0.25, 0.25, 0.3)
	cell.add_child(visual)

	# Posición de la celda: rejilla centrada en el origen.
	var x: int = index % grid_size
	var y: int = index / grid_size
	cell.position = Vector2(
		(x - (grid_size - 1) / 2.0) * CELL_SIZE,
		(y - (grid_size - 1) / 2.0) * CELL_SIZE
	)

	# La celda recuerda su índice (para la acción) y su visual (para pintar).
	cell.set_meta("index", index)
	cell.input_event.connect(_on_cell_input_event.bind(cell))

	add_child(cell)
	_cell_visuals.append(visual)

## Se ejecuta con CADA evento de entrada sobre una celda (clic, hover...).
## Solo reaccionamos si es un clic izquierdo PRESIONADO.
func _on_cell_input_event(_viewport: Node, event: InputEvent, _shape_idx: int, cell: Area2D) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# NO tocamos el estado aquí: se lo PEDIMOS al store vía la acción Flux.
		# El store alternará la celda y nos lo devolverá por state_changed.
		action.execute({"cell_index": cell.get_meta("index")})

## Llega CADA cambio de estado del store: repintamos las celdas.
func _on_state_changed(new_state: Dictionary) -> void:
	_apply_state(new_state)

## Pinta cada celda según su estado (verde = activa, gris = apagada).
## La UI no decide NADA: solo refleja el estado que recibió.
func _apply_state(new_state: Dictionary) -> void:
	var cells: Array = new_state["cells"]
	for i in _cell_visuals.size():
		var visual: ColorRect = _cell_visuals[i]
		var active: bool = (cells[i] as Dictionary).get("active", false) as bool
		visual.color = Color(0.25, 0.8, 0.35) if active else Color(0.25, 0.25, 0.3)