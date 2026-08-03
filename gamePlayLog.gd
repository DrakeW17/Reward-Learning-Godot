extends Node

var log_entries: Array = []
var has_exported := false
var instance_id = randi()


func _ready() -> void:
	# Ensures this node receives quit/close notifications
	get_tree().set_auto_accept_quit(false)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		export_log()
		get_tree().quit() # actually close the window after exporting


func record_interaction(interaction_type: String, success: bool, reaction_time: float, reward_amount: float) -> void:
	var entry = {
		"timestamp": Time.get_datetime_string_from_system(),
		"interaction_type": interaction_type,
		"reward_amount":  reward_amount,
		"success": success,
		"reaction_time": reaction_time
	}
	log_entries.append(entry)

func export_log(path: String = "") -> void:
	if has_exported:
		return
	if path == "":
		var datetime = Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_")
		path = "user://%s_interaction_log.csv" % datetime

	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("GameplayLog: failed to open file for writing at " + path)
		return

	file.store_line("timestamp,interaction_type,success,reaction_time,reward_amount")
	for entry in log_entries:
		file.store_line("%s,%s,%s,%.3f,%s" % [entry.timestamp, entry.interaction_type, entry.success, entry.reaction_time, entry.reward_amount])
	file.close()

	print("GameplayLog: exported to ", ProjectSettings.globalize_path(path))
	has_exported = true
	
func clear_log() -> void:
	log_entries.clear()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"): # Escape by default
		export_log()
