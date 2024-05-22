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

var velocity = Vector2(0,0)

func _ready():
	set_start_burst()

func set_start_burst():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	velocity = Vector2(rng.randf_range(-BURST_SPEED, BURST_SPEED), rng.randf_range(BURST_VERTICAL*0.75, BURST_VERTICAL))

func _physics_process(delta):
	velocity = handlefallfunctions(delta, velocity)
	var collision_info = move_and_collide(velocity*delta)
	if collision_info:
		velocity = velocity.bounce(collision_info.normal)*BOUNCE_LOSS


	
func handlefallfunctions(delta, _velocity) -> Vector2:
	var relativegravity =  GRAVITY

	_velocity.y += relativegravity*delta		
	_velocity.y = clamp(_velocity.y, -MAX_FALL_SPEED, MAX_FALL_SPEED) #Axis are down positive. Giggity

	return _velocity
