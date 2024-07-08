extends Actor_Hurt
class_name Actor_Parried

var combat_float = false	#Necessary here to avoid an error with the rest of the system as all our action nodes have got a bit too similar

func enter(_msg := {}) -> bool:
	base_actor.set_animation("parried")
	return true
