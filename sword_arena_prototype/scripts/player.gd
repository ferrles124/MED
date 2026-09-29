extends CharacterBody3D
class_name SwordPrototypePlayer

@export var move_speed := 4.6
@export var acceleration := 18.0
@export var gravity := 22.0
@export var jump_velocity := 7.5
@export var look_sensitivity := 0.004

@onready var character: Node3D = $Character
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var animation_player: AnimationPlayer = $Character/AnimationPlayer
@onready var hit_area: Area3D = $Character/Rig/Skeleton3D/RightHandWeapon/Sword/HitArea
@onready var hud: CanvasLayer = get_node_or_null("../HUD")

var yaw := 0.0
var pitch := -0.12
var mobile_move := Vector2.ZERO
var mobile_look := Vector2.ZERO
var attacking := false
var attack_cooldown := 0.0
var attack_elapsed := 0.0
var attack_hit_done := false
var sword_color := Color(0.25, 0.75, 1.0)

func _ready() -> void:
    add_to_group("player")
    hit_area.monitoring = false
    animation_player.animation_finished.connect(_on_animation_finished)
    play_animation(&"Sword_Idle")
    _set_status("Kılıç hazır — F veya ekrandaki SALDIR düğmesine bas")
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        _look(event.relative * look_sensitivity)
    elif event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    elif event is InputEventMouseButton and event.pressed:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    elif event.is_action_pressed("attack"):
        request_attack()

func _physics_process(delta: float) -> void:
    if attack_cooldown > 0.0:
        attack_cooldown -= delta
    if attacking:
        _update_attack(delta)
    mobile_look = Vector2.ZERO
    var mobile_controls := get_node_or_null("../HUD/MobileControls")
    if mobile_controls:
        mobile_move = mobile_controls.move_vector
        _look(mobile_controls.consume_look_delta() * look_sensitivity)
        if mobile_controls.jump_requested:
            mobile_controls.jump_requested = false
            request_jump()
        if mobile_controls.attack_requested:
            mobile_controls.attack_requested = false
            request_attack()
    var input_vector := mobile_move if mobile_move.length_squared() > 0.01 else Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var local := Vector3(input_vector.x, 0.0, input_vector.y)
    if local.length_squared() > 1.0:
        local = local.normalized()
    var direction := Basis(Vector3.UP, yaw) * local
    var target := direction * move_speed
    velocity.x = move_toward(velocity.x, target.x, acceleration * delta)
    velocity.z = move_toward(velocity.z, target.z, acceleration * delta)
    if not is_on_floor():
        velocity.y -= gravity * delta
    elif Input.is_action_just_pressed("jump"):
        request_jump()
    if is_on_floor() and not attacking:
        if input_vector.length_squared() > 0.01:
            play_animation(&"Walk")
        else:
            play_animation(&"Sword_Idle")
    move_and_slide()
    _update_camera()

func request_jump() -> void:
    if is_on_floor() and not attacking:
        velocity.y = jump_velocity
        play_animation(&"Jump_Start")
        _set_status("Zıplama")

func request_attack() -> void:
    if attacking or attack_cooldown > 0.0:
        return
    attacking = true
    attack_elapsed = 0.0
    attack_hit_done = false
    attack_cooldown = 0.6
    hit_area.monitoring = false
    play_animation(&"Sword_Attack")
    _set_status("KILIÇ SALDIRISI")

func _update_attack(delta: float) -> void:
    attack_elapsed += delta
    if attack_elapsed > 0.18 and attack_elapsed < 0.42 and not attack_hit_done:
        attack_hit_done = true
        hit_area.monitoring = true
        _set_status("Kılıç menzili aktif")
        await get_tree().create_timer(0.10).timeout
        hit_area.monitoring = false
    if attack_elapsed > 0.62:
        attacking = false
        hit_area.monitoring = false
        play_animation(&"Sword_Idle")
        _set_status("Kılıç hazır")

func _on_animation_finished(animation_name: StringName) -> void:
    if animation_name == &"Sword_Attack" and attacking:
        attacking = false
        hit_area.monitoring = false
        play_animation(&"Sword_Idle")

func _look(delta_look: Vector2) -> void:
    yaw -= delta_look.x
    pitch = clamp(pitch - delta_look.y, deg_to_rad(-50.0), deg_to_rad(28.0))
    rotation.y = yaw

func _update_camera() -> void:
    camera_pivot.rotation.x = pitch

func play_animation(name: StringName) -> void:
    if animation_player.has_animation(name) and animation_player.current_animation != name:
        animation_player.play(name, 0.10)

func _set_status(message: String) -> void:
    if hud:
        var label := hud.get_node_or_null("Status") as Label
        if label:
            label.text = message
