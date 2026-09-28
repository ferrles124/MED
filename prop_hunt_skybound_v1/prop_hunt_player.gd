extends CharacterBody3D

signal mode_action_requested

@export var move_speed := 4.8
@export var gravity := 18.0
@export var jump_velocity := 7.0

@onready var model: Node3D = $Character
@onready var camera_pivot: Node3D = $CameraPivot
@onready var spring_arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var animation_player: AnimationPlayer = find_child("AnimationPlayer", true, false)
@onready var mobile_controls = get_node_or_null("../HUD/MobileControls")

var disguised := false
var current_prop: Node3D
var disguise_visual: Node3D
var mode := "player"
var camera_yaw := 0.0
var camera_pitch := -0.14
var landing_timer := 0.0

func _ready() -> void:
    play_animation(&"Idle_Loop")
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        _apply_look(event.screen_relative * Vector2(0.0025, 0.002))
    elif event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    elif event is InputEventMouseButton and event.pressed:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _apply_look(delta_look: Vector2) -> void:
    camera_yaw -= delta_look.x
    camera_pitch = clamp(camera_pitch - delta_look.y, -0.85, 0.42)
    camera_pivot.rotation = Vector3(camera_pitch, camera_yaw, 0.0)

func _physics_process(delta: float) -> void:
    if landing_timer > 0.0:
        landing_timer -= delta
    if Input.is_action_just_pressed("interact"):
        mode_action_requested.emit()
    if mobile_controls:
        if mobile_controls.action_requested:
            mobile_controls.action_requested = false
            mode_action_requested.emit()
        if mobile_controls.jump_requested:
            mobile_controls.jump_requested = false
            _jump()
        if mobile_controls.look_delta.length_squared() > 0.0001:
            _apply_look(mobile_controls.look_delta)
            mobile_controls.look_delta = Vector2.ZERO
    var was_on_floor := is_on_floor()
    if not was_on_floor:
        velocity.y -= gravity * delta
    elif Input.is_action_just_pressed("jump"):
        _jump()
    var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    if mobile_controls and mobile_controls.move_vector.length_squared() > 0.01:
        input = mobile_controls.move_vector
    var direction := Basis(Vector3.UP, camera_yaw) * Vector3(input.x, 0.0, input.y)
    if direction.length_squared() > 1.0:
        direction = direction.normalized()
    velocity.x = move_toward(velocity.x, direction.x * move_speed, 24.0 * delta)
    velocity.z = move_toward(velocity.z, direction.z * move_speed, 24.0 * delta)
    if direction.length_squared() > 0.01 and not disguised:
        rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), delta * 8.0)
    move_and_slide()
    var now_on_floor := is_on_floor()
    if not was_on_floor and now_on_floor:
        landing_timer = 0.28
        play_animation(&"Jump_Land")
    elif not now_on_floor:
        if velocity.y > 0.0:
            play_animation(&"Jump_Loop")
        else:
            play_animation(&"Jump_Land")
    elif landing_timer <= 0.0 and not disguised:
        if direction.length_squared() > 0.01:
            play_animation(&"Sprint_Loop" if Input.is_key_pressed(KEY_SHIFT) else &"Walk_Loop")
        else:
            play_animation(&"Idle_Loop")
    camera_pivot.rotation = Vector3(camera_pitch, camera_yaw, 0.0)

func _jump() -> void:
    if is_on_floor():
        velocity.y = jump_velocity
        play_animation(&"Jump_Start")

func set_disguised(prop: Node3D) -> void:
    if disguised:
        return
    disguised = true
    current_prop = prop
    model.visible = false
    # The original prop stays exactly where it is. Only the player collision is disabled.
    collision_layer = 0
    collision_mask = 0
    var packed := load(current_prop.scene_file_path) as PackedScene
    if packed:
        disguise_visual = packed.instantiate()
        disguise_visual.name = "DisguiseCopy"
        add_child(disguise_visual)
        disguise_visual.position = Vector3.ZERO
        disguise_visual.rotation = current_prop.global_rotation - global_rotation
        disguise_visual.scale = current_prop.global_transform.basis.get_scale()
        _set_collision_enabled(disguise_visual, false)
    global_position = prop.global_position + Vector3(0, 0.35, 0)
    velocity = Vector3.ZERO
    spring_arm.spring_length = 8.0
    camera.fov = 74.0
    camera_pitch = -0.20
    camera_pivot.rotation = Vector3(camera_pitch, camera_yaw, 0.0)

func clear_disguise() -> void:
    disguised = false
    if disguise_visual and is_instance_valid(disguise_visual):
        disguise_visual.queue_free()
    disguise_visual = null
    if current_prop and is_instance_valid(current_prop):
        global_position = current_prop.global_position + Vector3(1.6, 1.0, 0)
    current_prop = null
    collision_layer = 1
    collision_mask = 1
    model.visible = true
    spring_arm.spring_length = 6.4
    camera.fov = 70.0
    play_animation(&"Idle_Loop")

func _set_collision_enabled(node: Node, enabled: bool) -> void:
    if node is CollisionShape3D:
        node.disabled = not enabled
    if node is CollisionObject3D:
        node.collision_layer = 1 if enabled else 0
        node.collision_mask = 1 if enabled else 0
    for child in node.get_children():
        _set_collision_enabled(child, enabled)

func set_mode(new_mode: String) -> void:
    mode = new_mode
    if mode == "hunter" and disguised:
        clear_disguise()

func play_animation(name: StringName) -> void:
    if animation_player and animation_player.has_animation(name) and animation_player.current_animation != name:
        animation_player.play(name, 0.12)
