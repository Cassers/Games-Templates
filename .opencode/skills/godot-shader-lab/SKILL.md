---
name: godot-shader-lab
description: "Trigger: godot shader, canvasitem shader, spatial shader, godot GLSL, visual shader, shader uniform, particle shader godot. Develop 2D, 3D, and particle shaders in Godot 4."
license: Apache-2.0
metadata:
  author: "metis"
  version: "1.0"
---

## Activation Contract

Activate this skill when:
- Writing, debugging, or optimizing 2D (`canvas_item`), 3D (`spatial`), sky, fog, or particle shaders in Godot 4.
- Passing uniforms, texture maps, or noise parameters from GDScript/C# to ShaderMaterials.
- Creating visual effects like dissolve, outline, distortion, water, or dissolve shaders.

Do not activate for standard GDScript node logic or game state management (use `godot-4-architecture`).

## Hard Rules

- **Explicit Shader Type:** Every shader must declare `shader_type canvas_item;`, `shader_type spatial;`, or `shader_type particles;` as the first line.
- **Godot Shading Syntax:** Use Godot's built-in functions (`texture()`, `mix()`, `step()`, `smoothstep()`) and GLSL types (`vec2`, `vec3`, `vec4`, `mat4`).
- **No Heavy Branching:** Avoid complex dynamic `if/else` inside fragment/vertex processors; use `step()`, `mix()`, or `clamp()` for performance.
- **Uniform Hints:** Always annotate uniforms with range or type hints (e.g. `uniform float speed : hint_range(0.0, 10.0) = 1.0;`, `uniform sampler2D noise_tex : repeat_enable;`).
- **Performance Profiling:** Keep texture lookups inside `fragment()` minimal; compute invariant UV operations in `vertex()` and pass via `varying`.

## Decision Gates

| Target Render Effect | Shader Type & Function |
|----------------------|------------------------|
| UI, 2D Sprites, TileMaps | `shader_type canvas_item;` in `fragment()` modifying `COLOR` |
| 3D Meshes, PBR Materials | `shader_type spatial;` modifying `ALBEDO`, `ROUGHNESS`, `METALLIC`, `EMISSION` |
| CPU/GPU Particle movement | `shader_type particles;` modifying `VELOCITY`, `COLOR`, `TRANSFORM` |
| Code-driven parameters | Modify via `material.set_shader_parameter("uniform_name", value)` |

## Execution Steps

1. **Define Shader Type & Render Mode:** Select `canvas_item` or `spatial`, set render modes (e.g. `render_mode unshaded, blend_mix;`).
2. **Declare Uniforms & Varyings:** Add custom parameters with range hints and uniform samplers.
3. **Write Vertex Processor (if needed):** Calculate position shifts or pass varying data to fragment.
4. **Implement Fragment Processor:** Combine UV coordinates, noise textures, colors, and math logic to set output pixels.
5. **Hook GDScript/C# Controller:** Write helper functions to update uniforms dynamically over time or on game events.

## Output Contract

Return valid `.gdshader` code, GDScript uniform binding scripts, and performance advice.

## References

- Godot 4 Shading Language Reference: `https://docs.godotengine.org/en/stable/tutorials/shaders/shading_language.html`
- Godot 4 Shader Types: `https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/index.html`
