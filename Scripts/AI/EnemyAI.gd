extends ActorController
class_name EnemyAI

export var initial_state := NodePath()
export(String) var see_player_state = "AI_Spar" #What state do we go into when we first see out player?

# The current active state. At the start of the game, we get the `initial_state`.
onready var action_state: AI_State = get_node(initial_state)
onready var Global = get_node("/root/Global") #Collect and assign our globals for referencing

var ai_states = {} # Dictionary of different actions we can do
export(Vector2) var viewlimit = Vector2(50, 100)

func _ready():
	._ready() #remember to call our super!
	for child in get_children():
		if child is AI_State: #Check if this is an actor state class
			child.base_AI = self
			ai_states[child.name] = child	#Add our action to our dictionary
	
	action_state.enter()

func _process(delta):
	if action_state:
		action_state.update(delta)
		

#This promises to become more complicated
func change_action_state(new_state_name: String, reset_if_same: bool):
	if (ai_states.has(new_state_name)):
		if !reset_if_same && action_state.name.to_lower() == new_state_name.to_lower():
			return	#don't change if we're calling through the same state again, and not doing a re-call
		var new_actor_state = ai_states[new_state_name]
		
		if action_state.exit():
			if new_actor_state.enter():
				action_state = new_actor_state


#This promises to become more complicated
func interrupt_change_action_state(new_state_name: String, reset_if_same: bool):
	if (ai_states.has(new_state_name)):
		if !reset_if_same && action_state.name.to_lower() == new_state_name.to_lower():
			return	#don't change if we're calling through the same state again, and not doing a re-call
		var new_actor_state = ai_states[new_state_name]
		if action_state.exit():
			if new_actor_state.enter():
				action_state = new_actor_state
		elif action_state.interruptexit():	#The whole "I wasn't just asking" option
			if new_actor_state.enter():
				action_state = new_actor_state

#For when we've just been hit by something - most likely our player
func on_take_damage(damageAmount, knockback, attackstun, on_damage_function, hurt_type, instigator):
	action_state.on_take_damage(damageAmount, knockback, attackstun, on_damage_function, hurt_type, instigator)

func on_get_blocked(instigator):
	action_state.on_get_blocked(instigator)

#This function is called up from each of the combat states that have the player enter a strike check area
func do_trigger_strike_callback(body, strike_action: String):
	#print("Got trigger callback " + strike_action)
	#So we could be getting a few of these coming through over a set period of time before making a stike...
	if action_state.has_meta("do_trigger_strike_callback"):
		action_state.do_trigger_strike_callback(body, strike_action)

#This will be called from our AI state, and passed through to our base actor
func set_strike_triggers(state: bool):
	#callback_attacks.clear()
	targetactor.set_strike_triggers(state)

func anim_finished(anim_name: String):
	if action_state.has_method("anim_finished"):
		action_state.anim_finished(anim_name)
