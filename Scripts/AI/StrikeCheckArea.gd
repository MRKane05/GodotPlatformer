extends Area2D
class_name StrikeCheckArea

func set_collision_enabled(state: bool):
	$CollisionShape2D.disabled = !state
