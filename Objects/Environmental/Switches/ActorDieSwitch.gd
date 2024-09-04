extends Node2D

#essentially we need to keep a watch on a target object/actor to see if they die, and if they
#are dead to trigger the target object
export (NodePath) var target_actor
onready var targetactor:ObjectBase = get_node(target_actor)
export (NodePath) var target_switchable
onready var switchable:switch_trigger_object = get_node(target_switchable)
var bHasSwitched = false
#It would be better to call back through to us after we die from the Actorm, but I'm not sure that I care at this stage

func _process(delta):
	if !is_instance_valid(targetactor):	#This'll do for the moment
		if !bHasSwitched:	#as we're simply vanishing actors when they die at this stage
			bHasSwitched = true;
			if switchable && switchable.has_method("do_action"):
				switchable.do_action()
				
	#elif targetactor:
	#	if targetactor is ObjectBase && !bHasSwitched:
	#		if targetactor.is_dead:
	#			bHasSwitched = true;
	#			if switchable && switchable.has_method("do_action"):
	#				switchable.do_action()
