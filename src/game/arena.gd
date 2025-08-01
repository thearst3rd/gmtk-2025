extends Node2D


var game_time: float = 0

@onready var player: Player = %Player


func _ready() -> void:
	player.draw_controller.line_complete.connect(on_line_complete)


func _process(delta: float) -> void:
	game_time += delta


func on_line_complete(points: Array[Vector2], penalty: float) -> void:
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
	$Projectiles.add_child(new_projectile)
