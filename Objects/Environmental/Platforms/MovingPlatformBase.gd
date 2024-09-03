extends switch_trigger_object
class_name moving_platform

onready var platform = $Platform
onready var tween = $MoveTween

var follow = Vector2.ZERO

export(float) var idle_duration = 1.0
export(Vector2) var move_to = Vector2(0,0)
export(float) var speed = 3.0 * 16.0 #Will it accept inline math?
export(bool) var needs_trigger = false

func _ready():
	if !needs_trigger:
		_init_tween()

func do_action():
	_init_tween()

func _init_tween():
	var duration = move_to.length()/speed
	tween.interpolate_property(self, "follow", Vector2.ZERO, move_to, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, idle_duration)
	tween.interpolate_property(self, "follow", move_to, Vector2.ZERO, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, idle_duration*2 + duration)
	tween.start()
	
func _physics_process(delta):
	platform.position = platform.position.linear_interpolate(follow, 0.075)

