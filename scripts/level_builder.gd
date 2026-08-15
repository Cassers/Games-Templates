extends Node2D
class_name LevelBuilder
## LevelBuilder: convierte LevelData en nodos visibles con colisión.
##
## Este script se escribe UNA sola vez y sirve para CUALQUIER nivel: solo
## lee la receta (level_data) y construye (build()) lo que dice. De aquí
## viene la magia del género: añadir niveles nuevos no toca ni una línea
## de este archivo.
##
## Qué construye por nivel:
##   - Una plataforma StaticBody2D por cada entrada de `platforms`
##     (colisión sólida + ColorRect como visual). Las plataformas alternan
##     dos grises para que en pantalla se VEA cada entrada de datos.
##   - Una zona meta (Area2D verde) en `goal_position`: cuando el jugador
##     la toca, se emite `goal_reached` y la escena principal reacciona.

const LevelDataScript := preload("res://scripts/level_data.gd")

# La receta del nivel que hay que construir. Se asigna desde main.gd.
@export var level_data: LevelDataScript
# Dónde se crean los nodos construidos (un Node2D vacío por nivel).
@export var target_parent: Node2D

# Señal de victoria de nivel: la emite la zona meta al tocar al jugador.
signal goal_reached

## Construye TODO el nivel a partir de level_data: borra lo anterior,
## crea las plataformas y la meta. Mismo código para cualquier nivel.
func build() -> void:
	_clear()
	for i in level_data.platforms.size():
		_create_platform(level_data.platforms[i], i)
	_create_goal()

## Borra la construcción anterior (al cambiar de nivel o reiniciar).
## queue_free() libera el nodo al final del frame, seguro incluso si lo
## llamamos justo cuando un nodo del nivel nos emitió una señal.
func _clear() -> void:
	for child in target_parent.get_children():
		child.queue_free()

## Crea UNA plataforma a partir de su entrada de datos:
## StaticBody2D (física) + CollisionShape2D (forma) + ColorRect (visual).
func _create_platform(platform: Dictionary, index: int) -> void:
	var body := StaticBody2D.new()
	body.position = platform["position"] as Vector2

	# Colisión: un rectángulo del tamaño del dato. Sin forma, un
	# StaticBody2D "no existe" para la física (error clásico de estudiantes).
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = platform["size"] as Vector2
	shape.shape = rect
	body.add_child(shape)

	# Visual: ColorRect del mismo tamaño, centrado en la posición.
	var visual := ColorRect.new()
	visual.size = rect.size
	visual.position = -visual.size / 2.0
	# Alternamos dos grises según el índice de la entrada: así cada
	# plataforma se distingue en pantalla y se ve como un dato propio.
	visual.color = Color(0.42, 0.42, 0.46) if index % 2 == 0 else Color(0.3, 0.3, 0.34)
	body.add_child(visual)

	target_parent.add_child(body)

## Crea la zona meta: un Area2D (detecta contacto SIN bloquear el paso).
## Capas: layer 0 (no ocupa espacio solido) y mask 2 (solo detecta al
## jugador, que está en la capa 2 en player.tscn).
func _create_goal() -> void:
	var goal := Area2D.new()
	goal.collision_layer = 0
	goal.collision_mask = 2
	goal.position = level_data.goal_position

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(48, 48)
	shape.shape = rect
	goal.add_child(shape)

	var visual := ColorRect.new()
	visual.size = rect.size
	visual.position = -visual.size / 2.0
	visual.color = Color(0.3, 0.9, 0.4)
	goal.add_child(visual)

	goal.body_entered.connect(_on_goal_body_entered)
	target_parent.add_child(goal)

## Algo entró en la meta: si es EL JUGADOR (por su grupo), nivel completado.
func _on_goal_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		goal_reached.emit()