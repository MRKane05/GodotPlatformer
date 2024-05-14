extends AI_State
class_name AI_Amble

func update(_delta: float) -> void:
	if base_AI.targetactor.seeplayer(): # && base_AI.see_player_state: #Leave the amble state if we see the player (or a target I guess)
		print("AI Seen Player")
		base_AI.change_action_state(base_AI.see_player_state, false)
	
	#keep an eye out for having to change movement directions
	if base_AI.targetactor.is_at_edge():
		base_AI.move_dir *= -1
		base_AI.facing_dir *= -1
		
	#send driving command to move
	base_AI.targetactor.set_move_dir(base_AI.move_dir, base_AI.facing_dir, 0)
