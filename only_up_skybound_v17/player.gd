extends CharacterBody3D

@export_category("Movement")
@export var walk_speed: float = 5.2
@export var air_control: float = 0.62
@export var jump_velocity: float = 10.0
@export var gravity: float = 20.0
@export var coyote_time: float = 0.12

@export_category("Ledge Grab")
@export var ledge_grab_enabled: bool = true
@export var ledge_forward_distance: float = 0.9
@export var ledge_chest_height: float = 1.0
@export var ledge_top_height: float = 2.25
@export var ledge_min_height: float = 0.35
@export var ledge_max_height: float = 2.45
@export var climb_duration: float = 0.58
@export var landing_shake_strength: float = 0.08

@export_category("Camera")
@export var mouse_sensitivity: float = 0.0025
@export var mobile_sensitivity: float = 0.004
@export var camera_distance: float = 5.6
@export var camera_height: float = 2.35

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var animation_player: AnimationPlayer = find_child("AnimationPlayer", true, false)
@onready var mobile_controls: Control = get_node_or_null("../HUD/MobileControls")
@onready var world = get_parent()

var yaw: float = 0.0
var pitch: float = -0.18
var coyote_left: float = 0.0
var respawn_lock: float = 0.0
var landing_bump: float = 0.0
var previous_vertical_velocity: float = 0.0
var is_grabbing_ledge: bool = false
var grab_start: Vector3
var grab_target: Vector3
var climb_elapsed: float = 0.0
var camera_shake: float = 0.0
var first_person := false

