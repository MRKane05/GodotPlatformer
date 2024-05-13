extends Area2D
onready var  area = $Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	#set_deferred("monitoring", true)
	pass

func _on_Area2D_body_entered(body):
	if body.has_method("set_quick_respawn_location"):
		print("player enetered fast respawn point")
		body.set_quick_respawn_location()
