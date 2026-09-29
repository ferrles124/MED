extends CharacterBody3D
class_name FracturePlayer

signal died

@export var move_speed := 5.8
@export var acceleration := 22.0
@export var mouse_sensitivity := 0.0024
@export var gravity := 18.0

var game: Node
var health := 100
var alive := true
var pitch := 0.0
var spawn_position := Vector3.ZERO
var recoil := 0.0
var weapon: Node3D
var mobile_controls: Control

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var primary_weapon: Node3D = $Head/Camera3D/WeaponAnchor/StriderCarbine
@onready var secondary_weapon: Node3D = $Head/Camera3D/WeaponAnchor/LumenPistol
@onready var body_visual: Node3D = $Visual
@onready var health_bar: ProgressBar = $HealthBar

func _ready() -> void:
    add_to_group("player")
    spawn_position = global_position
    camera.current = true
    weapon = primary_weapon
    primary_weapon.visible = true
    secondary_weapon.visible = false
    health_bar.visible = false

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch or event is InputEventScreenDrag:
        return
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and alive:
        rotate_y(-event.relative.x * mouse_sensitivity)
        pitch = clampf(pitch - event.relative.y * mouse_sensitivity, -1.25, 1.25)
        head.rotation.x = pitch
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
        elif alive and game != null and game.is_live():
            _fire_weapon()
    if event is InputEventKey and event.pressed and not event.echo:
        if event.physical_keycode == KEY_R and alive:
            weapon.reload()
        elif event.physical_keycode == KEY_1:
            _equip(primary_weapon)
        elif event.physical_keycode == KEY_2:
            _equip(secondary_weapon)

func _physics_process(delta: float) -> void:
    if mobile_controls == null and game != null:
        mobile_controls = game.hud.mobile_controls
    if mobile_controls != null and mobile_controls.visible:
        var mobile_look: Vector2 = mobile_controls.consume_look_delta()
        if alive and mobile_look.length_squared() > 0.0:
            rotate_y(-mobile_look.x * mouse_sensitivity)
            pitch = clampf(pitch - mobile_look.y * mouse_sensitivity, -1.25, 1.25)
            head.rotation.x = pitch
        if mobile_controls.consume_reload() and alive:
            weapon.reload()
        if mobile_controls.consume_weapon_switch():
            _equip(secondary_weapon if weapon == primary_weapon else primary_weapon)
        if mobile_controls.consume_interact() and game != null and game.is_live():
            game.request_interact()
        if mobile_controls.fire_pressed and alive and game != null and game.is_live():
            _fire_weapon()
    if not is_on_floor():
        velocity.y -= gravity * delta
    else:
        velocity.y = -0.2
    var input_vector: Vector2 = mobile_controls.get_move_vector() if mobile_controls != null and mobile_controls.visible else Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var wish_dir := (transform.basis * Vector3(input_vector.x, 0.0, input_vector.y)).normalized()
    var target := wish_dir * move_speed if alive else Vector3.ZERO
    velocity.x = move_toward(velocity.x, target.x, acceleration * delta)
    velocity.z = move_toward(velocity.z, target.z, acceleration * delta)
    move_and_slide()
    if alive:
        var bob := sin(Time.get_ticks_msec() * 0.009) * minf(velocity.length() / move_speed, 1.0) * 0.018
        head.position.y = 0.68 + bob
        recoil = move_toward(recoil, 0.0, delta * 5.0)
        head.rotation.x = pitch - recoil
    if global_position.y < -10.0:
        reset_for_round()

func _fire_weapon() -> void:
    if not weapon.try_fire():
        return
    recoil = weapon.recoil_amount
    var origin := camera.global_position
    var direction := -camera.global_transform.basis.z
    var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * weapon.range)
    query.exclude = [self]
    query.collision_mask = 1
    var hit := get_world_3d().direct_space_state.intersect_ray(query)
    if not hit.is_empty():
        var target = hit.get("collider")
        if target != null and target.has_method("apply_damage"):
            target.apply_damage(weapon.damage)
        var impact := MeshInstance3D.new()
        var sphere := SphereMesh.new()
        sphere.radius = 0.045
        sphere.height = 0.09
        impact.mesh = sphere
        impact.material_override = weapon.impact_material()
        impact.global_position = hit.position
        get_tree().current_scene.add_child(impact)
        get_tree().create_timer(0.12).timeout.connect(impact.queue_free)

func _equip(next_weapon: Node3D) -> void:
    if not is_instance_valid(next_weapon):
        return
    primary_weapon.visible = next_weapon == primary_weapon
    secondary_weapon.visible = next_weapon == secondary_weapon
    weapon = next_weapon

func apply_damage(amount: int) -> void:
    if not alive:
        return
    health = maxi(0, health - amount)
    if game != null:
        game.hud.set_damage_flash()
    if health <= 0:
        alive = false
        body_visual.visible = false
        collision_layer = 0
        died.emit()

func reset_for_round() -> void:
    global_position = spawn_position
    velocity = Vector3.ZERO
    rotation = Vector3.ZERO
    head.rotation = Vector3.ZERO
    pitch = 0.0
    health = 100
    alive = true
    body_visual.visible = true
    collision_layer = 1
    weapon.reset_weapon()
