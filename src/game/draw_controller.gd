class_name DrawController
extends Node2D


signal line_complete(points: Array[Vector2], penalty: float)


@export var SHOW_DEBUG_COMPARISON := false

# Distance (in pixels) a new point must be from the previous point
@export var NEW_POINT_DIST_THRESHOLD := 20.0

# Maximum total length of a line
@export var MAXIMUM_LINE_DISTANCE := 150.0

# Maxmimum length of a gap between the end and start of a line.
@export var MAXIMUM_GAP := 50.0

# Penalty threshold - higher than this value and it doesn't count as a circle
const PENALTY_THRESHOLD := 25.0

var active := true
var golden := false
var drawing := false
var drawing_points: Array[Vector2]
var current_length: float

@onready var line: Line2D = $Line2D
@onready var comparison_line: Line2D = $ComparisonLine

@onready var failed_line: Line2D = $FailedLine
@onready var fail_animation: AnimationPlayer = %FailAnimation
@onready var success_line: Line2D = $SuccessLine
@onready var success_animation: AnimationPlayer = %SuccessAnimation

@onready var success_tween: Tween = null


func _unhandled_input(event: InputEvent) -> void:
	if not active:
		if event is InputEventMouseMotion:
			_draw_crosshair()
			get_viewport().set_input_as_handled()
		return
	else:
		$Crosshair.hide()
		$CrosshairLine.hide()
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
	current_length = 0.0
	var current_mouse := get_local_mouse_position()
	drawing_points.push_back(current_mouse)
	line.clear_points()
	line.add_point(current_mouse)
	line.add_point(current_mouse)
	line.show()
	comparison_line.hide()


func _drawing_moved() -> void:
	if current_length > MAXIMUM_LINE_DISTANCE:
		# Limit the total length of line a player can draw.
		return
	var last_point: Vector2 = drawing_points.back()
	var current_mouse := get_local_mouse_position()
	line.set_point_position(line.points.size() - 1, current_mouse)
	var distance_squared_to_last_point := last_point.distance_squared_to(current_mouse)
	if distance_squared_to_last_point >= NEW_POINT_DIST_THRESHOLD * NEW_POINT_DIST_THRESHOLD:
		drawing_points.push_back(current_mouse)
		line.add_point(current_mouse)
		current_length += sqrt(distance_squared_to_last_point)
		if _check_crossover(drawing_points):
			_drawing_finished()


func _drawing_finished() -> void:
	drawing = false
	if not SHOW_DEBUG_COMPARISON:
		line.hide()

	if drawing_points.size() < 3:
		print("Not enough points")
		_drawing_failed()
		return

	# How good of a circle was this?
	var mean_circle := _get_mean_circle(drawing_points)
	var mean_center: Vector2 = mean_circle[0]
	var mean_radius: float = mean_circle[1]

	var penalty := _check_circularity(drawing_points, mean_center, mean_radius)

	var is_closed := _check_if_closed(drawing_points)

	print("Penalty: %f, Closed: %s" % [penalty, "true" if is_closed else "false"])

	if SHOW_DEBUG_COMPARISON:
		comparison_line.clear_points()
		for i in range(64):
			comparison_line.add_point(mean_center + mean_radius * Vector2.from_angle(float(i) * TAU / 64.0))
		if penalty < PENALTY_THRESHOLD and is_closed:
			comparison_line.default_color = Color.GREEN
		else:
			comparison_line.default_color = Color.RED
		comparison_line.show()

	if not is_closed:
		_drawing_failed()
		return

	# Now that the loop is finished, convert all of the points into their global position
	for idx in range(len(drawing_points)):
		drawing_points[idx] = drawing_points[idx] + global_position
	_drawing_succeeded(mean_center)
	line_complete.emit(drawing_points, penalty)


# Check if the last point added has crossed over the existing line.
func _check_crossover(points: Array[Vector2]) -> bool:
	var last_point := points[-1]

	var threshold_sq := NEW_POINT_DIST_THRESHOLD * NEW_POINT_DIST_THRESHOLD

	if len(points) <= 4:
		return false

	# Ignore the last few points because they are likely to be within the threshold.
	for point in points.slice(0, -3):
		if last_point.distance_squared_to(point) < threshold_sq:
			return true

	return false


# Get the mean circle given a group of points. Will return an array with the first element being the
# center of the circle as a Vector2, and the second being the radius of the circle as a float.
func _get_mean_circle(points: Array[Vector2]) -> Array:
	var mean_point := Vector2.ZERO
	for point in points:
		mean_point += point
	mean_point /= points.size()
	var mean_radius := 0.0
	for point in points:
		mean_radius += point.distance_to(mean_point)
	mean_radius /= points.size()

	return [mean_point, mean_radius]


# How good of a circle is the list of points passed in. Will return a penalty value.
func _check_circularity(points: Array[Vector2], center: Vector2, radius: float) -> float:
	var total_penalty := 0.0
	for point in points:
		var new_point := (point - center) / radius
		#print(new_point)
		var penalty := absf(1 - new_point.length())
		total_penalty += penalty
	total_penalty /= drawing_points.size()
	total_penalty *= 100.0
	return total_penalty


# Determine if a loop is "close enough" to being closed.
func _check_if_closed(points: Array[Vector2]) -> bool:
	var last_point := points[-1]

	var threshold_sq := MAXIMUM_GAP * MAXIMUM_GAP

	# Only check the first part of the loop.
	for point in points.slice(0, roundi(points.size() * 0.2)):
		if last_point.distance_squared_to(point) < threshold_sq:
			return true

	return false


func _drawing_failed() -> void:
	line.hide()
	failed_line.points = line.points
	fail_animation.stop()
	fail_animation.play(&"failed")


func _drawing_succeeded(mean_point: Vector2) -> void:
	line.hide()
	success_line.clear_points()
	for i in range(line.get_point_count()):
		success_line.add_point(line.get_point_position(i) - mean_point)
	success_line.position = mean_point
	success_animation.stop()
	success_animation.play(&"success")

	if success_tween:
		success_tween.stop()
	success_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	success_tween.tween_property(success_line, ^"position", Vector2.ZERO, 0.5)


func _draw_crosshair() -> void:
	var mouse_pos := get_local_mouse_position()
	if golden:
		$Crosshair.play("gold")
		$CrosshairLine.texture = preload("res://assets/crosshair_line_gold.png")
	else:
		$Crosshair.play("default")
		$CrosshairLine.texture = preload("res://assets/crosshair_line_normal.png")
	$Crosshair.position = mouse_pos
	$Crosshair.show()
	$CrosshairLine.set_point_position(1, mouse_pos)
	$CrosshairLine.show()
