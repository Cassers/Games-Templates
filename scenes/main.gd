extends Node2D
## Escena principal genérica (género "Genérico" / base).
##
## Hace de "pegamento": conecta las señales del GameManager con el HUD
## y arranca la partida. Cada género (platformer, topdown, ...) trae su
## propia versión de esta escena, pero con la misma idea.

# Patrón "preload type": precargamos el script del HUD como TIPO para poder
# llamar a show_message() con verificación estática, sin depender de la
# caché de class_name del editor (funciona a la primera, incluso en CLI).
const HudScript := preload("res://scenes/hud/hud.gd")

@onready var hud: HudScript = %HUD

func _ready() -> void:
	# Al iniciar, la partida empieza con el HUD en cero (o el valor que
	# el GameManager tenga configurado).
	GameManager.reset()

	# Conectamos el HUD a las señales del GameManager. Como el HUD ya se
	# conecta solo en su propio _ready(), aquí solo lo mostramos.
	hud.show_message("¡Usa las flechas o WASD para moverte!")