extends ActorState
class_name Actor_Block

#Copied from the combat section. This'll need thinking over, but for the moment lets just do something!
var move_while_blocking = false
var combat_float = false
var reblock_time = 0.75 #Just a number I pulled out of my ass

var parry_time = 1.0	#How long should our parry last for?

func enter(_msg := {}) -> bool:
	if base_actor.next_block_time > 0:
		return false #We can't enter our state until this has been ticked down to prevent spamming parry

	#Can we block in the air? If we go in the "air combat" direction then it'd make sense that we can
	base_actor.set_animation("block")
	return true

func physics_update(_delta: float, _velocity: Vector2, _move_dir: float) -> Vector2:
	base_actor.next_block_time = reblock_time
	parry_time -= _delta
	#Check to see if we're stopping our block (this can also be handled elsewhere)
	if !Input.is_action_pressed("ui_shift_right"): #We're not holding down block anymore to transition back to our standard state
		base_actor.change_action_state("Actor_OnGround", false)
	
	if move_while_blocking:
		#While we're on the ground we really only need to worry about movement and falling
		_velocity = calculatehorizontalmovement(_delta, _velocity, base_actor.move_dir)
		_velocity = handlefallfunctions(_delta, _velocity)	#Apply our gravity
	else:
		if combat_float: #this begs to have yet more expansion done
			_velocity = Vector2(0,0)
		_velocity = Vector2(0,0)
	return _velocity

#Basic hurt function
func handle_take_damage(damageAmount, knockback, attackstun, instigator):
	#of course if we're being attacked from behind we should take damage. That'll be something to get in
	if sign(knockback) + sign(base_actor.facing_dir) != 0: #See if the damage is coming from the direction we're not facing
		#We need to call the super from the function that called this...
		return false
	
	if (parry_time > 0): #While not all attacks will be parryable (is that a word?) lets just roll with the basics for now
		instigator.get_parried(20*base_actor.facing_dir, 3, base_actor)
		print("Did Parry")
		return true
	
	return true
	#Don't take damage while blocking, but instead erode our block state
