extends CharacterBody3D
class_name FightEnemy

@export var health := 100
@onready var animation_player: AnimationPlayer = $Character/AnimationPlayer
@onready var recovery_animation_player: AnimationPlayer = $RecoveryAnimationPlayer
var dead := false
var recovering := false

func _ready() -> void:
    animation_player.animation_finished.connect(_on_character_animation_finished)
    recovery_animation_player.animation_finished.connect(_on_recovery_animation_finished)
    _play(&"Idle")

func take_hit(zone: StringName, amount: int) -> void:
    if dead or recovering: return
    health = max(health - amount, 0)
    if zone == &"head":
        _play(&"Hit_Head")
    else:
        _play(&"Hit_Chest")
    if health <= 0:
        dead = true
        animation_player.play(&"Death01")

func _on_character_animation_finished(name: StringName) -> void:
    if name == &"Death01" and dead:
        recovery_animation_player.play(&"GetUp")
        recovering = true

func _on_recovery_animation_finished(name: StringName) -> void:
    if name != &"GetUp": return
    recovering = false
    dead = false
    health = 100
    animation_player.play(&"Idle")

func _play(name: StringName) -> void:
    if animation_player.has_animation(name):
        animation_player.play(name, 0.08)
