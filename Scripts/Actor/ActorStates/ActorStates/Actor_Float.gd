extends ActorState
class_name Actor_Float

var cooldown = 0.5
var has_applied_float = false
var has_applied_fall_hold = false

func enter(_msg := {}) -> bool:
	base_actor.set_animation("float")
	has_applied_float = false
	has_applied_fall_hold = false
	cooldown = 0.5
	return true

func physics_update(_delta: float, _velocity: Vector2, _move_dir: float) -> Vector2:
	#if !base_actor.on_ground:	#Just in case we're knocked off a ledge
	#	base_actor.set_animation(fall_anim_name)
	#While we're on the ground we really only need to worry about movement and falling
	#_velocity = calculatehorizontalmovement(_delta, _velocity + Vector2(base_actor.current_knockback,0), base_actor.move_dir)
	if !has_applied_float:
		_velocity += Vector2(0, base_actor.LAUNCH_POWER)
		has_applied_float = true
	
	_velocity = calculatehorizontalmovement(_delta, _velocity + Vector2(base_actor.current_knockback,0), base_actor.move_dir)
	#So we've actually got to do a bit of funny busisness here at our apex and have a fall hold...
	if (abs(_velocity.y) < 5 && !has_applied_fall_hold):
		base_actor.fall_hold = 0.75
		has_applied_fall_hold = true
		
	_velocity = handlefallfunctions(_delta, _velocity)	#Apply our gravity
	cooldown -= _delta
	#We can free this actor from this state by having it touch the ground. Of course this'll need a recovery state, but for the moment...
	if base_actor.on_ground && cooldown < 0:
		base_actor.change_action_state("Actor_OnGround", false)
	return _velocity

