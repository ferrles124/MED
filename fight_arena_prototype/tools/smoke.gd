extends SceneTree
var failures: Array[String] = []
func _init() -> void:
    var packed := load("res://scenes/arena.tscn") as PackedScene
    var arena := packed.instantiate()
    root.add_child(arena)
    await process_frame
    _check(arena.get_node_or_null("Player/Character/AnimationPlayer") != null, "player animation player")
    _check(arena.get_node_or_null("Enemy/Character/AnimationPlayer") != null, "enemy animation player")
    _check(arena.get_node_or_null("HUD/MobileControls/Joystick/Base") != null, "node-based analog joystick")
    _check(arena.get_node_or_null("HUD/MobileControls/Actions/Jab") != null, "jab button")
    arena.get_node("Player").punch(&"Punch_Jab")
    await process_frame
    _check(arena.get_node("Player").attacking, "player jab starts")
    _check(arena.get_node("Player/PunchHitArea") != null, "punch hit area")
    if failures.is_empty():
        print("FIGHT ARENA SMOKE PASS")
        quit(0)
    else:
        for f in failures: push_error(f)
        quit(1)
func _check(value: bool, text: String) -> void:
    if not value: failures.append(text)
