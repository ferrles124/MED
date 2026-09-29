extends CanvasLayer
class_name FractureHud

var game: Node
var message_time := 0.0
var damage_flash := 0.0

@onready var phase_label: Label = $Layer/TopBar/Phase
@onready var score_label: Label = $Layer/TopBar/Score
@onready var timer_label: Label = $Layer/TopBar/Timer
@onready var objective_label: Label = $Layer/Objective
@onready var health_label: Label = $Layer/BottomLeft/Health
@onready var ammo_label: Label = $Layer/BottomRight/Ammo
@onready var credits_label: Label = $Layer/BottomRight/Credits
@onready var message_label: Label = $Layer/Message
@onready var buy_panel: Panel = $Layer/BuyPanel
@onready var result_panel: Panel = $Layer/ResultPanel
@onready var result_title: Label = $Layer/ResultPanel/Title
@onready var result_detail: Label = $Layer/ResultPanel/Detail
@onready var flash: ColorRect = $Layer/DamageFlash
@onready var mobile_controls: Control = $Layer/MobileControls

func _ready() -> void:
    buy_panel.visible = false
    result_panel.visible = false
    flash.modulate.a = 0.0

func _process(delta: float) -> void:
    message_time = maxf(0.0, message_time - delta)
    damage_flash = maxf(0.0, damage_flash - delta)
    flash.modulate.a = damage_flash * 0.55

func refresh() -> void:
    if game == null:
        return
    phase_label.text = game.phase_name()
    score_label.text = "MAVİ  %d   —   %d  AMBER" % [game.blue_score, game.amber_score]
    timer_label.text = "%02d:%02d" % [int(game.phase_time) / 60, int(game.phase_time) % 60]
    objective_label.text = game.objective_text()
    health_label.text = "SAĞLIK  %03d" % game.player.health
    ammo_label.text = "%s  %02d / %02d" % [game.player.weapon.weapon_name, game.player.weapon.ammo, game.player.weapon.magazine_size]
    credits_label.text = "KREDİ  %04d" % game.credits
    if message_time <= 0.0 and game.phase == game.Phase.LIVE:
        message_label.text = "WASD hareket   ·   Sol tık ateş   ·   R doldur   ·   E hedef cihazı"

func set_message(text: String) -> void:
    message_label.text = text
    message_time = 4.5

func set_damage_flash() -> void:
    damage_flash = 0.35

func toggle_buy_panel() -> void:
    buy_panel.visible = not buy_panel.visible

func hide_buy_panel() -> void:
    buy_panel.visible = false

func show_round_result(winner: String, reason: String) -> void:
    result_panel.visible = true
    result_title.text = "MAVİ TURU KAZANDI" if winner == "blue" else "AMBER TURU KAZANDI"
    result_title.modulate = Color(0.32, 0.78, 1.0) if winner == "blue" else Color(1.0, 0.47, 0.25)
    result_detail.text = "%s\n\nENTER ile sonraki tur" % reason

func hide_result() -> void:
    result_panel.visible = false
