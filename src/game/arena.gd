extends Node2D


const CHUNK_SIZE = 1000


var game_time: float = 0
var score: int = 0
var loaded_chunks: Array[Vector2] = []

@onready var player: Player = %Player


func _ready() -> void:
	player.draw_controller.line_complete.connect(on_line_complete)
	score = 0

	var player_chunk_pos := Vector2(
		round(player.position.x / CHUNK_SIZE) * CHUNK_SIZE,
		round(player.position.y / CHUNK_SIZE) * CHUNK_SIZE
	)

	# Spawn a 3x3 area of chunks around the player.
	for x in range(-1, 2):
		for y in range(-1, 2):
			var chunk_start = player_chunk_pos + Vector2(x, y) * CHUNK_SIZE
			spawn_objects(chunk_start)


func _process(delta: float) -> void:
	game_time += delta

	var player_chunk_pos := Vector2(
		round(player.position.x / CHUNK_SIZE) * CHUNK_SIZE,
		round(player.position.y / CHUNK_SIZE) * CHUNK_SIZE
	)

	# Unload any chunks that are no longer adjacent to the player's chunk
	for chunk_start in loaded_chunks:
		if abs((player_chunk_pos - chunk_start).x) > 2 * CHUNK_SIZE:
			despawn_objects(chunk_start)
		if abs((player_chunk_pos - chunk_start).y) > 2 * CHUNK_SIZE:
			despawn_objects(chunk_start)

	# Spawn in new objects for any new chunks
	for x in range(-1, 2):
		for y in range(-1, 2):
			var chunk_start = player_chunk_pos + Vector2(x, y) * CHUNK_SIZE
			if chunk_start not in loaded_chunks:
				spawn_objects(chunk_start)


# Spawn a random number of rocks and cacti in a chunk.
func spawn_objects(chunk_start: Vector2) -> void:
	loaded_chunks.append(chunk_start)

	var num_objects := randi_range(8, 20)

	var existing_object_positions: Array[Vector2] = [player.position]

	var distance_sq_threshold := 2500.0

	for _idx in range(num_objects):
		var new_pos := Vector2(
			randf_range(chunk_start.x, chunk_start.x + CHUNK_SIZE),
			randf_range(chunk_start.y, chunk_start.y + CHUNK_SIZE)
		)

		# What do I even do with line-breaks here????
		while existing_object_positions.any(
			func is_close(x): return x.distance_squared_to(new_pos) < distance_sq_threshold
		):
			new_pos = Vector2(
				randf_range(chunk_start.x, chunk_start.x + CHUNK_SIZE),
				randf_range(chunk_start.y, chunk_start.y + CHUNK_SIZE)
			)

		existing_object_positions.append(new_pos)
		if randi_range(0, 1) == 0:
			var rock := preload("res://src/game/rock.tscn").instantiate()
			rock.position = new_pos
			$Objects.add_child(rock)
		else:
			var cactus := preload("res://src/game/cactus.tscn").instantiate()
			cactus.position = new_pos
			$Objects.add_child(cactus)


func despawn_objects(chunk_start: Vector2) -> void:
	loaded_chunks.erase(chunk_start)
	var chunk = Rect2(chunk_start, Vector2.ONE * CHUNK_SIZE)

	for object in $Objects.get_children() as Array[Node2D]:
		if chunk.has_point(object.position):
			$Objects.remove_child(object)
			object.queue_free()


func on_line_complete(points: Array[Vector2], penalty: float) -> void:
	var enemies_captured := 0

	for node in $Enemies.get_children():
		if node is not Enemy:
			continue

		var enemy := node as Enemy
		if enemy.is_inside_polygon(points):
			enemies_captured += 1
			$Enemies.remove_child(enemy)
			enemy.queue_free()
			player.captured_enemy()

	if enemies_captured > 0:
		if penalty < 8.0:
			add_to_score(500 + 150 * enemies_captured * enemies_captured)
			player.draw_controller.golden = true
		else:
			add_to_score(100 + 50 * enemies_captured * enemies_captured)
			player.draw_controller.golden = false
		player.draw_controller.active = false


func on_player_shoot(location: Vector2, direction: Vector2, billiard: bool = false) -> void:
	var new_projectile := preload("res://src/game/enemy_projectile.tscn").instantiate()
	new_projectile.billiard_ball = billiard
	new_projectile.init(location, direction)
	new_projectile.object_hit.connect(on_projectile_hit)
	new_projectile.enemy_respawn.connect(on_projectile_expire)
	$Projectiles.add_child.call_deferred(new_projectile)


func on_projectile_hit(body: Node2D, projectile_position: Vector2, billiard_ball: bool) -> void:
	if body is Enemy:
		if billiard_ball:
			var new_direction := (body.position - projectile_position).normalized()
			on_player_shoot(body.position, new_direction, true)
		# Explode
		add_to_score(2500)
		$Enemies.remove_child(body)
		body.queue_free()
	else:
		add_to_score(1000)


func on_projectile_expire(location: Vector2) -> void:
	var new_enemy := preload("res://src/game/enemy.tscn").instantiate()
	new_enemy.position = location
	$Enemies.add_child(new_enemy)


func add_to_score(value: int) -> void:
	score += value
	%ScoreLabel.text = "Score: " + str(score)
