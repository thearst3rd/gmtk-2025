extends HBoxContainer


const MAX_HEALTH := 3


var healthy_texture := preload("res://assets/cowboy_hat.png")
var unhealthy_texture := preload("res://icon.svg")

@onready var health_markers: Array[TextureRect] = [$HealthMarker, $HealthMarker2, $HealthMarker3]


func _on_player_player_hit(current_health: int) -> void:
	if current_health >= MAX_HEALTH:
		return
	for i in MAX_HEALTH:
		if i >= current_health:
			health_markers[i].texture = unhealthy_texture
