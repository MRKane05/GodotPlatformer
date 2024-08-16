extends ActorState
class_name Actor_OnGround

export(String) var fall_anim_name = "fall"
export(String) var move_anim_name = "run"
export(String) var idle_anim_name = "idle"
export(String) var crouch_anim_name = "crouch"

var fall_frame_pause = 0.25

func enter(_msg := {}) -> bool:
	#base_actor.set_debug_header("On_Ground")
	return true
	
# Virtual function. Corresponds to the `_process()` callback.
func physics_update(_delta: float, _velocity: Vector2, _move_dir: float) -> Vector2:
	#base_actor.set_debug_header("PhysUpdate")
	if !base_actor.on_ground:
		fall_frame_pause -= _delta
		base_actor.set_animation(fall_anim_name)
		if base_actor.has_method("set_collision_jumping") && fall_frame_pause < 0:
			base_actor.set_collision_jumping(true)	#For when we're simply falling
	else:
		fall_frame_pause = 0.25
		#animation handling
		if abs(_velocity.x) > 0:
			#base_actor.set_debug_header("MOVING")
			base_actor.set_animation(move_anim_name)
		else:
			if base_actor.vertical_move_dir > base_actor.CROUCH_THRESHOLD:
				#base_actor.set_debug_header("CROUCHING")
				base_actor.set_animation(crouch_anim_name)
				base_actor.set_collision_crouched(true)
			else:
				#We need some way of knowing if we're holding down to crouch. It seems logical to handle that here
				#base_actor.set_debug_header("IDLEG")
				base_actor.set_animation(idle_anim_name)
				base_actor.set_collision_crouched(false)
		
	if base_actor.vertical_move_dir > base_actor.CROUCH_THRESHOLD:	#Don't move while crouching
		_velocity = calculatehorizontalmovement(_delta, Vector2(0, _velocity.y), base_actor.move_dir)
	else:
		#While we're on the ground we really only need to worry about movement and falling
		_velocity = calculatehorizontalmovement(_delta, _velocity, base_actor.move_dir)
	_velocity = handlefallfunctions(_delta, _velocity)	#Apply our gravity
	
	return _velocity


func exit(): #Don't allow a state change while we're dashing. An interrupt will be fine however
	base_actor.set_collision_crouched(false)
	return true
	
func interruptexit() -> bool: #If an interrupt happens (take damage, hit wall) is this action ok with handing over (as exit may have failed)
	base_actor.set_collision_crouched(false)
	return true
