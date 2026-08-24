extends Node
var log_entries: Array = []
var instance_id = randi()
var last_t_time_ms = -1.0
var log_path = ""
var header_written = false
var first_t_recorded = false 

func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	process_mode = Node.PROCESS_MODE_ALWAYS

	var datetime = Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_")
	log_path = "user://%s_interaction_log.csv" % datetime
	print("GameplayLog: writing to ", ProjectSettings.globalize_path(log_path))

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_write_final_summary()
		get_tree().quit()

func record_interaction(
	interaction_type: String,
	success: bool,
	reaction_time: float,
	reward_amount: float,
	t_bush_interact: String = "",
	t_emerge: String = "",
	t_anticipatory_start: String = "",
	t_anticipatory_end: String = "",
	t_hit_or_miss: String = ""
) -> void:
	var now_ms = Time.get_ticks_msec()
	var time_since_last_T = (now_ms - last_t_time_ms) if last_t_time_ms >= 0 else -1.0
	var entry = {
		"timestamp": get_precise_timestamp(),
		"time_since_last_T": time_since_last_T,
		"interaction_type": interaction_type,
		"reward_amount": reward_amount,
		"success": success,
		"reaction_time": reaction_time,
		"t_arrived_at_npc": t_bush_interact,
		"t_npc_emerge": t_emerge,
		"t_anticipatory_start": t_anticipatory_start,
		"t_anticipatory_end": t_anticipatory_end,
		"t_hit_or_miss": t_hit_or_miss
	}
	log_entries.append(entry) 
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
	file.seek_end()
	if not header_written:
		file.store_line("timestamp,time_since_last_T,interaction_type,success,reaction_time,reward_amount,t_arrived_at_npc,t_npc_emerge,t_anticipatory_start,t_anticipatory_end,t_outcome_animation,t_hit_or_miss")
		header_written = true
	file.store_line("%s,%s,%s,%s,%.3f,%s,%s,%s,%s,%s,%s" % [
		entry.timestamp, entry.time_since_last_T, entry.interaction_type, entry.success, entry.reaction_time, entry.reward_amount,
		entry.t_arrived_at_npc, entry.t_npc_emerge, entry.t_anticipatory_start, entry.t_anticipatory_end,  entry.t_hit_or_miss
	])
	file.close()

func clear_log() -> void:
	log_entries.clear()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("T") && !first_t_recorded:
		first_t_recorded = true
		last_t_time_ms = Time.get_ticks_msec()
		record_interaction("Scanning Start Time", true, 0.0, 0.0)

func get_success_percentage() -> float:
	var real_interactions = log_entries.filter(func(e): return e.interaction_type != "Scanning Start Time")
	if real_interactions.is_empty():
		return 0.0
	var successes = real_interactions.filter(func(e): return e.success == true)
	return (float(successes.size()) / float(real_interactions.size())) * 100.0

static func get_precise_timestamp() -> String:
	var datetime = Time.get_datetime_dict_from_system()
	var unix_time = Time.get_unix_time_from_system()
	var ms = int(fmod(unix_time, 1.0) * 1000)
	return "%02d:%02d:%02d.%03d" % [datetime.hour, datetime.minute, datetime.second, ms]

func _write_final_summary() -> void:
	var successRate = get_success_percentage()
	var npcIndex = DataManager.npcIndex
	var finalReactionTime = DataManager.reactionTime

	var finalEarnings = 0.0
	var player = get_tree().get_first_node_in_group("player")
	if player:
		finalEarnings = player.score / 100.0

	var file
	if FileAccess.file_exists(log_path):
		file = FileAccess.open(log_path, FileAccess.READ_WRITE)
	else:
		file = FileAccess.open(log_path, FileAccess.WRITE)

	if file == null:
		push_error("GameplayLog: failed to open file for writing at " + log_path)
		return

	file.seek_end()
	file.store_line("")
	file.store_line("session_summary_timestamp,success_rate_percent,final_npc_index,final_reaction_time,final_earnings_dollars")
	file.store_line("%s,%.1f,%d,%.4f,%.2f" % [get_precise_timestamp(), successRate, npcIndex, finalReactionTime, finalEarnings])
	file.close()

	print("GameplayLog: session summary written -- success rate: %.1f%%, final index: %d, final reactionTime: %.4f, final earnings: $%.2f" % [successRate, npcIndex, finalReactionTime, finalEarnings])
