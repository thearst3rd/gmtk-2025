extends HBoxContainer


func _on_player_player_hit(current_health: int) -> void:
	while get_child_count() > current_health:
		var child: TextureRect = get_child(0)
		_spawn_hat_fragments(position + child.position + child.size / 2.0)
		remove_child(child)
		child.queue_free()


func _spawn_hat_fragments(pos: Vector2) -> void:
	print(pos)
	for i in range(20):
		var sprite := Sprite2D.new()
		sprite.texture = preload("res://assets/cowboy_hat.png")
		sprite.scale = Vector2(2.0, 2.0)
		sprite.region_enabled = true
		sprite.region_rect = Rect2(randf() * 28, 16 + randf() * 12, 4.0, 4.0)
		sprite.position = pos + Vector2.from_angle(randf() * TAU) * 20 * randf()
		add_sibling(sprite)
		var target_pos := pos + Vector2.from_angle(randf() * TAU) * 60 * randf()
		var tween := sprite.create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(sprite, ^"position", target_pos, 0.75)
		tween.tween_property(sprite, ^"modulate", Color(1.0, 1.0, 1.0, 0.0), 0.75)
		tween.tween_callback(sprite.queue_free)
