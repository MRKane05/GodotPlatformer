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

#When we take damage. This could be the birth of something amazing, or it could just be for when our player manages to chump the AI
func on_take_damage(damageAmount, knockback, attackstun, on_damage_function, hurt_type, instigator):
	pass

#We've been blocked by something (probably the player) so this call is passed through least there's a reaction
func on_get_blocked(instigator):
	pass

func do_trigger_strike_callback(body, strike_action: String):
	pass

#Tickers to help our AI

