extends Node

func set_player_door(target_door):
	#The player should be a child of the scene root
	var player = $Player
	
	if player:
		for child in self.get_children():
			if child.get_name().to_lower() == target_door.to_lower(): #This is the door we want to position at
				print ("Target door found")
				player.position = child.get_positioning()
	else:
		print("NO PLAYER FOUND IN SCENE!!!")
