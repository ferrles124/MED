extends CharacterBody3D

signal interact_requested

@export var move_speed := 4.8
@export var gravity := 18.0
@export var jump_velocity := 7.0

@onready var model: Node3D = $Character
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var animation_player: AnimationPlayer = find_child("AnimationPlayer", true, false)

var disguised := false
var current_prop: Node3D
var yaw := 0.0
var pitch := -0.14

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
    if Input.is_action_just_pressed("interact"):
        interact_requested.emit()
    if not is_on_floor():
        velocity.y -= gravity * delta
    elif Input.is_action_just_pressed("jump"):
        velocity.y = jump_velocity
    var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction := Vector3(input.x, 0.0, input.y)
    direction = Basis(Vector3.UP, yaw) * direction
    if direction.length_squared() > 1.0:
        direction = direction.normalized()
    velocity.x = move_toward(velocity.x, direction.x * move_speed, 24.0 * delta)
    velocity.z = move_toward(velocity.z, direction.z * move_speed, 24.0 * delta)
    move_and_slide()
    if not disguised:
        if direction.length_squared() > 0.01:
            play_animation(&"Walk_Loop")
        else:
            play_animation(&"Idle_Loop")

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

func play_animation(name: StringName) -> void:
    if animation_player and animation_player.has_animation(name) and animation_player.current_animation != name:
        animation_player.play(name, 0.12)
