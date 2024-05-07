extends Actor_Hurt
class_name Actor_Parried

func enter(_msg := {}) -> bool:
	base_actor.set_animation("parried")
	return true
