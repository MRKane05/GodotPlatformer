extends KinematicBody2D
class_name ObjectBase

#Essentially this is the bottom of the tree for anything that could be attackable. Naturally everything else branches off of this class
export(float) var current_knockback = 0
var stuntime = 0
export(float) var health = 30
var base_health = 30
var is_dead = false

func _ready():
	base_health = health	#So that we're starting on the right foot for our displays and systems

func dead():
	is_dead = true
	queue_free() #For the moment lets just vanish whatever dies

#Basic hurt function
func take_damage(damageAmount, knockback, attackstun, on_damage_function, hurt_type, instigator):
	current_knockback = knockback
	health -= damageAmount
	stuntime = 0.25	#Stun our enemy with the hit
	
	if health < 0:	#Don't call a hurt state if we should be dying. This'll create all sorts of horrible
		dead()
	else:
		match hurt_type:
			"hurt" : do_hurt()	#Call our hurt function
			"call" : pass		#Have the attached script call on the combat function handle the response from the actor
	
	if self.has_method(on_damage_function):
		call(on_damage_function)

func do_hurt():
	pass

func do_float():
	pass

func do_stun(knockback : float, stunamount : float, instigator):
	stuntime = stunamount

#Called for when we want to juggle something in the air
func strike_fall_hold(fall_hold_delay):
	pass

func is_within_range(dist: float, target: Vector2, base: Vector2):
	if abs(target.x-base.x) > dist:
		return false
	if abs(target.y-base.y) > dist:
		return false
	return true
