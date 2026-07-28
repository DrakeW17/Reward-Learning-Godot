extends Node

# The reaction speed of the player (with some compensation for the player's movement speed)
var reactionTime = 1
#I changed reactionTime to a set amount for testing so I don't have to do the test every time

# The amount of NPC interactions we want to generate
var interactionAmount = 10

# The distribution of interaction types. Order: bad, neutral, good.
# Idealy, this should add up to interactionAmount
const interactionTypeDistribution = [2, 1, 2]
# A sum of interactionTypeDistribution
var distributionSum = interactionTypeDistribution.reduce(func(accum, number): return accum + number, 0)

# A list of references to the NPC Situations
var placedInteractions = []

# The available interaction types to pick from
var interactionTypesAvailable = []

# Sets the interaction types
func SetInteractionTypes() -> void:
	# Sets interactionTypesAvailable
	for i in range(3):
			for s in range(ceil((float(interactionTypeDistribution[i]) / distributionSum) * interactionAmount)):
				interactionTypesAvailable.append(i)
	
	# Distributes the available interaction types over the placed interactions
	for i in range(placedInteractions.size()):
		var typeID = randi_range(0, interactionTypesAvailable.size() - 1)
		placedInteractions[i].NPC.type = interactionTypesAvailable[typeID]
		placedInteractions[i].NPC.Set()
		interactionTypesAvailable.remove_at(typeID)
