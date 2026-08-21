extends Control

@onready var tutorialButton: Button = $TutorialButton
@onready var mainGameButton: Button = $GamePlayButton
@onready var blackOverlay: ColorRect = $BlackOverlay
@onready var fixationCross: Label = $FixationCross
@onready var titleLabel: Label = $TitleLabel
@onready var indexInput: LineEdit = $IndexInput

var t_received = false
var startingIndex = 0

var waiting_for_start := false # true once T has been received, now waiting on S

func _ready() -> void:
	tutorialButton.pressed.connect(_on_tutorial_pressed)
	mainGameButton.pressed.connect(_on_main_game_pressed)
	indexInput.text_submitted.connect(_on_index_submitted)
	tutorialButton.visible = false
	mainGameButton.visible = false
	blackOverlay.visible = true
	blackOverlay.color.a = 1.0
	fixationCross.visible = true
	titleLabel.visible = false
	indexInput.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("T") and not waiting_for_start and not t_received:
		waiting_for_start = true
		t_received = true
		print("Scan sync received, waiting for experimenter to press S")
		return

	if event.is_action_pressed("start") and waiting_for_start:
		print("Starting game")
		waiting_for_start = false
		_reveal_menu()

func _reveal_menu() -> void:
	blackOverlay.visible = false
	fixationCross.visible = false
	tutorialButton.visible = true
	mainGameButton.visible = true
	titleLabel.visible = true
	
func _on_index_submitted(text: String) -> void:
	print("Starting index:", text)
	startingIndex = int(text)
	DataManager.set_starting_index(startingIndex)
	get_tree().change_scene_to_file("res://main_scene.tscn")


func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/tutorial_scene.tscn") 

func _on_main_game_pressed() -> void:
	indexInput.visible = true
	
