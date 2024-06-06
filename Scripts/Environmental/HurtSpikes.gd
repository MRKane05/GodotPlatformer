extends Area2D

export(float) var damage = 5
export(float) var knockback = 20

func _on_LevelSpikes_body_entered(body):
	print ("Character touched hurtspikes")
	if body is Actor:
		#func take_damage(damageAmount, knockback, attackstun, instigator):
		#Somehow we've got to get the rotation of our tile to figure out which direction to push the player...
		body.take_damage(damage, knockback, 1, "", self)

