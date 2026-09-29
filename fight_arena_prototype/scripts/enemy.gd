extends CharacterBody3D
class_name FightEnemy

@export var health := 100
@export var move_speed := 1.8
@onready var animation_player: AnimationPlayer = $Character/AnimationPlayer
@onready var hit_area: Area3D = $HitArea
var target: Node3D
var attacking := false
var attack_time := 0.0

func _ready() -> void:
    target = get_tree().get_first_node_in_group("player")
    hit_area.monitoring = false
    hit_area.body_entered.connect(_on_hit_body_entered)
    _play(&"Idle")

func _on_hit_body_entered(body: Node3D) -> void:
    if attacking and body.has_method("take_damage"):
        body.take_damage(12)

func _physics_process(delta: float) -> void:
    if not is_instance_valid(target): return
    var offset := target.global_position - global_position
    offset.y = 0
    if offset.length() > 2.0:
        velocity = offset.normalized() * move_speed
        _play(&"Walk")
    else:
        velocity = Vector3.ZERO
        if not attacking:
            _play(&"Idle")
            if Time.get_ticks_msec() % 1600 < 30: _attack()
    if attacking:
        attack_time += delta
        hit_area.monitoring = attack_time > 0.25 and attack_time < 0.48
        if attack_time > 0.9:
            attacking = false
            hit_area.monitoring = false
    move_and_slide()

func _attack() -> void:
    attacking = true
    attack_time = 0.0
    _play(&"Punch_Jab")

func take_damage(amount: int) -> void:
    health -= amount
    _play(&"Hit_Chest")
    if health <= 0:
        _play(&"Death01")
        set_physics_process(false)

func _play(name: StringName) -> void:
    if animation_player.has_animation(name): animation_player.play(name, 0.08)
