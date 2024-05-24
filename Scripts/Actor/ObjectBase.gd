extends KinematicBody2D
class_name ObjectBase

#Essentially this is the bottom of the tree for anything that could be attackable. Naturally everything else branches off of this class
export(float) var current_knockback = 0
var stuntime = 0
export(float) var health = 30
var is_dead = false

func dead():
	is_dead = true
	queue_free() #For the moment lets just vanish whatever dies

#Basic hurt function
func take_damage(damageAmount, knockback, attackstun, instigator):
	current_knockback = knockback
	health -= damageAmount
	stuntime = 0.25	#Stun our enemy with the hit
	
	if health < 0:	#Don't call a hurt state if we should be dying. This'll create all sorts of horrible
		dead()
	else:
		do_hurt()

func do_hurt():
	pass

func do_stun(knockback : float, stunamount : float, instigator):
	stuntime = stunamount
