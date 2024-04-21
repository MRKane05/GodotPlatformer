extends Area2D
#String = the name
#FILE = hint of type
#*.tscn is a definer (or another hint if we want to put it that way)
export(String, FILE, "*.tscn") var target_stage	#Turpule export variable to select stage with arguments

func _ready():
	pass # Replace with function body.


func _on_ChangeStage_body_entered(body):
	if "Player" in body.name:
		#get_tree().change_scene(target_stage)
		pass
	
	
