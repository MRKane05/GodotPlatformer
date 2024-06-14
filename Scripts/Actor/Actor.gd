extends ObjectBase
class_name Actor

#A stack of variables which won't be configerable...
export(float) var MAX_SPEED_RUN = 80			#Basic movement speed

#We might want to expose these to add interesting behavior with enemies
const MOVE_ACCEL = 300		#Movement acceleration, delta time affected
const MOVE_DECEL = 300		#Delta time affected also

const GRAVITY = 500				#Gravity acceleration. Assume 60fps
const MAX_FALL_SPEED = 180		#Maxiumum falling speed
const JUMP_POWER = -200			#Jump velocity
const LAUNCH_POWER = -200		#Float velocity. Used when the player is jumping up to meet a floated target, or when an enemy is "floated"

const FLOOR = Vector2(0, -1)	#The normal direction of the floor (used with move_and_slide system to see where collisions should happen with the ground)
const CROUCH_THRESHOLD = 0.8	#At what point in our analogue control do we stop moving and start crouching? This might need to be higher

var is_launched = false	 	#Were we launched by an attack
var is_lifting = false		#Are we lifting into an attack after launching something?

var on_ground = false	#Are we grounded by touching or with raycasts?
var on_wall = 0			#Wallbased raycasts to allow for wallgrabs
var facing_dir = 1 #Which direction should our sprite nominally be facing?
var sprite_flipped = false	#The direction of our sprite as defined by the different functions

export(String) var strike_plain = "" #What is our attack if we're not putting in any input? This promises to get overly complex
export(String) var strike_up = "" #What is our attack if we're holdin up and striking? I can't help but think there needs to be different logic here...
# Path to the initial active state. We export it to be able to pick the initial state in the inspector.
export var initial_state := NodePath()

#Get our animation players
export (NodePath) var _animation_player
onready var animation_player:AnimationPlayer = get_node(_animation_player)

#The setup just doesn't like this - apparently it's making a cyclic dependency
#export (NodePath) var _controller
#onready var char_controller:ActorController = get_node(_controller)
var controller #This will be assigned by our controller at runtime

# The current active state. At the start of the game, we get the `initial_state`.
onready var action_state: ActorState = get_node(initial_state)
onready var Global = get_node("/root/Global") #Collect and assign our globals for referencing

#Animation stuff
var actor_animationtree #The animation tree that'll be driving our animations

var actor_states = {} # Dictionary of different actions we can do
var combat_states = {} # Dictionary of different combat actions we can do

var velocity = Vector2(0,0)	#our movement as defined by our state class

var move_dir = 0	#sent through from our controller
var vertical_move_dir = 0 #Another through controller value

var fall_hold = 0	#Used when doing air combat, this value arrests gravity for a duration

var attack_actions = [] #A list of combat actions sent through from the controller. This may or may not be used by the AI

#combat systems
var combat_fall_hold = 1.0 #0.75
var combo_counter = 0
var attack_presses = 0
var attack_refresh = 0

var next_block_time = 0
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
	
	if action_state:
		action_state.enter()
	else: #We've a major problem here
		pass

#handle timing variables
func handlecountdowns(delta):
	fall_hold -= delta
	next_block_time -= delta
	#if fall_hold > 0:
#		set_debug_header("H")
	#else:
#		set_debug_header("_")


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
				#print(new_state_name)
		elif action_state.interruptexit():	#The whole "I wasn't just asking" option
			if new_actor_state.enter():
				action_state = new_actor_state
				#print(new_state_name)

func set_debug_header(debug_text):
	if $DebugLabel:
		$DebugLabel.text = debug_text


func set_animation(anim_name: String):
	if animation_player:
		if animation_player.has_animation(anim_name):
			animation_player.current_animation = anim_name	#Dunno if we can do this?
		else:
			pass
	else:
		pass


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
	#if attack_presses > 0 && !is_attacking: #we want to do an attack, and we can do an attacdk
	#	select_attack_action()

func _physics_process(delta):
	handlecountdowns(delta) #Important for our built-in tickers
	if action_state: #Call through to our state so that we can do stuff!
		velocity = action_state.physics_update(delta, velocity, move_dir)
		#Move according to what our velocity says we should do
		#velocity = move_and_slide(velocity, FLOOR) #this automatically includes delta time behind the scenes
		var snap = Vector2.DOWN * 0.2 if is_on_floor() else Vector2.ZERO
		velocity = move_and_slide_with_snap(velocity, snap, FLOOR) #this automatically includes delta time behind the scenes
		#Handle our collisions
		handlemovementcontacts()
		#set our globals. This position will be referenced by AI and probably other functions
		#Global.playerpos = self.position
	else:
		pass

#Check to see if we're against a wall
func touchingwall():
	if $WallCheckRight.is_colliding():
		return -1
	elif $WallCheckLeft.is_colliding():
		return 1
	return 0

