extends Actor
class_name Actor_Enemy

export(Vector2) var viewlimit = Vector2(50,100)
export(float) var player_contact_hurt = -1 #if this is above zero we'll hurt the player when we contact
export(float) var player_contact_knockback = 20

var strike_check_areas = []	# All or our strike check areas that'll be collated at start

export(float) var initial_dir = 1	#What's our initial facing direction?

# Recursive function to get all descendants with the "StrikeCheckArea" script
func get_strike_check_areas_recursive(node: Node) -> Array:
	var _strike_check_areas = []
	for child in node.get_children():
		if child is StrikeCheckArea: #.get_script() == preload("res://path/to/StrikeCheckArea.gd"):
			_strike_check_areas.append(child)
		_strike_check_areas += get_strike_check_areas_recursive(child)
	return _strike_check_areas

func _ready():
	yield(owner, "ready")
	._ready() #Do our super
	#Get all the objects that are using a StrikeCheckArea
	strike_check_areas = get_strike_check_areas_recursive(self)


func dead():
	#Mostly for testing
	#if Global.gemhandler:
	# we need to turn off our collider while we're dying so our player can move
	$CollisionShape2D.disabled = true
	Global.gemhandler.call_deferred("spawn_collectables", self.position, 5)		
	.dead()


#Player countdowns
func handlecountdowns(delta):
	.handlecountdowns(delta)

func handlemovementcontacts():
	#Super simplified contacts return
	# || $FlipElements/EdgeCheck.is_colliding()) 
	if (is_on_floor() && velocity.y  >= 0): #Only land on the ground when falling:	#check if we're standing on the ground is_on_floor() || 
		on_ground = true
	else:	#character is airbourne
		on_ground = false

func is_at_edge():
	if is_on_wall():
		#print ("hit wall")
		return true
	
	return !$FlipElements/EdgeCheck.is_colliding()	#Flip this so we get a positive return if we're at an edge while walking

func backed_to_edge():
	return !$FlipElements/EdgeCheck_Back.is_colliding()
	
#Dirt basic function to see if we can see our player (exclusion based)
func seeplayer():
	if sign(Global.playerpos.x - self.position.x) * facing_dir > 0: #our player is in "front" of this actor
		if playerwithinlimit(viewlimit):	#See if we're within our box of "caring about"
			$PlayerRayCheck.enabled = true #Turn our our raycast
			$PlayerRayCheck.cast_to = Global.playerpos -  self.position
			if $PlayerRayCheck.is_colliding():
				return ($PlayerRayCheck.get_collider() == Global.Player)
		else:
			$PlayerRayCheck.enabled = false
	return false

#This will need to be linked up manually for every enemy type
func body_entered_damage_area(body):
	if player_contact_hurt > 0:
		if body is Actor_Player:
			#take_damage(damageAmount, knockback, attackstun, on_damage_function, hurt_type, instigator):
			body.take_damage(player_contact_hurt, player_contact_knockback * facing_dir, 1, "", "hurt", self)

#if our attack is blocked this is returned
#func get_blocked(instigator):
#	pass

#This function enables the strike triggers which will then report back to the AI so we can play the strike that suits (guided by art)
func set_strike_triggers(state: bool):
	for trigger in strike_check_areas:
		trigger.set_collision_enabled(state)
