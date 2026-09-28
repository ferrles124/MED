extends StaticBody3D

@export_enum("static", "moving", "bounce", "breakable", "vanishing", "rotating") var behavior: String = "static"
@export var movement_axis := Vector3.RIGHT
@export var movement_distance := 2.0
@export var movement_speed := 1.0
@export var bounce_force := 12.0
@export var break_delay := 0.45

var _base_position := Vector3.ZERO
var _time := 0.0
var _breaking := false

func _ready() -> void:
	_base_position = position
	_apply_visual_style()

func _physics_process(delta: float) -> void:
	_time += delta
	if behavior == "moving":
		position = _base_position + movement_axis * sin(_time * movement_speed) * movement_distance
	elif behavior == "rotating":
		rotate_y(delta * movement_speed)

func _on_body_entered(body: Node3D) -> void:
	if behavior == "bounce" and body.is_in_group("player"):
		body.velocity.y = bounce_force
	if behavior == "breakable" and body.is_in_group("player") and not _breaking:
		_breaking = true
		await get_tree().create_timer(break_delay).timeout
		visible = false
		$CollisionShape3D.set_deferred("disabled", true)
		await get_tree().create_timer(2.0).timeout
		visible = true
		$CollisionShape3D.set_deferred("disabled", false)
		_breaking = false
	if behavior == "vanishing" and body.is_in_group("player") and not _breaking:
		_breaking = true
		await get_tree().create_timer(break_delay).timeout
		visible = false
		$CollisionShape3D.set_deferred("disabled", true)
		await get_tree().create_timer(1.7).timeout
		visible = true
		$CollisionShape3D.set_deferred("disabled", false)
		_breaking = false

func _apply_visual_style() -> void:
	var colors := {
		"static": Color("#42677b"),
		"moving": Color("#b57b3a"),
		"bounce": Color("#785c9e"),
		"breakable": Color("#9e5960")
		,"vanishing": Color("#5f877e")
	}
	var accent_colors := {
		"static": Color("#82b8c7"),
		"moving": Color("#e4b461"),
		"bounce": Color("#c6a8f0"),
		"breakable": Color("#e5968d")
		,"vanishing": Color("#9ed2bd")
	}
	var main_material := $Mesh.material_override.duplicate() as StandardMaterial3D
	main_material.albedo_color = colors.get(behavior, colors["static"])
	main_material.emission = main_material.albedo_color * 0.08
	$Mesh.material_override = main_material
	var trim_material := $Trim.material_override.duplicate() as StandardMaterial3D
	trim_material.albedo_color = accent_colors.get(behavior, accent_colors["static"])
	trim_material.emission = trim_material.albedo_color * 0.18
	$Trim.material_override = trim_material
