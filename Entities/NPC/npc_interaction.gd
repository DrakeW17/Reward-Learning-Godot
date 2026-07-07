extends Node2D

@onready var Animations = $AnimationPlayer
var AnimationPlayed = false

@onready var Sprites = [$Goblin, $Archer, $Angel]
@export var Type = 0
@export var Power = 0

@onready var DeathTimer = $DeathTimer

var Player

func _ready() -> void:
	Sprites[Type].visible = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not AnimationPlayed:
		Animations.play("emerge")
		Player = body
		AnimationPlayed = true


func _on_timer_timeout() -> void:
	Sprites[Type].play("no_interaction")


func _on_sprite_animation_finished() -> void:
	queue_free()


func _on_interaction_body_entered(body: Node2D) -> void:
	DeathTimer.stop()
	Sprites[Type].play("interaction")
	$Interaction.queue_free()
	body.score += int(pow(5, Power) * (Type - 1))
