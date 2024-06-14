extends Node

#Global system reference  variables
var playerpos = Vector2(0,0)	#the position of our player, will be set by the player script
var PlayerCollider = null #: KinematicBody2D
var Player = null #: Node

var gemhandler: Node

#Details for scene loading and handling
var current_loaded_scene: Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
