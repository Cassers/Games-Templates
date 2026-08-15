extends Area2D
## Bala del shooter: avanza en línea recta y se destruye sola.
##
## Una bala es un Area2D: un "detector" de zonas. Más adelante, cuando
## existan enemigos, bastará con asignar la máscara de colisión adecuada
## en la escena (collision_mask = 3, la capa "enemies") y usar la señal
## body_entered para saber cuándo le pega a alguien.

## Velocidad de la bala en píxeles por segundo.
@export var speed: float = 500.0
## Vida útil de la bala en segundos (evita balas infinitas).
@export var lifetime: float = 2.0

# Edad acumulada de la bala.
var _age: float = 0.0

func _physics_process(delta: float) -> void:
	# Aplicamos la velocidad manualmente (nada de física pesada aquí):
	# position += velocidad * tiempo. "up" de la bala está rotado según la
	# rotación que le dio el jugador al instanciarla, así que moverla en
	# dirección +Y local la hace ir hacia el ratón.
	position += Vector2.UP * speed * delta

	# Envejecemos la bala; al pasar su vida útil, se autodestruye.
	_age += delta
	if _age >= lifetime:
		queue_free()