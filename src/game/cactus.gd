extends Area2D


func on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.hit_by_cactus()
