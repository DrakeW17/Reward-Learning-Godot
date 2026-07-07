extends Node2D

@onready var animations = $AnimationPlayer
var emergePlayed = false

@onready var sprites = [$Goblin, $Archer, $Angel]
@export var type = 0
@export var power = 0

@onready var deathTimer = $DeathTimer

func _ready() -> void:
	sprites[type].visible = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not emergePlayed:
		animations.play("emerge")
		emergePlayed = true


func _on_timer_timeout() -> void:
	sprites[type].play("no_interaction")


func _on_sprite_animation_finished() -> void:
	queue_free()


func _on_interaction_body_entered(body: Node2D) -> void:
	deathTimer.stop()
	sprites[type].play("interaction")
	$Interaction.queue_free()
	body.score += int(pow(5, power) * (type - 1))
