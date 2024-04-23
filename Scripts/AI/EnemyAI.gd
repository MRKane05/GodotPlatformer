extends ActorController
class_name EnemyAI

func _process(delta):
	#keep an eye out for having to change movement directions
	if !targetactor.is_at_edge():
		move_dir *= -1
		facing_dir *= -1
		
	targetactor.set_move_dir(move_dir, facing_dir)
