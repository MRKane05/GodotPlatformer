extends ActorState
class_name Actor_OnGround

func enter(_msg := {}) -> bool:
	
	return true
	
# Virtual function. Corresponds to the `_process()` callback.
func physics_update(_delta: float, _velocity: Vector2, _move_dir: float) -> Vector2:
	if !base_actor.on_ground:
		base_actor.set_animation("fall")
	else:
		#animation handling
		if abs(_velocity.x) > 0:
			base_actor.set_animation("run")
		else:
			base_actor.set_animation("idle")
	
	#While we're on the ground we really only need to worry about movement and falling
	_velocity = calculatehorizontalmovement(_delta, _velocity, base_actor.move_dir)
	_velocity = handlefallfunctions(_delta, _velocity)	#Apply our gravity
	return _velocity
