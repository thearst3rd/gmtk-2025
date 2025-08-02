extends Control


signal exited()


const TEXT = [
	"Capture enemies in your lasso by clicking and dragging with the mouse to draw a loop around them.",
	"When you have an enemy capture, aim at a cactus, rock or other enemy and click to shoot.",
	"If you draw a very round circle, your cursor will turn gold, and your projectiles may have extra effects.",
]

const MAX_SCREENS = 3


var current_screen_idx = 0


@onready var prev_button: Button = %PrevButton
@onready var next_button: Button = %NextButton
@onready var step_explanation: Label = %StepExplanation
@onready var lasso_view: Node2D = %LassoView
@onready var projectile_view: Node2D = %ProjectileView
@onready var gold_view: Node2D = %GoldView
@onready var gold_cursor: AnimatedSprite2D = $GoldView/GoldCursor


func _ready() -> void:
	current_screen_idx = 0
	lasso_view.hide()
	projectile_view.hide()
	gold_view.hide()
	gold_cursor.play("default")


func to_prev_screen() -> void:
	current_screen_idx -= 1
	assert(current_screen_idx >= 0)
	load_screen()


func to_next_screen() -> void:
	current_screen_idx += 1
	assert(current_screen_idx < MAX_SCREENS)
	load_screen()


func load_screen() -> void:
	step_explanation.text = TEXT[current_screen_idx]

	if current_screen_idx == 0:
		projectile_view.hide()
		gold_view.hide()
		prev_button.disabled = true
		next_button.disabled = false
		$AnimationPlayer.play("lasso_view")
	elif current_screen_idx == 1:
		lasso_view.hide()
		gold_view.hide()
		prev_button.disabled = false
		next_button.disabled = false
		$AnimationPlayer.play("projectile_view")
	elif current_screen_idx == 2:
		$AnimationPlayer.stop()
		lasso_view.hide()
		projectile_view.hide()
		gold_view.show()
		prev_button.disabled = false
		next_button.disabled = true


func close_menu() -> void:
	hide()
	$AnimationPlayer.stop()
	exited.emit()
