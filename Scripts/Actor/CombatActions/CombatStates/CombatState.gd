extends ActorState
class_name CombatState

#So I want something that's really freeform for this node, essentially it just stores an action,
#So I want something that's really freeform for this node, essentially it just stores an action,
#and a state by and which we'll call it
#export(String) var attack_name = "attack"	#Make the attack into the name of the node
export (String) var hurt_type = "hurt" #Just standard damage, with nothing special going on

export(int) var attack_chain_order = 0		#Where should this attack sit in a combo?
export(String) var next_combo_action = "a"	#What action we have to press to engage in this combo. This will help us dismiss actions for a new one (such as pressing up/down halfway through an attack)
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
	var is_animating = base_actor.set_animation(get_name())	#In theory we should use our node name...
	#print (is_animating)
	base_actor.is_attacking = true
	#base_actor.attack_presses -=1	#Detriment our attack presses (although this will be changed to an attack queue or something)
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
		var next_attack_action = base_actor.get_next_attack_action()
		#base_actor.controller is PlayerController && 
		if base_actor.attack_actions.size() > 0 && next_combo_state != "" && next_attack_action == next_combo_action: #We want to do a chain attack
			base_actor.deque_attack_action()	#Make sure we take one off the top
			base_actor.change_action_state(next_combo_state, false)
		#This logic only works for the player
		elif !base_actor.controller.button_released && next_combo_held_state != "": #The player has held the button
			#print("Attack held")
			base_actor.change_action_state(next_combo_held_state, false)
		else:
			#For whatever reason this combo has fallen through to the default.
			#Assume that this is the combo ending action
			if base_actor.attack_actions.size() > 0: #we need to continue our attack actions and send a trigger through
				pass
			base_actor.attack_presses = 0
			base_actor.clear_action_stack()	#Clear our stack as we've just finished a combo or action set
			base_actor.change_action_state("Actor_OnGround", false)

func exit(): #Don't allow a state change while we're dashing. An interrupt will be fine however
	base_actor.is_attacking = false
	base_actor.clear_all_combat_strikers();
	return animation_cleared
	
func interruptexit() -> bool: #If an interrupt happens (take damage, hit wall) is this action ok with handing over (as exit may have failed)
	base_actor.is_attacking = false
	base_actor.clear_all_combat_strikers();
	return true
