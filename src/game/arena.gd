extends Node2D


const CHUNK_SIZE = 1000


var game_time: float = 0
var score: int = 0
var loaded_chunks: Array[Vector2] = []
var is_game_over := false

@onready var player: Player = %Player
@onready var golden_sound: AudioStreamPlayer = $GoldenSound
@onready var how_to_play: Control = %HowToPlay
@onready var pause_menu: ColorRect = %PauseMenu
@onready var game_over: ColorRect = %GameOver

var collect_sounds: Array[AudioStreamPlayer] = []


func _ready() -> void:
	%DifficultyLabel.hide()
	player.draw_controller.line_complete.connect(on_line_complete)
	$EnemySpawner.difficulty_up.connect($AnimationPlayer.play.bind("difficulty_up"))
	score = 0
	is_game_over = false

	var player_chunk_pos := Vector2(
		round(player.position.x / CHUNK_SIZE) * CHUNK_SIZE,
		round(player.position.y / CHUNK_SIZE) * CHUNK_SIZE
	)

	# Spawn a 3x3 area of chunks around the player.
	for x in range(-1, 2):
		for y in range(-1, 2):
			var chunk_start = player_chunk_pos + Vector2(x, y) * CHUNK_SIZE
			spawn_objects(chunk_start)

	# Create a few "collection" sounds at varying pitches for use when collecting enemies
	for i in range(5):
		var sound := AudioStreamPlayer.new()
		sound.bus = &"Sound"
		sound.volume_db = -3.0
		sound.stream = preload("res://assets/sfx/collect.wav")
		sound.pitch_scale = 1.0 + float(i) / 3.0
		collect_sounds.push_back(sound)
		add_child(sound)

	for object in $Objects.get_children() as Array[Node2D]:
		if object.position.distance_squared_to(player.position) < 6400:
			$Objects.remove_child(object)
			object.queue_free()


func _process(delta: float) -> void:
	if is_game_over:
		return

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


func on_line_complete(points: Array[Vector2], center: Vector2, golden: bool) -> void:
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
		if golden:
			add_to_score(200 + 100 * enemies_captured * enemies_captured, center)
			player.draw_controller.golden = true
			golden_sound.play()
		else:
			add_to_score(100 + 50 * enemies_captured * enemies_captured, center)
			player.draw_controller.golden = false
		player.draw_controller.active = false

		for i in range(enemies_captured):
			var sound := collect_sounds[mini(i, collect_sounds.size() - 1)]
			sound.stop()
			sound.play()
			await get_tree().create_timer(0.15).timeout


func on_player_shoot(location: Vector2, direction: Vector2, billiard: int = 0) -> void:
	var new_projectile := preload("res://src/game/enemy_projectile.tscn").instantiate()
	new_projectile.billiard_ball = billiard
	new_projectile.init(location, direction)
	new_projectile.object_hit.connect(on_projectile_hit)
	new_projectile.enemy_respawn.connect(on_projectile_expire)
	$Projectiles.add_child.call_deferred(new_projectile)


func on_projectile_hit(body: Node2D, projectile_position: Vector2, billiard_ball: int) -> void:
	if body is Enemy:
		if billiard_ball:
			var new_direction := (body.position - projectile_position).normalized()
			on_player_shoot(body.position, new_direction, billiard_ball + 1)
			if billiard_ball == 2:
				print("Strike!!!")
				var strike := AudioStreamPlayer2D.new()
				strike.bus = &"Sound"
				strike.volume_db = 4.0
				strike.position = body.position
				strike.stream = preload("res://assets/sfx/bowlingStrike.wav")
				add_child(strike)
				strike.finished.connect(strike.queue_free)
				strike.play()
			add_to_score(billiard_ball * 1000, projectile_position)
		else:
			add_to_score(1000, body.position)
		create_explosion(projectile_position)
		$Enemies.remove_child(body)
		body.queue_free()
	else:
		add_to_score(500 + billiard_ball * 1000, projectile_position)
		create_explosion(projectile_position)


func create_explosion(location: Vector2) -> void:
	var explosion = preload("res://src/game/explosion.tscn").instantiate()
	explosion.position = location
	add_child(explosion)


func on_projectile_expire(location: Vector2) -> void:
	var new_enemy := preload("res://src/game/enemy.tscn").instantiate()
	new_enemy.position = location
	$Enemies.add_child(new_enemy)


func add_to_score(value: int, label_position: Vector2) -> void:
	score += value
	var score_label := ScoreLabel.new_label(str(value), label_position)
	$ScoreLabels.add_child(score_label)
	%ScoreLabel.text = "Score: " + str(score)


func _on_player_player_died() -> void:
	is_game_over = true
	game_over.reveal(score)
	pause_menu.pausable = false


func on_how_to_play_button_pressed() -> void:
	get_tree().paused = true
	$UI.hide()
	how_to_play.show()
	how_to_play.load_screen()
	pause_menu.pausable = false


func on_how_to_play_exited() -> void:
	get_tree().paused = false
	$UI.show()
	pause_menu.pausable = true
