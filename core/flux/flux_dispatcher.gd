extends Node
class_name FluxDispatcher
## Dispatcher Flux: el "cartero" que enruta cada acción a su store.
##
## Su único trabajo: recibir una acción y pasársela al store para que la
## procese con reduce(). No toma decisiones ni mira el payload: es un punto
## de paso. Si mañana hubiera varios stores, aquí se decidiría a cuál va
## cada acción — por eso existe como eslabón separado de la cadena.

# Precarga del script Store usada como tipo de la referencia exportada.
const FluxStoreScript := preload("res://core/flux/flux_store.gd")
# Precarga del script Acción: así tipamos el parámetro sin depender de la
# caché de class_name (patrón "funciona a la primera en CLI" de la plantilla).
const FluxActionScript := preload("res://core/flux/flux_action.gd")

# El store al que van a parar todas las acciones. Se asigna en la escena
# (o en el cableado del script que la usa).
@export var store: FluxStoreScript

## Entrega la acción (con su payload) al store: el store decide cómo
## reducir el estado. El dispatcher no sabe qué significa la acción.
func dispatch(action: FluxActionScript, payload: Dictionary) -> void:
	store.reduce(action, payload)