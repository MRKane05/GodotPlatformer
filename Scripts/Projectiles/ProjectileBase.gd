extends Area2D

var direction = Vector2(100,100) #This is direction as well as speed
var damageAmount = 5
var knockback = 20

var speed = 500
var instigator = null #This will have to be set to our player

func setup_projectile(new_direction: Vector2, new_instigator):
	direction = new_direction
	instigator = new_instigator
	#of course we'll need collision layer things in here too, but for the moment we'll not worry about it

func _physics_process(delta):
	position += direction * speed * delta

func _on_Area2D_body_entered(body):
	
	if body.name == "Player":
		pass
	else:
		if body.is_in_group("Enemy"): #So we've got to figure out if we've hit something that's not the player...
			#body.queue_free()
			if body.has_method("take_damage"):	#if this can be handled by the action state then do so
				body.take_damage(damageAmount, direction.x*knockback, 3, "", instigator)
		
		queue_free()
	

