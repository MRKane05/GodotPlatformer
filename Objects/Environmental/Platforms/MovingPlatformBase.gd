extends Node2D

onready var platform = $Platform
onready var tween = $MoveTween

var follow = Vector2.ZERO

export(float) var idle_duration = 1.0
export(Vector2) var move_to = Vector2(0,0)
export(float) var speed = 3.0 * 16.0 #Will it accept inline math?

func _ready():
	_init_tween()

func _init_tween():
	var duration = move_to.length()/speed
	tween.interpolate_property(self, "follow", Vector2.ZERO, move_to, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, idle_duration)
	tween.interpolate_property(self, "follow", move_to, Vector2.ZERO, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, idle_duration*2 + duration)
	tween.start()
	
func _physics_process(delta):
	platform.position = platform.position.linear_interpolate(follow, 0.075)
