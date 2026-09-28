extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var height_label: Label = $HUD/Height
@onready var checkpoint_label: Label = $HUD/Checkpoint
@onready var score_label: Label = $HUD/Score
@onready var timer_label: Label = $HUD/Timer
@onready var status_label: Label = $HUD/Status
@onready var results_panel: PanelContainer = $HUD/Results
@onready var results_stats: Label = $HUD/Results/VBox/Stats

var checkpoint_position := Vector3(0, 7, -1)
var checkpoint_height := 0.0
var score := 0
var elapsed := 0.0
var best_height := 0.0
var save_path := "user://only_up_save.cfg"
var game_won := false
var sfx_players: Dictionary = {}
var music_player: AudioStreamPlayer

func _ready() -> void:
	if get_tree().current_scene.scene_file_path.get_file() == "level_02.tscn":
		checkpoint_position = Vector3(29, 127, -418.2)
	_load_progress()
	for node in get_tree().get_nodes_in_group("checkpoint"):
		node.checkpoint_reached.connect(_on_checkpoint_reached)
	for node in get_tree().get_nodes_in_group("finish"):
		node.finish_reached.connect(_on_finish_reached)
	_setup_audio()
	if get_tree().current_scene.scene_file_path.get_file() == "level_02.tscn":
		status_label.text = "BÖLÜM 2: Harmanlanmış gökyüzü tırmanışı başladı."
	else:
		status_label.text = "Gerçek beyaz eşyalarla rastgele tırmanış: her nesne bir sonraki basamak."

func _process(delta: float) -> void:
	if game_won:
		return
	elapsed += delta
	var height := maxf(0.0, player.global_position.y)
	best_height = maxf(best_height, height)
	height_label.text = "YÜKSEKLİK  %04d m" % int(height)
	checkpoint_label.text = "CHECKPOINT  %04d m" % int(checkpoint_height)
	score_label.text = "SKOR  %06d" % score
	timer_label.text = "SÜRE  %05.1f" % elapsed
	if player.global_position.y < checkpoint_height - 16.0:
		player.respawn_at(checkpoint_position)
		play_sfx("respawn")
		status_label.text = "Düştün; son checkpoint'e döndün."

func _on_checkpoint_reached(pos: Vector3, height: float) -> void:
	if height <= checkpoint_height:
		return
	checkpoint_position = pos + Vector3.UP * 1.5
	checkpoint_height = height
	score += 250
	play_sfx("checkpoint")
	status_label.text = "CHECKPOINT! +250 SKOR"
	_save_progress()

func collect_star(value: int) -> void:
	score += value
	status_label.text = "+%d yıldız" % value
	_save_progress()

func _on_finish_reached() -> void:
	play_sfx("transition")
	if get_tree().current_scene.scene_file_path.get_file() == "game.tscn":
		get_tree().change_scene_to_file("res://level_02.tscn")
		return
	game_won = true
	player.set_physics_process(false)
	$HUD/MobileControls.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	best_height = maxf(best_height, player.global_position.y)
	results_stats.text = "YÜKSEKLİK  %04d m\nSKOR  %06d\nSÜRE  %05.1f" % [int(best_height), score, elapsed]
	results_panel.visible = true
	status_label.text = "Zirve tamamlandı!"
	_save_progress()

func _on_respawn_button_pressed() -> void:
	if game_won:
		return
	player.respawn_at(checkpoint_position)
	play_sfx("respawn")
	status_label.text = "Son checkpoint'e döndün."

func _on_camera_button_pressed() -> void:
	player.toggle_view()
	$HUD/CameraButton.text = "KAMERA: 1. ŞAHIS" if player.first_person else "KAMERA: 3. ŞAHIS"

func _setup_audio() -> void:
	for key in ["jump", "landing", "checkpoint", "respawn", "transition", "wind"]:
		var stream := load("res://sfx_" + key + ".mp3") as AudioStream
		if stream == null:
			continue
		var audio := AudioStreamPlayer.new()
		audio.name = "SFX_" + key
		audio.stream = stream
		add_child(audio)
		sfx_players[key] = audio
	if sfx_players.has("wind"):
		sfx_players["wind"].volume_db = -18.0
		sfx_players["wind"].play()
	var music_stream := load("res://music_option_a_skybound.mp3") as AudioStream
	if music_stream:
		music_player = AudioStreamPlayer.new()
		music_player.name = "BackgroundMusic"
		music_player.stream = music_stream
		music_player.volume_db = -10.0
		add_child(music_player)
		music_player.finished.connect(_loop_background_music)
		music_player.play()

func _loop_background_music() -> void:
	if music_player and not game_won:
		music_player.play()

func play_sfx(key: String) -> void:
	if sfx_players.has(key):
		sfx_players[key].play()

func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")

func _save_progress() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "best_height", best_height)
	cfg.set_value("progress", "score", score)
	cfg.save(save_path)

func _load_progress() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(save_path) == OK:
		best_height = float(cfg.get_value("progress", "best_height", 0.0))
		score = int(cfg.get_value("progress", "score", 0))
