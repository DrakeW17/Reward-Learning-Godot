extends Node2D

# THIS IS WORK IN PROGRESS

# The possible situations
const situations = [preload("res://Levels/test_scene.tscn"),preload("res://Levels/situation_1.tscn")]
# The width of one situation
const situationLength = 640

# The number of situations to place
const situationAmount = 10

# The pool of situations
var situationPool = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Places the situations
	for p in range(situationAmount):
		# Refills the situation pool if all situations have been used
		if situationPool.size() == 0:
			situationPool = situations
		# Selects a random situation from the situation pool
		var situationID = randi() % situationPool.size()
		# Spawns the situation chosen
		var instance = situationPool[situationID].instantiate()
		instance.global_position.x = p * situationLength
		add_child(instance)
		# Removes the situation from the situation pool
		situationPool.remove_at(situationID)
		
