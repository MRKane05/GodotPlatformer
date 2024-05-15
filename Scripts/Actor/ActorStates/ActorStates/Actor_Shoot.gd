extends ActorState
class_name Actor_Shoot

onready var shoot_marker = get_node("../../ShootMarker")

export (PackedScene) var Bullet

#It's becoming obvious that these should be moved somewhere more generic...
export(String) var fall_anim_name = "fall"
export(String) var move_anim_name = "run"
export(String) var idle_anim_name = "idle"

var target_vector = Vector2(1, 0)

var action_fall_hold = 0

func enter(_msg := {}) -> bool:
	shoot_marker.visible = true	#Turn our marker on
	action_fall_hold = 0.5 #How long until we stop setting the fall hold so that our charcter won't fall
	return true

func exit() -> bool: 
	shoot_marker.visible = false	#Turn our marker off
	return true

func interruptexit() -> bool: 
	shoot_marker.visible = false	#Turn our marker off
	return true
	
func physics_update(_delta: float, _velocity: Vector2, _move_dir: float) -> Vector2:
	action_fall_hold -= _delta
	
	if !base_actor.on_ground:
		base_actor.set_animation(fall_anim_name)
		if action_fall_hold > 0:
			base_actor.fall_hold = 0.25
	else:
		#animation handling
		if abs(_velocity.x) > 0:
			base_actor.set_animation(move_anim_name)
		else:
			base_actor.set_animation(idle_anim_name)

	#While we're on the ground we really only need to worry about movement and falling
	#_velocity = calculatehorizontalmovement(_delta, _velocity, base_actor.move_dir)
	#We want our actor to stand and shoot, allowing the player to aim with the left stick while
	#holding down Triangle, so lets do the decelerate thing
	if (_velocity.x > 0):
		_velocity.x = min(_velocity.x - base_actor.MOVE_DECEL*_delta, 0)
	if (_velocity.x < 0):
		_velocity.x = max(_velocity.x + base_actor.MOVE_DECEL*_delta, 0)
	#Do our fall stuff
	_velocity = handlefallfunctions(_delta, _velocity)	#Apply our gravity
	
	if Input.is_action_pressed("ui_select"):
		do_weapon_aim()
	else:
		do_shoot()
		base_actor.change_action_state("Actor_OnGround", false)
	
	return _velocity

func do_shoot():
	var b = Bullet.instance()
	base_actor.owner.add_child(b)
	#b.transform = $Muzzle.global_transform
	b.transform = base_actor.transform #.position + target_vector #So in theory we'll be spawning this outside of the player?
	#func setup_projectile(new_direction: Vector2, new_instigator):
	if target_vector.length() > 0.2: #This is a valid shot
		b.setup_projectile(target_vector, base_actor)
	else:
		b.setup_projectile(Vector2(base_actor.facing_dir, 0), base_actor)
	pass

func do_weapon_aim():
	var xAxis = Input.get_joy_axis(0, JOY_ANALOG_LX)
	var yAxis = Input.get_joy_axis(0, JOY_ANALOG_LY)
	
	target_vector = Vector2(xAxis, yAxis)
	target_vector = target_vector.normalized()
	
	#Elute the angle we should be aiming our sprite at
	var target_angle = atan2(yAxis, xAxis)
	
	shoot_marker.rotation  = target_angle
