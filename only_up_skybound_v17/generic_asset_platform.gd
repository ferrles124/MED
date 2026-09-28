@tool
extends AnimatableBody3D

## Inspector'dan seçilecek tek GLB dosyası.
@export_file("*.glb") var model_path: String = ""
@export_category("Model")
@export var model_scale: float = 3.3
@export var generate_full_mesh_collision: bool = true
@export var collision_layer_override: int = 1
@export_category("Optional Movement")
@export var movement_enabled: bool = false
@export var movement_axis := Vector3.RIGHT
@export var movement_distance: float = 0.0
@export var movement_speed: float = 0.8
@export var rotating: bool = false
@export var rotation_speed: float = 0.5

var _model: Node3D
var _base_position := Vector3.ZERO
var _time := 0.0
var _last_model_path := ""
var _last_scale := 0.0

func _ready() -> void:
    _base_position = position
    collision_layer = collision_layer_override
    collision_mask = 1
    _rebuild_model()

func _process(_delta: float) -> void:
    if Engine.is_editor_hint():
        if model_path != _last_model_path or not is_equal_approx(model_scale, _last_scale):
            _rebuild_model()

func _physics_process(delta: float) -> void:
    if Engine.is_editor_hint():
        return
    _time += delta
    if movement_enabled:
        position = _base_position + movement_axis.normalized() * sin(_time * movement_speed) * movement_distance
    if rotating:
        rotate_y(delta * rotation_speed)

func _rebuild_model() -> void:
    if not is_inside_tree():
        return
    if _model:
        _model.queue_free()
        _model = null
    for child in get_children():
        if child is CollisionShape3D:
            child.queue_free()
    _last_model_path = model_path
    _last_scale = model_scale
    if model_path.is_empty():
        return
    var packed := load(model_path) as PackedScene
    if packed == null:
        push_warning("GLB yüklenemedi: " + model_path)
        return
    _model = packed.instantiate() as Node3D
    if _model == null:
        push_warning("GLB içinde Node3D bulunamadı: " + model_path)
        return
    _model.name = "GLB_Model"
    _model.scale = Vector3.ONE * model_scale
    add_child(_model)
    if generate_full_mesh_collision:
        _add_mesh_collisions(_model)
    else:
        _add_box_fallback()

func _add_mesh_collisions(node: Node) -> void:
    for child in node.get_children():
        if child is MeshInstance3D:
            var mesh_instance := child as MeshInstance3D
            if mesh_instance.mesh:
                var collision := CollisionShape3D.new()
                collision.name = "FullSurface_" + mesh_instance.name
                collision.shape = mesh_instance.mesh.create_trimesh_shape()
                add_child(collision)
                collision.global_transform = mesh_instance.global_transform
        if child.get_child_count() > 0:
            _add_mesh_collisions(child)

func _add_box_fallback() -> void:
    var collision := CollisionShape3D.new()
    collision.name = "FallbackCollision"
    var shape := BoxShape3D.new()
    shape.size = Vector3(2.0, 0.25, 2.0)
    collision.shape = shape
    collision.position = Vector3(0, 0.15, 0)
    add_child(collision)
