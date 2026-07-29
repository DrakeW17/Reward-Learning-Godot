extends Node

# The reaction speed of the player (with some compensation for the player's movement speed)
var reactionTime = 2
#I changed reactionTime to a set amount for testing so I don't have to do the test every time

# The amount of NPC interactions we want to generate
var interactionAmount = 10

# The distribution of interaction types. Order: bad, neutral, good.
# Idealy, this should add up to interactionAmount
const interactionTypeDistribution = [2, 1, 2]
# A sum of interactionTypeDistribution
var distributionSum = interactionTypeDistribution.reduce(func(accum, number): return accum + number, 0)

# The ordered list of NPCs to spawn, as size_type labels
#var npcLabels = ['sm_goblin', 'sm_goblin', 'md_goblin', 'sm_goblin', 'lg_goblin', 'sm_goblin', 'sm_angel', 'sm_goblin', 'md_angel', 'sm_goblin', 'lg_angel', 'sm_goblin', 'sm_archer', 'sm_goblin', 'md_archer', 'sm_goblin', 'lg_archer', 'md_goblin', 'md_goblin', 'lg_goblin']
var npcLabels = ['sm_goblin', 'md_goblin', 'lg_goblin', 'sm_angel', 'md_angel', 'lg_angel', 'sm_archer', 'md_archer', 'lg_archer', 'md_goblin', 'md_angel', 'md_archer', 'sm_goblin', 'sm_goblin']
# A list of references to the NPC Situations
var placedInteractions = []

# The available interaction types to pick from
var interactionTypesAvailable = []

# Sets the interaction types
func SetInteractionTypes() -> void:
	# Sets interactionTypesAvailable
	for i in range(placedInteractions.size()):
		placedInteractions[i].NPC.Set(npcLabels[i])
