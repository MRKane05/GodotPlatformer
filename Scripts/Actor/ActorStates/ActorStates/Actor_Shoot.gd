extends ActorState
class_name Actor_Shoot

export (PackedScene) var Bullet

#It's becoming obvious that these should be moved somewhere more generic...
export(String) var fall_anim_name = "fall"
export(String) var move_anim_name = "run"
export(String) var idle_anim_name = "Aim_Standing"

export (NodePath) var _shoot_marker
onready var shoot_marker:Node2D = get_node(_shoot_marker)

export (NodePath) var _aiming_arm
onready var aiming_arm:Node2D = get_node(_aiming_arm)

var target_vector = Vector2(1, 0)

var action_fall_hold = 0.25

var target_hold_time = 0.25	#How long do we hold the "bang!" frame for?
var fire_release = false
var hold_time = 0

func enter(_msg := {}) -> bool:
	if base_actor.pistol_shots <= 0:
		return false
	shoot_marker.visible = true	#Turn our marker on
	action_fall_hold = 0.5 #How long until we stop setting the fall hold so that our charcter won't fall
	fire_release = false
	return true

func exit() -> bool: 
	shoot_marker.visible = false	#Turn our marker off
	aiming_arm.visible = false
	return true

func interruptexit() -> bool: 
	shoot_marker.visible = false	#Turn our marker off
	aiming_arm.visible = false
	return true
	
func physics_update(_delta: float, _velocity: Vector2, _move_dir: float) -> Vector2:
	action_fall_hold -= _delta
	hold_time -= _delta
	
	if !base_actor.on_ground:
		base_actor.set_animation(fall_anim_name)
		if action_fall_hold > 0:
			base_actor.fall_hold = max(action_fall_hold, base_actor.fall_hold)
	else:
		#animation handling
		if abs(_velocity.x) > 0:	#If we're moving we shouldn't be aiming
			base_actor.set_animation(move_anim_name)
			aiming_arm.visible = false
		else:
			base_actor.set_animation(idle_anim_name)
			aiming_arm.visible = true

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
	elif Input.is_action_just_released("ui_select"):	#Logically we've done a release? Ok, lets overprogramme this
		do_shoot()
		hold_time = target_hold_time
		fire_release = true
	
	
	if fire_release:
		if hold_time <= 0:
			base_actor.change_action_state("Actor_OnGround", false)
	
	return _velocity

func do_shoot():
	#This is where we'd want to find our best target and do a little auto-aiming for our player
	var b = Bullet.instance()
	base_actor.owner.add_child(b)
	#b.transform = $Muzzle.global_transform
	b.transform = base_actor.transform #.position + target_vector #So in theory we'll be spawning this outside of the player?
	b.global_position = aiming_arm.global_position + target_vector * 12.0 #Position so we'll not be coming from the center of the sprite
	
	#func find_best_target_position(aim_dir: Vector2, base_position: Vector2):
	var aimed_angle = base_actor.find_best_target_position(target_vector, base_actor.position)
	
	#func setup_projectile(new_direction: Vector2, new_instigator):
	if aimed_angle.length() > 0.2: #This is a valid shot
		b.setup_projectile(aimed_angle, base_actor)
	else:
		b.setup_projectile(Vector2(base_actor.facing_dir, 0), base_actor)
	
	base_actor.change_shots(-1)

func do_weapon_aim():
	var xAxis = Input.get_joy_axis(0, JOY_ANALOG_LX)
	var yAxis = Input.get_joy_axis(0, JOY_ANALOG_LY)
	
	target_vector = Vector2(xAxis, yAxis)
	target_vector = target_vector.normalized()
	
	#Elute the angle we should be aiming our sprite at
	var target_angle = atan2(yAxis, xAxis)
	if  base_actor.facing_dir < 0:
		target_angle = 3.1415 - target_angle
	#shoot_marker.rotation  = target_angle #This will be handled by the shoulder rotation now
	aiming_arm.rotation = target_angle
