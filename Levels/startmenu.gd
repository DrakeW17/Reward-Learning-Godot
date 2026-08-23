extends Control

@onready var tutorialButton: Button = $TutorialButton
@onready var mainGameButton: Button = $GamePlayButton
@onready var calibrationButton: Button = $PracticeButton
@onready var blackOverlay: ColorRect = $BlackOverlay
@onready var fixationCross: Label = $FixationCross
@onready var titleLabel: Label = $TitleLabel
@onready var indexInput: LineEdit = $IndexInput

var t_received = false
var startingIndex = 0

var waiting_for_main_game_start := false # true once T received, waiting on S, specifically for Main Game
var _mainGamePending = false # true only after Main Game button is clicked, arms the T/S listener

func _ready() -> void:
	tutorialButton.pressed.connect(_on_tutorial_pressed)
	calibrationButton.pressed.connect(_on_calibration_pressed)
	mainGameButton.pressed.connect(_on_main_game_pressed)
	indexInput.text_submitted.connect(_on_index_submitted)


	tutorialButton.visible = true
	calibrationButton.visible = true
	mainGameButton.visible = true
	blackOverlay.visible = false
	fixationCross.visible = false
	indexInput.visible = false

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
	_mainGamePending = true
	blackOverlay.visible = true
	blackOverlay.color.a = 1.0
	fixationCross.visible = true
	tutorialButton.visible = false
	calibrationButton.visible = false
	mainGameButton.visible = false
	indexInput.visible = false
	titleLabel.visible = false
	DataManager.set_starting_index(startingIndex)
	waiting_for_main_game_start = true
	

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
