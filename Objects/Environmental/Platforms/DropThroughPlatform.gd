extends StaticBody2D


onready var collision = $CollisionShape2D
onready var  area = $Area2D

var notification_player

func player_fall_through(this_player):
	notification_player = this_player
	area.set_deferred("monitoring", true)


func _on_Area2D_body_exited(body):
	area.set_deferred("monitoring", false)
	if body.has_method("set_drop_collision"):
		notification_player.set_drop_collision(false)