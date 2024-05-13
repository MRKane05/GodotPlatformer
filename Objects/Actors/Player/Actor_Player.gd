extends Actor
class_name Actor_Player

#A stack of variables which won't be configerable...
#const MAX_SPEED_RUN = 80			#Basic movement speed
const MAX_SPEED_DASH = 150			#Also our sprinting speed
const MAX_SPEED_SPRINT = 130		#Faster than run, slower than dash, is our sprint state
const WALLJUMP_HSP = 50			#Horizontal speed we jump off walls
#const MOVE_ACCEL = 300		#Movement acceleration, delta time affected
#const MOVE_DECEL = 300		#Delta time affected also
#const GRAVITY = 500				#Gravity acceleration. Assume 60fps
const GRAVITYMULTIPLIER = 1.5	#The suggested value for marioesque gravity behavior
const WALL_SLIDE_SPEED = 50	#if we're not holding against the wall how quickly do we slide down?
#const MAX_FALL_SPEED = 180		#Maxiumum falling speed
#const JUMP_POWER = -200			#Jump velocity
const WALLJUMP_POWER = -180		#Vertical jump off walls
const MAX_CYOTETIME = 0.15		#How long does our cyote time last for after leaving the ground?
#const FLOOR = Vector2(0, -1)	#The normal direction of the floor (used with move_and_slide system to see where collisions should happen with the ground)
const WALLJUMP_LOCKTIME = 0.3	#The duration that we'll "lose" movement control following a walljump to stop the player from turning and latching straight back on
const DASH_DURATION = 0.4		#The duration that we'll dash for
const REDASH_WAIT = 0.5			#How long we have to wait until we can dash again
const DASH_LAYER = 1			#What layer do we disalbe for dashing
const DROP_LAYER = 2			#The layer that our fall-through platforms are on

#var on_ground = false	#Are we grounded by touching or with raycasts?
var jump_free = false #Set by the raycasts to allow for a jump just before our player contacts the ground
#var on_wall = 0			#Wallbased raycasts to allow for wallgrabs
var dash_dir = 0	#The direction -1, 0, 1 that we're dashing in, also used as a check to see if we're dashing dash_dir == 0
#var facing_dir = 1 #Which direction should our sprite nominally be facing?
#var sprite_flipped = false	#The direction of our sprite as defined by the different functions
var jumps_left = 1	#how many jumps we've got left. Reset on contact with wall or floor, or bonus
var dashes_left = 1	#how many dashes we've got left. Reset on contact with wall, floor, or bonus

#var combo_counter = 0
#var attack_presses = 0
#var attack_refresh = 0
#var is_attacking = false

var cyote_time = 0	#Time that we'll be able to jump after leaving a platform
var walljump_time = 0 #Control lock time based off of when we jumped off a wall
var dash_time = 0 #Time remaining on our dash (might be handled elsewhere)
var dash_hold = false
var redash_time = 0 #Time until we can dash again

func _ready():
	._ready()
	Global.Player = self
	Global.PlayerCollider = $CollisionShape2D

#Player countdowns
func handlecountdowns(delta):
		cyote_time -= delta
		walljump_time -= delta
		dash_time -= delta
		redash_time -= delta
		next_block_time -= delta
		#stuntime -= delta
		#parry_time -= delta
		
		if dash_time <= 0 && dash_dir != 0:
			dash_dir = 0	#Clear our dash direction
			#setdashcollisions(false)
			redash_time = REDASH_WAIT
		
		attack_refresh -= delta
		if attack_refresh <=0: #reset our combo systems
			attack_presses = 0
			combo_counter = 0

func handlemovementcontacts():
	#Get our contacts======================================
	if !on_ground:
		on_wall = touchingwall()
		#This piece of logic promises to have a substantial number of hiccoughs, which we may want to end up changing
		#especially because it's handled as an interrupt...
		if on_wall != 0 && sign(move_dir) == -on_wall && dash_time <= 0:
			change_action_state("Actor_OnWall", false)
			#canceldash()	#stop our dash if we hit a wall
			facing_dir = on_wall #Set our players facing direction while on a wall
			jumps_left = 1 #reset our double jump counter
			dashes_left = 1 #reset our dash counter
	else:
		on_wall = 0
		walljump_time = 0
	
	#Check our object grounded========================================================================
	#use raycasts to see if we're colliding with the ground to give us a little jump buffer
	if $DowncastLeft.is_colliding() || $DowncastRight.is_colliding():
		jump_free = true
	else:
		jump_free = false
	
	if (is_on_floor()) && velocity.y  >= 0: #Only land on the ground when falling:	#check if we're standing on the ground is_on_floor() || 
		on_ground = true
		jumps_left = 1 #reset our double jump counter
		dashes_left = 1 #reset our dash counter
		cyote_time = MAX_CYOTETIME #Set our cyote time as we're not touching the ground
	else:	#character is airbourne
		on_ground = false

func setdashcollisions(is_dashing):
	set_collision_layer_bit(DASH_LAYER, !is_dashing)
	set_collision_mask_bit(DASH_LAYER, !is_dashing)

func take_damage(damageAmount, knockback, attackstun, instigator):
	.take_damage(damageAmount, knockback, attackstun, instigator)
	#And update our health bar!
	$Camera2D/HUD._on_health_updated((health/30.0) * 100.0, 30)

func _physics_process(delta):
	Global.playerpos = self.position

func check_drop_function():
	if $DowncastGround.is_colliding():
		if $DowncastGround.get_collider().has_method("player_fall_through"):
			$DowncastGround.get_collider().player_fall_through(self)
			return true
	
	return false

func set_drop_collision(is_dropping):
	set_collision_layer_bit(DROP_LAYER, !is_dropping)
	set_collision_mask_bit(DROP_LAYER, !is_dropping)

