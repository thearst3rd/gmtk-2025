extends ColorRect


@onready var score_text: RichTextLabel = %ScoreText
@onready var restart_button: Button = %RestartButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func reveal(final_score) -> void:
	score_text.text = "Final score: " + str(final_score)
	restart_button.grab_focus()
	animation_player.play(&"enter")


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/menu/main_menu.tscn")
