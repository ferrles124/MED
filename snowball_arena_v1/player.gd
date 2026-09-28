extends CharacterBody3D

@export var speed := 6.0
@export var gravity := 20.0
@export var max_charge_time := 2.4
@export var max_ball_radius := 1.65

@onready var camera_pivot: Node3D = $CameraPivot
@onready var spring_arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var arena = get_parent()

var camera_yaw := 0.0
var camera_pitch := -0.18
var charging := false
var charge_time := 0.0
var held_ball: MeshInstance3D
var held_ball_material: StandardMaterial3D

func _ready() -> void:
    add_to_group("players")
    _create_held_ball()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        _look(event.screen_relative * Vector2(0.0025, 0.002))
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
            _start_charge()
        else:
            _release_snowball()
    elif event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta
    var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction := Basis(Vector3.UP, camera_yaw) * Vector3(input.x, 0.0, input.y)
    if direction.length_squared() > 1.0:
        direction = direction.normalized()
    velocity.x = move_toward(velocity.x, direction.x * speed, 30.0 * delta)
    velocity.z = move_toward(velocity.z, direction.z * speed, 30.0 * delta)
    move_and_slide()
    camera_pivot.rotation = Vector3(camera_pitch, camera_yaw, 0.0)
    if charging:
        charge_time = min(charge_time + delta, max_charge_time)
        _update_held_ball()
    if Input.is_action_just_pressed("charge") and not charging:
        _start_charge()
    elif Input.is_action_just_released("charge") and charging:
        _release_snowball()

func _look(delta_look: Vector2) -> void:
    camera_yaw -= delta_look.x
    camera_pitch = clamp(camera_pitch - delta_look.y, -0.85, 0.4)
    camera_pivot.rotation = Vector3(camera_pitch, camera_yaw, 0.0)

func _start_charge() -> void:
    if charging:
        return
    charging = true
    charge_time = 0.0
    held_ball.visible = true
    _update_held_ball()
    arena.show_status("KARTOPU BÜYÜYOR  •  bırakınca fırlat")

func _release_snowball() -> void:
    if not charging:
        return
    var power: float = clampf(charge_time / max_charge_time, 0.18, 1.0)
    var radius: float = lerpf(0.35, max_ball_radius, power)
    var forward: Vector3 = -camera.global_transform.basis.z
    charging = false
    held_ball.visible = false
    arena.launch_snowball(global_position + Vector3.UP * 1.15 + forward * 0.9, forward, radius, power)
    charge_time = 0.0
    arena.show_status("KARTOPU FIRLATILDI!")

func _create_held_ball() -> void:
    held_ball = MeshInstance3D.new()
    held_ball.name = "HeldSnowball"
    var mesh := SphereMesh.new()
    mesh.radius = 0.35
    mesh.height = 0.7
    mesh.radial_segments = 20
    mesh.rings = 12
    held_ball.mesh = mesh
    held_ball_material = StandardMaterial3D.new()
    held_ball_material.albedo_color = Color(0.92, 0.98, 1.0, 1)
    held_ball_material.roughness = 0.95
    held_ball.material_override = held_ball_material
    add_child(held_ball)
    held_ball.position = Vector3(0.55, 0.25, -0.55)
    held_ball.visible = false

func _update_held_ball() -> void:
    var power: float = clampf(charge_time / max_charge_time, 0.0, 1.0)
    var radius: float = lerpf(0.35, max_ball_radius, power)
    held_ball.scale = Vector3.ONE * (radius / 0.35)
    held_ball.position = Vector3(0.55, 0.25 + radius * 0.35, -0.65 - radius * 0.15)
