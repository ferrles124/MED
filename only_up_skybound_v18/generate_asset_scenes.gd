extends SceneTree

const OUT_DIR := "res://props/"
const SCALE := 3.3

const ASSETS := [
    "KA-F600_Washer_V1.glb",
    "KA-F600_Dryer_V1.glb",
    "KA-F600_Stove_V1.glb",
    "KA_Micro_V2.glb",
    "KA-F600_Fridge_V1.glb",
    "KA-F1000_FridgeSBS_V1.glb",
    "KA-F600_Fan_V1.glb",
    "KA-F800_Fan_V1.glb",
    "KAC-F600_Fridge_V1_Shelf.glb",
    "KAC-F600_Fridge_V1_Drawer.glb",
    "KAC-F600_Fridge_V1_DrawerHolder.glb",
    "KAC-F1000_FridgeSBS_V1_FreezerShelf.glb",
    "KAC-F1000_FridgeSBS_V1_FreezerDrawer.glb",
    "KAC-F1000_FridgeSBS_V1_FreezerDrawerHolder.glb",
    "KAC-F600_OvenTray_V2.glb",
    "KAC-F600_OvenTray_V3.glb",
    "KAC-F600_TrayGuide_V2.glb",
    "KAC_Micro_Tray_V2.glb",
    "KAC_Oven_Fan_V2.glb",
    "KAC_Oven_HeatingTop_V2.glb"
]

func _init() -> void:
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
    for filename in ASSETS:
        _make_scene(filename)
    print("Generated ", ASSETS.size(), " baked prop scenes")
    quit()

func _make_scene(filename: String) -> void:
    var source_path := "res://assets/" + filename
    var packed := load(source_path) as PackedScene
    if packed == null:
        push_error("Missing asset: " + source_path)
        return
    var root := AnimatableBody3D.new()
    root.name = _scene_name(filename)
    root.set_script(load("res://baked_prop.gd"))
    root.collision_layer = 1
    root.collision_mask = 1
    var model := packed.instantiate() as Node3D
    model.name = "Model"
    model.scale = Vector3.ONE * SCALE
    root.add_child(model)
    _add_baked_collisions(root, model, Transform3D.IDENTITY)
    _set_owner_recursive(root, root)
    var scene := PackedScene.new()
    var result := scene.pack(root)
    if result != OK:
        push_error("Could not pack " + filename + ": " + str(result))
        return
    var out_path := OUT_DIR + filename.get_basename() + ".tscn"
    var save_result := ResourceSaver.save(scene, out_path)
    if save_result != OK:
        push_error("Could not save " + out_path + ": " + str(save_result))
    else:
        print(out_path)

func _add_baked_collisions(root: AnimatableBody3D, node: Node, parent_transform: Transform3D) -> void:
    var node_transform := parent_transform
    if node is Node3D:
        node_transform = parent_transform * (node as Node3D).transform
    for child in node.get_children():
        if child is MeshInstance3D:
            var mesh_instance := child as MeshInstance3D
            if mesh_instance.mesh:
                var collision := CollisionShape3D.new()
                collision.name = "BakedSurface_" + mesh_instance.name
                collision.shape = mesh_instance.mesh.create_trimesh_shape()
                collision.transform = node_transform * mesh_instance.transform
                root.add_child(collision)
        if child.get_child_count() > 0:
            _add_baked_collisions(root, child, node_transform)

func _set_owner_recursive(node: Node, owner_node: Node) -> void:
    for child in node.get_children():
        child.owner = owner_node
        _set_owner_recursive(child, owner_node)

func _scene_name(filename: String) -> String:
    return filename.get_basename().replace("-", "_")
