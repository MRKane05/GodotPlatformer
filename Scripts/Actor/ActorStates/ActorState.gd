extends Node
class_name ActorState

var base_actor = null

# Virtual function. Receives events from the `_unhandled_input()` callback.
func handle_input(_event: InputEvent) -> void:
	pass


# Virtual function. Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	pass


# Virtual function. Corresponds to the `_physics_process()` callback.
# Which is great, but we need to know what our user wants us to be doing
func physics_update(_delta: float, _velocity: Vector2, _move_dir: float) -> Vector2:
	return _velocity #We'll change our velocity in this point as necessary


# Virtual function. Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> bool:
	return true

# Virtual function. Called by the state machine before changing the active state. Use this function
# to clean up the state.
func exit() -> bool: #There's a possibility that we won't be able to let the player do what they want to do
	return true

# Virtual function. Called by the state machine as an interrupt before changing the active state. Use this function
# to clean up the state.
func interruptexit() -> bool: #If an interrupt happens (take damage, hit wall) is this action ok with handing over (as exit may have failed)
	return true

# Virtual function. Corresponds to the `_process()` callback.
func anim_finished(anim_name: String) -> void:
	pass

#Assorted helper functions for handling our movement#The logic for calculating the movement values for our object
func calculatehorizontalmovement(delta: float, velocity: Vector2, move_dir: float) -> Vector2:
	#And a checker to see if we need to wait until we've finished our animation
	#print(dash_hold)
	if move_dir != 0 && base_actor.walljump_time <=0: #Handle our standard movement
			velocity.x += base_actor.MOVE_ACCEL * delta * move_dir	#directional acceleration
			var maxspeed = base_actor.MAX_SPEED_RUN

			velocity.x = clamp(velocity.x, -maxspeed, maxspeed)
	elif base_actor.walljump_time <=0 || base_actor.on_ground:	#Handle our stopping, but only if we're not walljumping
		if (velocity.x > 0):
			velocity.x = min(velocity.x - base_actor.MOVE_DECEL*delta, 0)
		if (velocity.x < 0):
			velocity.x = max(velocity.x + base_actor.MOVE_DECEL*delta, 0)
	return velocity

func handlefallfunctions(delta, velocity) -> Vector2:
	#Implement gravity===========================================================
	#var relativegravity = lerp(MIN_GRAVITY, GRAVITY, abs(velocity.y)/GRAVITY)
	var relativegravity = base_actor.GRAVITY
	if velocity.y >0:
		relativegravity = base_actor.GRAVITY*base_actor.GRAVITYMULTIPLIER
	velocity.y += relativegravity*delta 
	
	#Clamp our fallspeed so that we don't keep accellerating because it's not fun
	var maxFallSpeed = base_actor.MAX_FALL_SPEED
	velocity.y = clamp(velocity.y, base_actor.JUMP_POWER, maxFallSpeed) #Axis are down positive. Giggity
	return velocity
