extends KinematicBody2D
class_name Actor

#A stack of variables which won't be configerable...
export(float) var MAX_SPEED_RUN = 80			#Basic movement speed

#We might want to expose these to add interesting behavior with enemies
const MOVE_ACCEL = 300		#Movement acceleration, delta time affected
const MOVE_DECEL = 300		#Delta time affected also

const GRAVITY = 500				#Gravity acceleration. Assume 60fps
const MAX_FALL_SPEED = 180		#Maxiumum falling speed
const JUMP_POWER = -200			#Jump velocity
const FLOOR = Vector2(0, -1)	#The normal direction of the floor (used with move_and_slide system to see where collisions should happen with the ground)

var on_ground = false	#Are we grounded by touching or with raycasts?
var on_wall = 0			#Wallbased raycasts to allow for wallgrabs
var facing_dir = 1 #Which direction should our sprite nominally be facing?
var sprite_flipped = false	#The direction of our sprite as defined by the different functions

# Path to the initial active state. We export it to be able to pick the initial state in the inspector.
export var initial_state := NodePath()

#Get our animation players
export (NodePath) var _animation_player
onready var animation_player:AnimationPlayer = get_node(_animation_player)

# The current active state. At the start of the game, we get the `initial_state`.
onready var action_state: ActorState = get_node(initial_state)
onready var Global = get_node("/root/Global") #Collect and assign our globals for referencing

#Animation stuff
var actor_animationtree #The animation tree that'll be driving our animations

var actor_states = {} # Dictionary of different actions we can do
var combat_states = {} # Dictionary of different combat actions we can do

var velocity = Vector2(0,0)	#our movement as defined by our state class

var move_dir = 0	#sent through from our controller

#combat systems
var combo_counter = 0
var attack_presses = 0
var attack_refresh = 0
var is_attacking = false
#export(CollisionShape2D) var combatstikers = []	# well that's a pain in the ass...
var combatstrikers = []

#So the idea is that the actor has a set of actor states defining what the actor can do
#These states are selected by an input driver state controller, this might be the player, or the AI
#So this base actor class should be a heap of helper functions

# Called when the node enters the scene tree for the first time.
func _ready():
	yield(owner, "ready")
	#actor_animationtree = $AnimationTree.get("parameters/playback")
	# The state machine assigns itself to the State objects' state_machine property.
	for child in $ActorStates.get_children():
		if child is ActorState: #Check if this is an actor state class
			child.base_actor = self
			actor_states[child.name] = child	#Add our action to our dictionary
	
	for child in $CombatStates.get_children():
		if child is ActorState: #Check if this is an actor state class
			child.base_actor = self
			combat_states[child.name] = child	#Add to our combat list so that the system can reference it
			actor_states[child.name] = child	#Add our action list so that we can play it
	
	#Go through and collect all our combat collision shapes. Assume that every character has the same setup
	for child in $FlipElements/AttackArea2D.get_children():
		if child is CollisionShape2D:
			combatstrikers.append(child)
	
	action_state.enter()

#handle timing variables
func handlecountdowns(delta):
	pass


#This promises to become more complicated
func change_action_state(new_state_name: String, reset_if_same: bool):

	if (actor_states.has(new_state_name)):
		if !reset_if_same && action_state.name.to_lower() == new_state_name.to_lower():
			return	#don't change if we're calling through the same state again, and not doing a re-call
		var new_actor_state = actor_states[new_state_name]
		
		if action_state.exit():
			if new_actor_state.enter():
				action_state = new_actor_state


#This promises to become more complicated
func interrupt_change_action_state(new_state_name: String, reset_if_same: bool):
	if (actor_states.has(new_state_name)):
		if !reset_if_same && action_state.name.to_lower() == new_state_name.to_lower():
			return	#don't change if we're calling through the same state again, and not doing a re-call
		var new_actor_state = actor_states[new_state_name]
		if action_state.exit():
			if new_actor_state.enter():
				action_state = new_actor_state
				print(new_state_name)
		elif action_state.interruptexit():	#The whole "I wasn't just asking" option
			if new_actor_state.enter():
				action_state = new_actor_state
				print(new_state_name)

