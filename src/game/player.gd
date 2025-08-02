class_name Player
extends CharacterBody2D


signal player_died()
signal player_hit()


const SPEED := 180.0


var remaining_health := 3


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	velocity = direction * SPEED
	move_and_slide()


func player_damaged() -> void:
	print("Oof ouch owie my bones.")
	remaining_health -= 1
	player_hit.emit()
	if(remaining_health <= 0):
		player_died.emit()


func _on_area_entered(area: Area2D) -> void:
	if(area.is_in_group("HurtsPlayer")):
		player_damaged()
