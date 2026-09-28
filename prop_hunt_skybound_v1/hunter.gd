extends CharacterBody3D

@export var patrol_speed := 2.4
@export var chase_speed := 4.2
@export var detection_range := 18.0
@export var prop_check_range := 2.6

var game
var player
var patrol_points: Array = []
var patrol_index := 0

func _physics_process(delta: float) -> void:
    if not game or game.round_over:
        return
    if not player.disguised:
        var distance: float = global_position.distance_to(player.global_position)
        if distance < detection_range:
            _move_toward_target(player.global_position, chase_speed, delta)
            if distance < 1.45:
                game.player_caught()
                return
        else:
            _patrol(delta)
    else:
        if global_position.distance_to(player.global_position) < prop_check_range:
            game.player_caught()
            return
        _patrol(delta)

func _patrol(delta: float) -> void:
    if patrol_points.is_empty():
        return
    var target: Vector3 = patrol_points[patrol_index]
    if global_position.distance_to(target) < 1.0:
        patrol_index = (patrol_index + 1) % patrol_points.size()
        target = patrol_points[patrol_index]
    _move_toward_target(target, patrol_speed, delta)

func _move_toward_target(target: Vector3, speed: float, delta: float) -> void:
    var flat := target - global_position
    flat.y = 0.0
    if flat.length_squared() > 0.01:
        flat = flat.normalized()
        rotation.y = lerp_angle(rotation.y, atan2(-flat.x, -flat.z), delta * 5.0)
    velocity.x = move_toward(velocity.x, flat.x * speed, 12.0 * delta)
    velocity.z = move_toward(velocity.z, flat.z * speed, 12.0 * delta)
    if not is_on_floor():
        velocity.y -= 18.0 * delta
    else:
        velocity.y = 0.0
    move_and_slide()
