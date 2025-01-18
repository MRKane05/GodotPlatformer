extends AI_State
class_name AI_Spar

var next_shift = 0 #How long until we change what we're doing
var advance_on = true
var ai_pause = false
var next_strike_time = 0

#A few little internals for keeping track of things
var player_sign = 1
var facing_dir =1
var float_sign = 1 #This one will be adjusted using a lerp to give "reflexes"
var temp_sign = 1

#So tightening these vallues will make the AI more aggressive in it's behaviour
export(float) var pause_chance = 0.25
export(float) var advance_chance = 0.75
export(Vector2) var pause_duration = Vector2(1,2) 
export(Vector2) var advance_duration = Vector2(1,3)
export(Vector2) var backup_duration = Vector2(1,3)
export(float) var combo_likelihood = 0.8 #How likely are we to do each consecutive attack in a combo. This will tie into difficulty
export(Vector2) var blockhold_duration = Vector2(0.75,2)
export(Vector2) var health_blocking_odds = Vector2(0.4, 0.1) #What are the odds of us blocking, based off of our health and how close we are to dying?
export(Vector2) var parry_followup_cooldown = Vector2(0.1, 0.3) #What are the odds of us blocking, based off of our health and how close we are to dying?
var blockhold = 1
var parry_cooldown = 0.3

var waiting_open_strike = false #if true Are we waiting for one of our attacks to return that we can attack
var doing_strike = false
export(Vector2) var attack_found_cooldown_range = Vector2(0.25, 0.5)
export(Vector2) var reblock_cooldown_range = Vector2(0.25, 0.5)	#After we've blocked how long until we try to block again? Setting this above the attack found can make our AI more aggressive
var attack_found_cooldown = 1
var reblock_cooldown = 1
var triggered_attack = ""

var lerp_playerpos = Vector2(0,0) #So what I want to do is have something that'll simulate "reflexes", and doing a lerp on the player position should do that
export(float) var playerpos_lerp_rate = 0.5 #How quickly our player pos will be lerped to. Of course 1 means it's always on position

var AI_Substate = "NONE"	#Things have got complicated. We need a substate machine...
var state_time = 0			#How long have we been in a particular state? Will be used by some of the strike callbacks to add delays

func enter(_msg := {}) -> bool:
	state_time = 0	#Make sure this is zero to begin with
	#base_AI.targetactor.set_debug_header("NONE")
	waiting_open_strike = true	
	base_AI.targetactor.set_strike_triggers(waiting_open_strike) #Set our AI so that it's looking to make a hit
	lerp_playerpos = base_AI.Global.playerpos	#Set our position entering this state
	var rng = RandomNumberGenerator.new()
	rng.randomize()	
	attack_found_cooldown = rng.randf_range(attack_found_cooldown_range.x, attack_found_cooldown_range.y) #Reset our ticker to something
	reblock_cooldown = rng.randf_range(reblock_cooldown_range.x, reblock_cooldown_range.y) #Reset our ticker to something
	return true

