extends Node

var interactionAmount = 5

# The distribution of interaction types. Order: bad, neutral, good.
# Idealy, this should add up to interactionAmount
const interactionTypeDistribution = [2, 2, 1]
# A sum of interactionTypeDistribution
var distributionSum = interactionTypeDistribution.reduce(func(accum, number): return accum + number, 0)

# The amount of interactions of each type
var interactionAmounts = [0, 0, 0]

# A list of references to the NPC Situations
var placedInteractions = []

# The available interaction types to pick from
var interactionTypesAvailable = []

# Sets the interaction types
func SetInteractionTypes() -> void:
	# Appends 
	for i in range(3):
			#interactionAmounts[i] = ceil((float(interactionTypeDistribution[i]) / distributionSum) * interactionAmount)
			for s in range(ceil((float(interactionTypeDistribution[i]) / distributionSum) * interactionAmount)):
				interactionTypesAvailable.append(i)
	
	for i in range(placedInteractions.size()):
		var typeID = randi_range(0, interactionTypesAvailable.size() - 1)
		print(interactionTypesAvailable.size())
		placedInteractions[i].NPC.type = interactionTypesAvailable[typeID]
		placedInteractions[i].NPC.Set()
		interactionTypesAvailable.remove_at(typeID)
