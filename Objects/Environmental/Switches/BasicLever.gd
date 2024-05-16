extends Node2D

var retrigger_time = 1
var can_trigger = true
var player_over = false

export (NodePath) var target_switchable
onready var switchable:BasicDoor = get_node(target_switchable)

func take_damage(damageAmount, knockback, attackstun, instigator):
	do_toggle()

func do_toggle():
	if can_trigger:
		$FlipNode.scale.x *=-1
		can_trigger = false
		$Timer.wait_time = retrigger_time #reset our timer
		print("Doing toggle")
		if switchable && switchable.has_method("do_action"):
			switchable.do_action()

func _on_Timer_timeout():
	can_trigger = true

#Handle our icon visibility
func _on_Area2D_body_entered(body):
	if body.name =="Player":
		$InteractionIcon.visible = true
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
		
