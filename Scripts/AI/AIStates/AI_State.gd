extends Node
class_name AI_State

var base_AI = null

# Virtual function. Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> bool:
	return true

# Virtual function. Called by the state machine before changing the active state. Use this function
# to clean up the state.
func exit() -> bool: #There's a possibility that we won't be able to let the player do what they want to do
	return true

# Virtual function. Called by the state machine as an interrupt before changing the active state. Use this function
# to clean up the state.
func interruptexit() -> bool: #If an interrupt happens (take damage, hit wall) is this action ok with handing over (as exit may have failed)
	return true

# Virtual function. Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	pass

# Virtual function. Corresponds to the `_process()` callback.
func anim_finished(anim_name: String) -> void:
	pass

#Tickers to help our AI

