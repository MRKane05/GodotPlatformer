extends CombatState
class_name Attack_Slam

func physics_update(_delta: float, _velocity: Vector2, _move_dir: float) -> Vector2:
	_velocity = handleslamfunctions(_delta, _velocity)	#Apply our gravity
	return _velocity

func handleslamfunctions(delta, velocity) -> Vector2:
	#Implement gravity===========================================================
	#var relativegravity = lerp(MIN_GRAVITY, GRAVITY, abs(velocity.y)/GRAVITY)
	var relativegravity = base_actor.GRAVITY*2

	velocity.y += relativegravity*delta 
	
	#Clamp our fallspeed so that we don't keep accellerating because it's not fun
	var maxFallSpeed = base_actor.MAX_FALL_SPEED*2
	velocity.y = clamp(velocity.y, base_actor.JUMP_POWER, maxFallSpeed) #Axis are down positive. Giggity
	
	#if our actor gets grounded we've got to move to the next part of this attack\
	if base_actor.on_ground:
		animation_cleared = true #Necessary to release our combat state
		base_actor.change_action_state(next_combo_state, false)
			
	return velocity
