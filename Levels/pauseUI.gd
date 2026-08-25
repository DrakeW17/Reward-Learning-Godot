extends CanvasLayer

signal resume_pressed

@onready var prompt_label: Label = $PromptLabel
@onready var countdown_label: Label = $CountdownLabel
@onready var fade_overlay: ColorRect = $FadeOverlay
@onready var index_label: Label = $IndexLabel
@onready var percentage_label: Label = $PercentageLabel
@onready var earnings_label: Label = $EarningsLabel
@onready var reaction_time_label: Label = $ReactionTimeLabel

var waiting_for_input := false
var waiting_for_unlock := false
var fade_tween: Tween

func _ready() -> void:
	countdown_label.visible = false
	prompt_label.visible = false
	index_label.visible = false
	percentage_label.visible = false
	earnings_label.visible = false
	reaction_time_label.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	fade_overlay.color.a = 0.0
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _unhandled_input(event: InputEvent) -> void:
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
	
	index_label.visible = true
	index_label.text = "NPC index: %d" % DataManager.npcIndex
	
	earnings_label.visible = true
	var player = get_tree().get_first_node_in_group("player") # requires Player in "player" group
	if player:
		earnings_label.text = "Earnings: $%.2f" % (player.score / 100.0)

	reaction_time_label.visible = true
	reaction_time_label.text = "Reaction Time: %.3fs" % DataManager.reactionTime


	percentage_label.visible = true
	var successRate = GamePlayLog.get_success_percentage()
	percentage_label.text = "Success rate: %.1f%%" % successRate


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
