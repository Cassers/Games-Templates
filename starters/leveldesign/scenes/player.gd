extends CharacterBody2D
## Jugador Plataformero: salto con COYOTE TIME y JUMP BUFFER.
##
## Movimiento reutilizado del starter PLATAFORMERO: grav, salto, coyote y
## buffer son los mismos, con los mismos @export. En este género, el
## jugador es la pieza FIJA del motor: lo que cambia entre niveles es el
## DATO (LevelData), no el movimiento.
##
## Los dos "secretos" de un salto que se siente bien (game feel):
##
## 1) COYOTE TIME (tiempo de coyote): si el jugador se cae de una
##    plataforma, todavía puede saltar durante un breve instante
##    (_coyote_time segundos). Imita el "instinto" de no saltar al
##    borde exacto. Sin esto, el juego castiga milisegundos de error.
##
## 2) JUMP BUFFER (amortiguador de salto): si el jugador pulsa saltar
##    UN POCO antes de tocar el suelo, el salto queda "en cola" y se
##    ejecuta en cuanto aterriza. Sin esto, cada salto "temprano"
##    parecería un error del motor.
##
## Ambos son temporizadores: cuentan hacia abajo con delta y solo
## se disparan cuando están activos al mismo tiempo.

## Gravedad en píxeles por segundo al cuadrado.
@export var gravity: float = 980.0
## Velocidad vertical inicial del salto (negativa = hacia arriba).
@export var jump_velocity: float = -400.0
## Segundos de gracia para saltar después de dejar una plataforma.
@export var coyote_time: float = 0.15
## Segundos que un salto pulsado "temprano" queda en espera.
@export var jump_buffer_time: float = 0.1
## Velocidad horizontal de carrera.
@export var run_speed: float = 220.0

# Temporizadores internos (se cuentan en _physics_process).
var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0

func _ready() -> void:
	# Se marca con el grupo "player": así la meta (goal_reached) puede
	# distinguirlo de cualquier otro cuerpo que entre en contacto.
	add_to_group("player")

func _physics_process(delta: float) -> void:
	# --- 1) Movimiento horizontal (teclas A/D o flechas) ---
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * run_speed

	# --- 2) Gravedad + temporizador de coyote ---
	if is_on_floor():
		# Tocamos el suelo: el contador de coyote se recarga por completo.
		_coyote_timer = coyote_time
	else:
		# En el aire: la gravedad nos atrae y el coyote va muriendo.
		_coyote_timer -= delta
		velocity.y += gravity * delta

	# --- 3) Temporizador de buffer de salto ---
	if Input.is_action_just_pressed("jump"):
		# El jugador pidió saltar: guardamos esa intención.
		_jump_buffer_timer = jump_buffer_time
	else:
		_jump_buffer_timer -= delta

	# --- 4) Ejecutar el salto si AMBOS temporizadores están activos ---
	if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		velocity.y = jump_velocity
		# Gastamos ambos temporizadores para no saltar dos veces.
		_coyote_timer = 0.0
		_jump_buffer_timer = 0.0

	# --- 5) Aplicar movimiento y resolver colisiones ---
	move_and_slide()

	# Nota: al ser is_on_floor() true, el temporizador de coyote se
	# recarga en cada frame tocando el suelo, así que el salto normal
	# (pulsar y aterrizar) funciona exactamente igual que siempre.