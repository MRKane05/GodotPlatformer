extends Node

#Global system reference  variables
var playerpos = Vector2(0,0)	#the position of our player, will be set by the player script
var PlayerCollider = null #: KinematicBody2D
var Player = null #: Node

var gemhandler: Node

#Details for scene loading and handling
var current_loaded_scene: Node

var debug_state = 0 #1=ActorStates, 2 = AI states, 0 = off

#Player settings for moving between scenes
var player_health = 30
var player_shots = 0
var can_wallgrab = false
var player_airdashes = 0
var player_airjumps = 0

#And some loading details for reloading the level
var target_scene = ""
var target_door = ""
