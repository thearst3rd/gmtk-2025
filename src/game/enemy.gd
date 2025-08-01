extends CharacterBody2D


const SPEED := 80.0


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
