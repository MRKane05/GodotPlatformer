extends Node2D

#Essentially this is a parent that'll handle the spawning of gems in the world when
#an enemy dies, and perhaps also some other group math to try and speed things up
onready var Global = get_node("/root/Global") #Collect and assign our globals for referencing
export (PackedScene) var HealthPickup

# Called when the node enters the scene tree for the first time.
func _ready():
	#This will be reset as we move between rooms
	Global.gemhandler = self

func spawn_collectables(start_position: Vector2, count: int):
	print("Spawning collectables")
	#for the moment we're just doing something to test
	for n in count:
		var b = HealthPickup.instance()
		self.add_child(b)
		b.position = start_position