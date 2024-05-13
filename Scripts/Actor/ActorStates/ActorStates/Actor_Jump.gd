extends ActorState
class_name Actor_Jump
# Virtual function. Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> bool:
	if !base_actor.on_ground && !base_actor.jump_free && base_actor.on_wall == 0 && base_actor.cyote_time <=0 && base_actor.jumps_left <= 0:
		return false	#we can't fesiably enter this state
	#Assume we're good and set our velocity
	base_actor.velocity = dojumplogic(base_actor.velocity)
	return true

func dojumplogic(velocity: Vector2) -> Vector2:
	if base_actor.on_wall != 0: #Simplify our logic by handling our wall jump first
		#facing_dir = on_wall
		velocity.x = base_actor.on_wall*base_actor.WALLJUMP_HSP
		velocity.y = base_actor.WALLJUMP_POWER				
		base_actor.walljump_time = base_actor.WALLJUMP_LOCKTIME
		base_actor.set_animation("jump")
	elif (base_actor.on_ground || base_actor.cyote_time > 0):	#include our cyote time and ignore the bug that could happen by jumping then jumping...
		velocity.y = base_actor.JUMP_POWER
		base_actor.on_ground = false
		base_actor.set_animation("jump")
	elif base_actor.jumps_left > 0:
		base_actor.jumps_left = base_actor.jumps_left -1
		velocity.y = base_actor.JUMP_POWER
		base_actor.on_ground = false
		base_actor.set_animation("jump")
	return velocity
	
# Standard move function
func physics_update(_delta: float, _velocity: Vector2, _move_dir: float) -> Vector2:

	#While we're on the ground we really only need to worry about movement and falling
	_velocity = calculatehorizontalmovement(_delta, _velocity, base_actor.move_dir)
	_velocity = handlefallfunctions(_delta, _velocity)	#Apply our gravity
	
	#Give us a variable jump
	if _velocity.y < 0 && !Input.is_action_pressed("ui_accept") && !base_actor.on_ground:
		_velocity.y = max(_velocity.y, base_actor.JUMP_POWER/2.5)	
	
	if base_actor.on_ground: #we need to transition back to our ground state. Check here for walls too
		base_actor.change_action_state("Actor_OnGround", false)
	
	return _velocity
