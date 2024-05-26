extends Interactable_Object
class_name LC_Door_Standard

export(String) var target_scene = ""	#Which scene does this door take us to?
export(String) var target_doorway= ""	#Which doorway should our player be put into with this load?

export (NodePath) var _scene_base		#This  needs to be set as I don't know how else we'd be sure to remove the scene this is associated with
onready var scene_base:Node2D = get_node(_scene_base)

func do_toggle():
	if	scene_base:
		LoadingScreen.change_scene(target_scene, scene_base, null) #load our first scene!
	else: #throw an error
		print("NO SCENE BASE ASSIGNED TO DOOR: " + self.get_name())
