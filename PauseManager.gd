extends Node

var play_timer: Timer
var pause_pending := false
var emerging_count := 0

@onready var pause_ui: CanvasLayer

func _ready() -> void:
	play_timer = Timer.new()
	play_timer.wait_time = 10 #480.0 # 8 minutes
	play_timer.one_shot = true # still one_shot -- we manually restart it each cycle
	add_child(play_timer)
	play_timer.timeout.connect(_on_play_timer_timeout)
	play_timer.start()

	pause_ui = preload("res://PauseUI.tscn").instantiate()
	pause_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(pause_ui)
	pause_ui.visible = false
	pause_ui.resume_pressed.connect(_on_resume_pressed)
	

func _on_play_timer_timeout() -> void:
	pause_pending = true
	_try_pause()

func notify_emerge_started() -> void:
	emerging_count += 1

func notify_emerge_finished() -> void:
	emerging_count = max(0, emerging_count - 1)
	_try_pause()

func _try_pause() -> void:
	if pause_pending and emerging_count == 0:
		print("paused")
		pause_pending = false
		get_tree().paused = true
		pause_ui.fade_out()

func _on_resume_pressed() -> void:
	pause_ui.start_countdown()

func actually_resume() -> void:
	get_tree().paused = false
	pause_ui.visible = false
	play_timer.start() # restart the 8-minute cycle now that play has resumed
