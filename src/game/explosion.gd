extends AnimatedSprite2D


func _ready() -> void:
	play("explode")
	animation_finished.connect(
		func():
			hide()
			queue_free()
	)
