extends Node3D

@onready var player = $Player
@onready var hunter = $Hunter
@onready var timer_label: Label = $HUD/Timer
@onready var status_label: Label = $HUD/Status
@onready var hint_label: Label = $HUD/Hint
@onready var result_panel: Panel = $HUD/ResultPanel
@onready var result_label: Label = $HUD/ResultPanel/Result

var round_time := 120.0
var round_over := false
var props: Array[Node3D] = []

func _ready() -> void:
    for node in get_tree().get_nodes_in_group("hide_props"):
        props.append(node as Node3D)
    player.interact_requested.connect(_on_player_interact)
    hunter.game = self
    hunter.player = player
    hunter.patrol_points = [Vector3(-10, 0.8, -7), Vector3(10, 0.8, -7), Vector3(10, 0.8, 7), Vector3(-10, 0.8, 7)]
    result_panel.visible = false
    status_label.text = "AVCI HAZIRLANIYOR..."
    hint_label.text = "WASD hareket  •  E: en yakın eşyaya saklan / çık  •  Space: zıpla"

func _process(delta: float) -> void:
    if round_over:
        return
    round_time = maxf(0.0, round_time - delta)
    timer_label.text = "KALAN SÜRE  %02d:%02d" % [int(round_time) / 60, int(round_time) % 60]
    if player.disguised:
        status_label.text = "SAKLANIYORSUN  •  Avcı yakındaysa E ile çık"
    else:
        status_label.text = "GİZLENMEK İÇİN E'ye bas  •  Avcı seni görebilir"
    if round_time <= 0.0:
        player_won()

func _on_player_interact() -> void:
    if round_over:
        return
    if player.disguised:
        player.clear_disguise()
        return
    var nearest: Node3D = null
    var nearest_distance := 3.5
    for prop in props:
        if not is_instance_valid(prop):
            continue
        var distance: float = player.global_position.distance_to(prop.global_position)
        if distance < nearest_distance:
            nearest_distance = distance
            nearest = prop
    if nearest:
        player.set_disguised(nearest)
        status_label.text = "EŞYAYA DÖNÜŞTÜN. KIPIRDAMA!"
    else:
        status_label.text = "Yakında saklanabileceğin bir eşya yok."

func player_caught() -> void:
    if round_over:
        return
    round_over = true
    player.clear_disguise()
    result_panel.visible = true
    result_label.text = "YAKALANDIN!\nAvcı seni buldu.\n\nR ile yeniden başlat"
    status_label.text = "TUR BİTTİ"

func player_won() -> void:
    if round_over:
        return
    round_over = true
    result_panel.visible = true
    result_label.text = "KAZANDIN!\n120 saniye boyunca saklandın.\n\nR ile yeniden başlat"
    status_label.text = "TUR BİTTİ"

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.keycode == KEY_R and event.pressed and round_over:
        get_tree().reload_current_scene()
