extends Control
@onready var tutorialButton: Button = $TutorialButton
@onready var mainGameButton: Button = $GamePlayButton
@onready var calibrationButton: Button = $PracticeButton
@onready var blackOverlay: ColorRect = $BlackOverlay
@onready var fixationCross: Label = $FixationCross
@onready var titleLabel: Label = $TitleLabel
@onready var indexInput: LineEdit = $IndexInput
@onready var reactionTimeInput: LineEdit = $ReactionTimeInput
@onready var startingAmountInput: LineEdit = $StartingAmountInput


var t_received = false
var startingIndex = 0
var waiting_for_main_game_start := false
var _mainGamePending = false

func _ready() -> void:
	tutorialButton.pressed.connect(_on_tutorial_pressed)
	calibrationButton.pressed.connect(_on_calibration_pressed)
	mainGameButton.pressed.connect(_on_main_game_pressed)
	indexInput.text_submitted.connect(_on_index_submitted)
	reactionTimeInput.text_submitted.connect(_on_reaction_time_submitted)
	startingAmountInput.text_submitted.connect(_on_starting_amount_submitted)


	tutorialButton.visible = true
	calibrationButton.visible = true
	mainGameButton.visible = true
	blackOverlay.visible = false
	fixationCross.visible = false
	indexInput.visible = false
	reactionTimeInput.visible = false
	startingAmountInput.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("T") and waiting_for_main_game_start == false and _mainGamePending:
		waiting_for_main_game_start = true
		print("Scan sync received, waiting for experimenter to press S")
		return
	if event.is_action_pressed("start") and waiting_for_main_game_start:
		waiting_for_main_game_start = false
		_mainGamePending = false
		_launch_main_game()

func _on_index_submitted(text: String) -> void:
	print("Starting index:", text)
	startingIndex = int(text)
	DataManager.set_starting_index(startingIndex)
	indexInput.visible = false
	reactionTimeInput.visible = true # ask for reaction time next

func _on_reaction_time_submitted(text: String) -> void:
	var enteredTime = float(text)
	if enteredTime > 0.0:
		DataManager.reactionTime = enteredTime
		print("Starting reactionTime set to: ", enteredTime)
	else:
		print("Invalid reactionTime entered, keeping default: ", DataManager.reactionTime)

	reactionTimeInput.visible = false
	startingAmountInput.visible = true

	
func _on_starting_amount_submitted(text: String) -> void:
	var dollars = float(text)
	if dollars > 0.0:
		DataManager.startingBalanceCents = int(round(dollars * 100))
		print("Starting balance set to: $", dollars, " (", DataManager.startingBalanceCents, " cents)")
	else:
		print("Invalid starting amount entered, keeping default: ", DataManager.startingBalanceCents, " cents")

	reactionTimeInput.visible = false
	_mainGamePending = true
	blackOverlay.visible = true
	blackOverlay.color.a = 1.0
	fixationCross.visible = true
	tutorialButton.visible = false
	calibrationButton.visible = false
	mainGameButton.visible = false
	titleLabel.visible = false
	startingAmountInput.visible = false

func _on_calibration_pressed() -> void:
	DataManager.start_precalibration()
	get_tree().change_scene_to_file("res://Levels/calibration_scene.tscn")

func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/tutorial_scene.tscn")

func _on_main_game_pressed() -> void:
	indexInput.visible = true

func _launch_main_game() -> void:
	DataManager.start_main_game_tracking()
	get_tree().change_scene_to_file("res://main_scene.tscn")
