extends Node2D
class_name Interactable_Object

var can_trigger = true
var player_over = false
var disabled = false

func take_damage(damageAmount, knockback, attackstun, instigator):
	pass

func do_toggle():
	pass

func _on_Timer_timeout():
	can_trigger = true
	$Timer.stop() #We don't want this getting triggered again

#Handle our icon visibility
func _on_Area2D_body_entered(body):
	if body.name =="Player":
		$InteractionIcon.visible = !disabled
		player_over = true

func _on_Area2D_body_exited(body):
	if body.name =="Player":
		$InteractionIcon.visible = false
		player_over = false

func _process(delta):
	#Look to see if we've got an interaction action while the player is over this switch
	if player_over:
		if Input.is_action_pressed("ui_up") || Input.get_joy_axis(0, JOY_ANALOG_LY) < -0.9:
			do_toggle()
		

func _on_InteractionArea_body_entered(body):
	if body.name =="Player":
		$InteractionIcon.visible = !disabled
		player_over = true


func _on_InteractionArea_body_exited(body):
	if body.name =="Player":
		$InteractionIcon.visible = false
		player_over = false
