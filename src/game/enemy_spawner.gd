extends Node


const MIN_SPAWN_DISTANCE := 700.0
const MAX_SPAWN_DISTANCE := 1200.0


var enemy := preload("res://src/game/enemy.tscn")
var player: CharacterBody2D
var spawn_per_second := 1

@onready var arena: Node2D = owner
@onready var enemies: Node = $"../Enemies"
@onready var enemy_spawn_timer: Timer = $EnemySpawnTimer


func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")


func _process(_delta: float) -> void:
	# After x time, increase the number of enemies spawned per second
	pass


func spawn_enemy() -> void:
	var new_enemy := enemy.instantiate() as CharacterBody2D
	enemies.add_child(new_enemy)
	# Potentially change spawning away from a circle to make it feel better with a rectangular screen
	var angle := randf() * TAU
	var direction := Vector2(cos(angle), sin(angle)).normalized()
	var distance := randf_range(MIN_SPAWN_DISTANCE, MAX_SPAWN_DISTANCE)
	new_enemy.global_position = player.global_position + direction * distance


func _on_enemy_spawn_timer_timeout() -> void:
	for i in spawn_per_second:
		spawn_enemy()
