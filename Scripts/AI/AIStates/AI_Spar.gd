extends AI_State
class_name AI_Spar

var next_shift = 0 #How long until we change what we're doing
var advance_on = true
var ai_pause = false
var next_strike_time = 0

#So tightening these vallues will make the AI more aggressive in it's behaviour
export(float) var pause_chance = 0.25
export(float) var advance_chance = 0.75
export(Vector2) var pause_duration = Vector2(1,2) 
export(Vector2) var advance_duration = Vector2(1,3)
export(Vector2) var backup_duration = Vector2(1,3)

var waiting_open_strike = false #if true Are we waiting for one of our attacks to return that we can attack
var collecting_attacks = false #Are we waiting to see what attacks will be avaliable
export(Vector2) var attack_found_cooldown_range = Vector2(0.25, 0.5)
var attack_found_cooldown = 1
var callback_attacks = [] #If we've done a tick to see what attacks we can make they'll be listed here

func enter(_msg := {}) -> bool:
	waiting_open_strike = true
	base_AI.targetactor.set_strike_triggers(waiting_open_strike) #Set our AI so that it's looking to make a hit
	return true

func update(_delta: float) -> void:
	next_strike_time -= _delta
	next_shift -= _delta #Tick down our counter
	if next_shift <= 0:	#reset our ticker and make another seed
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var random = rng.randf()
		if rng.randf() < pause_chance:
			ai_pause = true
			next_shift = rng.randf_range(pause_duration.x, pause_duration.y) #Reset our ticker to something
		else:
			ai_pause = false
		
		if rng.randf() < advance_chance:
			advance_on = true
			next_shift = rng.randf_range(advance_duration.x, advance_duration.y) #Reset our ticker to something
		else:
			advance_on = false
			next_shift = rng.randf_range(backup_duration.x, backup_duration.y) #Reset our ticker to something
		#next_shift = rng.randf_range(1, 3) #Reset our ticker to something
	
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
	
	#So for our attacks we kind of need an "attack on" for seeing if we can make attacks and then
	#Something to carry out the attacks selected from the ones that were found
	if collecting_attacks:
		attack_found_cooldown -= _delta
	
	if collecting_attacks && attack_found_cooldown <=0: #We're free to do an attack
		if callback_attacks.size() > 0: #We do have attacks!
			var rng = RandomNumberGenerator.new()
			rng.randomize()
			var n = rng.randi_range(0,callback_attacks.size()-1)
			var selected_attack = callback_attacks[n]
			#Turn our systems off before changing state
			collecting_attacks = false
			waiting_open_strike = false
			#base_AI.targetactor.set_strike_triggers(waiting_open_strike) #Set our AI so that it's looking to make a hit
			#And after all of that set our state so that we can do an attack!
			print("Setting attack state")
			base_AI.targetactor.change_action_state(selected_attack, false)
	#if our player gets close enough lets take a swing at them. We should include a little more logic here for finesse
	#if next_strike_time <= 0 && abs(Global.playerpos.x - base_AI.targetactor.position.x) < 15 && abs(Global.playerpos.y - base_AI.targetactor.position.y) < 7 && !base_AI.targetactor.is_attacking: #This will need expanded
	#	base_AI.targetactor.change_action_state(base_AI.targetactor.strike_plain, false)
	#	var rng = RandomNumberGenerator.new()
	#	rng.randomize()
	#	next_strike_time = rng.randf_range(1,3)
	#send driving command to move
	if !base_AI.targetactor.is_attacking:
		base_AI.targetactor.set_move_dir(player_sign, facing_dir, 0)
	else:
		base_AI.targetactor.set_move_dir(0, facing_dir, 0)	#Stop our player movement, keep our facing (this is going to glitch)

#We've had a callback from one of our attack states
func do_trigger_strike_callback(body, strike_action: String):
	print("AI_Spar got attack callback: " + strike_action)
	if !collecting_attacks:
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		attack_found_cooldown = rng.randf_range(1,3)
		collecting_attacks = true
		
	if !callback_attacks.has(strike_action):
		callback_attacks.append(strike_action)
