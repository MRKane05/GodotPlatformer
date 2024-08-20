extends Area2D
class_name StrikeCheckArea

var strike_timer = 0
export(Vector2) var strike_delay_duration = Vector2(0.25,0.5) #How long we have to wait before we can consider our collisions enabled? 
var targetState = false	#What we intend to change to
var targetDelay = 0.5

func set_collision_enabled(state: bool):
	if (state):
		targetState = true;
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		targetDelay = rng.randf_range(strike_delay_duration.x, strike_delay_duration.y)
	else:
		$CollisionShape2D.disabled = !state
	
	strike_timer = 0 #Reset our strike timer to zero

func _process(delta):
	strike_timer += delta
	if strike_timer > targetDelay && targetState:	#Turn our strike area on
		$CollisionShape2D.disabled = false
