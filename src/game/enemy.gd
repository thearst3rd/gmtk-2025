class_name Enemy
extends CharacterBody2D


@export var SPEED := 80.0
@export var FOOTSTEP_CHANCE := 0.4

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var footsteps: Array[AudioStreamPlayer2D] = [$Footstep1, $Footstep2, $Footstep3]


func _ready() -> void:
	animated_sprite.play(&"walk")
	animated_sprite.frame_progress = randf() # So that all enemies are randomly offset from another


func _physics_process(_delta: float) -> void:
	# Set direction to vector at the player
	var player: CharacterBody2D = get_tree().get_first_node_in_group("Player")
	if not player:
		animated_sprite.play(&"default")
		return

	var player_position := player.global_position
	var direction: Vector2
	if player.dead:
		direction = (position - player_position).normalized()
		velocity = direction * SPEED / 2
	else:
		direction = (player_position - position).normalized()
		velocity = direction * SPEED
	move_and_slide()


func is_inside_polygon(points: Array[Vector2]) -> bool:
	var packed_points := PackedVector2Array(points)

	var collision_rect: Rect2 = $CollisionShape2D.get_shape().get_rect()

	var rect_points: Array[Vector2] = [
		position + collision_rect.position,
		position + collision_rect.position + Vector2.RIGHT * collision_rect.size.x,
		position + collision_rect.position + Vector2.DOWN * collision_rect.size.y,
		position + collision_rect.position + collision_rect.size
	]

	var num_points_inside := 0
	for point in rect_points:
		# The points passed in are in local space, but the points in the collision rect are in
		# global space. This offset will re-align them.
		if Geometry2D.is_point_in_polygon(point, packed_points):
			num_points_inside += 1

	return num_points_inside >= 3


func _on_frame_changed() -> void:
	if animated_sprite.frame in [1, 3]:
		if randf() < FOOTSTEP_CHANCE:
			footsteps.pick_random().play()
