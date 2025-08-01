extends Node2D


var game_time: float = 0

@onready var player: CharacterBody2D = %Player


func _process(delta: float) -> void:
	game_time += delta
