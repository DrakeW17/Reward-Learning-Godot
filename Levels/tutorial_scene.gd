extends Node2D

const TextSpeed = 0.05

@onready var transitionPath = "res://Levels/StartMenu.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$FirstGoblin.Set("sm_goblin")
	$GoblinInteract.Set("md_goblin")
	$AngelInteract.Set("lg_angel")
	$ArcherInteract.Set("md_archer")
	var tween = create_tween()
	tween.tween_property($MovementInstructions, "visible_characters", $MovementInstructions.text.length(), TextSpeed * $MovementInstructions.text.length())

func _on_detection_body_entered(body: Node2D) -> void:
	var tween = create_tween()
	tween.tween_property($InteractInstructions, "visible_characters", $InteractInstructions.text.length(), TextSpeed * $InteractInstructions.text.length())

func _on_first_goblin_death_timer_timeout() -> void:
	await get_tree().create_timer(1.5).timeout
	var tween = create_tween()
	tween.tween_property($CoinLossComment, "visible_characters", $CoinLossComment.text.length(), TextSpeed * $CoinLossComment.text.length())

func _on_goblin_interact_player_interacted() -> void:
	await get_tree().create_timer(1.5).timeout
	$InteractInstructions.visible_characters = 0
	$InteractInstructions.text = "You interacted with the goblin before it could steal your coins!"
	var tween = create_tween()
	tween.tween_property($InteractInstructions, "visible_characters", $InteractInstructions.text.length(), TextSpeed * $InteractInstructions.text.length())

func _on_angel_detection_body_entered(body: Node2D) -> void:
	var tween = create_tween()
	tween.tween_property($AngelInstructions, "visible_characters", $AngelInstructions.text.length(), TextSpeed * $AngelInstructions.text.length())


func _on_archer_detection_body_entered(body: Node2D) -> void:
	var tween = create_tween()
	tween.tween_property($ArcherInstructions, "visible_characters", $ArcherInstructions.text.length(), TextSpeed * $ArcherInstructions.text.length())


func _on_tutorial_end_body_entered(body: Node2D) -> void:
	$Player.canMove = false
	$Player.transitionToScene(transitionPath)
