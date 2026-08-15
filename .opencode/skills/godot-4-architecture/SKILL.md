---
name: godot-4-architecture
description: "Trigger: godot architecture, gdscript, godot 4, node composition, state machine, custom resource, event bus, game feel godot, godot csharp. Design modular, performant Godot 4 games and systems."
license: Apache-2.0
metadata:
  author: "metis"
  version: "1.1"
---

## Activation Contract

Activate this skill when:
- Designing or refactoring scene trees, node hierarchies, or project architecture in Godot 4.
- Implementing typed GDScript 2.0 or C# logic, state machines, custom resources, or signal-based communication.
- Implementing CharacterBody2D/3D physics & game feel (coyote time, jump buffer, dash, wall jump).
- Structuring entity-component patterns (`HealthComponent`, `HitboxComponent`, `HurtboxComponent`).
- Building Camera systems (Trauma shake, 2D/3D follow, Deadzones, Spring Lerp).

Do not activate for writing GLSL shaders (use `godot-shader-lab`), UI design (use `godot-ui`), or unit tests (use `godot-gut-testing`).

## Hard Rules

- **Composition over Deep Inheritance:** Avoid deep node subclassing. Use child nodes or component resources for behavior (e.g. `HitboxComponent`, `HealthComponent`).
- **Signal-Driven Decoupling:** Call down, signal up. Parent nodes call functions on child nodes; child nodes emit signals to communicate upwards or outward.
- **Data-Driven Custom Resources:** Use `.tres` / custom `Resource` scripts for stats, inventory items, and configurations instead of hardcoded JSON or monolithic scripts.
- **Strict Typing:** Always use strong static typing in GDScript 2.0 (`var health: int = 100`, `func take_damage(amount: int) -> void:`).
- **Node Paths:** Never hardcode absolute node paths (`$../../UI/Label`). Use `@export var target_node: Node` or `@onready var` with unique scene names (`%UniqueNode`).

## Essential Architectural Patterns

### 1. Component Pattern: Health & Hitbox / Hurtbox

```gdscript
# HealthComponent.gd
class_name HealthComponent extends Node

signal health_changed(current: int, max_health: int)
signal died

@export var max_health: int = 100
@onready var current_health: int = max_health

func damage(amount: int) -> void:
	current_health = max(0, current_health - amount)
	health_changed.emit(current_health, max_health)
	if current_health <= 0:
		died.emit()
```

```gdscript
# HitboxComponent.gd
class_name HitboxComponent extends Area2D

@export var damage_amount: int = 10

func _init() -> void:
	collision_layer = 0
	collision_mask = 2 # Hurtbox layer
```

### 2. Game Feel Physics (Coyote Time & Jump Buffer)

```gdscript
# CharacterBody2D Game Feel Handler
class_name PlatformerController extends CharacterBody2D

@export var gravity: float = 980.0
@export var jump_velocity: float = -400.0
@export var coyote_time: float = 0.15
@export var jump_buffer_time: float = 0.1

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0

func _physics_process(delta: float) -> void:
	# Update timers
	if is_on_floor():
		_coyote_timer = coyote_time
	else:
		_coyote_timer -= delta
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer_time
	else:
		_jump_buffer_timer -= delta

	# Execute jump if both buffer and coyote are active
	if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		velocity.y = jump_velocity
		_coyote_timer = 0.0
		_jump_buffer_timer = 0.0

	move_and_slide()
```

### 3. Camera Trauma Shake System

```gdscript
# CameraShake2D.gd
class_name TraumaCamera2D extends Camera2D

@export var max_offset: Vector2 = Vector2(25, 25)
@export var max_roll: float = 0.1
@export var decay: float = 0.8

var trauma: float = 0.0 # 0.0 to 1.0

func add_trauma(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)

func _process(delta: float) -> void:
	if trauma > 0.0:
		trauma = max(trauma - decay * delta, 0.0)
		var shake_amount: float = trauma * trauma # Non-linear feel
		rotation = max_roll * shake_amount * randf_range(-1.0, 1.0)
		offset = max_offset * shake_amount * Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
	else:
		offset = Vector2.ZERO
		rotation = 0.0
```

## Output Contract

Provide clean GDScript 2.0 / C# code blocks, scene hierarchy tree diagrams, signal specifications, and clear instructions for resource creation.

## References

- Official Godot 4 GDScript Documentation: `https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/`
- Godot 4 Best Practices: `https://docs.godotengine.org/en/stable/tutorials/best_practices/`
