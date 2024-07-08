extends ActorState
class_name Actor_Block

#Copied from the combat section. This'll need thinking over, but for the moment lets just do something!
var move_while_blocking = false
var combat_float = false
var reblock_time = 0.75 #Just a number I pulled out of my ass
var block_strength = 12 #How much damage can this block soak before it's broken and the remaining damage is passed back onto the actor?


export(float) var parry_chance = 1 #What are the odds we'll have a successful parry?
export(float) var parry_time = 0.5	#How long should our parry last for?
export(float) var parry_knockback = 20	#How forceful is our parry knockback
export(float) var parry_stun = 0.75	#How long is our parry stun?


var parry_left = 0.5 #How much time is left on our parry?
export (PackedScene) var parry_effect #What effect do we play when we parry successfully?

export (NodePath) var _parry_point
var parry_point:Node # = get_node(_parry_point)

func enter(_msg := {}) -> bool:
	if _parry_point && !parry_point:
		parry_point = get_node(_parry_point)
	
	if base_actor.next_block_time > 0:
		return false #We can't enter our state until this has been ticked down to prevent spamming parry
	
	block_strength = 12
	#Can we block in the air? If we go in the "air combat" direction then it'd make sense that we can
	base_actor.set_animation("block")
	parry_left = parry_time
	return true

func physics_update(_delta: float, _velocity: Vector2, _move_dir: float) -> Vector2:
	base_actor.next_block_time = reblock_time
	parry_left -= _delta
	
	#Check to see if we're stopping our block (this can also be handled elsewhere). This is player only code
	if base_actor is Actor_Player:
		if !Input.is_action_pressed("ui_shift_right"): #We're not holding down block anymore to transition back to our standard state
			base_actor.change_action_state("Actor_OnGround", false)
	
	if move_while_blocking || !base_actor.on_ground:
		#While we're on the ground we really only need to worry about movement and falling
		_velocity = calculatehorizontalmovement(_delta, _velocity, base_actor.move_dir)
		_velocity = handlefallfunctions(_delta, _velocity)	#Apply our gravity
	else:
		if combat_float: #this begs to have yet more expansion done
			_velocity = Vector2(0,0)
		_velocity = Vector2(0,0)
	return _velocity

#Basic hurt function
func handle_take_damage(damageAmount, knockback, attackstun, on_damage_function, hurt_type, instigator):
	block_strength -= damageAmount
	if block_strength <= 0: #our block has been broken
		base_actor.change_action_state("Actor_Hurt", false)	#That'll do for the moment, but we could really do with a block state fail
		return false
	
	#of course if we're being attacked from behind we should take damage. That'll be something to get in
	if sign(knockback) + sign(base_actor.facing_dir) != 0: #See if the damage is coming from the direction we're not facing
		#We need to call the super from the function that called this...
		return false
		
	var rng = RandomNumberGenerator.new()
	rng.randomize()	
	if parry_left > 0 && parry_chance > rng.randf(): #While not all attacks will be parryable (is that a word?) lets just roll with the basics for now
		instigator.get_parried(parry_knockback*base_actor.facing_dir, parry_stun, base_actor)
		print("Did Parry")
		do_parry_effect()
		return true
	
	instigator.get_blocked(base_actor)
	return true
	#Don't take damage while blocking, but instead erode our block state

func do_parry_effect():
	if parry_effect && parry_point:
		var p_effect = parry_effect.instance()
		base_actor.owner.add_child(p_effect)
		p_effect.global_position = parry_point.global_position #Position our effect
		p_effect.scale = Vector2(base_actor.facing_dir, 1)	#Make sure our parry effect is going in the correct direction
		#And we'll have to set our direction here too
