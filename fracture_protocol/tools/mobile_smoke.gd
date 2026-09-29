extends SceneTree

var failures: Array[String] = []

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed: PackedScene = load("res://scenes/fracture_protocol.tscn") as PackedScene
    var world: Node = packed.instantiate()
    root.add_child(world)
    await process_frame
    var controls: Control = world.get_node("HUD/Layer/MobileControls") as Control
    controls.visible = true
    var size: Vector2 = get_root().get_viewport().get_visible_rect().size
    var unit: float = minf(size.x, size.y)
    var move_start := InputEventScreenTouch.new()
    move_start.index = 1
    move_start.position = Vector2(unit * 0.2, size.y - unit * 0.19)
    move_start.pressed = true
    controls._input(move_start)
    var move_drag := InputEventScreenDrag.new()
    move_drag.index = 1
    move_drag.position = move_start.position + Vector2(unit * 0.08, 0.0)
    move_drag.relative = Vector2(unit * 0.08, 0.0)
    controls._input(move_drag)
    _check(controls.get_move_vector().x > 0.4, "mobile joystick should produce horizontal movement")
    var move_end := InputEventScreenTouch.new()
    move_end.index = 1
    move_end.position = move_drag.position
    move_end.pressed = false
    controls._input(move_end)
    var fire := InputEventScreenTouch.new()
    fire.index = 2
    fire.position = Vector2(size.x - unit * 0.17, size.y - unit * 0.2)
    fire.pressed = true
    controls._input(fire)
    _check(controls.fire_pressed, "mobile fire button should stay pressed")
    var fire_end := InputEventScreenTouch.new()
    fire_end.index = 2
    fire_end.position = fire.position
    fire_end.pressed = false
    controls._input(fire_end)
    _check(not controls.fire_pressed, "mobile fire button should release")
    world.queue_free()
    await process_frame
    if failures.is_empty():
        print("[mobile-smoke] PASS: joystick, fire press and release")
        quit(0)
        return
    for failure in failures:
        push_error("[mobile-smoke] " + failure)
    quit(1)

func _check(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)