func do_platform_drop():
	if $DowncastGround.is_colliding():
		var downcast_ground_collider = $DowncastGround.get_collider()
		

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

func set_move_dir(new_move_dir: float, new_facing_dir, new_vertical_move_dir):
	move_dir = new_move_dir
	facing_dir = new_facing_dir
	vertical_move_dir = new_vertical_move_dir
	set_facing_scale(facing_dir)

#See about having the animations themselves handle the next step in the combo. This will need expanded
func has_attack_press():
	return attack_presses > 0

func deque_attack_action():
	if attack_actions.size() == 0:
		return ""
	
	var attack_action = attack_actions[0]
	attack_actions.remove(0)
	return attack_action

func get_next_attack_action():
	if attack_actions.size() == 0:
		return ""
	return attack_actions[0]

func clear_action_stack():
	attack_actions.clear()

#This isn't a good system and will need changing
#This will be called after an attack finishes
func select_attack_action(new_attack_action):
	attack_actions.append(new_attack_action)
	#print(new_attack_action)
	attack_presses += 1
	attack_refresh = 0.8	#Essentially the time we've got until we can't press fire again to keep doing the combo
	combo_counter += 1
	#Can we interrupt what we're doing?
	if is_attacking || attack_actions.size() == 0:
		return;
	
	var attack_action = deque_attack_action()
	
	if action_state is CombatState:
		pass
		#Sure this seems like a good idea, but I'm not sure that it is...
		#if action_state.next_combo_state != "": #if we have an action after this
		#	attack_presses -=1 #Remove one from our attack presses
		#	change_action_state(action_state.next_combo_state, false)
	else:
		#I think we're at the point where maybe my prior idea of having a "best selection" approach won't be a terrible idea...
		
		#So at this point we want to figure out which attack animation we need to start with (or switch with)
		match attack_action:
			"a":
				if (strike_plain != "" && combat_states[strike_plain]):
					var attack = combat_states[strike_plain]
					change_action_state(strike_plain, false)
			"u":
				#Some player specific case handling. This isn't the way to go about this...
				if on_ground:
					if (strike_up != "" && combat_states[strike_up]):
						var attack = combat_states[strike_up]
						change_action_state(strike_up, false)
				else:
					if (strike_plain != "" && combat_states[strike_plain]):
						var attack = combat_states[strike_plain]
						change_action_state(strike_plain, false)

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
	#print("Attack animation finished")
	anim_finished("attack")
	#select_attack_action()

func anim_finished(anim_name: String):
	if action_state:
		action_state.anim_finished(anim_name)

func take_damage(damageAmount, knockback, attackstun, on_damage_function, hurt_type, instigator):
	if controller:
		controller.on_take_damage(damageAmount, knockback, attackstun, on_damage_function, hurt_type, instigator)
	else:
		print("Controller not assigned")
	
	if action_state.has_method("handle_take_damage"):	#if this can be handled by the action state then do so
		if action_state.handle_take_damage(damageAmount, knockback, attackstun, on_damage_function, hurt_type, instigator):
			#Our function has handled this, and logically we'll not be taking damage
			pass
		else:
			.take_damage(damageAmount, knockback, attackstun, on_damage_function, hurt_type, instigator)
	else:
		.take_damage(damageAmount, knockback, attackstun, on_damage_function, hurt_type, instigator)

func do_hurt():
	interrupt_change_action_state("Actor_Hurt", false)

func get_parried(knockback, parrystun, instigator):
	current_knockback = knockback
	interrupt_change_action_state("Actor_Parried", false)

#Callback from one of our strike areas. I might have to think of a novel way to figure out what the damage will be...
#this is called when we manage to hit something
func _on_AttackArea2D_body_entered(body):
	if body.has_method("take_damage"):	#ducktyping to see if we're hitting something that's generically hittable
		#Look to our current action state to see what damage we should be doing
		if action_state is CombatState:
			body.take_damage(action_state.attack_damage, action_state.knockback_force * sign(facing_dir), action_state.attack_stun, action_state.on_function_call, action_state.hurt_type, self)
			if action_state.combat_float:
				#call_deferred("strike_fall_hold", combat_fall_hold) #Do the float for ourselves
				if body.has_method("strike_fall_hold"):
					print("body has fall hold method")
					#body.call_deferred("strike_fall_hold", combat_fall_hold)
					body.strike_fall_hold(combat_fall_hold)

#Boilerplate function used by the player
func set_collision_crouched(is_crouched):
	pass

func do_float_lift():
	is_launched = true
	#velocity += Vector2(0, LAUNCH_POWER)
	interrupt_change_action_state("Actor_Float", false)


func do_float_launch():
	print ("doing float launch")
	is_lifting = true
	velocity += Vector2(0, LAUNCH_POWER)

#Called for when we want to juggle something in the air
func strike_fall_hold(fall_hold_delay):
	if !on_ground:
		fall_hold = fall_hold_delay
		print ("strike_fall_hold: " + String(fall_hold))
