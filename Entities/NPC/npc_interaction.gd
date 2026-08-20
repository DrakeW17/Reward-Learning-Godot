extends Node2D

signal player_interacted

# Reference to the animation player
@onready var animations = $AnimationPlayer

#Variables for logging
const typeNames = ["goblin", "archer", "angel"]
var flashStartTime := 0.0
var reactionTime
var potentialReward = 0
var isFlashing = false
var awaitingReaction = false # true from emerge start through end of flash phase — covers the whole button mashing window


@export var interactionDisabled = false # if true, this NPC can't be succeeded OR false-started -- pure demo/passive NPC

# Stores each sprite's original position, before any scale-compensation is applied
var spriteBasePositions = []

# Has the emerge animation played
var emergePlayed = false

# References to the sprites possible for the npc
@onready var sprites = [$Goblin, $Archer, $Angel]

enum Sprites {goblin, archer, angel}

enum Outcome {LOSS, NEUTRAL, GAIN}

const outcomeNames = ["loss", "neutral", "gain"]

# The type of the npc
var type = 0
# The power of the npc
var power = 0

# Reference to the death timer
@onready var deathTimer = $DeathTimer
# Reference to the interaction start timer
@onready var interactionTimer = $StartInteractionTimer
# Reference to the 
@onready var anticipatoryDelayTimer = $AnticipatoryDelayTimer

# Overriding the death timer. -1 = no override, -2 = infinite time
@export var deathTimerOverride = -1

# Saves the interacting body
var Player

# Stores how the player interacted
var interacted = 0

const typeIndices = {"goblin": 0, "archer": 1, "angel": 2}
const sizeScales = {"sm": 0.75, "md": 1.0, "lg": 1.4}
const sizePowers = {"sm": 0, "md": 1, "lg": 2}

func _ready() -> void:
	# Records the original position of each sprite before any adjustments
	for sprite in sprites:
		spriteBasePositions.append(sprite.position)

func Set(label: String) -> void:
	var parts = label.split("_")
	var sizeKey = parts[0]
	var typeKey = parts[1]

	type = typeIndices[typeKey]
	power = sizePowers[sizeKey]

	var scaleAmount = sizeScales[sizeKey]
	var sprite = sprites[type]
	
	
	# Reset before applying scaling
	sprite.scale = Vector2(-1, 1)
	sprite.position = spriteBasePositions[type]
	
	
	# Potential reward: what's at stake if the player succeeds, calculated once and fixed
	potentialReward = int(pow(5, power) * (type - 1))
	
	#Angel is larger so scale down if angel
	if (typeKey == 'angel'):
		# Apply scale
		sprite.scale = Vector2(-(scaleAmount*0.8), (scaleAmount*0.8))
	else:
		# Apply scale
		sprite.scale = Vector2(-scaleAmount, scaleAmount)
		
	# Compensate for scaling around center pivot
	if (sizeKey == 'sm'):
		var frameTexture = sprite.sprite_frames.get_frame_texture(sprite.animation, 0)
		var spriteHeight = frameTexture.get_height()
		var offset = (spriteHeight * (1.0 - scaleAmount)) / 2.0
		sprite.position.y += offset
	elif (sizeKey == 'md'):
		var frameTexture = sprite.sprite_frames.get_frame_texture(sprite.animation, 0)
		var spriteHeight = frameTexture.get_height()
		var offset = ((spriteHeight * (1.0 - scaleAmount)) / 2.0) + 3.5
		sprite.position.y += offset
		
	sprite.visible = true


# When a player has come near enough to initiate the interaction
func _on_area_2d_body_entered(body: Node2D) -> void:
	# Saves the interacting body
	Player = body
	# Prevents the player from moving
	Player.canMove = false
	# Starts the interaction timer
	interactionTimer.start(randf_range(0, 2))

# When the player fails to interact
func _on_death_timer_timeout() -> void:
	isFlashing = false
	awaitingReaction = false
	sprites[type].play("no_interaction")
	if (type == 0):
		await get_tree().create_timer(0.3).timeout
		Player.flash_red()
	reactionTime = (Time.get_ticks_msec() / 1000.0) - flashStartTime
	if not DataManager.calibrating:
		GamePlayLog.record_interaction(outcomeNames[type], false, 0, potentialReward)
	DataManager.register_calibration_result(false)
	PauseManager.notify_emerge_finished()
	interacted = -1
	letPlayerMove()

# When the interaction is finished
func _on_sprite_animation_finished() -> void:
	# Updates the player's score
	Player.scoreIncrease(int(pow(5, power) * (float(1.0/2.0) * abs(type - 1) * (type - 1 + interacted))))
	# Deletes the NPC
	queue_free()

# Lets the player move again
func letPlayerMove() -> void:
	Player.canMove = true
	Player.inputPrimed = false

# When the player interacts
func _unhandled_input(event: InputEvent) -> void:
	if interactionDisabled:
		return
	if isFlashing and interacted == 0 and event.is_action_pressed("move_right"):
		_on_success()
		emit_signal("player_interacted")
	elif awaitingReaction:
		_on_false_start()

func _on_success() -> void:
	isFlashing = false
	awaitingReaction = false
	deathTimer.stop()
	interacted = 1
	letPlayerMove()

	if (type == Sprites.goblin):
		Player.play_attack()

	if (type == Sprites.angel):
		var flyUpOffset = Vector2(0, -40)
		var flyTween = create_tween()
		flyTween.tween_property(sprites[type], "position", spriteBasePositions[type] + flyUpOffset, 0.5)
		await flyTween.finished

	sprites[type].play("interaction")
	reactionTime = (Time.get_ticks_msec() / 1000.0) - flashStartTime
	
	if not DataManager.calibrating:
		GamePlayLog.record_interaction(outcomeNames[type], true, reactionTime, potentialReward)
	DataManager.register_calibration_result(true)


	if is_instance_valid($Interaction):
		$Interaction.queue_free()

func _on_start_interaction_timer_timeout() -> void:
	# Emerges if it has not already done so
	if not emergePlayed:
		PauseManager.notify_emerge_started()
		animations.play("emerge")
		sprites[type].play("idle")
		emergePlayed = true
		awaitingReaction = true # false-start window begins here

#If player hits too early
func _on_false_start() -> void:
	awaitingReaction = false
	isFlashing = false
	deathTimer.stop()
	interacted = -1
	sprites[type].play("no_interaction")
	if (type == 0):
		await get_tree().create_timer(0.3).timeout
		Player.flash_red()
	reactionTime = -1.0 # or 0, however you want to flag "pressed too early" in the log
	if not DataManager.calibrating:
		GamePlayLog.record_interaction(outcomeNames[type], false, reactionTime, potentialReward)
	DataManager.register_calibration_result(false)
	PauseManager.notify_emerge_finished()
	letPlayerMove()


# When the emerge animation finishes, wait a random amount between 2 and 2.5s before flashing
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "emerge":
		anticipatoryDelayTimer.start(randf_range(2.0, 2.5))

# Starts the flash/interaction window after the anticipatory delay
func _on_anticipatory_delay_timer_timeout() -> void:
	if deathTimerOverride == -1:
		deathTimer.start(DataManager.reactionTime)
	elif deathTimerOverride >= 0:
		print(deathTimerOverride)
		deathTimer.start(0.1)
	sprites[type].play("flash")
	flashStartTime = Time.get_ticks_msec() / 1000.0
	PauseManager.notify_emerge_finished()
	isFlashing = true
