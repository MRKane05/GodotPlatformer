extends AI_State
class_name AI_Spar

var next_shift = 0 #How long until we change what we're doing
var advance_on = true
var ai_pause = false

func update(_delta: float) -> void:
	next_shift -= _delta #Tick down our counter
	if next_shift <= 0:	#reset our ticker and make another seed
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var random = rng.randf()
		if rng.randf() < 0.25:
			ai_pause = true
		else:
			ai_pause = false
		
		if rng.randf() < 0.25:
			advance_on = false
		else:
			advance_on = true
		next_shift = rng.randf_range(1, 3) #Reset our ticker to something
	
	#Figure out what the facing direction for the player is
	var player_sign = sign(base_AI.Global.playerpos.x - base_AI.targetactor.position.x)
	var facing_dir = player_sign #face our player direction
	#Of course this means that AI can back off of ledges...
	if !advance_on:
		player_sign *= -1
	
	if ai_pause:
		player_sign = 0 #Have our AI pause for a bit
	
	#keep an eye out for having to change movement directions
	if base_AI.targetactor.is_at_edge():
		player_sign = 0	#don't walk over the edge of our platform
	
	if (player_sign != facing_dir): #we could back off the edge here
		if base_AI.targetactor.backed_to_edge():
			player_sign = 0	
	
	#if our player gets close enough lets take a swing at them
	if (abs(Global.playerpos.x - base_AI.targetactor.position.x) < 15) && !base_AI.targetactor.is_attacking: #This will need expanded
		base_AI.targetactor.change_action_state(base_AI.targetactor.strike_plain, false)
	#send driving command to move
	if !base_AI.targetactor.is_attacking:
		base_AI.targetactor.set_move_dir(player_sign, facing_dir)
	else:
		base_AI.targetactor.set_move_dir(0, facing_dir)	#Stop our player movement, keep our facing (this is going to glitch)
