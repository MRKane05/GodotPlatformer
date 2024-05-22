extends Collectable_Base
class_name pickup_bullet

func do_collect():
	#We want to send information through to our player about what we've collected
	#and we need to play some sort of effect
	#plus we should destroy this object
	Global.Player.change_shots(1)
	queue_free()
