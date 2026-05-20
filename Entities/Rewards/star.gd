extends Node2D

# The points given upon collection
@export var pointAmount = 1

# Preloading the despawn particles
const DESPAWN = preload("res://Effects/reward_despawn.tscn")

# This is multiplied by the point amount to get the final scale of the start
var scaleFactor = 0.3


func _ready() -> void:
	#Sets the scale of the star
	scale = scaleFactor * Vector2(pointAmount, pointAmount)

#Triggered when collected
func _on_area_2d_body_entered(body: Node2D) -> void:
	#Increases the player's point amount
	body.scoreIncrease(pointAmount)
	
	#Spwans despawn particles
	var despawnP = DESPAWN.instantiate()
	despawnP.position = position
	despawnP.get_node("Particles").amount = pointAmount * 5
	get_parent().add_child(despawnP)
	
	# Deletes itself
	queue_free()
