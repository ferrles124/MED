extends CharacterBody3D

signal mode_action_requested

@export var move_speed := 4.8
@export var gravity := 18.0
@export var jump_velocity := 7.0

@onready var model: Node3D = $Character
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var animation_player: AnimationPlayer = find_child("AnimationPlayer", true, false)
@onready var mobile_controls = get_node_or_null("../HUD/MobileControls")

var disguised := false
var current_prop: Node3D
var mode := "player"
var yaw := 0.0
var pitch := -0.14
var landing_timer := 0.0

func _ready() -> void:
    play_animation(&"Idle_Loop")
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        yaw -= event.relative.x * 0.0025
        pitch = clamp(pitch - event.relative.y * 0.002, -0.9, 0.45)
        rotation.y = yaw
    elif event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    elif event is InputEventMouseButton and event.pressed:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

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
    var was_on_floor := is_on_floor()
    if not was_on_floor:
        velocity.y -= gravity * delta
    elif Input.is_action_just_pressed("jump"):
        _jump()
    var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    if mobile_controls and mobile_controls.move_vector.length_squared() > 0.01:
        input = mobile_controls.move_vector
    var direction := Basis(Vector3.UP, yaw) * Vector3(input.x, 0.0, input.y)
    if direction.length_squared() > 1.0:
        direction = direction.normalized()
    velocity.x = move_toward(velocity.x, direction.x * move_speed, 24.0 * delta)
    velocity.z = move_toward(velocity.z, direction.z * move_speed, 24.0 * delta)
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
    elif landing_timer <= 0.0:
        if direction.length_squared() > 0.01:
            play_animation(&"Sprint_Loop" if Input.is_key_pressed(KEY_SHIFT) else &"Walk_Loop")
        else:
            play_animation(&"Idle_Loop")

func _jump() -> void:
    if is_on_floor():
        velocity.y = jump_velocity
        play_animation(&"Jump_Start")

func set_disguised(prop: Node3D) -> void:
    disguised = true
    current_prop = prop
    model.visible = false
    global_position = prop.global_position + Vector3(0, 0.45, 0)
    velocity = Vector3.ZERO

func clear_disguise() -> void:
    disguised = false
    model.visible = true
    if current_prop:
        global_position = current_prop.global_position + Vector3(1.5, 0.2, 0)
    current_prop = null
    play_animation(&"Idle_Loop")

func set_mode(new_mode: String) -> void:
    mode = new_mode
    if mode == "hunter" and disguised:
        clear_disguise()

func play_animation(name: StringName) -> void:
    if animation_player and animation_player.has_animation(name) and animation_player.current_animation != name:
        animation_player.play(name, 0.12)
