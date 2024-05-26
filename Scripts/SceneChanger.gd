extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func goto_scene(path, current_scene):
	var loader = ResourceLoader.load_interactive(path)
	
	if loader == null:
		print("Resource loader unable to load the resource at path: " + path)
		return
	var loading_screen = load("res://Scenes/LoadingScreen.tscn").instance()
	print (loading_screen)
	
		
	#var loading_screen = ref_loading_screen.instance()
	get_tree().get_root().call_deferred("add_child", loading_screen)
	
	#Our load loop
	while true:
		var err = loader.poll()
		if err == ERR_FILE_EOF:
			#Loading complete
			var resource = loader.get_resource()
			
			Global.current_loaded_scene = get_tree().get_root().call_deferred("add_child", resource.instance())
			current_scene.queue_free()
			loading_screen.queue_free()
			break
		if err == OK:
			#Still loading
			var progress = float(loader.get_stage())/loader.get_stage_count()
			print(progress)
			loading_screen.value = progress #.set_bar_progress(progress)
		else:
			print("Error while loading file")
			break
		
		yield(get_tree(), "idle_frame")	#Prevent frame from blocking bar
