extends CanvasLayer

onready var Global = get_node("/root/Global") #Collect and assign our globals for referencing

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_bar_progress(progress):
	$ProgressBar.value = progress
	
func change_scene(target_scene: String, current_scene, target_door) -> void:
	print("changing scene")
	$AnimationPlayer.play("dissolve")
	yield($AnimationPlayer, "animation_finished")
	#get_tree().change_scene(target_scene)
	
	var loader = ResourceLoader.load_interactive(target_scene)
	if loader == null:
		print("Resource loader unable to load the resource at path: " + target_scene)
		return
		
	while true:
		var err = loader.poll()
		if err == ERR_FILE_EOF:
			#Loading complete
			var resource = loader.get_resource()
			var resource_instance = resource.instance()
			get_tree().get_root().call_deferred("add_child", resource_instance)
			if target_door:
				resource_instance.call_deferred("set_player_door", target_door)
			#if target_door:
			#	new_scene.set_player_door(target_door)
			current_scene.queue_free()
			break
		if err == OK:
			#Still loading
			var progress = float(loader.get_stage())/loader.get_stage_count()
			print(progress)
			$dissolve_rect/ProgressBar.value = progress * 100 #.set_bar_progress(progress)
		else:
			print("Error while loading file")
			break
		
		yield(get_tree(), "idle_frame")	#Prevent frame from blocking bar
	$AnimationPlayer.play_backwards('dissolve')
	#Need a control command to release control to player following loading


