extends Control


@onready var back_button: Button = %BackButton
@onready var licenses_button: Button = %LicensesButton

@onready var licenses_panel: PanelContainer = %LicensesPanel
@onready var licenses_label: RichTextLabel = %LicensesLabel


var main_licenses := [
	["Godot Engine", Engine.get_license_text()],
	["Bowling sound", "SPRTInd-Int_BowlingStrike_Zus_OwSfx_Hard by ZusIsKing -- https://freesound.org/s/766871/ -- License: Creative Commons 0"],
	["Hardpixel Regular Font", FileAccess.get_file_as_string("res://assets/fonts/hardpixel/1001fonts-hardpixel-eula.txt")],
	["Nandaka Western Font", FileAccess.get_file_as_string("res://assets/fonts/1001fonts-eula.txt")],
]


func _ready() -> void:
	back_button.grab_focus()


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/menu/main_menu.tscn")


func _on_licenses_button_pressed() -> void:
	if licenses_panel.visible:
		licenses_panel.hide()
		licenses_button.text = "View All Licenses"
		back_button.show()
	else:
		licenses_panel.show()
		licenses_button.text = "Hide Licenses"
		if licenses_label.text.is_empty():
			licenses_label.parse_bbcode(generate_license_bbcode_text())
		back_button.hide()


func generate_license_bbcode_text() -> String:
	var text := "[center][font_size=36]Licenses[/font_size][/center]"

	for license: Array in main_licenses:
		text += "\n\n[center][font_size=20]" + license[0] + "[/font_size][/center]\n\n"
		text += "[font_size=13]" + license[1].strip_edges() + "[/font_size]"

	text += "\n\n[center][font_size=26]All Third-Party Licenses[/font_size][/center]"

	# These engine license/copyright functions are not incredibly obvious how to usefully extract information from.
	# This is similar to how it's done in the "About Godot" -> "Third-party Licenses" -> "All Components" screen
	for info in Engine.get_copyright_info():
		text += "\n\n[center][font_size=18]" + info.name + "[/font_size][/center]\n[font_size=14]"
		for part: Dictionary in info.parts:
			for copyright: String in part.copyright:
				text += "\n(c) " + copyright
			text += "\nLicense: " + part.license
		text += "[/font_size]"

	var engine_licenses := Engine.get_license_info()
	for license: String in engine_licenses:
		text += "\n\n[center][font_size=18]" + license + "[/font_size][/center]\n\n"
		text += "[font_size=12]" + engine_licenses[license] + "[/font_size]"

	return text
