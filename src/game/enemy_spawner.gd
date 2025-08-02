extends Node


signal difficulty_up()


@export var MIN_SPAWN_DISTANCE := 700.0
@export var MAX_SPAWN_DISTANCE := 1200.0
@export var DESPAWN_DISTANCE := 1800.0
@export var TIME_BETWEEN_ROUNDS := 60

var enemy := preload("res://src/game/enemy.tscn")
var player: CharacterBody2D
var spawn_per_second := 0.25
var spawn_per_second_multiplier := 1.0
var remainder := 0.0
var spawn_stage := 0
var min_enemies := 10
var max_enemies := 100

@onready var arena: Node2D = owner
@onready var enemies: Node = $"../Enemies"
@onready var enemy_spawn_timer: Timer = $EnemySpawnTimer


func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")


func _process(_delta: float) -> void:
	if enemies.get_child_count() < min_enemies:
		spawn_per_second_multiplier = 5
	elif enemies.get_child_count() >= max_enemies:
		spawn_per_second_multiplier = 0.2
	else:
		spawn_per_second_multiplier = 1
	# After x time, increase the number of enemies spawned per second
	if floor(arena.game_time / TIME_BETWEEN_ROUNDS) > spawn_stage:
		spawn_stage += 1
		spawn_per_second = 0.25 + spawn_stage * spawn_stage * 0.5
		min_enemies += 5
		max_enemies += 20
		difficulty_up.emit()

	for enemy_node in enemies.get_children():
		var enemy_pos: Vector2 = enemy_node.position
		if enemy_pos.distance_squared_to(arena.player.position) > DESPAWN_DISTANCE * DESPAWN_DISTANCE:
			enemies.remove_child(enemy_node)
			enemy_node.queue_free()


func spawn_enemy() -> void:
	if arena.player.remaining_health <= 0:
		return
	var new_enemy := enemy.instantiate() as CharacterBody2D
	# Potentially change spawning away from a circle to make it feel better with a rectangular screen
	var angle := randf() * TAU
	var direction := Vector2(cos(angle), sin(angle)).normalized()
	var distance := randf_range(MIN_SPAWN_DISTANCE, MAX_SPAWN_DISTANCE)
	new_enemy.position = player.global_position + direction * distance
	enemies.add_child(new_enemy)


func _on_enemy_spawn_timer_timeout() -> void:
	var num_spawns: float = spawn_per_second * spawn_per_second_multiplier
	remainder += num_spawns - floor(num_spawns)
	if remainder >= 1:
		num_spawns += 1
		remainder -= 1
	for i in floor(num_spawns):
		spawn_enemy()
