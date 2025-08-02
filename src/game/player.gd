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
@onready var hurtbox: Area2D = %Hurtbox
@onready var footsteps: Array[AudioStreamPlayer] = [$Footstep1, $Footstep2, $Footstep3]
@onready var shoot_sound: AudioStreamPlayer = $ShootSound
@onready var hurt_sound: AudioStreamPlayer = $HurtSound
@onready var game_over_sound: AudioStreamPlayer = $GameOverSound
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animation_player.play(&"normal")


func _physics_process(_delta: float) -> void:
	if remaining_health <= 0:
		return

	var direction := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	velocity = direction * SPEED

	if direction != Vector2.ZERO:
		animated_sprite.play(&"walk")
	else:
		animated_sprite.play(&"default")
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
		game_over_sound.play()
		player_died.emit()
		animated_sprite.play(&"default")
		animation_player.play(&"dead")
		draw_controller.cancel_drawing()
	else:
		hurt_sound.play()
		vulnerable = false
		animation_player.play(&"invincible")
		i_frames.start()


func _unhandled_input(event: InputEvent) -> void:
	if captured_enemies == 0:
		return

	if event.is_action_pressed(&"shoot"):
		var direction := get_local_mouse_position().normalized()
		shoot.emit(position, direction, 1 if draw_controller.golden else 0)
		shoot_sound.play()
		captured_enemies -= 1
		if captured_enemies == 0:
			draw_controller.active = true
		get_viewport().set_input_as_handled()


func captured_enemy() -> void:
	captured_enemies += 1


func _on_i_frames_timeout() -> void:
	animation_player.play(&"normal")
	vulnerable = true
	var areas := hurtbox.get_overlapping_areas()
	for area in areas:
		_on_hurtbox_area_entered(area)


func _on_frame_changed() -> void:
	if animated_sprite.animation == &"walk":
		if animated_sprite.frame in [1, 3]:
			play_footstep()


func play_footstep() -> void:
	footsteps.pick_random().play()
