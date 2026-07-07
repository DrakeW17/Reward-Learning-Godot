extends Node

var interactionAmount = 10

# The distribution of interaction types. Order: bad, neutral, good
const interactionTypeDistribution = [2, 3, 2]
var distributionSum = interactionTypeDistribution.reduce(func(accum, number): return accum + number, 0)

var interactionAmounts = [0, 0, 0]

var placedInteractions = []

func _ready() -> void:
	for i in range(2):
		interactionAmounts[i] = (interactionTypeDistribution[i] / distributionSum) * interactionAmount
		

func SetInteractionTypes() -> void:
	for i in range(placedInteractions):
		
