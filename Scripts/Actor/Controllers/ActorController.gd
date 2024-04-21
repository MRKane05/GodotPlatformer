extends Node
class_name ActorController

export var ActorTarget := NodePath()
var targetactor : Actor

var move_dir = 0 				#The direction we want to move in
var facing_dir = 1
#export var DEADZONE = 0.2			#Children don't expose export variables due to a bug
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	yield(owner, "ready")
	#Find our TargetActor as we can't export it
	targetactor = get_parent() as Actor
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
