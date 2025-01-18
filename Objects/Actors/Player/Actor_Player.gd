extends Actor
class_name Actor_Player

#A stack of variables which won't be configerable...
#const MAX_SPEED_RUN = 80			#Basic movement speed
const MAX_SPEED_DASH = 225			#Also our sprinting speed
const MAX_SPEED_SPRINT = 195		#Faster than run, slower than dash, is our sprint state
const WALLJUMP_HSP = 75			#Horizontal speed we jump off walls
#const MOVE_ACCEL = 300		#Movement acceleration, delta time affected
#const MOVE_DECEL = 300		#Delta time affected also
#const GRAVITY = 500				#Gravity acceleration. Assume 60fps
#const GRAVITYMULTIPLIER = 1.5	#The suggested value for marioesque gravity behavior
const WALL_SLIDE_SPEED = 50	#if we're not holding against the wall how quickly do we slide down?
#const MAX_FALL_SPEED = 180		#Maxiumum falling speed
#const JUMP_POWER = -200			#Jump velocity
const WALLJUMP_POWER = -270		#Vertical jump off walls
const MAX_CYOTETIME = 0.15		#How long does our cyote time last for after leaving the ground?
#const FLOOR = Vector2(0, -1)	#The normal direction of the floor (used with move_and_slide system to see where collisions should happen with the ground)
const WALLJUMP_LOCKTIME = 0.4	#The duration that we'll "lose" movement control following a walljump to stop the player from turning and latching straight back on
const DASH_DURATION = 0.4		#The duration that we'll dash for
const REDASH_WAIT = 0.5			#How long we have to wait until we can dash again
const DASH_LAYER = 1			#What layer do we disalbe for dashing
const DROP_LAYER = 2			#The layer that our fall-through platforms are on

#Essentially these control and limit our players movement so we can unlock abilities with powerups
export(bool) var can_wallgrab = false
export(int) var max_airdashes = 0
export(int) var max_airjumps = 0

#var on_ground = false	#Are we grounded by touching or with raycasts?
var jump_free = false #Set by the raycasts to allow for a jump just before our player contacts the ground
#var on_wall = 0			#Wallbased raycasts to allow for wallgrabs
var dash_dir = 0	#The direction -1, 0, 1 that we're dashing in, also used as a check to see if we're dashing dash_dir == 0
#var facing_dir = 1 #Which direction should our sprite nominally be facing?
#var sprite_flipped = false	#The direction of our sprite as defined by the different functions
var jumps_left = max_airjumps	#how many jumps we've got left. Reset on contact with wall or floor, or bonus
var dashes_left = max_airdashes	#how many dashes we've got left. Reset on contact with wall, floor, or bonus

func set_ability(ability_name, state):
	match ability_name:
		"wallgrab":
			can_wallgrab = bool(state)
		"airdash":
			max_airdashes = 1
		"doublejump":
			max_airjumps = 1
			

#var combo_counter = 0
#var attack_presses = 0
#var attack_refresh = 0
#var is_attacking = false

var cyote_time = 0	#Time that we'll be able to jump after leaving a platform
#var walljump_time = 0 #Control lock time based off of when we jumped off a wall
var dash_time = 0 #Time remaining on our dash (might be handled elsewhere)
var dash_hold = false
var redash_time = 0 #Time until we can dash again

#Details for our pistol (I assume this is only as complicated as it'll be for the moment...)
export(int) var pistol_shots = 0

var quick_respawn_location = Vector2(0,0) #Where will we zoom back to if we land in spikes?

func _ready():
	._ready()
	Global.Player = self
	#Global.PlayerCollider = $CollisionShape2D
	update_hud()

#Player countdowns
func handlecountdowns(delta):
	.handlecountdowns(delta)
	cyote_time -= delta
	walljump_time -= delta
	dash_time -= delta
	redash_time -= delta
	#next_block_time -= delta
	#stuntime -= delta
	#parry_time -= delta
	
	if dash_time <= 0 && dash_dir != 0:
		dash_dir = 0	#Clear our dash direction
		#setdashcollisions(false)
		redash_time = REDASH_WAIT
	
	attack_refresh -= delta
	if attack_refresh <=0: #reset our combo systems
		#attack_presses = 0
		#print("Zeroed attack presses")
		combo_counter = 0

func handlemovementcontacts():
	#Get our contacts======================================
	if !on_ground && can_wallgrab:
		on_wall = touchingwall()
		#This piece of logic promises to have a substantial number of hiccoughs, which we may want to end up changing
		#especially because it's handled as an interrupt...
		if on_wall != 0 && sign(move_dir) == -on_wall && dash_time <= 0:
			change_action_state("Actor_OnWall", false)
			#canceldash()	#stop our dash if we hit a wall
			facing_dir = on_wall #Set our players facing direction while on a wall
			jumps_left = max_airjumps #reset our double jump counter
			dashes_left = max_airdashes #reset our dash counter
	else:
		on_wall = 0
		walljump_time = 0
	
	#Check our object grounded========================================================================
	#use raycasts to see if we're colliding with the ground to give us a little jump buffer
	if $DowncastLeft.is_colliding() || $DowncastRight.is_colliding():
		jump_free = true
	else:
		jump_free = false
	
	if (is_on_floor() || $DowncastGround.is_colliding()) && velocity.y  >= 0: #Only land on the ground when falling:	#check if we're standing on the ground is_on_floor() || 
		on_ground = true
		jumps_left = max_airjumps #reset our double jump counter
		dashes_left = max_airdashes #reset our dash counter
		cyote_time = MAX_CYOTETIME #Set our cyote time as we're not touching the ground
	else:	#character is airbourne
		on_ground = false

