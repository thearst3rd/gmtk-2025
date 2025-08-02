class_name Player
extends CharacterBody2D


signal player_died()
signal player_hit(current_health: int)
signal shoot(location: Vector2, direction: Vector2, billiard: int)


const SPEED := 180.0


var remaining_health := 3
var captured_enemies := 0
var vulnerable := true

@onready var draw_controller: DrawController = $DrawController
@onready var i_frames: Timer = $IFrames
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var footsteps: Array[AudioStreamPlayer] = [$Footstep1, $Footstep2, $Footstep3]


func _physics_process(_delta: float) -> void:
	if remaining_health <= 0:
		return

	var direction := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	velocity = direction * SPEED

	if direction != Vector2.ZERO:
		animated_sprite.play("walk")
	else:
		animated_sprite.play("default")
	move_and_slide()
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider: Node = collision.get_collider()
		if collider.is_in_group("HurtsPlayer"):
			player_damaged()
			break


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("HurtsPlayer"):
		player_damaged()


func player_damaged() -> void:
	if not vulnerable:
		return
	print("Oof ouch owie my bones.")
	remaining_health -= 1
	player_hit.emit(remaining_health)
	if remaining_health <= 0:
		player_died.emit()
	else:
		vulnerable = false
		i_frames.start()


func _unhandled_input(event: InputEvent) -> void:
	if captured_enemies == 0:
		return

	if event.is_action_pressed(&"shoot"):
		var direction := get_local_mouse_position().normalized()
		shoot.emit(position, direction, 2 if draw_controller.golden else 0)
		captured_enemies -= 1
		if captured_enemies == 0:
			draw_controller.active = true
		get_viewport().set_input_as_handled()


func captured_enemy() -> void:
	captured_enemies += 1


func _on_i_frames_timeout() -> void:
	vulnerable = true


func _on_frame_changed() -> void:
	if animated_sprite.frame in [1, 3]:
		play_footstep()


func play_footstep() -> void:
	footsteps.pick_random().play()
