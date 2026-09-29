extends CharacterBody3D
class_name FightEnemy

@export var health := 100
@onready var animation_player: AnimationPlayer = $Character/AnimationPlayer
var dead := false

func _ready() -> void:
    _play(&"Idle")

func take_hit(zone: StringName, amount: int) -> void:
    if dead: return
    health = max(health - amount, 0)
    if zone == &"head":
        _play(&"Hit_Head")
    else:
        _play(&"Hit_Chest")
    if health <= 0:
        dead = true
        _play(&"Death01")

func get_hit_zone() -> StringName:
    return &"chest"

func _play(name: StringName) -> void:
    if animation_player.has_animation(name):
        animation_player.play(name, 0.05)
