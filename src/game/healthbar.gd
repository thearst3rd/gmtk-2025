extends HBoxContainer


const MAX_HEALTH := 3

var health_markers: Array[TextureRect]
var healthy_texture := preload("res://assets/cowboy_hat.png")
var unhealthy_texture := preload("res://icon.svg")

@onready var health_marker: TextureRect = $HealthMarker
@onready var health_marker_2: TextureRect = $HealthMarker2
@onready var health_marker_3: TextureRect = $HealthMarker3


func _ready() -> void:
	health_markers.append_array([health_marker, health_marker_2, health_marker_3])


func _on_player_player_hit(current_health: int) -> void:
	if(current_health >= MAX_HEALTH):
		return
	for i in MAX_HEALTH:
		if(i >= current_health):
			health_markers[i].texture = unhealthy_texture
