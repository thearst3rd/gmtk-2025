extends Node2D


signal enemy_respawn(pos: Vector2)
signal enemy_hit(other: Node2D)


@export var MAX_DISTANCE := 250
@export var SPEED := 20


@onready var distance_traveled := 0


var initial_position: Vector2
var direction: Vector2


func _physics_process(delta: float) -> void:
	position += delta * SPEED * direction
	if position.distance_squared_to(initial_position) > MAX_DISTANCE * MAX_DISTANCE:
		enemy_respawn.emit(position)
		queue_free()


func on_body_entered(body: Node2D) -> void:
	if body is Player:
		return
	# Fancy particle effects, etc.
	enemy_hit.emit(body)
	queue_free()
