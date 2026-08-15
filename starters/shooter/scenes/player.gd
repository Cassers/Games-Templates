extends CharacterBody2D
## Jugador Shooter 2D: movimiento top-down + apuntar con el ratón + disparar.
##
## Conceptos nuevos respecto al top-down:
## - get_global_mouse_position(): posición del ratón en coordenadas del mundo.
## - La dirección de disparo ES la normalización de (raton - jugador).
## - "Apunta" visualmente rotando la visual del jugador hacia el ratón.
## - Disparo con COOLDOWN (enfriamiento): evita disparar 60 veces por segundo
##   manteniendo un temporizador que impide usar la acción hasta que pasa.

## Velocidad de movimiento en píxeles por segundo.
@export var speed: float = 280.0
## Segundos que hay que esperar entre disparo y disparo.
@export var shoot_cooldown: float = 0.25

# Escena de la bala que instanciamos al disparar (asignada en el editor).
@export var bullet_scene: PackedScene

# Temporizador de enfriamiento: > 0 significa "no puedo disparar todavía".
var _cooldown_left: float = 0.0

@onready var muzzle: Marker2D = %Muzzle

func _physics_process(delta: float) -> void:
	# --- 1) Movimiento top-down (igual que el género top-down) ---
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()

	# --- 2) Enfriamiento: cuenta hacia abajo hasta 0 ---
	if _cooldown_left > 0.0:
		_cooldown_left -= delta

	# --- 3) Apuntar: rotamos el cuerpo hacia el ratón ---
	# atan2 calcula el ángulo entre el jugador y el ratón; rotation es un
	# ángulo en radianes (la visual apunta "hacia arriba" por defecto, así
	# que sumamos PI/2 para que la punta quede en la dirección +90°).
	var angle_to_mouse := global_position.angle_to_point(get_global_mouse_position())
	rotation = angle_to_mouse + PI / 2.0

	# --- 4) Disparar ---
	if Input.is_action_pressed("shoot") and _cooldown_left <= 0.0:
		_shoot()
		_cooldown_left = shoot_cooldown

## Instancia una bala en la punta del cañón (Marker2D "Muzzle").
func _shoot() -> void:
	# "Instanciar" = crear una copia de la escena bullet.tscn dentro del mundo.
	var bullet := bullet_scene.instantiate() as Area2D

	# La bala nace en la posición global del cañón y hereda nuestra rotación.
	bullet.global_position = muzzle.global_position
	bullet.rotation = rotation

	# La añadimos al árbol de escenas (sin padre específico: la raíz actual).
	get_tree().current_scene.add_child(bullet)