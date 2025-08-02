extends Control


@onready var play_button: Button = %PlayButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_button: Button = %QuitButton
@onready var main_buttons: VBoxContainer = %MainButtons
@onready var settings_panel: PanelContainer = %SettingsPanel
@onready var title_and_buttons: VBoxContainer = %TitleAndButtons
@onready var how_to_play: Control = %HowToPlay
@onready var settings_menu: VBoxContainer = %SettingsMenu


func _ready() -> void:
	if OS.has_feature("web"):
		quit_button.hide()
	play_button.grab_focus()


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/game/arena.tscn")


func _on_settings_button_pressed() -> void:
	title_and_buttons.hide()
	settings_panel.show()
	settings_menu.focus()


func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/menu/credits_menu.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)


func _on_settings_back_button_pressed() -> void:
	title_and_buttons.show()
	settings_panel.hide()
	settings_button.grab_focus()


func _on_how_to_play_button_pressed() -> void:
	how_to_play.show()
	how_to_play.load_screen()
