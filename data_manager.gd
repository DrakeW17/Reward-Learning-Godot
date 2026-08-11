extends Node

# The reaction speed of the player (with some compensation for the player's movement speed)
var reactionTime: float = 1.0 # already exists, staircase will update this live

var calibrating = false
var calibrationTrialCount = 0
const STEP_UP = 0.033                  # miss -> window grows (easier), 66% weight
const STEP_DOWN = 0.017                # hit -> window shrinks (harder), 34% weight
const MIN_WINDOW = 0.2					#flashing window
const MAX_WINDOW = 2.0
var windowHistory: Array = []

# The amount of NPC interactions we want to generate
var interactionAmount = 81

# The distribution of interaction types. Order: bad, neutral, good.
# Idealy, this should add up to interactionAmount
const interactionTypeDistribution = [2, 1, 2]
# A sum of interactionTypeDistribution
var distributionSum = interactionTypeDistribution.reduce(func(accum, number): return accum + number, 0)

# The ordered list of NPCs to spawn, as size_type labels
var npcLabels = ['sm_goblin', 'sm_goblin', 'md_goblin', 'sm_goblin', 'lg_goblin', 'sm_goblin', 'sm_angel', 'sm_goblin', 'md_angel', 'sm_goblin', 'lg_angel', 'sm_goblin', 'sm_archer', 'sm_goblin', 'md_archer', 'sm_goblin', 'lg_archer', 'md_goblin', 'md_goblin', 'lg_goblin', 'md_goblin', 'sm_angel', 'md_goblin', 'md_angel', 'md_goblin', 'lg_angel', 'md_goblin', 'sm_archer', 'md_goblin', 'md_archer', 'md_goblin', 'lg_archer', 'lg_goblin', 'lg_goblin', 'sm_angel', 'lg_goblin', 'md_angel', 'lg_goblin', 'lg_angel', 'lg_goblin', 'sm_archer', 'lg_goblin', 'md_archer', 'lg_goblin', 'lg_archer', 'sm_angel', 'sm_angel', 'md_angel', 'sm_angel', 'lg_angel', 'sm_angel', 'sm_archer', 'sm_angel', 'md_archer', 'sm_angel', 'lg_archer', 'md_angel', 'md_angel', 'lg_angel', 'md_angel', 'sm_archer', 'md_angel', 'md_archer', 'md_angel', 'lg_archer', 'lg_angel', 'lg_angel', 'sm_archer', 'lg_angel', 'md_archer', 'lg_angel', 'lg_archer', 'sm_archer', 'sm_archer', 'md_archer', 'sm_archer', 'lg_archer', 'md_archer', 'md_archer', 'lg_archer', 'lg_archer']
#var npcLabels = [ 'sm_goblin', 'md_goblin', 'lg_goblin','sm_angel', 'md_angel', 'lg_angel', 'sm_archer', 'md_archer', 'lg_archer', 'md_goblin', 'md_angel', 'md_archer', 'sm_goblin', 'sm_goblin']


# A list of references to the NPC Situations
var placedInteractions = []

# The available interaction types to pick from
var interactionTypesAvailable = []

# Sets the interaction types
func SetInteractionTypes() -> void:
	# Sets interactionTypesAvailable
	for i in range(placedInteractions.size()):
		placedInteractions[i].NPC.Set(npcLabels[i])


func start_calibration() -> void:
	print("calibration started")
	calibrating = true
	calibrationTrialCount = 0
	windowHistory.clear()
	reactionTime = 1.0 # starting guess

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

	# Start recording history once there's been a reasonable number of trials to converge
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
	get_tree().change_scene_to_file("res://MainGame.tscn") # swap to your real main scene path
