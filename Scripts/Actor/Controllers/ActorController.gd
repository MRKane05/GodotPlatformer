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

# Called when the node enters the scene tree for the first time.
func _ready():
	yield(owner, "ready")
	#Find our TargetActor as we can't export it
	targetactor = get_parent()# as Actor
	targetactor.controller = self
	print("Target Actor")
	print(targetactor)
	

func on_take_damage(damageAmount, knockback, attackstun, instigator):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
