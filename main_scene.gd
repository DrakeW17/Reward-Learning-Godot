extends Node2D

# THIS IS WORK IN PROGRESS

# The possible inbetween situations
const transitionSituations = [preload("res://Levels/test_scene.tscn"),preload("res://Levels/situation_1.tscn")]
# The width of one situation
const situationLength = 320

# The number of situations to place
const interactionAmount = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for p in range(interactionAmount):
		var interactionInstance = preload("res://Levels/NPC_situation.tscn").instantiate()
		interactionInstance.global_position.x = p * situationLength * 2
		add_child(interactionInstance)
		
		var transitionInstance = transitionSituations[randi() % transitionSituations.size()].instantiate()
		transitionInstance.global_position.x = (p * 2 + 1) * situationLength
		add_child(transitionInstance)
		
