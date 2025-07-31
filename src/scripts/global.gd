extends Node


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# We can save here if we need to save
		get_tree().quit()
