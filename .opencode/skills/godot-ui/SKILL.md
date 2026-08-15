---
name: godot-ui
description: "Trigger: godot ui, godot theme, control node, godot hud, godot interface, responsive ui godot, damage popup godot. Design responsive, themed, and performant user interfaces in Godot 4."
license: Apache-2.0
metadata:
  author: "metis"
  version: "1.0"
---

## Activation Contract

Activate this skill when:
- Designing or implementing User Interfaces (UI), HUDs, or menus in Godot 4.
- Creating custom UI themes (`Theme` resources), dynamic scaling, or control node styling.
- Implementing UI components such as health bars, damage popups, inventory grids, or floating text.

## Hard Rules

- **Use Container Nodes:** Never rely on absolute position anchors alone. Always use Layout Containers (`MarginContainer`, `VBoxContainer`, `HBoxContainer`, `GridContainer`, `CenterContainer`) for responsive UI across different screen resolutions.
- **Theme Overrides via Theme Resources:** Centralize font, color, and stylebox definitions in custom `.theme` resources (`res://themes/main_theme.theme`) rather than hardcoding stylebox overrides on individual nodes.
- **Decouple UI from Game Logic:** UI nodes should observe game state via signals or an `EventBus` singleton. UI nodes must NOT directly mutate player or enemy stats.
- **Pixel-Perfect Scaling:** Set Window Stretch mode in `project.godot` to `canvas_items` or `viewport` with appropriate aspect ratio (`keep` or `expand`).
- **Smooth Animation with Tweens:** Use Godot 4 `create_tween()` for UI transitions, panel popups, and damage numbers rather than heavy AnimationPlayer tracks for simple UI micro-interactions.

## Common UI Patterns & Components

### 1. Floating Damage Popups (Tween-based)
```gdscript
class_name DamagePopup extends Label

func pop(amount: int, is_critical: bool = false) -> void:
	text = str(amount)
	modulate = Color.YELLOW if is_critical else Color.WHITE
	pivot_offset = size / 2.0
	
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 40.0, 0.6).set_trans(Tween.TRANS_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.6).set_ease(Tween.EASE_IN)
	if is_critical:
		tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.2).set_trans(Tween.TRANS_BACK)
	
	tween.chain().tween_callback(queue_free)
```

### 2. Signal-Driven Health Bar
```gdscript
class_name HealthBarUI extends TextureProgressBar

@export var health_component: HealthComponent

func _ready() -> void:
	if health_component:
		health_component.health_changed.connect(_on_health_changed)
		max_value = health_component.max_health
		value = health_component.current_health

func _on_health_changed(new_health: int, _max_health: int) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "value", float(new_health), 0.3).set_trans(Tween.TRANS_QUAD)
```

## References

- Godot 4 Control Nodes Guide: `https://docs.godotengine.org/en/stable/tutorials/ui/index.html`
- Theme System in Godot 4: `https://docs.godotengine.org/en/stable/tutorials/ui/gui_using_theme_editor.html`
