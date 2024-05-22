extends KinematicBody2D
class_name Collectable_Base
#Because collectables probably shouldn't be physics objects as they're prone to chewing up process

const GRAVITY = 500				#Gravity acceleration. Assume 60fps
const MAX_FALL_SPEED = 180		#Maxiumum falling speed

const FLOOR = Vector2(0, -1)	#The normal direction of the floor (used with move_and_slide system to see where collisions should happen with the ground)
const BURST_SPEED = 80
const BURST_VERTICAL = -600

const MOVE_THRESHOLD = 10		#At what point don't we bounce?
const BOUNCE_LOSS = 0.6			#How much velocity is lost with a bounce?

const COLLECT_RANGE = 24

var velocity = Vector2(0,0)
onready var Global = get_node("/root/Global") #Collect and assign our globals for referencing

var player_collected = false
const COLLECT_TIME_TOTAL = 0.75
var collect_time #Basically the time to hoover this up
var collect_delay = 1.25 #A small delay before these become collectable (basically I want them to burst)

func _ready():
	collect_time = COLLECT_TIME_TOTAL
	set_start_burst()

func set_start_burst():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	velocity = Vector2(rng.randf_range(-BURST_SPEED, BURST_SPEED), rng.randf_range(BURST_VERTICAL*0.75, BURST_VERTICAL))

func _physics_process(delta):
	if (!player_collected):
		velocity = handlefallfunctions(delta, velocity)
		var collision_info = move_and_collide(velocity*delta)
		if collision_info:
		#	if collision_info.collider.name == "Player":
		#		do_collect()
			velocity = velocity.bounce(collision_info.normal)*BOUNCE_LOSS
		
		collect_delay -= delta
		if collect_delay <= 0:
			check_player_collect()
	else:
		collect_time -= delta
		self.position = lerp(self.position, Global.playerpos, 1.0-collect_time/COLLECT_TIME_TOTAL)
		if collect_time <= 0:
			do_collect()

func do_collect():
	#We want to send information through to our player about what we've collected
	#and we need to play some sort of effect
	#plus we should destroy this object
	Global.Player.get_health(1)
	queue_free()

func check_player_collect():
	if self.position.distance_squared_to(Global.playerpos) < COLLECT_RANGE * COLLECT_RANGE:
		player_collected = true


func handlefallfunctions(delta, _velocity) -> Vector2:
	var relativegravity =  GRAVITY

	_velocity.y += relativegravity*delta		
	_velocity.y = clamp(_velocity.y, -MAX_FALL_SPEED, MAX_FALL_SPEED) #Axis are down positive. Giggity

	return _velocity

func _on_Area2D_body_entered(body):
	if body.name == "Player": #we've been collected by our player
		do_collect()