func setdashcollisions(is_dashing):
	#set_collision_layer_bit(DASH_LAYER, !is_dashing)
	set_collision_mask_bit(DASH_LAYER, !is_dashing)

func take_damage(damageAmount, knockback, attackstun, on_damage_function, hurt_type, instigator):
	.take_damage(damageAmount, knockback, attackstun, on_damage_function, hurt_type, instigator)
	#And update our health bar!
	$Camera2D/HUD._on_health_updated((health/30.0) * 100.0, 30)

var camera_zoom = 0.75
var target_camera_zoom = 0.75

func setTargetCameraZoom(toThis):
	target_camera_zoom = toThis;

func _physics_process(delta):
	Global.playerpos = self.position
	
	if (abs(camera_zoom-target_camera_zoom) > 0.01):
		camera_zoom = lerp(camera_zoom, target_camera_zoom, delta * 4.0)
		$Camera2D._setCameraZoom(camera_zoom)

#Used for dropping through platforms that can be dropped through
func check_drop_function():
	if $DowncastGround.is_colliding():
		if $DowncastGround.get_collider().has_method("player_fall_through"):
			$DowncastGround.get_collider().player_fall_through(self)
			return true
	return false

func set_drop_collision(is_dropping):
	print ("Doing collision drop")
	set_collision_layer_bit(DROP_LAYER, !is_dropping)
	set_collision_mask_bit(DROP_LAYER, !is_dropping)

func set_quick_respawn_location(new_position):
	quick_respawn_location = new_position - Vector2(0, 10) #This may need configured for player height
	change_action_state("Actor_OnGround", false)
	

func touched_killspikes():
	if (actor_states.has("Actor_SpikeDie")):
		interrupt_change_action_state("Actor_SpikeDie", false)
	else:
		do_quick_respawn();

func do_die():
	#This'll be a little more complicated because it's the player
	#if Global.target_scene != "" && Global.target_door != "":
		#We can do a proper reload with this information
	#	LoadingScreen.change_scene(Global.target_scene, scene_base, Global.target_doorway) #load our first scene!
	#You know what? Fuckit. Sometimes life is too complicated
	#get_tree().reload_current_scene()
	LoadingScreen.reload_scene(self.get_parent())
	
	#queue_free()	#This should be cleared in the reload

func do_quick_respawn():
	if quick_respawn_location != Vector2(0,0): #we've got a quick respawn location set
		#do the animation and then move after it
		#Move using something eloquent
		#Do set amount of damage as penalty
		#For the moment just snap to location
		self.position = quick_respawn_location
		

func set_collision_crouched(is_crouched):
	$CollisionShape2D.set_deferred("disabled", is_crouched)
	#$CollisionShape2D.disabled = is_crouched
	$CollisionShapeCrouched.set_deferred("disabled", !is_crouched)
	#$CollisionShapeCrouched.disabled = !is_crouched
	$CollisionShapeJump.set_deferred("disabled", !is_crouched)
	#$CollisionShapeJump.disabled = is_crouched

#Well technically: is airbourne...
func set_collision_jumping(is_jumping):
	$CollisionShape2D.set_deferred("disabled", is_jumping)
	#$CollisionShape2D.disabled = is_jumping
	$CollisionShapeCrouched.set_deferred("disabled", is_jumping)
	#$CollisionShapeCrouched.disabled = is_jumping
	$CollisionShapeJump.set_deferred("disabled", !is_jumping)
	#$CollisionShapeJump.disabled = !is_jumping
	
#Used with our pickups
func get_health(amount):
	health = clamp(health + amount, 0, 30)
	$Camera2D/HUD._on_health_given((health/30.0) * 100.0, 30)

#this function will go both ways
func change_shots(amount):
	pistol_shots += amount
	$Camera2D/HUD._set_pistol_shots(pistol_shots)

func update_hud():
	$Camera2D/HUD._on_health_updated((health/30.0) * 100.0, 30)
	$Camera2D/HUD._set_pistol_shots(pistol_shots)


#Called from the player based off of an aim direction they're trying
func find_best_target_position(aim_dir: Vector2, base_position: Vector2):
	var aim_angle = aim_dir.normalized()
	
	var best_dot = 0.8 #This is whatever our "autoaim" lenency is
	var bestEnemy = null
	var best_vector

	var base = self.get_parent()
	for child in base.get_children():
		#if child is Actor_Enemy: #This is causing a sea of problems
		if child is Actor && child != self:
			print ("Have actor Enemy")
			if is_within_range(70, child.position, base_position): #See if this node is within range before we do the expensive math
				var target_to = child.position - base_position
				var target_angle = target_to.normalized()
				var dot_diff = aim_angle.dot(target_angle) #Use the dot product to see how close we are to our intended aiming vector
				#Of course I'd be wise to also consider things like proximity, but for the moment we'll do "closest to aim vector"
				if dot_diff > best_dot:
					best_dot = dot_diff
					bestEnemy = child
					best_vector = target_angle
	
	if bestEnemy:
		return best_vector #return our found angle
	return aim_dir #Nothing worthwhile, just use our standard angle
