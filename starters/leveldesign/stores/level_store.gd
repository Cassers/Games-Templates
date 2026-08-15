extends "res://core/flux/flux_store.gd"
class_name LevelStore
## LevelStore: el progreso entre niveles, con Flux.
##
## El estado (nivel actual, ¿terminó la campaña?) vive AQUÍ, como en todo
## store Flux. Cuando un nivel se completa, main.gd ejecuta la acción
## "complete_level"; este store avanza de nivel y emite state_changed;
## la UI y el LevelBuilder reaccionan solos. Nadie toca este estado fuera
## de reduce().
##
## Niveles COMO DATOS: la lista `levels` (array de LevelData) se rellena
## en el inspector de level_store.tres arrastrando los .tres de cada nivel.
## Añadir un nivel a la campaña = crear su .tres + añadirlo aquí. CERO
## código (¡esa es la idea del género!).
##
## Nota técnica (gotcha de Godot): _init() corre ANTES de que los @export
## se carguen desde el .tres, así que "levels.size()" aquí daría 0. Por eso
## el estado se mantiene mínimo y los consumidores leen `levels` directo.

# Precarga del script LevelData usada como tipo de la lista exportada.
const LevelDataScript := preload("res://scripts/level_data.gd")

# Los niveles de la campaña, en orden. Se rellena en el inspector de
# level_store.tres con los recursos level_XX.tres.
@export var levels: Array[LevelDataScript] = []

func _init() -> void:
	# Estado mínimo: solo el índice del nivel actual y si la campaña acabó.
	state = {
		"current_level": 0,
		"finished": false,
	}

## reduce(): cómo reacciona el store a cada acción. Todo el progreso
## entre niveles pasa por este `match` (y por este ÚNICO punto de mutación).
func reduce(action: FluxActionScript, payload: Dictionary) -> void:
	match action.action_name:
		"complete_level":
			_complete_level()
		"restart_level":
			# No cambia el estado: solo NOTIFICA. La señal state_changed es
			# el mensaje: quien la escuche (main.gd) reconstruye el nivel.
			_emit()
		_:
			error_occurred.emit("Acción desconocida: %s" % action.action_name)

## Avanza al siguiente nivel (o marca la campaña como terminada).
## El payload está vacío a propósito: el nivel actual lo sabe el store.
func _complete_level() -> void:
	if state["finished"]:
		# Ya está todo terminado: ignorar (evita avanzar en bucle).
		return
	var next: int = int(state["current_level"]) + 1
	if next >= levels.size():
		state["finished"] = true
	else:
		state["current_level"] = next
	_emit()

## Devuelve el LevelData del nivel actual (o null si no hay niveles).
## Atajo para que main.gd no repita la lectura del estado cada vez.
func latest_level() -> LevelDataScript:
	if levels.is_empty():
		return null
	return levels[int(state["current_level"])]

## Emite el estado nuevo hacia la UI (set_state es la ÚNICA vía de salida).
func _emit() -> void:
	set_state(state)