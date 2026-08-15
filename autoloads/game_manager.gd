extends Node
## Autoload "GameManager": estado global del juego + bus de señales.
##
## Un autoload (singleton) es un nodo que Godot carga ANTES que cualquier
## escena y que está disponible desde cualquier parte del proyecto con su
## nombre: GameManager.add_score(10), GameManager.score, etc.
##
## ¿Por qué hacerlo así?
## - Evita guardar el puntaje en la escena del jugador (que se destruye).
## - Centraliza el estado del juego (puntaje, vidas) en UN solo lugar.
## - Hace de "bus de señales" (signal bus): las escenas se comunican a través
##   de señales emitidas aquí, sin conocerse entre ellas.
##
## Patrón "call down, signal up": cualquiera llama a métodos de este nodo,
## y este nodo avisa el cambio emitiendo una señal; la UI la recibe y se
## actualiza sola.

# Señales públicas: la UI (y cualquier otra escena) se conecta a ellas.
signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal game_over

## Vidas iniciales de cada partida. Se puede ajustar desde el editor.
@export var starting_lives: int = 3

# Estado global del juego.
var score: int = 0
var lives: int = 0

func _ready() -> void:
	# Al arrancar, inicializamos las vidas a partir del valor exportado.
	lives = starting_lives

## Suma puntos al puntaje global y avisa a todos los que estén escuchando.
func add_score(points: int) -> void:
	score += points
	score_changed.emit(score)

## Resta una vida. Si llega a 0, emite game_over.
func lose_life() -> void:
	lives -= 1
	lives_changed.emit(lives)
	if lives <= 0:
		game_over.emit()

## Reinicia la partida (puntaje en 0, vidas a su valor inicial).
func reset() -> void:
	score = 0
	lives = starting_lives
	score_changed.emit(score)
	lives_changed.emit(lives)