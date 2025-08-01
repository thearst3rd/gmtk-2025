class_name Player
extends CharacterBody2D


signal player_died()
signal shoot(direction: Vector2)


const SPEED := 180.0


@onready var draw_controller: DrawController = $DrawController


var captured_enemies := 0


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	velocity = direction * SPEED

	if direction != Vector2.ZERO:
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("default")
	move_and_slide()


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


func hit_by_cactus() -> void:
	print("Oof ouch owie my bones.")
	player_died.emit()


func captured_enemy() -> void:
	captured_enemies += 1
