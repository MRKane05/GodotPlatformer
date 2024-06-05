extends ActorState
class_name CombatState

#So I want something that's really freeform for this node, essentially it just stores an action,
#and a state by and which we'll call it
#export(String) var attack_name = "attack"	#Make the attack into the name of the node
export(int) var attack_chain_order = 0		#Where should this attack sit in a combo?
export(String) var next_combo_state = ""	#Which attack comes after this one?
export(String) var next_combo_held_state = "" #If we hold the attack button what state will we go to? (Intended for use with float lifts and jumping to attack enemies in the air)
export(String) var on_function_call = ""	#If we're doing something special this is the function we call
export(float) var attack_damage = 5	#What's the expected damage of this attack?
export(float) var knockback_force = 20	#How big is our standard knockback force?
export(float) var attack_stun = 1 #How long will we apply the standard stun on hit?
#This'll need to have some "evolving" done to see what'll happen
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
	base_actor.attack_presses -=1	#Detriment our attack presses (although this will be changed to an attack queue or something)
	return true

func physics_update(_delta: float, _velocity: Vector2, _move_dir: float) -> Vector2:
	if move_while_attacking:
		#While we're on the ground we really only need to worry about movement and falling
		_velocity = calculatehorizontalmovement(_delta, _velocity, base_actor.move_dir)
		_velocity = handlefallfunctions(_delta, _velocity)	#Apply our gravity
	else:
		#Need to check and see if we're hitting something, and if so do the float...
		#if combat_float: #this begs to have yet more expansion done
		#_velocity = Vector2(0,0)
		_velocity = handlefallfunctions(_delta, _velocity)	#Apply our gravity
	return _velocity

# Virtual function. Corresponds to the `_process()` callback.
func anim_finished(anim_name: String) -> void:
	if (anim_name == "attack"):
		animation_cleared = true
		#This could be a good place to see if our player as kept the button depressed
		#Need a little more logic with the next step after this command...
		if base_actor.attack_actions.size() > 0 && next_combo_state != "": #We want to do a chain attack
			base_actor.change_action_state(next_combo_state, false)
		elif base_actor.controller is PlayerController && !base_actor.controller.button_released && next_combo_held_state != "": #The player has held the button
			base_actor.change_action_state(next_combo_held_state, false)
		else:
			#Assume that this is the combo ending action
			base_actor.attack_presses = 0
			base_actor.change_action_state("Actor_OnGround", false)

func exit(): #Don't allow a state change while we're dashing. An interrupt will be fine however
	base_actor.is_attacking = false
	base_actor.clear_all_combat_strikers();
	return animation_cleared
	
func interruptexit() -> bool: #If an interrupt happens (take damage, hit wall) is this action ok with handing over (as exit may have failed)
	base_actor.is_attacking = false
	base_actor.clear_all_combat_strikers();
	return true
