extends Node3D

# Uzun, geniş ve kontrollü rastgele Only Up rotası. Tüm asset ailesi kullanılır.
const PROP_SCRIPT = preload("res://asset_prop.gd")
const CHECKPOINT_SCENE = preload("res://checkpoint.tscn")
const STAR_SCENE = preload("res://star.tscn")
const VISUAL_SCALE := 3.30

var rng := RandomNumberGenerator.new()
var current_top := 0.0
var current_pos := Vector3.ZERO

# 20 asset çeşidi: 8 tam cihaz + 12 parça.
const PROPS := [
    {"file":"KA-F600_Washer_V1.glb", "size":Vector3(0.82,1.06,0.69), "kind":"washer"},
    {"file":"KA-F600_Dryer_V1.glb", "size":Vector3(0.82,1.06,0.69), "kind":"dryer"},
    {"file":"KA-F600_Stove_V1.glb", "size":Vector3(0.90,0.91,0.66), "kind":"stove"},
    {"file":"KA_Micro_V2.glb", "size":Vector3(0.45,0.31,0.28), "kind":"microwave"},
    {"file":"KA-F600_Fridge_V1.glb", "size":Vector3(1.20,2.00,0.61), "kind":"fridge"},
    {"file":"KA-F1000_FridgeSBS_V1.glb", "size":Vector3(1.60,2.00,0.61), "kind":"big_fridge"},
    {"file":"KA-F600_Fan_V1.glb", "size":Vector3(0.60,0.50,0.51), "kind":"fan_small"},
    {"file":"KA-F800_Fan_V1.glb", "size":Vector3(0.80,0.50,0.51), "kind":"fan_large"},
    {"file":"KAC-F600_Fridge_V1_Shelf.glb", "size":Vector3(0.53,0.02,0.50), "kind":"shelf"},
    {"file":"KAC-F600_Fridge_V1_Drawer.glb", "size":Vector3(0.50,0.17,0.48), "kind":"drawer"},
    {"file":"KAC-F600_Fridge_V1_DrawerHolder.glb", "size":Vector3(0.54,0.21,0.50), "kind":"drawer_holder"},
    {"file":"KAC-F1000_FridgeSBS_V1_FreezerShelf.glb", "size":Vector3(0.33,0.02,0.50), "kind":"freezer_shelf"},
    {"file":"KAC-F1000_FridgeSBS_V1_FreezerDrawer.glb", "size":Vector3(0.30,0.17,0.48), "kind":"freezer_drawer"},
    {"file":"KAC-F1000_FridgeSBS_V1_FreezerDrawerHolder.glb", "size":Vector3(0.34,0.21,0.50), "kind":"freezer_holder"},
    {"file":"KAC-F600_OvenTray_V2.glb", "size":Vector3(0.47,0.04,0.40), "kind":"oven_tray_deep"},
    {"file":"KAC-F600_OvenTray_V3.glb", "size":Vector3(0.47,0.02,0.40), "kind":"oven_tray_flat"},
    {"file":"KAC-F600_TrayGuide_V2.glb", "size":Vector3(0.52,0.22,0.43), "kind":"tray_guide"},
    {"file":"KAC_Micro_Tray_V2.glb", "size":Vector3(0.18,0.02,0.17), "kind":"micro_tray"},
    {"file":"KAC_Oven_Fan_V2.glb", "size":Vector3(0.11,0.02,0.11), "kind":"oven_fan"},
    {"file":"KAC_Oven_HeatingTop_V2.glb", "size":Vector3(0.42,0.03,0.51), "kind":"heating_top"}
]

func _ready() -> void:
    rng.seed = 20260927
    var anchor: Dictionary = PROPS[5]
    _spawn_prop(anchor, Vector3(0, 0, 0), anchor.size, -1)
    current_top = anchor.size.y * VISUAL_SCALE
    _generate_path()

