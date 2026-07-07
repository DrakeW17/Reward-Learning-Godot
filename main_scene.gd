extends Node2D

# The possible transition situations
const transitionSituations = [preload("res://Levels/test_scene.tscn"),preload("res://Levels/situation_1.tscn")]
# The width of one situation
const situationLength = 320

# The number of interaction situations to place
const interactionAmount = 10

# Sets up the levels
func _ready() -> void:
	for p in range(interactionAmount):
		# Loads in one interaction
		var interactionInstance = preload("res://Levels/NPC_situation.tscn").instantiate()
		interactionInstance.global_position.x = p * situationLength * 2
		add_child(interactionInstance)
		
		#Loads in one transition after this interaction
		var transitionInstance = transitionSituations[randi() % transitionSituations.size()].instantiate()
		transitionInstance.global_position.x = (p * 2 + 1) * situationLength
		add_child(transitionInstance)
		
