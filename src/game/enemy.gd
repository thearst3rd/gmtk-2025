class_name Enemy
extends CharacterBody2D


@export var SPEED := 80.0


var is_lassoed := false


func _physics_process(_delta: float) -> void:
	# Don't apply this movement if the enemy is lassoed
	if not is_lassoed:
		# Set direction to vector at the player
		var player: CharacterBody2D = get_tree().get_first_node_in_group("Player")
		var player_position := player.global_position
		var direction := (player_position - position).normalized()
		velocity = direction * SPEED
		$AnimatedSprite2D.play("walk")
		move_and_slide()
	else:
		# Set position to... slowly circling the player?
		pass


func is_inside_polygon(points: Array[Vector2]) -> bool:
	var packed_points := PackedVector2Array(points)

	var collision_rect: Rect2 = $CollisionShape2D.get_shape().get_rect()

	var rect_points: Array[Vector2] = [
		position + collision_rect.position,
		position + collision_rect.position + Vector2.RIGHT * collision_rect.size.x,
		position + collision_rect.position + Vector2.DOWN * collision_rect.size.y,
		position + collision_rect.position + collision_rect.size
	]

	print("Enemy position: ", position)

	var num_points_inside := 0
	for point in rect_points:
		# The points passed in are in local space, but the points in the collision rect are in
		# global space. This offset will re-align them.
		if Geometry2D.is_point_in_polygon(point, packed_points):
			num_points_inside += 1

	return num_points_inside >= 3
