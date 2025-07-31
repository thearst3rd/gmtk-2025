#!/usr/bin/env -S godot --headless -s
extends SceneTree


func _init() -> void:
	print("Exporting all projects")

	clean_directory("web")
	clean_directory("windows")
	clean_directory("linux")
	clean_directory("mac")

	await export_web()
	await export_windows()
	await export_linux()
	await export_mac()

	quit()


func clean_directory(name: String) -> void:
	print("Cleaning directory %s" % [name])
	var da := DirAccess.open("res://.exports/%s" % [name])
	if da == null or not da.current_is_dir():
		push_error("Invalid directory \"%s\"" % [name])
	for file in da.get_files():
		if file == ".gitkeep":
			continue
		da.remove(file)


func export_preset(preset_name: String) -> void:
	#OS.execute(OS.get_executable_path(), ["--headless", "--export-release", preset_name])
	var pid := OS.create_instance(["--headless", "--export-release", preset_name])
	while OS.is_process_running(pid):
		await create_timer(0.001).timeout


func zip_directory(name: String) -> void:
	var dir := "res://.exports/%s" % [name]
	var da := DirAccess.open(dir)
	if da == null or not da.current_is_dir():
		push_error("Could not zip %s" % [name])
	var files := da.get_files()

	var zip := ZIPPacker.new()
	var err := zip.open("%s/gmtk-2025-%s.zip" % [dir, name])
	if err:
		push_error("Could not create zip %s" % [name])

	print("Zipping directory %s" % [name])
	for file in files:
		if file == ".gitkeep":
			continue
		print("Adding file %s" % file)
		zip.start_file(file)
		zip.write_file(FileAccess.get_file_as_bytes("%s/%s" % [dir, file]))


func export_web() -> void:
	print("Exporting Web")
	await export_preset("Web")
	DirAccess.rename_absolute("res://.exports/web/gmtk-2025.html", "res://.exports/web/index.html")
	zip_directory("web")


func export_windows() -> void:
	print("Exporting Windows")
	await export_preset("Windows Desktop")
	zip_directory("windows")


func export_linux() -> void:
	print("Exporting Linux")
	await export_preset("Linux")
	zip_directory("linux")


func export_mac() -> void:
	# TODO
	pass
