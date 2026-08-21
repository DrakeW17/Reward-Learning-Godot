extends CanvasLayer

signal resume_pressed

@onready var prompt_label: Label = $PromptLabel
@onready var countdown_label: Label = $CountdownLabel
@onready var fade_overlay: ColorRect = $FadeOverlay

var waiting_for_input := false
var waiting_for_unlock := false
var fade_tween: Tween

func _ready() -> void:
	countdown_label.visible = false
	prompt_label.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	fade_overlay.color.a = 0.0
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _unhandled_input(event: InputEvent) -> void:
	if waiting_for_unlock and event.is_action_pressed("unlock_pause"):
		waiting_for_unlock = false
		prompt_label.text = "Press forward to continue"
		waiting_for_input = true
		return

	if waiting_for_input and event.is_action_pressed("move_right"):
		waiting_for_input = false
		resume_pressed.emit()

func fade_out() -> void:
	visible = true
	countdown_label.visible = false
	waiting_for_input = false
	waiting_for_unlock = true

	prompt_label.visible = true
	prompt_label.text = "Game paused for break"

	if is_instance_valid(fade_tween):
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(fade_overlay, "color:a", 1.0, 0.6)
	await fade_tween.finished

func start_countdown() -> void:
	waiting_for_input = false
	prompt_label.visible = false
	countdown_label.visible = true
	countdown_label.add_theme_font_size_override("font_size", 96)

	if is_instance_valid(fade_tween):
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(fade_overlay, "color:a", 0.0, 10.0)

	for i in range(10, 0, -1):
		countdown_label.text = str(i)
		await get_tree().create_timer(1.0).timeout

	countdown_label.visible = false
	PauseManager.actually_resume()
