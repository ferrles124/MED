extends Node3D

@onready var player = $Player
@onready var timer_label: Label = $HUD/Timer
@onready var status_label: Label = $HUD/Status
@onready var hint_label: Label = $HUD/Hint
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
    mobile_controls.set_mode(mode)
    if mode == "player":
        timer_label.text = "OYUNCU MODU"
        status_label.text = "Yakındaki eşyaya dönüşmek için E'ye bas."
        hint_label.text = "E / SAKLAN: en yakın eşyaya dönüş  •  Tekrar bas: çık"
    else:
        timer_label.text = "AVCI MODU"
        status_label.text = "Eşyaları hedefleyip E veya VUR butonuna bas."
        hint_label.text = "E / VUR: kameranın önündeki eşyayı kontrol et"

func _process(_delta: float) -> void:
    if mode == "player" and player.disguised:
        status_label.text = "EŞYAYA DÖNÜŞTÜN. Tekrar E ile çık."

func perform_mode_action() -> void:
    if mode == "player":
        if player.disguised:
            player.clear_disguise()
            status_label.text = "Karakter formuna döndün."
            return
        var nearest: Node3D = null
        var nearest_distance: float = 3.5
        for prop in props:
            if not is_instance_valid(prop):
                continue
            var distance: float = player.global_position.distance_to(prop.global_position)
            if distance < nearest_distance:
                nearest_distance = distance
                nearest = prop
        if nearest:
            player.set_disguised(nearest)
            status_label.text = "EŞYAYA DÖNÜŞTÜN."
        else:
            status_label.text = "Yakında dönüşebileceğin bir eşya yok."
    else:
        var target := _get_target_prop()
        if target:
            hit_prop(target)
        else:
            status_label.text = "Önünde vurulabilir bir eşya yok."

func _get_target_prop() -> Node3D:
    var best: Node3D = null
    var best_score := 0.72
    var forward: Vector3 = -player.camera.global_transform.basis.z
    for prop in props:
        if not is_instance_valid(prop):
            continue
        var offset: Vector3 = prop.global_position - player.camera.global_position
        var distance: float = offset.length()
        if distance > 9.0 or distance < 0.1:
            continue
        var score: float = forward.dot(offset.normalized())
        if score > best_score:
            best_score = score
            best = prop
    return best

func hit_prop(prop: Node3D) -> void:
    action_count += 1
    var original := prop.rotation_degrees
    var tween := create_tween()
    tween.tween_property(prop, "rotation_degrees", original + Vector3(0, 18, 8), 0.08)
    tween.tween_property(prop, "rotation_degrees", original, 0.16)
    status_label.text = "EŞYAYA VURDUN! Kontrol: %02d" % action_count