func _ready() -> void:
	add_to_group("player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_update_view_camera()
	play_animation(&"Idle")
	_update_camera()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_look(event.relative * mouse_sensitivity)
	elif event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event is InputEventKey and event.keycode == KEY_R and event.pressed:
		respawn_at(world.checkpoint_position)
	elif event is InputEventKey and event.keycode == KEY_V and event.pressed:
		toggle_view()

func _physics_process(delta: float) -> void:
	if respawn_lock > 0.0:
		respawn_lock -= delta
	landing_bump = maxf(0.0, landing_bump - delta)
	camera_shake = maxf(0.0, camera_shake - delta * 0.9)
	if is_grabbing_ledge:
		_process_ledge_climb(delta)
		_update_camera()
		return
	if mobile_controls:
		_look(mobile_controls.consume_look_delta() * mobile_sensitivity)
		if mobile_controls.jump_requested:
			mobile_controls.jump_requested = false
			_jump()
	var input := _read_input()
	var local := Vector3(input.x, 0.0, input.y)
	if local.length_squared() > 1.0:
		local = local.normalized()
	var direction := Basis(Vector3.UP, yaw) * local
	var control := 1.0 if is_on_floor() else air_control
	var target := direction * walk_speed
	velocity.x = move_toward(velocity.x, target.x, 32.0 * control * delta)
	velocity.z = move_toward(velocity.z, target.z, 32.0 * control * delta)
	if is_on_floor():
		coyote_left = coyote_time
		if Input.is_action_just_pressed("jump"):
			_jump()
			if previous_vertical_velocity < -6.0:
				landing_bump = 0.12
				camera_shake = landing_shake_strength
				if world.has_method("play_sfx"):
					world.play_sfx("landing")
	else:
		coyote_left = maxf(0.0, coyote_left - delta)
		velocity.y -= gravity * delta
		if velocity.y < 0.0:
			_try_ledge_grab()
	if Input.is_action_just_released("jump") and velocity.y > 0.0:
		velocity.y *= 0.55
	previous_vertical_velocity = velocity.y
	if not is_grabbing_ledge:
		move_and_slide()
	if global_position.y < -20.0 and respawn_lock <= 0.0:
		respawn_at(world.checkpoint_position)
	_update_animation(input)
	_update_camera()

func _read_input() -> Vector2:
	if mobile_controls and mobile_controls.move_vector.length_squared() > 0.01:
		return mobile_controls.move_vector
	return Input.get_vector("move_left", "move_right", "move_forward", "move_back")

func _jump() -> void:
	if is_on_floor() or coyote_left > 0.0:
		velocity.y = jump_velocity
		coyote_left = 0.0
		play_animation(&"Jump_Start")
		if world.has_method("play_sfx"):
			world.play_sfx("jump")

func toggle_view() -> void:
	first_person = not first_person
	_update_view_camera()
	_set_status("1. şahıs kamera" if first_person else "3. şahıs kamera")

func _update_view_camera() -> void:
	if first_person:
		camera.position = Vector3(0, 1.52, 0.08)
		camera.fov = 76.0
	else:
		camera.position = Vector3(0, camera_height, camera_distance)
		camera.fov = 70.0

func _try_ledge_grab() -> void:
	if not ledge_grab_enabled or is_grabbing_ledge or velocity.y >= 0.0:
		return
	var forward := -global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var space := get_world_3d().direct_space_state
	var chest_from := global_position + Vector3.UP * ledge_chest_height
	var chest_to := chest_from + forward * ledge_forward_distance
	var wall_query := PhysicsRayQueryParameters3D.create(chest_from, chest_to)
	wall_query.exclude = [self]
	var wall_hit := space.intersect_ray(wall_query)
	if wall_hit.is_empty():
		return
	var top_from := global_position + Vector3.UP * ledge_top_height + forward * 0.7
	var top_to := global_position + Vector3.UP * 0.05 + forward * 0.7
	var top_query := PhysicsRayQueryParameters3D.create(top_from, top_to)
	top_query.exclude = [self]
	var top_hit := space.intersect_ray(top_query)
	if top_hit.is_empty():
		return
	var top_y: float = top_hit.position.y
	var height_difference: float = top_y - global_position.y
	if height_difference < ledge_min_height or height_difference > ledge_max_height:
		return
	grab_start = global_position
	grab_target = top_hit.position + Vector3.UP * 1.05 - forward * 0.38
	climb_elapsed = 0.0
	velocity = Vector3.ZERO
	is_grabbing_ledge = true
	var climb_animation: StringName = &"Roll_RM" if animation_player and animation_player.has_animation(&"Roll_RM") else &"Roll"
	play_animation(climb_animation)
	_set_status("KENARA TUTUNDUN! Yukarı çekiliyorsun...")

func _process_ledge_climb(delta: float) -> void:
	climb_elapsed += delta
	var progress: float = clampf(climb_elapsed / climb_duration, 0.0, 1.0)
	var smooth_progress: float = progress * progress * (3.0 - 2.0 * progress)
	global_position = grab_start.lerp(grab_target, smooth_progress)
	if progress >= 1.0:
		global_position = grab_target
		velocity = Vector3.ZERO
		is_grabbing_ledge = false
		landing_bump = 0.12
		camera_shake = landing_shake_strength * 1.8
		play_animation(&"Idle")
		_set_status("İyi kurtardın! Tırmanmaya devam et.")

func _look(delta_look: Vector2) -> void:
	yaw -= delta_look.x
	pitch = clamp(pitch - delta_look.y, deg_to_rad(-55.0), deg_to_rad(28.0))
	rotation.y = yaw

func _update_camera() -> void:
	camera_pivot.rotation.x = pitch
	var shake_offset := Vector3.ZERO
	if camera_shake > 0.0:
		shake_offset = Vector3(sin(Time.get_ticks_msec() * 0.045), cos(Time.get_ticks_msec() * 0.055), 0) * camera_shake
	camera_pivot.position = Vector3(0, 1.2 + landing_bump * 0.8, 0) + shake_offset

func _update_animation(input: Vector2) -> void:
	if is_grabbing_ledge:
		return
	if not is_on_floor():
		play_animation(&"Jump" if velocity.y > 0.0 else &"Jump_Land")
	elif input.length_squared() > 0.01:
		play_animation(&"Walk")
	else:
		play_animation(&"Idle")

func play_animation(name: StringName) -> void:
	if animation_player and animation_player.has_animation(name) and animation_player.current_animation != name:
		animation_player.play(name, 0.12)

func _set_status(message: String) -> void:
	var status := get_node_or_null("../HUD/Status") as Label
	if status:
		status.text = message

func respawn_at(pos: Vector3) -> void:
	respawn_lock = 0.7
	is_grabbing_ledge = false
	global_position = pos
	velocity = Vector3.ZERO
	play_animation(&"Idle")
