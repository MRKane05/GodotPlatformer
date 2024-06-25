extends Area2D

func _on_LevelSpikes_body_entered(body):
	if body.has_method("touched_killspikes"):
		body.touched_killspikes()
