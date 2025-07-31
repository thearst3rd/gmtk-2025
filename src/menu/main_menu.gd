extends Control


@onready var quit_button: Button = %QuitButton


func _ready() -> void:
	if OS.has_feature("web"):
		quit_button.hide()


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/game/arena.tscn")


func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/menu/credits_menu.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
