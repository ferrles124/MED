extends CharacterBody3D
class_name FractureBot

@export var team := "amber"
@export var move_speed := 2.5
@export var health := 100
@export var weapon_damage := 12
@export var fire_interval := 0.72

var game: Node
var alive := true
var spawn_position := Vector3.ZERO
var shot_clock := 0.0
var strafe_clock := 0.0
var strafe_sign := 1.0

@onready var visual: Node3D = $Visual
@onready var weapon_visual: Node3D = $Visual/Weapon

func _ready() -> void:
    add_to_group("bots")
    spawn_position = global_position
    shot_clock = randf_range(0.2, 1.0)
    strafe_clock = randf_range(1.0, 2.5)

func _physics_process(delta: float) -> void:
    if not alive or game == null or not game.is_live():
        velocity = Vector3.ZERO
        return
    var target: Node = game.player
    if not is_instance_valid(target) or not target.alive:
        return
    var to_target: Vector3 = target.global_position - global_position
    to_target.y = 0.0
    var distance: float = to_target.length()
    if distance > 7.0:
        var forward: Vector3 = to_target.normalized()
        velocity.x = forward.x * move_speed
        velocity.z = forward.z * move_speed
    else:
        strafe_clock -= delta
        if strafe_clock <= 0.0:
            strafe_clock = randf_range(1.0, 2.0)
            strafe_sign *= -1.0
        var side := Vector3(-to_target.z, 0.0, to_target.x).normalized() * strafe_sign
        velocity.x = side.x * move_speed * 0.65
        velocity.z = side.z * move_speed * 0.65
    velocity.y = -0.25
    move_and_slide()
    look_at(Vector3(target.global_position.x, global_position.y + 0.7, target.global_position.z), Vector3.UP)
    shot_clock -= delta
    if shot_clock <= 0.0 and distance < 28.0:
        shot_clock = fire_interval + randf_range(-0.12, 0.18)
        _shoot_at_player(target)

func _shoot_at_player(target: Node) -> void:
    var origin := global_position + Vector3.UP * 1.05
    var target_point: Vector3 = target.global_position + Vector3.UP * 0.55
    var query := PhysicsRayQueryParameters3D.create(origin, target_point)
    query.exclude = [self]
    query.collision_mask = 1
    var hit := get_world_3d().direct_space_state.intersect_ray(query)
    if not hit.is_empty() and hit.get("collider") == target:
        target.apply_damage(weapon_damage)

func apply_damage(amount: int) -> void:
    if not alive:
        return
    health = maxi(0, health - amount)
    if health <= 0:
        alive = false
        visual.visible = false
        collision_layer = 0
        collision_mask = 0
        if game != null:
            game.hud.set_message("Bir amber operatörü etkisizleştirildi.")

func reset_for_round() -> void:
    global_position = spawn_position
    velocity = Vector3.ZERO
    health = 100
    alive = true
    visible = true
    visual.visible = true
    collision_layer = 1
    collision_mask = 1
    shot_clock = randf_range(0.3, 1.0)
