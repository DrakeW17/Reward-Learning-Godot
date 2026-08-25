extends Node2D
# The possible transition situations
const transitionSituations = [preload("res://Levels/test_scene.tscn"), preload("res://Levels/situation_1.tscn")]
# The width of one situation
const situationLength = 120
func _ready() -> void:
	DataManager.placedInteractions.clear()
	for p in range(DataManager.interactionAmount):
		var interactionInstance = preload("res://Levels/NPC_situation.tscn").instantiate()
		interactionInstance.global_position.x = p * situationLength * 2
		add_child(interactionInstance)
		DataManager.placedInteractions.append(interactionInstance)
		var transitionInstance = transitionSituations[randi() % transitionSituations.size()].instantiate()
		transitionInstance.global_position.x = (p * 2 + 1) * situationLength
		add_child(transitionInstance)
	_set_calibration_labels()
	DataManager.start_precalibration()
	PauseManager.start_auto_pause_timer() # NEW: 8-minute auto-pause starts as soon as calibration begins

func _set_calibration_labels() -> void:
	for interaction in DataManager.placedInteractions:
		interaction.NPC.Set(DataManager._calibration_npc_label())
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("end_calibration") and DataManager.calibrating:
		DataManager.finish_precalibration()
