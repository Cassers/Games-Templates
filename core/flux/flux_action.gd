extends Node
class_name FluxAction
## Acción Flux: representa UN intento de cambio sobre el estado del juego.
##
## La UI JAMÁS modifica el estado directamente. Cuando quiere un cambio
## (encender una celda, reiniciar, sumar oro...), ejecuta una acción:
##   accion.execute({"celda": 3})
## La acción se limita a entregarse (a sí misma + el payload) al dispatcher.
## No sabe QUÉ debe pasar ni quién lo hará: solo expresa la intención.
##
## NOTA (patrón de la plantilla): usamos `preload` como TIPO para que el
## proyecto funcione a la primera desde consola (CLI), sin necesidad de que
## el editor haya construido la caché de `class_name` todavía.

# Precarga del script Dispatcher usada como tipo de la referencia exportada.
const FluxDispatcherScript := preload("res://core/flux/flux_dispatcher.gd")

# A qué dispatcher entregamos la acción. Se asigna en la escena (o en el
# cableado del script que la usa).
@export var dispatcher: FluxDispatcherScript
# Nombre de la intención: el store lo usa en reduce() para saber QUÉ hacer
# ("toggle_cell", "reset"...). Mejor un nombre explícito que el nombre del nodo.
@export var action_name: String = ""

## Ejecuta la acción: entrega la intención + payload al dispatcher.
func execute(payload: Dictionary = {}) -> void:
	dispatcher.dispatch(self, payload)