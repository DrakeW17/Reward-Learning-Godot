extends Control

@onready var tutorialButton: Button = $TutorialButton
@onready var mainGameButton: Button = $GamePlayButton

func _ready() -> void:
	tutorialButton.pressed.connect(_on_tutorial_pressed)
	mainGameButton.pressed.connect(_on_main_game_pressed)

func _on_tutorial_pressed() -> void:
	print("tutorial chosen")
	get_tree().change_scene_to_file("res://Levels/tutorial_scene.tscn") 

func _on_main_game_pressed() -> void:
	get_tree().change_scene_to_file("res://main_scene.tscn")
