extends CanvasLayer

#Details for our player that are carried over between loads
var player_health = 30
var player_shots = 6
var can_wallgrab = false
var player_airdashes = 0
var player_airjumps = 0

onready var Global = get_node("/root/Global") #Collect and assign our globals for referencing

func set_bar_progress(progress):
	$ProgressBar.value = progress
	
func change_scene(target_scene: String, current_scene, target_door) -> void:
	print("changing scene")
	if current_scene:
		if current_scene.has_method("get_player"):
			var cur_player = current_scene.get_player()
			if cur_player:
				print ("Caching player details")
				Global.target_scene = target_scene
				Global.target_door = target_door
				
				player_health = cur_player.health
				player_shots = cur_player.pistol_shots
				can_wallgrab = cur_player.can_wallgrab
				player_airdashes = cur_player.max_airdashes
				player_airjumps = cur_player.max_airjumps
				
				#This needs to be in globals in case we die...
				Global.player_health = cur_player.health;
				Global.player_shots = cur_player.pistol_shots
				Global.can_wallgrab = cur_player.can_wallgrab
				Global.player_airdashes = cur_player.max_airdashes
				Global.player_airjumps = cur_player.max_airjumps
	
	$dissolve_rect.visible = true #Because it should be disabled to save process
	$AnimationPlayer.play("dissolve")
	yield($AnimationPlayer, "animation_finished")
	
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
			
			if resource_instance.has_method("set_player_details"):
				resource_instance.call_deferred("set_player_details", player_health, player_shots, can_wallgrab, player_airdashes, player_airjumps)
			current_scene.queue_free()
			break
		if err == OK:
			#Still loading
			var progress = float(loader.get_stage())/loader.get_stage_count()
			$dissolve_rect/ProgressBar.value = progress * 100 #.set_bar_progress(progress)
		else:
			print("Error while loading file")
			break
		
		yield(get_tree(), "idle_frame")	#Prevent frame from blocking bar
	$AnimationPlayer.play_backwards('dissolve')
	yield($AnimationPlayer, "animation_finished")
	$dissolve_rect.visible = false #Because it should be disabled to save process
	#Need a control command to release control to player following loading


