extends ColorRect


@onready var score_text: Label = %ScoreText
@onready var restart_button: Button = %RestartButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func reveal(final_score: int, max_chain: int) -> void:
	score_text.text = "Final score: %d\nLongest chain: %d\n\n" % [final_score, max_chain]
	if final_score > Global.high_score:
		score_text.text += "New High Score! Previous: %d" % [Global.high_score]
		Global.high_score = final_score
		Global.save_settings()
	else:
		score_text.text += "High Score: %d" % [Global.high_score]
	restart_button.grab_focus()
	animation_player.play(&"enter")


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/menu/main_menu.tscn")
