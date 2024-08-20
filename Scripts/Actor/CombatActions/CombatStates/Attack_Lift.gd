extends ActorState
class_name Attack_Lift

var cooldown = 0.5
var has_applied_fall_hold = false


#Special attack state that causes the player to jump up after something that should have been launched into the air
func enter(_msg := {}) -> bool:
	#base_actor.set_animation(get_name())	#In theory we should use our node name...
	base_actor.set_animation("jump")
	base_actor.velocity += Vector2(0, base_actor.LAUNCH_POWER)
	has_applied_fall_hold = false
	cooldown = 0.5
	return true

func physics_update(_delta: float, _velocity: Vector2, _move_dir: float) -> Vector2:

	#While we're on the ground we really only need to worry about movement and falling
	_velocity = calculatehorizontalmovement(_delta, _velocity, base_actor.move_dir)
	_velocity = handlefallfunctions(_delta, _velocity)	#Apply our gravity
	
	if (abs(_velocity.y) < 5 && !has_applied_fall_hold):
		base_actor.fall_hold = 0.75
		has_applied_fall_hold = true
	
	cooldown -= _delta
	if base_actor.on_ground && cooldown <= 0: #we need to transition back to our ground state. Check here for walls too
		base_actor.change_action_state("Actor_OnGround", false)
	
	return _velocity

func exit(): #Don't allow a state change while we're dashing. An interrupt will be fine however
	return true
	
func interruptexit() -> bool: #If an interrupt happens (take damage, hit wall) is this action ok with handing over (as exit may have failed)
	return true
