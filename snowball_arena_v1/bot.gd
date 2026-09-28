extends CharacterBody3D

var arena
var target_point := Vector3.ZERO
var wander_timer := 0.0
var knocked := false
var knock_timer := 0.0
var bot_color: Color

func setup(owner, color: Color, start: Vector3) -> void:
    arena = owner
    bot_color = color
    global_position = start
    target_point = start
    _build_visual()

func _physics_process(delta: float) -> void:
    if knocked:
        velocity.y -= 20.0 * delta
        move_and_slide()
        knock_timer -= delta
        if knock_timer <= 0.0:
            knocked = false
        return
    wander_timer -= delta
    if wander_timer <= 0.0:
        wander_timer = randf_range(1.0, 3.0)
        target_point = Vector3(randf_range(-15.0, 15.0), 1.0, randf_range(-15.0, 15.0))
    var direction := target_point - global_position
    direction.y = 0.0
    if direction.length() > 0.5:
        direction = direction.normalized()
        velocity.x = direction.x * 2.3
        velocity.z = direction.z * 2.3
        rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), delta * 4.0)
    else:
        velocity.x = move_toward(velocity.x, 0.0, 10.0 * delta)
        velocity.z = move_toward(velocity.z, 0.0, 10.0 * delta)
    velocity.y -= 20.0 * delta if not is_on_floor() else 0.0
    move_and_slide()

func knock_back(from: Vector3, strength: float) -> void:
    var away := global_position - from
    away.y = 0.0
    if away.length_squared() < 0.01:
        away = Vector3.FORWARD
    away = away.normalized()
    velocity = away * (8.0 + strength * 7.0) + Vector3.UP * (5.0 + strength * 4.0)
    knocked = true
    knock_timer = 1.4
    arena.register_hit(self)

func _build_visual() -> void:
    var body := MeshInstance3D.new()
    var mesh := CapsuleMesh.new()
    mesh.radius = 0.48
    mesh.height = 1.8
    mesh.radial_segments = 16
    body.mesh = mesh
    var material := StandardMaterial3D.new()
    material.albedo_color = bot_color
    material.roughness = 0.8
    body.material_override = material
    add_child(body)
    var collision := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = 0.48
    shape.height = 1.8
    collision.shape = shape
    add_child(collision)
