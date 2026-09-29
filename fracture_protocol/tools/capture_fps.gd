extends SceneTree

func _init() -> void:
    var packed: PackedScene = load("res://scenes/fracture_protocol.tscn") as PackedScene
    var scene: Node = packed.instantiate()
    root.add_child(scene)
    call_deferred("_capture")

func _capture() -> void:
    await process_frame
    await process_frame
    await process_frame
    var image := get_root().get_texture().get_image()
    image.save_png("/tmp/fracture_protocol_capture.png")
    quit()
