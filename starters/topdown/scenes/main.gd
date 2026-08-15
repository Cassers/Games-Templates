extends Node2D
## Escena principal top-down: sala + jugador + HUD.

# Patrón "preload type": el script del HUD se precarga como TIPO para
# llamar a show_message() con verificación estática, incluso sin la caché
# de class_name del editor (funciona a la primera, también en CLI).
const HudScript := preload("res://scenes/hud/hud.gd")

@onready var hud: HudScript = %HUD

func _ready() -> void:
	# Reinicia puntaje y vidas al arrancar.
	GameManager.reset()
	hud.show_message("Muévete con WASD o las flechas")

func _unhandled_input(event: InputEvent) -> void:
	# Comodidad de clase: reiniciar la partida con la tecla R.
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		get_tree().reload_current_scene()