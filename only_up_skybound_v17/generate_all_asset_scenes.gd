extends SceneTree

const OUT_DIR := "res://props/"

func _init() -> void:
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
    var files := DirAccess.get_files_at("res://assets")
    files.sort()
    var count := 0
    for filename in files:
        if filename.to_lower().ends_with(".glb") and _make_scene(filename):
            count += 1
    print("Generated ", count, "static baked prop scenes")
    quit()

func _make_scene(filename: String) -> bool:
    var packed := load("res://assets/" + filename) as PackedScene
    if packed == null:
        push_error("Missing asset: " + filename)
        return false
    var root := StaticBody3D.new()
    root.name = _scene_name(filename)
    root.collision_layer = 1
    root.collision_mask = 1
    var model := packed.instantiate() as Node3D
    if model == null:
        push_error("No Node3D in: " + filename)
        return false
    model.name = "Model"
    model.scale = Vector3.ONE * _scale_for(filename)
    root.add_child(model)
    _add_collisions(root, model, Transform3D.IDENTITY, false)
    _set_owner_recursive(root, root)
    var scene := PackedScene.new()
    if scene.pack(root) != OK:
        push_error("Could not pack " + filename)
        return false
    if ResourceSaver.save(scene, OUT_DIR + filename.get_basename() + ".tscn") != OK:
        push_error("Could not save " + filename)
        return false
    print(filename, " scale=", _scale_for(filename), " collision=full_mesh")
    return true

func _add_collisions(root: StaticBody3D, node: Node, parent_transform: Transform3D, simplified: bool) -> void:
    var node_transform := parent_transform
    if node is Node3D:
        node_transform = parent_transform * (node as Node3D).transform
    for child in node.get_children():
        if child is MeshInstance3D:
            var mesh_instance := child as MeshInstance3D
            if mesh_instance.mesh:
                var collision := CollisionShape3D.new()
                collision.name = "BakedSurface_" + mesh_instance.name
                collision.shape = mesh_instance.mesh.create_convex_shape() if simplified else mesh_instance.mesh.create_trimesh_shape()
                collision.transform = node_transform * mesh_instance.transform
                root.add_child(collision)
        if child.get_child_count() > 0:
            _add_collisions(root, child, node_transform, simplified)

func _set_owner_recursive(node: Node, owner_node: Node) -> void:
    for child in node.get_children():
        child.owner = owner_node
        _set_owner_recursive(child, owner_node)

func _is_large_vehicle(filename: String) -> bool:
    var n := filename.to_lower()
    return n.contains("boat") or n.contains("kayak") or n.contains("jetski") or n.contains("plane") or n.contains("helicopter")

func _scale_for(filename: String) -> float:
    var n := filename.to_lower()
    if n.begins_with("ka-") or n.begins_with("kac-") or n.begins_with("ka_"):
        return 3.3
    # These GLBs contain an internal 0.01 import transform; use real area-sized multipliers.
    if n.contains("boat"):
        return 3.5
    if n.contains("plane"):
        return 6.0
    if n.contains("helicopter"):
        return 5.0
    if n.contains("kayak") or n.contains("jetski"):
        return 2.5
    if n.contains("paddle") or n.contains("fishing_rod"):
        return 1.8
    if n.contains("plank"):
        return 1.5
    if n.contains("table"):
        return 1.7
    if n.contains("pole") or n.contains("signal"):
        return 1.8
    return 2.5

func _scene_name(filename: String) -> String:
    return "Prop_" + filename.get_basename().replace("-", "_").replace(" ", "_")
