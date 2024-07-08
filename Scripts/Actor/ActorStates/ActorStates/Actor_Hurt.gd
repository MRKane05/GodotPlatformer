extends ActorState
class_name Actor_Hurt

export(String) var fall_anim_name = "fall"
var animation_cleared = false

# Virtual function. Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> bool:
	#Can we be hurt twice?
	print("Actor in hurt state")
	base_actor.set_animation("hurt")
	return true

#Called when we've taken damage and need to play the necessary animation, which may lead into a stun
#also used as a reaction to being parried (at this stage)
# Virtual function. Corresponds to the `_process()` callback.
func physics_update(_delta: float, _velocity: Vector2, _move_dir: float) -> Vector2:
	#if !base_actor.on_ground:	#Just in case we're knocked off a ledge
	#	base_actor.set_animation(fall_anim_name)
	#While we're on the ground we really only need to worry about movement and falling
	#_velocity = calculatehorizontalmovement(_delta, _velocity + Vector2(base_actor.current_knockback,0), base_actor.move_dir)
	#PROBLEM: Our velocity on hurt might need to be put into a different state to handle being tossed aside
	_velocity = calculatehorizontalmovement(_delta, Vector2(base_actor.current_knockback,0), base_actor.move_dir)
	_velocity = handlefallfunctions(_delta, _velocity)	#Apply our gravity
	return _velocity
	
func exit() -> bool: #There's a possibility that we won't be able to let the player do what they want to do
	return animation_cleared
	
func anim_finished(anim_name: String) -> void:
	if (anim_name == "hurt"):
		animation_cleared = true
		#print("Animation cleared")
		base_actor.change_action_state("Actor_OnGround", false)
