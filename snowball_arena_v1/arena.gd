extends Node3D

var bot_script = preload("res://bot.gd")
var rng := RandomNumberGenerator.new()
var score := 0
var shots := 0
var hit_count := 0
var status_label: Label
var score_label: Label
var snowballs: Array[Node3D] = []

func _ready() -> void:
    rng.randomize()
    _build_world()
    _build_ui()
    for i in range(8):
        _spawn_bot(i)
    show_status("WASD hareket  •  sol tık basılı tut: kartopu büyüt  •  bırak: fırlat")

func _process(delta: float) -> void:
    for snowball in snowballs.duplicate():
        if not is_instance_valid(snowball):
            snowballs.erase(snowball)
            continue
        snowball.position += snowball.get_meta("velocity", Vector3.ZERO) * delta
        snowball.rotate_x(delta * 8.0)
        for bot in get_tree().get_nodes_in_group("bots"):
            if is_instance_valid(bot) and not bot.knocked and snowball.global_position.distance_to(bot.global_position + Vector3.UP * 0.9) < float(snowball.get_meta("radius", 0.5)) + 0.7:
                bot.knock_back(snowball.global_position, float(snowball.get_meta("power", 0.5)))
                _remove_snowball(snowball)
                break
        if is_instance_valid(snowball) and (abs(snowball.position.x) > 24.0 or abs(snowball.position.z) > 24.0 or snowball.position.y < -3.0):
            _remove_snowball(snowball)
    for bot in get_tree().get_nodes_in_group("bots"):
        if is_instance_valid(bot) and (abs(bot.position.x) > 21.0 or abs(bot.position.z) > 21.0 or bot.position.y < -3.0):
            score += 1
            bot.queue_free()
            _spawn_bot(rng.randi_range(0, 99))
            _refresh_score()

func _build_world() -> void:
    var floor := MeshInstance3D.new()
    var floor_mesh := BoxMesh.new()
    floor_mesh.size = Vector3(42, 0.5, 42)
    floor.mesh = floor_mesh
    floor.position.y = -0.25
    var floor_mat := StandardMaterial3D.new()
    floor_mat.albedo_color = Color(0.78, 0.9, 0.98, 1)
    floor_mat.roughness = 1.0
    floor.material_override = floor_mat
    add_child(floor)
    var floor_collision := StaticBody3D.new()
    var floor_shape := CollisionShape3D.new()
    var box_shape := BoxShape3D.new()
    box_shape.size = Vector3(42, 0.5, 42)
    floor_shape.shape = box_shape
    floor_collision.add_child(floor_shape)
    floor_collision.position.y = -0.25
    add_child(floor_collision)
    for pos in [Vector3(-20, 1.5, 0), Vector3(20, 1.5, 0), Vector3(0, 1.5, -20), Vector3(0, 1.5, 20)]:
        _build_bank(pos)

func _build_bank(pos: Vector3) -> void:
    var bank := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = Vector3(1.3, 3.0, 42.0) if abs(pos.x) > 0 else Vector3(42.0, 3.0, 1.3)
    bank.mesh = mesh
    bank.position = pos
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.62, 0.82, 0.94, 1)
    bank.material_override = mat
    add_child(bank)

func _spawn_bot(seed_value: int) -> void:
    var bot := CharacterBody3D.new()
    bot.name = "Bot_%02d" % seed_value
    bot.set_script(bot_script)
    bot.add_to_group("bots")
    add_child(bot)
    var palette := [Color(0.9, 0.2, 0.25), Color(0.95, 0.55, 0.12), Color(0.55, 0.25, 0.9), Color(0.1, 0.65, 0.45)]
    bot.setup(self, palette[seed_value % palette.size()], Vector3(rng.randf_range(-14, 14), 1.0, rng.randf_range(-14, 8)))

func launch_snowball(start: Vector3, direction: Vector3, radius: float, power: float) -> void:
    shots += 1
    var ball := MeshInstance3D.new()
    ball.name = "SnowballProjectile"
    var mesh := SphereMesh.new()
    mesh.radius = radius
    mesh.height = radius * 2.0
    mesh.radial_segments = 24
    mesh.rings = 16
    ball.mesh = mesh
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.95, 0.99, 1.0, 1)
    mat.roughness = 0.9
    ball.material_override = mat
    ball.position = start
    ball.set_meta("velocity", direction.normalized() * (13.0 + power * 17.0))
    ball.set_meta("radius", radius)
    ball.set_meta("power", power)
    add_child(ball)
    snowballs.append(ball)
    _refresh_score()

func _remove_snowball(ball: Node3D) -> void:
    snowballs.erase(ball)
    if is_instance_valid(ball):
        ball.queue_free()

func register_hit(_bot: Node3D) -> void:
    hit_count += 1
    score += 10
    _refresh_score()
    show_status("İSABET! Rakip savruldu  •  +10")

func _build_ui() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    var panel := ColorRect.new()
    panel.color = Color(0.02, 0.08, 0.16, 0.72)
    panel.position = Vector2(22, 20)
    panel.size = Vector2(430, 105)
    layer.add_child(panel)
    score_label = Label.new()
    score_label.position = Vector2(18, 12)
    score_label.add_theme_font_size_override("font_size", 24)
    panel.add_child(score_label)
    status_label = Label.new()
    status_label.position = Vector2(18, 58)
    status_label.add_theme_font_size_override("font_size", 16)
    panel.add_child(status_label)
    var cross := Label.new()
    cross.text = "+"
    cross.position = Vector2(638, 342)
    cross.add_theme_font_size_override("font_size", 30)
    layer.add_child(cross)
    _refresh_score()

func _refresh_score() -> void:
    if score_label:
        score_label.text = "SNOWBALL ARENA\nSkor: %d   İsabet: %d   Atış: %d" % [score, hit_count, shots]

func show_status(message: String) -> void:
    if status_label:
        status_label.text = message
