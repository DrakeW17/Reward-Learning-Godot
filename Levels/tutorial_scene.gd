extends Node2D

const TextSpeed = 0.05

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$FirstGoblin.Set("sm_goblin")
	$GoblinInteract.Set("md_goblin")
	$AngelInteract.Set("lg_angel")
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
	$InteractInstructions.text = "That goblin couldn't steal your coins!"
	var tween = create_tween()
	tween.tween_property($InteractInstructions, "visible_characters", $InteractInstructions.text.length(), TextSpeed * $InteractInstructions.text.length())

func _on_angel_detection_body_entered(body: Node2D) -> void:
	var tween = create_tween()
	tween.tween_property($AngelInstructions, "visible_characters", $AngelInstructions.text.length(), TextSpeed * $AngelInstructions.text.length())
