extends AnimatableBody3D

@export var movement_enabled := false
@export var movement_axis := Vector3.RIGHT
@export var movement_distance := 0.0
@export var movement_speed := 0.8
@export var rotating := false
@export var rotation_speed := 0.5

var _base_position := Vector3.ZERO
var _time := 0.0

func _ready() -> void:
    _base_position = position

func _physics_process(delta: float) -> void:
    _time += delta
    if movement_enabled:
        position = _base_position + movement_axis.normalized() * sin(_time * movement_speed) * movement_distance
    if rotating:
        rotate_y(delta * rotation_speed)