func update(_delta: float) -> void:
	#Essentially we've got a couple of substates in this one, which is bad processing, but it's not too terrible at this stage
	
	next_strike_time -= _delta
	next_shift -= _delta #Tick down our counter
	blockhold -= _delta
	reblock_cooldown -= _delta
	parry_cooldown -= _delta
	state_time += _delta	#Increase this ticker for our combat system to use as a watcher
	
	#Little sub-state to handle how much this character moves back/forward. This is just a random system
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
	
	#Facing directions======================================================================================
	#Figure out what the facing direction for the player is, with the lerp system emulating "reflexes"
	#This really doesn't work for reactions, as the AI can sometimes run past where it assumes the player to be and thus faces the other direction...
	#lerp_playerpos = lerp_playerpos.linear_interpolate(base_AI.Global.playerpos, _delta * playerpos_lerp_rate)
	lerp_playerpos = base_AI.Global.playerpos
	
	temp_sign = sign(lerp_playerpos.x - base_AI.targetactor.position.x)
	float_sign = lerp(float_sign, temp_sign, _delta*playerpos_lerp_rate) #THIS works well for enemy reactions
	
	if !base_AI.targetactor.is_attacking: #Don't update while we're attacking so that we won't magically flip sides
		player_sign = sign(float_sign)
		facing_dir = player_sign #face our player direction
		
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
	
	#Quick blocking handler================================================================================
	#So I'm not sure what our blocking details would look like, because we've got to anticipate the player
	#attacking us, somehow...
	if !base_AI.targetactor.is_attacking && AI_Substate == "NONE" && reblock_cooldown < 0:
		if abs(Global.playerpos.x-base_AI.targetactor.position.x) < 30: #Don't worry if we're not close enough
			#We need to see if we're in a state that we can block from
			if base_AI.targetactor.action_state.name == "Actor_OnGround":
				if Global.Player:
					if Global.Player.is_attacking:	#So in theory there's a tiny window before we're hit...
						#Calculate the odds that we'll actually block
						var block_chance = lerp(health_blocking_odds.x, health_blocking_odds.y, base_AI.targetactor.health/base_AI.targetactor.base_health)
						var rng = RandomNumberGenerator.new()
						rng.randomize()	
						#Have some random that becomes higher the more we get hurt as a thing of self-preservation
						if base_AI.targetactor.actor_states.has("Actor_Block") && rng.randf() < block_chance:
							
							rng.randomize()							
							reblock_cooldown = rng.randf_range(reblock_cooldown_range.x, reblock_cooldown_range.y) #Reset our ticker to something
							
							AI_Substate = "BLOCK"
							base_AI.targetactor.change_action_state("Actor_Block", false)
							parry_cooldown = rng.randf_range(parry_followup_cooldown.x, parry_followup_cooldown.y)
							#var rng = RandomNumberGenerator.new()
							rng.randomize()	
							blockhold = rng.randf_range(blockhold_duration.x, blockhold_duration.y) #Random block hold duration
		
	if AI_Substate == "BLOCK":
		#base_AI.targetactor.set_debug_header("BLOCK")
		#Check and see if we might have just parried the player
		if Global.Player.action_state.name == "Actor_Parried" && parry_cooldown <=0:
			#Should have something in here to decide if we're vindictive...
			#For the moment
			base_AI.targetactor.change_action_state(base_AI.targetactor.strike_plain, false) #Do an attack after we got a parry
			AI_Substate = "NONE"
			#base_AI.targetactor.set_debug_header("NONE")
			state_time = 0
		if blockhold <= 0 || abs(Global.playerpos.x-base_AI.targetactor.position.x) > 30:
			base_AI.targetactor.change_action_state("Actor_OnGround", false)
			AI_Substate = "NONE"
			state_time = 0
			#base_AI.targetactor.set_debug_header("NONE")
	#Strike codeblock==========================================================================================
	#So for our attacks we kind of need an "attack on" for seeing if we can make attacks and then
	#Something to carry out the attacks selected from the ones that were found
	if !base_AI.targetactor.is_attacking && AI_Substate == "NONE":
		#base_AI.targetactor.set_debug_header("ATTACK")
		if doing_strike:
			attack_found_cooldown -= _delta
		
		if attack_found_cooldown <=0 && doing_strike: #We're free to do an attack
			#Turn our systems off before changing state
			doing_strike = false
			waiting_open_strike = false
			base_AI.targetactor.set_strike_triggers(waiting_open_strike) #Set our AI so that it's looking to make a hit
			#Do the strike we've had assigned
			base_AI.targetactor.change_action_state(triggered_attack, false)
	
	#Apply actions============================================================================================
	if !base_AI.targetactor.is_attacking:
		base_AI.targetactor.set_move_dir(player_sign, facing_dir, 0)
	else:
		base_AI.targetactor.set_move_dir(0, facing_dir, 0)	#Stop our player movement, keep our facing (this is going to glitch)

#We've had a callback from one of our attack states
func do_trigger_strike_callback(body, strike_action: String):
	#We should enact this attack (maybe with a delay)
	if !doing_strike && body is Actor_Player:
		triggered_attack = strike_action
		doing_strike = true
		
		var rng = RandomNumberGenerator.new()
		rng.randomize()	
		attack_found_cooldown = rng.randf_range(attack_found_cooldown_range.x, attack_found_cooldown_range.y) #Reset our ticker to something

#Ideally this is called when we've finished our attack animation
func anim_finished(anim_name: String) -> void:
	state_time = 0 #reset our ticker counter
	var combo_string = base_AI.targetactor.state_combo_next(triggered_attack)
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var random = rng.randf()
	
	if combo_string != "" && combo_string != null && random < combo_likelihood && temp_sign == facing_dir:	#We'll do more checks for this, but for now lets combo!
		triggered_attack = combo_string
		base_AI.targetactor.change_action_state(triggered_attack, false)
	else:
		#Here's a good point to see if there's another combo position in our current attack, and we need to decide if we should run it, or setup for it
		triggered_attack = ""
		doing_strike = false
		#Open up our strike states to see about attacking again
		waiting_open_strike = true	
		base_AI.targetactor.set_strike_triggers(waiting_open_strike) #Set our AI so that it's looking to make a hit

func exit() -> bool: #There's a possibility that we won't be able to let the player do what they want to do
	doing_strike = false
	waiting_open_strike = false
	base_AI.targetactor.set_strike_triggers(waiting_open_strike) #Set our AI so that it's looking to make a hit
	return true


func interruptexit() -> bool: #If an interrupt happens (take damage, hit wall) is this action ok with handing over (as exit may have failed)
	doing_strike = false
	waiting_open_strike = false
	base_AI.targetactor.set_strike_triggers(waiting_open_strike) #Set our AI so that it's looking to make a hit
	return true
