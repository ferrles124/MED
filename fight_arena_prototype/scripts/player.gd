extends CharacterBody3D
class_name FightPlayer

@export var move_speed := 4.8
@export var acceleration := 18.0
@export var gravity := 22.0
@export var jump_velocity := 7.0
@export var look_sensitivity := 0.006
@onready var character: Node3D = $Character
@onready var camera_pivot: Node3D = $CameraPivot
@onready var animation_player: AnimationPlayer = $Character/AnimationPlayer
@onready var hit_area: Area3D = $PunchHitArea
@onready var hud: CanvasLayer = get_node_or_null("../HUD")
var mobile_move := Vector2.ZERO
var yaw := 0.0
var pitch := deg_to_rad(-10.0)
var attacking := false
var attack_time := 0.0
var attack_kind := &"Punch_Jab"
var health := 100
var hit_targets: Dictionary = {}

func _ready() -> void:
    add_to_group("player")
    hit_area.monitoring = false
    hit_area.area_entered.connect(_on_punch_area_entered)
    camera_pivot.rotation.x = pitch
    camera_pivot.rotation.y = yaw
    _play(&"Idle")

func _on_punch_area_entered(area: Area3D) -> void:
    if attacking and area.name in [&"HeadHitZone", &"ChestHitZone"]:
        var target := area.get_parent() as FightEnemy
        if target and not hit_targets.has(target):
            hit_targets[target] = true
            var zone: StringName = &"head" if area.name == &"HeadHitZone" else &"chest"
            target.take_hit(zone, 18 if attack_kind == &"Punch_Jab" else 26)

func _physics_process(delta: float) -> void:
    var mobile_controls := get_node_or_null("../HUD/MobileControls") as FightMobileControls
    if mobile_controls:
        mobile_move = mobile_controls.move_vector
        _look(mobile_controls.consume_look_delta() * look_sensitivity)
        if mobile_controls.jab_requested:
            mobile_controls.jab_requested = false
            punch(&"Punch_Jab")
        if mobile_controls.cross_requested:
            mobile_controls.cross_requested = false
            punch(&"Punch_Cross")
    var direction := _movement_direction(mobile_move)
    velocity.x = move_toward(velocity.x, direction.x * move_speed, acceleration * delta)
    velocity.z = move_toward(velocity.z, direction.z * move_speed, acceleration * delta)
    if not is_on_floor():
        velocity.y -= gravity * delta
    elif Input.is_action_just_pressed("jump"):
        velocity.y = jump_velocity
    if not attacking:
        _play(&"Walk" if direction.length_squared() > 0.01 else &"Idle")
        if direction.length_squared() > 0.01:
            rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.z) + PI, delta * 9.0)
    else:
        attack_time += delta
        hit_area.monitoring = attack_time > 0.22 and attack_time < 0.52
        if attack_time > animation_player.get_animation(attack_kind).length:
            attacking = false
            hit_area.monitoring = false
            _play(&"Idle")
    move_and_slide()

func _movement_direction(input: Vector2) -> Vector3:
    var local := Vector3(input.x, 0.0, input.y)
    if local.length_squared() > 1.0: local = local.normalized()
    return Basis(Vector3.UP, yaw) * local

func _look(delta_look: Vector2) -> void:
    yaw -= delta_look.x
    pitch = clamp(pitch - delta_look.y, deg_to_rad(-28.0), deg_to_rad(18.0))
    camera_pivot.rotation.y = yaw
    camera_pivot.rotation.x = pitch

func punch(kind: StringName) -> void:
    if attacking: return
    attacking = true
    attack_time = 0.0
    attack_kind = kind
    hit_targets.clear()
    _play(kind)
    _status("JAB" if kind == &"Punch_Jab" else "CROSS")

func take_damage(amount: int) -> void:
    health = max(health - amount, 0)
    _status("DARBE ALDI  %d HP" % health)
    if health == 0:
        _play(&"Death01")
        set_physics_process(false)

func _play(name: StringName) -> void:
    if animation_player.has_animation(name) and animation_player.current_animation != name:
        animation_player.play(name, 0.08)

func _status(text: String) -> void:
    if hud:
        var label := hud.get_node_or_null("Status") as Label
        if label: label.text = text
