extends Node


const SETTINGS_FILE := "user://settings.json"

var sound_volume := 0.5
var music_volume := 0.5

var high_score := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_settings()
	settings_updated()

	var music := AudioStreamPlayer.new()
	music.bus = &"Music"
	music.stream = preload("res://assets/music/cowboy_v1.ogg")
	music.volume_db = -10.0
	add_child(music)
	music.play()


func load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_FILE):
		return
	var settings_str := FileAccess.get_file_as_string(SETTINGS_FILE)
	var obj = JSON.parse_string(settings_str)
	if typeof(obj) != TYPE_DICTIONARY:
		push_error("Invalid settings file")
		return
	var json: Dictionary = obj
	if typeof(json.get("sound_volume", null)) in [TYPE_FLOAT, TYPE_INT]:
		sound_volume = clampf(json["sound_volume"], 0.0, 1.0)
	if typeof(json.get("music_volume", null)) in [TYPE_FLOAT, TYPE_INT]:
		music_volume = clampf(json["music_volume"], 0.0, 1.0)
	if json.get("fullscreen", false) == true:
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN
	if typeof(json.get("high_score", null)) in [TYPE_FLOAT, TYPE_INT]:
		high_score = json["high_score"]


func save_settings() -> void:
	var json := {
		"sound_volume": sound_volume,
		"music_volume": music_volume,
		"fullscreen": get_window().mode in [Window.MODE_EXCLUSIVE_FULLSCREEN, Window.MODE_FULLSCREEN],
		"high_score": high_score,
	}
	var f := FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	if not f:
		var error := FileAccess.get_open_error()
		push_error("Failed to save settings: Error %s (%s)" % [error, error_string(error)])
		return
	f.store_string(JSON.stringify(json, "\t", false))
	f.close()


func settings_updated() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"Sound"), linear_to_db(sound_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"Music"), linear_to_db(music_volume))
	save_settings()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_settings()
		get_tree().quit()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_fullscreen"):
		var is_fullscreen := get_window().mode in [Window.MODE_EXCLUSIVE_FULLSCREEN, Window.MODE_FULLSCREEN]
		get_window().mode = Window.MODE_WINDOWED if is_fullscreen else Window.MODE_EXCLUSIVE_FULLSCREEN
		settings_updated()
		get_window().set_input_as_handled()
