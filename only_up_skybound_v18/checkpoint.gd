extends Area3D

signal checkpoint_reached(position: Vector3, height: float)
var activated := false

func _ready() -> void:
	add_to_group("checkpoint")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if activated or not body.is_in_group("player"):
		return
	activated = true
	checkpoint_reached.emit(global_position, global_position.y)
	$Beacon.light_energy = 5.0
