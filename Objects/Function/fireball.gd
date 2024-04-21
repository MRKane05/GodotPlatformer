extends Area2D

const SPEED = 100
var velocity = Vector2()
var direction = 1	#our sign direction for controlling how the fireball works

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_fireball_direction(newdir):
	direction = newdir
	if (direction == -1):
		$AnimatedSprite.flip_h = true;	#flip our spirte direction with the new direction


func _physics_process(delta):
	velocity.x = SPEED * delta * direction
	translate(velocity)	#faster and simpler than move and slide
	#play any animation associated with the fireball


#notification for when the fireball leaves the screen
func _on_VisibilityNotifier2D_screen_exited():
	queue_free() #destroy this object and clear from memory


#called when the fireball collides with something
func _on_fireball_body_entered(body):
	#check to see what we've hit, and if we want to damage it
	if "Enemy" in body.name:
		body.dead()		#Damage the body that we've hit
	
	queue_free()	#destroy fireball
