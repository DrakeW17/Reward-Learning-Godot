extends CharacterBody2D

# If the player can move or not
var canMove = true

# tracks whether forward key has been freshly pressed since movement was re-enabled
var inputPrimed = false 

#Stores if the player is actively attacking
var isAttacking = false

#tween variable for red flashing
var flash_tween: Tween

#The friction (acts as an involuntary deceleration)
var friction = 600
# The strength of gravity on the player
var gravity = 1000

# The acceleration of the player's movement
var acceleration = 550 + friction
# The maximum speed the player can achieve via standerd movement
var maxSpeed = 100
# The jump strength of the player
var jumpStrength = 250
# The player's inability to move while in the air (lower = more control) 
var airControl = 0.8

# Keeps track of the player's score
var score = 50

var rewardFlashTween: Tween
var isFlashingScore = false # NEW: suppresses _process() overwriting the flash text



# Helpful paths
@onready var scoreUI = $CanvasLayer/Score
@onready var scoreIncreaseParticles = $CanvasLayer/ScoreIncreaseParticles
@onready var animatedSprite = $AnimatedSprite2D
@onready var transition = $CanvasLayer/BlackTransition


func _ready() -> void:
	# Plays idle animation upon game start
	animatedSprite.play("idle")
	animatedSprite.animation_finished.connect(_on_animated_sprite_2d_animation_finished)
	create_tween().tween_property(transition, "modulate:a", 0, 1)
	
func _physics_process(delta: float) -> void:
	if canMove and not inputPrimed:
		if not Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
			inputPrimed = true # no keys held = safe to start sensing input again
	
	var rawDirection = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var movementDirection = rawDirection * int(canMove) * int(inputPrimed)
	
	if abs(velocity.x) < maxSpeed or sign(velocity.x) != sign(movementDirection):
		velocity.x += movementDirection * acceleration * delta * (1 - (int(!is_on_floor()) * airControl))
	
	if is_on_floor():
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		if velocity.y > 0:
			velocity.y = 0
		if Input.is_action_just_pressed("jump"):
			velocity.y -= jumpStrength
	else:
		velocity.y += gravity * delta
	
	if not isAttacking:
		if movementDirection > 0:
			animatedSprite.flip_h = false
			animatedSprite.play("walk")
		elif movementDirection < 0:
			animatedSprite.flip_h = true
			animatedSprite.play("walk")
		else:
			animatedSprite.play("idle")
	
	move_and_slide()

func play_attack() -> void:
	isAttacking = true
	animatedSprite.play("attack")

func _on_animated_sprite_2d_animation_finished() -> void:
	if animatedSprite.animation == "attack":
		isAttacking = false

func _process(delta: float) -> void:
	if not isFlashingScore:
		scoreUI.text = "Coins: " + str(score)

# Function for increasing the score
func scoreIncrease(amount: int) -> void:
	# Spawns UI particles
	if amount > 0:
		scoreIncreaseParticles.amount = amount * 5
	else:
		scoreIncreaseParticles.amount = 0
	scoreIncreaseParticles.emitting = true
	# Updates the player's score
	score += amount

func flash_red() -> void:
	if is_instance_valid(flash_tween):
		flash_tween.kill()
	animatedSprite.modulate = Color(1, 0, 0)
	flash_tween = create_tween()
	flash_tween.tween_property(animatedSprite, "modulate", Color(1, 1, 1), 0.5)

func transitionToScene(path: String):
	var tween = create_tween()
	await tween.tween_property(transition, "modulate:a", 1, 1).finished
	get_tree().change_scene_to_file(path)

func show_reward_popup(amount: int) -> void:
	if is_instance_valid(rewardFlashTween):
		rewardFlashTween.kill()

	var flashText: String
	var colorHex: String

	if amount > 0:
		colorHex = "#00FF00" # green
		flashText = "[center][color=%s]+%d[/color][/center]" % [colorHex, amount]
	elif amount < 0:
		colorHex = "#FF0000" # red
		flashText = "[center][color=%s]%d[/color][/center]" % [colorHex, amount]
	else:
		colorHex = "#FFFFFF"
		flashText = "[center][color=%s]+0[/color][/center]" % colorHex

	isFlashingScore = true
	scoreUI.text = flashText # if bbcode_enabled is true, this parses the tags directly

	await get_tree().create_timer(1.5).timeout

	isFlashingScore = false
