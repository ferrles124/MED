extends Node3D
class_name FractureGame

## Fracture Protocol'ün offline tur yöneticisi.
## Yetki akışı tek oyunculu bir vertical slice için burada tutulur;
## görsel sunum ve aktör davranışları ayrı sahne/script bileşenlerindedir.

enum Phase { BUY, LIVE, POST }

@onready var player: CharacterBody3D = $Player
@onready var map: Node3D = $Map
@onready var hud: CanvasLayer = $HUD

var phase: Phase = Phase.BUY
var phase_time := 12.0
var round_number := 1
var blue_score := 0
var amber_score := 0
var credits := 2400
var bomb_planted := false
var bomb_time := 0.0
var post_time := 0.0
var round_reason := ""
var bots: Array[Node] = []

func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    player.game = self
    player.died.connect(_on_player_died)
    for bot in get_tree().get_nodes_in_group("bots"):
        bot.game = self
        bots.append(bot)
    hud.game = self
    hud.set_message("ENTER ile hazırlık fazını tamamla · B ile ekipman ekranını aç")
    hud.refresh()

func _process(delta: float) -> void:
    match phase:
        Phase.BUY:
            phase_time = maxf(0.0, phase_time - delta)
            if phase_time <= 0.0:
                _begin_live()
        Phase.LIVE:
            phase_time = maxf(0.0, phase_time - delta)
            if bomb_planted:
                bomb_time = maxf(0.0, bomb_time - delta)
                if bomb_time <= 0.0:
                    end_round("amber", "Hedef cihazı devre dışı bırakılamadı.")
            if phase_time <= 0.0 and not bomb_planted:
                end_round("amber", "Tur süresi doldu.")
            _check_elimination()
        Phase.POST:
            post_time = maxf(0.0, post_time - delta)
            if post_time <= 0.0:
                _start_next_round()
    hud.refresh()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        match event.physical_keycode:
            KEY_ENTER, KEY_SPACE:
                if phase == Phase.BUY:
                    _begin_live()
                elif phase == Phase.POST:
                    _start_next_round()
            KEY_B:
                if phase == Phase.BUY:
                    hud.toggle_buy_panel()
            KEY_E:
                if phase == Phase.LIVE and not bomb_planted:
                    _try_plant_bomb()
            KEY_ESCAPE:
                if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
                    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
                else:
                    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _begin_live() -> void:
    if phase != Phase.BUY:
        return
    phase = Phase.LIVE
    phase_time = 90.0
    hud.hide_buy_panel()
    hud.set_message("Saha aktif · Hedef cihazını işaretli bölgeye kur veya rakipleri etkisizleştir")

func _try_plant_bomb() -> void:
    if not player.alive or not map.is_player_in_site(player):
        hud.set_message("Kurulum için amber işaretli hedef alanına yaklaşmalısın.")
        return
    bomb_planted = true
    bomb_time = 35.0
    hud.set_message("HEDEF CİHAZI KURULDU · 35 saniye")
    map.set_bomb_state(true)

func request_interact() -> void:
    if phase == Phase.LIVE and not bomb_planted:
        _try_plant_bomb()

func _check_elimination() -> void:
    if not player.alive:
        return
    var living := 0
    for bot in bots:
        if is_instance_valid(bot) and bot.alive:
            living += 1
    if living == 0:
        end_round("blue", "Amber timi etkisizleştirildi.")

func end_round(winner: String, reason: String) -> void:
    if phase == Phase.POST:
        return
    phase = Phase.POST
    post_time = 5.0
    round_reason = reason
    if winner == "blue":
        blue_score += 1
        credits += 3250
    else:
        amber_score += 1
        credits += 1900
    map.set_bomb_state(false)
    hud.show_round_result(winner, reason)

func _on_player_died() -> void:
    if phase == Phase.LIVE:
        end_round("amber", "Oyuncu etkisizleştirildi.")

func _start_next_round() -> void:
    round_number += 1
    phase = Phase.BUY
    phase_time = 12.0
    bomb_planted = false
    bomb_time = 0.0
    player.reset_for_round()
    for bot in bots:
        if is_instance_valid(bot):
            bot.reset_for_round()
    hud.hide_result()
    hud.set_message("Yeni tur hazır · B ile ekipmanını kontrol et · ENTER ile başla")

func is_live() -> bool:
    return phase == Phase.LIVE

func phase_name() -> String:
    match phase:
        Phase.BUY:
            return "SATIN ALMA FAZI"
        Phase.LIVE:
            return "AKTİF TUR"
        Phase.POST:
            return "TUR SONU"
    return ""

func objective_text() -> String:
    if bomb_planted:
        return "CİHAZ AKTİF  %.1f sn" % bomb_time
    return "HEDEFİ KUR · E" if phase == Phase.LIVE else "HEDEF HAZIR"
