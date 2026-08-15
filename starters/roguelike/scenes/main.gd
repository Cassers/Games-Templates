extends Node2D
## Escena principal del roguelike: mazmorra generada + jugador + HUD.

# Patrón "preload type": el script del HUD se precarga como TIPO para
# llamar a show_message() con verificación estática, incluso sin la caché
# de class_name del editor (funciona a la primera, también en CLI).
const HudScript := preload("res://scenes/hud/hud.gd")

@onready var hud: HudScript = %HUD

func _ready() -> void:
	# Reinicia puntaje y vidas al arrancar.
	GameManager.reset()
	hud.show_message("La mazmorra se generó con código")

	# Posición de aparición (spawn) del jugador: el centro de la sala.
	# La sala mide room_size (800x480) centrada en el origen, así que el
	# centro exacto es (0, 0) — el origen del mundo.
	%Player.position = Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	# Comodidad de clase: regenerar la mazmorra con R.
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		get_tree().reload_current_scene()