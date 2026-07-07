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

func Set() -> void:
	# Sets the correct sprite depending on the type
	sprites[type].visible = true

# When a player has come near enough to initiate the interaction
func _on_area_2d_body_entered(body: Node2D) -> void:
	# emerges if it has not already done so
	if not emergePlayed:
		animations.play("emerge")
		sprites[type].play("idle")
		emergePlayed = true

# When the player fails to interact
func _on_timer_timeout() -> void:
	sprites[type].play("no_interaction")

# When the interaction is finished
func _on_sprite_animation_finished() -> void:
	# Deletes the NPC
	queue_free()

# When the player interacts
func _on_interaction_body_entered(body: Node2D) -> void:
	# Stops the death timer
	deathTimer.stop()
	# Plays the interaction animation
	sprites[type].play("interaction")
	# Deletes the interaction area to prevent re-interaction
	$Interaction.queue_free()
	# Increases the player's score
	body.scoreIncrease(int(pow(5, power) * (type - 1)))