func set_animation(anim_name: String):
	#actor_animationtree.travel(anim_name)
	if animation_player:
		animation_player.current_animation = anim_name	#Dunno if we can do this?

func set_facing_scale(new_scale : float):
	$FlipElements.scale.x = abs($FlipElements.scale.x) * new_scale
	#this is important as it saves screwing up function with other methods...

# Virtual function. Receives events from the `_unhandled_input()` callback.
func handle_input(_event: InputEvent) -> void:
	pass


func _process(delta):
	if action_state: #Call through to our state so that we can do stuff!
		action_state.update(delta)
	#this feels like a good place to put our combat action stuff
	if attack_presses > 0 && !is_attacking: #we want to do an attack, and we can do an attacdk
		select_attack_action()


func _physics_process(delta):
	handlecountdowns(delta) #Important for our built-in tickers
	if action_state: #Call through to our state so that we can do stuff!
		velocity = action_state.physics_update(delta, velocity, move_dir)
		#Move according to what our velocity says we should do
		velocity = move_and_slide(velocity, FLOOR) #this automatically includes delta time behind the scenes
		#Handle our collisions
		handlemovementcontacts()
		#set our globals. This position will be referenced by AI and probably other functions
		Global.playerpos = self.position

#Check to see if we're against a wall
func touchingwall():
	if $WallCheckRight.is_colliding():
		return -1
	elif $WallCheckLeft.is_colliding():
		return 1
	return 0

	#All the contacts that the actor could make in the level (ground, walls)
func handlemovementcontacts():
	#Get our contacts======================================
	
	#Check our object grounded========================================================================
	#use raycasts to see if we're colliding with the ground to give us a little jump buffer
	#This needs to be different for AI so that they know where the edge of something is
	if ($DowncastLeft.is_colliding() || $DowncastRight.is_colliding() || is_on_floor()) && velocity.y  >= 0: #Only land on the ground when falling:	#check if we're standing on the ground is_on_floor() || 
		
		on_ground = true
		#jumps_left = 1 #reset our double jump counter
		#dashes_left = 1 #reset our dash counter
		#cyote_time = MAX_CYOTETIME #Set our cyote time as we're not touching the ground
	else:	#character is airbourne
		on_ground = false

func set_move_dir(new_move_dir: float, new_facing_dir):
	move_dir = new_move_dir
	facing_dir = new_facing_dir
	set_facing_scale(facing_dir)

func make_attack_press():
	#I'd really like to think of a way to try and put this system somewhere else....but here we are for the moment
	attack_presses += 1
	attack_refresh = 0.5	#Essentially the time we've got until we can't press fire again to keep doing the combo
	combo_counter += 1
	#Logic time! Lets see if we can find something to use as an attack in our combat_states dictionary...
	#for the moment lets just jump straight into the action select
	#select_attack_action()

#This isn't a good system and will need changing
func select_attack_action():
	var best_attack
	var best_attack_name
	for key in combat_states:
		var thisAttack = combat_states[key]
		#check our state for ground/air first
		if thisAttack.only_ground && !on_ground || thisAttack.only_air && on_ground:
			#we can't use this attack as we're not in the correct state
			print ("attack not viable")
		else:
			if !best_attack: #make sure we've got something
				best_attack = thisAttack
				best_attack_name = key
			#subtract 1 from the combo counter as we'll always be incrementing it by one anyway
			if (combo_counter-1) == thisAttack.attack_chain_order: #this is probably the better pick
				best_attack = thisAttack
				best_attack_name = key
	
	if best_attack_name:
		attack_presses = clamp(attack_presses-1, 0, 5)	#Currently clamped our combo to 5. Lets see that become a bug later
		change_action_state(best_attack_name, false)

#Just in case something funky as all hell manages to happen while our character is undergoing an attack
func clear_all_combat_strikers():
	for striker in combatstrikers:
		striker.disabled = true

func public_animation_finished(animation_name: String):
	print("Got Animation Finish Call")
	#This is one way to check when our animation has been finished for the likes of slide, but I don't
	#feel that it's a good method and could do with something more dynamic...

func anim_slide_finished():
	anim_finished("slide")

func attack_animation_finished():
	anim_finished("attack")

func anim_finished(anim_name: String):
	if action_state:
		action_state.anim_finished(anim_name)