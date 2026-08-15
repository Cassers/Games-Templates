extends CharacterBody2D
## Jugador genérico con movimiento en 8 direcciones (WASD + flechas).
##
## Sirve como punto de partida para cualquier género: no tiene gravedad ni
## salto; solo se mueve en el plano XY usando las acciones del InputMap
## (move_left, move_right, move_up, move_down).

## Velocidad de movimiento en píxeles por segundo.
@export var speed: float = 300.0

func _physics_process(_delta: float) -> void:
	# 1) Leemos las acciones de teclado como un vector de dirección.
	#    Cada Input.get_axis devuelve -1, 0 o 1 por eje:
	#    - horizontal: derecha = +1, izquierda = -1
	#    - vertical:   abajo = +1, arriba = -1
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# 2) La velocidad es la dirección normalizada multiplicada por speed.
	#    Nota: pulsar dos direcciones opuestas a la vez da un vector de
	#    magnitud 0, por lo que el jugador se queda quieto.
	velocity = direction * speed

	# 3) move_and_slide() aplica la velocidad y resuelve colisiones contra
	#    los cuerpos estáticos del nivel (suelo, paredes, plataformas).
	move_and_slide()