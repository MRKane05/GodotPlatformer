extends AI_State
class_name AI_PingPong

#This AI just runs back and forth between where it can. There's not much higher function going on here
func update(_delta: float) -> void:
	
	#if base_AI.targetactor.seeplayer(): # && base_AI.see_player_state: #Leave the amble state if we see the player (or a target I guess)
	#	base_AI.change_action_state(base_AI.see_player_state, false)
	
	#keep an eye out for having to change movement directions
	if base_AI.targetactor.is_at_edge():
		base_AI.move_dir *= -1
		base_AI.facing_dir *= -1
		
	#send driving command to move
	base_AI.targetactor.set_move_dir(base_AI.move_dir, base_AI.facing_dir, 0)

func on_get_blocked(instigator):
	#Swap our direction
	base_AI.move_dir *= -1
	base_AI.facing_dir *= -1

#Notify our AI of our player (if it is our player)
func on_take_damage(damageAmount, knockback, attackstun, on_damage_function, hurt_type, instigator):
	if instigator is Actor_Player:
		#What I might do is add something here to see if we change direction or not
		#base_AI.change_action_state(base_AI.see_player_state, false)
		pass
