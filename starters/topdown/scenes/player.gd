extends CharacterBody2D
## Jugador Top-down: movimiento en 8 direcciones + tinte visual por dirección.
##
## Además de moverse, el jugador "mira" hacia el último lado por el que se
## movió: guardamos la dirección y teñimos el rectángulo del jugador con un
## color distinto. Esto enseña el concepto de VECTOR NORMALIZADO:
## al dividir el vector de entrada entre su longitud (normalize()),
## mantenemos la MISMA DIRECCIÓN pero con magnitud 1, para que la velocidad
## diagonal no sea más rápida que la horizontal (¡diagonal de 1.41x!).

## Velocidad de movimiento en píxeles por segundo.
@export var speed: float = 300.0

# Última dirección de movimiento normalizada (Vector2.ZERO si está quieto).
var facing: Vector2 = Vector2.DOWN

# La referencia a la visual para poder cambiarle el color.
@onready var visual: ColorRect = %Visual

func _physics_process(_delta: float) -> void:
	# 1) Vector de entrada de las acciones del InputMap.
	var raw_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# 2) Si hay input, normalizamos y recordamos la dirección ("facing").
	if raw_input != Vector2.ZERO:
		facing = raw_input.normalized()

	# 3) Movimiento: dirección (ya normalizada) por velocidad.
	velocity = facing * speed
	move_and_slide()

	# 4) Tinte por dirección, para "ver" hacia dónde miramos:
	#    abajo = rojo, arriba = azul, derecha = verde, izquierda = amarillo.
	if facing == Vector2.DOWN:
		visual.color = Color(0.9, 0.3, 0.3)
	elif facing == Vector2.UP:
		visual.color = Color(0.3, 0.5, 0.9)
	elif facing == Vector2.RIGHT:
		visual.color = Color(0.3, 0.8, 0.4)
	elif facing == Vector2.LEFT:
		visual.color = Color(0.9, 0.8, 0.3)