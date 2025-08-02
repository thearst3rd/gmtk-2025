class_name Player
extends CharacterBody2D


signal player_died()
signal player_hit(current_health: int)
signal shoot(direction: Vector2)


const SPEED := 180.0


var remaining_health := 3
var captured_enemies := 0
var vulnerable := true

@onready var draw_controller: DrawController = $DrawController
@onready var i_frames: Timer = $IFrames


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	velocity = direction * SPEED

	if direction != Vector2.ZERO:
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("default")
	move_and_slide()
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider: Node = collision.get_collider()
		if(collider.is_in_group("HurtsPlayer")):
			player_damaged()
			break


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if(area.is_in_group("HurtsPlayer")):
		player_damaged()


func player_damaged() -> void:
	if(not vulnerable):
		return
	print("Oof ouch owie my bones.")
	remaining_health -= 1
	player_hit.emit(remaining_health)
	if(remaining_health <= 0):
		player_died.emit()
	else:
		vulnerable = false
		i_frames.start()


func _unhandled_input(event: InputEvent) -> void:
	if captured_enemies == 0:
		return

	if event.is_action_pressed(&"shoot"):
		var direction := get_local_mouse_position().normalized()
		shoot.emit(direction)
		captured_enemies -= 1
		if captured_enemies == 0:
			draw_controller.active = true
		get_viewport().set_input_as_handled()


func captured_enemy() -> void:
	captured_enemies += 1


func _on_i_frames_timeout() -> void:
	vulnerable = true
