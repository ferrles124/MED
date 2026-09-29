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
    var player := arena.get_node("Player") as FightPlayer
    var enemy := arena.get_node("Enemy") as FightEnemy
    var old_yaw := player.yaw
    player._look(Vector2(80, 0))
    _check(player.yaw != old_yaw, "right touch camera look changes yaw")
    _check(enemy.animation_player.current_animation == &"Idle", "enemy stays idle")
    enemy.take_hit(&"head", 1)
    _check(enemy.animation_player.current_animation == &"Hit_Head", "head hit animation")
    enemy.take_hit(&"chest", 1)
    _check(enemy.animation_player.current_animation == &"Hit_Chest", "chest hit animation")
    player.punch(&"Punch_Jab")
    await process_frame
    _check(player.attacking, "player jab starts")
    _check(player.get_node("PunchHitArea") != null, "punch hit area")
    if failures.is_empty():
        print("FIGHT ARENA SMOKE PASS")
        quit(0)
    else:
        for f in failures: push_error(f)
        quit(1)
func _check(value: bool, text: String) -> void:
    if not value: failures.append(text)
