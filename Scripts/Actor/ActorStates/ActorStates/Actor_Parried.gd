extends Actor_Hurt
class_name Actor_Parried

var combat_float = false	#Necessary here to avoid an error with the rest of the system as all our action nodes have got a bit too similar

func enter(_msg := {}) -> bool:
	base_actor.set_animation("parried")
	return true

func anim_finished(anim_name: String) -> void:
	if (anim_name == "hurt" || anim_name == "parried"):
		animation_cleared = true
		#print("Animation cleared")
		base_actor.change_action_state("Actor_OnGround", false)
