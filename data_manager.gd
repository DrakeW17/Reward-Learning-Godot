extends Node

var interactionAmount = 10

# The distribution of interaction types. Order: bad, neutral, good
const interactionTypeDistribution = [2, 3, 2]
var distributionSum = interactionTypeDistribution.reduce(func(accum, number): return accum + number, 0)

var interactionAmounts = [0, 0, 0]

var placedInteractions = []

var interactionTypesAvailable = []

func _ready() -> void:
	for i in range(2):
			interactionAmounts[i] = int((float(interactionTypeDistribution[i]) / distributionSum) * interactionAmount)
			for s in range(interactionAmounts[i]):
				interactionTypesAvailable.append(i)
		

func SetInteractionTypes() -> void:

	for i in range(placedInteractions.size()):
		print(placedInteractions[i].get_script())

		var typeIDPicked = randi() % interactionTypesAvailable.size()
		placedInteractions[i].type
