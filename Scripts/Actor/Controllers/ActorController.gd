extends Node
class_name ActorController

export var ActorTarget := NodePath()
var targetactor# : Actor

export(float) var move_dir = 0 				#The direction we want to move in
export(float) var vertical_move_dir = 0
export(float) var facing_dir = 1
#export var DEADZONE = 0.2			#Children don't expose export variables due to a bug
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#Variables used by the player and ignored by the AI
var button_released = true

# Called when the node enters the scene tree for the first time.
func _ready():
	yield(owner, "ready")
	#Find our TargetActor as we can't export it
	targetactor = get_parent()# as Actor
	targetactor.controller = self

func on_take_damage(damageAmount, knockback, attackstun, on_damage_function, hurt_type, instigator):
	pass

func on_get_blocked(instigator):
	pass

func do_trigger_strike_callback(body, strike_action: String):
	pass

func anim_finished(anim_name: String):
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
