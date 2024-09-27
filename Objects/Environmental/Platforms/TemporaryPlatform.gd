extends StaticBody2D
#extends DropThroughPlatform
class_name TemporaryPlatform

#Should this be a fallthrough? Seems counter to what we really want

onready var collision = $CollisionShape2D
onready var area = $Area2D

var notification_player

export (NodePath) var _animation_player
onready var animation_player:AnimationPlayer = get_node(_animation_player)

var anim_playing = false

func _on_Area2D_body_exited(body):
	print("Body exited area")
	area.set_deferred("monitoring", false)
	if body.has_method("set_drop_collision"):
		notification_player.set_drop_collision(false)

func _on_Area2D_body_entered(body):
	#We need to start our fall counter
	if !anim_playing:
		animation_player.current_animation = "Drop"
		anim_playing = true

func _platform_reset():
	anim_playing = false
	animation_player.current_animation = "Idle"


