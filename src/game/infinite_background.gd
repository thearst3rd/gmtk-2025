extends TextureRect


@export var max_size: float


func _ready() -> void:
	size = Vector2.ONE * max_size
	position = -0.5 * size


func _physics_process(delta: float) -> void:
	var player: CharacterBody2D = get_tree().get_first_node_in_group("Player")
	var viewport_size = get_viewport_rect().size

	var position_offset_start = player.global_position - position
	var position_offset_end = position + size - player.global_position

	# Move by a consistent 10 tiles to avoid breaking the illusion.
	if position_offset_start.x < 0.6 * viewport_size.x:
		position.x -= texture.get_size().x * 10
	if position_offset_end.x < 0.6 * viewport_size.x:
		position.x += texture.get_size().x * 10
	if position_offset_start.y < 0.6 * viewport_size.y:
		position.y -= texture.get_size().y * 10
	if position_offset_end.y < 0.6 * viewport_size.y:
		position.y += texture.get_size().y * 10
