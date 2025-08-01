class_name Player
extends CharacterBody2D


signal player_died()


const SPEED := 400.0


func _process(_delta: float) -> void:
	var direction := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	velocity = direction * SPEED
	move_and_slide()

func hit_by_cactus() -> void:
	print("Oof ouch owie my bones.")
	player_died.emit()
