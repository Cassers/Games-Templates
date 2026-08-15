extends Node2D
## Escena principal del shooter: sala + jugador + HUD.
##
## El jugador necesita saber QUÉ escena instanciar cuando dispara:
## la bala (bullet.tscn) se le asigna en el editor como recurso exportado
## (bullet_scene), no hardcodeada en el código. Así puedes crear una bala
## nueva (láser, bola de fuego...) y cambiarla sin tocar GDScript.

# Patrón "preload type": el script del HUD se precarga como TIPO para
# llamar a show_message() con verificación estática, incluso sin la caché
# de class_name del editor (funciona a la primera, también en CLI).
const HudScript := preload("res://scenes/hud/hud.gd")

@onready var hud: HudScript = %HUD

func _ready() -> void:
	# Reinicia puntaje y vidas al arrancar.
	GameManager.reset()
	hud.show_message("¡Apunta con el ratón y haz clic para disparar!")

func _unhandled_input(event: InputEvent) -> void:
	# Comodidad de clase: reiniciar la partida con la tecla R.
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		get_tree().reload_current_scene()