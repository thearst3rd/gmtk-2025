extends Control


signal exited()


const TEXT = [
	"Capture enemies in your lasso by clicking and dragging with the mouse to draw a loop around them. The loop has to be closed and fully contain the enemy.",
	"When you have an enemy captured, aim at a cactus, rock, or other enemy, and click to shoot. You can capture multiple enemies in the same loop.",
	"If the loop you drew is close to a perfect circle, your cursor will turn gold, and projectiles you throw will cause a chain reaction!",
	"The longer you're alive, the more difficult it will get, and the faster that enemies will spawn. Try to get as many points as you can!",
]

const MAX_SCREENS = 4


var current_screen_idx = 0


@onready var prev_button: Button = %PrevButton
@onready var next_button: Button = %NextButton
@onready var step_explanation: Label = %StepExplanation

@onready var lasso_view: Node2D = %LassoView
@onready var projectile_view: Node2D = %ProjectileView
@onready var gold_view: Node2D = %GoldView
@onready var difficulty_view: Node2D = $DifficultyView

@onready var gold_cursor: AnimatedSprite2D = $GoldView/GoldCursor


func _ready() -> void:
	current_screen_idx = 0
	lasso_view.hide()
	projectile_view.hide()
	gold_view.hide()
	gold_cursor.play(&"default")


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

	prev_button.disabled = current_screen_idx <= 0
	next_button.disabled = current_screen_idx >= MAX_SCREENS - 1

	$AnimationPlayer.stop()
	lasso_view.hide()
	projectile_view.hide()
	gold_view.hide()
	difficulty_view.hide()

	if current_screen_idx == 0:
		$AnimationPlayer.play(&"lasso_view")
	elif current_screen_idx == 1:
		$AnimationPlayer.play(&"projectile_view")
	elif current_screen_idx == 2:
		gold_view.show()
	elif current_screen_idx == 3:
		$AnimationPlayer.play(&"difficulty_view")


func focus() -> void:
	next_button.grab_focus()


func close_menu() -> void:
	hide()
	$AnimationPlayer.stop()
	exited.emit()
