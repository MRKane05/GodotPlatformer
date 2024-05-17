extends Node2D

var retrigger_time = 1
var can_trigger = true
var player_over = false
export var toggle_once = false
var disabled = false

export (NodePath) var target_switchable
onready var switchable:BasicDoor = get_node(target_switchable)

func take_damage(damageAmount, knockback, attackstun, instigator):
	do_toggle()

func do_toggle():
	if can_trigger && ! disabled:
		$FlipNode.scale.x *=-1
		can_trigger = false
		$Timer.wait_time = retrigger_time #reset our timer
		$Timer.start()
		print("Doing toggle")
		if switchable && switchable.has_method("do_action"):
			switchable.do_action()
		if toggle_once:
			disabled = true
			$InteractionIcon.visible = false	#Turn off our icon after toggling this switch

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
		
