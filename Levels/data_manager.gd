extends Node

var reactionTime: float = 1.0
var calibrating = false
var calibrationTrialCount = 0
const STEP_UP = 0.033
const STEP_DOWN = 0.017
const MIN_WINDOW = 0.2
const MAX_WINDOW = 2.0
var windowHistory: Array = []

var interactionAmount = 81
const interactionTypeDistribution = [2, 1, 2]
var distributionSum = interactionTypeDistribution.reduce(func(accum, number): return accum + number, 0)

var npcLabels = ['sm_goblin', 'sm_goblin', 'md_goblin', 'sm_goblin', 'lg_goblin', 'sm_goblin', 'sm_angel', 'sm_goblin', 'md_angel', 'sm_goblin', 'lg_angel', 'sm_goblin', 'sm_archer', 'sm_goblin', 'md_archer', 'sm_goblin', 'lg_archer', 'md_goblin', 'md_goblin', 'lg_goblin', 'md_goblin', 'sm_angel', 'md_goblin', 'md_angel', 'md_goblin', 'lg_angel', 'md_goblin', 'sm_archer', 'md_goblin', 'md_archer', 'md_goblin', 'lg_archer', 'lg_goblin', 'lg_goblin', 'sm_angel', 'lg_goblin', 'md_angel', 'lg_goblin', 'lg_angel', 'lg_goblin', 'sm_archer', 'lg_goblin', 'md_archer', 'lg_goblin', 'lg_archer', 'sm_angel', 'sm_angel', 'md_angel', 'sm_angel', 'lg_angel', 'sm_angel', 'sm_archer', 'sm_angel', 'md_archer', 'sm_angel', 'lg_archer', 'md_angel', 'md_angel', 'lg_angel', 'md_angel', 'sm_archer', 'md_angel', 'md_archer', 'md_angel', 'lg_archer', 'lg_angel', 'lg_angel', 'sm_archer', 'lg_angel', 'md_archer', 'lg_angel', 'lg_archer', 'sm_archer', 'sm_archer', 'md_archer', 'sm_archer', 'lg_archer', 'md_archer', 'md_archer', 'lg_archer', 'lg_archer']

var placedInteractions = []
var interactionTypesAvailable = []

var npcIndex = 0

func _ready() -> void:
	print("DataManager _ready, loading progress...")


func set_starting_index(index: int) -> void:
	npcIndex = index
	print("Starting NPC index set to: ", npcIndex)

func _next_npc_label() -> String:
	var label = npcLabels[npcIndex]
	npcIndex += 1
	
	if npcIndex >= npcLabels.size():
		npcIndex = 0
	
	return label

func SetInteractionTypes() -> void:
	for i in range(placedInteractions.size()):
		placedInteractions[i].NPC.Set(_next_npc_label())

func start_calibration() -> void:
	print("calibration started")
	calibrating = true
	calibrationTrialCount = 0
	windowHistory.clear()
	reactionTime = 1.0

func register_calibration_result(success: bool) -> void:
	if not calibrating:
		return
	calibrationTrialCount += 1
	if success:
		reactionTime = max(MIN_WINDOW, reactionTime - STEP_DOWN)
		print("success")
	else:
		reactionTime = min(MAX_WINDOW, reactionTime + STEP_UP)
		print("fail")
	if calibrationTrialCount > 5:
		windowHistory.append(reactionTime)

func finish_calibration() -> void:
	if not windowHistory.is_empty():
		var sum = 0.0
		for w in windowHistory:
			sum += w
		reactionTime = sum / windowHistory.size()
	calibrating = false
	print("Calibration finished. Final reactionTime: ", reactionTime)
	get_tree().change_scene_to_file("res://MainGame.tscn")
