extends Area3D

@export var value := 100
var collected := false
var base_y := 0.0

func _ready() -> void:
	base_y = position.y
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	rotate_y(delta * 2.2)
	position.y = base_y + sin(Time.get_ticks_msec() * 0.003) * 0.12

func _on_body_entered(body: Node3D) -> void:
	if collected or not body.is_in_group("player"):
		return
	collected = true
	var world = get_tree().current_scene
	if world == null:
		world = get_parent().get_parent()
	if world and world.has_method("collect_star"):
		world.collect_star(value)
	queue_free()
