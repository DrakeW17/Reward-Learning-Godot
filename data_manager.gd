extends Node

var interactionAmount = 10

# The distribution of interaction types. Order: bad, neutral, good
const interactionTypeDistribution = [2, 3, 2]
var distributionSum = interactionTypeDistribution.reduce(func(accum, number): return accum + number, 0)

var interactionAmounts = [0, 0, 0]

var placedInteractions = []

var interactionTypesAvailable = []

func SetInteractionTypes() -> void:
	for i in range(2):
			interactionAmounts[i] = int((float(interactionTypeDistribution[i]) / distributionSum) * interactionAmount)
			for s in range(interactionAmounts[i]):
				interactionTypesAvailable.append(i)
	for i in range(placedInteractions.size()):
		var typeID = randi_range(0, interactionTypesAvailable.size() - 1)
		print(placedInteractions[i].NPC.type)
		placedInteractions[i].NPC.type = interactionTypesAvailable[typeID]
		placedInteractions[i].NPC.Set()
		#interactionTypesAvailable.remove_at(typeID)
