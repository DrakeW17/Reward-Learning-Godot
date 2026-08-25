extends Node
@onready var pause_ui: CanvasLayer

func _ready() -> void:
	pause_ui = preload("res://Levels/PauseUI.tscn").instantiate()
	pause_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(pause_ui)
	pause_ui.visible = false
	pause_ui.resume_pressed.connect(_on_resume_pressed)
	

func _on_resume_pressed() -> void:
	pause_ui.start_countdown()

func actually_resume() -> void:
	get_tree().paused = false
	pause_ui.visible = false
	_set_hud_visible(true)

func _set_hud_visible(is_visible: bool) -> void:
	var player = get_tree().get_first_node_in_group("player") 
	if player:
		player.scoreUI.visible = is_visible
