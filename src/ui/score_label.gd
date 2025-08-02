class_name ScoreLabel
extends Node2D


const SCENE := preload("res://src/ui/score_label.tscn")


static func new_label(text: String, location: Vector2) -> ScoreLabel:
	var output: ScoreLabel = SCENE.instantiate()
	output.find_child("Label").text = text
	output.position = location
	return output


func _ready() -> void:
	$AnimationPlayer.play("play")
	$AnimationPlayer.animation_finished.connect(func(_x): queue_free())
