extends Control


@onready var sound_slider: HSlider = %SoundSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var fullscreen_check: CheckButton = %FullscreenCheck


func _ready() -> void:
	sound_slider.set_value_no_signal(Global.sound_volume)
	music_slider.set_value_no_signal(Global.music_volume)
	var is_fullscreen := get_window().mode in [Window.MODE_EXCLUSIVE_FULLSCREEN, Window.MODE_FULLSCREEN]
	fullscreen_check.set_pressed_no_signal(is_fullscreen)


func _on_sound_slider_value_changed(value: float) -> void:
	Global.sound_volume = value
	Global.settings_updated()


func _on_music_slider_value_changed(value: float) -> void:
	Global.music_volume = value
	Global.settings_updated()


func _on_fullscreen_check_toggled(toggled_on: bool) -> void:
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if toggled_on else Window.MODE_WINDOWED
	Global.settings_updated()


func _process(_delta: float) -> void:
	# In case the fullscreen changes outside of the settings menu
	var is_fullscreen := get_window().mode in [Window.MODE_EXCLUSIVE_FULLSCREEN, Window.MODE_FULLSCREEN]
	if fullscreen_check.button_pressed != is_fullscreen:
		print("Changing button, mode is: %s" % [get_window().mode])
		fullscreen_check.set_pressed_no_signal(is_fullscreen)
