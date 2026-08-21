extends Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("abort_game"):
		GamePlayLog._write_final_summary()
		get_tree().quit()
