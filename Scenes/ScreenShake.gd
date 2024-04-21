extends Node2D

var current_shake_priority = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func move_camera(vector):
	get_parent().get_node("Player").get_node("Camera2D").offset = Vector2(rand_range(-vector.x, vector.x), rand_range(-vector.y, vector.y))

func screen_shake(shake_length, shake_power, shake_priority):
	if (shake_priority > current_shake_priority):
		current_shake_priority = shake_priority
		#Giant tween command!
		$Tween.interpolate_method(self, "move_camera", Vector2(shake_power, shake_power), Vector2(0,0), shake_length, Tween.TRANS_SINE, Tween.EASE_OUT, 0)
		$Tween.start()	#Start our Tween command


func _on_Tween_tween_all_completed():
	current_shake_priority = 0 #reset our shake priority after finishing a screen shake
