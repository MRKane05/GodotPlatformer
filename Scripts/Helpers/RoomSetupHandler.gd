extends Node
class_name Room_Setup_Handler

func set_player_door(target_door):
	#The player should be a child of the scene root
	var player = $Player
	print("Attempting to set player to target door")
	if player:
		for child in self.get_children():
			if child.get_name() == target_door: #This is the door we want to position at
				print ("Target door found")
				player.position = child.get_positioning()
	else:
		print("NO PLAYER FOUND IN SCENE!!!")

func get_player():
	var player = $Player
	if player:
		return player
	return null

func set_player_details(cur_health, cur_ammo, cur_wallgrab, cur_airdashes, cur_airjumps):
	var player = $Player
	print("setting player details")
	if player:
		player.health = cur_health
		player.pistol_shots = cur_ammo
		player.can_wallgrab = cur_wallgrab
		player.max_airdashes = cur_airdashes
		player.max_airjumps = cur_airjumps
		
		#Finally after setting all of that make sure we update our players HUD to match the new information
		player.call_deferred("update_hud")# .update_hud()
