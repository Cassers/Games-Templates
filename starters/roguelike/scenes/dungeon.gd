extends Node2D
## Generador procedural de mazmorra: una sala con paredes construidas en bucle.
##
## ¿Qué es "generación procedural"? Crear contenido con CÓDIGO en vez de
## dibujarlo a mano en el editor. Aquí construimos una sola sala: el suelo
## es un ColorRect y las 4 paredes se crean en un bucle for sobre una lista
## de datos (posiciones y tamaños). Cambiar un número genera un mundo nuevo.
##
## CÓMO EXTENDER (ejercicios de clase):
## 1. Lista de salas: en vez de una sala, ten `var salas: Array[Rect2]` y
##    recórrela llamando a _build_room() por cada una. Cada sala queda en
##    (position + tamaño) — con eso ya tienes varias habitaciones.
## 2. Puertas/corredores: entre salas adyacentes, deja un hueco en la pared
##    (construye la pared en 2 trozos separados por un ancho de puerta).
## 3. Spawn de enemigos: tras construir la sala, instancia enemigos en
##    posiciones aleatorias con randf_range() dentro de los límites.
## 4. Suelo con baldosas: en vez de un ColorRect grande, instancia N
##    ColorRect de 32x32 en un doble bucle for (filas y columnas).

# Dimensiones internas de la sala (sin contar el grosor de las paredes).
@export var room_size: Vector2 = Vector2(800, 480)
# Grosor de las paredes.
@export var wall_thickness: float = 32.0

func _ready() -> void:
	_build_room()

## Construye el suelo + las 4 paredes de una sala centrada en el origen.
func _build_room() -> void:
	_build_floor()
	_build_walls()

## Suelo: un único ColorRect del tamaño interior de la sala.
func _build_floor() -> void:
	var floor_rect := ColorRect.new()
	var floor_size := room_size
	floor_rect.size = floor_size
	floor_rect.position = -floor_size / 2.0
	floor_rect.color = Color(0.13, 0.13, 0.17)
	add_child(floor_rect)

## Paredes: datos de cada pared (posición y tamaño) en una lista.
## El bucle for aplica el mismo proceso a cada una: crea el cuerpo estático
## (StaticBody2D), le añade su forma de colisión (RectangleShape2D) y su
## visual (ColorRect). Sin repetir código 4 veces — a eso se llama ser
## "data-driven": los datos en una lista, el mismo código para todos.
func _build_walls() -> void:
	var half := room_size / 2.0
	var t := wall_thickness

	# Cada entrada: [posición central, tamaño (ancho, alto)].
	var wall_data: Array[Dictionary] = [
		{"position": Vector2(0, -half.y - t / 2.0), "size": Vector2(room_size.x + t * 2.0, t)},
		{"position": Vector2(0, half.y + t / 2.0), "size": Vector2(room_size.x + t * 2.0, t)},
		{"position": Vector2(-half.x - t / 2.0, 0), "size": Vector2(t, room_size.y + t * 2.0)},
		{"position": Vector2(half.x + t / 2.0, 0), "size": Vector2(t, room_size.y + t * 2.0)},
	]

	for wall in wall_data:
		var body := StaticBody2D.new()
		body.position = wall["position"]

		var shape := CollisionShape2D.new()
		var rect_shape := RectangleShape2D.new()
		rect_shape.size = wall["size"]
		shape.shape = rect_shape
		body.add_child(shape)

		var visual := ColorRect.new()
		visual.size = wall["size"]
		visual.position = -wall["size"] / 2.0
		visual.color = Color(0.4, 0.4, 0.5)
		body.add_child(visual)

		add_child(body)