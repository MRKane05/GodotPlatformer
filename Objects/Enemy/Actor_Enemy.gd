extends Actor
class_name Actor_Enemy

export(Vector2) var viewlimit = Vector2(50,100)

#A stack of variables which won't be configerable...
#const MAX_SPEED_RUN = 80			#Basic movement speed
#const MAX_SPEED_DASH = 150			#Also our sprinting speed
#const MAX_SPEED_SPRINT = 130		#Faster than run, slower than dash, is our sprint state
#const WALLJUMP_HSP = 50			#Horizontal speed we jump off walls
#const MOVE_ACCEL = 300		#Movement acceleration, delta time affected
#const MOVE_DECEL = 300		#Delta time affected also
#const GRAVITY = 500				#Gravity acceleration. Assume 60fps
const GRAVITYMULTIPLIER = 1.5	#The suggested value for marioesque gravity behavior
#const WALL_SLIDE_SPEED = 50	#if we're not holding against the wall how quickly do we slide down?
#const MAX_FALL_SPEED = 180		#Maxiumum falling speed
#const JUMP_POWER = -200			#Jump velocity
#const WALLJUMP_POWER = -180		#Vertical jump off walls
#const MAX_CYOTETIME = 0.15		#How long does our cyote time last for after leaving the ground?
#const FLOOR = Vector2(0, -1)	#The normal direction of the floor (used with move_and_slide system to see where collisions should happen with the ground)
#const WALLJUMP_LOCKTIME = 0.3	#The duration that we'll "lose" movement control following a walljump to stop the player from turning and latching straight back on
#const DASH_DURATION = 0.4		#The duration that we'll dash for
#const REDASH_WAIT = 0.5			#How long we have to wait until we can dash again


#var on_ground = false	#Are we grounded by touching or with raycasts?
#var on_wall = 0			#Wallbased raycasts to allow for wallgrabs
#var dash_dir = 0	#The direction -1, 0, 1 that we're dashing in, also used as a check to see if we're dashing dash_dir == 0
#var facing_dir = 1 #Which direction should our sprite nominally be facing?
#var sprite_flipped = false	#The direction of our sprite as defined by the different functions
#var jumps_left = 1	#how many jumps we've got left. Reset on contact with wall or floor, or bonus
#var dashes_left = 1	#how many dashes we've got left. Reset on contact with wall, floor, or bonus

#var combo_counter = 0
#var attack_presses = 0
#var attack_refresh = 0
#var is_attacking = false

#var cyote_time = 0	#Time that we'll be able to jump after leaving a platform
var walljump_time = 0 #Control lock time based off of when we jumped off a wall
#var dash_time = 0 #Time remaining on our dash (might be handled elsewhere)
#var dash_hold = false
#var redash_time = 0 #Time until we can dash again
#func _ready():
#	_ready()
#	move_dir = 1

#Player countdowns
func handlecountdowns(delta):
	pass

func handlemovementcontacts():
	#Super simplified contacts return
	if is_on_floor(): #Only land on the ground when falling:	#check if we're standing on the ground is_on_floor() || 
		on_ground = true
	else:	#character is airbourne
		on_ground = false

func is_at_edge():
	if is_on_wall():
		return true
	return !$FlipElements/EdgeCheck.is_colliding()	#Flip this so we get a positive return if we're at an edge while walking

func backed_to_edge():
	return !$FlipElements/EdgeCheck_Back.is_colliding()
	
#Dirt basic function to see if we can see our player (exclusion based)
func seeplayer():
	if sign(Global.playerpos.x - self.position.x) * facing_dir > 0: #our player is in "front" of this actor
		
		if playerwithinlimit():	#See if we're within our box of "caring about"
			$PlayerRayCheck.enabled = true #Turn our our raycast
			$PlayerRayCheck.cast_to = Global.playerpos -  self.position
			if $PlayerRayCheck.is_colliding():
				return ($PlayerRayCheck.get_collider() == Global.Player)
		else:
			$PlayerRayCheck.enabled = false
	return false

#Check and see if the player is within our "attention zone" (this is to save on raycasts)
func playerwithinlimit():
	if abs(self.position.x - Global.playerpos.x) < viewlimit.x && abs(self.position.y - Global.playerpos.y) < viewlimit.y:
		return true
	return false
