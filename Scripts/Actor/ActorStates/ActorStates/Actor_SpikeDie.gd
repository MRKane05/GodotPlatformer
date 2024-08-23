extends Actor_Die
class_name Actor_SpikeDie

#This is mostly intended for use with the player, and will have a respawn state
func anim_finished(anim_name: String) -> void:
	if (anim_name == "die"):
		animation_cleared = true
		base_actor.do_quick_respawn() #For the moment lets just do this
