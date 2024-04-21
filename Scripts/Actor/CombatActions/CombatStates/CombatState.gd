extends ActorState
class_name CombatState

#So I want something that's really freeform for this node, essentially it just stores an action,
#and a state by and which we'll call it
#export(String) var attack_name = "attack"	#Make the attack into the name of the node
export(int) var attack_chain_order = 0		#Where should this attack sit in a combo?
export(String) var next_combo_state = ""
export(bool) var combo_finish = false
export(bool) var only_ground = false
export(bool) var only_air = false
export(bool) var move_while_attacking = false
export(bool) var combat_float = false

#We'll have to figure out something for direction holding
var animation_cleared = false

func enter(_msg := {}) -> bool:
	base_actor.set_animation(get_name())	#In theory we should use our node name...
	base_actor.is_attacking = true
	return true

func physics_update(_delta: float, _velocity: Vector2, _move_dir: float) -> Vector2:
	if move_while_attacking:
		#While we're on the ground we really only need to worry about movement and falling
		_velocity = calculatehorizontalmovement(_delta, _velocity, base_actor.move_dir)
		_velocity = handlefallfunctions(_delta, _velocity)	#Apply our gravity
	else:
		if combat_float: #this begs to have yet more expansion done
			_velocity = Vector2(0,0)
		_velocity = Vector2(0,0)
	return _velocity

# Virtual function. Corresponds to the `_process()` callback.
func anim_finished(anim_name: String) -> void:
	if (anim_name == "attack"):
		animation_cleared = true
		if base_actor.attack_presses > 0 && next_combo_state != "": #We want to do a chain attack
			base_actor.change_action_state(next_combo_state, false)
		else:
			base_actor.change_action_state("Actor_OnGround", false)

func exit(): #Don't allow a state change while we're dashing. An interrupt will be fine however
	base_actor.is_attacking = false
	base_actor.clear_all_combat_strikers();
	return animation_cleared
	
func interruptexit() -> bool: #If an interrupt happens (take damage, hit wall) is this action ok with handing over (as exit may have failed)
	base_actor.is_attacking = false
	base_actor.clear_all_combat_strikers();
	return true
