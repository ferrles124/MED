extends Area3D

signal finish_reached
var triggered := false

func _ready() -> void:
	add_to_group("finish")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if triggered or not body.is_in_group("player"):
		return
	triggered = true
	finish_reached.emit()
