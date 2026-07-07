extends Node

var interactionAmount = 5

# The distribution of interaction types. Order: bad, neutral, good
const interactionTypeDistribution = [2, 2, 1]
var distributionSum = interactionTypeDistribution.reduce(func(accum, number): return accum + number, 0)

var interactionAmounts = [0, 0, 0]

var placedInteractions = []

var interactionTypesAvailable = []

func SetInteractionTypes() -> void:
	for i in range(3):
			interactionAmounts[i] = ceil((float(interactionTypeDistribution[i]) / distributionSum) * interactionAmount)
			for s in range(interactionAmounts[i]):
				interactionTypesAvailable.append(i)
	for i in range(placedInteractions.size()):
		var typeID = randi_range(0, interactionTypesAvailable.size() - 1)
		print(interactionTypesAvailable.size())
		placedInteractions[i].NPC.type = interactionTypesAvailable[typeID]
		placedInteractions[i].NPC.Set()
		interactionTypesAvailable.remove_at(typeID)
