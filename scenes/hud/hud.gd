extends CanvasLayer
## HUD (Heads Up Display): la capa de interfaz del juego.
##
## Regla de UI: LOS NODOS DE UI NUNCA MODIFICAN EL ESTADO DEL JUEGO.
## Solo OBSERVAN las señales del GameManager y actualizan sus etiquetas.
## Así el HUD se puede rediseñar o borrar sin tocar la lógica del juego.
##
## Nota: no usamos class_name aquí a propósito. En su lugar, las escenas
## que lo necesitan precargan este script como tipo (ver main.gd: la
## constante HudScript). Así el proyecto funciona incluso la PRIMERA vez
## que se ejecuta desde consola, sin depender de la caché de clases globales
## que solo crea el editor al abrirse.

# Referencias a las etiquetas usando %UniqueName (nombres únicos del
# escenario). Nunca usamos rutas absolutas como $../../... — así el HUD
# se puede mover de sitio sin romperse.
@onready var score_label: Label = %ScoreLabel
@onready var lives_label: Label = %LivesLabel
@onready var message_label: Label = %MessageLabel

func _ready() -> void:
	# Nos suscribimos a las señales del autoload GameManager.
	# Cuando el puntaje/vidas/game over cambian, Godot llama a nuestro método.
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.game_over.connect(_on_game_over)

	# Valores iniciales: leemos el estado actual del GameManager.
	score_label.text = "Puntaje: %d" % GameManager.score
	lives_label.text = "Vidas: %d" % GameManager.lives

func _on_score_changed(new_score: int) -> void:
	score_label.text = "Puntaje: %d" % new_score

func _on_lives_changed(new_lives: int) -> void:
	lives_label.text = "Vidas: %d" % new_lives

func _on_game_over() -> void:
	show_message("¡Fin del juego!")

## Muestra un mensaje temporal en el HUD (se borra solo tras 2 segundos).
func show_message(text: String) -> void:
	message_label.text = text
	# create_timer es un atajo: crea un temporizador de un solo uso.
	# "await" pausa esta función hasta que el temporizador termine.
	await get_tree().create_timer(2.0).timeout
	message_label.text = ""