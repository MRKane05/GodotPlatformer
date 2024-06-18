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
	print(new_state_name)
	if (ai_states.has(new_state_name)):
		if !reset_if_same && action_state.name.to_lower() == new_state_name.to_lower():
			return	#don't change if we're calling through the same state again, and not doing a re-call
		var new_actor_state = ai_states[new_state_name]
		
		if action_state.exit():
			if new_actor_state.enter():
				action_state = new_actor_state
				print(new_state_name) #Quick debug on our AI


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
