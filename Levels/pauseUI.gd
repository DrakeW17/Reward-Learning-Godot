extends CanvasLayer

signal resume_pressed

@onready var prompt_label: Label = $PromptLabel
@onready var countdown_label: Label = $CountdownLabel
@onready var fade_overlay: ColorRect = $FadeOverlay

var waiting_for_input := false
var fade_tween: Tween

func _ready() -> void:
	countdown_label.visible = false
	prompt_label.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	fade_overlay.color.a = 0.0
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	prompt_label.add_theme_font_size_override("font_size", 48)
	prompt_label.add_theme_color_override("font_color", Color("#D4AF37"))
	prompt_label.add_theme_color_override("font_outline_color", Color.BLACK)
	prompt_label.add_theme_constant_override("outline_size", 4)

func fade_out() -> void:
	visible = true
	countdown_label.visible = false
	waiting_for_input = false

	prompt_label.visible = true
	prompt_label.text = "Game paused for break"
	
	if is_instance_valid(fade_tween):
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(fade_overlay, "color:a", 1.0, 0.6) # fade to black
	await fade_tween.finished

	await get_tree().create_timer(10.0).timeout # forward press ignored during this wait
	
	prompt_label.add_theme_font_size_override("font_size", 48)

	prompt_label.text = "Press forward to continue"
	waiting_for_input = true
	
func _unhandled_input(event: InputEvent) -> void:
	if waiting_for_input and event.is_action_pressed("move_right"):
		print("move right pressed")
		waiting_for_input = false
		resume_pressed.emit()


func start_countdown() -> void:
	waiting_for_input = false

	if is_instance_valid(fade_tween):
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(fade_overlay, "color:a", 0.0, 10.0) # fade back in over 10s

	for i in range(10, 0, -1):
		prompt_label.text = str(i)
		await get_tree().create_timer(1.0).timeout 

	prompt_label.visible = false
	PauseManager.actually_resume()
