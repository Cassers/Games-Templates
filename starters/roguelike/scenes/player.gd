extends CharacterBody2D
## Jugador roguelike: movimiento top-down de 8 direcciones.
##
## Misma física que el género top-down, pero reutilizando la norma de
## "composición": la mazmorra (dungeon) es un contenedor que genera sus
## propias paredes; el jugador solo se mueve y colisiona con lo que haya.

## Velocidad de movimiento en píxeles por segundo.
@export var speed: float = 300.0

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()