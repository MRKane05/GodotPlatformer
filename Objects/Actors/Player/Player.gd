extends KinematicBody2D

#default is 60fps

const MAX_SPEED_RUN = 80			#Basic movement speed
const MAX_SPEED_DASH = 150			#Also our sprinting speed
const MAX_SPEED_SPRINT = 130		#Faster than run, slower than dash, is our sprint state
const WALLJUMP_HSP = 50			#Horizontal speed we jump off walls
const MOVE_ACCEL = 300		#Movement acceleration, delta time affected
const MOVE_DECEL = 300		#Delta time affected also
const GRAVITY = 500				#Gravity acceleration. Assume 60fps
const GRAVITYMULTIPLIER = 1.5	#The suggested value for marioesque gravity behavior
const WALL_SLIDE_SPEED = 50	#if we're not holding against the wall how quickly do we slide down?
const MAX_FALL_SPEED = 180		#Maxiumum falling speed
const JUMP_POWER = -200			#Jump velocity
const WALLJUMP_POWER = -180		#Vertical jump off walls
const MAX_CYOTETIME = 0.15		#How long does our cyote time last for after leaving the ground?
const FLOOR = Vector2(0, -1)	#The normal direction of the floor (used with move_and_slide system to see where collisions should happen with the ground)
const WALLJUMP_LOCKTIME = 0.3	#The duration that we'll "lose" movement control following a walljump to stop the player from turning and latching straight back on
const DASH_DURATION = 0.3		#The duration that we'll dash for
const REDASH_WAIT = 0.5			#How long we have to wait until we can dash again

#Input constants
const DEADZONE = 0.2			#What is our thumbstick deadzone?


const FIREBALL = preload("res://Objects/Function/fireball.tscn") #set our fireball as a referenced object

var is_attacking = false	#Are we in the middle of an attack action (animation cancelled)

var is_dead = false
export(float) var health = 100
var velocity = Vector2() #Our movement velocity

var on_ground = false	#Are we grounded by touching or with raycasts?
var on_wall = 0			#Wallbased raycasts to allow for wallgrabs
var move_dir = 0 #The direction -1, 0, 1 that we're moving in
var dash_dir = 0	#The direction -1, 0, 1 that we're dashing in, also used as a check to see if we're dashing dash_dir == 0
var facing_dir = 1 #Which direction should our sprite nominally be facing?
var sprite_flipped = false	#The direction of our sprite as defined by the different functions
var jumps_left = 1	#how many jumps we've got left. Reset on contact with wall or floor, or bonus
var dashes_left = 1	#how many dashes we've got left. Reset on contact with wall, floor, or bonus

#Countdown timers
var cyote_time = 0
var walljump_time=0
var dash_time = 0
var dash_hold = false
var redash_time = 0

#combat systems
var combo_counter = 3
var attack_presses = 0
var attack_refresh = 0

var is_blocking = false
var parry_time = 0

var current_knockback = 0
var stuntime = 0

onready var Global = get_node("/root/Global") #Collect and assign our globals for referencing

func _ready():
	Global.Player = self
	Global.PlayerCollider = $CollisionShape2D
	#Set our gamera limits
	var tilemap_rect = get_parent().get_node("TileMap").get_used_rect()
	var tilemap_cell_size = get_parent().get_node("TileMap").cell_size
	$Camera2D.limit_left = tilemap_rect.position.x * tilemap_cell_size.x
	$Camera2D.limit_right = tilemap_rect.end.x * tilemap_cell_size.x
	$Camera2D.limit_top = tilemap_rect.position.y * tilemap_cell_size.y
	$Camera2D.limit_bottom = tilemap_rect.end.y * tilemap_cell_size.y
	


func downray_hitground():
	if $DowncastLeft.is_colliding():
		return true
	if $DowncastRight.is_colliding():
		return true
	return false

#handle timing variables
func handlecountdowns(delta):
		cyote_time -= delta
		walljump_time -= delta
		dash_time -= delta
		redash_time -= delta
		stuntime -= delta
		parry_time -= delta
		
		if dash_time <= 0 && dash_dir != 0:
			dash_dir = 0	#Clear our dash direction
			setdashcollisions(false)
			redash_time = REDASH_WAIT
		
		attack_refresh -= delta
		if attack_refresh <=0: #reset our combo systems
			attack_presses = 0
			combo_counter = 3

