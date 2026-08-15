extends "res://core/flux/flux_store.gd"
class_name PuzzleStore
## PuzzleStore: versión Flux del puzzle 3x3. ¡El ejemplo estrella!
##
## El estado del tablero vive AQUÍ (celdas, contador, victoria), NO en la
## UI. `grid.gd` solo dibuja y, cuando el jugador hace clic, ejecuta una
## acción; `main.gd` solo observa y reacciona. Ninguno toca el estado.
##
## Qué enseña este archivo:
##  - Un store es un Resource con `state` + `reduce()` + `set_state()`.
##  - `reduce()` es el ÚNICO lugar donde el estado cambia (regla de oro).
##  - El estado se comunica hacia afuera SOLO con la señal `state_changed`
##    (emitida por `set_state()`), y la UI se suscribe en vez de preguntar.
##  - `action_name` identifica la intención dentro del `match`.
##
## Para cambiar el tamaño del tablero: modifica GRID_SIZE aquí abajo y la
## UI se adapta sola (es el "punto de extensión" de este starter).

# Tamaño de la rejilla (N x N). Cambia este número y el tablero crece.
const GRID_SIZE: int = 3

func _init() -> void:
	# El estado arranca "limpio": todas las celdas apagadas, sin victoria.
	state = _fresh_state()

## Construye un estado inicial nuevo. Lo usan _init() y la acción "reset":
## reiniciar NO es crear un problema distinto, es volver al estado cero.
func _fresh_state() -> Dictionary:
	return {
		"cells": _create_cells(),
		"active_count": 0,
		"won": false,
	}

## Genera GRID_SIZE*GRID_SIZE celdas apagadas. Cada celda es un pequeño
## Dictionary con su propio estado: {"active": false}.
func _create_cells() -> Array:
	var cells: Array = []
	for i in GRID_SIZE * GRID_SIZE:
		cells.append({"active": false})
	return cells

## reduce(): cómo reacciona el store a cada acción que llega del dispatcher.
## Un `match` sobre action.action_name — limpio y fácil de ampliar:
## añadir una acción nueva = añadir un caso más aquí.
func reduce(action: FluxActionScript, payload: Dictionary) -> void:
	match action.action_name:
		"toggle_cell":
			_toggle_cell(payload)
		"reset":
			state = _fresh_state()
			_emit()
		_:
			# Acción desconocida: avisamos por señal, sin romper nada.
			error_occurred.emit("Acción desconocida: %s" % action.action_name)

## Alterna la celda cuyo índice viene en el payload, recalcula el contador
## y, si todas quedaron activas, marca la victoria. Al final, emite.
func _toggle_cell(payload: Dictionary) -> void:
	var index: int = payload.get("cell_index", -1) as int
	var total: int = GRID_SIZE * GRID_SIZE
	if index < 0 or index >= total:
		error_occurred.emit("Índice de celda fuera de rango: %d" % index)
		return

	# Mutación SOLO dentro de reduce(): invertimos el estado de la celda.
	var cells: Array = state["cells"]
	var cell: Dictionary = cells[index]
	cell["active"] = not cell["active"]

	# Recalculamos el contador desde cero (código simple y legible;
	# 9 celdas en un bucle no cuesta nada y es imposible que se desincronice).
	var count: int = 0
	for c: Dictionary in cells:
		if c["active"]:
			count += 1
	state["active_count"] = count
	state["won"] = count >= total

	_emit()

## Emite el estado nuevo hacia la UI. Nota didáctica: set_state() guarda
## `state` Y emite `state_changed` — la UI suscrita se entera sola.
func _emit() -> void:
	set_state(state)