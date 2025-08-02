extends Node2D


var game_time: float = 0
var score: int = 0

@onready var player: Player = %Player
@onready var game_over: ColorRect = %GameOver


func _ready() -> void:
	player.draw_controller.line_complete.connect(on_line_complete)
	score = 0


func _process(delta: float) -> void:
	game_time += delta


func on_line_complete(points: Array[Vector2], _penalty: float) -> void:
	var enemy_captured := false

	for node in $Enemies.get_children():
		if node is not Enemy:
			continue

		var enemy := node as Enemy
		if enemy.is_inside_polygon(points):
			enemy_captured = true
			$Enemies.remove_child(enemy)
			enemy.queue_free()
			player.captured_enemy()

	if enemy_captured:
		player.draw_controller.active = false


func on_player_shoot(direction: Vector2) -> void:
	var new_projectile := preload("res://src/game/enemy_projectile.tscn").instantiate()
	new_projectile.direction = direction
	new_projectile.initial_position = player.position
	new_projectile.position = player.position
	new_projectile.object_hit.connect(on_projectile_hit)
	$Projectiles.add_child(new_projectile)


func on_projectile_hit(body: Node2D) -> void:
	if body is Enemy:
		# Explode
		add_to_score(250)
		$Enemies.remove_child(body)
		body.queue_free()
	else:
		add_to_score(100)


func add_to_score(value: int) -> void:
	score += value
	%ScoreLabel.text = "Score: " + str(score)


func _on_player_player_died() -> void:
	game_over.reveal(score)
