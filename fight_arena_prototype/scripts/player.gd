extends CharacterBody3D
class_name FightPlayer

@export var move_speed := 4.8
@export var acceleration := 18.0
@export var gravity := 22.0
@export var jump_velocity := 7.0
@onready var animation_player: AnimationPlayer = $Character/AnimationPlayer
@onready var hit_area: Area3D = $PunchHitArea
@onready var hud: CanvasLayer = get_node_or_null("../HUD")
var mobile_move := Vector2.ZERO
var attacking := false
var attack_time := 0.0
var attack_kind := &"Punch_Jab"
var health := 100

func _ready() -> void:
    add_to_group("player")
    hit_area.monitoring = false
    hit_area.body_entered.connect(_on_punch_body_entered)
    _play(&"Idle")

func _on_punch_body_entered(body: Node3D) -> void:
    if attacking and body.has_method("take_damage"):
        body.take_damage(18 if attack_kind == &"Punch_Jab" else 26)

func _physics_process(delta: float) -> void:
    var controls := get_node_or_null("../HUD/MobileControls")
    if controls:
        var mobile_controls := controls as FightMobileControls
        if mobile_controls == null: return
        mobile_move = mobile_controls.move_vector
        if mobile_controls.jab_requested:
            mobile_controls.jab_requested = false
            punch(&"Punch_Jab")
        if mobile_controls.cross_requested:
            mobile_controls.cross_requested = false
            punch(&"Punch_Cross")
    var input := mobile_move
    if input.length_squared() < 0.01:
        input = Vector2(Input.get_axis("attack_cross", "attack_cross"), Input.get_axis("attack_jab", "attack_jab")) * 0.0
    var direction := Vector3(input.x, 0.0, input.y)
    if direction.length_squared() > 1.0: direction = direction.normalized()
    velocity.x = move_toward(velocity.x, direction.x * move_speed, acceleration * delta)
    velocity.z = move_toward(velocity.z, direction.z * move_speed, acceleration * delta)
    if not is_on_floor(): velocity.y -= gravity * delta
    elif Input.is_action_just_pressed("jump"): velocity.y = jump_velocity
    if not attacking:
        _play(&"Walk" if direction.length_squared() > 0.01 else &"Idle")
    else:
        attack_time += delta
        if attack_time > 0.22 and attack_time < 0.48: hit_area.monitoring = true
        else: hit_area.monitoring = false
        if attack_time > animation_player.get_animation(attack_kind).length:
            attacking = false
            hit_area.monitoring = false
            _play(&"Idle")
    move_and_slide()

func punch(kind: StringName) -> void:
    if attacking: return
    attacking = true
    attack_time = 0.0
    attack_kind = kind
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
