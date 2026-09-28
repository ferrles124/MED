extends Node3D

@onready var player = $Player
@onready var timer_label: Label = $HUD/Timer
@onready var status_label: Label = $HUD/Status
@onready var hint_label: Label = $HUD/Hint
@onready var target_label: Label = $HUD/TargetLabel
@onready var crosshair: Label = $HUD/Crosshair
@onready var mode_panel: Panel = $HUD/ModePanel
@onready var result_panel: Panel = $HUD/ResultPanel
@onready var mobile_controls = $HUD/MobileControls

var props: Array[Node3D] = []
var mode := "player"
var action_count := 0

func _ready() -> void:
    for node in get_tree().get_nodes_in_group("hide_props"):
        props.append(node as Node3D)
    mode_panel.visible = true
    crosshair.visible = false
    target_label.visible = false
    result_panel.visible = false
    timer_label.text = "MOD SEÇ"
    status_label.text = "Oyuncu olarak eşyaya dönüş veya Avcı olarak eşya vurma modunu seç."
    hint_label.text = "WASD / joystick hareket  •  Space zıpla  •  E veya mobil buton etkileşim"
    player.mode_action_requested.connect(perform_mode_action)
    $HUD/ModePanel/PlayerMode.pressed.connect(func(): choose_mode("player"))
    $HUD/ModePanel/HunterMode.pressed.connect(func(): choose_mode("hunter"))

func choose_mode(new_mode: String) -> void:
    mode = new_mode
    player.set_mode(mode)
    mode_panel.visible = false
    crosshair.visible = true
    mobile_controls.set_mode(mode)
    if mode == "player":
        timer_label.text = "OYUNCU MODU"
        status_label.text = "İmleci eşyaya getir ve E / SAKLAN'a bas."
        hint_label.text = "İmleç: hedef seç  •  E / SAKLAN: eşyaya dönüş  •  sağ ekranı sürükle: kamera"
    else:
        timer_label.text = "AVCI MODU"
        status_label.text = "İmleci eşyaya getir ve E / VUR'a bas."
        hint_label.text = "İmleç: hedef seç  •  E / VUR: eşyaya vur  •  sağ ekranı sürükle: kamera"

func _process(_delta: float) -> void:
    if mode_panel.visible:
        return
    if player.disguised:
        target_label.visible = false
        status_label.text = "EŞYAYA DÖNÜŞTÜN. Tekrar E ile çık."
        return
    var target: Node3D = _get_target_prop()
    if target:
        target_label.visible = true
        target_label.text = ("DÖNÜŞ: " if mode == "player" else "VUR: ") + _pretty_name(target.name)
    else:
        target_label.visible = false

func _pretty_name(raw: String) -> String:
    return raw.replace("HideProp_", "").replace("_", " ")

func perform_mode_action() -> void:
    if mode == "player":
        if player.disguised:
            player.clear_disguise()
            status_label.text = "Karakter formuna döndün."
            return
        var target: Node3D = _get_target_prop()
        if target:
            player.set_disguised(target)
            status_label.text = "EŞYAYA DÖNÜŞTÜN."
        else:
            status_label.text = "İmleci bir eşyanın üzerine getir."
    else:
        var target: Node3D = _get_target_prop()
        if target:
            hit_prop(target)
        else:
            status_label.text = "İmleci vurmak istediğin eşyanın üzerine getir."

func _get_target_prop() -> Node3D:
    var forward: Vector3 = -player.camera.global_transform.basis.z
    var query := PhysicsRayQueryParameters3D.create(player.camera.global_position, player.camera.global_position + forward * 12.0)
    query.exclude = [player]
    query.collision_mask = 1
    var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
    if hit.is_empty():
        return null
    var node := hit.get("collider") as Node
    while node and node != self:
        if node.is_in_group("hide_props"):
            return node as Node3D
        node = node.get_parent()
    return null

func hit_prop(prop: Node3D) -> void:
    action_count += 1
    player.play_animation(&"Punch_Jab")
    var original: Vector3 = prop.rotation_degrees
    var tween := create_tween()
    tween.tween_property(prop, "rotation_degrees", original + Vector3(0, 18, 8), 0.08)
    tween.tween_property(prop, "rotation_degrees", original, 0.16)
    status_label.text = "EŞYAYA VURDUN! Kontrol: %02d" % action_count
