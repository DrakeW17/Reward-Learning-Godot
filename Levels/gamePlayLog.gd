extends Node
var log_entries: Array = []
var instance_id = randi()
var last_t_time_ms = -1.0
var log_path = ""
var header_written = false

func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	process_mode = Node.PROCESS_MODE_ALWAYS

	var datetime = Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_")
	log_path = "user://%s_interaction_log.csv" % datetime
	print("GameplayLog: writing to ", ProjectSettings.globalize_path(log_path))

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()

func record_interaction(interaction_type: String, success: bool, reaction_time: float, reward_amount: float) -> void:
	var now_ms = Time.get_ticks_msec()
	var time_since_last_T = (now_ms - last_t_time_ms) if last_t_time_ms >= 0 else -1.0

	var entry = {
		"timestamp": Time.get_datetime_string_from_system(),
		"time_since_last_T": time_since_last_T,
		"interaction_type": interaction_type,
		"reward_amount": reward_amount,
		"success": success,
		"reaction_time": reaction_time
	}
	log_entries.append(entry) # kept for optional in-memory reference/debugging
	_write_entry(entry)

func _write_entry(entry: Dictionary) -> void:
	var file
	if FileAccess.file_exists(log_path):
		file = FileAccess.open(log_path, FileAccess.READ_WRITE)
	else:
		file = FileAccess.open(log_path, FileAccess.WRITE)

	if file == null:
		push_error("GameplayLog: failed to open file for writing at " + log_path)
		return

	file.seek_end() # always append, never overwrite

	if not header_written:
		file.store_line("timestamp,time_since_last_T,interaction_type,success,reaction_time,reward_amount")
		header_written = true

	file.store_line("%s,%s,%s,%s,%.3f,%s" % [entry.timestamp, entry.time_since_last_T, entry.interaction_type, entry.success, entry.reaction_time, entry.reward_amount])
	file.close()

func clear_log() -> void:
	log_entries.clear()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("T"):
		last_t_time_ms = Time.get_ticks_msec()
		record_interaction("Scanning Start Time", true, 0.0, 0.0)
		print("Scanning Started")
