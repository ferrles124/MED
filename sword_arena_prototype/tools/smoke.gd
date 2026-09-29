extends SceneTree

var failures: Array[String] = []

func _init() -> void:
    var packed := load("res://scenes/prototype.tscn") as PackedScene
    if packed == null:
        failures.append("prototype scene could not load")
    else:
        var world := packed.instantiate()
        root.add_child(world)
        await process_frame
        _check(world.get_node_or_null("Floor/Mesh") != null, "floor mesh exists")
        _check(world.get_node_or_null("Player/Character/Rig/Skeleton3D/WeaponSocket/Sword/Model") != null, "sword is attached under the WeaponSocket BoneAttachment3D")
        _check(world.get_node_or_null("Player/Character/Rig/Skeleton3D/WeaponSocket/Sword/GripMarker") != null, "weapon grip marker exists")
        _check(world.get_node_or_null("Player/Character/Rig/Skeleton3D/LeftHandIK") != null, "TwoBoneIK3D node exists")
        _check(world.get_node_or_null("Player/AnimationTree") != null, "AnimationTree node exists")
        _check(world.get_node_or_null("Player/Character/AnimationPlayer") != null, "character AnimationPlayer exists")
        _check(world.get_node_or_null("HUD/MobileControls/MovePad/Up") != null, "node-based mobile movement controls exist")
        _check(world.get_node_or_null("HUD/MobileControls/LookPanel") != null, "node-based mobile look panel exists")
        var player := world.get_node("Player")
        player.request_attack()
        await process_frame
        _check(player.attacking, "sword attack can start")
        await create_timer(0.8).timeout
        _check(player.attacking, "sword attack is not cut off before the 1.53s animation ends")
        await create_timer(0.9).timeout
        _check(not player.attacking, "sword attack returns to idle after the full animation")
        world.queue_free()
    if failures.is_empty():
        print("SWORD PROTOTYPE SMOKE PASS")
        quit(0)
    else:
        for failure in failures:
            push_error(failure)
        quit(1)

func _check(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)
