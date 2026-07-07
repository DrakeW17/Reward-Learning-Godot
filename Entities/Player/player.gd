extends CharacterBody2D

#T he friction (acts as an involuntary deceleration)
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
var score = 0

# Helpful paths
@onready var scoreUI = $CanvasLayer/Score
@onready var scoreIncreaseParticles = $CanvasLayer/ScoreIncreaseParticles
@onready var animatedSprite = $AnimatedSprite2D


func _ready() -> void:
	# Plays idle animation upon game start
	animatedSprite.play("idle")
	
func _physics_process(delta: float) -> void:
	# Gets input from the player to determine movement direction
	var movementDirection = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	# Accelerates the player if they have not it the max speed
	if abs(velocity.x) < maxSpeed or sign(velocity.x) != sign(movementDirection):
		velocity.x += movementDirection * acceleration * delta * (1 - (int(!is_on_floor()) * airControl))
	
	if is_on_floor():
		# Applies friction if the player
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
		# Removes all downward velocity
		if velocity.y > 0:
			velocity.y = 0
		
		# Allows the player to jump
		if Input.is_action_just_pressed("jump"):
			velocity.y -= jumpStrength
	else:
		# Applies gravity if not on the floor
		velocity.y += gravity * delta
	
	if movementDirection > 0:
		animatedSprite.flip_h = false
		animatedSprite.play("walk")
	elif movementDirection < 0:
		animatedSprite.flip_h = true
		animatedSprite.play("walk")
	else:
		animatedSprite.play("idle")
	# Updates the position
	move_and_slide()

func _process(delta: float) -> void:
	# Updates the score UI
	scoreUI.text = "Score: " + str(score)

# Function for increasing the score
func scoreIncrease(amount: int) -> void:
	# Spawns UI particles
	scoreIncreaseParticles.amount = amount * 5
	scoreIncreaseParticles.emitting = true
	# Updates the player's score
	score += amount