#All the contacts that the actor could make in the level (ground, walls)
func handlemovementcontacts():
	#Get our contacts======================================
	if !on_ground:
		on_wall = touchingwall()
		if on_wall != 0:
			canceldash()	#stop our dash if we hit a wall
			facing_dir = on_wall #Set our players facing direction while on a wall
			jumps_left = 1 #reset our double jump counter
			dashes_left = 1 #reset our dash counter
	else:
		on_wall = 0
		walljump_time = 0
	
	#Check our object grounded========================================================================
	#use raycasts to see if we're colliding with the ground to give us a little jump buffer
	if $DowncastLeft.is_colliding() || $DowncastRight.is_colliding() || is_on_floor():	#check if we're standing on the ground is_on_floor() || 
		on_ground = true
		jumps_left = 1 #reset our double jump counter
		dashes_left = 1 #reset our dash counter
		cyote_time = MAX_CYOTETIME #Set our cyote time as we're not touching the ground
	else:	#character is airbourne
		on_ground = false
		if !is_attacking:
			if on_wall !=0:
				$AnimatedSprite.play("wallgrab")
			elif velocity.y < 0:
				if $AnimatedSprite.animation != "jump":	#Does this do re-triggers?
					$AnimatedSprite.play("jump")
			else:
				if $AnimatedSprite.animation != "fall":
					$AnimatedSprite.play("fall")

func setattackarea(bAttacking):
	$AttackArea2D/StandardStriker.disabled = !bAttacking	#set our weapon hurt zone active

func handleblocking():
		#I figure this is a good enough place to put our block?
	if Input.is_action_just_pressed("ui_shift_right"):
		is_blocking = true
		is_attacking = false 	#cancel our attack
		dash_dir = 0	#cancel our dash
		dash_hold = false
		parry_time = 0.75	#PROBLEM: This needs to be configerable
		$AnimatedSprite.play("block")
	if !Input.is_action_pressed("ui_shift_right"): #Dunno if this is the way of going about it
		is_blocking = false

#Character attacks
func handleattacks():
	#Attacking code================================================================
	#So it'd be nice to have something that's forgiving in terms of the attack system
	if Input.is_action_just_pressed("ui_focus_next"):
		attack_presses += 1
		attack_refresh = 0.5	#Essentially the time we've got until we can't press fire again to keep doing the combo
	
	if attack_presses > 0 && !is_attacking && combo_counter > 0:
		
		if combo_counter == 3:
			$AnimatedSprite.play("attack01")	#play attack animation
		elif combo_counter == 2:
			$AnimatedSprite.play("attack02")	#play attack animation
		elif combo_counter == 1:
			$AnimatedSprite.play("attack03")	#play attack animation
		
		#handle our counters
		attack_presses -=1	#reduce our press count
		combo_counter -=1	#reduce our combo count
		is_attacking = true	#Will be set to false with animation finishing
		setattackarea(is_attacking)
		
func doprojectile():
		var fireball = FIREBALL.instance() #create an instance of the fireball
		fireball.set_fireball_direction(sign($Position2D.position.x))	#set the direction of the fireball, using the position of the Position2D (not all that eloquent...)
		get_parent().add_child(fireball) #get the scene that the player is in, and add the fireball to it
		fireball.position = $Position2D.global_position	#set the fireball to the position 2D on the player

#Directional input from the user is assigned in this function
func getdirectionalinput():
	#Movement controllers=============================================
	if Input.get_connected_joypads().size() > 0:
		#See about handling thumbsticks
		var xAxis = Input.get_joy_axis(0, JOY_ANALOG_LX)
		if (abs(xAxis) > DEADZONE):	#Of course this entertains the problem of being able to creep slowly. That might involve some animation speed stuff?
			move_dir = xAxis
		else:
			move_dir=0
	else: #Without an attached controller default to button inputs
		#horizontal movement input controller
		if Input.is_action_pressed("ui_right"):
			move_dir = 1
		elif Input.is_action_pressed("ui_left"):
			move_dir = -1
		else:
			move_dir = 0
		
	if Input.is_action_just_pressed("ui_shift_left") && redash_time <= 0 && dashes_left > 0:
		dashes_left -= 1	#decrease our dash counter to keep with form
		dash_time = DASH_DURATION
		dash_dir = facing_dir
		setdashcollisions(true)
		if on_ground:
			dash_hold = true
			