func _generate_path() -> void:
    for i in range(60):
        var template: Dictionary
        # İlk tırmanışlarda tam cihazlar, ileride parçalar ve karışık kümeler.
        if i < 12 or i % 9 == 0:
            template = PROPS[rng.randi_range(0, 7)]
        else:
            template = PROPS[rng.randi_range(0, PROPS.size() - 1)]
        var raw_size: Vector3 = template.size
        var final_size := raw_size * VISUAL_SCALE
        var gap := rng.randf_range(1.8, 2.8)
        var next_top := current_top + gap
        var dx := rng.randf_range(-4.8, 4.8)
        var dz := rng.randf_range(-3.8, -0.12)
        var next_pos := Vector3(clampf(current_pos.x + dx, -11.0, 11.0), next_top - final_size.y, current_pos.z + dz)
        _spawn_prop(template, next_pos, raw_size, i)
        current_top = next_top
        current_pos = next_pos

        # Çapraz yan objeler parkuru tek sıra olmaktan çıkarır.
        if i > 0 and i % 4 == 1:
            var side_template: Dictionary = PROPS[rng.randi_range(0, PROPS.size() - 1)]
            var side_pos := current_pos + Vector3(rng.randf_range(-3.8, 3.8), rng.randf_range(-0.65, 0.85), rng.randf_range(0.5, 2.8))
            _spawn_prop(side_template, side_pos, side_template.size, 100 + i)
        if i > 0 and i % 8 == 0:
            _spawn_checkpoint(current_pos + Vector3(0, final_size.y + 0.35, 0))
        if i % 5 == 2:
            _spawn_star(current_pos + Vector3(0, final_size.y + 0.9, 0))
    _spawn_checkpoint(current_pos + Vector3(0, 0.45, 0))

func _spawn_prop(template: Dictionary, base_pos: Vector3, raw_size: Vector3, index: int) -> void:
    var final_size := raw_size * VISUAL_SCALE
    var prop := AnimatableBody3D.new()
    prop.name = "Climbable_%03d_%s" % [index, template.kind]
    prop.set_script(PROP_SCRIPT)
    prop.position = base_pos
    # Daha yatık/natürel: v10'daki eğimin yaklaşık yarısı.
    prop.rotation_degrees = Vector3(rng.randf_range(-9.0, 9.0), rng.randf_range(0.0, 360.0), rng.randf_range(-12.0, 12.0))
    add_child(prop)

    var mesh_scene := load("res://assets/" + template.file) as PackedScene
    if mesh_scene:
        var model := mesh_scene.instantiate() as Node3D
        model.name = "Model"
        model.scale = Vector3.ONE * VISUAL_SCALE
        prop.add_child(model)
        _add_full_mesh_collisions(prop, model)
    if prop.get_child_count() == 1:
        _add_fallback_box(prop, final_size)

    if index >= 0 and index % 10 == 0:
        prop.behavior = "moving"
        prop.movement_axis = Vector3(rng.randf_range(0.7, 1.0), 0, rng.randf_range(-0.25, 0.25)).normalized()
        prop.movement_distance = rng.randf_range(0.55, 1.35)
        prop.movement_speed = rng.randf_range(0.45, 0.8)
    elif index >= 0 and index % 13 == 0:
        prop.behavior = "rotating"
        prop.movement_speed = rng.randf_range(0.3, 0.7)

func _add_full_mesh_collisions(prop: AnimatableBody3D, node: Node) -> void:
    for child in node.get_children():
        if child is MeshInstance3D:
            var mesh_instance := child as MeshInstance3D
            if mesh_instance.mesh:
                var collision := CollisionShape3D.new()
                collision.name = "FullSurfaceCollision_" + mesh_instance.name
                collision.shape = mesh_instance.mesh.create_trimesh_shape()
                prop.add_child(collision)
                collision.global_transform = mesh_instance.global_transform
        if child.get_child_count() > 0:
            _add_full_mesh_collisions(prop, child)

func _add_fallback_box(prop: AnimatableBody3D, size: Vector3) -> void:
    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(size.x * 0.92, maxf(0.22, size.y), size.z * 0.92)
    collision.shape = shape
    collision.position = Vector3(0, size.y * 0.5, 0)
    prop.add_child(collision)

func _spawn_checkpoint(pos: Vector3) -> void:
    var cp := CHECKPOINT_SCENE.instantiate()
    cp.position = pos
    add_child(cp)

func _spawn_star(pos: Vector3) -> void:
    var star := STAR_SCENE.instantiate()
    star.position = pos
    add_child(star)
