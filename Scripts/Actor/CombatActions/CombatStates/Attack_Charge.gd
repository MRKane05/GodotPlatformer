extends CombatState
class_name Attack_Charge

export(float) var charge_speed = 50
export(float) var charge_duration = 1.5

var charge_time = 0

func enter(_msg := {}) -> bool:
	var is_animating = base_actor.set_animation(get_name())	#In theory we should use our node name...
	#print (is_animating)
	base_actor.is_attacking = true
	charge_time = 0
	#base_actor.attack_presses -=1	#Detriment our attack presses (although this will be changed to an attack queue or something)
	return true

func physics_update(_delta: float, _velocity: Vector2, _move_dir: float) -> Vector2:
	charge_time += _delta
	if charge_time > charge_duration:
		base_actor.change_action_state("Actor_OnGround", false)
	
	var dash_dir = base_actor.move_dir
	if dash_dir == 0:
		dash_dir = base_actor.facing_dir
	_velocity = calculatedashhorizontalmovement(_delta, _velocity, charge_speed, dash_dir)
	_velocity = handlefallfunctions(_delta, _velocity)	#Apply our gravity
	
	return _velocity

func exit(): #Don't allow a state change while we're dashing. An interrupt will be fine however
	print("finished charge")
	base_actor.is_attacking = false
	base_actor.clear_all_combat_strikers();
	return animation_cleared
	
func interruptexit() -> bool: #If an interrupt happens (take damage, hit wall) is this action ok with handing over (as exit may have failed)
	base_actor.is_attacking = false
	base_actor.clear_all_combat_strikers();
	return true