#The logic for calculating the movement values for our object
func handlemovement(delta):
	#And a checker to see if we need to wait until we've finished our animation
	#print(dash_hold)
	if move_dir != 0 && walljump_time <=0: #Handle our standard movement
		if !is_attacking && !is_blocking:
			velocity.x += MOVE_ACCEL * delta * move_dir	#directional acceleration
			var maxspeed = MAX_SPEED_RUN
			if Input.is_action_pressed("ui_shift_left") && on_ground:	#if we're holding sprint have our character sprint (which will logically be after a dash)
				maxspeed = MAX_SPEED_SPRINT
			velocity.x = clamp(velocity.x, -maxspeed, maxspeed)
			if on_wall == 0:
				$AnimatedSprite.play("run")
			if on_wall == 0: #only worry about setting this if we're not facing a well
				facing_dir = sign(move_dir)	#This will be later used to handle the facing direction of our sprite
			if sign($AttackArea2D.scale.x) != facing_dir:	
				$AttackArea2D.scale.x *= -1 #flip our Attack area position
	elif walljump_time <=0 || on_ground:	#Handle our stopping, but only if we're not walljumping
		if (velocity.x > 0):
			velocity.x = min(velocity.x - MOVE_DECEL*delta, 0)
		if (velocity.x < 0):
			velocity.x = max(velocity.x + MOVE_DECEL*delta, 0)
		
		if on_ground && !is_attacking && !is_blocking:
			$AnimatedSprite.play("idle")

func handledashmovement():
	#set our dash velocity
	velocity.x = MAX_SPEED_DASH * dash_dir
	if dash_dir!= 0:
		facing_dir = dash_dir	#Make this so that the user can't have the pawn "dash backwards"
	if on_ground:
		$AnimatedSprite.play("dash_ground")
	else:
		$AnimatedSprite.play("dash_air")

#Jumping logic and wall contacts
func handlejumping():
	if Input.is_action_just_pressed("ui_accept"):	#Lazy way of making this into the x button to jump
		canceldash() #Cancel our dash (if we're doing one)
		if on_wall != 0: #Simplify our logic by handling our wall jump first
			facing_dir = on_wall
			velocity.x = on_wall*WALLJUMP_HSP
			velocity.y = WALLJUMP_POWER				
			walljump_time = WALLJUMP_LOCKTIME
			$AnimatedSprite.play("wallgrab")
		elif (on_ground || cyote_time > 0):	#include our cyote time and ignore the bug that could happen by jumping then jumping...
			velocity.y = JUMP_POWER
			on_ground = false
		elif jumps_left > 0:
			jumps_left = jumps_left -1
			velocity.y = JUMP_POWER
			on_ground = false
	#Give us a variable jump
	if velocity.y < 0 && !Input.is_action_pressed("ui_accept") && !on_ground:
		velocity.y = max(velocity.y, JUMP_POWER/2.5)	

#Gravity, wall slides
func handlefallfunctions(delta):
	#Implement gravity===========================================================
	#Need some more wall grab logic here
	if !on_ground && on_wall != 0 && sign(on_wall) == -sign(velocity.x): #We're on a wall, and thus should "stick" to it based off of user input direction
		velocity.y = 0	#we're on a wall so fall slowly
	else:
		#var relativegravity = lerp(MIN_GRAVITY, GRAVITY, abs(velocity.y)/GRAVITY)
		var relativegravity = GRAVITY
		if velocity.y >0:
			relativegravity = GRAVITY*GRAVITYMULTIPLIER
		velocity.y += relativegravity*delta 
	
	#Clamp our fallspeed so that we don't keep accellerating because it's not fun
	var maxFallSpeed = MAX_FALL_SPEED
	if on_wall != 0:
		maxFallSpeed = WALL_SLIDE_SPEED
	velocity.y = clamp(velocity.y, JUMP_POWER, maxFallSpeed) #Axis are down positive. Giggity

