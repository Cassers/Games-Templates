---
name: godot-gut-testing
description: "Trigger: godot testing, gut, godot unit test, godot integration test, mock godot signals, TDD godot. Write automated tests for Godot 4 using GUT framework."
license: Apache-2.0
metadata:
  author: "metis"
  version: "1.0"
---

## Activation Contract

Activate this skill when:
- Creating unit, integration, or end-to-end test suites for Godot 4 nodes, resources, or scripts.
- Mocking signals, scene trees, network calls, or physics in Godot.
- Configuring headless CLI automated test runs for CI/CD pipelines.

Do not activate for general gameplay architecture (use `godot-4-architecture`).

## Hard Rules

- **Extend `GutTest`:** All test scripts must inherit from `GutTest` (`extends GutTest` or `class_name MyTest extends GutTest`).
- **Clean Lifecycle Hooks:** Instantiate nodes in `before_each()` and always call `free()` or `autofree(node)` to prevent memory leaks in the scene tree.
- **Signal Assertions:** Use `assert_signal_emitted(object, "signal_name")` or `watch_signals(object)` instead of manual boolean flags.
- **Headless Execution:** Ensure test suites can run via headless CLI: `godot --headless -s addons/gut/gut_cmdln.gd`.
- **Isolation:** Never depend on global editor state or un-mocked external network resources during unit tests.

## Decision Gates

| Test Objective | Technique / Method |
|----------------|--------------------|
| Pure script / logic verification | Instantiate script directly (`var script = load(...).new()`), call `autofree(script)` |
| Scene / Node interaction | Use `add_child_autofree(instance)` to test physics and node tree lifecycle |
| Async / Timer / Signal waiting | Use `await wait_for_signal(object.signal_name, max_wait_sec)` |
| Dependency / Class mocking | Use `double()` or `partial_double()` provided by GUT |

## Execution Steps

1. **Setup Test File:** Create `test/unit/test_{feature}.gd` extending `GutTest`.
2. **Define Fixtures:** Set up `before_each()` with required instances registered via `autofree()`.
3. **Write AAA Test Cases:**
   - **Arrange:** Set initial node properties or custom resources.
   - **Act:** Call target functions or simulate input/signals.
   - **Assert:** Use GUT assertions (`assert_eq`, `assert_true`, `assert_signal_emitted`).
4. **Handle Async Operations:** Use `await yield_to_physics_frame()` or `wait_for_signal()` when testing physics/timers.
5. **Run Suite:** Execute tests via GUT panel in editor or headless command line.

## Output Contract

Return complete, leak-free GDScript test files, clear assertion breakdowns, and headless execution CLI commands.

## References

- GUT Framework Wiki: `https://github.com/bitwes/Gut/wiki`
- Godot 4 Command Line Tutorial: `https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html`
