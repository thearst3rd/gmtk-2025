extends ColorRect


@onready var resume_button: Button = %ResumeButton


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		if visible:
			unpause()
		else:
			pause()
		get_viewport().set_input_as_handled()


func pause():
	get_tree().paused = true
	show()
	resume_button.grab_focus()


func unpause():
	get_tree().paused = false
	hide()


func quit():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://src/menu/main_menu.tscn")