func canceldash():
	dash_time = 0
	dash_dir = 0
	setdashcollisions(false)

func setdashcollisions(is_dashing):
	set_collision_layer_bit(1, !is_dashing)
	set_collision_mask_bit(1, !is_dashing)

#Core loop for handling the character controller
func _physics_process(delta):
	if is_dead == false:
		handlecountdowns(delta) #for our timing variables
		
		handlemovementcontacts()
		
		getdirectionalinput()
		
		if !is_attacking: #Quick stationary attack hack
			if dash_dir == 0: # && !dash_hold:
				handlemovement(delta)
			else:
				handledashmovement()	#really we need to spend a bit more time making sure this is behaving correctly, with a recovery then run after dash, but for the moment it's functional
		else:
			velocity.x = 0
		
		handlejumping()
		if on_ground: # && !dash_hold:
			handleblocking()
		
		if !is_blocking:
			handleattacks()
		
		if dash_dir == 0: #don't fall if we're dashing
			handlefallfunctions(delta)
		else:
			velocity.y = 0	#I'm sure this logic will be expanded as other things are added
		
		#Handle our sprite facings ====================================================================
		sprite_flipped = facing_dir < 0
		$AnimatedSprite.flip_h = sprite_flipped	#Handle character orientation based off of movement direction (this should be velocity?)
		
		#apply movement with internal collision checking===========================================================
		velocity = move_and_slide(velocity, FLOOR) #this automatically includes delta time behind the scenes
		
		#if get_slide_count() > 0: #This counds the collisions that can occur
		#	for i in range(get_slide_count()):	#Iterate through all collisions
		#		if "Enemy" in get_slide_collision(i).collider.name: #See if one of the collisions is an enemy, and if so kill the player
		#			dead()
		
		#set our globals. This position will be referenced by AI and probably other functions
		Global.playerpos = self.position
		
#Check to see if we're against a wall
func touchingwall():
	if $WallCheckRight.is_colliding():
		return -1 #returning our direction away from the wall
	if $WallCheckLeft.is_colliding():
		return 1
	return 0

func dead():
	is_dead = true #Mark our player as being dead
	velocity = Vector2(0,0) #annul our velocity
	$AnimatedSprite.play("dead")
	$CollisionShape2D.disabled = true
	$DieTimer.start()
	get_parent().get_node("ScreenShake").screen_shake(1,10,100)	#Shake screen when player dies

#Call through to see if we've finished playing the attack animation
func _on_AnimatedSprite_animation_finished():
	print($AnimatedSprite.animation)
	if $AnimatedSprite.animation.substr(0, 6) == "attack":	#Check if this is a named attack animation
		is_attacking = false; #set things so that we can attack again
		setattackarea(is_attacking) #disable our attack zone
	if $AnimatedSprite.animation.substr(0, 4) == "dash":
		dash_hold = false

func _on_DieTimer_timeout():
	#get_tree().change_scene("res://Scenes/TitleScreen.tscn") #load our titlescreen
	pass

#Basic hurt function
func take_damage(damageAmount, knockback, instigator):
	#Will need to analyse which direction our attack is coming from, as at the moment blocking essentially just makes the player invincible
	if parry_time >= 0: #we're in the parry stage of our action
		print("Parry successful")
		if instigator.has_method("do_stun"):
			instigator.do_stun(80*sign(facing_dir), 0.75, self)
	elif !is_blocking: #Take damage, or perhaps we could take chip damage, I dunno
		print("Player Damaged")
		
		current_knockback = knockback
		health -= damageAmount
		stuntime = 0.25	#Stun our enemy with the hit
		if health < 0:
			dead()

#this is called when we manage to hit something
func _on_AttackArea2D_body_entered(body):
	if body.has_method("take_damage"):	#ducktyping to see if we're hitting something that's generically hittable
		body.take_damage(5, 20 * sign(facing_dir), self)
