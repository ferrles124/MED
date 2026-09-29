extends SceneTree
var failures: Array[String] = []
func _init() -> void:
    var packed := load("res://scenes/arena.tscn") as PackedScene
    var arena := packed.instantiate()
    root.add_child(arena)
    await process_frame
    _check(arena.get_node_or_null("Player/Character/AnimationPlayer") != null, "player animation player")
    _check(arena.get_node_or_null("Enemy/Character/AnimationPlayer") != null, "enemy animation player")
    _check(arena.get_node_or_null("Enemy/RecoveryAnimationPlayer") != null, "enemy recovery animation player")
    _check(arena.get_node_or_null("Player/RecoveryAnimationPlayer") != null, "node-based recovery animation player")
    _check(arena.get_node_or_null("HUD/MobileControls/Joystick/Base") != null, "node-based analog joystick")
    _check(arena.get_node_or_null("HUD/MobileControls/Actions/Jab") != null, "jab button")
    var player := arena.get_node("Player") as FightPlayer
    var enemy := arena.get_node("Enemy") as FightEnemy
    var old_yaw := player.yaw
    player._look(Vector2(80, 0))
    _check(player.yaw != old_yaw, "right touch camera look changes yaw")
    var controls := arena.get_node("HUD/MobileControls") as FightMobileControls
    controls.base.size = Vector2(240, 240)
    controls.knob.size = Vector2(76, 76)
    controls._process(0.0)
    var press := InputEventMouseButton.new()
    press.button_index = MOUSE_BUTTON_LEFT
    press.pressed = true
    press.position = Vector2(190, 120)
    controls._on_joystick_input(press)
    _check(controls.move_vector.length() > 0.1, "joystick local node input")
    var release := InputEventMouseButton.new()
    release.button_index = MOUSE_BUTTON_LEFT
    release.pressed = false
    controls._on_joystick_input(release)
    var touch := InputEventScreenTouch.new()
    touch.index = 4
    touch.pressed = true
    touch.position = Vector2(120, 120)
    controls._on_joystick_input(touch)
    var drag := InputEventScreenDrag.new()
    drag.index = 4
    drag.position = Vector2(190, 120)
    drag.relative = Vector2(70, 0)
    controls._on_joystick_input(drag)
    _check(controls.move_vector.x > 0.1, "touch joystick drag")
    _check(enemy.animation_player.current_animation == &"Idle", "enemy stays idle")
    enemy.take_hit(&"head", 1)
    _check(enemy.animation_player.current_animation == &"Hit_Head", "head hit animation")
    enemy.take_hit(&"chest", 1)
    _check(enemy.animation_player.current_animation == &"Hit_Chest", "chest hit animation")
    player.punch(&"Punch_Jab")
    await process_frame
    _check(player.attacking, "player jab starts")
    _check(player.get_node("PunchHitArea") != null, "punch hit area")
    player.take_damage(100)
    await create_timer(7.0).timeout
    await process_frame
    await process_frame
    _check(not player.dead and not player.recovering, "death to getup recovery")
    _check(arena.get_node("HUD/Status").text == "TEKRAR AYAĞA KALKTI", "idle after getup")
    enemy.take_hit(&"head", 100)
    await create_timer(7.0).timeout
    _check(not enemy.dead and not enemy.recovering, "enemy death to getup recovery")
    if failures.is_empty():
        print("FIGHT ARENA SMOKE PASS")
        quit(0)
    else:
        for f in failures: push_error(f)
        quit(1)
func _check(value: bool, text: String) -> void:
    if not value: failures.append(text)
