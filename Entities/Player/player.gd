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
var maxSpeed = 150
# The jump strength of the player
var jumpStrength = 250
# The player's inability to move while in the air (lower = more control) 
var airControl = 0.8

# Keeps track of the player's score
var score = 50

# Helpful paths
@onready var scoreUI = $CanvasLayer/Score
@onready var scoreIncreaseParticles = $CanvasLayer/ScoreIncreaseParticles
@onready var animatedSprite = $AnimatedSprite2D


func _ready() -> void:
	# Plays idle animation upon game start
	animatedSprite.play("idle")
	animatedSprite.animation_finished.connect(_on_animated_sprite_2d_animation_finished)
	
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
	# Updates the score UI
	scoreUI.text = "Coins: " + str(score)

# Function for increasing the score
func scoreIncrease(amount: int) -> void:
	# Spawns UI particles
	scoreIncreaseParticles.amount = abs(amount) * 5
	scoreIncreaseParticles.emitting = true
	# Updates the player's score
	score += amount
	

func flash_red() -> void:
	if is_instance_valid(flash_tween):
		flash_tween.kill() # stop any flash already in progress
	
	animatedSprite.modulate = Color(1, 0, 0) # solid red
	flash_tween = create_tween()
	flash_tween.tween_property(animatedSprite, "modulate", Color(1, 1, 1), 0.5) # fade back to normal
