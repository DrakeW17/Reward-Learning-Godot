extends Node

var reactionTime: float = 1.0
var calibrating = false
var calibrationTrialCount = 0
const STEP_UP = 0.033
const STEP_DOWN = 0.017
var currentScale = 0.15
var isPrecalibrating = false
var isMainGameTracking = false
var startingBalanceCents = 4000 # default $40.00

const MIN_WINDOW = 0.2
const MAX_WINDOW = 2.0
var windowHistory: Array = []

var interactionAmount = 81
const interactionTypeDistribution = [2, 1, 2]
var distributionSum = interactionTypeDistribution.reduce(func(accum, number): return accum + number, 0)

var npcLabels = ['sm_goblin', 'sm_goblin', 'md_goblin', 'sm_goblin', 'lg_goblin', 'sm_goblin', 'sm_angel', 'sm_goblin', 'md_angel', 'sm_goblin', 'lg_angel', 'sm_goblin', 'sm_archer', 'sm_goblin', 'md_archer', 'sm_goblin', 'lg_archer', 'md_goblin', 'md_goblin', 'lg_goblin', 'md_goblin', 'sm_angel', 'md_goblin', 'md_angel', 'md_goblin', 'lg_angel', 'md_goblin', 'sm_archer', 'md_goblin', 'md_archer', 'md_goblin', 'lg_archer', 'lg_goblin', 'lg_goblin', 'sm_angel', 'lg_goblin', 'md_angel', 'lg_goblin', 'lg_angel', 'lg_goblin', 'sm_archer', 'lg_goblin', 'md_archer', 'lg_goblin', 'lg_archer', 'sm_angel', 'sm_angel', 'md_angel', 'sm_angel', 'lg_angel', 'sm_angel', 'sm_archer', 'sm_angel', 'md_archer', 'sm_angel', 'lg_archer', 'md_angel', 'md_angel', 'lg_angel', 'md_angel', 'sm_archer', 'md_angel', 'md_archer', 'md_angel', 'lg_archer', 'lg_angel', 'lg_angel', 'sm_archer', 'lg_angel', 'md_archer', 'lg_angel', 'lg_archer', 'sm_archer', 'sm_archer', 'md_archer', 'sm_archer', 'lg_archer', 'md_archer', 'md_archer', 'lg_archer', 'lg_archer']

var placedInteractions = []
var interactionTypesAvailable = []

# Ratio that determines the 66% convergence target -- never change this ratio itself
const STEP_RATIO_UP = 0.66
const STEP_RATIO_DOWN = 0.34

# Pre-scan calibration: starts coarse, decays toward a fine floor
var precalStartScale = 0.15
var precalMinScale = 0.01
var precalDecayRate = 0.92

# Main game: flat, small, fixed
const MAIN_GAME_SCALE = 0.01

# Random throwaway label for calibration -- never touches npcIndex/npcLabels
func _calibration_npc_label() -> String:
	var sizes = ["sm", "md", "lg"]
	var types = ["goblin", "angel", "archer"]
	return sizes[randi() % sizes.size()] + "_" + types[randi() % types.size()]

# --- Pre-scan calibration: decaying step size, converges toward 66% ---
func start_precalibration() -> void:
	calibrating = true
	isPrecalibrating = true
	isMainGameTracking = false
	calibrationTrialCount = 0
	windowHistory.clear()
	currentScale = precalStartScale
	reactionTime = 0.7

var npcIndex = 0



func set_starting_index(index: int) -> void:
	npcIndex = index
	print("Starting NPC index set to: ", npcIndex)

func _next_npc_label() -> String:
	var label = npcLabels[npcIndex]
	npcIndex += 1
	
	if npcIndex >= npcLabels.size():
		npcIndex = 0
	
	return label

func advance_npc_index() -> void:
	npcIndex += 1
	if npcIndex >= npcLabels.size():
		npcIndex = 0

func SetInteractionTypes() -> void:
	for i in range(placedInteractions.size()):
		placedInteractions[i].NPC.Set(_next_npc_label())

func start_calibration() -> void:
	calibrating = true
	calibrationTrialCount = 0
	windowHistory.clear()
	reactionTime = 1.0

func register_calibration_result(success: bool) -> void:
	if not calibrating:
		return

	calibrationTrialCount += 1

	if isPrecalibrating:
		currentScale = max(precalMinScale, currentScale * precalDecayRate)

	var stepUp = STEP_RATIO_UP * currentScale
	var stepDown = STEP_RATIO_DOWN * currentScale

	if success:
		reactionTime = max(MIN_WINDOW, reactionTime - stepDown)
	else:
		reactionTime = min(MAX_WINDOW, reactionTime + stepUp)

	if isPrecalibrating and calibrationTrialCount > 5:
		windowHistory.append(reactionTime)

		
# --- Main game: flat, small fixed step, continues from calibrated reactionTime ---
func start_main_game_tracking() -> void:
	print("Main game tracking started from reactionTime: ", reactionTime)
	calibrating = true
	isPrecalibrating = false
	isMainGameTracking = true
	calibrationTrialCount = 0
	windowHistory.clear()
	currentScale = MAIN_GAME_SCALE

func finish_precalibration() -> void:
	if not windowHistory.is_empty():
		var sum = 0.0
		for w in windowHistory:
			sum += w
		reactionTime = sum / windowHistory.size()
	calibrating = false
	isPrecalibrating = false
	print("Pre-scan calibration finished. Final reactionTime: ", reactionTime)
	get_tree().change_scene_to_file("res://Levels/StartMenu.tscn")
	
func finish_calibration() -> void:
	if not windowHistory.is_empty():
		var sum = 0.0
		for w in windowHistory:
			sum += w
		reactionTime = sum / windowHistory.size()
	calibrating = false
	get_tree().change_scene_to_file("res://MainGame.tscn")
