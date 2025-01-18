extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$StartButton.grab_focus() #Set this as the first selected button

func _physics_process(delta):
	#Handle UI reactivity for mouse
	if $StartButton.is_hovered():
		$StartButton.grab_focus()
		
	#if $MarginContainer/VBoxContainer/VBoxContainer/QuitButton.is_hovered():
	#	$MarginContainer/VBoxContainer/VBoxContainer/QuitButton.grab_focus()


func _on_StartButton_pressed():
	#get_tree().change_scene("res://Scenes/Stage01.tscn") #load our first scene!
	LoadingScreen.change_scene("res://Scenes/TitleScreen.tscn", self, "")#"Door_Standard") #load our first scene!
	#SceneChanger.goto_scene("res://Scenes/LoadingScreen.tscn", self)

func _on_QuitButton_pressed():
	get_tree().quit() #quit
