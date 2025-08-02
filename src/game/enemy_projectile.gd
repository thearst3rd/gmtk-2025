extends Node2D


signal enemy_respawn(pos: Vector2)
signal object_hit(other: Node2D, position: Vector2, billiard_ball: int)


@export var MAX_DISTANCE := 250
@export var SPEED := 20


@onready var hit: AudioStreamPlayer2D = $Hit


var initial_position: Vector2
var direction: Vector2
var billiard_ball: int = 0


func _physics_process(delta: float) -> void:
	position += delta * SPEED * direction
	if position.distance_squared_to(initial_position) > MAX_DISTANCE * MAX_DISTANCE:
		enemy_respawn.emit(position)
		queue_free()


func init(init_position: Vector2, init_direction: Vector2) -> void:
	position = init_position
	initial_position = init_position
	direction = init_direction
	if direction.x < 0:
		$AnimationPlayer.play("left")
	else:
		$AnimationPlayer.play("right")


func on_body_entered(body: Node2D) -> void:
	if body is Player or body.owner is Player:
		return
	hide()
	object_hit.emit(body, position, billiard_ball)
	if billiard_ball != 2:
		hit.play()
		hit.reparent(get_parent())
	queue_free()
