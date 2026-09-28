extends AnimatableBody3D

@export var behavior := "static"
@export var movement_axis := Vector3.RIGHT
@export var movement_distance := 0.0
@export var movement_speed := 1.0
var _base_position := Vector3.ZERO
var _time := 0.0

func _ready() -> void:
    _base_position = position

func _physics_process(delta: float) -> void:
    _time += delta
    if behavior == "moving":
        position = _base_position + movement_axis * sin(_time * movement_speed) * movement_distance
    elif behavior == "rotating":
        rotate_y(delta * movement_speed)
