extends ActorState
class_name Actor_Die

var animation_cleared = false

# Virtual function. Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> bool:
	#Can we be hurt twice?
	#print("Actor in hurt state")
	base_actor.set_animation("die")
	#Really we should disable all our colliders too...
	return true
	
func physics_update(_delta: float, _velocity: Vector2, _move_dir: float) -> Vector2:
	#Freeze our movement
	_velocity = Vector2(0,0)
	return _velocity
	
func exit() -> bool: #There's a possibility that we won't be able to let the player do what they want to do
	return animation_cleared
	
func anim_finished(anim_name: String) -> void:
	if (anim_name == "die"):
		animation_cleared = true
		queue_free()
		#print("Animation cleared")
		#base_actor.change_action_state("Actor_OnGround", false)
		#Of course I don't actually have a setup for the player...
