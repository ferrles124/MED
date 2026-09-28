extends Control

func _ready() -> void:
	$Panel/VBox/StartButton.grab_focus()

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")

func _on_reset_button_pressed() -> void:
	DirAccess.remove_absolute("user://only_up_save.cfg")
	$Panel/VBox/Status.text = "Kayıt sıfırlandı."

func _on_quit_button_pressed() -> void:
	get_tree().quit()
