extends Node2D

# Reference to the animation player
@onready var animations = $AnimationPlayer
# Has the emerge animation played
var emergePlayed = false

# References to the sprites possible for the npc
@onready var sprites = [$Goblin, $Archer, $Angel]
# The type of the npc
@export var type = 0
# The power of the npc
@export var power = 0

# Reference to the death timer
@onready var deathTimer = $DeathTimer
# Reference to the interaction start timer
@onready var interactionTimer = $StartInteractionTimer

# Saves the interacting body
var Player

# Stores how the player interacted
var interacted = 0

func Set() -> void:
	# Sets the correct sprite depending on the type
	sprites[type].scale.x = -1
	sprites[type].visible = true
	interactionTimer.wait_time = randf_range(0, 2)

# When a player has come near enough to initiate the interaction
func _on_area_2d_body_entered(body: Node2D) -> void:
	# Saves the interacting body
	Player = body
	# Prevents the player from moving
	Player.canMove = false
	# Starts the interaction timer
	interactionTimer.start()

# When the player fails to interact
func _on_timer_timeout() -> void:
	sprites[type].play("no_interaction")
	interacted = -1

# When the interaction is finished
func _on_sprite_animation_finished() -> void:
	# Updates the player's score
	Player.scoreIncrease(int(pow(5, power) * (float(1.0/2.0) * abs(type - 1) * (type - 1 + interacted))))
	# Deletes the NPC
	queue_free()

# Lets the player move again
func letPlayerMove():
	Player.canMove = true

# When the player interacts
func _on_interaction_body_entered(body: Node2D) -> void:
	if !bool(interacted):
		# Saves the interacting body
		Player = body
		# Stops the death timer
		deathTimer.stop()
		interacted = 1
		# Plays the interaction animation
		sprites[type].play("interaction")
		# Deletes the interaction area to prevent re-interaction
		$Interaction.queue_free()
		# Increases the player's score


func _on_start_interaction_timer_timeout() -> void:
	# Emerges if it has not already done so
	if not emergePlayed:
		deathTimer.wait_time = DataManager.reactionTime
		animations.play("emerge")
		sprites[type].play("idle")
		emergePlayed = true
