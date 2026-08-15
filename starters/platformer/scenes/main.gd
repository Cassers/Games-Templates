extends Node2D
## Escena principal del plataformero: junta nivel + jugador + HUD.
##
## Este script es el "pegamento" del juego: inicia la partida y usa el
## HUD para dar mensajes al jugador a través del GameManager (nunca
## tocando el HUD directamente desde el jugador).

# Patrón "preload type": el script del HUD se precarga como TIPO para
# llamar a show_message() con verificación estática, incluso sin la caché
# de class_name del editor (funciona a la primera, también en CLI).
const HudScript := preload("res://scenes/hud/hud.gd")

@onready var hud: HudScript = %HUD
@onready var player: CharacterBody2D = %Player

func _ready() -> void:
	# Reinicia puntaje y vidas al arrancar la escena.
	GameManager.reset()

	# Mensaje de bienvenida usando el HUD (método con temporizador).
	hud.show_message("¡Salta con ESPACIO!")

func _unhandled_input(event: InputEvent) -> void:
	# Comodidad de clase: reiniciar la partida con la tecla R.
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		get_tree().reload_current_scene()