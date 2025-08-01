extends Node2D


const SHOW_DEBUG_COMPARISON := true

# Distance (in pixels) a new point must be from the previous point
const NEW_POINT_DIST_THRESHOLD := 20.0
# Penalty threshold - higher than this value and it doesn't count as a circle
const PENALTY_THRESHOLD := 25.0

var drawing := false
var drawing_points: Array[Vector2]

@onready var line: Line2D = $Line2D
@onready var comparison_line: Line2D = $ComparisonLine


func _unhandled_input(event: InputEvent) -> void:
	if drawing:
		if event is InputEventMouseMotion:
			_drawing_moved()
			get_viewport().set_input_as_handled()
		if event.is_action_released(&"shoot"):
			_drawing_finished()
			get_viewport().set_input_as_handled()
	else:
		if event.is_action_pressed(&"shoot"):
			_drawing_started()
			get_viewport().set_input_as_handled()


func _drawing_started() -> void:
	drawing = true
	drawing_points = []
	var current_mouse := get_local_mouse_position()
	drawing_points.push_back(current_mouse)
	line.clear_points()
	line.add_point(current_mouse)
	line.add_point(current_mouse)
	line.show()
	comparison_line.hide()


func _drawing_moved() -> void:
	var last_point: Vector2 = drawing_points.back()
	var current_mouse := get_local_mouse_position()
	line.set_point_position(line.points.size() - 1, current_mouse)
	if last_point.distance_squared_to(current_mouse) >= NEW_POINT_DIST_THRESHOLD * NEW_POINT_DIST_THRESHOLD:
		drawing_points.push_back(current_mouse)
		line.add_point(current_mouse)


func _drawing_finished() -> void:
	drawing = false
	if not SHOW_DEBUG_COMPARISON:
		line.hide()

	if drawing_points.size() < 3:
		print("Not enough points")
		return

	# How good of a circle was this?
	var mean_point := Vector2.ZERO
	for point in drawing_points:
		mean_point += point
	mean_point /= drawing_points.size()
	var mean_radius := 0.0
	for point in drawing_points:
		mean_radius += point.distance_to(mean_point)
	mean_radius /= drawing_points.size()

	var total_penalty := 0.0
	for point in drawing_points:
		var new_point := (point - mean_point) / mean_radius
		#print(new_point)
		var penalty := absf(1 - new_point.length())
		total_penalty += penalty
	total_penalty /= drawing_points.size()
	total_penalty *= 100.0
	print(total_penalty)

	if SHOW_DEBUG_COMPARISON:
		comparison_line.clear_points()
		for i in range(64):
			comparison_line.add_point(mean_point + mean_radius * Vector2.from_angle(float(i) * TAU / 64.0))
		if total_penalty < PENALTY_THRESHOLD:
			comparison_line.default_color = Color.GREEN
		else:
			comparison_line.default_color = Color.RED
		comparison_line.show()
