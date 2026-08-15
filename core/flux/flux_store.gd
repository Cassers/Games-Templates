extends Resource
class_name FluxStore
## Store Flux: el ESTADO del juego + la reactividad.
##
## Es un Resource (no un nodo): no necesita estar en el árbol de escena,
## lo que lo hace fácil de compartir y de probar solo. Contiene:
##
##   - `state`:       el estado completo en un Dictionary (única fuente de verdad).
##   - `reduce()`:    el ÚNICO lugar donde el estado puede cambiar. Las
##                    subclases lo sobreescriben para reaccionar a acciones.
##   - `set_state()`: guarda el estado nuevo y EMITE `state_changed`.
##
## La UI se SUSCRIBE a `state_changed` y se entera sola de cada cambio:
## nadie le avisa manualmente, nadie tiene que "sincronizar" nada.

# Precarga del script Acción usada como tipo en la firma de reduce().
# (Patrón de la plantilla: preload en vez de class_name para que todo
# funcione a la primera desde consola, sin abrir el editor antes.)
const FluxActionScript := preload("res://core/flux/flux_action.gd")

# Señal de reactividad: se emite con el estado nuevo tras cada cambio.
# La UI conectada repinta/actualiza lo que necesite.
signal state_changed(new_state: Dictionary)
# Señal de error: reduce() la emite cuando una acción no se puede procesar
# (acción desconocida, índice fuera de rango...).
signal error_occurred(message: String)

# El estado del juego. Las subclases lo inicializan en _init().
var state: Dictionary = {}

## reduce(): cómo reacciona el store a una acción. Las subclases lo
## sobreescriben con un `match` sobre action.action_name.
## Regla de oro: NUNCA mutar `state` fuera de reduce().
func reduce(_action: FluxActionScript, _payload: Dictionary) -> void:
	pass

## set_state(): asigna el estado nuevo y emite state_changed con él.
## Es la ÚNICA vía por la que el estado "viaja" hacia la UI.
func set_state(new_state: Dictionary) -> void:
	state = new_state
	state_changed.emit(state)