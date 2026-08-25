extends Node
@onready var pause_ui: CanvasLayer
var auto_pause_timer: Timer


func _ready() -> void:
	pause_ui = preload("res://Levels/PauseUI.tscn").instantiate()
	pause_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(pause_ui)
	pause_ui.visible = false
	pause_ui.resume_pressed.connect(_on_resume_pressed)
	auto_pause_timer = Timer.new()
	auto_pause_timer.wait_time = 480.0 # 8 minutes
	auto_pause_timer.one_shot = true
	add_child(auto_pause_timer)
	auto_pause_timer.timeout.connect(_on_auto_pause_timeout)

func start_auto_pause_timer() -> void:
	auto_pause_timer.start()

func _on_auto_pause_timeout() -> void:
	get_tree().paused = true
	pause_ui.fade_out()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("manual_pause"):
		get_tree().paused = true
		_set_hud_visible(false)
		pause_ui.fade_out()

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
