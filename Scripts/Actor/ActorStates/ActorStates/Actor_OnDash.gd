extends ActorState
class_name Actor_OnDash
# Virtual function. Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> bool:
	if base_actor.redash_time > 0 || base_actor.dash_dir != 0:
		return false	#we can't fesiably enter this state
	
	#Setup our Dash logic
	base_actor.dashes_left -= 1	#decrease our dash counter to keep with form
	base_actor.dash_time = base_actor.DASH_DURATION
	base_actor.dash_dir = base_actor.facing_dir
	if base_actor.on_wall != 0:
		base_actor.dash_dir = base_actor.on_wall
		base_actor.facing_dir = base_actor.dash_dir
	#setdashcollisions(true)
	if base_actor.on_ground:
		base_actor.dash_hold = true
		base_actor.set_animation("slide")
	else:
		base_actor.set_animation("airdash")
	base_actor.setdashcollisions(true)
	return true

func physics_update(_delta: float, _velocity: Vector2, _move_dir: float) -> Vector2:
	#While we're on the ground we really only need to worry about movement and falling
	_velocity = calculatedashmovement(_delta, _velocity, base_actor.move_dir)
	
	return _velocity

func calculatedashmovement(delta: float, velocity: Vector2, move_dir: float) -> Vector2:
	velocity.x = base_actor.MAX_SPEED_DASH * base_actor.dash_dir
	velocity.y = 0
	
	if base_actor.dash_dir!= 0:
		base_actor.facing_dir = base_actor.dash_dir	#Make this so that the user can't have the pawn "dash backwards"
	if !base_actor.on_ground && base_actor.dash_time <= 0: #Seeing as we're not on the ground lets transition to our default
		base_actor.change_action_state("Actor_OnGround", false)
	return velocity

# Virtual function. Corresponds to the `_process()` callback.
func anim_finished(anim_name: String) -> void:
	if (anim_name == "slide"):
		base_actor.change_action_state("Actor_OnGround", false)

# Virtual function. Called by the state machine before changing the active state. Use this function
# to clean up the state.
func exit(): #Don't allow a state change while we're dashing. An interrupt will be fine however
	base_actor.setdashcollisions(false)
	return base_actor.dash_time <= 0
	
func interruptexit() -> bool: #If an interrupt happens (take damage, hit wall) is this action ok with handing over (as exit may have failed)
	base_actor.setdashcollisions(false)
	return true
