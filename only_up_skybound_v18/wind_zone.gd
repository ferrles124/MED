extends Area3D

@export var wind_force := Vector3(2.5, 0, 0)
var bodies: Array[CharacterBody3D] = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
	for body in bodies:
		if is_instance_valid(body):
			body.velocity += wind_force * delta

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and body.is_in_group("player"):
		bodies.append(body)

func _on_body_exited(body: Node3D) -> void:
	if body in bodies:
		bodies.erase(body)
