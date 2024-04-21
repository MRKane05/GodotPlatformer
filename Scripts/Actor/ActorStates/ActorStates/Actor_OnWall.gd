extends ActorState
class_name Actor_OnWall
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func enter(_msg := {}) -> bool:
	base_actor.set_animation("wallslide")
	return true

# Virtual function. Corresponds to the `_process()` callback.
func physics_update(_delta: float, _velocity: Vector2, _move_dir: float) -> Vector2:
	#.update(_delta) #Call our super
	
	#While we're on the ground we really only need to worry about movement and falling
	_velocity = calculatehorizontalmovement(_delta, _velocity, base_actor.move_dir)
	_velocity = handlewallslidefunctions(_delta, _velocity)	#Apply our gravity
	return _velocity

func handlewallslidefunctions(delta, velocity) -> Vector2:
	#Implement gravity===========================================================
	var relativegravity = base_actor.GRAVITY
	if velocity.y >0:
		relativegravity = base_actor.GRAVITY*base_actor.GRAVITYMULTIPLIER
	velocity.y += relativegravity*delta 
	
	#Clamp our fallspeed so that we don't keep accellerating because it's not fun
	var maxFallSpeed = base_actor.MAX_FALL_SPEED
	if base_actor.on_wall != 0:
		if sign(base_actor.on_wall) == -sign(base_actor.move_dir): #If we're on a wall have us "hold" to fall slower
			maxFallSpeed =  base_actor.WALL_SLIDE_SPEED/3	#we're on a wall so fall slowly
		else:
			maxFallSpeed = base_actor.WALL_SLIDE_SPEED
	velocity.y = clamp(velocity.y, base_actor.JUMP_POWER, maxFallSpeed) #Axis are down positive. Giggity
	
	if base_actor.on_ground:	#we're at the bottom of the wall
		base_actor.change_action_state("Actor_OnGround", false)
	elif base_actor.on_wall == 0: #We're off our wall so lets revert to our standard state
		base_actor.change_action_state("Actor_OnGround", false)
	
	return velocity
