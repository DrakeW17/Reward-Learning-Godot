extends Node2D

# Helpful paths
@onready var betweenTimer = $BetweenTimer
@onready var instructions = $Instructions

# The list of reaction times
var times = []
# The reaction stopwatch
var currentTime = 0

# The amount of trials we want to do
const dataAmount = 10

func _ready() -> void:
	# Starts the timer to make the message disappear
	betweenTimer.start()
	
func _process(delta: float) -> void:
	# Only runs if the instructions are not visable
	if !instructions.visible:
		# Updates the stopwatch
		currentTime += delta
		# Checks if the player has given input
		if Input.is_action_just_pressed("jump"):
			# Adds the most recent time to our list of times
			times.push_back(currentTime)
			# Checks if we have more data to collect
			if times.size() < dataAmount:
				# Resets the stopwatch
				currentTime = 0
				# Makes the instructions visable again
				instructions.visible = true
				# Randomizes the time till the next trial
				betweenTimer.wait_time = randf_range(0.5, 3)
				# Starts counting down to the next trial
				betweenTimer.start()
			# If we have collected enough data
			else:
				# Calculates the average of the dataset
				var average = times.reduce(func(accum, number): return accum + number, 0) / times.size()
				# Finds a time that the player would get 66% of the time
				var time = (average - times.min()) * 0.33 + times.min()
				# Updates this in the DataManager, with compensation for player movement time
				DataManager.reactionTime = time + 1.0/3.0
				# Loads the player into the game
				get_tree().change_scene_to_file("res://main_scene.tscn")

# Initiates a trial
func _on_between_timer_timeout() -> void:
	instructions.visible = false
	
