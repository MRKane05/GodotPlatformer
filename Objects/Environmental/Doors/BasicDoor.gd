extends Node2D
class_name BasicDoor

func do_action():
	print ("Got action trigger")
	$AnimationPlayer.play("Open")
