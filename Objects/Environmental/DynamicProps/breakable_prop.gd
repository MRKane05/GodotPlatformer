extends ObjectBase
class_name breakable_prop

export(Resource) var hit_sound
export(Resource) var destroy_sound

export(Resource) var destroyed_sprite

func do_hurt():
	if !$AudioStreamPlayer2D.is_playing():
		$AudioStreamPlayer2D.stream = hit_sound
		$AudioStreamPlayer2D.play()

func dead():
	if !$AudioStreamPlayer2D.is_playing():
		$AudioStreamPlayer2D.stream = hit_sound
		$AudioStreamPlayer2D.play()
	#Disable all our colliders
	for child in self.get_children ():
		if "Collision" in child.get_name():
			child.set_deferred("disabled",true)
	
	#Swap our sprite to a broken one
	$Sprite.texture = destroyed_sprite
